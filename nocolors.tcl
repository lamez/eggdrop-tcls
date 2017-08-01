##################################
### NoColors.tcl               ###
### Version 1.2                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

###################################################################################
## This script warns users if they use colored text on the channel. It warns on  ##
## the first offense, kicks on the second, and bans on the third.                ##
###################################################################################

##############
## COMMANDS ##
################################################################
## DCC ## .chanset <channel> +/-nocolors                      ##
######### Enables or disables color protection for a channel. ##
################################################################

##########################################################
## Just load the script, edit the settings, and rehash. ##
##########################################################

#############################################################
# Set the time in minutes before a ban expiers here. If set #
# to 0, the ban will not be removed.                        #
#############################################################

set nocolors_setting(exp) "0"

########################################################
# Set the warning message sent to the channel here.    #
# %nick is substituted with the offending user's nick. #
########################################################

set nocolors_setting(msg) "%nick, please do use colors in this channel."

##################################################
# Set the first kick message text here. %nick is #
# substituted with the offending user's nick.    #
##################################################

set nocolors_setting(kmsg) "Please do use colors in this channel. You will be banned on the next offense."

###################################################
# Set the second kick message text here. %nick is #
# substituted with the offending user's nick.     #
###################################################

set nocolors_setting(kmsg2) "Please do use colors in this channel."

#############################
# Set the ban type here:    #
# 1 - *!*@host.domain	    #
# 2 - *!user@host.domain    #
# 3 - nick!*@host.domain    #
# 4 - nick!user@host.domain #
# 5 - *!?user@*.host.domain #
#############################

set nocolors_setting(bantype) "1"

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002NOCOLORS:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002NOCOLORS:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

setudef flag nocolors

bind PUBM - * nocolors_pubm
bind CTCP - ACTION nocolors_action
bind NOTC - * nocolors_notc

proc nocolors_maskban {nick uhost} {
	global nocolors_setting
	switch -- $nocolors_setting(bantype) {
		1 { set ban "*!*@[lindex [split $uhost @] 1]" }
		2 { set ban "*!$uhost" }
		3 { set ban "$nick!*@[lindex [split $uhost @] 1]" }
		4 { set ban "$nick!$uhost" }
		5 { set ban [maskhost $uhost] }
		default { set ban "*!*@[lindex [split $uhost @] 1]" }
	}
	return $ban
}
proc nocolors_pubm {nick uhost hand chan text} {
	if {[lsearch -exact [channel info $chan] +nocolors] == -1} { return }
	nocolors_parse $nick $chan $uhost $hand $text
}
proc nocolors_notc {nick uhost hand text dest} {
	if {[isbotnick $dest] || ![validchan $dest] || [lsearch -exact [channel info $dest] +nocolors] == -1} { return }
	nocolors_parse $nick $dest $uhost $hand $text
}
proc nocolors_action {nick uhost hand dest key text} {
	if {[isbotnick $dest] || ![validchan $dest] || [lsearch -exact [channel info $dest] +nocolors] == -1} { return }
	nocolors_parse $nick $dest $uhost $hand $text
}
proc nocolors_parse {nick chan uhost hand text} {
	global nocolors_array nocolors_setting
	set banmask [nocolors_maskban $nick $uhost]
	set name [string tolower $chan]![join [lindex [split $uhost @] 1]]
	if {![info exists nocolors_array($name)]} { set nocolors_array($name) 0 }
	if {[isop $nick $chan] || [matchattr $hand o|o $chan] || ![botisop $chan] || ![regexp \003|\026 $text]} { return }
	incr nocolors_array($name)
	switch -- $nocolors_array($name) {
		1 {
   			regsub -all -- %nick $nocolors_setting(msg) $nick msg
			putserv "PRIVMSG $chan :$msg"
		}
		2 {
			regsub -all -- %nick $nocolors_setting(kmsg) $nick msg
			putserv "KICK $chan $nick :$msg"
		}
		default {
			regsub -all -- %nick $nocolors_setting(kmsg2) $nick msg
			putserv "MODE $chan +b $banmask"
			puthelp "KICK $chan $nick :$msg"
			if {$nocolors_setting(exp) != 0} { timer $nocolors_setting(exp) [list putserv "MODE $chan -b $banmask"] }
		}
	}
}
putlog "\002NOCOLORS:\002 NoColors.tcl Version 1.2 by Wcc is loaded."
