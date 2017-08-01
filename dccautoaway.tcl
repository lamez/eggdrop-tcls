### DCC-AutoAWAY by Chair <chair@gws.org>
### This script will periodically check your bot's party line for idle
###   users.  Set them away after a period of time.
###  This script came from another script that didn't work correctly.
###  Any problems, questions, concerns, etc. can be addressed to
###   chair@gws.org or chair@cosmos.lod.com.
###  For eggdrop support, check out #bothelp on Undernet
###   and http://cosmos.lod.com/~chair/eggdrop


####Configure Section
# Minutes before autoaway. (0 = off)
set dccautotime 30
# Auto-away message
set dccautoawaymsg "Edin lamer po-malko"
# How often, in minutes, to check idle times.
set dccautocheck 1
# Turn the script off/on [0/1]
set dccautoaway 1

######  End Configure Section  ##########################
###
###
######You should not need to edit anything below this..##
#########################################################
####################  Script  ###########################
#########################################################

set DCCver 1.1.0
proc dccautoaway {} {
	global dccautotime dccautoawaymsg dccautocheck dccautoaway
	if {$dccautoaway == 0} {
		return 1
	}
	foreach dccinfo [dcclist] {
		if {[lindex $dccinfo 3] == "CHAT"} {
			set tempaaidx "[lindex $dccinfo 0]"
			if {[getdccaway $tempaaidx] != ""} {
				continue
			}
			if {[getdccidle $tempaaidx] == ""} {
				continue
			}
			set tempaaidle "[expr [getdccidle $tempaaidx] * 1.000 / 60 ]"
			if {$tempaaidle > $dccautotime} {
				setdccaway $tempaaidx "$dccautoawaymsg"
				putlog "DCCAutoaway: [lindex $dccinfo 1]"
			}
		}
	}
	timer $dccautocheck dccautoaway
}
foreach timer [timers] {
   if {"[lindex $timer 1]" == "dccautoaway"} {
    killtimer [lindex $timer 2] }
 }
timer $dccautocheck dccautoaway
bind dcc m dccautoaway dcc:dccautoaway
proc dcc:dccautoaway {hand idx vars} {
	global dccautoaway dccautocheck
	if {[string length "$vars"] < 1} {
		putdcc $idx "Correct Usage: .dccautoaway <on/off>"
		return 0
	}
	set ddcrstemp "[string tolower [lindex $vars 0] ]"
	if {[subst $ddcrstemp] != "on"} {
		if {$ddcrstemp != "off"} {
			putdcc $idx "Correct Usage: .dccautoaway <on/off>"
			return 0
		}
	}
	if {[subst $ddcrstemp] == "on"} {
		if {$dccautoaway == 0} {
			putdcc $idx "DCC Auto-Away Lister Enabled"
			putloglev 1 * "DCC Auto-Away Enabled"
			set dccautoaway 1
			timer $dccautocheck dccautoaway
			return 1
		}
		if {$dccautoaway == 1} {
			putdcc $idx "DCC Auto-Away Already Enabled"
			return 1
		}
	}
	if {[subst $ddcrstemp] == "off"} {
		if {$dccautoaway == 0} {
			putdcc $idx "DCC Auto-Away Already Disabled"
			return 0
		}
		if {$dccautoaway == 1} {
			putdcc $idx "DCC Auto-Away Disabled"
			set dccautoaway 0
			putloglev 1 * "DCC Auto-Away Disabled"
			return 1
		}
	}
	return 0
}

putlog "\037DCC Auto-Away\037 v1.1 by \002Chair\002 <chair@gws.org> loaded."
putlog "\037DCC Auto-Away\037: Auto-away after $dccautotime mins"
