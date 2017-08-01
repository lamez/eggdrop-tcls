##########################################################################
# idle-deop.tcl by ShakE <shake@abv.bg>		                         #
##########################################################################
# Tozi tcl kick/ban useri koito kajat znacite *#* *www* *http* v kanala	 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################

#Kolko minuten da byde ban-a
set invkb_bantime "10"

###################### Ottuk nadolu ne butaite nishto! ###################

bind pubm - *#* invkb
bind pubm - *www* invkb
bind pubm - *http:* invkb
bind notc - *#* invkb
bind notc - *www* invkb
bind notc - *http:* invkb

proc invkb {nick uhost hand chan txt} {
 global botnick
 if {![matchattr $hand o] || ![matchattr $hand b]} {
  set invkb_tmask "*!*[string trimleft [maskhost $uhost] *!]"
  set invkb_bmask "*!*[string trimleft $banmask *!]"
  newchanban $chan $invkb_bmask $botnick "InviterZ 0uT!" $invkb_bantime
  putserv "mode $chan +b $invkb_bmask"
  putserv "kick $chan $nick :InviterZ 0uT!"
  putlog "\002Invite detected from $nick!\002"
 }
}
putlog "invkb.tcl by ShakE - http://shake.hit.bg" 