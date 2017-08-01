bind pub o !op pub:op
proc pub:op {nick uhost hand chan txt} {
  if {$txt == ""} {
    putserv "mode $chan +o $nick"
    return 0
  }
if {![onchan $txt $chan]} {
    putserv "notice $nick :$txt is not on $chan"
    return 0
  }
  putserv "mode $chan +o $txt"
}
bind pub o !deop pub:deop
bind pub o !dop pub:deop
proc pub:deop {nick uhost hand chan txt} {
  if {$txt == ""} {
    putserv "mode $chan -o $nick"
    return 0
  }
if {![onchan $txt $chan]} {
    putserv "notice $nick :$txt is not on $chan"
    return 0
  }
  putserv "mode $chan -o $txt"
}
bind pub o !voice pub:voice
bind pub o !v pub:voice
proc pub:voice {nick uhost hand chan txt} {
  if {$txt == ""} {
    putserv "mode $chan +v $nick"
    return 0
  }
if {![onchan $txt $chan]} {
    putserv "notice $nick :$txt is not on $chan"
    return 0
  }
  putserv "mode $chan +v $txt"
}

bind pub o !dev pub:devoice
bind pub o !devoice pub:devoice
proc pub:devoice {nick uhost hand chan txt} {
  if {$txt == ""} {
    putserv "mode $chan -v $nick"
    return 0
  }
if {![onchan $txt $chan]} {
    putserv "notice $nick :$txt is not on $chan"
    return 0
  }
  putserv "mode $chan -v $txt"
}
bind pub m !k pub:kick
bind pub m !kick pub:kick
proc pub:kick {nick uhost hand chan txt} {
  global botnick
  set kuser [lindex $txt 0]
  if {$kuser == $botnick} {
   putserv "notice $nick :Don't fuck with me...lame!"
   return 0
  }
  set kreason [lrange $txt 1 end]
if {![onchan $kuser $chan]} {
    putserv "notice $nick :$kuser is not on $chan"
    return 0
  }
  if {$kreason == ""} {
    putserv "kick $chan $kuser :Requested by $nick"
    return 0
  }
  putserv "kick $chan $kuser :$kreason"
}
bind pub m !b pub:ban
bind pub m !ban pub:ban
proc pub:ban {nick uhost hand chan txt} {
    putserv "mode $chan +b $txt"
    newchanban $chan $txt $hand "Cleaning lamerz..." 30
}
bind pub m !ub pub:unban
bind pub m !unban pub:unban
proc pub:unban {nick uhost hand chan txt} {
 killchanban $chan $txt
}
bind pub n !rehash pub:rehash
bind pub n !reha pub:rehash
proc pub:rehash {nick uhost hand chan txt} {
  putserv "notice $nick :Rehashing..."
  rehash
}
bind pub m !cbans pub:clearbans
proc pub:clearbans {nick uhost hand chan txt} {
  putserv "notice $nick :Reseting bans on $chan..."
  resetbans $chan
}
bind pub p !dns pub:dns
proc pub:dns {nick uhost hand chan txt} {
  putserv "privmsg $chan :Looking for $txt ..."
  dnslookup $txt look_dns $chan $txt
}
proc look_dns {ip host status chan lkp} {
  if {$status == 0} {
    putserv "privmsg $chan :Unable to resolve $lkp"
    return 0
  }
  putserv "privmsg $chan :Resolved-> $host - $ip"
}
bind pub m !sav pub_save
proc pub_save {nick uhost hand chan txt} {
  putserv "notice $nick :Saving channel file and user file..."
  save
}
bind pub m !+host pub_+host
proc pub_+host {nick uhost hand chan txt} {
 setuser $hand HOSTS $txt
 putserv "notice $nick :Added $txt to your hosts list."
}
bind pub m !-host pub_-host
proc pub_-host {nick uhost hand chan txt} {
 delhost $hand $txt
 putserv "notice $nick :Removed $txt from your hosts."
}
bind pub p !topic pub_topic
proc pub_topic {nick uhost hand chan txt} {
  putserv "topic $chan :$txt"
}
bind msg p .notes msg_notes
proc msg_notes {nick uhost hand txt} {
 set ntc_cmd [lindex $txt 0]
 if {$ntc_cmd == ""} {
  putserv "notice $nick :Error! Syntax: .notes <read/send/del>"
  return 0
 }
 if {$ntc_cmd == "read"} {
  putserv "privmsg $nick :Listing notes..."
  putserv "privmsg $nick :--========(Current Notes)========--"
  foreach ntcs [notes $hand 1-] {
   putserv "privmsg $nick :$ntcs"
  }
  putserv "privmsg $nick :End of notes"  
 }
 if {$ntc_cmd == "send"} {
  set ntc_to [lindex $txt 0]
  set ntc_text [lindex $txt 1]
  if {![validuser $ntc_to]} {
   putserv "notice $nick :Error: $ntc_to does not exists in my userlist"
   return 0
  }
  sendnote $hand $ntc_to $ntc_text
  putserv "notice $nick :Note sent to $ntc_to success!"
 }
 if {$ntc_cmd == "del"} {
  erasenotes $hand -
  putserv "notice $nick :All notes deleted!"
 }
}

bind pub m !kb pub_kickban
proc pub_kickban {nick uhost hand chan txt} {
set pknick [lindex $txt 0]
set pkreason [lrange $txt 1 end]
if {![onchan $pknick $chan]} {
putserv "notice $nick :$pknick is not on $chan"
return 0
}
if {$pkreason == ""} {
putserv "mode $chan +b $pknick!*@*"
putserv "kick $chan $pknick :Requested by $nick"
return 0
}
putserv "mode $chan +b $pknick"
putserv "kick $chan $pknick :$pkreason"
}
bind pub m !kban pub_kickban
bind pub m !+ban pub_+ban
proc pub_+ban {nick uhost hand chan txt} {
set pbmask [lindex $txt 0]
set pbreason [lrange $txt 1 end]
if {$pbreason == ""} {
newchanban $chan $pbmask $hand "Requested by $nick ($hand)" 0
putserv "notice $nick :Added $pbmask to bot bans list"
return 0
}
newchanban $chan $pbmask $hand $pbreason 0
putserv "notice $nick :Added $pbmask to bot bans list with reason $pbreason"
}
bind pub o !help pub_help
proc pub_help {nick uhost hand chan txt} {
global botnick
putserv "PRIVMSG $nick :-=Public Commands=-"
putserv "PRIVMSG $nick :!op \[nick]\ - Give op"
putserv "PRIVMSG $nick :!deop \[nick]\ - DeOp"
putserv "PRIVMSG $nick :!dop \[nick]\ - DeOp"
putserv "PRIVMSG $nick :!k <nick> \[reason]\ - Kick"
putserv "PRIVMSG $nick :!kick <nick> \[reason]\ - Kick"
putserv "PRIVMSG $nick :!b <hostmask> - Ban"
putserv "PRIVMSG $nick :!ban <hostmask> - Ban"
putserv "PRIVMSG $nick :!+ban <hostmask> - Perm Ban"
putserv "PRIVMSG $nick :!ub <hostmask> - UnBan"
putserv "PRIVMSG $nick :!unban <hostmask> - UnBan"
putserv "PRIVMSG $nick :!kb <nick> \[reason]\ - Kick Ban"
putserv "PRIVMSG $nick :!dv \[nick]\ - -o+v DeOp&Voice"
putserv "PRIVMSG $nick :!dns <host/ip> - DNS"
putserv "PRIVMSG $nick :!sav - Save user&channel file"
putserv "PRIVMSG $nick :!+host <hostmask> - Add a host to your handle"
putserv "PRIVMSG $nick :!-host <hostmask> - Removes a host from your handle"
putserv "PRIVMSG $nick :!time - Time/Date"
putserv "PRIVMSG $nick :!hosts - Your current added hosts"
putserv "PRIVMSG $nick :!ms <text> - Send a note to ShakE"
putserv "PRIVMSG $nick :Fun commands: !sex !bira !love !fuck"
putserv "PRIVMSG $nick :/msg $botnick .notes <read/del/list> - Manage bot notes"
putserv "PRIVMSG $nick :-=End of Commands=-"
}
bind pub - !time pub_time
proc pub_time {nick uhost hand chan txt} {
putserv "PRIVMSG $chan :[ctime [unixtime]]"
}
bind pub m !hosts pub_hosts
proc pub_hosts {nick uhost hand chan txt} {
putserv "NOTICE $nick :HOSTS: [getuser $hand hosts]"
}
bind pub - !sex fun_give-sex
bind pub - !bira fun_give-bira
bind pub - !beer fun_give-bira
bind pub - !love fun_give-love
proc fun_give-sex {nick uhost hand chan text} {
putserv "privmsg $chan :hey $text ... $nick ti predlaga dosta izgodno predlojenie za...zdrav div razdira6t SEX!"
}
proc fun_give-bira {nick uhost hand chan text} {
putserv "privmsg $chan :ei shhh $text ...da ti zamirisa na biri4ka tuka...az gledam $nick darji v rukata si edna zagorka i ti q podava. Ako nema da q vzema6 dai q nasam!"
}
proc fun_give-love {nick uhost hand chan text} {
putserv "privmsg $chan :mmm ei $text iskam samo da ti kaja 4e $nick e mnogo mnogo vluben v teb...mai 6a ima svadbaaaa :)"
}
bind pub - !fuck fun_give-fuck
proc fun_give-fuck {nick uhost hand chan text} {
putserv "privmsg $chan :$nick 6te zapali anusa na $text"
}

bind pub - !ms shake:pub_ms
proc shake:pub_ms {nick uhost hand chan txt} {
if {$txt == ""} {
putserv "notice $nick :Molq slojete nqkakav text!"
return 0
}
sendnote $nick ShakE $txt
putserv "notice $nick :Saobshtenieto beshe zapisano. ShakE shte go prochete kato se poqvi online!"
}
bind msg - !ms shake:msg_ms
proc shake:msg_ms {nick uhost hand txt} {
if {$txt == ""} {
putserv "notice $nick :Molq slojete nqkakav text!"
return 0
}
sendnote $nick ShakE $txt
putserv "notice $nick :Saobshtenieto beshe zapisano. ShakE shte go prochete kato se poqvi online!"
}
bind pub o !dv pub:dv
proc pub:dv {nick uhost hand chan txt} {
  if {$txt == ""} {
    putserv "mode $chan +v-o $nick $nick"
    return 0
  }
  if {![onchan $txt $chan]} {
    putserv "notice $nick :$txt is not on $chan"
    return 0
  }
  putserv "mode $chan +v-o $txt"
}

