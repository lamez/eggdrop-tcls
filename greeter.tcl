#         Script : Greeter v1.01 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2001 Radical Computer Systems
#                             All Rights Reserved
#
#       Testing
#      Platforms : Linux 2.2.16   TCL v8.3
#                  Eggdrop v1.6.2
#            And : SunOS 5.8      TCL v8.3
#                  Eggdrop v1.5.4
#
#    Description : Greeter gives your bot an auto-greet with a twist.
#                  Using probabilities for different things, it modifies
#                  the way it greets, and if it greets at all.
#                  Can also be set to only greet on certain channels.
#
#        History : 08/08/2001 - First Release
#                  12/28/2001 - v1.01
#                              o Fixed missing $ on variable error.
#                              o Was checking the existence of publics 
#                                wrong. Fixed.
#                              o Method for sending greeting is now
#                                definable.
#
#
#   Future Plans : Fix Bugs. :)
#
# Author Contact :     Email - DProper@stx.rr.com
#                  Home Page - http://home.stx.rr.com/dproper
#                        IRC - Nick: DrN  UnderNet/DALnet
#          Support Channels  - #RCS @ UnderNet
#                              #RCS @ DALnet
#
# Chaotix.Net is currentlly offline. Should return no later then Jan 1st, 2002
#
#   Radical Computer Systems - http://www.chaotix.net/rcs/
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

#\
# |##### NOTE: Anything on the Chaotix.Net domain is currently offline
#/

# Publics is for another script of mine that allows you to turn off
# channel stuff like this. It's also wired into my Channel Gaurdian script
# so stuff like this are turned off during flood attacks.
if {![info exists publics]} {set publics 1}

# This is the percentage chance they will get greeted at all.
set greet(greetprob) 80
# This is the percentage chance to Strip non-alpha chars
set greet(snaprob) 75
# This is the percentage chance to change nick to lowercase
set greet(nlowprob) 40
# This is the percentage chance to change greeting to lowercase
set greet(mlowprob) 35
# This is the percentage chance to add an ending (if greeting don't end in a ?)
set greet(end1prob) 60
# This is the percentage chance to add ending 2 (smily faces by defualt)
set greet(end2prob) 40

#[1/2/3] How do you want the greetinging sent.
# 1 : public   2 : msg  3 : notice
# When using method 2 or 3, Ya might wanna always include the channel name.
# If ya don't, you'll get even MORE people trying to chat with your bot. :)
set greet(notification) 1

# Define this as the channels you want to greet. * for all
set greet(chans) "#love #isleofview #Spank&Tickle #30+flirts #flirting_cafe"


# This is the main greeting lines. Variables here are $nick for the nick
# of the user being greeted and $chan for the current channel.
set greet(lines) {
 {Hiya $nick}
 {Howdy $nick}
 {Hey $nick}
 {What's up $nick?}
 {'Ello $nick}
 {Hiyaz $nick}
 {Hi $nick}
 {HiHi $nick}
 {Hallo $nick}
 {Hello there $nick}
 {Greetings $nick}
 {G'day $nick}
 {$nick}
 {WuzUp $nick}
 {It's the $nickster}
 {Wow! It's $nick}
 {Look! $nick is here}
}

# This is the first set of random endings.
set greet(endings1) {{!}  {.}  {!!}  {!!1} {!1!1!}}

# This is the set of second random endings.
set greet(endings2) {{ :)}  { :)}  { :o)} { :o)} { :-)} { :^)} { 8-)}}

set greet(ver) "v1.01.01"

bind join - ***** greet_join
proc greet_join {nick uhost hand chan} {
global botnick publics
if {$publics == 0} {return 0}

if {$botnick == $nick} {return 1}
if {![greetchan $chan]} {return 1}

utimer [expr [rand 15] + 5] "greet_do $nick $chan"
return 1
}

proc greet_do {nick chan} {
 global greet
 set gnick $nick
 set anick ""
 set gloop 0;
 while {$gloop < [string length $nick]} {
  if {[string match "*[string index $nick $gloop]*" "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"]} {set anick "$anick[string index $nick $gloop]"}
  incr gloop 1
                                        }
 if {[string length $anick] < 3} {set anick $nick}
# putlog "greet_do $nick $chan anick:$anick gnick:$gnick"
 if {![onchan $nick $chan]} {return 1}
 if {![probability $greet(greetprob)]} {return 1}
 if {![probability $greet(snaprob)]} {set gnick $anick}
 if {![probability $greet(nlowprob)]} {set gnick [string tolower $gnick]}

 set outmsg [randomline $greet(lines)]
 if {[probability $greet(mlowprob)]} {set outmsg [string tolower $outmsg]}
 if {([probability $greet(end1prob)]) && ([string index $outmsg [expr [string length $outmsg] - 1]] != "?")} {append outmsg [randomline $greet(endings1)]}
 if {[probability $greet(end2prob)]} {append outmsg [randomline $greet(endings2)]}
 regsub -all {\$nick} $outmsg $gnick outmsg
 regsub -all {\$chan} $outmsg $chan outmsg
 regsub -all {\\001} $outmsg \001 outmsg
 regsub -all {\\002} $outmsg \002 outmsg
 switch $greet(notification) {
  1 {putserv "PRIVMSG $chan :$outmsg"}
  2 {putserv "PRIVMSG $nick :$outmsg"}
  3 {putserv "NOTICE $nick :$outmsg"}
                             }
}

proc randomline {text} {
 return [lindex $text [rand [llength $text]]]
}

proc greetchan {chan} {
 global greet
 set chan [string tolower $chan]
 set chans [string tolower $greet(chans)]
 if {$chan == "*"} {set chans [string tolower [channels]]}
 set dothechan 0
 foreach c $chans {
  if {($chan == $c)} {set dothechan 1}
                  }
 if {$dothechan == 0} {return 0} else {return 1}
}


proc probability {prob} {
 if {$prob == 100} {return 1}
 set r [rand 100]
 set rng [rand [expr 100 - $prob]]
 set rngu [expr $rng + $prob]
# putlog "prob:$prob r:$r range: $rng - $rngu"
 if {($r > $rng) && ($r < $rngu)} {return 1}
 return 0
}

putlog "Greeter $greet(ver) by David Proper (DrN) -: LoadeD :-"
return "Greeter $greet(ver) by David Proper (DrN) -: LoadeD :-"

