############################################################################################
# Copyright #													##
#############												      ##
#															##
# Please do not change the copyright with any of the following:					##
#															##
# * Change/remove the putlog output										##
# * Dont change/remove the " reklam3r " in kick reason ($why)					 	##
# * Change/remove author name/email + other								##
# * Change/remove notice feedback										##
# * Change/remove logo												##
# * Give me the fucking credits! :)									      ##
#															##
# Are you going to change any of the following, mail mae@east.no and ask FIRST!           ##
#															##
#                                                         Mosse/iSP			      ##
############################################################################################
# MSG Commands #													##
################													##
#  															##
# /msg botnick inviteset <on/off>  # Turns the script on/off!					##
# /msg botnick invitebanset <ban duration in minutes>  # Sets the bantime in minutes!     ##
# /msg botnick invitebanset default  # Sets default bantime: 1 minute                     ##
# /msg botnick exchan <1-15> <#channel>	# The script will not be active on the channels	##
#                                           you set with this command :)			##
#															##
# /msg botnick invitekickandban <on/off>  # Sets kick and ban on/off!                     ##
#															##
############################################################################################
# DCC Commands #												 	##
################												      ##
#															##
# .inviteset <on/off>  # Turns the script on/off!							##
# .invitebanset <ban duration in minutes>  # Sets the bantime in minutes!			##
# .invitebanset default  # Sets default bantime: 1 minute						##
# .exchan <1-15> <#channel>  # The script will not be active on the channels you set	##
#					  with this command :)							##
#															##
# .invitekickandban <on/off>  # Sets kick and ban on/off!						##
############################################################################################



##########################
# Settings... ############
##########################

# Set Script On (1) or Off (0)

set inviteonoff 1

# Set kick ban time in minutes

set invitekickbantime 10

# Set Kick & Ban On (1) or Off (0)

set kickandban 1

# Exclude channels you dont want to use the script on (if you don't want to exclude any channels. Leave them at what they are eg. #channel1)

set exchan1 #channel1

set exchan2 #channel2

set exchan3 #channel3

set exchan4 #channel4

set exchan5 #channel5

set exchan6 #channel6

set exchan7 #channel7

set exchan8 #channel8

set exchan9 #channel9

set exchan10 #channel0

set exchan11 #channel1

set exchan12 #channel2

set exchan13 #channel3

set exchan14 #channel4

set exchan15 #channel5




###############################
# Dont edit anything here #####
###############################


############################################################
# This section will ban if you set $kickandban to 1.... ####
############################################################

bind pubm - * invite_check

proc invite_check {nick userhost hand chan things} {
  global inviteonoff
  global invitechar
  global invitekickbantime
  global kickandban
  global exchan1
  global exchan2
  global exchan3
  global exchan4
  global exchan5
  global exchan6
  global exchan7
  global exchan8
  global exchan9
  global exchan10
  global exchan11
  global exchan12
  global exchan13
  global exchan14
  global exchan15
  set who "Auto-Set"
  set why "reklam3r Detected. Banned for $invitekickbantime min(s)!"


set userhost [maskhost $userhost]
regsub {\*!} $userhost \*!\* ban


if {$inviteonoff == 0} {return 0}
  set invitechar #
  if {$inviteonoff == 1} {
    if {[string match "*$invitechar*" $things]} {
     if {![botisop $chan]} {return 0}
      if {$chan == $exchan1} {return 0}
	if {$chan == $exchan2} {return 0}
	if {$chan == $exchan3} {return 0}
	if {$chan == $exchan4} {return 0}
	if {$chan == $exchan5} {return 0}
	if {$chan == $exchan6} {return 0}
	if {$chan == $exchan7} {return 0}
	if {$chan == $exchan8} {return 0}
	if {$chan == $exchan9} {return 0}
	if {$chan == $exchan10} {return 0}
	if {$chan == $exchan11} {return 0}
	if {$chan == $exchan12} {return 0}
	if {$chan == $exchan13} {return 0}
	if {$chan == $exchan14} {return 0}
	if {$chan == $exchan15} {return 0}
     if {[matchattr $hand o|o $chan] == 0 && [matchattr $hand v|v $chan] == 0 && [matchattr $hand m|m $chan] == 0 && [matchattr $hand n|n $chan] == 0 && [matchattr $hand f|f $chan] == 0 && [matchattr $hand p|p $chan] == 0} {
       if {$kickandban == 0} { invite_dontban }
    
       newchanban $chan $ban "Auto-Set" $why $invitekickbantime                     
       putserv "MODE $chan +b $ban"
       putserv "KICK $chan $nick :$why"
       putcmdlog "reklam3r Kick - $nick kicked from $chan"
       return 0
      }
    }
  }
return 0
}

##################################################################
# This section will only kick if you set $kickandban to 0..... ###
##################################################################


bind pubm - * invite_dontban

proc invite_dontban {nick userhost hand chan things} {

  global inviteonoff
  global invitechar
  global invitekickbantime
  global kickandban
  global exchan1
  global exchan2
  global exchan3
  global exchan4
  global exchan5
  global exchan6
  global exchan7
  global exchan8
  global exchan9
  global exchan10
  global exchan11
  global exchan12
  global exchan13
  global exchan14
  global exchan15
  set who "Auto-Set"
  set why "reklam3r Detected."

if {$inviteonoff == 0} {return 0}
  set invitechar #
  if {$inviteonoff == 1} {
    if {[string match "*$invitechar*" $things]} {
     if {![botisop $chan]} {return 0}
      if {$chan == $exchan1} {return 0}
	if {$chan == $exchan2} {return 0}
	if {$chan == $exchan3} {return 0}
	if {$chan == $exchan4} {return 0}
	if {$chan == $exchan5} {return 0}
	if {$chan == $exchan6} {return 0}
	if {$chan == $exchan7} {return 0}
	if {$chan == $exchan8} {return 0}
	if {$chan == $exchan9} {return 0}
	if {$chan == $exchan10} {return 0}
	if {$chan == $exchan11} {return 0}
	if {$chan == $exchan12} {return 0}
	if {$chan == $exchan13} {return 0}
	if {$chan == $exchan14} {return 0}
	if {$chan == $exchan15} {return 0}
     if {[matchattr $hand o|o $chan] == 0 && [matchattr $hand v|v $chan] == 0 && [matchattr $hand m|m $chan] == 0 && [matchattr $hand n|n $chan] == 0 && [matchattr $hand f|f $chan] == 0 && [matchattr $hand p|p $chan] == 0} {

       putserv "KICK $chan $nick :$why"
       putcmdlog "reklam3r Kick - $nick kicked from $chan"
       return 0
      }
    }
  }
return 0
}



###########################
# MSG... ##################
###########################


bind msg m|m inviteset msg_set
bind msg n|n inviteset msg_set


proc msg_set {nick userhost hand rest} {
 global botnick
 global msgonoff
 global inviteonoff
 set msgonoff [lindex $rest 0]
 if {$msgonoff == ""} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 USAGE: /msg $botnick inviteset <on/off>"
  return 0
 }
  if {$msgonoff == "on"} {
    if {$inviteonoff == 1} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 reklam3r Kick is already ON!"
  return 0
 }
}
  if {$msgonoff == "on"} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 reklam3r Kick have been turned ON!"
  set inviteonoff 1
  return 0
 }
  if {$msgonoff == "off"} {
    if {$inviteonoff == 0} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 reklam3r Kick is already OFF!"
  return 0
   }
 }
 if {$msgonoff == "off"} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 reklam3r Kick have been turned OFF!"
  set inviteonoff 0
  return 0
  }
 }

bind msg m|m invitebanset msg_banset
bind msg n|n invitebanset msg_banset

proc msg_banset {nick userhost hand rest} {
 global botnick
 global invitekickbantime
 set invitebanset [lindex $rest 0]
 if {$invitebanset == ""} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 USAGE: /msg $botnick invitebanset <ban duration in minutes>"
  return 0
 }
  if {$invitebanset == $invitekickbantime} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 reklam3r Bantime is already set to $invitekickbantime minute(s)!"
  return 0
}   
if {$invitebanset == "default"} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 reklam3r Bantime is now set to default: 1 minute(s)!"
  set invitekickbantime 1
  return 0
 }
  puthelp "NOTICE $nick :\002\[iSP\]\002 reklam3r Bantime set to $invitebanset minute(s)!"
  set invitekickbantime $invitebanset
  return 0
}

bind msg m|m exchan msg_exchan
bind msg n|n exchan msg_exchan


proc msg_exchan {nick userhost hand rest} {
 global botnick
 global invitekickbantime
 global msgexchan
 global msgexchannum
 global chanselect
 global exchan1
 global exchan2
 global exchan3
 global exchan4
 global exchan5
 global exchan6
 global exchan7
 global exchan8
 global exchan9
 global exchan10
 global exchan11
 global exchan12
 global exchan13
 global exchan14
 global exchan15
 set msgexchan [lindex $rest 1]
 set msgexchannum [lindex $rest 0]
 if {$msgexchannum == ""} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 USAGE: /msg $botnick exchan <1-15> <#channel>"
  return 0
 }
 if {$msgexchan == ""} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 USAGE: /msg $botnick exchan <1-15> <#channel>"
  return 0
 }
  if {$msgexchannum == "1"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 1 set to: $chanselect"
  set exchan2 $chanselect
  return 0
}
  if {$msgexchannum == "2"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 2 set to: $chanselect"
  set exchan2 $chanselect
  return 0
}
  if {$msgexchannum == "3"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 3 set to: $chanselect"
  set exchan3 $chanselect
  return 0
}
  if {$msgexchannum == "4"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 4 set to: $chanselect"
  set exchan4 $chanselect
  return 0
}
  if {$msgexchannum == "5"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 5 set to: $chanselect"
  set exchan5 $chanselect
  return 0
}
  if {$msgexchannum == "6"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 6 set to: $chanselect"
  set exchan6 $chanselect
  return 0
}
  if {$msgexchannum == "7"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 7 set to: $chanselect"
  set exchan7 $chanselect
  return 0
}
  if {$msgexchannum == "8"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 8 set to: $chanselect"
  set exchan8 $chanselect
  return 0
}
  if {$msgexchannum == "9"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 9 set to: $chanselect"
  set exchan9 $chanselect
  return 0
}
  if {$msgexchannum == "10"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 10 set to: $chanselect"
  set exchan10 $chanselect
  return 0
}
  if {$msgexchannum == "11"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 11 set to: $chanselect"
  set exchan11 $chanselect
  return 0
}
  if {$msgexchannum == "12"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 12 set to: $chanselect"
  set exchan12 $chanselect
  return 0
}
  if {$msgexchannum == "13"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 13 set to: $chanselect"
  set exchan13 $chanselect
  return 0
}
  if {$msgexchannum == "14"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 14 set to: $chanselect"
  set exchan14 $chanselect
  return 0
}
  if {$msgexchannum == "15"} {
  set chanselect [lindex $rest 1]
  puthelp "NOTICE $nick :\002\[iSP\]\002 Exclude channel 15 set to: $chanselect"
  set exchan15 $chanselect
  return 0
}
puthelp "NOTICE $nick [lindex $rest 0] is not an valid channel number. Select one between 1-15"
return 0
}

bind msg m|m invitekickandban msg_kickandban
bind msg n|n invitekickandban msg_kickandban

proc msg_kickandban {nick userhost hand rest} {
 global botnick
 global invitekickbantime
 global msgkickandban
 global kickandban
 set msgkickandban [lindex $rest 0]
 if {$msgkickandban == ""} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 USAGE: /msg $botnick invitekickandban <on/off>"
  return 0
 }
 if {$msgkickandban == "on"} {
    if {$kickandban == 1} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 Kick And Ban is already ON"
  return 0
                         }
 }
 if {$msgkickandban == "on"} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 Kick And Ban have been turned ON"
  set kickandban 1
  return 0
 }
 if {$msgkickandban == "off"} {
    if {$kickandban == 0} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 Kick And Ban is already OFF"
  return 0
                         }
 }
 if {$msgkickandban == "off"} {
  puthelp "NOTICE $nick :\002\[iSP\]\002 Kick And Ban have been turned OFF"
  set kickandban 0
  return 0
 }
}


###########################
# DCC.... #################
###########################


bind dcc n|n inviteset invite_dcc
bind dcc m|m inviteset invite_dcc


proc invite_dcc {hand idx rest} {
     global botnick
     global dcconoff
     global inviteonoff
     set dcconoff [lindex $rest 0]
     if {$dcconoff == ""} {
        putidx $idx ".inviteset <on/off>"
        return 0          }

     if {$dcconoff == "on"} {
        if {$inviteonoff == 1} {
            putidx $idx "Advertise Kick is already ON"
            return 0           }
                           }

     if {$dcconoff == "on"} {
        putidx $idx "Advertise Kick have been turned ON"
        set inviteonoff 1
        return 0           }

     if {$dcconoff == "off"} {
        if {$inviteonoff == 0} {
            putidx $idx "Advertise Kick is already OFF"
            return 0
                               }
                            }
     if {$dcconoff == "off"} {
        putidx $idx "Advertise Kick have been turned OFF"
        set inviteonoff 0
        return 0           
                            }
}

bind dcc m|m invitebanset dcc_banset
bind dcc n|n invitebanset dcc_banset


proc dcc_banset {hand idx rest} {

 global botnick
 global invitekickbantime
 global dccbanset
 set dccbanset [lindex $rest 0]
 if {$dccbanset == ""} {
  putidx $idx ".invitebanset <ban duration in minutes>"
  return 0
 }
  if {$dccbanset == $invitekickbantime} {
  putidx $idx "Advertise Bantime is already set to $invitekickbantime minute(s)!"
  return 0
}   
if {$dccbanset == "default"} {
  putidx $idx "Advertise Bantime is now set to default: 1 minute(s)!"
  set invitekickbantime 1
  return 0
 }
  putidx $idx "Advertise Bantime set to $dccbanset minute(s)!"
  set invitekickbantime $dccbanset
  return 0
}

bind dcc m|m exchan dcc_exchan
bind dcc n|n exchan dcc_exchan


proc dcc_exchan {hand idx rest} {

 global botnick
 global invitekickbantime
 global dccexchan
 global dccexchannum
 global chanselect
 global exchan1
 global exchan2
 global exchan3
 global exchan4
 global exchan5
 global exchan6
 global exchan7
 global exchan8
 global exchan9
 global exchan10
 global exchan11
 global exchan12
 global exchan13
 global exchan14
 global exchan15
 set dccexchan [lindex $rest 1]
 set dccexchannum [lindex $rest 0]
 if {$dccexchannum == ""} {
  putidx $idx ".exchan <1-15> <#channel>"
  return 0
 }
 if {$dccexchan == ""} {
  putidx $idx ".exchan <1-15> <#channel>"
  return 0
 }
  if {$dccexchannum == "1"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 1 set to: $chanselect"
  set exchan1 $chanselect
  return 0
}
  if {$dccexchannum == "2"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 2 set to: $chanselect"
  set exchan2 $chanselect
  return 0
}
  if {$dccexchannum == "3"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 3 set to: $chanselect"
  set exchan3 $chanselect
  return 0
}
  if {$dccexchannum == "4"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 4 set to: $chanselect"
  set exchan4 $chanselect
  return 0
}
  if {$dccexchannum == "5"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 5 set to: $chanselect"
  set exchan5 $chanselect
  return 0
}
  if {$dccexchannum == "6"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 6 set to: $chanselect"
  set exchan6 $chanselect
  return 0
}
  if {$dccexchannum == "7"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 7 set to: $chanselect"
  set exchan7 $chanselect
  return 0
}
  if {$dccexchannum == "8"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 8 set to: $chanselect"
  set exchan8 $chanselect
  return 0
}
  if {$dccexchannum == "9"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 9 set to: $chanselect"
  set exchan9 $chanselect
  return 0
}
  if {$dccexchannum == "10"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 10 set to: $chanselect"
  set exchan10 $chanselect
  return 0
}
  if {$dccexchannum == "11"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 11 set to: $chanselect"
  set exchan11 $chanselect
  return 0
}
  if {$dccexchannum == "12"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 12 set to: $chanselect"
  set exchan12 $chanselect
  return 0
}
  if {$dccexchannum == "13"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 13 set to: $chanselect"
  set exchan13 $chanselect
  return 0
}
  if {$dccexchannum == "14"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 14 set to: $chanselect"
  set exchan14 $chanselect
  return 0
}
  if {$dccexchannum == "15"} {
  set chanselect [lindex $rest 1]
  putidx $idx "Exclude channel 1 set to: $chanselect"
  set exchan15 $chanselect
  return 0
}
putidx $idx "[lindex $rest 0] is not an valid channel number. Select one between 1-15"
return 0
}

bind dcc m|m invitekickandban dcc_kickandban
bind dcc n|n invitekickandban dcc_kickandban

proc dcc_kickandban {hand idx rest} {
 
 global botnick
 global invitekickbantime
 global dcckickandban
 global kickandban
 set dcckickandban [lindex $rest 0]
 if {$dcckickandban == ""} {
  putidx $idx ".invitekickandban <on/off>"
  return 0
 }
 if {$dcckickandban == "on"} {
    if {$kickandban == 1} {
  putidx $idx "Kick And Ban is already ON"
  return 0
                         }
 }
 if {$dcckickandban == "on"} {
  putidx $idx "Kick And Ban have been turned ON"
  set kickandban 1
  return 0
 }
 if {$dcckickandban == "off"} {
    if {$kickandban == 0} {
  putidx $idx "Kick And Ban is already OFF"
  return 0
                         }
 }
 if {$dcckickandban == "off"} {
  putidx $idx "Kick And Ban have been turned OFF"
  set kickandban 0
  return 0
 }
putidx $idx ".invitekickandban <on/off>"
}


putlog "reklam3r Kick/Ban Script by g0d Loaded!"
putlog "reklam3r Kick/Ban time set to: $invitekickbantime minute(s)!"


#####################
# Script End ########
#####################

