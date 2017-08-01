##################################
### BanTools.tcl               ###
### Version 1.2                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

########################################################################
## This script provides tools for managing bans on the bot. This also ##
## replaces BanCount.tcl.                                             ##
########################################################################

##############
## COMMANDS ##
###################################################################
## DCC ## .bans weed [channel]                                   ##
######### Removes all redundant bans from the bot's banlist.     ##
######### ------------------------------------------------------ ##
######### .bans count [channel]                                  ##
######### Returns the total number of bans in the bot's banlist. ##
######### ------------------------------------------------------ ##
######### .bans clearmatch <string> [channel]                    ##
######### Removes any bans matching the given string. Wildcards  ##
######### are supported.                                         ##
###################################################################

##########################################################
## Just load the script, edit the settings, and rehash. ##
##########################################################

###############################################################
# Set the flag required for using the bantools commands here. #
###############################################################

set bantools_setting(flag) "+m"

###################################
# Enable use of bold in DCC chat? #
###################################

set bantools_setting(bold) 1

############################################
# Prefix "BANTOOLS:" in DCC chat messages? #
############################################

set bantools_setting(BANTOOLS:) 1

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002BANTOOLS:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002BANTOOLS:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

bind filt $bantools_setting(flag) ".bans weed *" bantools_weed
bind filt $bantools_setting(flag) ".bans clearmatch *" bantools_clearmatch
bind filt $bantools_setting(flag) ".bans count *" bantools_count

proc bantools_dopre {} {
	global bantools_setting
	if {!$bantools_setting(BANTOOLS:)} { return "" }
	if {!$bantools_setting(bold)} { return "BANTOOLS: " }
	return "\002BANTOOLS:\002 "
}
proc bantools_ncm {pattern string} { return [string match [string tolower $pattern] [string tolower $string]] }
proc bantools_weed {idx text} {
	set count 0
	if {[lindex [split $text] 2] != "" && ![validchan [lindex [split $text] 2]]} { putdcc $idx "[bantools_dopre][join [lrange [split $text] 2 2]] is not a valid channel." ; return }
	foreach b [set allbans [expr {([lindex [split $text] 2] == "")?[banlist]:[banlist [lindex [split $text] 2]]}]] {
		foreach b2 $allbans {
			if {![bantools_ncm $b $b2] || [string compare [string tolower [join $b]] [string tolower [join $b2]]] == 0} { continue }
			if {[lindex [split $text] 2] == ""} { killban $b2 } { killchanban [lindex [split $text] 2] $b2 }
			incr count
		}
	}
	putdcc $idx "[bantools_dopre]Removed $count ban[expr {($count != 1)?"s":""}]."
}
proc bantools_clearmatch {idx text} {
	set count 0
	if {[lindex [split $text] 2] == ""} { putdcc $idx "[bantools_dopre]Usage: .bans clearmatch <match string> \[chan\]" ; return }
	if {[lindex [split $text] 3] != "" && ![validchan [lindex [split $text] 3]]} { putdcc $idx "[bantools_dopre][join [lrange [split $text] 3 3]] is not a valid channel." ; return }
	foreach ban [expr {([lindex [split $text] 3] == "")?[banlist]:[banlist [lindex [split $text] 3]]}] {
		set b [lindex $ban 0]
		if {![bantools_ncm [join [lrange [split $text] 2 2]] [join $b]]} { continue }
		if {[lindex [split $text] 3] == ""} { killban $b } { killchanban [lindex [split $text] 3] $b }
		incr count
	}
	putdcc $idx "[bantools_dopre]Removed $count ban[expr {($count != 1)?"s":""}]."
}
proc bantools_count {idx text} {
	if {[set chan [join [lrange [split $text] 2 2]]] == ""} {
		set bans [llength [banlist]]
		putdcc $idx "[bantools_dopre]There [expr {($bans != 1)?"are":"is"}] currently $bans ban[expr {($bans != 1)?"s":""}] in the global ban list."
		return
	}
	if {![validchan $chan]} { putdcc $idx "[bantools_dopre]$chan is not a valid channel." ; return }
	set bans [llength [banlist $chan]]
	putdcc $idx "[bantools_dopre]There [expr {($bans != 1)?"are":"is"}] currently $bans ban[expr {($bans != 1)?"s":""}] in the ban list for $chan." 
}
putlog "\002BANTOOLS:\002 BanTools.tcl Version 1.2 by Wcc is loaded."