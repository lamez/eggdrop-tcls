set pm_chan(#Program) "%nick has left #Program . Please come again!"
set pm_allusers 0
set pm_send "NOTICE"

# Don't edit below unless you know what you're doing.

proc pm_message {nick uhost hand chan {msg ""}} {
  global pm_allusers pm_chan pm_send pm_sent
  if {((!$pm_allusers) && ($hand != "*"))} {return 0}
  set stlchan [string tolower $chan]
  if {[info exists pm_sent($stlchan:$uhost)]} {return 0}
  if {[info exists pm_chan($stlchan)]} {
    set pm_sent($stlchan:$uhost) 1
    timer 5 [split "unset pm_sent($stlchan:$uhost)"]
    set message $pm_chan($stlchan)
    regsub -all -- "%nick" $message $nick message
    puthelp "$pm_send $nick :$message"
  }
  return 0
}

bind part - * pm_message

if {![info exists nb_component([file tail [file rootname [info script]]])]} {
  putlog "Loaded partmsg.tcl by GeniusS0ft (active on [join [array names pm_chan] ", "])."
}

return
