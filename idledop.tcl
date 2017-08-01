#         Script : IdleOP v1.03 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2002 Radical Computer Systems
#
#       Testing
#      Platforms : Linux 2.2.16    TCL v8.3
#                  Eggdrop v1.6.6
#            And : SunOS 5.8
#                  Eggdrop v1.5.4  TCL v8.3
#
#    Description : IdleOP will scan the idle times of OPs in channels you
#                  speccify and deOP anyone idle for longer then the set
#                  amount of time. Other bots and +m's are currently
#                  exempt from idle deOP.
#
#        History : 05/13/2001 - First Release
#                  07/10/2001 - v1.01
#                              o Added public command to toggle Idle
#                                checking on/off
#                              o .idleop command no longer uses current
#                                console channel. Will now list all
#                                channels in the $IDLEOP(chans) list.
#                 11/10/2001 - v1.02
#                              o Optional voice when DEop.
#                                R33D33R@UnderNet asked how to do it and I
#                                thought it would be a nice feature.
#                              o Idle-Devoice
#                              o Changed to use pushmode
#                              o Possibly fixed not getting handle on
#                                nicks with {} type charators.
#                                Thanks to {Judge}@UnderNet for pointing it out.
#                 03/29/2002 - v1.03
#                              o Added flag to prevent devoicing users
#                              o Added Idle Warn message
#                              o Fixed channel +m checking
#                              o Added exempt flag.
#                                Feature Requested by: LordDark@Galaxynet
#
# Setup Note: Add your bot to it's own userlist as +b or it will deop itself.
#
#   Future Plans : Unknown. Make a suggestion.
#
# Author Contact :     Email - DProper@stx.rr.com
#                  Home Page - http://home.stx.rr.com/dproper
#                        IRC - Nick: DrN
#                     UseNet - alt.irc.bots.eggdrop
# Linked Support Channels    - #RCS @ UnderNet
#                              #RCS @ DALnet
#                              #RCS @ EFnet (Stability of channel uncertain)
#                              #RCS @ GalaxyNet (Stability of channel uncertain)
#
# Chaotix.Net has returned. web site and mailing list functional.
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
#  Public:   - !idleop
#     MSG:   - N/A
#     DCC:   o idleop    o idleopchk
#
# Public Matching: N/A
#

# [0/1] Set this to 1 if you want the bot to +v users when it deops them.
set IDLEOP(voice) 1

# [0/1] Defualt status for IdleOP checking. 0:off 1:on
set IDLEOP(active) 1

# Set this to the number of minutes you want between each scan.
set IDLEOP(timer) 10

# Set to anything above 0 to warn them of thier idle time.
set IDLEOP(warnidle) 20
set IDLEOP(warnmsg) "You've been idle for !idle! minutes on !channel!."

# This is the time in minutes to DeOP if longer then.
set IDLEOP(maxidle) 30

# This is the time in minutes to DeVoice +v'ed OPs that are idle.
set IDLEOP(maxidlev) 60

# [0/1] Set this to 1 to devoice idle +v users. 0 not to.
set IDLEOP(dodevoice) 1

# Set this to the channels you want scanned.
set IDLEOP(chans) "#isleofview"

# Set this to a flag you want to be exempt from checks.
set IDLEOP(exempt) "E"


set IDLEOP(tag) "\002\[IdleOP\]\002"
set IDLEOP(ver) "v1.03.02"


set cmdchar_ "!"
proc cmdchar { } {
global cmdchar_
 return $cmdchar_
}


bind dcc o idleopchk dcc_idleopchk
proc dcc_idleopchk {handle idx args} {
global IDLEOP
 set chan [string tolower [lindex [console $idx] 0]]
 putidx $idx "$IDLEOP(tag) Checking OP Idle times for $chan"
 idleopchk $chan $idx
                                  }

proc check_idleop {} {
global IDLEOP
 timer $IDLEOP(timer) check_idleop
 if {$IDLEOP(active) == 0} {putlog "IdleOP Checking is Deactivated. Skipping Check."
                            return 0}
 foreach c [string tolower [channels]] {idleopchk $c 0}
                     }
 timer $IDLEOP(timer) check_idleop

proc idleopchk {chan idx} {
global IDLEOP
 set dochan 999
 foreach c [string tolower $IDLEOP(chans)] {
 if {$c == $chan} {set dochan 1}
                                              }
 if {$dochan != 1} {return 0}

 foreach user1 [chanlist $chan] {
  subst -nobackslashes -nocommands -novariables user1
  set ex 999
  set hand [nick2hand $user1 $chan]
  if {([matchattr $hand m] == 1) ||
      ([matchchanattr $hand |m $chan] == 1) ||
      ([matchattr $hand b] == 1)} {set ex 1}
  if {([matchattr $hand $IDLEOP(exempt) == 1) ||
      ([matchchanattr $hand |$IDLEOP(exempt) $chan) == 1) {set ex 1}

 if {($ex != 1) && ([isvoice $user1 $chan])} { 
 set idletime [getchanidle $user1 $chan]
 if {(($IDLEOP(dodevoice)) && ($idletime > $IDLEOP(maxidlev)))} {
  if {($idx > 0)} {putidx $idx "User $user1 idle for $idletime minutes. DeVoiceing."
                } else {putlog "User $user1 idle for $idletime minutes. DeVoiceing."}
  putserv "NOTICE $user1 :You have been idle over $idletime minutes. Forced DeVoice."
#  putserv "MODE $chan -v $user1"
  pushmode $chan -v $user1

                                       }
                                              }

 if {($ex != 1) && ([isop $user1 $chan])} {
 set idletime [getchanidle $user1 $chan]
 if {($idletime > $IDLEOP(warnidle))} {
  set idlemsg $IDLEOP(idlemsg)
  regsub -all {!idle!} $idlemsg "$idletime" idlemsg
  regsub -all {!channel!} $idlemsg "$chan" idlemsg
  putserv "NOTICE $user1 :$idlemsg"
                                      } 
 if {($idletime > $IDLEOP(maxidle))} {
  if {($idx > 0)} {putidx $idx "User $user1 idle for $idletime minutes. DeOPing."
                } else {putlog "User $user1 idle for $idletime minutes. DeOPing."}
  putserv "NOTICE $user1 :You have been idle over $idletime minutes. Forced DeOP."
#  putserv "MODE $chan -o $user1"
  pushmode $chan -o $user1

  if {($IDLEOP(voice) == 1) && (![isvoice $user1 $chan])} {
#                      putserv "MODE $chan +v $user1"
                       pushmode $chan +v $user1
                                                          }
                       }
                                         }
                                 }
}


bind dcc o idleop dcc_idleop
proc dcc_idleop {handle idx args} {
global IDLEOP

# set chan [string tolower [lindex [console $idx] 0]]
foreach c $IDLEOP(chans) {
 listidleops $c $idx
                         }
}

proc listidleops {chan idx} {
global IDLEOP
 putidx $idx "$IDLEOP(tag) Listing Idle times for $chan"
 set exnum 0
 foreach user1 [chanlist $chan] {
  set hand [nick2hand $user1 $chan]
  set ex " "
 if {([matchattr $hand m] == 1) ||
     ([matchchanattr $hand m $chan] == 1) ||
     ([matchattr $hand b] == 1)} {set ex "E"
                                  set exnum [expr $exnum + 1]}
  if {$ex != " "} {set ex " \($ex\) "}
  if {([isop $user1 $chan]) || ([isvoice $user1 $chan])} {
  
   putdcc $idx "$IDLEOP(tag)  User $user1${ex}has been idle [getchanidle $user1 $chan] mins."
                              }
                                }
  if {$exnum > 0} {putidx $idx "$IDLEOP(tag) NOTE: Users marked with a (E) after thier nick are exempted from idle-deop"}
}


bind pub o [cmdchar]idleop pub_idleop
proc pub_idleop {nick uhost hand channel rest} {
global IDLEOP
switch [string tolower [lindex $rest 0]] {
 ""    { putserv "NOTICE $nick :Syntax: [cmdchar]idleop \[on/off\]" }
 "off" { set IDLEOP(active) 0 }
 "on"  { set IDLEOP(active) 1 }
 }
if {$IDLEOP(active) == 0} { putserv "NOTICE $nick :IdleOP Checking if currentlly off"
                   } else { putserv "NOTICE $nick :IdleOP Checking is currentlly on" }
 }


putlog "IdleOP $IDLEOP(ver) by David Proper (DrN) -: LoadeD :-"
return "IdleOP $IDLEOP(ver) by David Proper (DrN) -: LoadeD :-"

