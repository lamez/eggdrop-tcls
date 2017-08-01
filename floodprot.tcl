##########################################################################
# floodlock.tcl v1.0 by ShakE <shake@vip.bg>			 	 #
##########################################################################
# Dosta dobyr tcl za protect na golemi kanali ot cloneflooders. 	 #
# Za tozi tcl moje da blagodarite na vsi4ki koito me karaha da go napisha#
# Mislq 4e dosta hora go tyrsqt. Po deistvie tozi tcl napodobqva tcl-a   #
# sentinel.tcl koito se izpolzva za dosta kanali, no ne e mnogo dobyr i  #
# spira samo text flood, a sega pove4eto flooders floodqt s notice. 	 #
# Drugoto koeto e 4e toi zaklu4va kanala s modes (+im) za "moderated" e  #
# dobre, no +i (invite only) spira i vsi4ki normalni posetiteli da vlizat#
# v kanala. Zatova az sam go napravil da slaga (+qm) koeto pozvolqva na  #
# vsichki koito sa identnati v NS da vlizat v kanala. 			 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################

########## Nastroiki ###########

#Za kolko minuti da se zaklu4i kanala
set locktime 10

#Kolko notice's za kolko sekundi [broi:sekundi]
set ntflood 3:10

## Ottuk nadolu ne butai ni6to!!! ##
#########################################################################################

bind notc - * checkflood
proc checkflood {nick uhost hand text chan} {
 global botnick locktime ntflood
 if {([string match *#* $chan]) || (![matchattr $hand o]) || (![matchattr $hand b])} { 
  if {![info exists ntcount($chan:$text)]} {
    set ntcount($chan:$text) 0
  }
  incr ntcount($chan:$text)
  if {$ntcount($chan:$text) == [lindex $ntflood 0]} {
   if {[botisop $chan] && [onchan $nick $chan]} {
    putserv "MODE $chan +mq"
    putserv "KICK $chan $nick :Flooderz Out!"
   }
   set bmask *!*[string tolower [string range $uhost [string first "@" $uhost] end]]
   newchanban $chan $bmask NoticeFlood "Flooderz Out!" $locktime
   timer $locktime unlockchan($chan)
   return 0
  }
 }
}
proc unlockchan {chan} {
 putserv "MODE $chan -qm"
 putlog "UnLocked $chan"
}
putlog "floodlock.tcl by ShakE loaded!"
putlog "Get more tcl's from http://shake.hit.bg"