######################################################
### IRCopScan.tcl by _]NiX[_ <nix@valium.org>      ###
### scan for irc operator who joined your channels ###
### http://valium.org                              ###
######################################################

# start IRCopScan.tcl by default?
set operscan(start) 1

# send a notice to channel operator (only if bot is chanop)
set operscan(noticechanop) 0

######################################################

bind join - * IRCopScanOnJoin
proc IRCopScanOnJoin {nick uh hand chan} {
	global operscan scanoperchan botnick
	if {$operscan(start) && $nick != "$botnick"} {
		set scanoperchan($nick) "$chan"
		putserv "USERHOST $nick"
	}
}

bind raw - "302" IRCopScan302
proc IRCopScan302 {from key text} {
	global operscan scanoperchan
	set text "[lindex $text 1]"
	set nick [lindex [split "$text" :=*] 1]
	if {($operscan(start)) && ([info exists scanoperchan($nick)]) && ([string match *\\* [lindex [split "$text" =] 0]])} {
		set chan $scanoperchan($nick)
		putlog "$nick is an IRC Operator - detected on $chan"
		if {([botisop $scanoperchan($nick)]) && ($operscan(noticechanop))} {
			foreach u [chanlist $chan] {
				if {[isop $u $chan]} {putserv "NOTICE $u :$nick is an IRC Operator - detected on $chan"}
			}
		}
		unset scanoperchan($nick)
	}
}

bind dcc m IRCopScan IRCopScanDCC
proc IRCopScanDCC {hand idx args} {
	global operscan
	if {$operscan(start)} {
		set operscan(start) 0
		putdcc $idx "IRCop scanner deactivated"
	} {
		set operscan(start) 1
		putdcc $idx "IRCop scanner activated"
	}
	return 1
}

putlog "IRCopScan.tcl - (.ircopscan to turn on/off)"