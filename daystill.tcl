#         Script : Daystill v1.01 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2002 Radical Computer Systems
#                             All Rights Reserved
#
#       Testing
#      Platforms : Linux 2.4.18   TCL v8.3.4
#                  Eggdrop v1.5.4
#                  Eggdrop v1.6.12
#            And : SunOS 5.8      TCL v8.3
#                  Eggdrop v1.5.4
#
#    Description : Days Till will display how many days until or since a
#                  given date. Default setup is for Christmas.
#                  Can spit out a list of multiple dates as well
#
#        History : 10/26/2002 - First Release
#                  11/03/2002 - v1.01
#                              o Only show days, not hours.
#                                The fix I used before for this fucked it up.
#                              o Oh hell, forgot to include [thes] proc.
#                                (Reported by Dirk)
#                              o Made it easier to quickly modify for 
#                                multiple commands for diff dates. First 
#                                step towards multi-date useage. :)
#                              o Threw in multi-date listing. :)
#                              o Added message and DCC commands
#
#      Donations : https://www.paypal.com/xclick/business=rainbows%40stx.rr.com
# (If you don't have PayPal and want to donate, EMail me for an address.
#  Will take money or hardware/computer donations)
#  Significant (or even non-significant donations) can be published on a
#  web site if you so choose.
#
#        Support : Wanna support RCS? Link to our homepage and our other sites.
#                  The House Of X    - http://www.thehouseofx.com
#                  The Flesh Factory - http://www.thefleshfactory.com
#                  GodSlayer         - http://www.godslayer.org
#
#                  We have several other sub sites under The Flesh Factory 
#                  you can link to as well. Or just goto the sites and
#                  sign up at the sponcer sites. :)
#
#   Future Plans : Fix Bugs. :)
#
# Author Contact :     Email - DProper@stx.rr.com
#                   Homepage - http://www.chaotix.net/~dproper
#                        IRC - Primary Nick: DrN
#                     UseNet - alt.irc.bots.eggdrop
# Support Channels: #RCS @UnderNet.Org
#                   #RCS @DALnet
#                   #RCS @EFnet
#                   #RCS @GalaxyNet
#                   #RCS @Choatix Addiction
#            Other channels - Check contact page for current list
#
#                Current contact information can be located at:
#                 http://rcs.chaotix.net/contact.html
#
# New TCL releases are sent to the following sites as soon as they're released:
#
# FTP Site                   | Directory                     
# ---------------------------+-------------------------------
# ftp.chaotix.net            | /pub/RCS
# ftp.eggheads.org           | Various
# ftp.realmweb.org           | /drn
#
# Chaotix.Net has returned. Web site and mailing list back online
# Main sites are still being repaired. 
#
#   Radical Computer Systems - http://rcs.chaotix.net/
# To subscribe to the RCS mailing list: 
#  http://www.chaotix.net/mailman/listinfo/rcs-list
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
#  Public:   - !daystill    - [userdefined]
#     MSG:   - daystill     - [userdefined]
#     DCC:   - daystill     - [userdefined]
#
# Public Matching: N/A
#

# This is the target month.
set daystill(month) 12
#set daystill(month) 2

# This is the target day.
set daystill(day) 25
#set daystill(day) 8

# If year is 0, it will use the current year. Or next year if the 
# date has passed.
set daystill(year) 0

# Set this to the name of the date you are showing days till/from.
set daystill(name) "Yule (Christmas)"
#set daystill(name) "DrN's Birthday"

# Set this to the command name to trigger the single date countdown
set daystill(trigger) "xmas"

# Set this to a list of dates for the !daystill trigger.
# It will list them all out in channel.
# FORMAT: 
# month day year name
# Like with the single daystill, if year is 0 it will use the current
# or next year if current year's date would have allready of passed.
set daystill(list) {
 {12 25 0000 Yule (Christmas)}
 {02 08 0000 DrN's Birthday}
 {01 01 0000 New Years}
                   }

# Set this to the channel you want on-join announcment for. Leave blank
# to have none.
set daystill(onjoinchan) "#RCS"
set daystill(onjoinchan) ""

# Set this to the command charactor to preceed all public commands
set cmdchar_ "!"


set daystill(ver) "v1.01.00"

proc cmdchar { } {global cmdchar_; return $cmdchar_}


bind join - ******* do_daystill_join
proc do_daystill_join {nick uhost hand chan} {
global daystill
 if {![$daystillchan $chan]} {return 0}
 putserv "NOTICE $nick :[getdaystill $daystill(month) $daystill(day) $daystill(year) $daystill(name)]"
}

proc daystillchan {$chan} {
global daystill
 if {$daystill(onjoinchan) == ""} {return 0}
 set chans [string tolower $daystill(onjoinchan)]
 if {$chans == "*"} {set chans [string tolower [channels]]}
 if {[lsearch -glob $chans [string tolower "*$chan*"]] > -1 } {return 1}
 return 0
}

proc getdaystill {month day year name} {
 set timediff [daystill $month $day $year]
if {$timediff > 0} {return "There are [lindex [tdiff2 $timediff] 0] days until $name"}
if {$timediff == 0} {return "Today is $name!"}
if {$timediff < 0} {
                    set timediff [expr $timediff - ($timediff * 2)]
                     return "It's been [lindex [tdiff2 $timediff] 0] days Since last $name"
                   }
                                                                
}


bind pub - [cmdchar]$daystill(trigger) pub_daystill
proc pub_daystill {nick uhost hand chan rest} {
global daystill
 putserv "PRIVMSG $chan :[getdaystill $daystill(month) $daystill(day) $daystill(year) $daystill(name)]"
}

bind msg - $daystill(trigger) msg_daystill
proc msg_daystill {nick uhost handle args} {
global daystill
 putserv "PRIVMSG $nick :[getdaystill $daystill(month) $daystill(day) $daystill(year) $daystill(name)]"
}

bind dcc - $daystill(trigger) dcc_daystill
proc dcc_daystill {handle idx args} {
global daystill
 putdcc $idx "[getdaystill $daystill(month) $daystill(day) $daystill(year) $daystill(name)]"
}

bind dcc - daystill dcc_daystillm
proc dcc_daystillm {handle idx args} {
global daystill
 foreach line $daystill(list) {
 set month [lindex $line 0]
 set day [lindex $line 1]
 set year [lindex $line 2]
 set name [lrange $line 3 end]
 putdcc $idx "[getdaystill $month $day $year $name]"
                              }
}

bind msg - daystill msg_daystillm
proc msg_daystillm {nick uhost handle args} {
global daystill
 foreach line $daystill(list) {
 set month [lindex $line 0]
 set day [lindex $line 1]
 set year [lindex $line 2]
 set name [lrange $line 3 end]
 putserv "PRIVMSG $nick :[getdaystill $month $day $year $name]"
                              }
}



bind pub - [cmdchar]daystill pub_daystillm
proc pub_daystillm {nick uhost hand chan rest} {
global daystill
 foreach line $daystill(list) {
 set month [lindex $line 0]
 set day [lindex $line 1]
 set year [lindex $line 2]
 set name [lrange $line 3 end]
 putserv "PRIVMSG $chan :[getdaystill $month $day $year $name]"
                              }
}

proc daystill {targetmonth targetday targetyear} {
  set rtime [ctime [unixtime]]
  set amonth [string range $rtime 4 6]

  switch $amonth {
    Jan {set month "1"}
    Feb {set month "2"}
    Mar {set month "3"}
    Apr {set month "4"}
    May {set month "5"}
    Jun {set month "6"}
    Jul {set month "7"}
    Aug {set month "8"}
    Sep {set month "9"}
    Oct {set month "10"}
    Nov {set month "11"}
    Dec {set month "12"}
  }


  set day [lindex $rtime 2]
  set year [string range $rtime 20 23]
  set date1 [clock scan $month/$day/$year]
  if {$targetyear == 0} {set targetyear $year
       set date2 [clock scan $targetmonth/$targetday/$targetyear]
       if {$date2<$date1} {set targetyear [expr $year + 1]}
                        }

  set date2 [clock scan $targetmonth/$targetday/$targetyear]
  set date3 [expr $date2 - $date1]
  return $date3
}


proc tdiff {t} {
 return [dotdiff 1 $t]
}
proc tdiff2 {t} {
 return [dotdiff 2 $t]
}

proc dotdiff {v ltime} {
 if {$v == 1} {
               set m_ "m"
               set h_ "h"
               set d_ "d"
               set s_ "s"
              } else {
               set m_ " minute"
               set h_ " hour"
               set d_ " day"
               set s_ " second"
                     }
set days 0
set hours 0
set minutes 0
set seconds 0
set after 0
set out ""

set seconds [expr $ltime % 60]
set ltime [expr ($ltime - $seconds) / 60]
set minutes [expr $ltime % 60]
set ltime [expr ($ltime - $minutes) / 60]
set hours [expr $ltime % 24]
set days [expr ($ltime - $hours) / 24]
if {$v == 1} {
if {$days > 0} {append out "${days}$d_ "}
if {$hours > 0} {append out "${hours}$h_ "}
if {$minutes > 0} {append out "${minutes}$m_ "}
if {$seconds > 0} {append out "${seconds}$s_ "}
             } else {
 if {$days > 0} {append out "${days}$d_[thes $days] "}
 if {$hours > 0} {append out "${hours}$h_[thes $hours] "}
 if {$minutes > 0} {append out "${minutes}$m_[thes $minutes] "}
 if {$seconds > 0} {append out "${seconds}$s_[thes $seconds] "}
                    }

if {[string index $out [expr [string length $out] - 1]] == " "} {
  set out [string range $out 0 [expr [string length $out] - 2]]}
return "$out"
}

proc thes {num} {
if {$num == 1} {return ""} else {return "s"}
}


putlog "Daystill $daystill(ver) by David Proper (DrN) -:LoadeD:-"
return "Daystill $daystill(ver) by David Proper (DrN) -:LoadeD:-"

