# botaway.tcl v1.14 [1 August 2000]
# Copyright (C) 1999-2000 Teemu Hjelt <temex@iki.fi>
#
# Latest version can be found from http://www.iki.fi/temex/eggdrop/ 
# 
# If you have any suggestions, questions or you want to report 
# bugs, please feel free to send me email to temex@iki.fi
#
# With this script you can set your bot away.
#
# Current DCC Commands:
#    .botaway, .botback, .autoaway
#
# Tested on eggdrop1.4.4 with TCL 7.6
#
# Version history:
# v1.00 - The very first version!
# v1.01 - Added the missing commands to away-help.
# v1.10 - Changed the name of this script from away.tcl to botaway.tcl 
#         Modified .away to .botaway, because .away was already in use.
#         Now you can select is the message log either ON or OFF. You can 
#         also select what kind of away message do you want. Added more of 
#         those "stupid" away reasons, fixed some big bugs and divided settings 
#         in to two sections. Also fixed bug with away reasons that contain chars 
#         like { } [ ] $ \ " 
# v1.11 - Renamed the procs & fixed some cosmetic things.
# v1.12 - Now you can select the channels where the bot shows the away-actions.
# v1.13 - Had to change time command to strftime, because v1.4.0 doesn't support
#         time and date commands anymore.
# v1.14 - Changed the names of the commands and the actual away time is now used.
        
### General Settings ###

## [0/1/2] What kind of away message do you want?
# 0 - Normal
# 1 - BitchX
# 2 - ScrollZ
set ba_style 1

## [0/1] Enable this is if you want the message log to be ON in the away message.
# Note: This only works when ba_style is set to 1 or 2.
set ba_logon 1

## [0/1] Show an action on $ba_actchans when you set your bot away or back?
# Note: This only works when ba_style is set to 1 or 2.
set ba_showaction 1

## What users can set the bot away/back and enable/disable AutoAway?
set ba_flag "m"

## On what channels do you want to show the away-actions?
# Note: Set this to "" to show the away-actions on all channels.
set ba_actchans "#ShakE #roots"

### Autoaway Settings ###

## [0/1] Enable Autoaway?
set ba_autoaway 1

## [0/1] Show an action on $ba_actchans when autoaway sets your bot away or back?
# Note: This only works when ba_style is set to 1 or 2.
set ba_autoaction 0

## [0/1] Enable this if you want the bot to log when it was set away or back by autoaway.
set ba_autolog 1

## [0/1] Enable this if you want the autoaway to randomly choose whether it sets your bot away or back.
set ba_rand 1

## [0/1] Enable this if you want to have a random interval for autoaway.
set ba_randint 1

## What is the maximum time of waiting before setting away in random interval (mins)?
set ba_maxdelay 40

## What is the minimum time of waiting before setting away in random interval (mins)?
set ba_mindelay 5

## If you haven't enabled $ba_randint then what interval do you want to use (mins)? 
set ba_interval 40 

###### You don't need to edit below this ######

### Misc Things ###

set ba_ver "1.14"
if {![info exists ba_isaway]} { set ba_isaway 0 }
if {![info exists ba_awaytime]} { set ba_awaytime 0 }

### Random AwayReasons ###

set ba_reasons {
	"Auto-Away after 10 mins"
	"Auto-Away after 20 mins"
	"Automatically set away"
	"Eating"
	"Gone"
	"Not here"
	"Not here. Use e-mail."
	"Not here. Use snail mail."
	"Somewhere"
	"Coming back soon"
	"Watching TV"
	"Listening to radio"
	"Listening to records"
	"Reading"
	"Surfing"
	"Surfing in the web."
	"Sleeping"
	"idling"
	"Doing homeworks"
	"Taking a bath"
	"Cleaning room"
	"Playing guitar"
	"Playing piano"
	"Playing tennis"
	"Playing basketball"
	"Playing badminton"
	"Playing ice-hockey"
	"Go away!"
	"Don't disturb me!"
	"err..."
}	

### Bindings ###

bind dcc $ba_flag autoaway dcc:ba_autoaway
bind dcc $ba_flag botaway dcc:ba_botaway
bind dcc $ba_flag botback dcc:ba_botback

### Main Procs ###

proc dcc:ba_autoaway {hand idx arg} {
global botnick ba_ver ba_autoaway
set option [string tolower [lindex $arg 0]]
	putcmdlog "#$hand# autoaway $arg"
	switch -exact -- $option {
		"" {
			if {$ba_autoaway} {
				putidx $idx "Autoaway is enabled."
				putidx $idx "You can disable it by typing: .autoaway -disable"
			} else {
				putidx $idx "Autoaway is disabled."
				putidx $idx "You can enable it by typing: .autoaway -enable"
			}
		}
		"-enable" {
			if {!$ba_autoaway} {
				ba_stopauto 
				ba_startauto 
				set ba_autoaway 1
				putidx $idx "Autoaway enabled." 
			} else {
				putidx $idx "Autoaway is already enabled."
			}
		}
		"-disable" {
			if {$ba_autoaway} {
				ba_stopauto
				set ba_autoaway 0
				putidx $idx "Autoaway disabled." 
			} else {
				putidx $idx "Autoaway is already disabled."
			}
		}
		"default" { 
			putidx $idx "Usage: .autoaway \[-enable/-disable\]" 
		}
	}
}

proc dcc:ba_botaway {hand idx arg} {
global botnick ba_reasons ba_autoaway ba_showaction
set reason [join [lrange [split $arg] 0 end]]
	putcmdlog "#$hand# botaway $arg"
	if {$reason == ""} { set reason [lindex $ba_reasons [rand [llength $ba_reasons]]] }
	set reason [ba_getreason $reason]
	if {$ba_autoaway} { ba_stopauto }
	if {$ba_showaction} { ba_awayaction $reason }
        putidx $idx "$botnick was set away - $reason"
	ba_setaway $reason
}

proc dcc:ba_botback {hand idx arg} {
global botnick ba_autoaway ba_showaction ba_awaytime
	putcmdlog "#$hand# botback $arg"
	if {$ba_autoaway} { ba_startauto }
	if {$ba_showaction} { ba_backaction }
	if {$ba_awaytime == 0} {
	        putidx $idx "$botnick was set back."
	} else {
	        putidx $idx "$botnick was set back. Bot was away [ba_duration [expr [unixtime] - $ba_awaytime]]"
	}
	ba_setback
}

### Other Procs ###

proc ba_awayaction {reason} {
global ba_style ba_actchans
	if {$ba_style == 1} { 
		foreach chan [channels] { 
			if {($ba_actchans != "") && ([lsearch -exact [split [string tolower $ba_actchans]] [string tolower $chan]] == -1)} { continue }
			putserv "PRIVMSG $chan :\001ACTION $reason\001" 
		} 
	} elseif {$ba_style == 2} { 
		foreach chan [channels] { 
			if {($ba_actchans != "") && ([lsearch -exact [split [string tolower $ba_actchans]] [string tolower $chan]] == -1)} { continue }
			putserv "PRIVMSG $chan :\001ACTION is away. $reason\001" 
		} 
	}
}

proc ba_backaction {} {
global ba_style ba_actchans ba_awaytime
	if {$ba_style == 1} {
		set awaytime [ba_duration [expr [unixtime] - $ba_awaytime]]
		foreach chan [channels] {
			if {($ba_actchans != "") && ([lsearch -exact [split [string tolower $ba_actchans]] [string tolower $chan]] == -1)} { continue }
			putserv "PRIVMSG $chan :\001ACTION is back from the dead. Gone $awaytime\001" 
		} 
	} elseif {$ba_style == 2} { 
		foreach chan [channels] { 
			if {($ba_actchans != "") && ([lsearch -exact [split [string tolower $ba_actchans]] [string tolower $chan]] == -1)} { continue }
			putserv "PRIVMSG $chan :\001ACTION is back. \002What was going on ?\002 \[SZ\002off\002\]\001" 
		} 
	}
}

proc ba_setaway {reason} {
global ba_style ba_isaway ba_awaytime
	if {$ba_style == 2} { append reason "  Away since [strftime "%a %b %d %H:%M"]" }
	set ba_awaytime [unixtime]
	set ba_isaway 1
	putserv "AWAY :$reason"
}

proc ba_setback { } {
global ba_isaway ba_awaytime
	set ba_awaytime 0
	set ba_isaway 0
	putserv "AWAY :"
}

proc ba_doaway { } {
global botnick ba_reasons ba_rand ba_isaway ba_autoaction ba_autolog ba_awaytime
set reason [ba_getreason [lindex $ba_reasons [rand [llength $ba_reasons]]]]
	if {$ba_rand} { 
		if {[rand 2]} {
			if {!$ba_isaway} { 
				if {$ba_autoaction} { ba_awayaction $reason }
			        if {$ba_autolog} { putlog "botaway: $botnick was set away - $reason" } 
				ba_setaway $reason
			}
		} else {
			if {$ba_isaway} {
				if {$ba_autoaction} { ba_backaction }
				if {$ba_autolog} { 
					if {$ba_awaytime == 0} {
					        putlog "$botnick was set back."
					} else {
					        putlog "$botnick was set back. Bot was away [ba_duration [expr [unixtime] - $ba_awaytime]]"
					}
				}
				ba_setback 
			}
		}
	} else { 
		if {!$ba_isaway} { 
			if {$ba_autoaction} { ba_awayaction $reason }
		        if {$ba_autolog} { putlog "botaway: $botnick was set away - $reason" } 
			ba_setaway $reason
		} else { 
			if {$ba_autoaction} { ba_backaction }
			if {$ba_autolog} { 
				if {$ba_awaytime == 0} {
				        putlog "$botnick was set back."
				} else {
				        putlog "$botnick was set back. Bot was away [ba_duration [expr [unixtime] - $ba_awaytime]]"
				}
			}
			ba_setback
		}
	}
	ba_startauto
}

proc ba_startauto { } {
global ba_randint ba_interval ba_maxdelay ba_mindelay
	if {![string match "*ba_doaway*" [timers]]} {
		if {$ba_randint} { 
			timer [expr [rand $ba_maxdelay] + $ba_mindelay +1] ba_doaway 
		} else {
			timer $ba_interval ba_doaway
		}
	}
}

proc ba_stopauto { } {
	foreach timer [timers] {
		if {[string match "*ba_doaway*" $timer]} { 
			killtimer [lindex $timer 2]
		}
	}
}

proc ba_duration {seconds} {
	set h [expr $seconds/3600]
	set m [expr $seconds/60 - $h*60] 
	set s [expr $seconds - $m*60 - $h*3600]
	return "[lindex [split $h] 0] hrs [lindex [split $m] 0] min [lindex [split $s] 0] secs"
}

proc ba_getreason {reason} {
global ba_style ba_logon
	if {($ba_style == 1) && ($ba_logon)} { set reason "is away: (${reason}) \[\002BX\002-MsgLog On\]" }
	if {($ba_style == 1) && (!$ba_logon)} { set reason "is away: (${reason}) \[\002BX\002-MsgLog Off\]" }
	if {($ba_style == 2) && ($ba_logon)} { set reason "\002${reason}\002 \[SZ\002on\002\]" }
	if {($ba_style == 2) && (!$ba_logon)} { set reason "\002${reason}\002 \[SZ\002off\002\]" }
	return $reason
}

### End ###

if {$ba_autoaway} { ba_startauto }

putlog "TCL loaded: botaway.tcl v$ba_ver by Sup <temex@iki.fi>" 
