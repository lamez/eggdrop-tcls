##########################################################################
# fun-text.tcl by ShakE <shake@abv.bg>		                         #
##########################################################################
# zna4i tova kara bota da otgovarq pri text !sex ... abe nai hubavo	 #
# napi6i v kanala !fun i bota 6te ti izkara help za komandite na tozi tcl#
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://tcl-bg.com i pi6ete tam!                                        #
##########################################################################


bind pub - !sex fun_give-sex
bind pub - !bira fun_give-bira
bind pub - !love fun_give-love
bind pub - !fun fun_give-fun

proc fun_give-sex {nick uhost hand chan text} {
 putserv "privmsg $chan :hey $text ... $nick ti predlaga dosta izgodno predlojenie za...zdrav div razdira6t SEX!"
}

proc fun_give-bira {nick uhost hand chan text} {
 putserv "privmsg $chan :ei shhh $text ...da ti zamirisa na biri4ka tuka...az gledam $nick darji v rukata si edna zagorka i ti q podava. Ako nema da q vzema6 dai q nasam!"
}

proc fun_give-love {nick uhost hand chan text} {
 putserv "privmsg $chan :mmm ei $text iskam samo da ti kaja 4e $nick e mnogo mnogo vluben v teb...mai 6a ima svadbaaaa :)"
}

proc fun_give-fun {nick uhost hand chan text} {
 putserv "privmsg $chan :Predlagam na vsi4ki da se pozabavlqvat s moq nov tcl napisan ot ShakE"
 putserv "privmsg $chan :Komandite sa slednite:"
 putserv "privmsg $chan :!sex <nick> , !bira <nick> , !love <nick>"
 putserv "privmsg $chan :Skoro o4akvaite novata versia na tozi tcl...mojete da q namerite na http://shake.hit.bg"
}

putlog "fun-text.tcl v1.0 by ShakE loaded!"