#badchan 1.0 by Bass of Undernet's #eggdrop (bass@tclslave.net)
#
#This is a basic 'badchan' script to auto-ban ppl who are on other chans deemed 'bad'
#People are scanned on-join.
#
#Public commands:
#!gbclist			--lists the contents of the Global BadChan list
#!bclist			--lists the contents of the BadChan list for the current channel
#!gabc <mask> <reason>	--adds an item to the Global BadChan list
#!grbc <mask>		--removes an item from the Global BadChan list
#!abc <mask> <reason>	--adds an item to the BadChan list for the current channel
#!rbc <mask>		--removes an item from the BadChan list for the current channel
#
#eg:  !abc *sex* No sex chans!
#
#Users need n|- to change the global settings.
#Users need o|o to change the channel settings.
#
#The script keeps a copy of the list in a file so that it can be reloaded
#   the next time the bot is restarted.

if {[info exists bchan]} {unset bchan}

#minutes to wait before rescanning (so a join-part flood won't hurt) 
set bchan(rescan) 3 	

#same as other flood-prot setting.
set bc_flood 3:10

#'ignored' channels.  no scanning is done.
set bchan(exempt) "#ShakE"

#protected masks:
set bchan(protect-hosts) {
 ShakE!*@*
}

### END OF CONFIG OPTIONS ###

if {[info exists bcqueue]} {unset bcqueue}
set bchan(chans) ""
proc bmaskhost {uhost} {
  set uhost [lindex [split $uhost !] [expr [llength [split $uhost !]] -1]]
  set temp [string range [lindex [split $uhost @] 0] [expr [string length [lindex [split $uhost @] 0]] - 8] e]
  return "*!*$temp@[lindex [split [maskhost *!*@[lindex [split $uhost @] 1]] @] 1]"
}

proc bchan_read {} {
  global bchan
  set fd [open scripts/badchan.conf r]
  while {![eof $fd]} {
    set inp [gets $fd]
    if {[string trim $inp " "] == ""} {continue}
    set ban [lrange $inp 1 e]
    set chan [string tolower [lindex $inp 0]]
    if {[lsearch $bchan(chans) $chan] == -1} {lappend bchan(chans) $chan}
    lappend bchan($chan) $ban
  }
  close $fd
  putlog "badchan.conf loaded."
}
putlog "Bass's badchan.tcl 1.0 loaded"
if {[file exists scripts/badchan.conf]} {bchan_read} {putlog "badchan.conf not found!"}

proc bc_flood_init {} {
  global bc_flood bc_flood_num bc_flood_time bc_flood_array
  if {![string match *:* $bc_flood]} {putlog bchan: var bc_flood not set correctly. ; return 1}
  set bc_flood_num [lindex [split $bc_flood :] 0]
  set bc_flood_time [lindex [split $bc_flood :] 1]
  set i [expr $bc_flood_num - 1]
  while {$i >= 0} {
    set bc_flood_array($i) 0
    incr i -1
  }
} ; bc_flood_init

proc bc_flood {nick uhost} {
  global bc_flood_num bc_flood_time bc_flood_array
  if {$bc_flood_num == 0} {return 0}
  set i [expr $bc_flood_num - 1]
  while {$i >= 1} {
    set bc_flood_array($i) $bc_flood_array([expr $i - 1])
    incr i -1
  }
  set bc_flood_array(0) [unixtime]
  if {[expr [unixtime] - $bc_flood_array([expr $bc_flood_num - 1])] <= $bc_flood_time} {
    putlog "bchan: Flood detected from $nick."
    #newignore [join [maskhost *!*[string trimleft $uhost ~]]] bchan flood 2
    return  1
  } {return 0}
}


bind join -|- * bchan_join

proc bchan_join {nick uhost hand chan} {
 global bchan bcqueue bcnicks botnick
 if {[matchattr [nick2hand $nick $chan] bmnof|mnof $chan]} {return 0}
 set host [string tolower [lindex [split $uhost @] 1]]
 set chan [string tolower $chan]
 set nick [string tolower $nick]
 if {[lsearch $bchan(chans) $chan] == -1 && ([lsearch $bchan(chans) global] == -1 || [lsearch $bchan(exempt) $chan] > -1)} {return 0}
 if {[string tolower $botnick] == [string tolower $nick]} {return 0}
 if {![botisop $chan]} {return 0}
 if {$bchan(protect-hosts) != ""} {
  foreach i $bchan(protect-hosts) {
   if {[string match [string tolower $i] $host]} {return 0}
  }
 }
 if {[info exists bcqueue($host)]} {return 0}
 set bcqueue($host) 1 
 if {[bc_flood $nick $uhost]} {return 0}
 set bcnicks($nick) $chan
 putserv "whois $nick" 
 set i 0 
 set temp ""
 while {$i < [string length $nick]} {
   if {[string index $nick $i] == "\\"} {append temp "\\\\"} elseif {
   [string index $nick $i] == "\["} {append temp "\\\["} elseif {
   [string index $nick $i] == "\]"} {append temp "\\\]"} elseif {
   [string index $nick $i] == "\{"} {append temp "\\\{"} elseif {
   [string index $nick $i] == "\}"} {append temp "\\\}"} {
   append temp [string index $nick $i]}
   incr i
 } ; set nick $temp
 timer $bchan(rescan) "unset bcqueue($host) ; unset bcnicks($nick)"
}

bind raw - 319 bc_whois
proc bc_whois {from key args} {
  global bchan bcqueue bcnicks
#  putlog "319: $args"
  set args [join $args]
  set nick [string tolower [lindex $args 1]]
  if {[info exists bcnicks($nick)]} {set chan $bcnicks($nick)} {return 0}
  set chans [string tolower [lrange $args 2 e]]
  if {[lsearch $bchan(exempt) $chan] == -1 && $bchan(global) != ""} {set bans $bchan(global)} {set bans ""}
  if {[lsearch $bchan(chans) $chan] > -1} {set bans "$bans $bchan($chan)"}
  foreach tok $chans {
    set tok [string trimleft $tok ":@+"]
    foreach ban $bans {
      if {[string match [lindex $ban 0] $tok]} {
        putlog "badchan:  match! $nick k/b'd from $chan because [lrange $ban 1 e]"
        putlog "args: $args, ban: $ban"
        if {[onchan $nick $chan]} {newchanban $chan [bmaskhost [getchanhost $nick $chan]] badchan "[lrange $ban 1 e]" 10}
        return 0
      }
    }
  }
  return 0
}
bind pub n|- !gbclist bc_glist
proc bc_glist {1 2 3 4 5} {bc_list $1 $2 $3 global $5}
bind pub o|o !bclist bc_list
proc bc_list {nick uhost hand chan args} {
  global bchan
  set chan [string tolower $chan]
  if {[lsearch $bchan(chans) $chan] == -1} {puthelp "notice $nick :No badchans are registered for $chan." ; return 1}
  set i 1
  puthelp "notice $nick :BadChans for $chan..."
  foreach ban $bchan($chan) {
    puthelp "notice $nick :$i) $ban"
    incr i
  }
}
bind pub n|- !gabc bc_gadd
proc bc_gadd {1 2 3 4 5} {bc_add $1 $2 $3 global $5}
bind pub o|o !abc bc_add
proc bc_add {nick uhost hand chan args} {
  global bchan
  set chan [string tolower $chan]
  if {![string match *\\\** [lindex $args 0]]} {puthelp "notice $nick :syntax is: !abc <chanmask> \[reason\]" ; return 1}
  set args [string trimright "[string tolower [lindex $args 0]] [lrange $args 1 e]" " "]
  if {[lsearch $bchan(chans) $chan]} {lappend bchan(chans) $chan}
  lappend bchan($chan) $args
  puthelp "notice $nick :[lindex $args 0] was added to $chan's badchan list."
  bchan_save
  return 1
}
bind pub n|- !grbc bc_grem
proc bc_grem {1 2 3 4 5} {bc_rem $1 $2 $3 global $5}
bind pub o|o !rbc bc_rem
proc bc_rem {nick uhost hand chan args} {
  global bchan
  set chan [string tolower $chan]
  set args [string tolower [lindex [join $args] 0]]
  if {[lsearch $bchan(chans) $chan] == -1} {puthelp "notice $nick :No badchans are registered for $chan." ; return 1}
  if {![string match *\\\** $args]} {puthelp "notice $nick :syntax is: !rbc <chanmask>" ; return 1}
  set i 0
  set temp ""
  foreach ban $bchan($chan) {
    if {[string compare $args [lindex $ban 0]] == 0} {incr i} {lappend temp $ban}
  }
  if {$i > 0} {
    if {$temp != ""} {set bchan($chan) $temp} {
      unset bchan($chan)
      set temp [lsearch $bchan(chans) $chan]
      if {$temp == -1} {putlog "bchan: I'm confused." ; return 1}
      set bchan(chans) [lreplace $bchan(chans) $temp $temp]
    }
    puthelp "notice $nick :$args was removed from $chan's badchan list."
    bchan_save
  } {puthelp "notice $nick :$args was not found in $chan's badchan list."}
  return 1
}
proc bchan_save {} {
  global bchan
  set fd [open scripts/badchan.conf w]
  foreach chan $bchan(chans) {
    foreach ban $bchan($chan) {
      puts $fd "$chan $ban"
    }
  }
  close $fd
}