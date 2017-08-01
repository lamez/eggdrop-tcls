##################################
### OpNotice.tcl               ###
### Version 1.9                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

####################################################################
## This script sends a notice or privmsg to all ops on a channel. ##
####################################################################

##############
## COMMANDS ##
#############################################################################
## DCC ## .onotice <channel> <message>                                     ##	
######### Sends a notice to all ops on the channel you specify. The sender ##
######### must have +o for the channel. The bot must be op'd for a user to ##
######### send an op notice. NOTE: Owners (+n) can override this.          ##
######### ---------------------------------------------------------------- ##
######### .omsg <channel> <message>                                        ##
######### Sends a msg to all ops on the channel you specify. The sender    ##
######### must have +o for the channel. The bot must be op'd for a user to ##
######### send an op notice. NOTE: Owners (+n) can override this.          ##
#############################################################################

##########################################################
## Just load the script, edit the settings, and rehash. ##
##########################################################

###################################
# Set the op-notice command here. #
###################################

set opnotice_setting(onotice) "onotice"

################################
# Set the op-msg command here. #
################################

set opnotice_setting(omsg) "omsg"

################################################
# Does your network support /notice @#channel? #
################################################

set opnotice_setting(chantarg) 1

###################################
# Enable use of bold in DCC chat? #
###################################

set opnotice_setting(bold) 1

############################################
# Prefix "OPNOTICE:" in DCC chat messages? #
############################################

set opnotice_setting(OPNOTICE:) 1

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002OPNOTICE:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x." }
if {[info tclversion] < 8.2} { putlog "\002OPNOTICE:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

bind dcc - $opnotice_setting(onotice) opnotice_onotice
bind dcc - $opnotice_setting(omsg) opnotice_omsg

proc opnotice_dopre {} {
	if {!$::opnotice_setting(OPNOTICE:)} { return "" }
	if {!$::opnotice_setting(bold)} { return "OPNOTICE: " }
	return "\002OPNOTICE:\002 "
}
proc opnotice_onotice {hand idx text} {
	if {[string compare [join [lrange [split $text] 1 1]] ""] == 0} { putdcc $idx "[opnotice_dopre]Usage: .$::opnotice_setting(onotice) <channel> <message>" ; return }
	if {![matchattr $hand o|o [set chan [join [lrange [split $text] 0 0]]]]} { putdcc $idx "What? You need '.help'" ; return }
	if {![botisop $chan] && ![matchattr $hand +n]} { putdcc $idx "[opnotice_dopre]I do not have ops on $chan, and you do not have access to override." ; return }
	putdcc $idx "[opnotice_dopre][set data "Op notice from $hand: [join [lrange [split $text] 1 end]]"]"
	if {$::opnotice_setting(chantarg)} { putserv "NOTICE @$chan :$data" ; return }
	foreach o [chanlist $chan] {
		if {[isop $o $chan] && ![isbotnick $o]} { putserv "NOTICE $o :$data" }
	}
}
proc opnotice_omsg {hand idx text} {
	if {[string compare [join [lrange [split $text] 1 1]] ""] == 0} { putdcc $idx "[opnotice_dopre]Usage: .$::opnotice_setting(omsg) <channel> <message>" ; return }
	if {![matchattr $hand o|o [set chan [lindex [split $text] 0]]]} { putdcc $idx "What? You need '.help'" ; return }
	if {![botisop $chan] && ![matchattr $hand +n]} { putdcc $idx "[opnotice_dopre]I do not have ops on $chan, and you do not have access to override." ; return }
	putdcc $idx "[opnotice_dopre][set data "Op msg from $hand: [join [lrange [split $text] 1 end]]"]"
	foreach o [chanlist $chan] {
		if {[isop $o $chan] && ![isbotnick $o]} { putserv "PRIVMSG $o :$data" }
	}
}

putlog "\002OPNOTICE:\002 OpNotice.tcl Version 1.9 by Wcc is loaded."
