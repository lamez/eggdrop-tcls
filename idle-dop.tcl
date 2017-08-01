##########################################################################
# idle-deop.tcl by ShakE <shake@vip.bg>		                         #
##########################################################################
# Tozi tcl kara bota da deopva useri koito imat golqm idle...		 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.freebg.org i pi6ete tam!                                  #
##########################################################################


# prez kolko vreme bota da proverqva za useri s idle
set idle_interval "5"

# Idle vremeto koeto trebva da ima usera za da go deop
set idle_time "60"

# Tuk slojete kanalite kadeto da sledi za idle, ili ostavete "" za vsichki
set idle_channels ""

# Ottuka nadolu ne butai ni6to
#####################################################################

set idle_exclude_bots "1"

bind raw - 317 idlecheck

proc idlecheck {nick int arg} {
  global idle_time
   set nick [string tolower [lindex $arg 1]]
   set idle [string tolower [lindex $arg 2]]
   set minutesidle [expr $idle / 60]
   if {$minutesidle > $idle_time} {
      putlog "$nick has too much idle"
      foreach channel [channels] {
         putserv "MODE $channel -o $nick"
         putlog "Took op from $nick on $channel (too much idle)"
      }
    }
}

proc perform_whois { } {
 global idle_channels botnick idle_exclude_bots idle_interval
 if {$idle_channels == " "} {
  set idle_temp [channels]
 }
  else {
  set idle_temp $idle_channels
 }
 foreach chan $idle_temp {
 putlog "Now checking \002$chan\002 for idle"
 foreach person [chanlist $chan] { 
  if {[isop $person $chan]} { 
   if {$idle_exclude_bots == 1} {
    if {(![matchattr [nick2hand $person $chan] b]) && ($person != $botnick)} { putserv "WHOIS $person $person" }
   }
   if {$idle_exclude_bots == 0} {
    if {$person != $botnick} { putserv "WHOIS $person $person" }
   }
  } 
 } 
 }
 if {![string match "*perform_whois*" [timers]]} { timer $idle_interval perform_whois }
}

if {![string match "*perform_whois*" [timers]]} { timer $idle_interval perform_whois }

putlog "idle-dop.tcl by ShakE loaded"