##########################################################################
# shell.tcl by ShakE <shake@abv.bg>		                         #
##########################################################################
# Mojete da podavate komandi na shella direktno ot DCC s komandata:      #
# .sh <shell komanda>							 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################
###################### Ottuk nadolu ne butaite nishto! ###################

bind dcc n sh shell
proc shell {hand idx txt} {
 exec "$txt"
}
putlog "shell.tcl by ShakE (more tcls at http://shake.hit.bg)"
