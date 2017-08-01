##########################################################################
# voteop.tcl by ShakE <shake@abv.bg>		                         #
##########################################################################
# V dosta kanali ima pravilo da se glasuva parvo predi da se addne user  #
# S tozi tcl tova stava avtomati4no za addvane na +fhop...komandite sa:  #
# .addvoteop <nick> <komentar> - Da predlojite user za glasuvane	 #
# .voteop <nick> - Da glasuvate za user					 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################

#Kolko usera trqbva da sa glasuvali za da se addne usera
set howusers 5

###################### Ottuk nadolu ne butaite nishto! ###################

bind dcc m addvoteop addvoteop
proc addvoteop {hand idx txt} {
 set uhand [lindex $txt 0]
 set ucomment [lrange $txt 1 end]
 if {[validuser $uhand]} {
  putdcc $idx "This user already exists!"
  return 0
 }
 adduser $uhand $uhand!*@*
 setuser $uhand COMMENT $ucomment
 setuser $uhand PASS votedoper
 setuser $uhand XTRA Added "voted by $hand (Not Added!)"
 setuser $uhand XTRA Votes $hand
 putlog "Voting Oper: by $hand as $uhand ($ucomment)"
}

bind dcc m voteop voteop
proc voteop {hand idx txt} {
 global howusers
 set tmpvts 0
 if {![validuser $uhand]} {
  putdcc $idx "This user doesn't exists!"
  return 0
 }
 foreach votez [getuser $txt XTRA Votes] {
  incr tmpvts
  if {$votez == $hand} {
   putdcc $idx "You already voted for $txt !!!"
   return 0
  }
 }
 if {$tmpvts == 0} {
  putdcc $idx "User $txt is already a valid oper!"
 }
 set tmpvu "[getuser $txt XTRA Votes] $hand"
 putdcc $idx "Voting for $txt for oper...Done!"
 if {$tmpvts == $howusers} {
  putlog "User $hand has been accepted for oper! Adding user with flags \002+fhop\002 ...Done!"
  setuser $txt XTRA Added "with voting by bot masters/owners"
  chattr $txt +fhop
  setuser $txt XTRA Votes ""
  setuser $txt PASS ""
 }
}
putlog "voteop.tcl by ShakE (more tcls at http://shake.hit.bg)"