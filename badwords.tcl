#############################################
# Badword.tcl 0.1 by #egghelp@efnet (KuNgFo0)

# Set the next line as the words/phrases you want to kick on
# (wildcards may be used)
set badwords {
 "eba"
 "shit"
 "fuck"
 "putka"
 "hui"
 "bitch"
 "kur"
 "laino"
 "laina"
 "microsoft*rules"
}
# Set the next line as the kick msg you want to say
set badword_msg "Bad Word Detected...removing spammer!"
# Set the next line as the channels you want to run in
set badword_chans "#testchannel1 #testchannel2"

bind pubm - * pubm_badword
bind ctcp - ACTION ctcp_badword 

putlog "*** Badword.tcl 0.1 by #egghelp@efnet loaded"

proc pubm_badword {nick uhost hand chan arg} {
 global badwords badword_msg badword_chans botnick
 if {(([lsearch -exact [string tolower $badword_chans] [string tolower $chan]] != -1) || ($badword_chans == "*")) && (![matchattr $hand b]) && ($nick != $botnick)} {
  foreach badword [string tolower $badwords] {
   if {[string match *$badword* [string tolower $arg]]} {
    putserv "KICK $chan $nick :$badword_msg"
    return
   }
  }
 }
}

proc ctcp_badword {nick uhost hand chan keyword arg} {
 pubm_badword $nick $uhost $hand $chan $arg
}

