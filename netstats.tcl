##################################
### NetStats.tcl               ###
### Version 1.2                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

#################################################################################
## This script writes the output of /LUSERS, /MAP, /LINKS, and /LIST to a text ##
## file every X minuets.                                                       ##
#################################################################################

##########################################################
## Just load the script, edit the settings, and rehash. ##
##########################################################

#################################
# Set the output filename here. #
#################################

set netstats_setting(file_output) "netstats.txt"

#####################################################
# Set the time in minuets to update the file here. #
#####################################################

set netstats_setting(timer_update) "10"

####################
# Code begins here #
####################

bind raw - 322 netstats_listrecieve
bind raw - 323 netstats_listend
bind raw - 251 netstats_write_lusers
bind raw - 252 netstats_write_lusers
bind raw - 254 netstats_write_lusers
bind raw - 255 netstats_write_lusers
bind raw - 265 netstats_write_lusers
bind raw - 266 netstats_write_lusers
bind raw - 364 netstats_parse_links
bind raw - 365 netstats_list

if {![string match *netstats_update* [timers]]} {
	timer $netstats_setting(timer_update) netstats_update
}
proc netstats_parse_links {from keyword text} {
	global netstats_links_data netstats_uplink netstats_localserver
	set netstats_localserver $from
	set netstats_links_data([lindex [split $text] 1]) [lrange [split $text] 1 end]
	set netstats_uplink([lindex [split $text] 1]) [lindex [split $text] 2]
}
proc netstats_list {from keyword text} {
	putserv "LIST"
}
proc netstats_write_lusers {from keyword text} {
	global netstats_setting netstats_lusers_data
	if {($keyword == 252) || ($keyword == 254)} {
		regsub -all -- ":" "[split $text]" "" text
	}
	set netstats_lusers_data($keyword) [string trimleft [lrange $text 1 end] :]
	if {$keyword == 266} {
		putserv "LINKS"
	}
}
proc netstats_listrecieve {from keyword text} {
	global netstats_list_data
	regsub -all -- "^:" "[lindex [split $text] 3]" "" text2
	set text [lreplace [split $text] 3 3 $text2]
	set netstats_list_data([lindex $text 1]) "[lrange $text 2 end]"
}
proc netstats_listend {from keyword text} {
	netstats_do_final
}
proc netstats_do_final {} {
	global netstats_setting netstats_links_data netstats_localserver netstats_list_data netstats_lusers_data
	set ffd [open $netstats_setting(file_output) w+]
	puts $ffd "Network Stats"
	puts $ffd "Connected to $netstats_localserver"
	puts $ffd "\n"
	puts $ffd "/LUSERS:"
	foreach i [array names netstats_lusers_data] {
		puts $ffd "$netstats_lusers_data($i)"
	}
	puts $ffd "\n"
	puts $ffd "/LIST:"
	foreach i [array names netstats_list_data] {
		regsub -all -- ":$" "[join $netstats_list_data($i)]" "" text2
		puts $ffd "$i $text2"
	}
	puts $ffd "\n"
	puts $ffd "/MAP:"
	puts $ffd "     $netstats_localserver     "
	netstats_do_netmap "     " $ffd $netstats_localserver
	puts $ffd "\n"
	puts $ffd "/LINKS:"
	foreach i [array names netstats_links_data] {
		puts $ffd "[join $netstats_links_data($i)]"
	}
	close $ffd
}
proc netstats_update {} {
	global netstats_setting netstats_uplink
	if {[info exists netstats_uplink]} {
		unset netstats_uplink
	}
	putserv "LUSERS"
	if {![string match *netstats_update* [timers]]} {
		timer $netstats_setting(timer_update) netstats_update
	}
}
proc netstats_do_netmap {indent fd server} {
	global netstats_uplink
	foreach server2 [array names netstats_uplink] {
		if {(![string match -nocase $server $server2]) && ([string match -nocase $netstats_uplink($server2) $server])} { 
			lappend downlinks $server2
		}
	}
	if {[info exists downlinks]} {
		foreach server2 $downlinks {
			if {[string match -nocase $server2 [lindex $downlinks end]]} {
				puts $fd "$indent `-$server2     "
				netstats_do_netmap "$indent  " $fd $server2
			} else {
				puts $fd "$indent |-$server2     "
				netstats_do_netmap "$indent |   " $fd $server2
			}
		}
	}
}
putlog "\002NETSTATS:\002 NetStats.tcl Version 1.2 by Wcc is loaded."
putlog "\002NETSTATS:\002 Updating stats file every $netstats_setting(timer_update) minutes."