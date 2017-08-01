##########################################################################
# SpamKicker/Checker Bot v2.0 by ShakE <shake@vip.bg>			 #
##########################################################################
# Tozi tcl se slaga na botovete koito sa link s SpamChecker bota, za da  #
# mogat da kick/ban invitera						 #
# Mojete da si naglasite banmask-a...po kakvo da banva			 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################

########## Nastroiki ###########

#Kolko vreme da stoi ban-a (v minuti)
set ban_time "60"

#flaga na userite koito bota nqma da ban/kick za invite
set exflag "o"

#tova e tiput ban koito 6te slaga bota
#[0/1/2 - *!*ident@*.host.com/*!*@bla.host.com/nick!*@*]
set bantype 0

## Ottuk nadolu ne butai ni6to!!! ##
#########################################################################################

bind bot - kb kbspam

proc kbspam {botnc kb inviter} {
 global kb_reason ban_time bantype exflag
 set nick [lindex $inviter 0]
 set uhost [lindex $inviter 1]
 set nickhand [nick2hand $nick]
 if {$bantype == 0} {
  set banmask "*!*[string trimleft [maskhost $uhost] *!]"
  set bmask "*!*[string trimleft $banmask *!]"
 }
 if {$bantype == 1} {
  set tmpbn [split $uhost @]
  set bmask "*!*@[lindex $tmpbn 1]"
 }
 if {$bantype == 2} {
  set bmask $nick!*@*
 }
 if {![matchattr $botnc Z]} {
  return 0
 }
 if {[matchattr $nickhand $exflag] || [matchattr $nickhand b]} {
  putlog "Spammer detected <<|$botnc|>>-> $nick ($bmask) <this is a bot user!>" 
  return 0
 }
 putlog "Spammer detected <<|$botnc|>>-> $nick ($bmask)" 
 putlog "Ban/Kicking $nick ($bmask) from channels..."
 foreach chan [channels] {
  newchanban $chan $bmask $botnc "$nick ($bmask) is a spammer" $ban_time
 }
}

putlog "SpamKicker.tcl by ShakE loaded"
putlog "Waiting for messages from SpamChecker..."
