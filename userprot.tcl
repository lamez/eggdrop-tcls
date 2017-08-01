##########################################################################
# userprot.tcl by ShakE <shake@abv.bg>		                         #
##########################################################################
# Tova e vsa6tnost e mnogo podobrena versia na protsys.tcl			 #
# Poneje protsys.tcl ima dosta bugove i nedostataci az sam opravil vsi4ko#
# Sega userprot.tcl e edna ot nai-sigurnite za6titi za va6ite useri	 #
# Durja da kaja za sazdatelq na protsys.tcl: DuRanDaL <sgb@ismennt.is>   #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################


##################### Informations ##########################
#                                                           #
# Note: '+f' userite se kickvat (i banvat ako e setnato)    #
#       za deop,kick ili ban na protected useri. Ako iskate #
#       da smenite tova prosto set exception flag na +f     #
#       taka bota nqma da reagira pri deop,kick 		#
#	  i ban na protuser (ne vi go preporu4vam)		#
#                                                           #
# Note: Botovete (+b) i masterite (+m|+m) ne se sledqt za   #
#       deop, kick ili ban na protected user.		      #
#       Ako ne vi haresva 4e botovete ne se sledqt za       #
#       tezi deistviq, to togava vie naistina iskate 		#
#       voina na botovete. Zatova ne vi preporu4vam da 	#
#	  smenqte tova. (ne pitaite za6to)			      #
#                                                           #
# Note: Tozi tcl ne pazi masteri i owneri ako te nqmat      #
#       flag '+P' (ne '+p'). Ne preporu4vam da slagate tozi #
#       flag na normalni useri ili master/owner useri +P    #
#       predi da im slojite exception flag (+E)             #
#       No ako iskate bota prosto da za6titava vsi4ki 	#
#       masteri i owneri prosto setnete protection flag-a 	#
#       na "n" ili "m" (ne 'N' ili "M") 				#
#                                                           #
# Note: A ima i o6te ne6to			                  #
#       Az (ShakE) ne poemam nikakva otgovornost za TCL-a   #
#       ako bota kick/ban/deop opovete v va6ia kanal        #
#       Prosto si napravete nastroikite!                    #
#                                                           #
#       Sega go nastroite kakto iskate		            #
#                                                           #
######################## End info ###########################

######################## PROTECT SYSTEM SETTINGS ##################
#                                                                 #
# Flaga koito iskate da izpolzvate za protected users? 		#
set protflag "P";                                                 #
#                                                                 #
# Kolko dalgo da e ban-a za deop na protected user? ("0" = Off)   #
set deoptime "15";                                                #
#                                                                 #
# Kolko dalgo da e ban-a za kick na protected user? ("0" = Off)   #
set kicktime "20";                                                #
#                                                                 #
# Kolko dalgo da e ban-a za ban na protected user? ("0" = Off)    #
set banstime "60";                                                #
#                                                                 #
# Flag-a na oponentite na protusers osven m|m i botovete ?		#
set exceflag "E";                                                 #
#                                                                 #
# Da se obadi li na usera kak da si varne pravata v bota(0/1) ?	#
set msgeuser "1";                                                 #
#                                                                 #
# Ako iskate da logvate vsi4ko koeto userprot pravi               #
# prosto mahnete "#" ot dolnata linia. (jelatelno)                #
#                                                                 #
logfile 7 * "/protsys.log";                          			#
#                                                                 #
######################### END OF SYSTEM SETTINGS ##################

######### BINDS ##############
bind mode - *-o* protsys:deop
bind kick - * protsys:kick
bind mode - *+b* protsys:ban
bind chon - * protsys:console
######### BINDS ##############

### Set prot sys console #####
proc protsys:console { hand idx } {
	set chan [lindex [console $idx] 0]
	if {[matchattr $hand m|m]} { console $idx +1 }
	return 0
}
#### End of set console ######

######### Prot deop ##########
proc protsys:deop {nick host hand chan mdechg dnick} {
global botnick protflag exceflag deoptime msgeuser
if {([matchattr $hand m|m $chan]) || ([matchattr $hand $exceflag|$exceflag]) || ([matchattr $hand b])} {return 0}
if {[string tolower $nick] == [string tolower $botnick]} {return 0}
if {[string tolower $dnick] == [string tolower $botnick]} {
  if {[validuser $hand]} {
    if {[matchattr $hand |o $chan]} {
      putserv "PRIVMSG $nick :You have lost your op on $chan for that !!"
      chattr $hand |-ao+d $chan
      if {$msgeuser} {putserv "PRIVMSG $nick :If you want your op back please talk to one of my masters. Masters on channel $chan are now: [chanlist $chan m|m]"}
      if {![string match "$deoptime" "0"]} {
        set banmask "*!*[string trimleft [maskhost $host] *!]"
        set targmask "*!*[string trimleft $banmask *!]"
        newchanban $chan $targmask Protsys "Deoped me !! [ctime [unixtime]] - $deoptime min ban." $deoptime
      }
      putloglev 7 * "Protectison system: $nick!$host !$hand! deoped me on $chan !!"
      return 0
      } else {
      chattr $hand |-ao+d $chan
      if {![string match "$deoptime" "0"]} {
        set banmask "*!*[string trimleft [maskhost $host] *!]"
        set targmask "*!*[string trimleft $banmask *!]"
        newchanban $chan $targmask Protsys "Deoped me !! [ctime [unixtime]] - $deoptime min ban." $deoptime
      }
      putloglev 7 * "Protectison system: $nick!$host !$hand! deoped me on $chan !!"
      return 0
    }
  }
  if {![string match "$deoptime" "0"]} {
    set banmask "*!*[string trimleft [maskhost $host] *!]"
    set targmask "*!*[string trimleft $banmask *!]"
    newchanban $chan $targmask Protsys "Deoped me !! [ctime [unixtime]] - $deoptime min ban." $deoptime
  }
  putloglev 7 * "Protectison system: $nick!$host !$hand! deoped me on $chan !!"
  return 0
}
if {![matchattr [nick2hand $dnick $chan] $protflag|$protflag $chan]} {return 0}
if {[string tolower $dnick] == [string tolower $nick]} {return 0}
if {[botisop $chan]} {
  pushmode $chan -o $nick 
  pushmode $chan +o $dnick
  if {![string match "$deoptime" "0"]} {
    set banmask "*!*[string trimleft [maskhost $host] *!]"
    set targmask "*!*[string trimleft $banmask *!]"
    pushmode $chan +b $targmask
  }
  flushmode $chan
  if {[matchattr $hand |o $chan]} {
    chattr $hand |-ao+d $chan
    putserv "KICK $chan $nick :Do NOT deop $dnick !! - You have lost your op on $chan for that !!"
    if {$msgeuser} {putserv "PRIVMSG $nick :If you want your op back please talk to one of my masters. Masters on channel $chan are now: [chanlist $chan m|m]"}
    } else {
    if {[validuser $hand]} {
      chattr $hand |-ao+d $chan
    }
    putserv "KICK $chan $nick :Do NOT deop $dnick !! - $deoptime min shitlist."
    if {![string match "$deoptime" "0"]} {
      set banmask "*!*[string trimleft [maskhost $host] *!]"
      set targmask "*!*[string trimleft $banmask *!]"
      newchanban $chan $targmask Protsys "Deoped [nick2hand $dnick $chan] [ctime [unixtime]] - $deoptime min ban." $deoptime}
    }
  }
  putloglev 7 * "Protectison system: $nick!$host !$hand! deoped $dnick![getchanhost $dnick $chan] ![nick2hand $dnick $chan]! on channel $chan !!"
  return 0
}
######### End proc deop ####

######### Prot kick ##########
proc protsys:kick {nick host hand chan knick reason} {
  global botnick protflag exceflag kicktime msgeuser
  if {([matchattr $hand m|m $chan]) || ([matchattr $hand $exceflag|$exceflag]) || ([matchattr $hand b])} {return 0}
  if {[string tolower $nick] == [string tolower $botnick]} {return 0}
  if {[string tolower $botnick] == [string tolower $knick]} {
    if {[validuser $hand]} {
      if {[matchattr $hand |o $chan]} {putserv "PRIVMSG $nick :You have lost your op on $chan for that !!"}
      chattr $hand |-ao+d $chan
      if {$msgeuser} {putserv "PRIVMSG $nick :If you want your op back please talk to one of my masters. Masters on channel $chan are now: [chanlist $chan m|m]"}
      if {![string match "$kicktime" "0"]} {
        set banmask "*!*[string trimleft [maskhost $host] *!]"
        set targmask "*!*[string trimleft $banmask *!]"
        newchanban $chan $targmask Protsys "Kicked [nick2hand $knick $chan] [ctime [unixtime]] - $kicktime min ban." $kicktime
      }
      putloglev 7 * "Protectison system: $nick!$host !$hand! kicked me off $chan reason: $reason"
      return 0
      } else {
      chattr $hand |-ao+d $chan
      if {![string match "$kicktime" "0"]} {
        set banmask "*!*[string trimleft [maskhost $host] *!]"
        set targmask "*!*[string trimleft $banmask *!]"
        newchanban $chan $targmask Protsys "Kicked me !! [nick2hand $knick $chan] [ctime [unixtime]] - $kicktime min ban." $kicktime
      }
      putloglev 7 * "Protectison system: $nick!$host !$hand! kicked me off $chan reason: $reason"
      return 0
    }
    if {![string match "$kicktime" "0"]} {
      set banmask "*!*[string trimleft [maskhost $host] *!]"
      set targmask "*!*[string trimleft $banmask *!]"
      newchanban $chan $targmask Protsys "Kicked me !! [ctime [unixtime]] - $kicktime min ban." $kicktime
    }
    putloglev 7 * "Protectison system: $nick!$host !$hand! kicked me off $chan reason: $reason"
    return 0
  }
  if {![matchattr [nick2hand $knick $chan] $protflag|$protflag $chan]} {return 0}
  if {[string tolower $knick] == [string tolower $nick]} {return 0}
  if {[botisop $chan]} {
    pushmode $chan -o $nick
    if {![string match "$kicktime" "0"]} {
      set banmask "*!*[string trimleft [maskhost $host] *!]"
      set targmask "*!*[string trimleft $banmask *!]"
      pushmode $chan +b $targmask
    }
    flushmode $chan
    if {[matchattr $hand |o $chan]} {
      chattr $hand |-ao+d $chan
      putserv "KICK $chan $nick :Do NOT Kick $knick !! - You have lost your op on $chan for that !!"
      if {$msgeuser} {putserv "PRIVMSG $nick :If you want your op back please talk to one of my masters. Masters on channel $chan are now: [chanlist $chan m|m]"}
      } else {
      if {[validuser $hand]} {
        chattr $hand |-ao+d $chan
      }
      putserv "KICK $chan $nick :Do NOT Kick $knick !! - $kicktime min shitlist."
      if {![string match "$kicktime" "0"]} {
        set banmask "*!*[string trimleft [maskhost $host] *!]"
        set targmask "*!*[string trimleft $banmask *!]"
        newchanban $chan $targmask Protsys "Kicked [nick2hand $knick $chan] [ctime [unixtime]] - $kicktime min ban." $kicktime
      }
    }
  }
  putloglev 7 * "Protectison system: $nick!$host !$hand! kicked $knick![getchanhost $knick $chan] ![nick2hand $knick $chan]! off channel $chan reason: $reason"
}
######### End proc kick ####

######### Prot ban ##########
proc protsys:ban {nick host hand chan mdechg ban} {
  global botnick botname protflag  exceflag banstime msgeuser
  if {([matchattr $hand m|m $chan]) || ([matchattr $hand $exceflag|$exceflag]) || ([matchattr $hand b])} {return 0}
  if {[string tolower $nick] == [string tolower $botnick]} {return 0}
  if {[string match "$ban" "$botname"]} {
    pushmode $chan -o $nick
    putserv "MODE $chan -b $ban"
    if {![string match "$banstime" "0"]} {
      set banmask "*!*[string trimleft [maskhost $host] *!]"
      set targmask "*!*[string trimleft $banmask *!]"
      pushmode $chan +b $targmask
    }
    flushmode $chan
    if {[matchattr $hand |o $chan]} {
      chattr $hand |-ao+d $chan
      putserv "KICK $chan $nick :Do NOT ban me !! - You have lost your op on $chan for that !!"
      if {$msgeuser} {putserv "PRIVMSG $nick :If you want your op back please talk to one of my masters. Masters on channel $chan are now: [chanlist $chan m|m]"}
      } else {
      if {[validuser $hand]} {chattr $hand |-ao+d $chan}
      putserv "KICK $chan $nick :Do NOT ban me !! - $banstime min shitlist."
      if {![string match "$banstime" "0"]} {
        set banmask "*!*[string trimleft [maskhost $host] *!]"
        set targmask "*!*[string trimleft $banmask *!]"
        newchanban $chan $targmask Protsys "Banned me [ctime [unixtime]] - $banstime min ban." $banstime
      }
    }
    putloglev 7 * "Protectison system: $nick!$host !$hand! banned me on $chan !!"
  }
  set pnicks [chanlist $chan $protflag|$protflag]
  foreach pnick $pnicks {
    if {[string match "$ban" "$pnick![getchanhost $pnick $chan]"]} {
      pushmode $chan -o $nick
      pushmode $chan -b $ban
      if {![string match "$banstime" "0"]} {
        set banmask "*!*[string trimleft [maskhost $host] *!]"
        set targmask "*!*[string trimleft $banmask *!]"
        pushmode $chan +b $targmask
      }
      flushmode $chan
      if {[matchattr $hand |o $chan]} {
        chattr $hand |-ao+d $chan
        putserv "KICK $chan $nick :Do NOT ban $pnick !! - You have lost your op on $chan for that !!"
        if {$msgeuser} {putserv "PRIVMSG $nick :If you want your op back please talk to one of my masters. Masters on channel $chan are now: [chanlist $chan m|m]"}
        } else {
        if {[validuser $hand]} {chattr $hand |-ao+d $chan}
        putserv "KICK $chan $nick :Do NOT ban $pnick !! - $banstime min shitlist."
        if {![string match "$banstime" "0"]} {
          set banmask "*!*[string trimleft [maskhost $host] *!]"
          set targmask "*!*[string trimleft $banmask *!]"
          newchanban $chan $targmask Protsys "Banned [nick2hand $pnick $chan] [ctime [unixtime]] - $banstime min ban." $banstime
        }
      }
      putloglev 7 * "Protectison system: $nick!$host !$hand! banned $pnick![getchanhost $pnick $chan] ![nick2hand $pnick $chan]!on channel $chan !!"
    }
  }
}
######### End proc ban #####

putlog "\[ShakE\]  userprot.tcl Loaded    \[ShakE\]"
