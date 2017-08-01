# W koi kanali da gleda dali owners na bota sa w akick-a
# Razdeleni sys prazni mesta.
# Ako slojete towa na [channels], wsi4ki kanali ste bydat zastitawani.
# Ne zabrawqjte da rehashnete bota sled addvane na now kanal.
set akick(nchans) "#Channel1 #Channel2"

# Kolko pyti trqbwa da byde kick bota ot chan za da adne potrebitelq w AKICK LISTA
set akick(ktimes) 3

# Sled kolko wreme spirat da waji ktimes za daden potrebitel
set akick(wreme) 120

# Dali da se zastitawat opredeleni potrebiteli (pri kick na bota).
# CS i OS se zastitawat po princip.
set akick(protectusers) 1

# Flagowete, koito potrebitelq trqbwa da ima, za da ne byde bannat/sloje w
# AKICK list-a pri kick na bota.
set akick(flagsprotect) "n|n"

# Flagowete, koito potrebitelq trqbwa da ima, za da se mahne ot AKICK lista.
set akick(flagmatch) "nb|n"

# +------------------------------ DO NOT EDIT BELLOW LINES ------------------------------+ #

bind mode - *+b* bot_banned
bind kick - * bot_kicked
bind raw - NOTICE services_parse

proc bot_banned {nick uhost hand chan mode victim} {
  global botname
  if {[string match -nocase "$victim" "$botname"]} {
    if {$nick == "CS"} {
	  putserv "PRIVMSG CS :akick $chan del $victim"
	  putserv "PRIVMSG CS :unban $chan"
	  putserv "JOIN $chan"
	}
  }
}

set kicked(beginchan) ""
proc bot_kicked {nick uhost hand chan target reason} {
  global kicked akick

  set host [lindex [split [getchanhost $nick $chan] @] 1]
  regsub {~} $uhost {} uhost

  if {[string tolower $nick] == "cs" || [string tolower $nick] == "os"} {
	return
  }

  if {$akick(protectusers) == 1 && [matchattr $hand $akick(flagsprotect) $chan]} {
	return
  }

  if {[array names kicked $host:$chan] == ""} {
    set kicked($host:$chan) [unixtime]
  } else {
	set kicked($host:$chan) [check_ts $kicked($host:$chan) $akick(wreme)]

	if {[llength $kicked($host:$chan)] == $akick(ktimes)} {
	  bankick $chan 2 $host
	} elseif {[llength $kicked($host:$chan)] >= 2} {
	  bankick $chan 1 $host
	}
  }
}

proc bankick {chan what host} {
  global botnick akick
  if {$what == 1} {
	newchanban $chan *@$host $botnick "Kicked me $akick(ktimes) times" 60 sticky
  } elseif {$what != 0} {
    putquick "PRIVMSG CS :AKICK $chan ADD *@$host"
  }
}

for {set i 0} {$i < 60} {set i [expr $i + 5]} {
  if {$i < 10} { set count "0$i" } else { set count $i }
  bind time - "$count * * * *" get_akick
}

proc get_akick {a b c d e} {
  global akick

  set count 1
  foreach chan $akick(nchans) {
	timer $count "putserv \"PRIVMSG CS :AKICK $chan LIST\""
	incr count
  }
}

proc services_parse {from key text} {
  global akick botnick kicked

  if {[string tolower [lindex [split $from "!"] 0]] == "cs"} {
	if {[lrange $text 1 4] == ":-- AutoKick List for"} {
	  set kicked(beginchan) [lindex $text 5]
	  set kicked(beginchan) [string range $kicked(beginchan) 2 end-2]
	  return
	}

	if {[lrange $text 1 5] == ":-- End of list --"} {
	  set kicked(beginchan) ""
	  return
	}

	if {$kicked(beginchan) == ""} {
	  return
	}

	set galabec [lindex $text 2]

	if {[matchattr [finduser $galabec] $akick(flagmatch) $kicked(beginchan)]} {
	  putserv "PRIVMSG CS :AKICK $kicked(beginchan) DEL $galabec"
	  return
    }
  }
}

proc check_ts {tss sec} {
  set tmp [list [unixtime]]

  foreach ts $tss {
    if {[expr [unixtime] - $ts] <= $sec} {
      lappend tmp $ts
    }
  }

  return $tmp
}

putlog "\002Anti Akick TCL by \006IRCHelp.UniBG.Org\006 Loaded!!!\002"
