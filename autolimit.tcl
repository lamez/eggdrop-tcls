#         Script : AutoLimit v1.02 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2002 Radical Computer Systems
#
#       Testing
#      Platforms : Linux 2.2.16
#                  Eggdrop v1.6.2
#            And : SunOS 5.8
#                  Eggdrop v1.5.4
#
#    Description : AutoLimit will let your bot automatically set a new
#                  channel limit using a predefined set of values.
#                  If anything it should help in botnet/clone attacks.
#
#        History : 05/02/2001 - First Release
#                  03/29/2002 - v1.01
#                              o Fixed logic problem
#                  06/21/2002 - v1.02
#                              o Wont reset limit if it's the same.
#
#
#   Future Plans : Good question. Send in any ideas.
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
#############################  Chaotix.net has returned
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
#  Where     F CMD       F CMD         F CMD        F CMD
#  -------   - --------- - ----------- - ---------- - --------- - -------
#  Public:   - N/A
#     MSG:   - N/A
#     DCC:   - N/A
#
# Public Matching: N/A
#


set autolimit(ver) "v1.02.01"

# This is a list of channels you want an auto-limit on. Multiple channels
# seperated by spaces.
set autolimit(chans) "#amiga"

# This is the base number to add to the total channel count for the new limit
set autolimit(base) 10

# This is the difference between the current limit and user count before
# a new limit is set.
set autolimit(diff) 5

# This is the timer, in minutes, between checks.
set autolimit(timer) 10

proc check_autolimit {} {
 global autolimit
 foreach c [string tolower [channels]] {
  autolimit $c
                   }
 timer $autolimit(timer) check_autolimit
}

proc autolimit {chan} {
 global autolimit

 set dochan 999
 foreach c [string tolower $autolimit(chans)] {
  if {$c == $chan} {set dochan 1}  
                                              }
 if {$dochan != 1} {return 0}
 if {![botonchan $chan]} {return 0}
 set modes [string tolower [getchanmode $chan]]
 set modev [lindex $modes 0]

 set count 0
 set num 0
 set limit 0

 while {$count < [string length $modev]} {
  set ch [string index $modev $count]
  if {$ch == "k"} {incr num}
  if {$ch == "l"} {incr num
                   set limit [lindex $modes $num]
                  }
  incr count
                                          }
 set usercount [llength [chanlist $chan]]
 if {$limit > $usercount} {set ldiff [expr $limit - $usercount]
                          } else {set ldiff [expr $usercount - $limit]}

 if {$limit == [expr $usercount + $autolimit(base)]} {return 0}

 if {$ldiff > $autolimit(diff)} {putserv "MODE $chan +l [expr $usercount + $autolimit(base)]"}
}

timer $autolimit(timer) check_autolimit
putlog "AutoLimit $autolimit(ver) by David Proper (DrN) -: LoadeD :-"
return "AutoLimit $autolimit(ver) by David Proper (DrN) -: LoadeD :-"

