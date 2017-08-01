##########################################################################
# shituser.tcl by ShakE <shake@abv.bg>		                         #
##########################################################################
# Mojete da addvate useri v neshto kato shitlist (autokick) 		 #
# !addshit <nick> <reason> , !delshit <nick> , !shitlist		 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################
###################### Ottuk nadolu ne butaite nishto! ###################

bind pub m !addshit addshit
proc addshit {nick uhost hand chan txt} {
 set shitnick [lindex $txt 0]
 set shitreason [lrange $txt 1 end]
 newban $shitnick $hand "$shitreason"
 adduser $shitnick $shitnick!*@*
 chattr $shitnick +dk
 setuser $shitnick pass blaa[rand 99999]
 setuser $shitnick comment "$shitreason"
 setuser $shitnick XTRA Added "by $hand as $shitnick"
 putserv "notice $nick :Added $shitnick to the shitlist with reason: $shitreason"
}
bind pub m !delshit delshit
proc delshit {nick uhost hand chan txt} {
 if {![matchattr $txt k]} {
  putserv "notice $nick :User $txt doesn't exists in my shitlist"
  return 0
 }
 deluser $txt
 killban $txt!*@*
 putserv "notice $nick :Removed $txt from my shitlist"
}
bind pub m !shitlist shitlist
proc shitlist {nick uhost hand chan txt} {
 putserv "notice $nick :Listing shits..."
 foreach ushit [userlist dk] {
  putserv "notice $nick :$ushit ([getuser $ushit comment]) - [getuser $ushit xtra Added]"
 }
 putserv "notice $nick :End of shitlist"
}
####
bind msg m !addshit addshitp
proc addshitp {nick uhost hand txt} {
 set shitnick [lindex $txt 0]
 set shitreason [lrange $txt 1 end]
 newban $shitnick $hand "$shitreason"
 adduser $shitnick $shitnick!*@*
 chattr $shitnick +dk
 setuser $shitnick pass blaa[rand 99999]
 setuser $shitnick comment "$shitreason"
 setuser $shitnick XTRA Added "by $hand as $shitnick"
 putserv "notice $nick :Added $shitnick to the shitlist with reason: $shitreason"
}
bind msg m !delshit delshitp
proc delshitp {nick uhost hand txt} {
 if {![matchattr $txt k]} {
  putserv "notice $nick :User $txt doesn't exists in my shitlist"
  return 0
 }
 deluser $txt
 killban $txt!*@*
 putserv "notice $nick :Removed $txt from my shitlist"
}
bind msg m !shitlist shitlistp
proc shitlistp {nick uhost hand txt} {
 putserv "notice $nick :Listing shits..."
 foreach ushit [userlist dk] {
  putserv "notice $nick :$ushit ([getuser $ushit comment]) - [getuser $ushit xtra Added]"
 }
 putserv "notice $nick :End of shitlist"
}
######
bind dcc m addshit addshitd
proc addshitd {hand idx txt} {
 set shitnick [lindex $txt 0]
 set shitreason [lrange $txt 1 end]
 newban $shitnick $hand "$shitreason"
 adduser $shitnick $shitnick!*@*
 chattr $shitnick +dk
 setuser $shitnick pass blaa[rand 99999]
 setuser $shitnick comment "$shitreason"
 setuser $shitnick XTRA Added "by $hand as $shitnick"
 putdcc $idx "Added $shitnick to the shitlist with reason: $shitreason"
}
bind dcc m delshit delshitd
proc delshitd {hand idx txt} {
 if {![matchattr $txt k]} {
 putdcc $idx "User $txt doesn't exists in my shitlist"
  return 0
 }
 deluser $txt
 killban $txt!*@*
 putserv "notice $nick :Removed $txt from my shitlist"
}
bind dcc m shitlist shitlistd
proc shitlistd {hand idx txt} {
 putdcc $idx "Listing shits..."
 foreach ushit [userlist dk] {
  putdcc $idx "$ushit ([getuser $ushit comment]) - [getuser $ushit xtra Added]"
 }
 putdcc $idx "End of shitlist"
}
putlog "shituser.tcl by ShakE (more tcls at http://shake.hit.bg)"