##################################
### DieAuth.tcl                ###
### Version 2.1                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

##############################################################################
## This script makes owners (+n users) enter an authorization code to use   ##
## ".die". You can also password protect the .die command. It also disables ##
## /msg <bot> die.                                                          ##
##############################################################################

##############
## COMMANDS ##
##########################################
## DCC ## .chanset <channel> +/-dieauth ##
######### Enables or disables dieauth   ##
######### notification for a channel.   ##
##########################################

###########################################################
## Just load the script, edit the settings, and restart. ##
###########################################################

#####################################################
# Require a confirmation code to shut down the bot? #
#####################################################

set dieauth_setting(useauth) 1

###########################################
# Require a password to shutdown the bot? #
###########################################

set dieauth_setting(usepass) 0

####################################################
# Broadcast a notice when a shutdown starts/fails? #
####################################################

set dieauth_setting(cast) 1

##################################
# Log when shutdowns start/fail? #
##################################

set dieauth_setting(log) 1

##################################################
# Set the length of the authorization code here. #
##################################################

set dieauth_setting(keylength) 8

############################################################
# Set the 1st encryption string for the confirmation code. #
# Do not use dictionary words.                             #
############################################################

set dieauth_setting(key1) "515hgd484R48gR54try000f7eD5G"

############################################################
# Set the 2nd encryption string for the confirmation code. #
# Do not use dictionary words.                             #
############################################################

set dieauth_setting(key2) "828Ff856fh447rh74"

##############################################
# Set the password for killing the bot here. #
##############################################

set dieauth_setting(pass) "PASSWORD_HERE"

######################################################
# Append users handle to the end of the die message? #
######################################################

set dieauth_setting(append) 1

###################################
# Enable use of bold in DCC chat? #
###################################

set dieauth_setting(bold) 1

###########################################
# Prefix "DIEAUTH:" in DCC chat messages? #
###########################################

set dieauth_setting(DIEAUTH:) 1

####################
# Code begins here #
####################

if {$numversion < 1060700} { putlog "\002DIEAUTH:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.7 or later." }
if {[info tclversion] < 8.2} { putlog "\002DIEAUTH:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

setudef flag dieauth
unbind dcc n|- die *dcc:die
unbind msg n|- die *msg:die
bind dcc +n die dieauth_die
bind dcc +n dieauth dieauth_dieauth

proc dieauth_dopre {} {
	if {!$::dieauth_setting(DIEAUTH:)} { return "" }
	if {!$::dieauth_setting(bold)} { return "DIEAUTH: " }
	return "\002DIEAUTH:\002 "
}
proc dieauth_putdcc {idx text} { putdcc $idx "[dieauth_dopre]$text" }
proc dieauth_chnotify {text} {
	foreach chan [channels] {
		if {[botonchan $chan] && [lsearch -exact [channel info $chan] +dieauth] != -1} { putserv "PRIVMSG $chan :$text" }
	}
}
proc dieauth_die {hand idx text} {
	if {!$::dieauth_setting(usepass) && !$::dieauth_setting(useauth)} { die $text[expr {($::dieauth_setting(append))?" \($hand\)":""}] ; return }
	if {$::dieauth_setting(usepass)} { set ::dieauth_data(valid) [dieauth_dopass $hand $idx $text] } { set ::dieauth_data(valid) 1 }
	if {!$::dieauth_setting(useauth) || !$::dieauth_data(valid)} { return }
	regsub -all -- {[a-z]|[A-Z]} $::dieauth_setting(key2) [set rkey [rand 100]] dieauth_key3
	set ::dieauth_data(diecode) [string range [md5 [encrypt [encrypt "[rand 5000]$hand$idx" $::dieauth_setting(key1)] $dieauth_key3]] 0 [expr $::dieauth_setting(keylength) - 1]]
	set ::dieauth_data(diehand) $hand
	if {!$::dieauth_setting(usepass)} { set ::dieauth_data(reason) [expr {($text != "")?"$text[expr {($::dieauth_setting(append))?" \($hand\)":""}]":"Authorized by $hand"}] }
	dieauth_chnotify "Shutdown initiated by $hand. A confirmation code has been sent."
	if {$::dieauth_setting(cast)} { dccbroadcast "[dieauth_dopre]Shutdown initiated by $hand. A confirmation code has been sent." }
	if {$::dieauth_setting(log)} { putlog "[dieauth_dopre]Shutdown initiated by $hand. A confirmation code has been sent." }
	putdcc $idx "[dieauth_dopre]Please type .dieauth $::dieauth_data(diecode) now to confirm shutdown. All attempts are logged."
}
proc dieauth_dieauth {hand idx text} {
	if {!$::dieauth_setting(useauth)} { dieauth_putdcc $idx "Die authorization is not enabled." ; return }
	if {$text == ""} { dieauth_putdcc $idx "Usage: .dieauth <code>" ; return }
	if {![info exists ::dieauth_data(valid)] || ![info exists ::dieauth_data(diecode)] || ![info exists ::dieauth_data(diehand)] || ![info exists ::dieauth_data(reason)]} { dieauth_putdcc $idx "You must type .die before using .dieauth." ; return }
	if {[string compare $::dieauth_data(diehand) $hand] != 0} {
		dieauth_putdcc $idx "Your hand did not initiate the die command. The die code has been reset, and the attempt logged."
		dieauth_chnotify "Invalid die attempt from $hand: Invalid hand."
		if {$::dieauth_setting(cast)} { dccbroadcast "[dieauth_dopre]Invalid die attempt from $hand: Invalid hand." }
		if {$::dieauth_setting(log)} { putlog "[dieauth_dopre]Invalid die attempt from $hand: Invalid hand." }
		return
	}
	if {[string compare [join [lrange [split $text] 0 0]] $::dieauth_data(diecode)] != 0} {
		dieauth_putdcc $idx "Invalid die code. The die code has been reset, you must now re-initiate the shutdown processes."
		dieauth_chnotify "Invalid die attempt from $hand: Invalid die code."
		if {$::dieauth_setting(cast)} { dccbroadcast "[dieauth_dopre]Invalid die attempt from $hand: Invalid die code." }
		if {$::dieauth_setting(log)} { putlog "[dieauth_dopre]Invalid die attempt from $hand: Invalid die code." }
		unset ::dieauth_data(diecode) ::dieauth_data(diehand)
		return
	}
	die $::dieauth_data(reason)
}
proc dieauth_dopass {hand idx text} {
	if {$text == ""} {
		dieauth_putdcc $idx "Usage: .die <password> \[reason\]"
		set ::dieauth_data(valid) 0
		return 0
	}
	if {[string compare [join [lrange [split $text] 0 0]] $::dieauth_setting(pass)] == 0} {
		set ::dieauth_data(reason) [expr {([lindex [split $text] 1] != "")?"[join [lrange [split $text] 1 end]][expr {($::dieauth_setting(append))?" \($hand\)":""}]":"Authorized by $hand"}]
		if {!$::dieauth_setting(useauth)} { die $::dieauth_data(reason) }
		return 1
	}
	dieauth_putdcc $idx "Invalid die password, attempt has been logged."
	dieauth_chnotify "Invalid die attempt from $hand: Invalid password."
	if {$::dieauth_setting(log)} { putlog "[dieauth_dopre]Invalid die attempt from $hand: Invalid password." }
	if {$::dieauth_setting(cast)} { dccbroadcast "[dieauth_dopre]Invalid die attempt from $hand: Invalid password." }
	return 0
}
putlog "\002DIEAUTH:\002 DieAuth.tcl 2.1 by Wcc is loaded."
