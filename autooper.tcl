#0per.tcl
#Made by Logruss 
 
# set your Oper name
set opername "ChanChecK"

# set your Oper password
set operpass "glupaviqbot"

set init-server {
putserv "OPER $opername $operpass"
putserv "MODE $botnick +biwk-szl"
}
###############################################################################
proc time_mode {chan} {
 global botnick
 if {![botisop $chan]} {
  putserv "MODE $chan +o $botnick"
 }
}

set rp_bflood 5:10
set rp_breason "Please Stop flooding"
set rp_slength 10
set rp_mtime 10
set rp_btime 10

proc rp_pubmsg {nick uhost hand chan text} {
 global botnick rp_bcount rp_bflood rp_breason rp_btime rp_kcount rp_kflood rp_kreason rp_scount rp_sflood rp_slength rp_sreason
  set uhost [string tolower $uhost]
  set chan [string tolower $chan]
  set text [string tolower $text]
  if {$nick == $botnick} {return 0}
  if {[matchattr $hand f|f $chan]} {return 0}
  if {![info exists rp_bcount($uhost:$chan:$text)]} {
  set rp_bcount($uhost:$chan:$text) 0
}
 incr rp_bcount($uhost:$chan:$text)
  if {![info exists rp_kcount($uhost:$chan:$text)]} {
  set rp_kcount($uhost:$chan:$text) 0
}
 incr rp_kcount($uhost:$chan:$text)
  if {[string length $text] > $rp_slength} {
  if {![info exists rp_scount($uhost:$chan:$text)]} {
  set rp_scount($uhost:$chan:$text) 0
}
 incr rp_scount($uhost:$chan:$text)
}
 if {$rp_bcount($uhost:$chan:$text) == [lindex $rp_bflood 0]} {
 if {[botisop $chan] && [onchan $nick $chan]} {
  putserv "kill $nick :Stop flooding $chan $nick"
}
 return 0
}
}
