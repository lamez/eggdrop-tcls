##########################################################################
# OpControl.tcl by ShakE <shake@abv.bg>		                         #
##########################################################################
# Tozi tcl e napisan ot mene, s mnogo pove4e komandi ot ostanalite i nema#
# nujda ot "auth" za da gi izpolzvate. Napravil sam mnogo kratki komandi #
# za po burza i lesna namesa primerno pri takeover.Eto NEKOI ot komandite#
# !op !dop !v !dev !k !kb !b !+ban !-ban !sav !rehash !+user !+bot !+host#
# Napi6i v kanala ili na private !help i 6te ti izkara vsi4ki komandi. 	 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################

bind pub o|o !op pub_op
proc pub_op {nick uhost hand chan txt} {
  if {$txt == ""} {
    putserv "mode $chan +o $nick"
    putlog "\-=|$nick|=- \ #($chan)# !op"
    return 0
  }
  if {![onchan $txt $chan]} {
    putserv "notice $nick :$txt is not on $chan"
    putlog "\-=|$nick|=- \ #($chan)# failed !op $txt"
    return 0
  }
  putserv "mode $chan +o $txt"
  putlog "\-=|$nick|=- \ #($chan)# !op $txt"
}

bind pub o|o !dop pub_deop
proc pub_deop {nick uhost hand chan txt} {
  if {$txt == ""} {
    putserv "mode $chan -o $nick"
    putlog "\-=|$nick|=- \ #($chan)# !dop"
    return 0
  }
  if {![onchan $txt $chan]} {
    putserv "notice $nick :$txt is not on $chan"
    putlog "\-=|$nick|=- \ #($chan)# failed !dop $txt"
    return 0
  }
  putserv "mode $chan -o $txt"
  putlog "\-=|$nick|=- \ #($chan)# !dop $txt"
}

bind pub o|o !v pub_voice
proc pub_voice {nick uhost hand chan txt} {
  if {$txt == ""} {
    putserv "mode $chan +v $nick"
    putlog "\-=|$nick|=- \ #($chan)# !v"
    return 0
  }
  if {![onchan $txt $chan]} {
    putserv "notice $nick :$txt is not on $chan"
    putlog "\-=|$nick|=- \ #($chan)# failed !v $txt"
    return 0
  }
  putserv "mode $chan +v $txt"
  putlog "\-=|$nick|=- \ #($chan)# !v $txt"
}

bind pub o|o !dev pub_devoice
proc pub_devoice {nick uhost hand chan txt} {
  if {$txt == ""} {
    putserv "mode $chan -v $nick"
    putlog "\-=|$nick|=- \ #($chan)# !dev"
    return 0
  }
  if {![onchan $txt $chan]} {
    putserv "notice $nick :$txt is not on $chan"
    putlog "\-=|$nick|=- \ #($chan)# failed !dev $txt"
    return 0
  }
  putserv "mode $chan -v $txt"
  putlog "\-=|$nick|=- \ #($chan)# !dev $txt"
}

bind pub o|o !opme pub_op
bind pub o|o !k pub_kick
proc pub_kick {nick uhost hand chan txt} {
  set opc_knick [lindex $txt 0]
  set opc_kreason [lrange $txt 1 end]
  if {![onchan $opc_knick $chan]} {
    putserv "notice $nick :$opc_knick is not on $chan"
    putlog "\-=|$nick|=- \ #($chan)# failed !k $opc_knick"
    return 0
  }
  if {$opc_kreason == ""} {
    putserv "kick $chan $opc_knick :Requested by $nick"
    putlog "\-=|$nick|=- \ #($chan)# !k $opc_knick"
    return 0
  }
  putserv "kick $chan $opc_knick :$opc_kreason"
  putlog "\-=|$nick|=- \ #($chan)# !k $opc_knick $opc_kreason"
}

bind pub o|o !b pub_ban
proc pub_ban {nick uhost hand chan txt} {
  if {[onchan $txt $chan]} {
    set opc_uhost [getchanhost $txt $chan]
    set opc_tmask "*!*[string trimleft [maskhost $opc_uhost] *!]"
    set opc_bmask "*!*[string trimleft $opc_tmask *!]"
    putserv "mode $chan +b $opc_bmask"
    putlog "\-=|$nick|=- \ #($chan)# !b $opc_bmask"
    return 0
  }
  putserv "mode $chan +b $txt"
  putlog "\-=|$nick|=- \ #($chan)# !b $txt"
}

bind pub o|o !kb pub_kickban
proc pub_kickban {nick uhost hand chan txt} {
  set opc_knick [lindex $txt 0]
  set opc_kreason [lrange $txt 1 end]
  if {![onchan $opc_knick $chan]} {
    putserv "notice $nick :$opc_knick is not on $chan"
    putlog "\-=|$nick|=- \ #($chan)# failed !kb $opc_knick"
    return 0
  }
  if {$opc_kreason == ""} {
    set opc_uhost [getchanhost $opc_knick $chan]
    set opc_tmask "*!*[string trimleft [maskhost $opc_uhost] *!]"
    set opc_bmask "*!*[string trimleft $opc_tmask *!]"
    putserv "mode $chan +b $opc_bmask"
    putserv "kick $chan $opc_knick :Requested by $nick"
    putlog "\-=|$nick|=- \ #($chan)# !kb $opc_knick"
    return 0
  }
  set opc_uhost [getchanhost $opc_knick $chan]
  set opc_tmask "*!*[string trimleft [maskhost $opc_uhost] *!]"
  set opc_bmask "*!*[string trimleft $opc_tmask *!]"
  putserv "mode $chan +b $opc_bmask"
  putserv "kick $chan $opc_knick :$opc_kreason"
  putlog "\-=|$nick|=- \ #($chan)# !kb $opc_knick $opc_kreason"
}

bind pub o|o !+ban pub_+ban
proc pub_+ban {nick uhost hand chan txt} {
  set opc_bmask [lindex $txt 0]
  set opc_breason [lrange $txt 1 end]
  if {$opc_breason == ""} {
    newban $opc_bmask $hand "Requested by $nick ($hand)"
    putserv "notice $nick :Added $opc_bmask to bot bans list"
    putlog "\-=|$nick|=- \ #($chan)# !+ban $opc_bmask"
    return 0
  }
  newban $opc_bmask $hand $opc_breason
  putserv "notice $nick :Added $opc_bmask to bot bans list with reason $opc_breason"
  putlog "\-=|$nick|=- \ #($chan)# !+ban $opc_bmask $opc_breason"
}

bind pub o|o !-ban pub_-ban
proc pub_-ban {nick uhost hand chan txt} {
  putserv "notice $nick :Removing $txt from bot global ban list..."
  killban $txt
  putlog "\-=|$nick|=- \ #($chan)# !-ban $txt"
}

bind pub o|o !bans pub_bans
proc pub_bans {nick uhost hand chan txt} {
  putlog "\-=|$nick|=- \ #($chan)# !bans"
  putserv "notice $nick :Listing bans..."
  foreach opc_tmpban [banlist] {
    putserv "notice $nick :$opc_tmpban"
  }
  putserv "notice $nick :End of bans list"
}

bind pub o|o !ub pub_unban
proc pub_unban {nick uhost hand chan txt} {
  putserv "MODE $chan -b $txt"
  putlog "\-=|$nick|=- \ #($chan)# !ub $txt"
}

#Master section

bind pub m !+user pub_+user
proc pub_+user {nick uhost hand chan txt} {
  global botnick admin
  if {[llength $txt] < 0} {
    putserv "notice $nick :Error! Syntax: !+user <nick> [hostmask]"
    putlog "\-=|$nick|=- \ #($chan)# failed !+user $txt"
    return 0
  }
  set opc_anick [lindex $txt 0]
  set opc_ahost [lindex $txt 1]
  if {$opc_ahost == ""} {
    adduser $opc_anick $opc_anick!*@*
    setuser $opc_anick xtra Added "by $hand as $opc_anick ([strftime %Y-%m-%d@%H:%M])"
    putserv "notice $nick :Added $opc_anick with hostmask $opc_anick!*@* with flags +hp"
    chattr $opc_anick +hp
    putlog "\-=|$nick|=- \ #($chan)# !+user $opc_anick"
  }    
  if {$opc_ahost != ""} {
    adduser $opc_anick $opc_ahost
    setuser $opc_anick xtra Added "by $hand as $opc_anick ([strftime %Y-%m-%d@%H:%M])"
    putserv "notice $nick :Added $opc_anick with hostmask $opc_ahost with flags +hp"
    chattr $opc_anick +hp
    putlog "\-=|$nick|=- \ #($chan)# !+user $opc_anick $opc_ahost"
  }
  putserv "notice $opc_anick :Your account has been added here by $hand"
  putserv "notice $opc_anick :Type /msg $botnick PASS <yourpass> to set your password."
  putserv "notice $opc_anick :After you have set your password, type /dcc chat $botnick to start a dcc chat session."
  putserv "notice $opc_anick :If you have any problems, please contact $admin"
}

bind pub m !-user pub_-user
proc pub_-user {nick uhost hand chan txt} {
  if {[llength $txt] < 0} {
    putserv "notice $nick :Error! Syntax: !-user <handle>"
    putlog "\-=|$nick|=- \ #($chan)# failed !-user"
    return 0
  }
  set opc_anick [lindex $txt 0]
  set opc_err [deluser $opc_anick]
  if {$opc_err == 0} {
    putserv "notice $nick :Failed removing $opc_anick ."
    putlog "\-=|$nick|=- \ #($chan)# failed !-user $opc_anick"
    return 0
  }
  putserv "notice $nick :Removed $opc_anick successfull!"
  putlog "\-=|$nick|=- \ #($chan)# !-user $opc_anick"
}

bind pub n !chattr pub_chattr
proc pub_chattr {nick uhost hand chan txt} {
  set opc_auser [lindex $txt 0]
  set opc_aflags [lindex $txt 1]
  set opc_err [validuser $opc_auser]
  if {!$opc_err} { 
    putserv "notice $nick :Error: User $opc_auser was not found on my userlist"
    putlog "\-=|$nick|=- \ #($chan)# failed !chattr $opc_auser"
    return 0 
  }
  chattr $opc_auser $opc_aflags
  putserv "notice $nick :Global flags for $opc_auser are now: [chattr $opc_auser]"
  putlog "\-=|$nick|=- \ #($chan)# !chattr $opc_auser $opc_aflags"
}

bind pub o|o !ma pub_match
proc pub_match {nick uhost hand chan txt} {
  if {![validuser $txt]} {
    putserv "notice $nick :User $txt was not found on my userlist"
    putlog "\-=|$nick|=- \ #($chan)# failed !ma $txt"
    return 0
  }
  putserv "notice $nick: -=| Matching $txt |=-"
  putserv "notice $nick: \Handle\: [getuser $txt handle]"
  putserv "notice $nick: \Flags\: [chattr $txt]"
  putserv "notice $nick: \Hosts\: [getuser $txt hosts]"
  if {[getuser $txt PASS] != ""} { putserv "notice $nick: Pass: yes" }
  putserv "notice $nick: \Added\: [getuser $txt xtra added]"
  putserv "notice $nick: \Info\: [getuser $txt info]"
  putserv "notice $nick: \Comment\: [getuser $txt comment]"
  putserv "notice $nick: \LastSeen\: [getuser $txt laston]" 
  putserv "notice $nick: -=| Found 1 matches |=-"
  putlog "\-=|$nick|=- \ #($chan)# !ma $txt"
}

bind pub - !time pub_time
proc pub_time {nick uhost hand chan txt} {
  putserv "notice $nick :[ctime [unixtime]]"
  putlog "\-=|$nick|=- \ #($chan)# !time"
}

bind pub n !rehash pub_rehash
proc pub_rehash {nick uhost hand chan txt} {
  putserv "notice $nick :Rehashing..."
  putlog "\-=|$nick|=- \ #($chan)# !rehash"
  rehash
}

bind pub n !restart pub_restart
proc pub_restart {nick uhost hand chan txt} {
  putserv "notice $nick :Restarting..."
  putlog "\-=|$nick|=- \ #($chan)# !restart"
  restart
}

bind pub m !sav pub_save
proc pub_save {nick uhost hand chan txt} {
  putserv "notice $nick :Saving channel file and user file..."
  putlog "\-=|$nick|=- \ #($chan)# !sav"
  save
}

bind pub o|o !stat pub_status
proc pub_status {nick uhost hand chan txt} {
  global server botname version
  putlog "\-=|$nick|=- \ #($chan)# !stat"
  putserv "notice $nick :\002Bot statistics:\002" 
  putserv "notice $nick :User records: [countusers]"
  putserv "notice $nick :My channels: [channels]"
  putserv "notice $nick :Linked bots: [bots]"
  putserv "notice $nick :My date: [date]"
  putserv "notice $nick :My time: [time]"
  putserv "notice $nick :My operating system: [unames]"
  putserv "notice $nick :Server: $server"
  putserv "notice $nick :My host: $botname"
  putserv "notice $nick :Eggdrop version: [lindex $version 0]"
}

bind pub n !+chan pub_+chan
proc pub_+chan {nick uhost hand chan txt} {
  if {[validchan $txt] == 1} {
    putserv "notice $nick :This channel already exists!"
    putlog "\-=|$nick|=- \ #($chan)# failed !+chan $txt"
    return 0
  }
  channel add $txt {+greet -bitch -autoop -bitch -stopnethack -revenge +shared +dontkickops}
  putserv "notice $nick :Added channel $txt ...joining"
  putlog "\-=|$nick|=- \ #($chan)# !+chan $txt"
}

bind pub n !-chan pub_-chan
proc pub_-chan {nick uhost hand chan txt} {
  if {[validchan $txt] == 0} {
    putserv "notice $nick :The channel $txt is not on my channels list"
    putlog "\-=|$nick|=- \ #($chan)# failed !-chan $txt"
    return 0
  }
  channel remove $chan
  putserv "notice $nick :Channel $txt removed from channels list"
  putlog "\-=|$nick|=- \ #($chan)# !-chan $txt"
}

bind pub n !chanset pub_chanset
proc pub_chanset {nick uhost hand chan txt} {
  channel set $chan $txt
  putserv "notice $nick :Options for channel $chan has been changed ($txt)"
  putlog "\-=|$nick|=- \ #($chan)# !chanset $chan $txt"
}

bind pub m !+bot pub_+bot
proc pub_+bot {nick uhost hand chan txt} {
  set opc_bothand [lindex $txt 0]
  set opc_bothost [lindex $txt 1]
  if {[llenght $txt] < 1} { 
    putserv "notice $nick :Error! Syntax: !+bot <handle> <address:port>"
    putlog "\-=|$nick|=- \ #($chan)# failed !+bot $txt"
    return 0
  }
  if {[llength [split [lindex $txt 1] ":"]]!=2} {
    notice $nick "Usage: !+bot <handle> <address:port>"
    putlog "\-=|$nick|=- \ #($chan)# failed !+bot $txt"
    return 0
  }
  set opc_err [addbot $opc_bothand $opc_bothost]
  if {$opc_err == 0} {
    putserv "notice $nick :This bot already exists!"
    putlog "\-=|$nick|=- \ #($chan)# failed !+bot $opc_bothand $opc_bothost"
    return 0
  }
  putserv "notice $nick :Added $opc_bothand with address:port $opc_bothost"
  putlog "\-=|$nick|=- \ #($chan)# !+bot $txt"
}

bind pub m !-bot pub_-bot
proc pub_-bot {nick uhost hand chan txt} {
  if {[islinked $txt]} {
    unlink $txt
    putserv "notice $nick :Unlinked $txt..."
  }
  deluser $txt
  putserv "notice $nick :Removed $txt from botlist"
  putlog "\-=|$nick|=- \ #($chan)# !-bot $txt"
}

bind pub m !link pub_link
proc pub_link {nick uhost hand chan txt} {
  set opc_err [link $txt]
  putserv "notice $nick :Trying to link to $txt..."
  if {!opc_err == 0} {
    putserv "notice $nick :Error! Can't link to $txt"
    putlog "\-=|$nick|=- \ #($chan)# failed !link $txt"
    return 0
  }
  if {opc_err == 1} { 
    putserv "notice $nick :Linked to $txt successfull!" 
    putlog "\-=|$nick|=- \ #($chan)# !link $txt"
  }
}

bind pub m !unlink pub_unlink
proc pub_unlink {nick uhost hand chan txt} {
  set opc_err [unlink $txt]
  putserv "notice $nick :Trying to unlink from $txt..."
  if {$opc_err == 0} { 
    putserv "notice $nick :Error! Can't unlink from $txt"
    putlog "\-=|$nick|=- \ #($chan)# failed !unlink $txt"
  }
  if {$opc_err == 1} { 
    putserv "notice $nick :Unlinked from $txt successfull!"
    putlog "\-=|$nick|=- \ #($chan)# !unlink $txt"
  }
}

bind pub m !+host pub_+host
proc pub_+host {nick uhost hand chan txt} {
  set opc_user [lindex $txt 0]
  set opc_host [lindex $txt 1]
  if {$opc_host == ""} {
    setuser $hand HOSTS $opc_host
    putserv "notice $nick :Added $opc_user to your hosts list."
    putlog "\-=|$nick|=- \ #($chan)# !+host $opc_user"
    return 0
  }
  if {![validuser $opc_user]} {
    putserv "notice $nick :Error! User $opc_user doesn't exists"
    putlog "\-=|$nick|=- \ #($chan)# failed !+host $opc_user $opc_host"
    return 0
  }
  setuser $opc_user HOSTS $opc_host
  putserv "notice $nick :Added $opc_host to $opc_user hosts"
  putlog "\-=|$nick|=- \ #($chan)# !+host $opc_user $opc_host"
}

bind pub m !-host pub_-host
proc pub_-host {nick uhost hand chan txt} {
  set opc_user [lindex $txt 0]
  set opc_host [lindex $txt 1]
  if {$opc_host == ""} {
    delhost $hand $opc_host
    putserv "notice $nick :Removed $opc_user from your hosts."
    putlog "\-=|$nick|=- \ #($chan)# !-host $opc_user"
    return 0
  }
  if {![validuser $opc_user]} {
    putserv "notice $nick :Error! User $opc_user doesn't exists"
    putlog "\-=|$nick|=- \ #($chan)# failed !-host $opc_user $opc_host"
    return 0
  }
  delhost $opc_user $opc_host
  putserv "notice $nick :Removed $opc_host from $opc_user hosts"
  putlog "\-=|$nick|=- \ #($chan)# !-host $opc_user $opc_host"
}

bind pub m !cb pub_clearbans
proc pub_clearbans {nick uhost hand chan txt} {
  putserv "notice $nick :Reseting bans on $chan..."
  putlog "\-=|$nick|=- \ #($chan)# !cb"
  resetbans $chan
}

bind pub p !bots pub_bots
proc pub_bots {nick uhost hand chan txt} {
  putlog "\-=|$nick|=- \ #($chan)# !bots"
  putserv "notice $nick :Bots: [bots]"
}

bind pub m !+ignore pub_+ignore
proc pub_+ignore {nick uhost hand chan txt} {
  set opc_ihost [lindex $txt 0]
  newignore $opc_ihost $hand Lame!
  putserv "notice $nick :Added $opc_ihost to ignorelist"
  putlog "\-=|$nick|=- \ #($chan)# !+ignore $opc_ihost"
}

bind pub m !-ignore pub_-ignore
proc pub_-ignore {nick uhost hand chan txt} {
  if {![isignore $txt]} {
    putserv "notice $nick :The hostmask $txt doesn't exists in my ignores"
    putlog "\-=|$nick|=- \ #($chan)# failed !-ignore $txt"
    return 0
  }
  killignore $txt
  putserv "notice $nick :Removed $txt from ignorelist"
  putlog "\-=|$nick|=- \ #($chan)# !-ignore $txt"
}

bind pub m !ignores pub_ignores
proc pub_ignores {nick uhost hand chan txt} {
  putlog "\-=|$nick|=- \ #($chan)# !ignores"
  putserv "notice $nick :Listing ignores..."
  foreach opc_lig [ignorelist] {
    putserv "notice $nick $opc_lig"
  }
  putserv "notice $nick :End of ignores."
}

bind pub m !mode pub_mode
proc pub_mode {nick uhost hand chan txt} {
  putserv "mode $chan $txt"
  putlog "\-=|$nick|=- \ #($chan)# !mode $txt"
}

bind pub p !topic pub_topic
proc pub_topic {nick uhost hand chan txt} {
  putserv "topic $chan :$txt"
  putlog "\-=|$nick|=- \ #($chan)# !topic $txt"
}

bind pub p !notes pub_notes
proc pub_notes {nick uhost hand chan txt} {
  set opc_cmd [lindex $txt 0]
  if {$opc_cmd == ""} {
    putserv "notice $nick :Error! Syntax: !notes <read/send/del>"
    putlog "\-=|$nick|=- \ #($chan)# failed !notes $txt"
    return 0
  }
  if {$opc_cmd == "read"} {
    if {[notes $hand -] == 0} {
      putserv "notice $nick :You have no messages."
      return 0
    }
    putserv "notice $nick :Listing notes..."
    putlog "\-=|$nick|=- \ #($chan)# !notes read"
    putserv "privmsg $nick :Notes:"
    foreach ntc [notes $hand -] {
      putserv "privmsg $nick :from [lindex $ntc 0] - \[\002[strftime "%b %d %H:%M" [lindex $ntc 1]]\002]\ [lrange $ntc 2 end]"
    }
    putserv "privmsg $nick :End of notes"  
  }
  if {$opc_cmd == "send"} {
    set ntc_to [lindex $txt 1]
    set ntc_text [lrange $txt 2 end]
    if {![validuser $ntc_to]} {
      putserv "notice $nick :Error: $ntc_to does not exists in my userlist"
      putlog "\-=|$nick|=- \ #($chan)# failed !notes send $ntc_to ..."
      return 0
    }
    sendnote $hand $ntc_to $ntc_text
    putserv "notice $nick :Note sent to $ntc_to success!"
    putlog "\-=|$nick|=- \ #($chan)# !notes send $ntc_to ..."
  }
  if {$opc_cmd == "del"} {
    erasenotes $hand -
    putserv "notice $nick :All notes deleted!"
    putlog "\-=|$nick|=- \ #($chan)# !notes del"
  }
}

bind pub o !dns get_dns
proc get_dns {nick uhost hand chan txt} {
  putserv "privmsg $chan :Looking for $txt ..."
  dnslookup $txt look_dns $chan $txt
  putlog "\-=|$nick|=- \ #($chan)# !dns $txt"
}
proc look_dns {ip host status chan lkp} {
  if {$status == 0} {
    putserv "privmsg $chan :Unable to resolve $lkp"
    return 0
  }
  putserv "privmsg $chan :Resolved-> $host - $ip"
}

bind pub m !addop pub_addop
proc pub_addop {nick uhost hand chan usr} {
  global botnick
  adduser $usr $usr!*@*
  chattr $usr +fhop
  setuser $usr xtra Added "by $hand as $usr ([strftime %Y-%m-%d@%H:%M])"
  putserv "notice $usr :You have been added with flags +fhop by $nick ... please set a password by typening: /msg $botnick pass <password>"
  putserv "notice $nick :Added $usr with flags +fhop"
  putlog "\-=|$nick|=- \ #($chan)# !addop $usr"
}

bind pub p !fnote opc_fnote
proc opc_fnote {nick uhost hand chan arg} {
  set to_flag [lindex $arg 0]
  set message [lrange $arg 1 end]
  set sentnotes 0
  if {$to_flag == "" || $message == ""} {
    putserv "notice $nick :Error! syntax: .fnote <flag> <message>"
    return 0
  }
  putserv "notice $nick :Sending notes users with flag $to_flag ..."
  foreach user [userlist] {
    if {![matchattr $user b] && $user != $hand} {
      if {[matchattr $user $to_flag]} {
        sendnote $hand $user "\002($to_flag)\002 $message"
        incr sentnotes
      }
    }
  }
  putserv "notice $nick : $sentnotes notes send to all users with flag $to_flag"
}

bind pub p !help pub_help
proc pub_help {nick uhost hand chan txt} {
  if {[llength $txt]<1} {
    putlog "\-=|$nick|=- \ #($chan)# !help"
    putserv "privmsg $nick :-=|\002 OpControl Help\002|=-"
    putserv "privmsg $nick :!op <nick> - ops \002nick\002"
    putserv "privmsg $nick :!dop <nick> - deops \002nick\002"
    putserv "privmsg $nick :!b <nick/host> - bans a \002nick/host\002"
    putserv "privmsg $nick :!k <nick> \[reason]\ - kicks a \002nick\002"
    putserv "privmsg $nick :!kb <nick> \[reason]\ - kick and bans a \002nick\002"
    putserv "privmsg $nick :!topic <text> - changes the channel topic"
    putserv "privmsg $nick :!ub <host> - unbans \002host\002 from channel"
    putserv "privmsg $nick :!v <nick> - gives \002nick\002 voice"
    putserv "privmsg $nick :!dev <nick> - takes away \002nick\002's voice"
    putserv "privmsg $nick :!opme - ops you if you have access"
    putserv "privmsg $nick :!cb - clears the channels bans"
    putserv "privmsg $nick :!notes <read/send/del> - manage your notes"
    putserv "privmsg $nick :!time - gives you the date and time"
    putserv "privmsg $nick :!stat - gives you some statistics"
    putserv "privmsg $nick :!+ban <hostmask> \[reason]\ - adds global ban on bot"
    putserv "privmsg $nick :!-ban <hostmask> - removes global ban from bot"
    putserv "privmsg $nick :!bans - gives you a banlist for global & channel bans"
    putserv "privmsg $nick :!ma <handle> - matchs a user"
    putserv "privmsg $nick :!+bot <handle> <address:port> - adds a bot"
    putserv "privmsg $nick :!-bot <handle> - removes a bot"
    putserv "privmsg $nick :!bots - lists the bots linked on the botnet"
    putserv "privmsg $nick :!link <bot> - attempts to link to \002bot\002"
    putserv "privmsg $nick :!unlink <bot> - attempts to unlink from \002bot\002"
    putserv "privmsg $nick :!mode <mode change> - changes a mode setting on the channel"
    putserv "privmsg $nick :!+user <handle/nick> \[host\] - adds a user"
    putserv "privmsg $nick :!-user <handle> - removes \002handle\002 from user list"
    putserv "privmsg $nick :!addop <nick> - adds a user with global flags +fhop...simple to use"
    putserv "privmsg $nick :!+host <handle> <host> - adds a host to a user"
    putserv "privmsg $nick :!-host <handle> <host> - removes a host from a user"
    putserv "privmsg $nick :!chattr <handle> <options> - changes attributes for user"
    putserv "privmsg $nick :!+chan <#channel> - makes the bot join a channel"
    putserv "privmsg $nick :!-chan <#channel> - makes the bot leave the channel"
    putserv "privmsg $nick :!chanset <mode> \[args\] - changes the active channel setting"
    putserv "privmsg $nick :!+ignore <hostmask> - adds a new ignore"
    putserv "privmsg $nick :!-ignore <hostmask> - removes an ignore"
    putserv "privmsg $nick :!ignores - gives you a list of ignores"
    putserv "privmsg $nick :!rehash - rehashes the bot"
    putserv "privmsg $nick :!restart - restarts the bot"
    putserv "privmsg $nick :!sav - saves the userfile and channel file"
    putserv "privmsg $nick :!dns <address> - dns lookup"
    putserv "privmsg $nick :!fnote <flags> <message> - FlagNote to users with flags"
    putserv "privmsg $nick :-=|\002 End of OpControl Help \002|=-"
    putserv "privmsg $nick :TCL: OpControl.tcl created by ShakE (\shake@abv.bg\)"
    putserv "notice $nick :Get more cool tcl's from http://shake.hit.bg"
    return 0
  }
  putserv "notice $nick :You're lame! What this !help is not enough for you?!"
  putlog "\-=|$nick|=- \ #($chan)# failed !help $txt"
}
putlog "OpControl.tcl by ShakE - get more tcl from http://shake.hit.bg"
