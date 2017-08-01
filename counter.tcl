#This is a basic kick and join counter. This script requires that 
#userinfo1.0.tcl is loaded before this script is. And also that KICKS is a 
#field in the userinfo1.0.tcl script. I would appreciate it, if you left my 
#nick in the putlog. Any changes, improvements, or problems plz don't hesitate
#to email me at abodnar@mail.utexas.edu
# --Neuromancer

#New to v2.0
#------------------------------------------------------------------------------
#- Added cmds to let you find out the total amount of joins to a channel by doing 
#either .totaljoins [#channel] in the bot or !totaljoins [#channel] in the
#channel, #channel is optional.
#- Added cmds to let you find out the total amount of kicks for a channel 
#or a person by doing either .totalkicks [nick] in the bot or 
#!totalkicks [nick] in the channel, nick is optional. 
#- Cleaned up some of the code dealing w/ the files
#- Made the # given when someone joins have the proper ending...
#ie. 1 = 1ia, 2 = 2ia, 263 = 263ia


if {![info exists userinfover] } {
 putlog "*** Can't load Counter 2.0 -- Userinfo v1.01 required"
 return 0
}

bind pub f|f !totaljoins pub:totaljoins
bind dcc f|f totaljoins dcc:totaljoins
bind join -|- * joincounter
bind pub f|f !totalkicks pub:totalkicks
bind dcc f|f totalkicks dcc:totalkicks
bind kick -|- * kickcounter
set khits 0
set jhits 0

proc convert {number} {
 set one ia
 set two ia
 set three ia
 set others ia
 set numlength [string length $number]
 incr numlength -2
 set num2ndchar [string index $number $numlength]
 switch $num2ndchar {
  1 { set number $number$others }
  default {
   incr numlength
   set numchar [string index $number $numlength]
   switch $numchar {
    1 { set number $number$one }
    2 { set number $number$two }
    3 { set number $number$three }
    default { set number $number$others }
   }
  }
 }
 return $number
}

proc dcc:totaljoins {hand idx arg} {
 if {$arg == ""} {
  set temp 0
  set chan [lindex [console $idx] 0]
  set rchan [string tolower $chan]
  if {[file exists ./text/$rchan.jcount.txt]} {
   set o_fid [open "./text/$rchan.jcount.txt" "RDONLY"]
   gets $o_fid temp
   close $o_fid
   putdcc $idx "$temp people have visited $rchan"
   return 0
  } else {
   putdcc $idx "Sorry, no one has visited $rchan yet"
  }
 } else {
  set temp 0
  set rchan [string tolower $arg]
  if {[file exists ./text/$rchan.jcount.txt]} {
   set o_fid [open "./text/$rchan.jcount.txt" "RDONLY"]
   gets $o_fid temp
   close $o_fid
   putdcc $idx "$temp people have visited $rchan"
   return 0
  } else {
   putdcc $idx "Sorry, no one has visited $rchan yet"
  }
 }
}

proc pub:totaljoins {nick host hand chan arg} {
 if { $arg == "" } {
  set temp 0
  set rchan [string tolower $chan]
  if {[file exists ./text/$rchan.jcount.txt]} {
   set o_fid [open "./text/$rchan.jcount.txt" "RDONLY"]
   gets $o_fid temp
   close $o_fid
   putserv "PRIVMSG $chan :$temp people have visited $chan"
   return 0
  } else {
   putserv "PRIVMSG $chan :Sorry, no one has visited $rchan yet"
  }
 } else {
  set temp 0
  set rchan [string tolower $arg]
  if {[file exists ./text/$rchan.jcount.txt]} {
   set o_fid [open "./text/$rchan.jcount.txt" "RDONLY"]
   gets $o_fid temp
   close $o_fid
   putserv "PRIVMSG $chan :$temp people have visited $rchan"
   return 0
  } else {
   putserv "PRIVMSG $chan :Sorry, no one has visited $rchan yet"
  }
 }
} 

proc joincounter {nick host hand chan} {
 global jhits
 set temp 0
 set rchan [string tolower $chan]
 if {[file exists ./text/$rchan.jcount.txt]} {
  set o_fid [open "./text/$rchan.jcount.txt" "RDONLY"]
  gets $o_fid temp
  close $o_fid
 } else {
  set o_fid [open "./text/$rchan.jcount.txt" "CREAT RDWR"]
  puts $o_fid temp
  close $o_fid
 }
 set jhits $temp
 incr jhits
 putserv "NOTICE $nick : Ti si [convert $jhits] chovek, koito vliza v $chan do sega" 
 set o_id [open "./text/$rchan.jcount.txt" "WRONLY"]
 puts $o_id $jhits
 close $o_id
}


proc dcc:totalkicks {hand idx arg} {
 if {$arg == ""} {
  set temp 0
  set chan [lindex [console $idx] 0]
  set rchan [string tolower $chan]
  if {[file exists ./text/$rchan.kcount.txt]} {
   set o_fid [open "./text/$rchan.kcount.txt" "RDONLY"]
   gets $o_fid temp
   close $o_fid
   putdcc $idx "$temp people have been kicked from $rchan"
   return 0
  } else {
   putdcc $idx "Sorry, no one has been kicked from $rchan yet"
  }
 } else {
  set temp 0
  set nick [string tolower $arg]
  if {[validuser $nick]} {
   if {[getuser $nick XTRA KICKS] == ""} {
    putdcc $idx "$arg hasn't kicked anyone yet"
   } else {
    set tkicks [getuser $nick XTRA KICKS]
    putdcc $idx "$arg has kicked $tkicks lamers"
   }
  } else {
   putdcc $idx "I do not know who $arg is"
  }
 }
}        

proc pub:totalkicks {nick host hand chan arg} {
 if {$arg == ""} {
  set temp 0
  set rchan [string tolower $chan]
  if {[file exists ./text/$rchan.kcount.txt]} {
   set o_fid [open "./text/$rchan.kcount.txt" "RDONLY"]
   gets $o_fid temp
   close $o_fid
   putserv "PRIVMSG $chan :$temp people have been kicked from $rchan"
   return 0
  } else {
   putserv "PRIVMSG $chan :Sorry, no one has been kicked from $rchan yet"
  }
 } else {
  set temp 0
  set nick [string tolower $arg]
  if {[validuser $nick]} {
   if {[getuser $nick XTRA KICKS] == ""} {
    putserv "PRIVMSG $chan :$arg hasn't kicked anyone yet"
   } else {
    set tkicks [getuser $nick XTRA KICKS]
    putserv "PRIVMSG $chan :$arg has kicked $tkicks lamers"
   }
  } else {
   putserv "PRIVMSG $chan :I do not know who $arg is"
  }
 }
}

proc kickcounter {nick host hand chan knick reason} {
 global khits
 set temp 0
 set rchan [string tolower $chan]
 if {[file exists ./text/$rchan.kcount.txt]} {
  set o_fid [open "./text/$rchan.kcount.txt" "RDONLY"]
  gets $o_fid temp
  close $o_fid
 } else {
  set o_fid [open "./text/$rchan.kcount.txt" "CREAT RDWR"]
  puts $o_fid temp
  close $o_fid
 }
 set khits $temp
 incr khits
 if {[validuser [nick2hand $nick $chan]]} {
  if {[getuser $hand XTRA KICKS] == ""} {
   setuser $hand XTRA KICKS 0 
  }
  set tkicks [getuser $hand XTRA KICKS]
  incr tkicks
  setuser $hand XTRA KICKS $tkicks
  putserv "PRIVMSG $chan :$nick napravi svoia $tkicks shut kvo da se pravi stavat takiva nesta;)"
 }
 putserv "PRIVMSG $chan :$knick be6e [convert $khits] lamer koito poluchava shut v $chan"
 set o_id [open "./text/$rchan.kcount.txt" "WRONLY"]
 puts $o_id $khits
 close $o_id
}

putlog "Join & Kick Counter v2.1 by Neuromancer"
