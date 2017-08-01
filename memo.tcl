### Na4alo na ko nfiratzionnata 4ast!
## Imeto na fajla kydeto ste se zapiswat userite, koito ste se /ison-vat
set filename  "nlist.txt"
## Imeto na fajla kydeto ste se zapiswat userite, koito imat block status on
set fileblock "block.txt"
## Imeto na fajla kydeto ste se zapiswat saobsteniqta (memotata)
set memofile "memos.txt"
## Kolko memota naj-mnogo mogat da se pratqt na user
set maxmemos "8"
## Slojete towa na tekustata vremeva zona w koqto ste (GMT+2 - Bulgaria)
set timezone "GMT+2"
### Kraj na konfiguratziqta!

## Ne butajte towa :P Izpolzwa se ot skripta
set online ""

if {![file exists $filename]} {
  set fh [open $filename w]
  puts -nonewline $fh ""
  close $fh
}

if {![file exists $fileblock]} {
  set fh [open $fileblock w]
  puts -nonewline $fh ""
  close $fh
}

if {![file exists $memofile]} {
  set fh [open $memofile w]
  puts -nonewline $fh ""
  close $fh
}

## send <nick> <message>
bind msg - send memo:send
proc memo:send {nick uhost hand text} {
  global botnick memofile maxmemos
  set dest [lindex $text 0]
  set message [lrange $text 1 end]

  if {$dest == "" || $message == ""} {
	putserv "NOTICE $nick :Pravilno: /msg $botnick send <nick> <message>"
	return 0
  }

  set memoblock [getblock $dest]

  if {[string tolower $memoblock] == "on"} {
	puthelp "NOTICE $nick :\002$dest\002 ne iska da poluchava memos."
	return 0
  }

  set memos 0
  set memo [open $memofile r]
  while {![eof $memo]} {
	set line [gets $memo]
	if {([string tolower [lindex $line 0]] == [string tolower $dest]) && ([lindex $line 1] == $nick)} {
	  incr memos
	}
	if {$memos > [expr $maxmemos - 1]} {
	  puthelp "NOTICE $nick :Sajalqvam, no ste previshili limit-a ot $maxmemos memos za \002$dest\002. Molq izchakaite \002$dest\002 da si iztrie memos predi da mu prashtate oshte."
	  return 0
	  close $memo
	}
  }
  close $memo
  set memo [open $memofile a]
  set putline "$dest $nick [unixtime] 1 $message"
  puts $memo $putline
  close $memo
  puthelp "NOTICE $nick :Memo-to beshe izprateno na \002$dest\002."
  ison_addisona $dest
  putserv "ISON [getinfoto]"
}

bind msg - read memo:read
proc memo:read {nick uhost hand text} {
  global botnick memofile
  set number [lindex $text 0]
  if {$number == ""} {
	puthelp "NOTICE $nick :Usage: READ <number>"
    return 0
  }
  set memos 0
  set message ""
  set memo [open $memofile r]
  while {![eof $memo]} {
	set line [gets $memo]
    if {[string tolower [lindex $line 0]] == [string tolower $nick]} { 
	  if {[string tolower $number] == "all"} {
		set message $line
	    puthelp "NOTICE $nick :Memo: \002$number\002  \002\002  Izprateno ot: \002[lindex $message 1]\002  \002\002  Za da go iztriesh, pishi: /msg $botnick del $number"
	    puthelp "NOTICE $nick :[lrange $message 4 end]"
	  } else {
		incr memos
  		if {$memos == $number} {
    	  set message $line
    	}
	  }
  	}
  }
  close $memo

  if {$message == ""} {
	puthelp "NOTICE $nick :Nqma takova memo!"
    return 0
  }
  if {[string tolower $number] != "all"} {
	puthelp "NOTICE $nick :Memo: \002$number\002  \002\002  Izprateno ot: \002[lindex $message 1]\002  \002\002  Za da go iztriesh, pishi: /msg $botnick del $number"
    puthelp "NOTICE $nick :[lrange $message 4 end]"
  }

  if {[string tolower $number] != "all"} {
    if {[lindex $message 3] != "1"} {
	  return 0
    }
  }
  set ok 0
  set fp [open $memofile r]
  set fpw [open $memofile.old w]
  set found 0
  while {![eof $fp]} {
    set line [gets $fp]
    set ok 1
	if {[string tolower $number] != "all"} {
  	  if {$line == $message} {
    	set dest [lindex $line 0]
    	set from [lindex $line 1]
    	set time [lindex $line 2]
    	set memo [lrange $line 4 end]
    	set line "$dest $from $time 0 $memo"
  		set ok 1
  	  }
	} else {
	  if {[string tolower [lindex $line 0]] == [string tolower $nick]} { 
		set dest [lindex $line 0]
    	set from [lindex $line 1]
    	set time [lindex $line 2]
    	set memo [lrange $line 4 end]
    	set line "$dest $from $time 0 $memo"
  		set ok 1
	  }
	}
    if {$ok == 1} {
	  if {$line != ""} {
    	puts $fpw $line
	  }
    }
  }
  close $fp
  close $fpw
  file delete $memofile
  file rename $memofile.old $memofile
}

bind msg - del memo:del
proc memo:del {nick uhost hand text} {
  global botnick memofile
  set word [lindex $text 0]
  if {$word == ""} {
	puthelp "NOTICE $nick :Usage: DEL <number>"
    return 0
  }
  set ok 0
  set fp [open $memofile r]
  set fpw [open $memofile.old w]
  set found 0
  while {![eof $fp]} {
	set line [gets $fp]
    set ok 1
	set del 0
    if {[string tolower [lindex $line 0]] == [string tolower $nick]} {
	  if {[string tolower $word] != "all"} {
	    incr found
    	if { $found == $word } {
    	  set ok 0
    	  incr found
    	}
	  } else {
		set del 1
		set ok 0
	  }
    }
    if {$ok == 1} {
	  if {$line != ""} {
  		puts $fpw $line
	  }
    }
  }
  close $fp
  close $fpw
  if {[string tolower $word] != "all"} {
    if { $found < $word } {
	  putserv "NOTICE $nick :Nqma takova memo!"
  	  file delete $memofile.old
  	  return 0
    }
  } else {
	if {$del == 0} {
	  putserv "NOTICE $nick :Nqma takova memo!"
  	  file delete $memofile.old
  	  return 0
	}
  }
  file delete $memofile
  file rename $memofile.old $memofile
  if {[string tolower $word] != "all"} {
    putserv "NOTICE $nick :Memo $word beshe iztrito."
  } else {
    putserv "NOTICE $nick :$word bqha iztriti."
  }
  if {[string tolower $word] != "all"} {
    if {$found == 2} {
	  ison:delison $nick
	}
  } else {
	ison:delison $nick
  }
}

bind msg - list memo:list
proc memo:list {nick uhost hand text} {
  global botnick memofile timezone
  puthelp "NOTICE $nick :Memo list za \002$nick\002: Za da gi prochetesh, pishi: /msg $botnick read <number>"
  set memos 0
  set linetoread ""
  set message ""
  set memo [open $memofile r]
  while {![eof $memo]} {
	set line [gets $memo]
    set prefix " "
    if {[string tolower [lindex $line 0]] == [string tolower $nick]} { 
  	  incr memos
  	  if {[lindex $line 3] == "1"} {
		set prefix "*"
	  }
  	  set linetoread " \002 \002 $prefix$memos  [lindex $line 1]  \002\002  \002\002  [ctime [lindex $line 2]] $timezone"
  	  puthelp "NOTICE $nick :$linetoread"
	}
  }
  close $memo
  if {$linetoread == ""} {
	puthelp "NOTICE $nick :Nqmash memos."
    return 0
  }
  puthelp "NOTICE $nick :Krai na memo list."
}

proc memo:check {nick} {
  global botnick memofile
  if {![file exists $memofile]} {
	set memo [open $memofile a]
    puts $memo "Memo File"
    puts $memo "---------"
    puts $memo ""
    close $memo
    return 0
  }
  set memo [open $memofile r]
  set memos 0
  while {![eof $memo]} {
	set line [gets $memo]
    if {([string tolower [lindex $line 0]] == [string tolower $nick]) && [lindex $line 3] == "1"} {
	  incr memos
	}
  }
  close $memo
  if {$memos == "0"} {
	return 0
  }
  return $memos
}

bind time - "05 18 * * *" memo:scan
proc memo:scan {min hour day month year} {
  set ok 0
  set found 0
  set fp [open $memofile r]
  set fpw [open $memofile.old w]
  while {![eof $fp]} {
	set line [gets $fp]
	if {[dupZZ [getinfoto] [lindex $line 0] 1] == ""} {
	  ison:delison [lindex $line 0]
	}
    set ok 1
    set time [lindex $line 2]
    if {[expr [unixtime] - $time] > 2800000} {
	  set ok 0
	}
  	if {$ok == 1} {
	  if {$line != ""} {
    	puts $fpw $line
	  }
    }
  }
  close $fp
  close $fpw
  file delete $memofile
  file rename $memofile.old $memofile
}

bind msg - block memo:block
proc memo:block { nick uhost hand text } {
  global botnick fileblock
  set option [lindex $text 0]
  if {[string tolower $option] == "on"} {
	set fh  [open $fileblock r]
	set fha [open $fileblock.old w]
	set found 0
	while {![eof $fh]} {
	  set line [gets $fh]
	  if {[lindex $line 0] == $nick} {
		set found 1
	  } else {
		if {$line != ""} {
		  puts $fha $line
		}
	  }
	}
	close $fh
	if {$found == 0} {
	  puts $fha "$nick BLOCK"
	} else {
	  puthelp "NOTICE $nick :Veche si blokiral memos!"
	  close $fha
	  file rename -force $fileblock.old $fileblock
	  return
	}
    file rename -force $fileblock.old $fileblock
	close $fha
    puthelp "NOTICE $nick :Memos sa \002blokirani\002. Poveche nqma da poluchavash memos."
    return 0
  } elseif {[string tolower $option] == "off"} {
	set fh  [open $fileblock r]
	set fha [open $fileblock.old w]
	set found 0
	while {![eof $fh]} {
	  set line [gets $fh]
	  if {[lindex $line 0] == $nick} {
		set found 1
	  } else {
		if {$line != ""} {
		  puts $fha $line
		}
	  }
	}
	close $fh
	if {$found == 0} {
	  puthelp "NOTICE $nick :Ne si blokiral memos!"
	  return
	}
	file rename -force $fileblock.old $fileblock
	close $fha
    puthelp "NOTICE $nick :Memos sa \002otblokirani\002. Veche shte poluchavash memos."
    return 0
  } else {
    puthelp "NOTICE $nick :Blokirovka na memos e \002<[getblock $nick]>\002. Za da go promenish /msg $botnick block \[on|off\]"
    return 0
  }
}

proc getblock {nick} {
  global fileblock
  set fh [open $fileblock r]
  set found 0
  while {![eof $fh]} {
	set line [gets $fh]
	if {[lindex $line 0] == $nick} {
	  set found 1
	}
  }
  close $fh
  if {$found == 1} {
	return "on"
  } else {
	return "off"
  }
}

bind raw - 325 whois:idented
proc whois:idented {* 325 arg} {
  global botnick
  set user [lindex $arg 1]
  set memos [memo:check $user]
  if {$memos != 0} {
	puthelp "NOTICE $user :Imash \002$memos\002 neprocheteni memos. Za list, pishi: /msg $botnick list."
  }
}

bind raw - 303 online_rawa
proc online_rawa {* 303 arg} {
  global online
  set nlist [getinfoto]
  string tolower $nlist
  set arg [string trimleft [lrange $arg 1 end] ":"]
  set arg [charfilter $arg]
  if {$arg == ""} {
	set online ""
  } else {
	if {$online == ""} {
	  set arg [removespaces $arg]
	  set online $arg
	  foreach user $arg {
		putserv "WHOIS $user"
	  }
	}
	return
  }

  set foo [qonreport 0 $arg $online]

  if {$foo != ""} {
	set foo [charfilter $foo]
	set foo [removespaces $foo]
    foreach user $foo {
	  putserv "WHOIS $user"
	}
  }
  set online1 $online
  unset online
  set online [qonreport 1 $arg $online1]
}

proc ison_addisona {arg} {
  set nlist [getinfoto]
  set dontsay [dupZZ $nlist $arg 0]
  if {$dontsay == ""} {
	set arg [charfilter $arg]
	set arg [removespaces $arg]
	writetof "$nlist $arg"
    putserv "ISON :$nlist $arg"
  } else {
	set dontsay [removespaces $dontsay]
	set dontsay [charfilter $dontsay]
	set final [dupZZ $nlist $dontsay 1]
	if {$final != ""} {
	  set final [removespaces $final]
	  set final [charfilter $final]
	}
	writetof "$nlist $final"
    putserv "ISON :$nlist $final"
  }
}

proc ison:delison {arg} {
  set nicknames [getinfoto]
  set who [lindex $arg 0]
  set who [charfilter $who]
  
  if {[lsearch -exact $nicknames [lindex $arg 0]] == -1} {
	return 0
  }
  regsub -all "\\\m$who\\\M" $nicknames "" nicknames
  regsub -all {\s+} $nicknames { } nicknames
  writetof $nicknames
}

proc notify {} {
  set nlist [getinfoto]
  putserv "ISON :$nlist"
  if {![string match *notify* [utimers]]} { utimer 30 notify }
}

proc charfilter {x {y ""} } {
  for {set i 0} {$i < [string length $x]} {incr i} {
    switch -- [string index $x $i] {
      "\"" {append y "\\\""}
      "\\" {append y "\\\\"}
      "\[" {append y "\\\["}
      "\]" {append y "\\\]"}
      "\}" {append y "\\\}"}
      "\{" {append y "\\\{"}
      default {append y [string index $x $i]}
    }
  }
  return $y
}

proc getinfoto {} {
  global filename
  set file [open $filename r]
  set nlist ""
  while {![eof $file]} {
	set chast [gets $file]
    if {$chast != ""} {
	  append nlist $chast
	}
  }
  close $file
  return $nlist
}

proc removespaces {arg} {
  regsub {^\s+} $arg "" arg
  return $arg
}

proc qonreport {how arg online} {
  set aq 0
  set foo ""
  foreach el $arg {
    foreach el1 $online {
	  if {$el == $el1} {
	    set aq 1
	  }
    }
    if {$aq == $how} {
	  append foo " $el"
	}
    set aq 0
  }
  return $foo
}

proc writetof {what} {
  global filename
  set fh [open $filename w]
  puts $fh $what
  close $fh
}

proc dupZZ {where what how} {
  set dontsay ""
  foreach el1 $what {
	if {[lsearch -exact $where $el1] != -1} {
	  if {$how == 0} {
  		append dontsay " $el1"
	  }
    } else {
	  if {$how == 1} {
		append dontsay " $el1"
	  }
	}
  }
  return $dontsay
}

# !help
bind pub -|- !help help
proc help {nick uhost handle chan text} {
global botnick
   puthelp "NOTICE $nick : BLOCK: /msg $botnick block \[on|off\] - Shte wi predpazi ot polu4awane na memota."
   puthelp "NOTICE $nick : DEL: /msg $botnick del <number|all> - Izpolzwa se za da iztriete memo."
   puthelp "NOTICE $nick : LIST: /msg $botnick list - Pokazwa wi starite i nowite wi memota."
   puthelp "NOTICE $nick : READ: /msg $botnick read <number|all> - Pro4itate memo."
   puthelp "NOTICE $nick : SEND: /msg $botnick send <user> <message> - Izpolzwa se za da pratite memo na potrebiel."
   }

if {![string match *notify* [utimers]]} { utimer 30 notify }

