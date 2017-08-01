# topiclock.tcl v2.04 [11 November 2000]
# Copyright (C) 1999-2000 Teemu Hjelt <temex@iki.fi>
#
# Latest version can be found from http://www.iki.fi/temex/eggdrop/
# 
# If you have any suggestions, questions or you want to report 
# bugs, please feel free to send me email to temex@iki.fi
#
# With this script you can lock topics of channels,
# so that the users of the channels can't change them.
#
# Current DCC Commands:
#    .tlock, .tunlock, .tlockall, .tunlockall, .tlhelp
#     
# Current MSG Commands:
#    tlock, tunlock, tlockall, tunlockall, tlhelp
# 
# Current Channel Commands:
#    tlock, tunlock, tlockall, tunlockall, tlhelp
#
# Tested on eggdrop1.4.4 with TCL 7.6
#
# Version history:
# v1.00 - The very first version!
# v1.01 - Fixed a little bug in topc:tl_change proc.
#         Also made the channel option optional and
#         added the help section.
# v2.00 - Rewrote almost everything and made this script also more compact.
#         Fixed a bug that allowed multiple timers to start. Now the flood
#         protection takes effect only on chans whose topic is locked. Added
#         also channel and msg commands. Now you can also lock or unlock
#         topics of all channels by using tlockall and tunlockall commands.
# v2.01 - Oops! Missing ')' caused a syntax error and I also forgot to bind few procs.
# v2.02 - Little cosmetic changes.
# v2.03 - Made this script more secure and fixed few little bugs.
# v2.04 - Fixed minor bug in the topc:tl_change proc. (Found by TiM)

### General Settings ###

## [0/1] Enable Channel Commands?
set tl_enablechan 1

## [0/1] Enable MSG Commands?
set tl_enablemsg 1

## [0/1] Enable DCC Commands?
set tl_enabledcc 1

## [0/1] Enable the login thingie?
# Note: If you enable this you must do /msg botnick LOGIN <password> 
# before you can use the channel commands.
set tl_login 0

## What command prefix do you want to use for channel commands?
set tl_cmdpfix "!"

## Do you want to send a notice that tolds to the  
## user who changed the topic that the topic is locked?
set tl_notice 1

## The users with the following global flags can change the topic even if it is locked.
set tl_globflags "m n o"

## The users with the following chan flags can change the topic even if it is locked.
set tl_chanflags "m n"

## What users can use the commands?
set tl_flag "o"

## List of channels where the tlockall and tunlockall commands shouldn't take effect on.
set tl_nochans "#lamest #botcentral"

### Flood Proctection Settings ###

## [0/1] Do you want to enable the flood protection?
set tl_fludprot 1

## Accept how many topic-changes?
set tl_maxtopics 5:50

## Set channel mode +t if it doesn exist?
set tl_setmodet 1

## For how long time do you want to set the channel mode to +t (min)?
set tl_modettime 10

## Deop the user?
set tl_deopuser 1

## [0/1] Enable this if you want to kick the flooder.
set tl_kick 0

## What kind of kick-reason do you want to use?
set tl_kickreason "flood"

## [0/1] Enable this if you want to ban the flooder.
set tl_ban 0

## For how long time do you want to ban the flooder (min)?
set tl_bantime 10

## [0/1] Enable this if you want to ignore the flooder.
set tl_ignore 0

## For how long time do you want to ignore the flooder (min)?
set tl_ignoretime 10

###### You don't need to edit below this ######

### Misc Things ###

set tl_ver "2.04"
set tl_maxtopics [split $tl_maxtopics :]

### Bindings ###

## Channel Commands
if {$tl_enablechan} {
	bind pub $tl_flag ${tl_cmdpfix}tlock pub:tl_tlock
	bind pub $tl_flag ${tl_cmdpfix}tunlock pub:tl_tunlock
	bind pub $tl_flag ${tl_cmdpfix}tlockall pub:tl_tlockall
	bind pub $tl_flag ${tl_cmdpfix}tunlockall pub:tl_tunlockall
	bind pub $tl_flag ${tl_cmdpfix}tlhelp pub:tl_tlhelp
}

## MSG Commands
if {$tl_enablemsg} {
	bind msg $tl_flag tlock msg:tl_tlock
	bind msg $tl_flag tunlock msg:tl_tunlock
	bind msg $tl_flag tlockall msg:tl_tlockall
	bind msg $tl_flag tunlockall msg:tl_tunlockall
	bind msg $tl_flag tlhelp msg:tl_tlhelp
}

## Channel Commands
if {$tl_enabledcc} {
	bind dcc $tl_flag tlock dcc:tl_tlock
	bind dcc $tl_flag tunlock dcc:tl_tunlock
	bind dcc $tl_flag tlockall dcc:tl_tlockall
	bind dcc $tl_flag tunlockall dcc:tl_tunlockall
	bind dcc $tl_flag tlhelp dcc:tl_tlhelp
}

## Login Commands
if {$tl_login} {
	bind msg - login msg:tl_login
	bind msg - logout msg:tl_logout
	bind part - * part:tl_check
	bind sign - * sign:tl_check
	if {![info exists tl_loaded]} {
		utimer 10 tl_unsetlogins
		set tl_loaded 1
	}
}

## Other Bindings
bind topc - * topc:tl_change
bind mode - * mode:tl_op

### Login Thingie ###

proc msg:tl_login {nick uhost hand arg} {
global botnick 
set pass [lindex [split $arg] 0]
set foundchan 0
	if {$hand != "*"} {
		foreach chan [channels] {
			if {[onchan $nick $chan]} {
				set foundchan 1
			}
		}
		if {!$foundchan} {
			putserv "NOTICE $nick :Login unsuccessful - You need to be on same channel with me."
			putlog "topiclock: $nick ($uhost) tried to log in as $hand - Not on any channel."
		} elseif {$pass == ""} {
			putserv "NOTICE $nick :Usage: /msg $botnick LOGIN <password>"
			putlog "topiclock: $nick ($uhost) tried to log in as $hand - No password."
		} elseif {[getuser $hand XTRA "LOGIN"] == "1"} {
			putserv "NOTICE $nick :Login unsuccessful - You have already logged in."
			putlog "topiclock: $nick ($uhost) tried to log in as $hand - Already logged in."
		} elseif {[passwdok $hand $pass]} {
			setuser $hand XTRA "LOGIN" "1"
			putserv "NOTICE $nick :Login successful."
			putlog "topiclock: $nick ($uhost) logged in as $hand."
		} else {
			putserv "NOTICE $nick :Login unsuccessful - Wrong password."
			putlog "topiclock: $nick ($uhost) tried to log in as $hand - Wrong password."
		}
	} else {
		putserv "NOTICE $nick :Login unsuccessful - You're not on my userlist."
		putlog "topiclock: $nick ($uhost) tried to log in - Not on my userlist."
	}
return 0
}

proc msg:tl_logout {nick uhost hand arg} {
	if {$hand != "*"} {
		if {[getuser $hand XTRA "LOGIN"] == "1"} {
			setuser $hand XTRA "LOGIN" "0"
			putserv "NOTICE $nick :Successfully logged out."
			putlog "topiclock: $nick ($uhost) logged out as $hand."
		} else {
			putserv "NOTICE $nick :Logout unsuccessful - You're already logged out."
			putlog "topiclock: $nick ($uhost) tried to log out as $hand - Already logged out."
		}		
	} else {
		putserv "NOTICE $nick :Logout unsuccessful - You're not on my userlist."
		putlog "topiclock: $nick ($uhost) tried to log out - Not on my userlist."
	}		
return 0
}

proc sign:tl_check {nick uhost hand chan reason} {
	if {($hand != "*") && ([getuser $hand XTRA "LOGIN"] == "1")} {
		setuser $hand XTRA "LOGIN" "0"
		putlog "topiclock: $nick ($uhost) signed off - Login for $hand expired."
	}
}

proc part:tl_check {nick uhost hand chan {msg ""}} {
	if {($hand != "*") && ([getuser $hand XTRA "LOGIN"] == "1")} {
		utimer 10 "tl_checkpart $nick $uhost $hand"
	}
}

proc tl_checkpart {nick uhost hand} {
set foundchan 0
	foreach chan [channels] {
		if {[handonchan $hand $chan]} {
			set foundchan 1
		}
	}
	if {(!$foundchan) && ([getuser $hand XTRA "LOGIN"] == "1")} {
		setuser $hand XTRA "LOGIN" "0"
		putlog "topiclock: $nick ($uhost) parted all channels - Login for $hand expired."
	}
}

proc tl_unsetlogins { } {
	foreach hand [userlist] {
		if {[getuser $hand XTRA "LOGIN"] == "1"} {
			setuser $hand XTRA "LOGIN" "0"
		}
	}
}

proc tl_login_check {hand} {
	if {[getuser $hand XTRA "LOGIN"] == "1"} { 
		return 1 
	} else {
		return 0
	}
}

### Channel Commands ###

proc pub:tl_tlock {nick uhost hand chan arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans tl_login tl_cmdpfix
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
	if {([string first # $arg] == 0) || ([string first & $arg] == 0) || ([string first + $arg] == 0) || ([string first ! $arg] == 0)} {
		set chan [lindex [split $arg] 0]
		set topic [join [lrange [split $arg] 1 end]]
	} else {
		set topic [join [lrange [split $arg] 0 end]]
	}
	if {![tl_botonchan $chan]} {
		putserv "NOTICE $nick :I'm not on $chan."
	} else { 
		set tl_lock([string tolower $chan]) 1
		if {$topic == ""} {
			set tl_topic([string tolower $chan]) [topic $chan]
		} else {
			set tl_topic([string tolower $chan]) $topic
		}
		putserv "NOTICE $nick :Holding topic of $chan."
		if {$tl_topic([string tolower $chan]) != [topic $chan]} {
			if {([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]])} {
				putserv "TOPIC $chan :$tl_topic([string tolower $chan])"
			}
		}
	}
return 1
}

proc pub:tl_tunlock {nick uhost hand chan arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans tl_login tl_cmdpfix
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
if {[lindex [split $arg] 0] != ""} { set chan [lindex [split $arg] 0] }
	if {![tl_botonchan $chan]} {
		putserv "NOTICE $nick :I'm not on $chan."
	} else { 
		if {[info exists tl_lock([string tolower $chan])] && ($tl_lock([string tolower $chan]))} { 
			set tl_lock([string tolower $chan]) 0 
			putserv "NOTICE $nick :Unholding topic of $chan."
		} else {
			putserv "NOTICE $nick :I'm not holding topic of $chan."
		}
	}
return 1
}

proc pub:tl_tlockall {nick uhost hand chan arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans tl_login tl_cmdpfix
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
set chanlist ""
set topic [join [lrange [split $arg] 0 end]]
	foreach chan [channels] {
		if {[lsearch -exact [split [string tolower $tl_nochans]] [string tolower $chan]] != -1} { continue }
		set tl_lock([string tolower $chan]) 1
		if {$topic == ""} {
			set tl_topic([string tolower $chan]) [topic $chan]
		} else {
			set tl_topic([string tolower $chan]) $topic
		}
		lappend chanlist $chan
		if {$tl_topic([string tolower $chan]) != [topic $chan]} {
			if {([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]])} {
				putserv "TOPIC $chan :$tl_topic([string tolower $chan])"
			}
		}
	}
	if {$chanlist != ""} {
		if {[llength $chanlist] == 1} {
			putserv "NOTICE $nick :Holding topic of [join $chanlist ", "] ([llength $chanlist] channel)"
		} else {
			putserv "NOTICE $nick :Holding topic of [join $chanlist ", "] ([llength $chanlist] channels)"
		}
	} else {
		putserv "NOTICE $nick :Holding topic of 0 channels."
	}
return 1
}

proc pub:tl_tunlockall {nick uhost hand chan arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans tl_login tl_cmdpfix
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
set chanlist ""
	foreach chan [channels] {
		if {[lsearch -exact [split [string tolower $tl_nochans]] [string tolower $chan]] != -1} { continue }
		if {([info exists tl_lock([string tolower $chan])]) && ($tl_lock([string tolower $chan]))} { 
			set tl_lock([string tolower $chan]) 0
			lappend chanlist $chan 
		}
	}
	if {$chanlist != ""} {
		if {[llength $chanlist] == 1} {
			putserv "NOTICE $nick :Unholding topic of [join $chanlist ", "] ([llength $chanlist] channel)"
		} else {
			putserv "NOTICE $nick :Unholding topic of [join $chanlist ", "] ([llength $chanlist] channels)"
		}
	} else {
		putserv "NOTICE $nick :Unholding topic of 0 channels."
	}
return 1
}

proc pub:tl_tlhelp {nick uhost hand chan arg} {
global tl_ver tl_login tl_cmdpfix
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
set command [lindex [split $arg] 0]
	if {[string index $command 0] == $tl_cmdpfix} { set command [string range $command 1 end] }
	switch -exact -- [string tolower $command] {
		"" {
			putserv "PRIVMSG $nick :topiclock.tcl v$tl_ver commands:"
			putserv "PRIVMSG $nick :  ${tl_cmdpfix}tlock          ${tl_cmdpfix}tunlock"
			putserv "PRIVMSG $nick :  ${tl_cmdpfix}tlockall       ${tl_cmdpfix}tunlockall"
			putserv "PRIVMSG $nick :To get more help on individual commands, type: '${tl_cmdpfix}tlhelp <command>'"
		}
		"tlock" {
			putserv "PRIVMSG $nick :###  ${tl_cmdpfix}tlock \[channel\] \[topic\]"
			putserv "PRIVMSG $nick :   will hold the topic of the channel you"
			putserv "PRIVMSG $nick :   have specified or your current channel."
		}
		"tunlock" {
			putserv "PRIVMSG $nick :###  ${tl_cmdpfix}tunlock \[channel\]"
			putserv "PRIVMSG $nick :   will unhold the topic of the channel you"
			putserv "PRIVMSG $nick :   have specified or your current channel."
		}
		"tlockall" {
			putserv "PRIVMSG $nick :###  ${tl_cmdpfix}tlockall \[topic\]"
			putserv "PRIVMSG $nick :   will hold topics of all channels."
		}
		"tunlockall" {
			putserv "PRIVMSG $nick :###  ${tl_cmdpfix}tunlockall"
			putserv "PRIVMSG $nick :   will unhold topics of all channels."
		}
		"default" { 
			putserv "PRIVMSG $nick :No help available on '$command'."
		}
	}
return 1
}

### MSG Commands ###

proc msg:tl_tlock {nick uhost hand arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans tl_login
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
set chan [lindex [split $arg] 0]
set topic [join [lrange [split $arg] 1 end]]
	if {$chan == ""} {
		putserv "NOTICE $nick :Usage: tlock <channel> \[topic\]"
	} else {
		if {![tl_botonchan $chan]} {
			putserv "NOTICE $nick :I'm not on $chan."
		} else { 
			set tl_lock([string tolower $chan]) 1
			if {$topic == ""} {
				set tl_topic([string tolower $chan]) [topic $chan]
			} else {
				set tl_topic([string tolower $chan]) $topic
			}
			putserv "NOTICE $nick :Holding topic of $chan."
			if {$tl_topic([string tolower $chan]) != [topic $chan]} {
				if {([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]])} {
					putserv "TOPIC $chan :$tl_topic([string tolower $chan])"
				}
			}
		}
	}
return 1
}

proc msg:tl_tunlock {nick uhost hand arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans tl_login
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
set chan [lindex [split $arg] 0]
	if {$chan == ""} {
		putserv "NOTICE $nick :Usage: tunlock <channel>"
	} else {
		if {![tl_botonchan $chan]} {
			putserv "NOTICE $nick :I'm not on $chan."
		} else { 
			if {([info exists tl_lock([string tolower $chan])]) && ($tl_lock([string tolower $chan]))} { 
				set tl_lock([string tolower $chan]) 0 
				putserv "NOTICE $nick :Unholding topic of $chan."
			} else {
				putserv "NOTICE $nick :I'm not holding topic of $chan."
			}
		}
	}
return 1
}

proc msg:tl_tlockall {nick uhost hand arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans tl_login
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
set chanlist ""
set topic [join [lrange [split $arg] 0 end]]
	foreach chan [channels] {
		if {[lsearch -exact [split [string tolower $tl_nochans]] [string tolower $chan]] != -1} { continue }
		set tl_lock([string tolower $chan]) 1
		if {$topic == ""} {
			set tl_topic([string tolower $chan]) [topic $chan]
		} else {
			set tl_topic([string tolower $chan]) $topic
		}
		lappend chanlist $chan
		if {$tl_topic([string tolower $chan]) != [topic $chan]} {
			if {([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]])} {
				putserv "TOPIC $chan :$tl_topic([string tolower $chan])"
			}
		}
	}
	if {$chanlist != ""} {
		if {[llength $chanlist] == 1} {
			putserv "NOTICE $nick :Holding topic of [join $chanlist ", "] ([llength $chanlist] channel)"
		} else {
			putserv "NOTICE $nick :Holding topic of [join $chanlist ", "] ([llength $chanlist] channels)"
		}
	} else {
		putserv "NOTICE $nick :Holding topic of 0 channels."
	}
return 1
}

proc msg:tl_tunlockall {nick uhost hand arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans tl_login
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
set chanlist ""
	foreach chan [channels] {
		if {[lsearch -exact [split [string tolower $tl_nochans]] [string tolower $chan]] != -1} { continue }
		if {([info exists tl_lock([string tolower $chan])]) && ($tl_lock([string tolower $chan]))} { 
			set tl_lock([string tolower $chan]) 0
			lappend chanlist $chan 
		}
	}
	if {$chanlist != ""} {
		if {[llength $chanlist] == 1} {
			putserv "NOTICE $nick :Unholding topic of [join $chanlist ", "] ([llength $chanlist] channel)"
		} else {
			putserv "NOTICE $nick :Unholding topic of [join $chanlist ", "] ([llength $chanlist] channels)"
		}
	} else {
		putserv "NOTICE $nick :Unholding topic of 0 channels."
	}
return 1
}

proc msg:tl_tlhelp {nick uhost hand arg} {
global tl_ver tl_login
if {$tl_login} { if {![tl_login_check $hand]} { return 0 } }
set command [lindex [split $arg] 0]
	switch -exact -- [string tolower $command] {
		"" {
			putserv "PRIVMSG $nick :topiclock.tcl v$tl_ver commands:"
			putserv "PRIVMSG $nick :  tlock          tunlock"
			putserv "PRIVMSG $nick :  tlockall       tunlockall"
			putserv "PRIVMSG $nick :To get more help on individual commands, type: 'tlhelp <command>'"
		}
		"tlock" {
			putserv "PRIVMSG $nick :###  tlock <channel> \[topic\]"
			putserv "PRIVMSG $nick :   will hold the topic of the channel you"
			putserv "PRIVMSG $nick :   have specified or your current channel."
		}
		"tunlock" {
			putserv "PRIVMSG $nick :###  tunlock <channel>"
			putserv "PRIVMSG $nick :   will unhold the topic of the channel you"
			putserv "PRIVMSG $nick :   have specified or your current channel."
		}
		"tlockall" {
			putserv "PRIVMSG $nick :###  tlockall \[topic\]"
			putserv "PRIVMSG $nick :   will hold topics of all channels."
		}
		"tunlockall" {
			putserv "PRIVMSG $nick :###  tunlockall"
			putserv "PRIVMSG $nick :   will unhold topics of all channels."
		}
		"default" { 
			putserv "PRIVMSG $nick :No help available on '$command'."
		}
	}
return 1
}

### DCC Commands ###

proc dcc:tl_tlock {hand idx arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans
	putcmdlog "#$hand# tlock $arg"
	if {([string first # $arg] == 0) || ([string first & $arg] == 0) || ([string first + $arg] == 0) || ([string first ! $arg] == 0)} {
		set chan [lindex [split $arg] 0]
		set topic [join [lrange [split $arg] 1 end]]
	} else {
		set chan [lindex [console $idx] 0] 
		set topic [join [lrange [split $arg] 0 end]]
	}
	if {($chan == "") || ($chan == "*")} {
		putidx $idx "Usage: .tlock <channel> \[topic\]"
	} else {
		if {![tl_botonchan $chan]} {
			putidx $idx "I'm not on $chan."
		} else { 
			set tl_lock([string tolower $chan]) 1
			if {$topic == ""} {
				set tl_topic([string tolower $chan]) [topic $chan]
			} else {
				set tl_topic([string tolower $chan]) $topic
			}
			putidx $idx "Holding topic of $chan."
			if {$tl_topic([string tolower $chan]) != [topic $chan]} {
				if {([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]])} {
					putserv "TOPIC $chan :$tl_topic([string tolower $chan])"
				}
			}
		}
	}
}

proc dcc:tl_tunlock {hand idx arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans
	putcmdlog "#$hand# tunlock $arg"
	if {[lindex [split $arg] 0] != ""} {
		set chan [lindex [split $arg] 0]
	} else {
		set chan [lindex [console $idx] 0] 
	}
	if {($chan == "") || ($chan == "*")} {
		putidx $idx "Usage: .tunlock <channel>"
	} else {
		if {![tl_botonchan $chan]} {
			putidx $idx "I'm not on $chan."
		} else { 
			if {([info exists tl_lock([string tolower $chan])]) && ($tl_lock([string tolower $chan]))} { 
				set tl_lock([string tolower $chan]) 0 
				putidx $idx "Unholding topic of $chan."
			} else {
				putidx $idx "I'm not holding topic of $chan."
			}
		}
	}
}

proc dcc:tl_tlockall {hand idx arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans
set chanlist ""
set topic [join [lrange [split $arg] 0 end]]
	putcmdlog "#$hand# tlockall $arg"
	foreach chan [channels] {
		if {[lsearch -exact [split [string tolower $tl_nochans]] [string tolower $chan]] != -1} { continue }
		set tl_lock([string tolower $chan]) 1
		if {$topic == ""} {
			set tl_topic([string tolower $chan]) [topic $chan]
		} else {
			set tl_topic([string tolower $chan]) $topic
		}
		lappend chanlist $chan
		if {$tl_topic([string tolower $chan]) != [topic $chan]} {
			if {([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]])} {
				putserv "TOPIC $chan :$tl_topic([string tolower $chan])"
			}
		}
	}
	if {$chanlist != ""} {
		if {[llength $chanlist] == 1} {
			putidx $idx "Holding topic of [join $chanlist ", "] ([llength $chanlist] channel)"
		} else {
			putidx $idx "Holding topic of [join $chanlist ", "] ([llength $chanlist] channels)"
		}
	} else {
		pputidx $idx "Holding topic of 0 channels."
	}
}

proc dcc:tl_tunlockall {hand idx arg} {
global tl_lock tl_topic tl_notice tl_globflags tl_chanflags tl_nochans
set chanlist ""
	putcmdlog "#$hand# tunlockall $arg"
	foreach chan [channels] {
		if {[lsearch -exact [split [string tolower $tl_nochans]] [string tolower $chan]] != -1} { continue }
		if {([info exists tl_lock([string tolower $chan])]) && ($tl_lock([string tolower $chan]))} { 
			set tl_lock([string tolower $chan]) 0
			lappend chanlist $chan 
		}
	}
	if {$chanlist != ""} {
		if {[llength $chanlist] == 1} {
			putidx $idx "Unholding topic of [join $chanlist ", "] ([llength $chanlist] channel)"
		} else {
			putidx $idx "Unholding topic of [join $chanlist ", "] ([llength $chanlist] channels)"
		}
	} else {
		putidx $idx "NOTICE $nick :Unholding topic of 0 channels."
	}
}

proc dcc:tl_tlhelp {hand idx arg} {
global tl_ver
set command [lindex [split $arg] 0]
	putcmdlog "#$hand# tlhelp $arg"
	if {[string index $command 0] == "."} { set command [string range $command 1 end] }
	switch -exact -- [string tolower $command] {
		"" {
			putidx $idx "topiclock.tcl v$tl_ver commands:"
			putidx $idx "  tlock          tunlock"
			putidx $idx "  tlockall       tunlockall"
			putidx $idx "To get more help on individual commands, type: '.tlhelp <command>'"
		}
		"tlock" {
			putidx $idx "###  tlock \[channel\] \[topic\]"
			putidx $idx "   will hold the topic of the channel you"
			putidx $idx "   have specified or your current channel."
		}
		"tunlock" {
			putidx $idx "###  tunlock \[channel\]"
			putidx $idx "   will unhold the topic of the channel you"
			putidx $idx "   have specified or your current channel."
		}
		"tlockall" {
			putidx $idx "###  tlockall \[topic\]"
			putidx $idx "   will hold topics of all channels."
		}
		"tunlockall" {
			putidx $idx "###  tunlockall"
			putidx $idx "   will unhold topics of all channels."
		}
		"default" { 
			putidx $idx "No help available on '$command'."
		}
	}
}

### Other Procs ###

proc topc:tl_change {nick uhost hand chan topic} {
global botnick tl_lock tl_topic tl_notice tl_globflags tl_chanflags
global tl_fludprot tl_maxtopics tl_topiccount tl_flooded tl_setmodet tl_modettime tl_deopuser tl_kick tl_kickreason tl_ban tl_bantime tl_ignore tl_ignoretime 
set hostmask "*!*[string range $uhost [string first "@" $uhost] end]"
set dowhat ""
	if {([string tolower $nick] != [string tolower $botnick]) && ($nick != "*") && ($uhost != "*")} {
		foreach globflag $tl_globflags { if {[matchattr $hand $globflag]} { return 1 } }
		foreach chanflag $tl_chanflags { if {[matchattr $hand |$chanflag $chan]} { return 1 } }
		if {($tl_fludprot) && ([info exists tl_lock([string tolower $chan])]) && ($tl_lock([string tolower $chan]))} {
			if {![info exists tl_topiccount([string tolower $chan])]} { set tl_topiccount([string tolower $chan]) 0 }
			if {![info exists tl_flooded([string tolower $chan])]} { set tl_flooded([string tolower $chan]) 0 }
			incr tl_topiccount([string tolower $chan])
			utimer [lindex $tl_maxtopics 1] "incr tl_topiccount([string tolower $chan]) -1"
			if {(!$tl_flooded([string tolower $chan])) && ($tl_topiccount([string tolower $chan]) > [lindex $tl_maxtopics 0])} {
				utimer 10 "set tl_flooded([string tolower $chan]) 0"
				set tl_flooded([string tolower $chan]) 1
				if {($tl_deopuser) && ([botisop $chan]) && ([isop $nick $chan])} {
					lappend dowhat "deopping"
					putserv "MODE $chan -o $nick" 
				} 
				if {($tl_setmodet) && (![string match "*t*" [lindex [getchanmode $chan] 0]]) && ([botisop $chan])} {
					lappend dowhat "setting mode +t"
					putserv "MODE $chan +t"  
					if {![string match "*tl_unsetmodet ${chan}*" [timers]]} {
						timer $tl_modettime "tl_unsetmodet $chan"
					}
				} 
				if {($tl_ignore) && (![isignore $hostmask])} { 
					lappend dowhat "ignoring"
					newignore $hostmask $botnick "Topic-flood" $tl_ignoretime 
				}
				if {($tl_ban) && (![isban $hostmask $chan])} { 
					lappend dowhat "banning"
					newchanban $chan $hostmask $botnick "Topic-flood" $tl_bantime 
				}
				if {($tl_kick) && ([botisop $chan]) && ([onchan $nick $chan])} { 
					lappend dowhat "kicking"
					putserv "KICK $chan $nick :$tl_kickreason" 
				}
				if {$dowhat != ""} {
					set dowhat "-- [join $dowhat " & "]"
				}
				putlog "topiclock: Topic flood from $nick ($uhost) on $chan $dowhat"
			}
		}
		if {([info exists tl_lock([string tolower $chan])]) && (([info exists tl_topic([string tolower $chan])]) && ($tl_lock([string tolower $chan]))) && ($topic != $tl_topic([string tolower $chan]))} { 
			if {([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]])} {	
				putserv "TOPIC $chan :$tl_topic([string tolower $chan])"
				if {$tl_notice} { 
					putserv "NOTICE $nick :The topic of $chan is locked." 
				}
			}
		}
	} 
}

proc mode:tl_op {nick uhost hand chan mode victim} {
global botnick tl_lock tl_topic
	if {((($mode == "+o") && ([string tolower $victim] == [string tolower $botnick])) || ($mode == "-t")) && ([info exists tl_lock([string tolower $chan])]) && ([info exists tl_topic([string tolower $chan])]) && ($tl_lock([string tolower $chan])) && ($tl_topic([string tolower $chan]) != [topic $chan])} {
		putserv "TOPIC $chan :$tl_topic([string tolower $chan])"
	}
}

proc tl_unsetmodet {chan} {
	if {([string match "*t*" [lindex [getchanmode $chan] 0]]) && ([botisop $chan])} {
		putserv "MODE $chan -t"
		putlog "topiclock: Setting mode -t on $chan."
	}
}

proc tl_botonchan {chan} {
global botnick numversion
	if {$numversion < 1032400} {
		if {([validchan $chan]) && ([onchan $botnick $chan])} {
			return 1
		} else {
			return 0
		}
	} else {
		if {([validchan $chan]) && ([botonchan $chan])} {
			return 1
		} else {
			return 0
		}
	}
}

### End ###

putlog "TCL loaded: topiclock.tcl v$tl_ver by Sup <temex@iki.fi>"
if {$tl_fludprot} { 
	putlog "   - Flood Protection: enabled. (Accepting [lindex $tl_maxtopics 0] topics in [lindex $tl_maxtopics 1] seconds)" 
} else {
	putlog "   - Flood Protection: disabled." 
}