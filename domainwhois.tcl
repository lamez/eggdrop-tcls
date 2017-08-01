############################
### DomainWhois.tcl      ###
### Version 1.2          ###
### By Wcc               ###
### wcc@techmonkeys.org  ###
### http://dawg.dynu.com ###
### EFnet #|DAWG|Tcl     ###
############################

############################################################################
### Copyright © 2000 - 2001 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

#############################################################################
## This script connects to the Network Solutions whois server and displays ##
## the registration information for a domain name. You can also set your   ##
## own whois server to connect to.					   ##
#############################################################################

##############
## COMMANDS ##
##############################################
## DCC ## .dwhois <domain> (Can be changed) ##
######### Displays the domain registration  ##
######### information for a domain.	    ##
##############################################

##########################################################
## Just load the script, set the variables, and rehash. ##
##########################################################

###########################################################
# Set the flag required to preform internic lookups here. #
###########################################################

set domainwhois_setting(flag) "o|o"

#########################################################
# Set the command for performing internic lookups here. #
#########################################################

set domainwhois_setting(cmd) "dwhois"

#######################################
# Set the lookup server address here. #
# Format: <server>:<port>             #
#######################################

set domainwhois_setting(server) "networksolutions.com:43"

###################################
# Enable use of bold in DCC chat? #
###################################

set domainwhois_setting(bold) 1

###############################################
# Prefix "DOMAINWHOIS:" in DCC chat messages? #
###############################################

set domainwhois_setting(DOMAINWHOIS:) 1

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002DOMAINWHOIS:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002DOMAINWHOIS:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

bind dcc $domainwhois_setting(flag) $domainwhois_setting(cmd) domainwhois_connect

proc domainwhois_dopre {} {
	global domainwhois_setting
	if {!$domainwhois_setting(DOMAINWHOIS:)} { return "" }
	if {!$domainwhois_setting(bold)} { return "DOMAINWHOIS: " }
	return "\002DOMAINWHOIS:\002 "
}
proc domainwhois_connect {hand idx text} {
	global domainwhois_setting
	if {$text == ""} { putidx $idx "[domainwhois_dopre]Usage: .$domainwhois_setting(cmd) <domain>" ; return }
	set server [lindex [split $domainwhois_setting(server) :] 0]
	set port [lindex [split $domainwhois_setting(server) :] 1]
	if {[catch {set sock [socket -async $server $port]} error]} {
		putidx $idx "[domainwhois_dopre]Connection to $domainwhois_setting(server) failed \([string totitle $error]\)."
		return
	}
	putidx $idx "[domainwhois_dopre]Looking up [lindex $text 0]."
	set timerid [utimer 15 [list domainwhois_timeout $sock $idx]]
	fileevent $sock writable [list domainwhois_connected $sock $idx [lindex [split $text] 0] $timerid]
}
proc domainwhois_connected {sock idx domain timerid} {
	global domainwhois_setting
	killutimer $timerid
	if {[set error [fconfigure $sock -error]] != ""} {
		putidx $idx "[domainwhois_dopre]Connection to $domainwhois_setting(server) port $domainwhois_setting(port) failed. \([string totitle $error]\)"
		close $sock
		return
	}
	fconfigure $sock -translation binary -buffering none -blocking 1
	fileevent $sock writable [list domainwhois_write $sock $idx $domain]
	fileevent $sock readable [list domainwhois_read $sock $idx]
	putidx $idx "[domainwhois_dopre]Connection to $domainwhois_setting(server) accepted."
}
proc domainwhois_timeout {sock idx} {
	global domainwhois_setting
	close $sock
	putidx $idx "[domainwhois_dopre]Connection to $domainwhois_setting(server) timed out."
}
proc domainwhois_read {sock idx} {
	global domainwhois_setting
	if {[gets $sock read] == -1} {
		putidx $idx "[domainwhois_dopre]Connection to $domainwhois_setting(server) closed."
		close $sock
		return
	}
	putidx $idx "[domainwhois_dopre]> $read"
}
proc domainwhois_write {sock idx domain} {
	puts $sock "WHOIS $domain"
	fileevent $sock writable {}
}
putlog "\002DOMAINWHOIS:\002 DomainWhois.tcl Version 1.2 by Wcc is loaded."