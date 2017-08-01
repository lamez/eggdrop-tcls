#         Script : TheHelper v1.00 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2002 Radical Computer Systems
#                             All Rights Reserved
#
#       Testing
#      Platforms : Linux 2.2.16   TCL v8.3
#                  Eggdrop v1.6.2
#            And : SunOS 5.8      TCL v8.3
#                  Eggdrop v1.5.4
#
#    Description : TheHelper is a simple TCL for doing quick and easy FAQ
#                  type help files for a channel. Ideal for help channels
#                  or anyone sick of answering the same shit over and over
#                  again. :)
#
#          Setup : The FAQ files comes in a data file that must be compiled.
#                  The compiler is mkhelper.
#                  The format of the datafile is as follows:
#                  Lines starting with a - is added to the main index
#                  Lines starting with a ? begin a question
#                  Lines starting with a space are added to the question file
# Example:
# -This is an example help file
# ?Question 1
#  This would be the answer to question 1
# ?Question 2
#  This would be the answer to question 2
#
#        History : Version history is now an external file. See thehelper.hst
#
#
#   Future Plans : Fix Bugs. :)
#
# Author Contact :     Email - DProper@stx.rr.com
#                  Home Page - http://home.stx.rr.com/dproper
#                        IRC - Primary Nick: DrN
#                     UseNet - alt.irc.bots.eggdrop
# Support Channels: #RCS @UnderNet.Org
#                   #RCS @DALnet
#                   #RCS @EFnet (Not sure if this will be perm or not)
#                   #RCS @GalaxyNet (Not sure if this will be perm or not)
#
# New TCL releases are sent to the following sites as soon as they're released:
#
# FTP Site                   | Directory                     
# ---------------------------+-------------------------------
# ftp.chaotix.net            | /pub/RCS                      
# ftp.eggheads.org           | Various                       
# http://www.botcentral.net  | Various                       
# drn.realmweb.org           | /drn                          
#
# Chaotix.Net has returned. Web site and mailing list running.
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
#  Public:   - helper
#     MSG:   - helper
#     DCC:   - helper
#
# Public Matching: N/A
#

set cmdchar_ "!"
set helperver "v1.00.01"

set helperfiles {
 {pirch /home/eggdrop/help/pirch/   Questions about the Pirch IRC client}
 {irc   /home/eggdrop/help/irchelp/ General Questions about IRC}
}
die "You need to edit thehelper.tcl and compile the help files."

proc cmdchar { } {
global cmdchar_
return $cmdchar_
}

bind pub - [cmdchar]helper pub_helper
proc pub_helper {nick uhost hand chan rest} {
start_helper $hand $nick $chan 3 $rest
}

bind msg - helper msg_helper
proc msg_helper {nick uhost hand rest} {
 start_helper $hand $nick $nick 2 $rest
}


bind dcc - helper dcc_helper
proc dcc_helper {hand idx rest} {
 set channel [lindex [console $idx] 0]
 putidx $idx "Set $channel as your defualt channel"
 start_helper $hand $idx $channel 4 $rest
}

proc start_helper {hand nick chan dirc rest} {
global helperfiles
 set topic [lindex $rest 0]
 set rest [lrange $rest 1 end]
 if {$topic == ""} {
                   helper_sendit $nick $chan $dirc "Calling Syntax: [cmdchar]helper topic \[question#\]"

                   helper_sendit $nick $chan $dirc "To list avaliable topics:  [cmdchar]helper list"
                   return 0}
 if {[string tolower $topic] == "list"} {
   helper.list $nick $chan $dirc
   return 0}
 set usehelpfile [helper.getpath $topic]
 if {$usehelpfile == ""} {
                   helper_sendit $nick $chan $dirc "I can't find any topic called $topic."
                   helper_sendit $nick $chan $dirc "To list avaliable topics:  [cmdchar]helper list"
                   return 0}
 do_thehelper $dirc $nick $hand $chan "$usehelpfile" "$rest"
}

proc helper.list {nick chan dirc} {
global helperfiles
 set totalhelp [llength $helperfiles]
 set helploop 0
 helper_sendit $nick $chan $dirc "\26Name           \26 \26Description                \26"
 helper_sendit $nick $chan $dirc "--------------- -------------------------------"
  while {$helploop < $totalhelp} {
  set dl_data [lindex $helperfiles $helploop]
  set dl_trig [lindex $dl_data 0]
  set dl_path [lindex $dl_data 1]
  set dl_desc [lrange $dl_data 2 end]
  helper_sendit $nick $chan $dirc "[format "%-15s" $dl_trig] $dl_desc"
  incr helploop
                                  }
  helper_sendit $nick $chan $dirc "\26 * \26 EX: [cmdchar]helper name"
}

proc do_thehelper {dirc nick hand chan path rest} {
global helperver
set quey [lindex $rest 0]
set toey [lindex $rest 1]
set howsend "NOTICE"

if {([string index $quey 0] == "#")} {set quey [string range $quey 1 [string length $quey]]}

set gotaccess 0
if {($nick != $chan) && ([matchchanattr $hand |o $chan])} {set gotaccess 1}
if {([matchattr $hand o])} {set gotaccess 1}

if {($gotaccess) && ($toey != "")} {
      if {($toey == "#")} {
                           set toey $chan
                           helper_sendit $nick $chan $dirc "Sending Question $quey to $toey"
                           set dirc 1
                            } {
  helper_sendit $nick $chan $dirc "Sending Question $quey to $toey"
  set nick $toey
  set dirc 3
                              }
                                            }

if {$rest != ""} {set helpfile "${path}$quey"
                 } {set helpfile "${path}index"
                   }
helper_sendit $nick $chan $dirc "The Helper $helperver by DrN"
if {![file exists $helpfile]} {helper_sendit $nick $chan $dirc "Sorry, can't find the answer to that."; return 0}

if {[catch {set fd [open $helpfile r]}] == 0} {
                                               while {![eof $fd]} {
                                                  set inp [gets $fd]
                                                  helper_sendit $nick $chan $dirc "$inp"
                                                                  }
                                               close $fd
                                               helper_sendit $nick $chan $dirc "--- \002end\002"
                                              }
 }

###########################################################################
proc helper.getpath {topic} {
 global helperfiles
 set totalhelp [llength $helperfiles]
 set helperloop 0
 set usehelpfile [lindex [lindex $helperfiles 0] 1]
 set usehelpfile ""
 while {$helperloop < $totalhelp} {
  set dl_data [lindex $helperfiles $helperloop]
  set dl_trig [lindex $dl_data 0]
  set dl_path [lindex $dl_data 1]
  set dl_desc [lrange $dl_data 2 end]
  if {($topic == [string tolower $dl_trig])} {set usehelpfile $dl_path}
  incr helperloop
                               }
 return $usehelpfile
}

proc helper_sendit {nick channel dirc txt} {
 if {$dirc == "1"} { puthelp "PRIVMSG $channel :$txt" }
 if {$dirc == "2"} { puthelp "PRIVMSG $nick :$txt" }
 if {$dirc == "3"} { putnotc $nick "$txt" }
 if {$dirc == "4"} { putdcc $nick "$txt" }
}


putlog "TheHelper $helperver by David Proper (DrN) -: LoadeD :-"
return "TheHelper $helperver by David Proper (DrN) -: LoadeD :-"

