##########################################################################
# voting.tcl by ShakE <shake@abv.bg>		                         #
##########################################################################
# Sistema za glasuvane. Mojete da predlagate kakvoto jelaete za glasuvane#
# Moje da ima samo 1 tema za glasuvane!	Komandite sa:			 #
#.startvote <tema> - Startirane na nova tema za glasuvane (spira starata)#
#.endvote - Spirate glasuvaneto v momenta				 #
#.vote - Glasuvate za temata koqto se glasuva v momenta			 #
#.votes - Pokazva broq na glasuvalite useri i temata na glasuvane	 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################
###################### Ottuk nadolu ne butaite nishto! ###################

bind dcc o vote vt_vote
proc vt_vote {hand idx txt} {
 global vt_for curentvotes
 if {$vt_for == ""} {
  putdcc $idx "Voting: There is no topic to vote!"
  return 0
 }
 if {[matchattr $hand V]} {
  putdcc $idx "Voting: You have already voted!"
  return 0
 }
 incr curentvotes
 putdcc $idx "Voting: You have voted for:\002 $vt_for \002"
 chattr $hand +V
}

bind dcc m startvote vt_startvote
proc vt_startvote {hand idx txt} {
 global vt_for curentvotes
 if {$vt_for != ""} {
  putdcc $idx "Voting: There is already started vote!"
  putdcc $idx "Voting: voted users($curentvotes) , Topic($vt_for)"
  putdcc $idx "Voting: to stop the curent voting type: .endvote"
  return 0
 }
 if {[lindex $txt 1] == ""} {
  putdcc $idx "Voting: Syntax error! Type- .startvote <topic for voting>"
  return 0
 }
 foreach vuser [userlist V] {
  chattr $vuser -V
 }
 putdcc $idx "Voting: started new voting - ($vt_for)"
 putlog "Voting: ($vt_for) voting stoped!"
 putlog "Voting: Current Votes($curentvotes)"
 putlog "Voting: new voting started by $hand !"
 putlog "Voting: voting for ($vt_for)"
 set vt_for [lrange $txt 1 end]
 set curentvotes 1
}

bind dcc o votes vt_votes
proc vt_votes {hand idx $txt} {
 global vt_for curentvotes
 if {$vt_for == ""} {
  putdcc $idx "Voting: there is no topic for voting!"
  return 0
 }
 putdcc $idx "Voting: current voted users($curentvotes)"
 putdcc $idx "Voting: vote topic ($vt_for)"
}

bind dcc m endvote vt_endvote
proc vt_endvote {hand idx txt} {
 global vt_for curentvotes
 if {$vt_for != ""} {
  putdcc $idx "Voting: there is no voting to stop!"
  return 0
 }
 putlog "Voting: ($vt_for) voting stoped!"
 putlog "Voting: Current Votes($curentvotes)"
 set vt_for ""
 set curentvotes 0
}
putlog "voting.tcl by ShakE (more tcls at http://shake.hit.bg)"