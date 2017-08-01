##########################################################################
# SpamChecker v2.0 by ShakE <shake@vip.bg>		                 #
##########################################################################
# Tova e tcl koito pravi va6ia eggdrop spam checker. Bota 6te rejoinva v #
# vseki kanal v koito e. Za da se sloji ban...checker-a trqbva da e link #
# s ostanalite botove v kanala i botovete trqbva da imat slojen 	 #
# SpamKicker.tcl ,koito varvi kato paket s tozi tcl.			 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################

########## Nastroiki ###########

#flaga na userite koito bota nqma da priema za inviters
set uflag "o"

#prez kolko vreme bota da rejoinva kanalite (v minuti)
set cycle_time "15"

#vtoria nick na checker-a
set chnick "vtori-nick-na-spamchecker"

#slojete 1 ako iskate bota da otgovarq na "hi"
set hianswer 0

## Ottuk nadolu ne butai ni6to!!! ##
#########################################################################################

bind raw -|- PRIVMSG kb_i
bind raw -|- NOTICE kb_i

proc kb_i {from key args} {
 global hianswer
 scan $from "%\[^!]@%s" unick uhost
 set handle [finduser $from]
 set in_active [lindex $args 0]
 set actv [lindex $in_active 0]
 if {[validchan $actv] == 0} {
  if {($unick == "Global") || ($unick == "CS") || ($unick == "NS")} { return 0 }
  if {[string match *#* $args]} { 
   kb_spammer $unick $handle $from
   return 0
  }
  if {[string match *w*w*w*.* $args]} { 
   kb_spammer $unick $handle $from 
   return 0
  }
  if {[string match *h*t*t*p*:*/*/* $args]} { 
   kb_spammer $unick $handle $from 
   return 0
  }
  if {[string match *W*w*W* $args]} { 
   kb_spammer $unick $handle $from 
   return 0
  }
  if {[string match *DCC* $args]} { 
   kb_spammer $unick $handle $from 
   return 0
  }
  if {[string match *hi* $args]} { 
   if {$hianswer == 1} {
    putserv "privmsg $unick :i'm just a spamchecker!" 
    return 0
   }
  }
 }
 if {[validchan $actv] == 1} {
  if {[string match *www.* $args]} { 
   kb_spammer $unick $handle $from 
   return 0
  }
  if {[string match *http://* $args]} { 
   kb_spammer $unick $handle $from 
   return 0
  }
 }
}

proc kb_spammer {unick handle uhost} {
   global uflag invbanhost
   if {[matchattr $handle $uflag] || [matchattr $handle b]} {
    putlog "Invite Detected from a user: $unick"
    return 0
   }
   putlog "SpaMeR DeTeCteD: $unick ($uhost)"
   putallbots "kb $unick $uhost"
   return 1
}
if {![string match "*cyclechans*" [timers]]} { timer $cycle_time cyclechans }
proc cyclechans {} {
 global cycle_time chnick
 putlog "Checker: Rejoining channels..."
 putserv "NICK $chnick"
 foreach chan [channels] {
  channel set $chan +inactive
  channel set $chan -inactive
 }
 if {![string match "*cyclechans*" [timers]]} { timer $cycle_time cyclechans }
}

putlog "SpamChecker.tcl by ShakE loaded!"
putlog "Get more tcl's from http://shake.hit.bg"