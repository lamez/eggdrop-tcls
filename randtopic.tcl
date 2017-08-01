# randtopic.tcl v2.04 [2 September 2000] 
# Copyright (C) 1999-2000 Teemu Hjelt <temex@iki.fi>
#
# Latest version can be found from http://www.iki.fi/temex/eggdrop/
# 
# If you have any suggestions, questions or you want to report 
# bugs, please feel free to send me email to temex@iki.fi
#
# This script gets a random topic to a channel from a file
# you have specified. You can add new topics or remove topics from 
# the file by using channel commands or dcc commands. 
#
# Current DCC Commands:
#    .rt, .rtall, .addrt, .delrt, .listrt, .sendrt, .rmrt, .rttimer, .rthelp
#
# Current MSG Commands:
#    topic, rt, rtall, addrt, delrt, listrt, sendrt, rmrt, topic, rttimer, rthelp
#
# Current Channel Commands:
#    topic, rt, rtall, addrt, delrt, listrt, sendrt, rmrt, topic, rttimer, rthelp
#
# Tested on eggdrop1.4.4 with TCL 7.6
#
# Version history:
# v1.00 - The very first version! 
# v1.01 - Added rtall command and fixed some little bugs.
# v1.02 - Removed lots of those exec commands - Uses now puts and gets commands.
#         v1.01 is still available in case you liked it more.
# v1.03 - Fixed little bug in delrt command and added the msg commands. 
#         Renamed the procs and renamed this script to randtopic1.03b.tcl.
# v1.04 - Made the channel option an optional option in dcc commands.
#         Also made a little change in dcc:rt_rtall proc.
# v2.00 - Rewrote almost everything and made this script also more compact.
#         There are no more two versions available. Added the rttimer command
#         to set a timer that changes the topic. Also added a possibility to
#         make a html-file that contains the topics that are in the database.
# v2.01 - Little cosmetic changes.
# v2.02 - Now this script checks if dccsend command is valid.
# v2.03 - Made this script more secure, fixed few bugs, added new variable; $rt_notifyme
#         and removed the html-file stuff because it was useless and it made this script bloated.
# v2.04 - Fixed minor bug in the dcc:rt_sendrt proc. (Found by Tim Harman)
         
### Settings ###

## [0/1] Enable Channel Commands?
set rt_enablechan 1

## [0/1] Enable MSG Commands?
set rt_enablemsg 1

## [0/1] Enable DCC Commands?
set rt_enabledcc 1

## [0/1] Enable the login thingie?
# Note: If you enable this you must do /msg botnick LOGIN <password> 
# before you can use the channel commands.
set rt_login 0

## [0/1] Do you want that the rtall command sets the same random topic to all channels?
set rt_sametopic 0

## What command prefix do you want to use for channel commands?
set rt_cmdpfix "!"

## List topics via NOTICE or PRIVMSG?
set rt_listmethod "PRIVMSG"

## What users can chance the topic?
set rt_tflag "o|o"

## What users can change the topic on all channels?
set rt_rtallflag "o"

## What users can add topic to the file? 
set rt_taddflag "o|o"

## What users can delete topics from the file?
set rt_tdelflag "m|m"

## What users can remove the topic file? 
set rt_trmflag "n"

## What users can request sending of the topic file? 
set rt_sendflag "m|m"

## What users can list the topics?
set rt_listflag "n"

## What users can start or stop the timer?
set rt_timerflag "o|o"

## What file do you want to use for storing topics?
set rt_tfile "topics.txt"

## List of channels where the rtall command shouldn't take effect on.
set rt_nochans "#lamest #botcentral"

## [0/1] Let the rtall command change only blank topics?
set rt_onlyblank 0

## [0/1] Log when timer does something?
set rt_logtimer 1

## [0/1] Let the timer change only blank topics?
set rt_tmronlyblank 0

## [0/1] When you use rtall public or msg command, do you want
## the bot to notify you on which channels it changed the topic?
set rt_notifyme 1

###### You don't need to edit below this ######

### Misc Things ###

set rt_ver "2.04"

### Bindings ###

## Channel Commands
if {$rt_enablechan} {
	bind pub $rt_tflag ${rt_cmdpfix}topic pub:rt_topic
	bind pub $rt_tflag ${rt_cmdpfix}rt pub:rt_rt
	bind pub $rt_rtallflag ${rt_cmdpfix}rtall pub:rt_rtall
	bind pub $rt_taddflag ${rt_cmdpfix}addrt pub:rt_addrt
	bind pub $rt_timerflag ${rt_cmdpfix}rttimer pub:rt_rttimer
	bind pub $rt_tdelflag ${rt_cmdpfix}delrt pub:rt_delrt
	bind pub $rt_trmflag ${rt_cmdpfix}rmrt pub:rt_rmrt
	bind pub $rt_sendflag ${rt_cmdpfix}sendrt pub:rt_sendrt
	bind pub $rt_listflag ${rt_cmdpfix}listrt pub:rt_listrt
	bind pub - ${rt_cmdpfix}rthelp pub:rt_rthelp
}

## MSG Commands
if {$rt_enablemsg} {
	bind msg $rt_tflag topic msg:rt_topic
	bind msg $rt_tflag rt msg:rt_rt
	bind msg $rt_rtallflag rtall msg:rt_rtall
	bind msg $rt_timerflag rttimer msg:rt_rttimer
	bind msg $rt_taddflag addrt msg:rt_addrt
	bind msg $rt_tdelflag delrt msg:rt_delrt
	bind msg $rt_trmflag rmrt msg:rt_rmrt
	bind msg $rt_sendflag sendrt msg:rt_sendrt
	bind msg $rt_listflag listrt msg:rt_listrt
	bind msg - rthelp msg:rt_rthelp
}

## DCC Commands
if {$rt_enabledcc} {
	bind dcc $rt_tflag rt dcc:rt_rt
	bind dcc $rt_rtallflag rtall dcc:rt_rtall
	bind dcc $rt_timerflag rttimer dcc:rt_rttimer
	bind dcc $rt_taddflag addrt dcc:rt_addrt
	bind dcc $rt_tdelflag delrt dcc:rt_delrt
	bind dcc $rt_trmflag rmrt dcc:rt_rmrt
	bind dcc $rt_sendflag sendrt dcc:rt_sendrt
	bind dcc $rt_listflag listrt dcc:rt_listrt
	bind dcc - rthelp dcc:rt_rthelp
}

## Login Commands
if {$rt_login} {
	bind msg - login msg:rt_login
	bind msg - logout msg:rt_logout
	bind part - * part:rt_check
	bind sign - * sign:rt_check
}

### Login Thingie ###

proc msg:rt_login {nick uhost hand arg} {
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
			putlog "randtopic: $nick ($uhost) tried to log in as $hand - Not on any channel."
		} elseif {$pass == ""} {
			putserv "NOTICE $nick :Usage: /msg $botnick LOGIN <password>"
			putlog "randtopic: $nick ($uhost) tried to log in as $hand - No password."
		} elseif {[getuser $hand XTRA "LOGIN"] == "1"} {
			putserv "NOTICE $nick :Login unsuccessful - You have already logged in."
			putlog "randtopic: $nick ($uhost) tried to log in as $hand - Already logged in."
		} elseif {[passwdok $hand $pass]} {
			setuser $hand XTRA "LOGIN" "1"
			putserv "NOTICE $nick :Login successful."
			putlog "randtopic: $nick ($uhost) logged in as $hand."
		} else {
			putserv "NOTICE $nick :Login unsuccessful - Wrong password."
			putlog "randtopic: $nick ($uhost) tried to log in as $hand - Wrong password."
		}
	} else {
		putserv "NOTICE $nick :Login unsuccessful - You're not on my userlist."
		putlog "randtopic: $nick ($uhost) tried to log in - Not on my userlist."
	}
return 0
}

proc msg:rt_logout {nick uhost hand arg} {
	if {$hand != "*"} {
		if {[getuser $hand XTRA "LOGIN"] == "1"} {
			setuser $hand XTRA "LOGIN" "0"
			putserv "NOTICE $nick :Successfully logged out."
			putlog "randtopic: $nick ($uhost) logged out as $hand."
		} else {
			putserv "NOTICE $nick :Logout unsuccessful - You're already logged out."
			putlog "randtopic: $nick ($uhost) tried to log out as $hand - Already logged out."
		}		
	} else {
		putserv "NOTICE $nick :Logout unsuccessful - You're not on my userlist."
		putlog "randtopic: $nick ($uhost) tried to log out - Not on my userlist."
	}		
return 0
}

proc sign:rt_check {nick uhost hand chan reason} {
	if {($hand != "*") && ([getuser $hand XTRA "LOGIN"] == "1")} {
		setuser $hand XTRA "LOGIN" "0"
		putlog "randtopic: $nick ($uhost) signed off - Login for $hand expired."
	}
}

proc part:rt_check {nick uhost hand chan {$msg ""}} {
	if {($hand != "*") && ([getuser $hand XTRA "LOGIN"] == "1")} {
		utimer 10 "rt_checkpart $nick $uhost $hand"
	}
}

proc rt_checkpart {nick uhost hand} {
set foundchan 0
	foreach chan [channels] {
		if {[handonchan $hand $chan]} {
			set foundchan 1
		}
	}
	if {(!$foundchan) && ([getuser $hand XTRA "LOGIN"] == "1")} {
		setuser $hand XTRA "LOGIN" "0"
		putlog "randtopic: $nick ($uhost) parted all channels - Login for $hand expired."
	}
}

proc rt_unsetlogins { } {
	foreach hand [userlist] {
		if {[getuser $hand XTRA "LOGIN"] == "1"} {
			setuser $hand XTRA "LOGIN" "0"
		}
	}
}

proc rt_login_check {hand} {
	if {[getuser $hand XTRA "LOGIN"] == "1"} { 
		return 1 
	} else {
		return 0
	}
}

### Channel Commands ###

proc pub:rt_topic {nick uhost hand chan arg} {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set topic [join [lrange [split $arg] 0 end]]
	if {([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]])} {
		if {$topic == ""} { 
			putserv "TOPIC $chan :" 
		} else {
			putserv "TOPIC $chan :$topic"
		}
	} else {
		putserv "NOTICE $nick :Unable to change topic of $chan."
	}
return 1
}

proc pub:rt_rt {nick uhost hand chan arg} {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
if {[lindex [split $arg] 0] != ""} { set chan [lindex [split $arg] 0] }
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putserv "NOTICE $nick :Unable to read from file $rt_tfile."
	} else {
		if {![rt_botonchan $chan]} {
			putserv "NOTICE $nick :I'm not on $chan."
		} else {
			set topic [rt_gettopic]
			if {($topic != "") && (([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]]))} {
				putserv "TOPIC $chan :$topic" 
			} else {
				putserv "NOTICE $nick :Unable to change topic of $chan."
			}
		}
	}
return 1
}

proc pub:rt_rtall {nick uhost hand chan arg} {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans rt_onlyblank rt_notifyme
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set chanlist ""
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putserv "NOTICE $nick :Unable to read from file $rt_tfile."
	} else {
		set topic [rt_gettopic]
		foreach chan [channels] {
			if {[lsearch -exact [split [string tolower $rt_nochans]] [string tolower $chan]] != -1} { continue }
			if {((($rt_onlyblank) && ([topic $chan] == "")) || (!$rt_onlyblank)) && ([rt_botonchan $chan]) && ($topic != "") && (([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]]))} {
				lappend chanlist $chan
				if {!$rt_sametopic} { 
					set topic [rt_gettopic] 
				} 
				putserv "TOPIC $chan :$topic" 
			}
		}
		if {$rt_notifyme} {
			if {$chanlist != ""} {
				if {[llength $chanlist] == 1} {
					putserv "NOTICE $nick :Changed topic of [join $chanlist ", "] ([llength $chanlist] channel)"
				} else {
					putserv "NOTICE $nick :Changed topic of [join $chanlist ", "] ([llength $chanlist] channels)"
				}
			} else {
				putserv "NOTICE $nick :Changed topic of 0 channels."
			}
		}
	}
return 1
}

proc pub:rt_rttimer {nick uhost hand chan arg} {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans
global rt_interval rt_chan rt_option
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set option [string tolower [lindex [split $arg] 0]]
set interval [lindex [split $arg] 1]
	if {[lindex [split $arg] 2] != ""} { set chan [lindex [split $arg] 2] }
	if {($option != "-stat") && ($option != "-stop") && (($interval == "") || ($option == "") || ((($option != "-rt") || ($chan == "")) && ($option != "-rtall")))} {
		putserv "NOTICE $nick :Usage: ${rt_cmdpfix}rttimer <option> \[interval \[channel\]\]"
	} elseif {($option == "-rt") && ($chan != "") && (![rt_botonchan $chan])} {
		putserv "NOTICE $nick :I'm not on $chan"
	} elseif {$option == "-stat"} {
		if {([string match "*rt_timer*" [timers]]) && (([info exists rt_interval]) && ([info exists rt_chan]))} {
			if {$rt_option == "-rt"} {
				putserv "NOTICE $nick :Timer is running! Changing topic of $rt_chan every $rt_interval mins."
			} elseif {$rt_option == "-rtall"} {
				putserv "NOTICE $nick :Timer is running! Changing topic of all channels every $rt_interval mins."
			}
		} else {
			putserv "NOTICE $nick :Timer is not running!"
		}
	} elseif {$option == "-stop"} {
		if {[string match "*rt_timer*" [timers]]} {
			rt_stoptimer
			putserv "NOTICE $nick :Timer stopped!"
		} else {
			putserv "NOTICE $nick :Timer is already stopped!"
		}
	} else {
		if {![rt_isnum $interval]} {
			putserv "NOTICE $nick :'$interval' is not a valid interval."
		} else {
			if {$option == "-rt"} {
				rt_stoptimer
				rt_timer $option $interval $chan
				putserv "NOTICE $nick :Timer started! Changing topic of $chan every $interval mins."
			} elseif {$option == "-rtall"} {
				rt_stoptimer
				rt_timer $option $interval "*"
				putserv "NOTICE $nick :Timer started! Changing topic of all channels every $interval mins."
			}
		}
	}
return 1
}

proc pub:rt_addrt {nick uhost hand chan arg}  {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set topic [join [lrange [split $arg] 0 end]]
	if {$topic == ""} {
		putserv "NOTICE $nick :Usage: ${rt_cmdpfix}addrt <topic>"
	} else {
		if {[rt_addtopic $topic]} {
			putserv "NOTICE $nick :A Topic was added to $rt_tfile."
		} else { 
			putserv "NOTICE $nick :Unable to add topic to $rt_tfile."
		}
	}
return 1
}

proc pub:rt_delrt {nick uhost hand chan arg} {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set topic [join [lrange [split $arg] 0 end]]
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putserv "NOTICE $nick :Unable to read from file $rt_tfile."
	} else {
		if {$topic == ""} {
			putserv "NOTICE $nick :Usage: ${rt_cmdpfix}delrt <topic>"
		} else {
			if {[rt_deltopic $topic]} { 
				putserv "NOTICE $nick :A Topic was deleted from $rt_tfile."
			} else {
				putserv "NOTICE $nick :Unable to delete topic from $rt_tfile."
			}
		}
	}
return 1
}

proc pub:rt_rmrt {nick uhost hand chan arg} {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
	if {[rt_delfile $rt_tfile]} {
		putserv "NOTICE $nick :$rt_tfile was succesfully deleted."			
	} else {
		putserv "NOTICE $nick :Unable to delete $rt_tfile."			
	}
return 1
}	

proc pub:rt_sendrt {nick uhost hand chan arg} {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
	if {![string match "*dccsend*" [string tolower [info commands]]]} {
		putserv "NOTICE $nick :Unable to use dccsend. Check that the transfer module is loaded."
	} else {
		if {[lindex [split $arg] 0] != ""} { set nick [lindex [split $arg] 0] }
		switch -exact -- [dccsend $rt_tfile $nick] {
			0 { putserv "NOTICE $nick :Sending you $rt_tfile ([expr [file size $rt_tfile] /1024] KB)"}
			1 { putserv "NOTICE $nick :Unable to send $rt_tfile (Too many connections)"              }
			2 { putserv "NOTICE $nick :Unable to send $rt_tfile (Can't open socket)"                 }
			3 { putserv "NOTICE $nick :Unable to send $rt_tfile (File doesn't exist)"                }
			4 { putserv "NOTICE $nick :Unable to send $rt_tfile (User has too many transfers)"       }
		}
	}
return 1
}

proc pub:rt_listrt {nick uhost hand chan arg} {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set amount 0
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putserv "NOTICE $nick :Unable to read from file $rt_tfile."
	} else {
		if {[lindex [split $arg] 0] != ""} { set nick [lindex [split $arg] 0] }
		putserv "$rt_listmethod $nick :--- Listing contents of $rt_tfile:"
		set fd [open $rt_tfile r]
		while {![eof $fd]} {
			gets $fd text
			if {$text != ""} {
				incr amount
				putserv "$rt_listmethod $nick : $text"
			}
		}
		close $fd
		putserv "$rt_listmethod $nick :--- Listing done ($amount topics)."
	}
return 1
}

proc pub:rt_rthelp {nick uhost hand chan arg} {
global rt_tfile rt_listmethod rt_login rt_cmdpfix rt_sametopic rt_nochans
global rt_ver rt_tflag rt_rtallflag rt_taddflag rt_tdelflag rt_trmflag rt_sendflag rt_listflag rt_timerflag
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set command [lindex [split $arg] 0]
	if {(![matchattr $hand $rt_tflag]) && (![matchattr $hand $rt_taddflag]) && (![matchattr $hand $rt_tdelflag]) && (![matchattr $hand $rt_trmflag]) && (![matchattr $hand $rt_sendflag]) && (![matchattr $hand $rt_listflag])} {
		return 0
	} else {
		if {[string index $command 0] == $rt_cmdpfix} { set command [string range $command 1 end] }
		switch -exact -- [string tolower $command] {
			"" {
				putserv "PRIVMSG $nick :randtopic.tcl v$rt_ver commands:"
				if {[matchattr $hand $rt_tflag]} {
					putserv "PRIVMSG $nick :   ${rt_cmdpfix}topic \[topic\]"
					putserv "PRIVMSG $nick :   ${rt_cmdpfix}rt \[channel\]"
				}
				if {[matchattr $hand $rt_rtallflag]} { putserv "PRIVMSG $nick :   ${rt_cmdpfix}rtall" }
				if {[matchattr $hand $rt_timerflag]} { putserv "PRIVMSG $nick :   ${rt_cmdpfix}rttimer <option> \[interval \[channel\]\]" }
				if {[matchattr $hand $rt_taddflag]} { putserv "PRIVMSG $nick :   ${rt_cmdpfix}addrt <topic>" }
				if {[matchattr $hand $rt_tdelflag]} { putserv "PRIVMSG $nick :   ${rt_cmdpfix}delrt <topic>" }
				if {[matchattr $hand $rt_trmflag]} { putserv "PRIVMSG $nick :   ${rt_cmdpfix}rmrt" }
				if {[matchattr $hand $rt_sendflag]} { putserv "PRIVMSG $nick :   ${rt_cmdpfix}sendrt \[nick\]" }
				if {[matchattr $hand $rt_listflag]} { putserv "PRIVMSG $nick :   ${rt_cmdpfix}listrt \[nick\]" }
				putserv "PRIVMSG $nick :To get more help on individual commands, type: '${rt_cmdpfix}rthelp <command>'"
			}
			"topic" {
				if {[matchattr $hand $rt_tflag]} {
					putserv "PRIVMSG $nick :###  ${rt_cmdpfix}topic \[topic\]"
					putserv "PRIVMSG $nick :   will change or clear the topic of $chan."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."	
				}
			}
			"rt" {
				if {[matchattr $hand $rt_tflag]} {
					putserv "PRIVMSG $nick :###  ${rt_cmdpfix}rt \[channel\]"
					putserv "PRIVMSG $nick :   will change the topic of $chan or the"
					putserv "PRIVMSG $nick :   channel you have specified to a random topic."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."	
				}
			}
			"rtall" {
				if {[matchattr $hand $rt_rtalllag]} {
					putserv "PRIVMSG $nick :###  ${rt_cmdpfix}rtall"
					putserv "PRIVMSG $nick :   will change the topic of the all"
					putserv "PRIVMSG $nick :   channels where the bot is to a random topic."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."	
				}
			}
			"rttimer" {
				if {[matchattr $hand $rt_timerflag]} {
					putserv "PRIVMSG $nick :###  ${rt_cmdpfix}rttimer <option> \[interval \[channel\]\]"
					putserv "PRIVMSG $nick :   will start a timer that changes the topic of all"
					putserv "PRIVMSG $nick :   channels where your bot is or only the topic of the"
					putserv "PRIVMSG $nick :   channel you have specified."
					putserv "PRIVMSG $nick :   Possible options:"
					putserv "PRIVMSG $nick :      -rt    - Changes the topic of the channel you have specified."
					putserv "PRIVMSG $nick :      -rtall - Changes the topic of all channels."
					putserv "PRIVMSG $nick :      -stat  - Shows the status of the timer."
					putserv "PRIVMSG $nick :      -stop  - Stops the timer."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"addrt" {
				if {[matchattr $hand $rt_taddflag]} {
					putserv "PRIVMSG $nick :###  ${rt_cmdpfix}addrt <topic>"
					putserv "PRIVMSG $nick :   will add a topic you have specified to the database."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."	
				}
			}
			"delrt" {
				if {[matchattr $hand $rt_tdelflag]} {
					putserv "PRIVMSG $nick :###  ${rt_cmdpfix}delrt <topic>"
					putserv "PRIVMSG $nick :   will remove the topic you have specified from the database."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."	
				}
			}
			"rmrt" {
				if {[matchattr $hand $rt_trmflag]} {
					putserv "PRIVMSG $nick :###  ${rt_cmdpfix}rmrt"
					putserv "PRIVMSG $nick :   will remove $rt_tfile file."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."	
				}
			}
			"sendrt" {
				if {[matchattr $hand $rt_sendflag]} {
					putserv "PRIVMSG $nick :###  ${rt_cmdpfix}sendrt \[nick\]"
					putserv "PRIVMSG $nick :   will send to you or to the nick" 
					putserv "PRIVMSG $nick :   you have specified $rt_tfile file."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."	
				}
			}
			"listrt" {
				if {[matchattr $hand $rt_listflag]} {
					putserv "PRIVMSG $nick :###  ${rt_cmdpfix}listrt \[nick\]"
					putserv "PRIVMSG $nick :   will list all the topics in the database" 
					putserv "PRIVMSG $nick :   to you or to the nick you have specified." 					
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."	
				}
			}
			"default" { 
				putserv "PRIVMSG $nick :No help available on '$command'."
			}
		}
	}
return 1
}

### MSG Commands ###

proc msg:rt_topic {nick uhost hand arg} {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set chan [lindex [split $arg] 0]
set topic [join [lrange [split $arg] 1 end]]
	if {$chan == ""} {
		putserv "NOTICE $nick :Usage: topic <channel> \[topic\]"
	} else {
		if {![rt_botonchan $chan]} {
			putserv "NOTICE $nick :I'm not on $chan."
		} else {
			if {[botisop $chan] || ![string match "*t*" [lindex [getchanmode $chan] 0]]} {
				if {$topic == ""} { 
					putserv "TOPIC $chan :" 
				} else {
					putserv "TOPIC $chan :$topic"
				}
			} else {
				putserv "NOTICE $nick :Unable to change topic of $chan."
			}
		}
	}
return 1
}

proc msg:rt_rt {nick uhost hand arg} {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set chan [lindex [split $arg] 0]
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putserv "NOTICE $nick :Unable to read from file $rt_tfile."
	} else {
		if {$chan == ""} {
			putserv "NOTICE $nick :Usage: rt <channel>"
		} else {
			if {![rt_botonchan $chan]} {
				putserv "NOTICE $nick :I'm not on $chan."
			} else {
				set topic [rt_gettopic]
				if {($topic != "") && ([botisop $chan] || ![string match "*t*" [lindex [getchanmode $chan] 0]])} {
					putserv "TOPIC $chan :$topic" 
				} else {
					putserv "NOTICE $nick :Unable to change topic of $chan."
				}
			}
		}
	}
return 1
}

proc msg:rt_rtall {nick uhost hand arg} {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans rt_onlyblank rt_notifyme
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set chanlist ""
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putserv "NOTICE $nick :Unable to read from file $rt_tfile."
	} else {
		set topic [rt_gettopic]
		foreach chan [channels] {
			if {[lsearch -exact [split [string tolower $rt_nochans]] [string tolower $chan]] != -1} { continue }
			if {((($rt_onlyblank) && ([topic $chan] == "")) || (!$rt_onlyblank)) && ([rt_botonchan $chan]) && ($topic != "") && (([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]]))} {
				if {!$rt_sametopic} { 
					set topic [rt_gettopic] 
				} 
				putserv "TOPIC $chan :$topic" 
			}
		}
		if {$rt_notifyme} {
			if {$chanlist != ""} {
				if {[llength $chanlist] == 1} {
					putserv "NOTICE $nick :Changed topic of [join $chanlist ", "] ([llength $chanlist] channel)"
				} else {
					putserv "NOTICE $nick :Changed topic of [join $chanlist ", "] ([llength $chanlist] channels)"
				}
			} else {
				putserv "NOTICE $nick :Changed topic of 0 channels."
			}
		}
	}
return 1
}

proc msg:rt_rttimer {nick uhost hand arg} {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans
global rt_interval rt_chan rt_option
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set option [string tolower [lindex [split $arg] 0]]
set interval [lindex [split $arg] 1]
set chan [lindex [split $arg] 2]
	if {($option != "-stat") && ($option != "-stop") && (($interval == "") || ($option == "") || ((($option != "-rt") || ($chan == "")) && ($option != "-rtall")))} {
		putserv "NOTICE $nick :Usage: rttimer <option> \[interval \[channel\]\]"
	} elseif {($option == "-rt") && ($chan != "") && ![rt_botonchan $chan]} {
		putserv "NOTICE $nick :I'm not on $chan"
	} elseif {$option == "-stat"} {
		if {([string match "*rt_timer*" [timers]]) && (([info exists rt_interval]) && ([info exists rt_chan]))} {
			if {$rt_option == "-rt"} {
				putserv "NOTICE $nick :Timer is running! Changing topic of $rt_chan every $rt_interval mins."
			} elseif {$rt_option == "-rtall"} {
				putserv "NOTICE $nick :Timer is running! Changing topic of all channels every $rt_interval mins."
			}
		} else {
			putserv "NOTICE $nick :Timer is not running!"
		}
	} elseif {$option == "-stop"} {
		if {[string match "*rt_timer*" [timers]]} {
			rt_stoptimer
			putserv "NOTICE $nick :Timer stopped!"
		} else {
			putserv "NOTICE $nick :Timer is already stopped!"
		}
	} else {
		if {![rt_isnum $interval]} {
			putserv "NOTICE $nick :'$interval' is not a valid interval."
		} else {
			if {$option == "-rt"} {
				rt_stoptimer
				rt_timer $option $interval $chan
				putserv "NOTICE $nick :Timer started! Changing topic of $chan every $interval mins."
			} elseif {$option == "-rtall"} {
				rt_stoptimer
				rt_timer $option $interval "*"
				putserv "NOTICE $nick :Timer started! Changing topic of all channels every $interval mins."
			}
		}
	}
return 1
}

proc msg:rt_addrt {nick uhost hand arg}  {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set topic [join [lrange [split $arg] 0 end]]
	if {$topic == ""} {
		putserv "NOTICE $nick :Usage: addrt <topic>"
	} else {
		if {[rt_addtopic $topic]} {
			putserv "NOTICE $nick :A Topic was added to $rt_tfile."
		} else {
			putserv "NOTICE $nick :Unable to add topic to $rt_tfile."
		}
	}
return 1
}

proc msg:rt_delrt {nick uhost hand arg} {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set topic [join [lrange [split $arg] 0 end]]
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putserv "NOTICE $nick :Unable to read from file $rt_tfile."
	} else {
		if {$topic == ""} {
			putserv "NOTICE $nick :Usage: delrt <topic>"
		} else {
			if {[rt_deltopic $topic]} { 
				putserv "NOTICE $nick :A Topic was deleted from $rt_tfile."
			} else {
				putserv "NOTICE $nick :Unable to remove topic from $rt_tfile."
			}
		}
	}
return 1
}

proc msg:rt_rmrt {nick uhost hand arg} {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
	if {[rt_delfile $rt_tfile]} {
		putserv "NOTICE $nick :$rt_tfile was succesfully deleted."
	} else {
		putserv "NOTICE $nick :Unable to delete $rt_tfile."
	}
return 1
}	

proc msg:rt_sendrt {nick uhost hand arg} {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
	if {![string match "*dccsend*" [string tolower [info commands]]]} {
		putserv "NOTICE $nick :Unable to use dccsend. Check that the transfer module is loaded."
	} else {
		if {[lindex [split $arg] 0] != ""} { set nick [lindex [split $arg] 0] }
		switch -exact -- [dccsend $rt_tfile $nick] {
			0 { putserv "NOTICE $nick :Sending you $rt_tfile ([expr [file size $rt_tfile] /1024] KB)"}
			1 { putserv "NOTICE $nick :Unable to send $rt_tfile (Too many connections)"              }
			2 { putserv "NOTICE $nick :Unable to send $rt_tfile (Can't open socket)"                 }
			3 { putserv "NOTICE $nick :Unable to send $rt_tfile (File doesn't exist)"                }
			4 { putserv "NOTICE $nick :Unable to send $rt_tfile (User has too many transfers)"       }
		}
	}
return 1
}

proc msg:rt_listrt {nick uhost hand arg} {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set amount 0
	if {![file exists $rt_tfile]} { 
		putserv "NOTICE $nick :$rt_tfile doesn't exist."
	} else {
		if {[lindex [split $arg] 0] != ""} { set nick [lindex [split $arg] 0] }
		putserv "$rt_listmethod $nick :--- Listing contents of $rt_tfile:"
		set fd [open $rt_tfile r]
		while {![eof $fd]} {
			gets $fd text
			if {$text != ""} {
				incr amount
				putserv "$rt_listmethod $nick : $text"
			}
		}
		close $fd
		putserv "$rt_listmethod $nick :--- Listing done ($amount topics)."
	}
return 1
}

proc msg:rt_rthelp {nick uhost hand arg} {
global rt_tfile rt_listmethod rt_login rt_sametopic rt_nochans
global rt_ver rt_tflag rt_rtallflag rt_taddflag rt_tdelflag rt_trmflag rt_sendflag rt_listflag rt_timerflag
if {$rt_login} { if {![rt_login_check $hand]} { return 0 } }
set command [lindex [split $arg] 0]
	if {(![matchattr $hand $rt_tflag]) && (![matchattr $hand $rt_taddflag]) && (![matchattr $hand $rt_tdelflag]) && (![matchattr $hand $rt_trmflag]) && (![matchattr $hand $rt_sendflag]) && (![matchattr $hand $rt_listflag])} {
		return 0
	} else {
		switch -exact -- [string tolower $command] {
			"" {
				putserv "PRIVMSG $nick :randtopic.tcl v$rt_ver commands:"
				if {[matchattr $hand $rt_tflag]} {
					putserv "PRIVMSG $nick :   topic <channel> \[topic\]"
					putserv "PRIVMSG $nick :   rt <channel>"
				}
				if {[matchattr $hand $rt_rtallflag } { putserv "PRIVMSG $nick :   rtall" }
				if {[matchattr $hand $rt_timerflag } { putserv "PRIVMSG $nick :   rttimer <option> \[interval \[channel\]\]" }
				if {[matchattr $hand $rt_taddflag]} { putserv "PRIVMSG $nick :   addrt <topic>" }
				if {[matchattr $hand $rt_tdelflag]} { putserv "PRIVMSG $nick :   delrt <topic>" }
				if {[matchattr $hand $rt_trmflag]} { putserv "PRIVMSG $nick :   rmrt" }
				if {[matchattr $hand $rt_sendflag]} { putserv "PRIVMSG $nick :   sendrt \[nick\]" }
				if {[matchattr $hand $rt_listflag]} { putserv "PRIVMSG $nick :   listrt \[nick\]" }
				putserv "PRIVMSG $nick :To get more help on individual commands, type: 'rthelp <command>'"
			}
			"topic" {
				if {[matchattr $hand $rt_tflag]} {
					putserv "PRIVMSG $nick :###  topic <channel> \[topic\]"
					putserv "PRIVMSG $nick :   will change or clear the topic of the channel you have specified."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"rt" {
				if {[matchattr $hand $rt_tflag]} {
					putserv "PRIVMSG $nick :###  rt <channel>"
					putserv "PRIVMSG $nick :   will change the topic of the channel"
					putserv "PRIVMSG $nick :   you have specified to a random topic."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"rtall" {
				if {[matchattr $hand $rt_rtallflag]} {
					putserv "PRIVMSG $nick :###  rtall"
					putserv "PRIVMSG $nick :   will change the topic of the all"
					putserv "PRIVMSG $nick :   channels where the bot is to a random topic."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"rttimer" {
				if {[matchattr $hand $rt_timerflag]} {
					putserv "PRIVMSG $nick :###  rttimer <option> \[interval \[channel\]\]"
					putserv "PRIVMSG $nick :   will start a timer that changes the topic of all"
					putserv "PRIVMSG $nick :   channels where your bot is or only the topic of the"
					putserv "PRIVMSG $nick :   channel you have specified."
					putserv "PRIVMSG $nick :   Possible options:"
					putserv "PRIVMSG $nick :      -rt    - Changes the topic of the channel you have specified."
					putserv "PRIVMSG $nick :      -rtall - Changes the topic of all channels."
					putserv "PRIVMSG $nick :      -stat  - Shows the status of the timer."
					putserv "PRIVMSG $nick :      -stop  - Stops the timer."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"addrt" {
				if {[matchattr $hand $rt_taddflag]} {
					putserv "PRIVMSG $nick :###  addrt <topic>"
					putserv "PRIVMSG $nick :   will add a topic you have specified to the database."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"delrt" {
				if {[matchattr $hand $rt_tdelflag]} {
					putserv "PRIVMSG $nick :###  delrt <topic>"
					putserv "PRIVMSG $nick :   will remove the topic you have specified from the database."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"rmrt" {
				if {[matchattr $hand $rt_trmflag]} {
					putserv "PRIVMSG $nick :###  rmrt"
					putserv "PRIVMSG $nick :   will remove $rt_tfile file."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"sendrt" {
				if {[matchattr $hand $rt_sendflag]} {
					putserv "PRIVMSG $nick :###  sendrt \[nick\]"
					putserv "PRIVMSG $nick :   will send to you or to the nick" 
					putserv "PRIVMSG $nick :   you have specified $rt_tfile file."
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"listrt" {
				if {[matchattr $hand $rt_listflag]} {
					putserv "PRIVMSG $nick :###  listrt \[nick\]"
					putserv "PRIVMSG $nick :   will list all the topics in the database" 
					putserv "PRIVMSG $nick :   to you or to the nick you have specified." 
				} else {
					putserv "PRIVMSG $nick :No help available on '$command'."
				}
			}
			"default" { 
				putserv "PRIVMSG $nick :No help available on '$command'."
			}
		}
	}
return 1
}

### DCC Commands ### 

proc dcc:rt_rt {hand idx arg} {
global rt_tfile rt_sametopic rt_nochans
set chan [lindex [split $arg] 0]
	putcmdlog "#$hand# rt $arg"
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putidx $idx "Unable to read from file $rt_tfile."
	} else {
		if {$chan == ""} { set chan [lindex [console $idx] 0] }
		if {($chan == "") || ($chan == "*")} {
			putidx $idx "Usage: .rt <channel>"
		} else {
			if {![rt_botonchan $chan]} {
				putidx $idx "I'm not on $chan."
			} else {
				set topic [rt_gettopic]
				if {($topic != "") && (([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]]))} {
					putserv "TOPIC $chan :$topic"
					putidx $idx "Topic of $chan changed." 
				} else {
					putidx $idx "Unable to change topic of $chan."
				}
			}
		}
	}
}

proc dcc:rt_rtall {hand idx arg} {
global rt_tfile rt_sametopic rt_nochans rt_onlyblank
set chanlist ""
	putcmdlog "#$hand# rtall $arg"
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putidx $idx "Unable to read from file $rt_tfile."
	} else {
		set topic [rt_gettopic]
		foreach chan [channels] {
			if {[lsearch -exact [split [string tolower $rt_nochans]] [string tolower $chan]] != -1} { continue }
			if {((($rt_onlyblank) && ([topic $chan] == "")) || (!$rt_onlyblank)) && ([rt_botonchan $chan]) && ($topic != "") && (([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]]))} {
				lappend chanlist $chan
				if {!$rt_sametopic} {
					set topic [rt_gettopic] 
				} 
				putserv "TOPIC $chan :$topic"
			}
		}
		if {$chanlist != ""} {
			if {[llength $chanlist] == 1} {
				putidx $idx "Changed topic of [join $chanlist ", "] ([llength $chanlist] channel)"
			} else {
				putidx $idx "Changed topic of [join $chanlist ", "] ([llength $chanlist] channels)"
			}
		} else {
			putidx $idx "Changed topic of 0 channels."
		}
	}
}

proc dcc:rt_rttimer {hand idx arg} {
global rt_tfile rt_sametopic rt_nochans
global rt_interval rt_chan rt_option
set option [string tolower [lindex [split $arg] 0]]
set interval [lindex [split $arg] 1]
	putcmdlog "#$hand# rttimer $arg"
	if {[lindex [split $arg] 2] != ""} { 
		set chan [lindex [split $arg] 2]
	} else {
		set chan [lindex [console $idx] 0]
	}
	if {($option != "-stat") && ($option != "-stop") && (($interval == "") || ($option == "") || ((($option != "-rt") || ($chan == "") || ($chan == "*")) && ($option != "-rtall")))} {
		putidx $idx "Usage: .rttimer <option> \[interval \[channel\]\]"
	} elseif {($option == "-rt") && ($chan != "") && ![rt_botonchan $chan]} {
		putidx $idx "I'm not on $chan"
	} elseif {$option == "-stat"} {
		if {([string match "*rt_timer*" [timers]]) && (([info exists rt_interval]) && ([info exists rt_chan]))} {
			if {$rt_option == "-rt"} {
				putidx $idx "Timer is running! Changing topic of $rt_chan every $rt_interval mins."
			} elseif {$rt_option == "-rtall"} {
				putidx $idx "Timer is running! Changing topic of all channels every $rt_interval mins."
			}
		} else {
			putidx $idx "Timer is not running!"
		}
	} elseif {$option == "-stop"} {
		if {[string match "*rt_timer*" [timers]]} {
			rt_stoptimer
			putidx $idx "Timer stopped!"
		} else {
			putidx $idx "Timer is already stopped!"
		}
	} else {
		if {![rt_isnum $interval]} {
			putidx $idx "'$interval' is not a valid interval."
		} else {
			if {$option == "-rt"} {
				rt_stoptimer
				rt_timer $option $interval $chan
				putidx $idx "Timer started! Changing topic of $chan every $interval mins."
			} elseif {$option == "-rtall"} {
				rt_stoptimer
				rt_timer $option $interval "*"
				putidx $idx "Timer started! Changing topic of all channels every $interval mins."
			}
		}
	}
}

proc dcc:rt_addrt {hand idx arg}  {
global rt_tfile rt_sametopic rt_nochans
set topic [join [lrange [split $arg] 0 end]]
	putcmdlog "#$hand# addrt $arg"
	if {$topic == ""} {
		putidx $idx "Usage: .addrt <topic>"
	} else {
		if {[rt_addtopic $topic]} {
			putidx $idx "A Topic was added to $rt_tfile."
		} else {
			putidx $idx "Unable to add topic to $rt_tfile."
		}
	} 
}

proc dcc:rt_delrt {hand idx arg} {
global rt_tfile rt_sametopic rt_nochans
set topic [join [lrange [split $arg] 0 end]]
	putcmdlog "#$hand# delrt $arg"
	if {(![file exists $rt_tfile]) || (![file readable $rt_tfile])} { 
		putidx $idx "Unable to read from file $rt_tfile."
	} else {
		if {$topic == ""} {
			putidx $idx "Usage: .delrt <topic>"
		} else {
			if {[rt_deltopic $topic]} { 
				putidx $idx "A Topic was deleted from $rt_tfile."
			} else {
				putidx $idx "Unable to remove topic from $rt_tfile."
			}
		}
	}
}

proc dcc:rt_rmrt {hand idx arg} {
global rt_tfile rt_sametopic rt_nochans
	putcmdlog "#$hand# rmrt $arg"
	if {[rt_delfile $rt_tfile]} { 
		putidx $idx "Unable to delete $rt_tfile." 
	} else { 
		putidx $idx "$rt_tfile was succesfully deleted." 
	}
}	

proc dcc:rt_sendrt {hand idx arg} {
global rt_tfile rt_sametopic rt_nochans
set nick [lindex [split $arg] 0]
	putcmdlog "#$hand# sendrt $arg"
	if {![string match "*dccsend*" [string tolower [info commands]]]} {
		putidx $idx "Unable to use dccsend. Check that the transfer module is loaded."
	} else {
		if {$nick == ""} { set nick [rt_getnick $hand] }
		if {$nick != ""} {
			switch -exact -- [dccsend $rt_tfile $nick] {
				0 { putidx $idx "Sending $rt_tfile to $nick ([expr [file size $rt_tfile] /1024] KB)" }
				1 { putidx $idx "Unable to send $rt_tfile (Too many connections)"                    } 
				2 { putidx $idx "Unable to send $rt_tfile (Can't open socket)"                       } 
				3 { putidx $idx "Unable to send $rt_tfile (File doesn't exist)"                      } 
				4 { putidx $idx "Unable to send $rt_tfile (User has too many transfers)"             }
			}
		} else {
			putidx $idx "Can't find your nickname - Use .sendrt <nick> instead."
		}
	}
}

proc dcc:rt_listrt {hand idx arg} {
global rt_tfile rt_sametopic rt_nochans
set amount 0
	putcmdlog "#$hand# listrt $arg"
	if {![file exists $rt_tfile]} { 
		putidx $idx "$rt_tfile doesn't exist."
	} else {
		putidx $idx "--- Listing contents of $rt_tfile:"
		set fd [open $rt_tfile r]
		while {![eof $fd]} {
			gets $fd text
			if {$text != ""} {
				incr amount
				putidx $idx " $text"
			}
		}
		close $fd
		putidx $idx "--- Listing done ($amount topics)."
	}
}

proc dcc:rt_rthelp {hand idx arg} {
global rt_tfile rt_sametopic rt_nochans
global rt_ver rt_tflag rt_rtallflag rt_taddflag rt_tdelflag rt_trmflag rt_sendflag rt_listflag rt_timerflag
set command [lindex [split $arg] 0]
	if {(![matchattr $hand $rt_tflag]) && (![matchattr $hand $rt_taddflag]) && (![matchattr $hand $rt_tdelflag]) && (![matchattr $hand $rt_trmflag]) && (![matchattr $hand $rt_sendflag]) && (![matchattr $hand $rt_listflag])} {
		putidx $idx "What?  You need '.help'"
		return 0
	} else {
		putcmdlog "#$hand# rthelp $arg"
		if {[string index $command 0] == "."} { set command [string range $command 1 end] }
		switch -exact -- [string tolower $command] {
			"" {
				putidx $idx "randtopic.tcl v$rt_ver commands:"
				if {[matchattr $hand $rt_tflag]} { putidx $idx "   rt \[channel\]" }
				if {[matchattr $hand $rt_rtallflag]} { putidx $idx "   rtall" }
				if {[matchattr $hand $rt_timerflag]} { putidx $idx "   rttimer <option> \[interval \[channel\]\]" }
				if {[matchattr $hand $rt_taddflag]} { putidx $idx "   addrt <topic>" }
				if {[matchattr $hand $rt_tdelflag]} { putidx $idx "   delrt <topic>" }
				if {[matchattr $hand $rt_trmflag]} { putidx $idx "   rmrt" }
				if {[matchattr $hand $rt_sendflag]} { putidx $idx "   sendrt \[nick\]" }
				if {[matchattr $hand $rt_listflag]} { putidx $idx "   listrt" }
				putidx $idx "To get more help on individual commands, type: '.rthelp <command>'"
			}
			"rt" {
				if {[matchattr $hand $rt_tflag]} {
					putidx $idx "###  rt \[channel\]"
					putidx $idx "   will change the topic of the channel you have specified"
					putidx $idx "   or your current console channel to a random topic."
				} else {
					putidx $idx "No help available on '$command'."
				}
			}
			"rtall" {
				if {[matchattr $hand $rt_rtallflag]} {
					putidx $idx "###  rtall"
					putidx $idx "   will change the topic of the all"
					putidx $idx "   channels where the bot is to a random topic."
				} else {
					putidx $idx "No help available on '$command'."
				}
			}
			"rttimer" {
				if {[matchattr $hand $rt_timerflag]} {
					putidx $idx "###  rttimer <option> \[interval \[channel\]\]"
					putidx $idx "   will start a timer that changes the topic of all"
					putidx $idx "   channels where your bot is or only the topic of the"
					putidx $idx "   channel you have specified."
					putidx $idx "   Possible options:"
					putidx $idx "      -rt    - Changes the topic of the channel you have specified."
					putidx $idx "      -rtall - Changes the topic of all channels."
					putidx $idx "      -stat  - Shows the status of the timer."
					putidx $idx "      -stop  - Stops the timer."
				} else {
					putidx $idx "No help available on '$command'."
				}
			}
			"addrt" {
				if {[matchattr $hand $rt_taddflag]} {
					putidx $idx "###  addrt <topic>"
					putidx $idx "   will add a topic to you have specified to the database."
				} else {
					putidx $idx "No help available on '$command'."
				}
			}
			"delrt" {
				if {[matchattr $hand $rt_tdelflag]} {
					putidx $idx "###  delrt <topic>"
					putidx $idx "   will remove the topic you have specified from the database."
				} else {
					putidx $idx "No help available on '$command'."
				}
			}
			"rmrt" {
				if {[matchattr $hand $rt_trmflag]} {
					putidx $idx "###  rmrt"
					putidx $idx "   will remove $rt_tfile file."
				} else {
					putidx $idx "No help available on '$command'."
				}
			}
			"sendrt" {
				if {[matchattr $hand $rt_sendflag]} {
					putidx $idx "###  sendrt \[nick\]"
					putidx $idx "   will send to you or to the nick" 
					putidx $idx "   you have specified $rt_tfile file."
				} else {
					putidx $idx "No help available on '$command'."
				}
			}
			"listrt" {
				if {[matchattr $hand $rt_listflag]} {
					putidx $idx "###  listrt"
					putidx $idx "   will list all the topics in the database." 
				} else {
					putidx $idx "No help available on '$command'."
				}
			}
			"default" { 
				putidx $idx "No help available on '$command'."
			}
		}
	}
}

### Other Procs ###

proc rt_getnick {hand} {
global numversion
	if {$hand != "*"} {
		if {$numversion < 1032700} {
			foreach chan [channels] {
				return [hand2nick $hand $chan]
			}
		} else {
			return [hand2nick $hand]
		}
	}
}

proc rt_botonchan {chan} {
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

proc rt_gettopic { } {
global rt_tfile
set topics ""
	set fd [open $rt_tfile r]
	while {![eof $fd]} { 
		gets $fd text
		if {$text != ""} {
			lappend topics $text
		}
	}
	close $fd
	return [lindex $topics [rand [llength $topics]]]
}

proc rt_addtopic {topic} {
global rt_tfile
	if {[catch {open $rt_tfile a} fd]} {
		return 0
	} else {
		puts $fd $topic
		close $fd
		return 1
	}
}

proc rt_deltopic {topic} {
global rt_tfile
set what ""
set topicrem 0
	if {[catch {open $rt_tfile r} fd]} {
		return 0
	} else {
		while {![eof $fd]} { 
			gets $fd text
			if {[string tolower $text] != [string tolower $topic]} { 
				append what "$text\n"
			} else { 
				set topicrem 1 
			} 
		}
		close $fd
		if {[catch {open $rt_tfile w} fd]} {
			return 0
		} else {
			puts $fd $what
			close $fd
			return $topicrem
		}
	}
}

proc rt_delfile {file} {
	if {[file exists $file]} {
		file delete -force $file
		if {[file exists $file]} {
			return 0
		} else {
			return 1
		}
	} else {
		return 0
	}
}

proc rt_isnum {number} {
	if {($number != "") && (![regexp \[^0-9\] $number])} {
		return 1
	} else {
		return 0
	}
}

proc rt_timer {option interval chan} {
global rt_logtimer rt_interval rt_chan rt_option
	if {![string match "*rt_timer*" [timers]]} { 
		timer $interval "rt_timer $option $interval $chan" 
		set rt_option $option
		set rt_interval $interval
		set rt_chan $chan
	} 
	if {$option == "-rt"} { 
		rt_dort $chan
	} elseif {$option == "-rtall"} { 
		rt_dortall
	}
}

proc rt_stoptimer { } {
	foreach timer [timers] {
		if {[string match "*rt_timer*" $timer]} { 
			killtimer [lindex $timer 2]
		}
	}
}

proc rt_dort {chan} {
global rt_logtimer rt_tmronlyblank
	set topic [rt_gettopic]
	if {((($rt_tmronlyblank) && ([topic $chan] == "")) || (!$rt_tmronlyblank)) && ([rt_botonchan $chan]) && ($topic != "") && (([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]]))} {
		putserv "TOPIC $chan :$topic"
		if {$rt_logtimer} { putlog "randtopic: Changed topic of $chan." }
	} else {
		if {$rt_logtimer} { putlog "randtopic: Unable to change topic of $chan." }
	}
}

proc rt_dortall { } {
global rt_logtimer rt_sametopic rt_nochans rt_tmronlyblank
set chanlist ""
	set topic [rt_gettopic]
	foreach chan [channels] {
		if {[lsearch -exact [split [string tolower $rt_nochans]] [string tolower $chan]] != -1} { continue }
		if {((($rt_tmronlyblank) && ([topic $chan] == "")) || (!$rt_tmronlyblank)) && ([rt_botonchan $chan]) && ($topic != "") && (([botisop $chan]) || (![string match "*t*" [lindex [getchanmode $chan] 0]]))} {
			lappend chanlist $chan
			if {!$rt_sametopic} {
				set topic [rt_gettopic] 
			} 
			putserv "TOPIC $chan :$topic"
		}
	}
	if {$rt_logtimer} {
		if {$chanlist != ""} {
			if {[llength $chanlist] == 1} {
				putlog "randtopic: Changed topic of [join $chanlist ", "] ([llength $chanlist] channel)"
			} else {
				putlog "randtopic: Changed topic of [join $chanlist ", "] ([llength $chanlist] channels)"
			}
		} else {
			putlog "randtopic: Changed topic of 0 channels."
		}
	}
}

### End ###

if {![info exists rt_loaded]} {
	if {$rt_login} { rt_unsetlogins }
	set rt_loaded 1
}

putlog "TCL loaded: randtopic.tcl v$rt_ver by Sup <temex@iki.fi>"