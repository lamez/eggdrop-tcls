#         Script : Channel Guardian v1.01 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2002 Radical Computer Systems
#                             All Rights Reserved
#
#       Testing
#      Platforms : Linux 2.2.16   TCL v8.3
#                  Eggdrop v1.6.2
#            And : SunOS 5.8      TCL v8.3
#                  Eggdrop v1.5.4
#
#    Description : Channel Guardian attempts to add some general channel
#                  protection to your bot. 
#       Features :
#                  o Repeat Kick/Banner
#                  o Single Character flood ban
#                  o Subtraction character Flood Ban
#                  o Addition character Flood Ban
#                  o Botnet join flood protection
#                  o Botnet flood protection on notice/ctcp/msg
#                  o Caps warn/kick/ban
#                  o Color warn/kick/ban
#                  o No Spaces warn/kick/ban
#                  o Auto-Banning for flooders
#                  o Botnet ban request capable
#                  o Kicks users who are not channel OPs and kicks or
#                    changes modes. (UnderNet EU Server desync problem)
#                  o Auto-bans for eggdrop bracket exploit
#                  o Ability to call in other bots on same net to help in
#                    channel attacks.
#
#        History : 04/15/2002 - First Release
#                  06/23/2002 - v1.01
#                              o Fixed "Missing publics" variable error
#
#
#   Future Plans : Fix Bugs. :)
#                 o Figure out best way to not trigger botnet join attack
#                   protection when a split rejoin happens.
#                 o Improve botnet join attack protection (counter messure
#                    speed mostly)
#
# Author Contact :     Email - DProper@stx.rr.com
#                  Home Page - http://home.stx.rr.com/dproper
#       Homepage Direct Link - http://www.chaotix.net:3000/~dproper
#                        IRC - Primary Nick: DrN
#                     UseNet - alt.irc.bots.eggdrop
# Support Channels: #RCS @UnderNet.Org
#                   #RCS @DALnet
#                   #RCS @EFnet
#                   #RCS @GalaxyNet
#                   #RCS @ChatGalaxy
#                   #RCS @Choatix Addiction
#
#                Current contact information can be located at:
#                 http://www.chaotix.net:3000/rcs/contact.html
#
# New TCL releases are sent to the following sites as soon as they're released:
#
# FTP Site                   | Directory                     
# ---------------------------+-------------------------------
# ftp.chaotix.net            | /pub/RCS
# ftp.eggheads.org           | Various
# drn.realmweb.org           | /drn
#
# Chaotix.Net has returned. site and mailing list is back.
#
#   Radical Computer Systems - http://www.chaotix.net:3000/rcs/
# To subscribe to the RCS mailing list: mail majordomo@chaotix.net and in
#  BODY of message, type  subscribe rcs-list
#
#  Feel free to Email me any suggestions/bug reports/etc.
# 
# You are free to use this TCL/script as long as:
#  1) You don't remove or change author credit
#  2) You don't release it in modified form. (Only the original)
# 
# If you have a "too cool" modification, send it to me and it'll be
# included in the official release. (With your credit)
#
# Commands Added:
#  Where     F CMD          F CMD            F CMD           F CMD
#  -------   - ----------   - ------------   - -----------   - ----------
#  Public:   N/A
#     MSG:   N/A
#     DCC:   N/A
#
# Public Matching: N/A
#



set guard(ver) "v1.01.00"
set guard(tag) "\[\002Guard\002\]"



if {[info exists guardn]} {unset guardn}
if {[info exists guardj]} {unset guardj}
if {[info exists guardc]} {unset guardc}


# This variable is set to 0 during some attacks. Usefull to have
# "toy scripts" check it so if there's a flood going on it wont
# activate things that could slow the bot down or aid in flooding it off
if {![info exists publics]} {set publics 1}

# [0/1] Set to 1 if you want the bot to send out a "911" call when being
#       attacked to other bots on the botnet. Bots on the same net that
#       answer the call will join the attacked channel and get OPs.
#       (They will only be auto-OPed for a short period after the 911 call
#        is placed.)
set guard(dial911) 1

# This is the userflag the bot record must have to get auto-OPs during
# a 911 call. Only when the calling bot is in "911 condition" can any
# bots gets OPed that join.
set guard(911flag) C

# [0/1] Set this to 1 if you wish to use the IRC server SILENCE command.
set guard(usesilence) 1

# Time in minutes that a channel lockdown will last.
set guard(lockdowntime) 5

# [0/1] Set this to 1 if you want to kick/ban any user with non-standard
#       charactors in thier account name. (High ASCII)
set guard(nobogus) 1

# This is the time in second to ban users with non-standard charactors
# in thier account name. (Mainly to prevent auto-rejoin)
set guard(bogusban) 30

# This is the number of seconds data records are kept.
set guard(expire) 3600

# This is the number of minutes to check for expired data.
set guard(expiret) 30

# Change this if you have bots linked in that are on other networks if you
# don't want them to set bans requested by the script, answer 911 calls,
# etc.
set guard(netcode) 927

# General ban length in minutes. Don't belive I use it anymore.
set guard(bantime) 60

# Time in minutes to ban flooders. Not sure it's used anymore.
set guard(floodbantime) 10

# X:Y Lock down if there's more then X joins in Y seconds
set guard(joinflood) "10:30"

# X:Y Lock down if there's more then X messages in Y seconds
set guard(msgflood) "10:30"

# X:Y Lock down if there's more then X CTCP in Y seconds
set guard(ctcpflood) "10:20"

# X:Y Lock down if there's more then X notices in Y seconds
set guard(noticeflood) "10:20"

# Maximim percentage of caps a line may contain
set guard(caps_per) 65

# Minimum length of line to check for all caps.
set guard(caps_min) 30

#####[ Caps Lock ]#####
# If you need to be told what this variable is, then you don't need a bot. :p
set guard(caps_reason) "Please do not use excessive caps."
# Number of offences before warning. 
set guard(caps_warn) 999
# Number of offences before kicking.
set guard(caps_kick) 1
# Number of offences before banning.
set guard(caps_ban) 2

#####[ No Spaces ]#####
# Minimun numbers of charactors a line must contain before being checked. 
set guard(spaces_min) 60
# Number of offences before warning.
set guard(spaces_warn) 999
# Number of offences before kicking.
set guard(spaces_kick) 1
# Number of offences before banning.
set guard(spaces_ban) 2
# Again, if ya need to be told what this variable is, just kill yourself.
set guard(spaces_reason) "Uhm. Try using some spaces next time."

#####[ Repeating ]#####
# Number of offences before warning.
set guard(repeat_warn) 3
# Number of offences before kicking.
set guard(repeat_kick) 5
# Number of offences before banning.
set guard(repeat_ban) 6

#####[ Add Charactor Flood ]#####
# Number of offences before banning on an add-charactor flood
set guard(addflood_ban) 4
set guard(addflood_reason) "ACF:There goes another float in the idiot parade"

#####[ Subtraction Charactor Flood ]#####
# Number of offences before banning on a subtraction-charactor flood
set guard(subflood_ban) 4
set guard(subflood_reason) "SCF:There goes another float in the idiot parade"

#####[ Single Charactor Flood ]#####
# Number of offences before banning on a single-charactor flood
set guard(scflood_ban) 5
set guard(scflood_reason) "1CF:There goes another float in the idiot parade"

#####[ Excessive Colors ]#####
# Channel(s) to check for excessive colors
set guard(nocolors) "#love"
# Number of offences before warning.
set guard(color_warn) 5
# Number of offences before kicking.
set guard(color_kick) 7
# Number of offences before banning
set guard(color_ban) 8
# Minimum number of color codes before checking.
set guard(color_max) 1
# You guessed it. If you need to be told what this variable is, you're an idiot.
set guard(color_reason) "Please do not use excessive colors on channel"






##### No more user definable variables beyond this point. #####












##### No. Really. No user servicable parts beyond this area #####












##### Stuborn little shit, arn't ya? #####















##### Go away allready. lol #####











bind kick - ** kickguard
proc kickguard {nick uh hand chan target reason} {
if {$nick == "!"} {return 0}
if {![isop $nick $chan]} {
 guardkick $nick $chan "NonOPed user abusing dysync"
 putlog "DESYNC ABUSE: $nick!$uh on $chan Kicked $target ($reason)"
                          }
 return 0
                                                  }

bind mode - ** modeguard
proc modeguard {nick uh hand chan mode target} {
if {$nick == ""} {return 0}
#if {[validop $hand $chan]} {return 0}
if {(![isop $nick $chan]) && ($target != $nick)} {
 guardkick $nick $chan "NonOPed user abusing dysync"
 putlog "DESYNC ABUSE: $nick!$uh on $chan Set mode $mode $target"
                          }
 return 0
                                                  }


proc guard_jdec {chan} {
 global guardj
 incr guardj($chan) -1
}

proc guard_dec {type} {
 global guardc
 incr guardc($type) -1
}

proc guard_inc {type flimit ftime } {
global guardc
 if {![info exists guardc($type)]} {set guardc($type) 1} else {incr guardc($type) 1}
 utimer $ftime "guard_dec $type"
 if {$guardc($type) < $flimit} {return 1}

 putlog "$type over max hits of $flimit in $ftime seconds"
 guard_lockdown $type
}

bind join - * guard_join
proc guard_join {nick uhost hand chan} {
global guard guardj
 if {[matchattr $hand E] == 1} {return 0}
 if {[onchansplit $nick $chan]} {putlog "$chan returned from split";return 0}
 set sitemask "*!*[string trimleft [maskhost $uhost] *!]"
 set chan [string tolower $chan]
 set account [string tolower [string range $uhost 0 [expr [string first @ $uhost] - 1]]]

 if {$guard(nobogus) && [guard_isbogus $account]} {
 guardban $nick $sitemask $chan "Bogus Account Name Detected"
                                                  }


 if {![info exists guardj($chan)]} {set guardj($chan) 1} else {incr guardj($chan) 1}
 utimer $guard(jointime) "guard_jdec $chan"
 if {$guardj($chan) < $guard(join)} {return 1}
  putlog "$chan over max joins of $guard(join) in $guard(jointime) seconds"
  guard_dial911 $chan
  if {[botisop $chan] == 0} {putlog "$guard(tag) Possible botnet join- NotOPed. Can't do anything."; return 1}
  set reason "Possible Botnet join detected"
#  putserv "privmsg $chan: Guardian Warning: Possible Botnet join detected"
# guardban $nick $sitemask $chan "Possible Botnet join detected"
#guardkick $nick $chan $reason

 guard_lockdown BotNetJoin
 if {([expr [unixtime] - $guard(lastlimit)] > 300)} {
   set guard(lastlimit) [unixtime]
   putquick "MODE $chan +il [llength [chanlist $chan]]" -next
   utimer 60 "guard_unlock $chan"
                                                   }
#  putallbots "guardban $guard(netcode) $nick $uhost $sitemask $reason 10"
}

proc guard_isbogus {acount} {
 if {[regsub -all -- "\[^\041-\176\]" $acount "" temp] >= 1} {return 1}
 return 0
}

bind ctcr - PING guard_reply
proc guard_reply {nick uhost hand dest key arg} {
global guard
 subst -nobackslashes -nocommands -novariables arg
 regsub -all {\[} $arg "!EXPLOIT!" arg
 regsub -all {\]} $arg "!EXPLOIT!" arg
 regsub -all {\"} $arg "!QT!" arg
if {([string match "*!EXPLOIT!*" " $arg "] > 0)} {
   putlog "$guard(tag) BUG exploit by $nick!$uhost\($hand\): $arg on $dest"
   set sitemask "*!*[string trimleft [maskhost $uhost] *!]"
   guardban $nick $sitemask "*" "Bracket Exploit Attempt"
   return 1
                                              }
}

proc guard_unlock {chan} {
 putserv "MODE $chan -i-l"
}

proc guard_ram {text} {
 set serveridx 0
 set data [dcclist]
 foreach line $data {
  if {[string tolower [lindex $line 3]] == "server"} {set serveridx [lindex $line 0]}
                    }
 if {$serveridx == 0} {putserv "$text"} else {putdcc $serveridx "$text"}
 unset serveridx data
}


bind pubm - "% *" pub_guard
proc pub_guard {nick uhost hand chan rest} {
subst -nobackslashes -nocommands -novariables text
 guard $nick $uhost $hand $chan $rest
}

bind notc - "*" notice_guard
proc notice_guard {nick uhost hand text dest} {
 global guard
 subst -nobackslashes -nocommands -novariables text
 guard $nick $uhost $hand "*" $text
 guard_inc notice $guard(notice) $guard(noticetime)
}

bind ctcp - ACTION action_guard
proc action_guard {nick uhost hand chan key text} {
 global guard
 subst -nobackslashes -nocommands -novariables text
 guard $nick $uhost $hand $chan $text
}

bind msgm - "*" msg_guard
proc msg_guard {nick uhost hand text} {
 global guard
 guard $nick $uhost $hand "*" $text
 guard_inc msg $guard(msg) $guard(msgtime)
}

bind ctcp - "PING" ctcp_guard
bind ctcp - "FINGER" ctcp_guard
bind ctcp - "TIME" ctcp_guard
bind ctcp - "CLIENTINFO" ctcp_guard
bind ctcp - "VERSION" ctcp_guard

proc ctcp_guard {nick uhost hand dest key rest} {
global guard
 subst -nobackslashes -nocommands -novariables rest
 guard_inc ctcp $guard(ctcp) $guard(ctcptime)
 guard "$nick" $uhost "$hand" "*" "$rest"
 return 0
}

bind flud - * guard_flood
proc guard_flood {nick uhost hand type chan} {
global guard
if {([matchattr $hand b])} {return 0}
if {([matchattr $hand o])} {return 0}
if {([matchattr $hand f])} {return 0}
if {$chan != "*"} {
 if {([matchchanattr $hand |o $chan])} {return 0}
 if {([matchchanattr $hand |f $chan])} {return 0}
 if {[isop $nick $chan]} {return 0}
                  }
 putlog "FLOOD: From:$nick!$uhost Type: $type Chan:$chan"
 set sitemask "*!*[string trimleft [maskhost $uhost] *!]"
 newban $sitemask Guardian "$type flood detected. Naughty Monkey. Go sit in the corner." $guard(floodbantime)
 newignore $sitemask Guardian "$type flood detected. Naughty Monkey. Go sit in the corner." $guard(floodbantime)
 guard_dial911 $chan
 guard_lockdown $type
}

proc guard_lockdown {type} {
global guard publics
 if {$guard(lockdown) == 1} {return 0}
 set guard(lockdown) 1
 set type [string tolower $type]
 putlog "$guard(tag) Entering Lockdown mode from a $type flood"
 set guard(oldpublics) $publics
 set publics 0
 if {[lsearch -glob "notice msg ctcp" "*$type*"] > -1} {
    newignore *!*@* Guardian "$type flood lockdown" $guard(lockdowntime)
    if {$guard(usesilence) == 1} {putserv "SILENCE *!*@*"}
                                                       }
 timer $guard(lockdowntime) guard_standdown
}

proc guard_standdown {} {
global guard publics
 if {$guard(lockdown) == 0} {return 0}
 set guard(lockdown) 0
 putlog "$guard(tag) Standing down."
 set publics $guard(oldpublics)
 unset guard(oldpublics)
 killignore *!*@*
 if {$guard(usesilence) == 1} {putserv "SILENCE -*!*@*"}

}

proc guard {nick uhost hand desc text} {
global guard guardn
subst -nobackslashes -nocommands -novariables text
if {([matchattr $hand b])} {return 0}
if {([matchattr $hand o])} {return 0}
if {([matchattr $hand f])} {return 0}
if {($desc != "*") && ([string index $desc 0] == "#")} {
 if {([matchchanattr $hand |o $desc])} {return 0}
 if {([matchchanattr $hand |f $desc])} {return 0}
 if {[isop $nick $desc]} {return 0}
                  }
regsub -all {\{} $text "?" text
regsub -all {\(} $text "?" text
regsub -all {\"} $text "?" text
regsub -all {\[} $text "?" text
regsub -all {\]} $text "?" text

set rtext $text
if {[llength $text] == 1} {set text [lindex $text 0]}
set text [string tolower $text]

set lnick [string tolower $nick]
set sitemask "*!*[string trimleft [maskhost $uhost] *!]"
if {![info exists guardn($lnick)]} {set guardn($lnick) "0 0 0 0 0 0 0 [unixtime] $text"
                                    append guardn(nicks) "$lnick "
                                   }

 set g_repeat [lindex $guardn($lnick) 0]
 set g_sflood [lindex $guardn($lnick) 1]
 set g_aflood [lindex $guardn($lnick) 2]
 set g_1flood [lindex $guardn($lnick) 3]
 set g_cc [lindex $guardn($lnick) 4]
 set g_caps [lindex $guardn($lnick) 5]
 set g_spaces [lindex $guardn($lnick) 6]
 set g_time [lindex $guardn($lnick) 7]
 set g_text [lrange $guardn($lnick) 8 end]

 set caps 0
 set spaces 0
 set gloop 0; set CC 0
 while {$gloop < [string length $text]} {
  if {[string match "*[string index $rtext $gloop]*" "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]} {incr caps 1}
  if {[string index $text $gloop] == "\003"} {incr CC 1}
  if {[string index $text $gloop] == " "} {incr spaces 1}
  incr gloop 1
                                        }
if {([guardchan $desc $guard(nocolors)]) && ($CC >> $guard(color_max))} {incr g_cc 1} else {set g_cc 0}
set totc [string length $rtext]
if {$text != ""} {set capsp [expr (${caps}.0 / ${totc}.0) * 100]} else {set capsp 0}
if {($totc > $guard(caps_min)) && ($capsp > $guard(caps_per))} {incr g_caps 1} else {set g_caps 0}
if {($totc > $guard(spaces_min)) && ($spaces == 0)} {incr g_spaces 1} else {set g_spaces 0}

#repeat flood
 if {$g_text == $text} {incr g_repeat 1} else {set g_repeat 0}
# Add char flood
if {[string range $text 0 [expr [string length $text] - 2]] == $g_text} {incr g_aflood} else {set g_aflood 0}
# Sub char flood
if {[string range $g_text 0 [expr [string length $g_text] - 2]] == $text} {incr g_sflood} else {set g_sflood 0}

if {[string length $text] == 1} {incr g_1flood} else {set g_1flood 0}
#if ([$strlen($Rtext)] == 1) {@SCcnt = SCcnt + 1}{@SCcnt = 1}

 if {$g_cc == $guard(color_warn)} {guardsay $nick $desc "$nick: $guard(color_reason)"}
 if {$g_cc == $guard(color_kick)} {guardkick $nick $desc $guard(color_reason)}
 if {$g_cc == $guard(color_ban)} {guardban $nick $sitemask $desc $guard(color_reason)}

 if {$g_spaces == $guard(spaces_warn)} {guardsay $nick $desc "$nick: $guard(color_spaces)"}
 if {$g_spaces == $guard(spaces_kick)} {guardkick $nick $desc $guard(spaces_reason)}
 if {$g_spaces == $guard(spaces_ban)} {guardban $nick $sitemask $desc $guard(spaces_reason)}


 if {$g_caps == $guard(caps_warn)} {guardsay $nick $desc "$nick: $guard(caps_reason)"}
 if {$g_caps == $guard(caps_kick)} {guardkick $nick $desc "$guard(caps_reason)"}
 if {$g_caps == $guard(caps_ban)} {guardban $nick $sitemask $desc "$guard(caps_reason)"}

 if {$g_1flood == $guard(scflood_ban)} {set g_1flood 0; guardban $nick $sitemask $desc $guard(scflood_reason)}
 if {$g_sflood == $guard(subflood_ban)} {set g_sflood 0; guardban $nick $sitemask $desc $guard(subflood_reason)}
 if {$g_aflood == $guard(addflood_ban)} {set g_aflood 0; guardban $nick $sitemask $desc $guard(addflood_reason)}
 if {$g_repeat == $guard(repeat_warn)} {guardsay $nick $desc "$nick: Please do not repeat"}
 if {$g_repeat == $guard(repeat_kick)} {guardkick $nick $desc "$nick: Please do not repeat. Last warning."}
 if {$g_repeat == $guard(repeat_ban)} {guardban $nick $sitemask $desc "Don't Repeat! Don't Repeat! Don't Repeat! Don't Repeat!"}

 set guardn($lnick) "$g_repeat $g_sflood $g_aflood $g_1flood $g_cc $g_caps $g_spaces [unixtime] $text"
 return 0
}

proc guardchan {chan chans} {
 set chan [string tolower $chan]
 set chans [string tolower $chans]
 set dothechan 0
 foreach c $chans {
  if {($chan == $c)} {set dothechan 1}
                  }
 if {$dothechan == 0} {return 0} else {return 1}
}

proc guardsay {nick chan text} {
 if {$chan != "*"} {putserv "PRIVMSG $chan :$text"}
 putserv "PRIVMSG $nick :$text"
}

proc guardkick {nick chan reason} {
if {[string index $chan 0] == "#"} {putquick "KICK $chan $nick :$reason"} else { guard_kickfromallchans $nick $reason}
}

proc guard_kickfromallchans {nick reason} {
  foreach chan [channels] {
   if {[onchan $nick $chan]} {
                              putserv "KICK $chan $nick :\002$reason\002"
                             }
                          }
}

proc guardban {nick sitemask chan reason} {
global guard
 putallbots "guardban $guard(netcode) $nick $sitemask $sitemask $reason"
if {[string index $chan 0] == "#"} {
 newchanban $chan $sitemask Guardian $reason $guard(bantime)
 putserv "KICK $chan $nick :$reason"
                                   } else {
                        newban $sitemask Guardian "$reason" $guard(bantime)
                        guard_kickfromallchans $nick "$reason"
                                          }
#  newchanban <channel> <ban> <creator> <comment> [lifetime] [options]
#  newban <ban> <creator> <comment> [lifetime] [options]
}


bind bot - guardban_reply guardban_reply_in
proc guardban_reply_in {bot cmd args} {
 global guard
 putlog "$guard(tag) Guardban reply from $bot: $args"
                                      }

bind bot - guardban guardban_in
proc guardban_in {bot cmd arg} {
 global guard network
 set c [lindex $arg 0]
 set n [lindex $arg 1]
 set u [lindex $arg 2]
 set s [lindex $arg 3]
 set r [lrange $arg 4 end]
 if {$c == $guard(netcode)} {
  putlog "$guard(tag) ban requested from $bot: nick:$n uhost:$u sitemask:$s reason:$r"
  set data [finduser $n!$u]
  if {$data != "*"} {putbot $bot "guardban_reply Sorry, $n!$u matches one of my users. (Handle:$data)"
                     putlog "$guard(tag) $n!$u matches user ($data). Not banning."
                     return 0}
  if {[isban $s]} {putbot $bot "guardban_reply $s is allready in my ban list."
                   putlog "$guard(tag) $s allready in banlist."
                   return 0}

 newban $s Guardian "($bot) $r" $guard(bantime)

  putbot $bot "guardban_reply $s has been banned: $r"
                            }
                                 }
proc guard_dial911 {chan} {
 global guard 
  if {$guard(in911) == 1} {return 0}
  if {![botisop $chan]} {putlog "$guard(tag) Not OPed on $chan! Can't call 911!"}
  set guard(in911) 1
  putallbots "guard911 $guard(netcode) $chan"
  putlog "$guard(tag) Placing 911 call to botnet $guard(netcode)"
  timer 10 guardend911
}

proc guardend911 {} {
 global guard
 putlog "$guard(tag) Halting 911 call"
 set guard(in911) 0
}

#  putallbots "guard911 $guard(netcode) $chan"
bind bot - guard911 guard911_in
proc guard911_in {bot cmd arg} {
 global guard network
 set c [lindex $arg 0]
 set chan [lindex $arg 1]
 if {$c == $guard(netcode)} {
  putlog "$guard(tag) 911 call recieved from $bot for channel $chan"
  if {![validchan $chan]} {
   putlog "$guard(tag) Answering 911 call"
   channel add $chan
   timer 20 "guard911hu $chan"
                          }
                            }
}
proc guard911hu {chan} {
 global guard
 putlog "$guard(tag) 911 Call Has Ended for $chan"
 channel remove $chan
}

bind join $guard(911flag) * guard_911join
proc guard_911join {nick uhost hand chan} {
 global guard
 if {$guard(in911) == 1} {putquick "MODE $chan +o $nick"}
}


proc guard_slasher {line} {
                    regsub -all {\\} $line "\\\\" line
                    regsub -all {\<} $line "\\\<" line
                    regsub -all {\>} $line "\\\>" line
                    regsub -all {\"} $line "\\\"" line
                    regsub -all {\(} $line "\\\(" line
                    regsub -all {\)} $line "\\\)" line
                    regsub -all {\{} $line "\\\{" line
                    regsub -all {\}} $line "\\\}" line
                    regsub -all {\[} $line "\\\[" line
                    regsub -all {\]} $line "\\\]" line
                    regsub -all {\;} $line "\\\;" line
                    regsub -all {\:} $line "\\\:" line
                    regsub -all {\.} $line "\\\." line
  return $line
}

proc validop {hand chan} {
if {([matchattr $hand b])} {return 1}
if {([matchattr $hand o])} {return 1}
if {([matchattr $hand f])} {return 1}
if {$chan != "*"} {
 if {([matchchanattr $hand |o $chan])} {return 1}
 if {([matchchanattr $hand |f $chan])} {return 1}
 if {[isop $nick $chan]} {return 1}
                  }
return 0
}

proc guard_expire {} {
global guardn guard
 if {![info exists guardn]} {return 0}
 putlog "$guard(tag) Checking for expired data"
 set newnicks ""
 foreach n [string tolower $guardn(nicks)] {
  set g_time [lindex $guardn($n) 7]
  set g_last [expr [unixtime] - $g_time]
  if {$g_last > $guard(expire)} {unset guardn($n)} else {append newnicks "$n "}
                     }
 putlog "$guard(tag) [llength $newnicks] out of [llength $guardn(nicks)] kept."
 set guardn(nicks) $newnicks

timer $guard(expiret) guard_expire
}
timer $guard(expiret) guard_expire

proc guard_loadfloodtimes {n t v nd td} {
global guard
set guard($n) $nd
set guard($t) $td
 if {![regexp ":" "$v"]} {putlog "ERROR: Can't parse $v correctlly. Using defualt of $nd:$td"
} else {
      set g [string first ":" $v]
      set g1 [string range $v 0 [expr $g - 1]]
      set g2 [string range $v [expr $g + 1] end]
 if {($g1 > 0)} {set guard($n) $g1}
 if {($g2 > 0)} {set guard($t) $g2}
}
#putlog "Parsed $v and got $n value of $guard($n) and $t value of $guard($t)"
}

# These settings are used internally by the script. Don't be an ass and
# mess with them. :p

set guard(joins) 0; guard_loadfloodtimes join jointime $guard(joinflood) 10 60
set guard(msgs) 0;  guard_loadfloodtimes msg msgtime $guard(msgflood) 10 40
set guard(ctcp) 0; guard_loadfloodtimes ctcp ctcptime $guard(ctcpflood) 10 20
set guard(notices) 0; guard_loadfloodtimes notice noticetime $guard(noticeflood) 10 20
set guard(lockdown) 0
set guard(in911) 0
set guard(lastlimit) [expr [unixtime] - 1000]

putlog "Channel Guardian $guard(ver) by David Proper (DrN) -: LoadeD :-"
return "Channel Guardian $guard(ver) by David Proper (DrN) -: LoadeD :-"


