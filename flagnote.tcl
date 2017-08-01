#
# flagnote.tcl v5.2 (for eggdrop *1.3*)
# Originally by Ernst <ernst@studbox.uni-stuttgart.de>  16/11/97
# Ernst's eggdrop page:  http://www.sodre.net/ernst/eggdrop/
#
# Modified 10/5/98, LoveAngel <LoveAngel@loveshack.org>
#
# A new command is added for masters to send a note to everyone on the
# userlist with whatever flags you specify, global or channel specific.
#
# New in v5.1:
# - now for eggdrop 1.3.x:
#    flags and flags matching has changed since 1.1
# - don't send note to itself
# - custom flags now are ALL capital letters
#
# Usage:  .flagnote <flag> [#channel/all] <message>
#
# Examples:
#
# .flagnote n Hello bot owner, please do not remove channel #holyshit!
#    This will go only to users with global flag +n
#
# .flagnote m all Hi %nick, check out new .flagnote command you can use!
#    This goes out to all users with +m flag
#    (either global or channel (any channel) specific)
#
# .flagnote o #lamechan Channel was taken over again today :(
#    This goes out only to users with channel flag +o in #lamechan
#
# You can include the macro %nick in the message, it will be replaced
# by the current username in each note.
#
# LoveAngel : Will now work with the fwd variable without crashing :)
#
# Revision History:  Version 1.0  by Keyoke                [12.13.95]
#                    Version 2.0  by BlackJac and panasync [01.20.96]
#                    Version 2.2  by BlackJac              [04.17.96]
#                    Version 3.0  by BlackJac              [05.20.96]
#                    Version 3.1  by answer                [05.22.96]
#                    Version 3.2  by BlackJac              [06.26.96]
#                    Version 4.0  by BLackJac              [07.21.96]
#                    Version 4.0x by DeathHand             [12.03.96]
#                    Version 5.0  by Ernst                 [06.25.97]
#                    Version 5.1  by Ernst                 [11.16.97]
#                    Version 5.2  by LoveAngel             [05.10.97]

############### [~] Do Not Change Anything Below This Line [~] ###############

# as of eggdrop 1.3.2:
set globalflags "a c d f h j k m n o p q t u v x"
set chanflags   "a d f k m n o q v"
set botflags    "b"

set customflags "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"

bind dcc m|m flagnote dcc_flagnote
proc dcc_flagnote {hand idx arg} {
	global customflags globalflags chanflags botflags
	set whichflag [lindex $arg 0]
	if {[string index [lindex $arg 1] 0] == "#"} {
		set toglobal 0
		set tochannel 1
		set channel "[lindex $arg 1]"
		if {![validchan $channel]} {
			putdcc $idx "I am not monitoring channel $channel, sorry."
			return 0
		}
		set message [lrange $arg 2 end]
	} elseif {[string tolower [lindex $arg 1]] == "all"} {
		set toglobal 1
		set tochannel 1
		set channel "[channels]"
		set message [lrange $arg 2 end]
	} {
		set toglobal 1
		set tochannel 0
		set channel ""
		set message [lrange $arg 1 end]
	}
	if {$whichflag == "" || $message == ""} {
		putdcc $idx "Usage: flagnote <\[+\]flag> \[#channel/all\] <message>"
		putdcc $idx "  Sends <message> to users with given channel or global flag."
		putdcc $idx "  If '#channel' is specified, message goes to users with channel"
		putdcc $idx "  <flag> for channel #channel. If 'all' is specified, message"
		putdcc $idx "  goes for users with either any channel or global <flag>."
		putdcc $idx "  Otherwise message will go only to users with global <flag>."
		putdcc $idx "  A '%nick' in message to be replaced with destination handle."
		return 0
	}
	if {[string index $whichflag 0] == "+"} {
		set whichflag [string index $whichflag 1]
	}
	if {([lsearch -exact $botflags $whichflag] > 0)} {
		putdcc $idx "The flag \[\002$whichflag\002\] is for bots only."
		putdcc $idx "Valid flags are (choose one):"
		putdcc $idx "\002[lsort $globalflags]\002 and any uppercase letter"
		return 0
	}
	if {[lsearch -exact [concat $globalflags $customflags] $whichflag] < 0} {
		putdcc $idx "The flag \[\002$whichflag\002\] is not a defined flag."
		putdcc $idx "Valid flags are (choose one):"
		putdcc $idx " \002[lsort $globalflags]\002 and any uppercase letter"
		return 0
	}
	if {$tochannel && $toglobal} {
		putcmdlog "#$hand# flagnote \[+$whichflag\] all ..."
		putdcc $idx "*** Sending FlagNote to all \[\002$whichflag\002\] users."
		set channel [channels]
	} elseif {$tochannel && !$toglobal} {
		putcmdlog "#$hand# flagnote \[+$whichflag $channel\] ..."
		putdcc $idx "*** Sending FlagNote to all \[\002$whichflag\002\] users ($channel)."
	} {
		putcmdlog "#$hand# flagnote \[+$whichflag\] ..."
		putdcc $idx "*** Sending FlagNote to all global \[\002$whichflag\002\] users."
	}
	if {[lsearch -exact [concat $chanflags $customflags] $whichflag] < 0 && $tochannel} {
		putdcc $idx "*** \[\002$whichflag\002\] is a global only flag."
	}
	set message "\[\002$whichflag\002\]\ $message"
	set notes 0
	set badnotes 0
	set badusers ""
	foreach user [userlist] {
		if {![matchattr $user b] && $user != $hand} {
			if {[matchattr $user $whichflag] && $toglobal} {
				regsub -all "%nick" $message "$user" tmpmessage
				set fwdaddy [getuser $user fwd]
				if {$fwdaddy == ""} {
					set ok [sendnote $hand $user $tmpmessage]
					if {$ok == 3 || $ok == 0} {
						incr badnotes
						lappend badusers $user
					} { incr notes }
					continue
				} else {
					set ok [sendnote $hand $fwdaddy $tmpmessage]
					if {$ok == 3 || $ok == 0} {
						incr badnotes
						lappend badusers $user
					} { incr notes }
					continue}
			}
			if {$tochannel} {
				foreach thischan $channel {
					if {[matchattr $user -|$whichflag $thischan]} {
						regsub -all "%nick" $message "$user" tmpmessage
						set fwdaddy [getuser $user fwd]
						if {$fwdaddy == ""} {
							set ok [sendnote $hand $user $tmpmessage]
							# 3 is never returned as it should, this is a bug in 1.3.2
							if {$ok == 3 || $ok == 0} {
								incr badnotes
								lappend badusers $user
							} { incr notes }
							break
						} else {
							set ok [sendnote $hand $fwdaddy $tmpmessage]
							# 3 is never returned as it should, this is a bug in 1.3.2
							if {$ok == 3 || $ok == 0} {
								incr badnotes
								lappend badusers $user
							} { incr notes }
							break}
					}
				}
			}
		}
	}
	if {$notes == 1} {set notes "1 note was"} {set notes "$notes notes were"}
	putdcc $idx "*** Done... $notes send."
	if {$badnotes} {
		if {$badnotes == 1} {set badnotes "1 note was"} {set badnotes "$badnotes notes were"}
		putdcc $idx "*** $badnotes not delivered: $badusers"
	}
}

putlog "- flagnote v5.2 by Ernst"
