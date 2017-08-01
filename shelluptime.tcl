##################################
### ShellUptime.tcl            ###
### Version 1.0                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

##########################################################
## This script shows the uptime of the Eggdrop's shell. ##
##########################################################

##############
## COMMANDS ##
#####################################################
## DCC ## .suptime (Can be changed)                ##
######### Shows the uptime of the Eggdrop's shell. ##
#####################################################
## PUB ## !suptime (Can be changed)                ##
######### Shows the uptime of the Eggdrop's shell. ##
#####################################################

##########################################################
## Just load the script, edit the settings, and rehash. ##
##########################################################

#############################
# Set the dcc command here. #
#############################

set shelluptime_setting(d_cmd) "suptime"

#############################
# Set the pub command here. #
#############################

set shelluptime_setting(p_cmd) "!suptime"

#################################################
# Set the flag required to use the script here. #
#################################################

set shelluptime_setting(flag) "+m"

###################################
# Enable use of bold in dcc chat? #
###################################

set shelluptime_setting(bold) 1

###############################################
# Prefix "SHELLUPTIME:" in dcc chat messages? #
###############################################

set shelluptime_setting(SHELLUPTIME:) 1

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002SHELLUPTIME:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002SHELLUPTIME:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

bind dcc $shelluptime_setting(flag) $shelluptime_setting(d_cmd) shelluptime_dcc
bind pub $shelluptime_setting(flag) $shelluptime_setting(p_cmd) shelluptime_pub

proc shelluptime_dopre {} {
	if {!$::shelluptime_setting(SHELLUPTIME:)} { return "" }
	if {!$::shelluptime_setting(bold)} { return "SHELLUPTIME: " }
	return "\002SHELLUPTIME:\002 "
}
proc shelluptime_dcc {hand idx text} {
	putdcc $idx "[shelluptime_dopre][shelluptime_getuptime]"
}
proc shelluptime_pub {nick uhost hand chan text} {
	putserv "PRIVMSG $chan :[shelluptime_getuptime]"
}
proc shelluptime_getuptime {} {
	if {[catch {exec which uptime}]} { return "Error: This system is not support 'uptime'." }
	if {[catch {exec uptime} uptime]} { return "Error: $uptime" }
	return $uptime
}
putlog "\002SHELLUPTIME:\002 ShellUptime.tcl Version 1.0 by Wcc is loaded."
