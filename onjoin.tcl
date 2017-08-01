############################################
# Onjoin.tcl 0.1 by #egghelp@efnet (KuNgFo0)
#
# Set the next lines as the random onjoin msgs you want to say
set onjoin_msg {
 {
  "Onjoin.tcl 0.1 by #egghelp@efnet"
  "(example onjoin script)"
  "Random msg #1"
  "Hello \$nick and welcome to \$chan"
 }
 {
  "Onjoin.tcl 0.1 by #egghelp@efnet"
  "(example onjoin script)"
  "Random msg #2"
  "Hello \$nick and welcome to \$chan"
 }
}
# Set the next line as the channels you want to run in
set onjoin_chans "#testchannel1 #testchannel2"

bind join - * join_onjoin

putlog "*** Onjoin.tcl 0.1 by #egghelp@efnet loaded"

proc join_onjoin {nick uhost hand chan} {
 global onjoin_msg onjoin_chans botnick
 if {(([lsearch -exact [string tolower $onjoin_chans] [string tolower $chan]] != -1) || ($onjoin_chans == "*")) && (![matchattr $hand b]) && ($nick != $botnick)} {
  set onjoin_temp [lindex $onjoin_msg [rand [llength $onjoin_msg]]]
  foreach msgline $onjoin_temp {
   puthelp "NOTICE $nick :[subst $msgline]"
  }
 }
}

