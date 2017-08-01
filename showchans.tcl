#         Script : ShowChansPlus v1.04 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2001-02 Radical Computer Systems
#
#  strip:* routines taken from Moretools.tcl v1.1.4 by MC_8
#
#       Original
#       Platform : Linux 2.0.33
#                  Eggdrop v1.2.0+bel1
#       Current
#      Platforms : Linux 2.2.16   (TCL v8.3  patchlevel 8.3.1)
#                  Eggdrop v1.6.2
#                  Eggdrop v1.6.6
#            And : SunOS 5.8      (TCL v8.3)
#                  Eggdrop v1.5.4
#
#    Description : ShowChansPlus does a few things:
#                   o Shows in DCCloglvl and/or wallops what channels a
#                     user is on that joins the channel.
#                   o Allows you to auto-ban based on "illegal" channels
#                   o Allows you to auto-ban based on real name field
#                   o Announces when an OPER joins the channel
#                   o Sets a full domain ban based on nicks (So they don't
#                     know they're banned by nick, better then nick!*@*)
#                   o Auto-Bans +d users.
#                   o Auto-detection for a popular clone flooding script
#                   o Auto-detection for one of the Drones on DALnet
#
#        History : 05/27/2001 - First Release
#                  10/31/2001 - v1.01
#                              o Added more triggers
#                              o Added +d banning
#                              o Fixed banning. Global ban instead of
#                                channel ban.
#                              o Hopfully fixed the *!*@ ban when target
#                                let channel before the hostmask could be
#                                obtained.
#                              o Changed lsearch calls to string match.
#                  02/10/2002 - v1.02
#                              o Fixed clonebot killer.
#                              o Fixed error with not checking last line
#                                of bad channels.
#                              o Belive I increased the detection speed.
#                                Checks will abort as soon as a trigger
#                                matches and wont do further checks if a
#                                match has allready been made.
#                  02/10/2002 - v1.03
#                              o Fixed a variable missnamed error in the
#                                bad channel checking routine.
#                  08/26/2002 - v1.04
#                              o Added possible detection of a drone bot
#                                on DALnet.
#                              o Added 2 nick bans
#                              o Added 2 channel bans
#                              o Added 1 bot trigger
#                              o Removed usage of strictmaskhost command
#
#
#   Future Plans : Suggest Something.
#
# Author Contact :     Email - DProper@stx.rr.com
#                  Home Page - http://home.stx.rr.com/dproper
#       Homepage Direct Link - http://www.chaotix.net/~dproper
#                        IRC - Primary Nick: DrN
#                     UseNet - alt.irc.bots.eggdrop
# Support Channels: #RCS @UnderNet.Org
#                   #RCS @DALnet
#                   #RCS @EFnet
#                   #RCS @GalaxyNet
#                   #RCS @Choatix Addiction
#            Other channels - Check contact page for current list
#
#                Current contact information can be located at:
#                 http://www.chaotix.net/rcs/contact.html
#
# New TCL releases are sent to the following sites as soon as they're released:
#
# FTP Site                   | Directory                     
# ---------------------------+-------------------------------
# ftp.chaotix.net            | /pub/RCS
# ftp.eggheads.org           | Various
# ftp.realmweb.org           | /drn
#
#
# Chaotix.Net has retured. web site and mailing list are now active.
#
#   Radical Computer Systems - http://www.chaotix.net/rcs/
# To subscribe to the RCS mailing list: mail majordomo@chaotix.net and in
#  BODY of message, type  subscribe rcs-list
#
#  Feel free to Email me any suggestions/bug reports/etc.
# 
# You are free to use this TCL/script as long as:
#  1) You don't remove or change author credit
#  2) You don't release it in modified form. (Only the original)
# 
# If you have a "too cool" modification, send it to me and it'll be
# included in the official release. (With your credit)
#
# Commands Added:
#  Where     F CMD       F CMD         F CMD        F CMD
#  -------   - --------- - ----------- - ---------- - --------- - -------
#  Public:   m !showchans
#     MSG:   m showchans
#     DCC:   o wallop    m showchans
#
# Public Matching: N/A
#

# To Do 
# Setup realnames list diff:
# set reason(!1!) "120 Bot. go away"
# set r(1) "shithead 60 You're a shithead, go away"
# set r(2) "BotService !1!"


# Not coded for yet. 
set sc_reason(threat) "14400 You have been identified as a possible threat."
set sc_reason(botservice) "60 Account identified as Bot Services. Not needed here."
set sc_reason(bot) "60 Possible Bot. Auto-Removal"
set sc_reason(cfbot) "14400 Possible clone/flood Bot. Auto-Removal"

# Publics is for another script of mine that allows you to turn off
# channel stuff like this. Uncomment the next line if not running it.
#set publics 1


set cmdchar_ "!"
set showchans(ver) "1.04.08"

# User Access flag to use the !showchans command
set showchans(flag) "m"

# [0/1] Set this to 1 if you want to kick/ban users with the exact same
#       ident and realname field.
set showchans(nodrone) 0

# [0/1] Set to 1 if you want userchans displayed in wallops
set showchans(wallop) 0
# [0/1] Set to 1 if you want userchans displayed in DCCLoglev
set showchans(dcclog) 1
# Set to the log level to send to
set showchans(dccloglev) 2
# [0/1] Set to 1 if you want OPERs identified via wallops
set showchans(showoper) 1
# Set this to the channels to check for bad channels on
set showchans(checkchans) "#love #freak"
# Set this to nicks NOT to whois. (Known bots, service bots, etc)
set showchans(nowhois) "W X ChanServ ^Elviraa^ LadySin WiLdOnE IsleBot GoD UWorld"

set showchans(logrealname) 1
set showchans(logchannels) 1

set badnick(bantime) 14400
set badnicks {
 {SLiNK-Y Channel Harrasment}
 {ooopps Ban Evasion}
 {sHaB[3]aN Ban Evasion}
 {duxxpinz The.}
 {[sHaB3aN] Ban Evasion and being a total fucking moron}
 {[SuX]Co0L Ban Evasion. Go away.}
 {C-Service Pathetic attempt at stealing passwords. Piss off lamer}
 {Hades108 Ban Evasion, Clones, Disrespect for channel. Grow up bitch.}
 {SHAI-HULU Ban Evasion, Clones, Disrespect for channel. Grow up bitch.}
}
# {empy User Harrasment, Stalking, Channel Harasment}
# {tlabs Requested: System Hacking/Threats}

# This is a list of channels or parts of channels to auto-kick for.
# Users kicked for this violation are banned for 1 minute to prevent
# Auto-rejoin on kick scripts.
set badchans(1) "#aþk mother*sex daughter*sex father*sex dad*sex"
set badchans(2) "humiliation familysex daddaughtersex motherdaughtersex"
set badchans(3) "animalsex #Galaxie #flooders"
set badchans(4) "childsex baby*sex mom*son favela"
set badchans(5) "fete&baieti monalisa2 respectati nimes alhoceima #moon #owen"
set badchans(6) "undernet_help 5star #yeþilköy flames"
set badchans(7) "#madaam #dimensions #m-net #libanon"
set badchanmax 7

# [0/1] Set to 1 if you want to check for bad channels
set showchans(check) 1

set showchans(nodeaf) 1

# Filter ban for realnames fields. Matches from this list are a "Possible
# Threat" and are banned for 10 days.
set badreals(autobantime) 14400
set badreals(autoban) {
 {BoT FlooD}
 {FucK iT All ScripT}
 {BoT FlooD DE FucK iT All ScripT}
 {Master Velocity}
 {Master Forcing}
 {4.1v ooFregniP}
 {4.1*niP}
 {LoveBugg58}
 {WarF|ood Eggdrop}
 {eggdrop a Tricky}
 {KiiLLaaa W.H.C}
 {Alliance bot}
 {.abot.}
 {No Info}
 {Under7.iFrance.com}
 {Under7}
 {white^falcon}
                      }
# Realnames matching filters in this list are marked as a Bot Service bot
# and banned for 1minute to prevent auto-rejoin
set badreals(botservicestime) 60
set badreals(botservices) {
 {XSBotservices}
 {www.blakjak.net/cyclebot}
 {cyclebot}
                          }

# Realnames matching filters in this list are marked as a bot and banned
# for 1 minute to prevent auto-rejoins
set badreals(botstime) 60
set badreals(bots) {
 {Devilz Script2 [BOT]}
 {bOTsCriPt www.geocities.com/sonsuzsiyah}
 {Eggdrop de la team}
 {Aide Script by Riker}
 {PaRaDiZe ScRiPt}
 {Eggdrop of }
 {Satan auto mesejbot}
 {HellSound Bot}
 {Temporary Bot}
 {MetroBot}
 {Pioneer-Script.BOT}
 {J u n i o r B o t}
 {CrAwLbOt * By NiteCrawler}
 {VcLoNe * By Virus}
                   }

proc cmdchar { } {
global cmdchar_
return $cmdchar_
}

bind dcc o o dcc_wallop
bind dcc o wallop dcc_wallop
proc dcc_wallop {hand idx onoff} {
set chan [string tolower [lindex [console $idx] 0]]

wallops $chan $onoff
}

bind msg $showchans(flag) showchan msg_showchan
proc msg_showchan {nick uhost hand args} {
global showtomsg showchans
set showtomsg $nick
set chan [lindex $args 0]
#set chan [string tolower [lindex [console $idx] 0]]

putserv "PRIVMSG $nick :Whoising everyone on $chan"
bind raw - "319" showmsgchan

    foreach user [chanlist $chan] {
    set whoisthem 0  
    foreach n $showchans(nowhois) {
     if {([string tolower $user] == [string tolower $n])} {set whoisthem 1}
                                 }
    if {$whoisthem == 0} {putserv "WHOIS $user"}
                                   }
}
proc showmsgchan {from key text} {
global niuhch showtomsg
 subst -nobackslashes -nocommands -novariables text

set ni [lindex $niuhch 0] ; set uh [lindex $niuhch 1] ; set ch [lindex $niuhch 2]
set onchans [string tolower [string trimleft [lrange $text 2 end] :]]
set nicky [lindex $text 1]
putserv "PRIVMSG $showtomsg :\002\[SHOWCHAN\] $nicky\002 is on: $onchans"
}



bind pub $showchans(flag) [cmdchar]showchan pub_showchan
proc pub_showchan {nick uhost handle channel args} {
global showtopub showchans
set showtopub $nick
set chan "$channel"
putserv "NOTICE $nick :Whoising everyone on $chan"
bind raw - "319" showpubchan

    foreach user [chanlist $chan] {
    set whoisthem 0  
    foreach n $showchans(nowhois) {
     if {([string tolower $user] == [string tolower $n])} {set whoisthem 1}
                                 }
    if {$whoisthem == 0} {putserv "WHOIS $user"}
                                   }
}
proc showpubchan {from key text} {
global niuhch showtopub
 subst -nobackslashes -nocommands -novariables text

 set ni [lindex $niuhch 0] ; set uh [lindex $niuhch 1] ; set ch [lindex $niuhch 2]
 set onchans [string tolower [string trimleft [lrange $text 2 end] :]]
 set nicky [lindex $text 1]
 putserv "NOTICE $showtopub :\002\[SHOWCHAN\] $nicky\002 is on: $onchans"
}




bind dcc m showchan dcc_showchan
proc dcc_showchan { hand idx onoff } {
global showtodcc showchans
set showtodcc $idx
set chan [string tolower [lindex [console $idx] 0]]

putdcc $idx "Whoising everyone on $chan"
bind raw - "319" showdccchan
global badchans

    foreach user [chanlist $chan] {
    set whoisthem 0  
    foreach n $showchans(nowhois) {
     if {([string tolower $user] == [string tolower $n])} {set whoisthem 1}
                                 }
    if {$whoisthem == 0} {putserv "WHOIS $user"}
                                   }
}
proc showdccchan {from key text} {
global niuhch showtodcc
set ni [lindex $niuhch 0] ; set uh [lindex $niuhch 1] ; set ch [lindex $niuhch 2]
set onchans [string tolower [string trimleft [lrange $text 2 end] :]]
set nicky [lindex $text 1]
putdcc $showtodcc "\002\[SHOWCHAN\] $nicky\002 is on: $onchans "
}

set showtodcc 0

bind join - ** whoisuser
#set niuhch "nick uhost chan"

proc whoisuser {nick uh ha ch} {
global niuhch badchans showchans badnicks badnick publics
 subst -nobackslashes -nocommands -novariables nick

bind raw - "313" showuoper
bind raw - "319" showuchan
set niuhch "$nick $uh $ch"
set sitemask "*!*[string trimleft [maskhost $uh] *!]"
set lnick [string tolower $nick]

foreach l $badnicks {
 if {[string tolower [lindex $l 0]] == $lnick} {
  if {![isban $sitemask]} {
    set reason [lrange $l 1 end]
    newban $sitemask BadNick $reason $badnick(bantime)
    kickfromallchans $nick $reason
                          }
                                               }
                    }

if {$publics == 0} {return 0}

set whoisthem 0
foreach n $showchans(nowhois) {
 if {([string tolower $nick] == [string tolower $n])} {set whoisthem 1}
                           }
if {$whoisthem == 0} {putserv "WHOIS $nick"}

}

proc showuoper {from key text} {
global niuhch badchans showchans
 subst -nobackslashes -nocommands -novariables text

 #set ni [lindex $niuhch 0] ; set uh [lindex $niuhch 1] ; 
 set ch [lindex $niuhch 2]
 #set onchans [string tolower [string trimleft [lrange $text 2 end] :]]
 set nick [lindex $text 1]
 if {$showchans(showoper) == 1} {wallops $ch "$nick is an IRCop"}
}

proc showuchan {from key text} {
global niuhch badchans badchanmax showchans
 subst -nobackslashes -nocommands -novariables text

set ni [lindex $niuhch 0] ; set uh [lindex $niuhch 1] ; set ch [lindex $niuhch 2]
set onchans [string tolower [string trimleft [lrange $text 2 end] :]]
set nicky [lindex $text 1]

if {(![onchan $nicky $ch])} {putlog "\[ShowChans\] Target left channel :$nicky:$ch"; return 0}
#set sitemask "*!*[string trimleft [strictmaskhost $nicky $ch] *!]"
 set sitemask "*!*[string trimleft [getchanhost $nicky $ch] *!]"


if {$showchans(wallop) == 1} {wallops $ch "$nicky is on the following channels: $onchans "}
if {$showchans(dcclog) == 1} {putloglev $showchans(dccloglev) $ch "$nicky is on the following channels: $onchans "}
if {$showchans(logchannels) == 1} {putlog "$nicky is on the following channels: $onchans "}
if {($showchans(nodeaf)==1) && ([string index [lindex $onchans 0] 0] == "-")} {putlog "User is +d"
    set reason "You are +d, therefor you are not a human user. Fuck off."
    newban $sitemask DeafUser $reason
    kickfromallchans $nicky $reason
}

if {$showchans(check) != 1} {return 0}


set dothechan 0
foreach c $showchans(checkchans) {
 if {([string tolower $ch] == [string tolower $c])} {set dothechan 1}
                           }

if {$dothechan == 0} {return 0}
set badchan 0
set badchann ""

set loop 1; set max [expr $badchanmax + 1]
while {($loop < $max) && ($badchan == 0)} {
 set badchannels [string tolower $badchans($loop)]
 set loop2 0; set max2 [llength $badchannels]
 while {($loop2 < $max2) && ($badchan == 0)} {
 set v [lindex $badchannels $loop2]
 if {[string match "*[string tolower $v]*" "$onchans"]} {set badchan 1; set badchann $v}
 incr loop2
                                              }
incr loop
}

#for {set bloop 1} {$bloop < $badchanmax+1} {incr bloop} {
# set badchannels [string tolower $badchans($bloop)]
#
#foreach v $badchannels { if {[string match "*[string tolower $v]*" "$onchans"]} {set badchan 1
#                                                                      set badchann $v}}
#     }

if {$badchan == 1} {
set reason "Sorry, we don't allow people from channels with \"$badchann\" in the name here."
newchanban $ch $sitemask BadChans $reason 1
flushmode $ch
putserv "KICK $ch $ni :$reason"
                   }
unbind raw - "319" showuchan
}

proc timedeban {chan sitemask} {
putserv "MODE $chan -b $sitemask"
}

proc wallops {chan msg} {
    foreach user1 [chanlist $chan] {
     set hand [nick2hand $user1 $chan]
     if {![onchansplit $user1 $chan] && ([isop $user1 $chan] || ([matchattr $hand o]))} {
      set oplist $user1
      putserv "NOTICE $oplist :(\002OPmsg\002/$chan) $msg"
      unset oplist
                                                             }
                                   }
}


bind raw - "311" realname_filter
proc realname_filter {from key text} {
global badreals showchans
 subst -nobackslashes -nocommands -novariables text
 set tonick [lindex $text 0]
 set unick [lindex $text 1]
 set account [lindex $text 2]
# if {[string index $account 0] == "~"} {set account [string range $account 1 end]}
 set domain [lindex $text 3]
 set text3 [lindex $text 4]
 set realname [lrange $text 5 end]
 set realnameo [strip:all [string trimleft [lrange $text 5 end] :]]
 set realname [strip:all [string tolower [string trimleft [lrange $text 5 end] :]]]

 if {$showchans(logrealname) == 1} {putlog "$unick's realname is \"$realname\""}


set nk_ln [string length $unick]
set rn_ln [string length $realnameo]
set ac_ln [string length $account]
set rn_u 0; if {$realnameo==[string toupper $realnameo]} {set rn_u 1}
set ac_u 0; if {$account==[string toupper $account]} {set ac_u 1}
set nk_u 0; if {$unick==[string toupper $unick]} {set nk_u 1}
set rn_l 0; if {$realnameo==[string tolower $realnameo]} {set rn_l 1}
set ac_l 0; if {$account==[string tolower $account]} {set ac_l 1}
set nk_l 0; if {$unick==[string tolower $unick]} {set nk_l 1}
set id 1
if {[string index $account 0] == "~"} {set id 0 
                                       incr ac_ln -1}
 set profile ""
#BPCEKCF   ~BAEBF   TCECJ
if {($id==0) && ($rn_ln==$ac_ln) && ($rn_u==1) && ($ac_u==1) && ($nk_u==1)} {set profile "2"}

#ioalv     ~IKLBE   MATPI
if {($id==0) && ($rn_ln==$ac_ln) && ($rn_u==1) && ($ac_u==1) && ($nk_l==1)} {set profile "1"}

#putlog "nk_ln:$nk_ln rn_ln:$rn_ln ac_ln:$ac_ln rn_u:$rn_u ac_u:$ac_u nk_u:$nk_u rn_l:$rn_l ac_l:$ac_l nk_l:$nk_l id:$id unick:$unick account:$account realnameo:$realnameo profile:$profile"
if {($profile != "") && ($showchans(nodrone)==1)} {
                  set reason "You match Drone profile #${profile}."
                  set sitemask [maskhost *!*@$domain]
#                  newban $sitemask CAS $reason $badreals(botstime)
                  kickfromallchans $unick $reason
                  
                  return 0
                      }

if {[string index $account 0] == "~"} {
 set account [string range $account 1 [string length $account]]
 if {([string length $account] == 2) && ([string length $realname] == 2)} {
#                  set badreal 100
                  set reason "Possible clone/flood Bot. Auto-Removal"
                  set sitemask [maskhost *!*@$domain]
                  newban $sitemask CAS $reason $badreals(botstime)
                  kickfromallchans $unick $reason
                  return 0
                      }
                                      }
if {($account == $realnameo) && ($showchans(nodrone)==1)} {
                  set reason "Possible Drone Machine. Auto-Removal"
                  set sitemask [maskhost *!*@$domain]
                  newban $sitemask CAS $reason $badreals(botstime)
                  kickfromallchans $unick $reason
                  return 0
                      }

#putlog "ac:$account:[string length $account] rl:$realname:[string length $realname] br:$badreal

set badreal 999

##foreach v $badreals(autoban) {if {[string match "*[string tolower $v]*" "$realname"]} {set badreal 1}}
set loop 0; set max [llength $badreals(autoban)]
while {($loop < $max) && ($badreal == 999)} {
if {[string match "*[string tolower [lindex $badreals(autoban) $loop]]*" "$realname"]} {set badreal 1}
 incr loop
}

#foreach v $badreals(botservices) {if {[string match "*[string tolower $v]*" "$realname"]} {set badreal 2}}
set loop 0; set max [llength $badreals(botservices)]
while {($loop < $max) && ($badreal == 999)} {
if {[string match "*[string tolower [lindex $badreals(botservices) $loop]]*" "$realname"]} {set badreal 2}
 incr loop
}


#foreach v $badreals(bots) {if {[string match "*[string tolower $v]*" "$realname"]} {set badreal 3}}
set loop 0; set max [llength $badreals(bots)]
while {($loop < $max) && ($badreal == 999)} {
if {[string match "*[string tolower [lindex $badreals(bots) $loop]]*" "$realname"]} {set badreal 3}
 incr loop
}



#if {$badreal == 100} {
#set reason "Possible clone/flood Bot. Auto-Removal"
#set sitemask [maskhost *!*@$domain]
#newban $sitemask CAS $reason $badreals(botstime)
#kickfromallchans $unick $reason
#                   }

set sitemask [maskhost $unick!*${account}@$domain]
if {$badreal == 1} {
set reason "You have been identified as a possible threat."
newban $sitemask BadReal $reason $badreals(autobantime)
kickfromallchans $unick $reason
                   }
if {$badreal == 2} {
set reason "Account identified as Bot Services. Not needed here."
newban $sitemask BadReal_SB $reason $badreals(botservicestime)
kickfromallchans $unick $reason
                   }
if {$badreal == 3} {
set reason "Possible Bot. Auto-Removal"
newban $sitemask BadReal_bot $reason $badreals(botstime)
kickfromallchans $unick $reason
                   }

}

proc kickfromallchans {nick reason} {
  foreach chan [channels] {
   if {[onchan $nick $chan]} {
                              putquick "KICK $chan $nick :\002$reason\002"
                             }
                          }
}

proc strip:color {ar} {
 set argument ""
 if {![string match *^C* $ar]} {return $ar} ; set i -1 ; set length [string length $ar]
 while {$i < $length} {
  if {[string index $ar $i] == "^C"} {
   set wind 1 ; set pos [expr $i+1]
   while {$wind < 3} {
    if {[string index $ar $pos] <= 9 && [string index $ar $pos] >= 0} {
     incr wind 1 ; incr pos 1} {set wind 3
    }
   }
   if {[string index $ar $pos] == "," && [string index $ar [expr $pos + 1]] <= 9 &&
       [string index $ar [expr $pos + 1]] >= 0} {
    set wind 1 ; incr pos 1
    while {$wind < 3} {
     if {[string index $ar $pos] <= 9 && [string index $ar $pos] >= 0} {
      incr wind 1 ; incr pos 1} {set wind 3
     }
    }
   }
   if {$i == 0} {
    set ar [string range $ar $pos end]
    set length [string length $ar]
   } {
    set ar "[string range $ar 0 [expr $i - 1]][string range $ar $pos end]"
    set length [string length $ar]
   }
   set argument "$argument[string index $ar $i]"
  } {incr i 1}
 }
 set argument $ar
 return $argument
}
proc strip:bold {ar} {
 set argument ""
 if {[string match *^B* $ar]} {
  set i 0
  while {$i <= [string length $ar]} {
   if {![string match ^B [string index $ar $i]]} {
    set argument "$argument[string index $ar $i]"
   }
   incr i 1
  }
 } { set argument $ar }
 return $argument
}
proc strip:uline {ar} {
 set argument ""
 if {[string match *^_* $ar]} {
  set i 0
  while {$i <= [string length $ar]} {
   if {![string match ^_ [string index $ar $i]]} {
    set argument "$argument[string index $ar $i]"
   }
   incr i 1
  }
 } { set argument $ar }
 return $argument
}
proc strip:reverse {ar} {
 set argument ""
 if {[string match *^V* $ar]} {
  set i 0
  while {$i <= [string length $ar]} {
   if {![string match ^V [string index $ar $i]]} {
    set argument "$argument[string index $ar $i]"
   }
   incr i 1
  }
 } { set argument $ar }
 return $argument
}

proc strip:all {ar} {
 return [strip:reverse [strip:uline [strip:bold [strip:color $ar]]]]
}

putlog "ShowChans v$showchans(ver) by David Proper (DrN) -=: LoadeD :=-"
return "ShowChans v$showchans(ver) by David Proper (DrN) -=: LoadeD :=-"


