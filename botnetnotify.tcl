##################################
### BotnetNotify.tcl           ###
### Version 1.8                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

#########################################################################
## This script notifies a channel (or channels) what a user joins the  ##
## partyline, when a ser leaves the partyline, when a bot disconnects, ##
## when a bot links, and when a user changes their handle. If hub mode ##
## is set to 1, it will notify when any bot links or delinks.          ##
#########################################################################

##############
## COMMANDS ##
##################################################################
## DCC ## .chanset <channel> +/-botnetnotify                    ##
######### This enables or disables botnet activity notification ##
######### for a channel.                                        ##
##################################################################

#############################################################
## Just load the script, edit the settings, and rehash.    ##
#############################################################

##################################################################
# If you want bot links and unlinks to be announced, set 1 here. #
##################################################################

set botnetnotify_setting(hub) 0

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002BOTNETNOTIFY:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002BOTNETNOTIFY:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }
setudef flag botnetnotify

foreach botnetnotify_bind [list chon chof link disc] { bind $botnetnotify_bind - * botnetnotify_$botnetnotify_bind }

proc botnetnotify_chanout {text} {
	foreach chan [channels] {
		if {[botonchan $chan] && [lsearch -exact [channel info $chan] +botnetnotify] != -1} { putserv "PRIVMSG $chan :$text" }
	}
}
proc botnetnotify_chon {hand idx} { botnetnotify_chanout "$hand has joined the partyline." }
proc botnetnotify_chof {hand idx} { botnetnotify_chanout "$hand has left the partyline." }
proc botnetnotify_link {bot to} {
	if {$::botnetnotify_setting(hub)} { botnetnotify_chanout "$bot is now linked to $to." }
}
proc botnetnotify_disc {botname} {
	if {$::botnetnotify_setting(hub)} { botnetnotify_chanout "$botname has disconnected from the botnet." }
}
putlog "\002BOTNETNOTIFY:\002 BotnetNotify.tcl Version 1.8 by Wcc is loaded."