############################################################
#                                                          #
#  DENIED-msg.tcl by maniac                                #
#                                                          #
############################################################
#                                                          #
#  Tozi Script zabranqva  ispolzvaneto na komandata .msg   #
#  za vischki s izkluchenie na tezi s flag +n,kato te      # 
#  mogat da  prastat .msg kum  drugi  useri ili .msg kum   #
#  #kanal,a za prastaneto na .msg  kum cs i  ns  osven     # 
#  flag +n e nuzno i da e addnat nicka na ownera (nai      # 
#   chesto admina na bota:) v tozi script po dolu          # 
#                                                          #
############################################################

unbind dcc o|o msg *dcc:msg
bind dcc o|o msg denied:msg
  proc denied:msg {hand idx arg} {   
       set msg [string tolower [lindex $arg 0]]
       set text [lrange $arg 1 end]
          if {[matchattr $hand n]} {
          if {$msg=="ns" || $msg=="cs" } { 

###########################################################
#    Tuk ADMINA na bota trqq si slozi nicka za da         #
#          moze da prashta .msg kum CS i NS               #
###########################################################
                          #
                          #
                        #####
                         ###
                          #

          if {$hand=="ShakE" } {
              putserv "PRIVMSG $msg :$text"
              putdcc $idx "msg to $msg: $text"
         } else {
              putdcc $idx "-=Access Denied=-"
         }
         } else {
              putserv "PRIVMSG $msg :$text "
              putdcc $idx "msg to $msg: $text"
         }
         } else {
              putdcc $idx "-=Access Denied=-"


}
}
putlog "Denied.tcl loaded *** http://shake.hit.bg ***"


