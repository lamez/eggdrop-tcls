#####################################################################
# SuperBitch v0.45 28-10-01 06:10 by IsP@Undernet (q_lander@hotmail.com)
#
# Superbitch is a manual opping de-oper for non-bot Ops.
#
# DO NOT EDIT THIS SCRIPT FOR *ANYTHING*! ALL COMMANDS ARE IN DCC CHAT
# WITH YOUR BOT! SEE .help superbitch
#
# WHAT?! Another Superbitch script? Yes, but this one is the BEST
# you've seen! Don't bother with script settings, just do it all in
# dcc chat for each channel! (For Eggdrop 1.6.X+) THATS RIGHT!
# JUST LOAD THIS SCRIPT CHANGE NOTHING IN HERE, AND DO IT ALL IN
# DCC CHAT! With the help file all you type is .help superbitch
# and all the info you need is there!
#
# This script will add 2 new channel settings 'superbitch-user' & 
# 'superbitch-op'. Place the superbitch.help file in the help dir
# then use .help superbitch for setting info.
# 
# PLEASE REPORT ANY BUGS!
#
# NOTE: This script binds the RAW mode command, and does not use
# the 'mode' bind - I needed ALL modes on 1 line piped to the proc,
# and the fastest way to do it was through RAW. If this makes no
# sense, then just ignore it. 
#
# It's late and I've had little sleep! MWHAHAHAHA ;P
#
# USAGE/SETTINGS: (see '.help superbitch')
#
# Action taken on opped user
# .chanset #<channel> superbitch-user X
# (0=nothing/off  1=Deop  2=deop & +d
#  3=Deop, +d & kick  4=Deop, +d, Kick and ban)
#
# Action taken on Op that Oped the user
# .chanset #<channel> superbitch-op X
# (Default  0=nothing/off)
# (1=deop  2=deop & +d  3=Deop, +d & kick  4=Deop, +d, Kick and ban - For non +m's and +n's)
# (5=deop  6=deop & +d  7=Deop, +d & kick  8=Deop, +d, Kick and ban - For non +n's)
# (9=deop 10=deop & +d 11=Deop, +d & kick 12=Deop, +d, Kick and ban - For All Ops)
#
#
# VERSIONS:
# 0.1 - 1st scripted and release.
# 0.2 - Now does Mass Modes (up to the maximum in 1 line based on IRC Network) using RAW.
# 0.3 - Fixed a little bug on the RAW  proc from return to return 0 (they're
#       not the same thing..doh!)
# 0.4 - 1 line deop for Op and Op'ed user - based on network type max modes
#     - Minor Syntax fixes - opps, I'm only human ;)
#
# TO DO:
# - You tell me :P - I think I've covered it all
# 
##########################################################################
#Kick Message
set bitch_kick "Unauthorised Access"

#DO NOT EDIT BELOW!
set debug 0
bind raw - MODE bitch_fix_raw
proc bitch_fix_raw {from mode args} {
	global debug
	set nck [lindex [split $from "!"] 0]
	set uhst [lindex [split $from "!"] 1]
	set hndle [nick2hand $nck]
	set chn [lindex [split [string trim $args "\{"]] 0]
	set mchng [lindex [split $args] 1]
	set othr [lrange [split [string trim [string trim $args "\}"]]] 2 end]
	if {![onchan ${nck} $chn]} {return 0}
	bitch_fix ${nck} $uhst $hndle $chn $mchng ${othr}
	return 0
}

proc bitch_fix {nick uhost handle chan mchange other} {
	global botnick bitch_kick modes-per-line
	if {$other == $botnick} {return 0}
	if {[matchattr $handle +b]} {return 0}
	if {$nick == "" || $nick == "\*"} {return 0}
	set mode [lindex $mchange 0]
	if {![string match "*+o*" $mode]} {return 0}
	if {[botisop $chan]} {
		set bitchchaninfo [channel info $chan]
		if {[string match "* +bitch *" $bitchchaninfo]} {
			set yesdeop ""
			foreach otherone $other {
				if {![matchattr [nick2hand $otherone $chan] +o]} {
					if {![matchattr [nick2hand $otherone $chan] |+o $chan]} {
						if {$otherone != $botnick} {set yesdeop "$yesdeop$otherone "}
					}
				}
			}
			if {$yesdeop != ""} {
				putserv "MODE $chan -oooooo $yesdeop"
			}
			putlog "Bitch Mode Active - Deopped $yesdeop"
		}
		set banotherhostmask "" ; set nother ""
		foreach oother $other {
			if {$oother != $botnick} {
				set nother "$nother$oother "
				set banotherhostmask "${banotherhostmask}[maskhost "$oother![getchanhost $oother]"] "
				if {$banotherhostmask == ""} {set banotherhostmask "$oother\*!\*@\*"}
			}
		}
		set other [string trim $nother]
		set banotherhostmask [string trim $banotherhostmask]
		set sbuser_val [string trim [lindex [split [string range $bitchchaninfo [string first "superbitch-user" $bitchchaninfo] end]] 1] \}]
		set chmodeusers $other
		switch $sbuser_val {
			"0"	{return 0}
			"1"	{
					#putserv "MODE $chan -oooooo $other"
					putlog "SuperBitch Mode User(1) - Deopped $other"
				}
			"2"	{
					#putserv "MODE $chan -oooooo $other"
					set lincntr 0
					while {$lincntr < [llength $other]} {
						adduser [lindex $other $lincntr] [lindex $banotherhostmask $lincntr]
						chattr [lindex $other $lincntr] -o|-o+d $chan
						putlog "SBM: -o|-o+d [lindex $other $lincntr] [lindex $banotherhostmask $lincntr]"
						incr lincntr 1
					}
					putlog "SuperBitch Mode User(2) - Deopped and +d $other"
				}
			"3"	{
					#putserv "MODE $chan -oooooo $other"
					set lincntr 0
					while {$lincntr < [llength $other]} {
						putkick $chan [lindex $other $lincntr] $bitch_kick
						adduser [lindex $other $lincntr] [lindex $banotherhostmask $lincntr]
						chattr [lindex $other $lincntr] -o|-o+d $chan
						putlog "SBM: -o|-o+d [lindex $other $lincntr] [lindex $banotherhostmask $lincntr]"
						incr lincntr 1
					}
					putlog "SuperBitch Mode User(3) - Deopped, Kicked and +d $other"
				}
			"4"	{
					#putserv "MODE $chan -oooooo $other"
					set lincntr 0
					while {$lincntr < [llength $other]} {
						putkick $chan [lindex $other $lincntr] $bitch_kick
						newchanban $chan [lindex $banotherhostmask $lincntr] $botnick "SUPERBITCH: $bitch_kick"
						adduser [lindex $other $lincntr] [lindex $banotherhostmask $lincntr]
						chattr [lindex $other $lincntr] -o|-o+d $chan
						putlog "SBM: -o|-o+d [lindex $other $lincntr] [lindex $banotherhostmask $lincntr]"
						incr lincntr 1
					}
					putlog "SuperBitch Mode User(4) - Deopped, Kicked/Banned and +d $other"
				}
			default	{
					#putserv "MODE $chan -oooooo $other"
					putlog "SuperBitch Mode Active(Default) - Deopped $other"
				}

		}
		#Opers
		set sbop_val [string trim [lindex [split [string range $bitchchaninfo [string first "superbitch-op" $bitchchaninfo] end]] 1] \}]
		set bannickhostmask [maskhost "$nick![getchanhost $nick]"]
		set maxmodes "[string range "oooooooooooooo" 1 ${modes-per-line}]"; set nickmode "${other} ${nick} "
		switch $sbop_val {
			"0"	{putserv "MODE $chan -$maxmodes ${other}" ; return 0}
			"1"	{
					if {![validuser $handle]} {
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
					} else {
						if {[matchattr $handle +m] || [matchattr $handle +n] || [matchattr $handle -|+m $chan] || [matchattr $handle -|+n $chan]} {
							putserv "MODE $chan -$maxmodes ${other}"
							return 0
						}
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
					}
					putlog "SuperBitch Mode-Op(1-non +m & +n) - Deopped $nick"
				}
			"2"	{
					if {![validuser $handle]} {
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
						adduser $nick $bannickhostmask 
						chattr $nick -jo|-jo+d $chan
					} else {
						if {[matchattr $handle +m] || [matchattr $handle +n] || [matchattr $handle -|+m $chan] || [matchattr $handle -|+n $chan]} {
							putserv "MODE $chan -$maxmodes ${other}"
							return 0
						}
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
						chattr $handle -jo|-jo+d $chan
					}
					putlog "SuperBitch Mode Op(2-non +m & +n) - Deopped and +d $nick"
				}
			"3"	{
					if {![validuser $handle]} {
						putkick $chan $nick $bitch_kick
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
						adduser $nick $bannickhostmask
						chattr $nick -jo|-jo+d $chan
					} else {
						if {[matchattr $handle +m] || [matchattr $handle +n] || [matchattr $handle -|+m $chan] || [matchattr $handle -|+n $chan]} {
							putserv "MODE $chan -$maxmodes ${other}"
							return 0
						}
						putkick $chan $nick $bitch_kick
						chattr $handle -jo|-jo+d $chan
					}
					putlog "SuperBitch Mode Op(3-non +m & +n) - Deopped, Kicked and +d $nick"
				}
			"4"	{
					if {![validuser $handle]} {
						putkick $chan $nick $bitch_kick
						#putserv "MODE $chan -o $nick"
						adduser $nick $bannickhostmask
						chattr $nick -jo|-jo+dk $chan
						newchanban $chan $bannickhostmask $botnick "SUPERBITCH: $bitch_kick"
					} else {
						if {[matchattr $handle +m] || [matchattr $handle +n] || [matchattr $handle -|+m $chan] || [matchattr $handle -|+n $chan]} {
							putserv "MODE $chan -$maxmodes ${other}"
							return 0
						}
						putkick $chan $nick $bitch_kick
						chattr $handle -jo|-jo+dk $chan
						newchanban $chan $bannickhostmask $botnick "SUPERBITCH: $bitch_kick"
					}
					putlog "SuperBitch Mode Op(4-non +m & +n) - Deopped, Kicked/Banned and +d $nick"
				}
			"5"	{
					if {![validuser $handle]} {
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
					} else {
						if {[matchattr $handle +n] || [matchattr $handle -|+n $chan]} {
							putserv "MODE $chan -$maxmodes ${other}"
							return 0
						}
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
					}
					putlog "SuperBitch Mode-Op(5-non +n) - Deopped $nick"
				}
			"6"	{
					if {![validuser $handle]} {
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
						adduser $nick $bannickhostmask 
						chattr $nick -mjo|-mjo+d $chan
					} else {
						if {[matchattr $handle +n] || [matchattr $handle -|+n $chan]} {
							putserv "MODE $chan -$maxmodes ${other}"
							return 0
						}
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
						chattr $handle -mjo|-jmo+d $chan
					}
					putlog "SuperBitch Mode Op(6-non +n) - Deopped and +d $nick"
				}
			"7"	{
					if {![validuser $handle]} {
						putkick $chan $nick $bitch_kick
						#putserv "MODE $chan -o $nick"
						adduser $nick $bannickhostmask
						chattr $nick -mjo|-mjo+d $chan
					} else {
						if {[matchattr $handle +n] || [matchattr $handle -|+n $chan]} {
							putserv "MODE $chan -$maxmodes ${other}"
							return 0
						}
						putkick $chan $nick $bitch_kick
						chattr $handle -mjo|-mjo+d $chan
					}
					putlog "SuperBitch Mode Op(7-non +n) - Deopped, Kicked and +d $nick"
				}
			"8"	{
					if {![validuser $handle]} {
						putkick $chan $nick $bitch_kick
						#putserv "MODE $chan -o $nick"
						adduser $nick $bannickhostmask
						chattr $nick -mjo|-mjo+dk $chan
						newchanban $chan $bannickhostmask $botnick "SUPERBITCH: $bitch_kick"
					} else {
						if {[matchattr $handle +n] || [matchattr $handle -|+n $chan]} {
							putserv "MODE $chan -$maxmodes ${other}"
							return 0
						}
						putkick $chan $nick $bitch_kick
						chattr $handle -mjo|-mjo+dk $chan
						newchanban $chan $bannickhostmask $botnick "SUPERBITCH: $bitch_kick"
					}
					putlog "SuperBitch Mode Op(8-non +n) - Deopped, Kicked/Banned and +d $nick"
				}
			"9"	{
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
					putlog "SuperBitch Mode-Op(9) - Deopped $nick"
				}
			"10"	{
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
					if {![validuser $handle]} {
						adduser $nick $bannickhostmask
						set handle $nick
					}
					chattr $handle -nmjo|-nmjo+d $chan
					putlog "SuperBitch Mode Op(10) - Deopped and +d $nick"
				}
			"11"	{
						#
						if {[llength $nickmode] > ${modes-per-line}} {
							putserv "MODE $chan -$maxmodes ${other}"
							putserv "MODE $chan -$maxmodes ${nick}"
						} else {
							putserv "MODE $chan -$maxmodes ${nickmode}"
						}
						#
					if {![validuser $handle]} {
						adduser $nick $bannickhostmask
						set handle $nick
					}
					chattr $handle -nmjo|-nmjo+d $chan
					putkick $chan $nick $bitch_kick
					putlog "SuperBitch Mode Op(11) - Deopped, Kicked and +d $nick"
				}
			"12"	{
					#putserv "MODE $chan -o $nick"
					putkick $chan $handle $bitch_kick
					if {![validuser $handle]} {
						adduser $nick $bannickhostmask
						set handle $nick
					}
					chattr $handle -nmnjo|-nmjo+d $chan
					newchanban $chan $bannickhostmask $botnick "SUPERBITCH: $bitch_kick"
					putlog "SuperBitch Mode Op(12) - Deopped, Kicked/Banned and +d $nick"
				}
			default {return 0}
		}
	}
	return 0
}
setudef "int" "superbitch-user"
setudef "int" "superbitch-op"
##bind mode - * bitch_fix
putlog "\002Loaded superbitch.tcl 0.45\002 (use .help superbitch) by IsP@Undernet"
if {[file exists "./help/superbitch.help"]} {
	loadhelp superbitch.help
} else {
	putlog "Error: Superbitch Help File Not Loaded! (Please ensure superbitch.help is in your /eggdrop/help/ direcoty!)"
}
