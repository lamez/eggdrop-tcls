##################################
### LinkedBots.tcl             ###
### Version 1.2                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

###########################################################################
## This script will message a list of linked and down bots to a channel  ##
## every X minutes. Messages will not be sent if no users on the channel ##
## match the required flags. Down bots must be in the bot's userlist.    ##
###########################################################################

##########################################################
## Just load the script, edit the settings, and rehash. ##
##########################################################

#########################################
# Set the flags to be checked for here. #
#########################################

set linkedbots_setting(flags) "nmto"

########################################
# How often should info be sent to the #
# channel (time is in minutes)?        #
########################################

set linkedbots_setting(timer) "15"

#######################################################
# Enable use of bold in some messages to the channel? #
#######################################################

set linkedbots_setting(bold) 1

##############################################
# Put down bots and linked bots on one line? #
##############################################

set linkedbots_setting(oneline) 0

####################################
# Set the channel to message here. #
####################################

set linkedbots_setting(chan) "#|DAWG|Net"

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002LINKEDBOTS:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002LINKEDBOTS:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

if {[lsearch -glob [timers] "*linkedbots_send *"] == -1} { timer $linkedbots_setting(timer) linkedbots_send }

proc linkedbots_bold {text} {
	if {$::linkedbots_setting(bold)} { return \002$text\002 } { return $text }
}
proc linkedbots_send {} {
	set locbot ${::botnet-nick}
	if {![validchan $::linkedbots_setting(chan)] || ![botonchan $::linkedbots_setting(chan)]} { return }
	foreach u [chanlist $::linkedbots_setting(chan)] {
		if {![matchattr [nick2hand $u] $::linkedbots_setting(flags)]} { continue }
		foreach b [userlist b] {
			if {[lsearch -exact [bots] $b] == -1 && ![string match [string tolower $locbot] [string tolower [join $b]]]} { lappend downbots $b, }
		}
		foreach bot [bots] { lappend linkedbots "$bot," }
		set down [expr ([info exists downbots])?"$downbots":"None"]
		set linked [expr ([info exists linkedbots])?"$linkedbots":"None"]
		regsub -all -- "," "[lindex $down end]" "" end
		regsub -all -- "," "[lindex $linked end]" "" end2
		set down [lreplace $down end end $end]
		set linked [lreplace $linked end end $end2]
		if {$::linkedbots_setting(oneline)} { putserv "PRIVMSG $::linkedbots_setting(chan) :[linkedbots_bold {Linked bots:}] $linked. [linkedbots_bold {Down bots:}] $down." ; return }
		putserv "PRIVMSG $::linkedbots_setting(chan) :[linkedbots_bold {Linked bots:}] $linked."
		putserv "PRIVMSG $::linkedbots_setting(chan) :[linkedbots_bold {Down bots:}] $down."
		break
	}
	if {[lsearch -glob [timers] "*linkedbots_send *"] == -1} { timer $::linkedbots_setting(timer) linkedbots_send }
}
putlog "\002LINKEDBOTS:\002 LinkedBots.tcl Version 1.2 by Wcc is loaded."