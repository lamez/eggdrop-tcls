set timedmsg1 "Ne za"
set timedmsg2 ""


if {$timedmsg1active == 1} {
  if {![info exists timedmsgrunning1]} {
    set timedmsgrunning1 "in use"
    timer 2 timed_msg1
  }
}

if {$timedmsg2active == 1} {
  if {![info exists timedmsgrunning2]} {
    set timedmsgrunning2 "in use"
    timer 4 timed_msg2
  }
}

#------------------------------------------------------------------------------------------------------------
# This Proc displays a custom message at a specified interval (message 1)
#------------------------------------------------------------------------------------------------------------
proc timed_msg1 {} {
    global timed_msg1 timer_chan1 timedmsgdelay1
      puthelp "PRIVMSG $timer_chan1 :$timed_msg1"
      timer $timedmsgdelay1 timed_msg1
}

#------------------------------------------------------------------------------------------------------------
# This Proc displays a custom message at a specified interval (message 2)
#------------------------------------------------------------------------------------------------------------
proc timed_msg2 {} {
    global timed_msg2 timer_chan2 timedmsgdelay2
      puthelp "PRIVMSG $timer_chan2 :$timed_msg2"
      timer $timedmsgdelay2 timed_msg2
}
