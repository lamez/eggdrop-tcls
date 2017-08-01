#         Script : QuickVote v1.01 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2002 Radical Computer Systems
#
#       Testing
#      Platforms : Linux 2.2.16
#                  Eggdrop v1.6.2
#            And : SunOS 5.8
#                  Eggdrop v1.5.4
#
#    Description : QuickVote allows you to have quick and dirty yes/no
#                  voting questions in a channel. Votes can be via channel
#                  command or via message command. 
#                  o Vote can be open or OPs only.
#                  o Can vote to ban/permchanban/globalban
#                  o Can vote to op/permchanop/permglobalop
#                  o Can vote to unban/permchanunban/globalunban
#                  o Can vote to deop/permchandeop/permglobaldeop
#
#        History : 01/08/2002 - First Release
#                  01/18/2002 - v1.01
#                              o Forgot the isnum proc. heh.
#                              o Removed useage of strictmaskhost
#                              o Added in an abort command to end the vote.
#                                 Suggested by: |crazy|@EFnet
#                              o Changed the vote start/end displays into
#                                easily changed variables.
#                                Send in any new formats ya add.
#                                End Format #3 based on one by |crazy|@EFnet
#
#
#   Future Plans : Fix any bugs. lol. :)
#
# Author Contact :     Email - DProper@stx.rr.com
#                  Home Page - http://home.stx.rr.com/dproper
#                        IRC - Nick: DrN  UnderNet/DALnet/EFnet
#                     UseNet - alt.irc.bots.eggdrop
# Linked IRC
# Support Channels: #RCS @UnderNet.Org
#                   #RCS @DALnet
#                   #RCS @EFnet (Not sure if this will be perm or not)
#
# Chaotix.Net has returned. More or less. Still getting things back up.
#
#   Radical Computer Systems - http://www.chaotix.net:3000/rcs/
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
#  Public:   - !yes      - !no         o vote
#     MSG:   - !yes      - !no         o vote
#     DCC:   - vote
#
# Public Matching: N/A
#

set vote(ver) "v1.01.02"

# This is the time in minutes that a vote will last.
set vote(timelimit) 1

# [1/2] Select display type
set vote(display) 3

##### Starting vote format displays #######################################
# Variables: 
#  %question% - The vote question
#  %tag% - Header tag (IE: OP's Only)
#  %cmdchar% - Command charactor used to trigger yes/no
#  %timelimit% - given time limit
#  %ver% - Script version	%chan% - Voting channel
#  \001 \002 \026 - variouse highlighting control codes.

set vote_displays(1) {
 {-: \002Vote Active\002 :-}
 {\026 Question: \026 %question% %tag%}
 {To vote, type/msg %cmdchar%yes or %cmdchar%no. You have %timelimit% minutes.}
                     }
set vote_displays(2) {
 { .--:\[\026 %chan% Vote Activated \026\]:------------ --- -- -}
 {( \002-\002:\002-\002 \002%question%\002 %tag%}
 {`--:\[ \002To vote, type/msg %cmdchar%yes or %cmdchar%no. %timelimit% min limit\002 \]:----- --- -- -}
                      }
set vote_displays(3) {
 {\026 %chan% Vote: \026 \002%question%\002}
 {\002To vote, type/msg %cmdchar%yes or %cmdchar%no. You have %timelimit% minutes}
                     }


##### Starting vote format displays #######################################
# Variables: 
#  %question% - The vote question
#  %ver% - Script version	%chan% - Voting channel
#  %yes% - Number of Yes votes	%yesp% - Percantage of Yes votes
#  %no% - Number of No votes	%nop% - Percantage of No votes
#  \001 \002 \026 - variouse highlighting control codes.

set vote_displaye(1) {
 {-: \002Vote Ended\002 :-}
 {\026 Question  : \026 %question%}
 {\026 Vote Tally: \026 \002Yes;\002 %yes%   \002No;\002 %no%}
 {QuickVote %ver% by David Proper (DrN)}
                      }
set vote_displays(2) {
 { .--:\[\026 %chan% Vote Ended \026\]:------------ --- -- -}
 {( -:- \002Vote Tally:  \026 Yes \026 %yes%   \026 No \026 %no%\002}
 { `--:\[ \002QuickVote %ver% by David Proper (DrN)\002 \]:----- --- -- -}
                      }
set vote_displaye(3) {
 {\026 Time is up! \026}
 {Vote results:}
 { Yes %yes% (%yesp%)}
 {  No %no% (%nop%)}
 {End of vote!}
                     }

set cmdchar_ "!"

proc cmdchar { } {
 global cmdchar_
 return $cmdchar_
}

bind msg - vote msg_vote
proc msg_vote {nick uhost hand args} {
global vote
 set args [lindex $args 0]
 if {([string index [lindex $args 0] 0] != "#")} {putserv "notice $nick :Calling Syntax: vote #channel Question"
                                                  return 0}
 pub_vote $nick $uhost $hand [lindex $args 0] [lrange $args 1 end]
 }

bind dcc o|o vote dcc_vote
proc dcc_vote {handle idx args} {
 global vote
 set chan [string tolower [lindex [console $idx] 0]]

 pub_vote $idx * $handle $chan [lindex $args 0]
                                }


bind pub o|o [cmdchar]vote pub_vote
proc pub_vote {nick uhost hand chan rest} {
 global vote vote_displays
 if {$rest == ""} {vote_out $nick "Calling Syntax: [cmdchar]vote Question"
                   vote_out $nick "Include +oponly to indicate only OPs may vote."
                   vote_out $nick "vote nick/sitemask +ban  to start a vote2ban"
                   vote_out $nick "vote nick/sitemask +pban  to start a vote2permban"
                   vote_out $nick "vote nick/sitemask +gban  to start a vote2globalpermban"
                   vote_out $nick "vote nick +op  to start a vote4ops"
                   vote_out $nick "vote nick +pop  to start a vote4permchanops"
                   vote_out $nick "vote nick +gop  to start a vote4globalops"

                   vote_out $nick "vote nick/sitemask -ban  to start a vote2unban"
                   vote_out $nick "vote nick/sitemask -pban  to start a vote2unpermban"
                   vote_out $nick "vote nick/sitemask -gban  to start a vote2globalunpermban"
                   vote_out $nick "vote nick -op  to start a vote4deops"
                   vote_out $nick "vote nick -pop  to start a vote4permchandeops"
                   vote_out $nick "vote nick -gop  to start a vote4globaldeops"
                   vote_out $nick "abort   Will abort the current vote"
                   return 0}
 
 if {[string toupper $rest] == "ABORT"} {
  if {$vote(timer) == ""} {vote_out $nick "There dosn't appear to be a vote going on."; return 0}
 putlog "Vote Aborted by $nick."
 putserv "PRIVMSG $vote(chan) :Vote Aborted by $nick"
 killtimer $vote(timer)
 set vote(timer) ""
 set vote(question) ""
 return 0
                                        }
 if {$vote(question) != ""} {vote_out $nick "There is allready a vote going on."
                   return 0}

 set vote(chan) $chan
 set vote(ban) ""
 set vote(bantype) 0
 set vote(oponly) 0
 set vote(nick) ""
 set vote(sitemask) ""
 set vote(optype) 0
 set cpos [lsearch -glob "$rest" "+oponly"]
  if {$cpos != -1} {
   set rest "[lrange $rest 0 [expr $cpos - 1]] [lrange $rest [expr $cpos + 1] end]"
   set vote(oponly) 1
                   }


 if {[lsearch -glob "$rest" "+ban"] != -1} {
   set vote(bantype) 1
   set cpos [lsearch -glob "$rest" "+ban"]
                                          }
 if {[lsearch -glob "$rest" "+pban"] != -1} {
   set vote(bantype) 2
   set cpos [lsearch -glob "$rest" "+pban"]
                                          }
 if {[lsearch -glob "$rest" "+gban"] != -1} {
   set vote(bantype) 3
   set cpos [lsearch -glob "$rest" "+gban"]
                                          }

 if {[lsearch -glob "$rest" "-ban"] != -1} {
  set vote(bantype) 11
  set cpos [lsearch -glob "$rest" "-ban"]
                                         }
if {[lsearch -glob "$rest" "-pban"] != -1} {
   set vote(bantype) 12
   set cpos [lsearch -glob "$rest" "-pban"]
                                          }
 if {[lsearch -glob "$rest" "-gban"] != -1} {
   set vote(bantype) 13
   set cpos [lsearch -glob "$rest" "-gban"]
                                          }

  if {$cpos != -1} {
   set rest "[lrange "$rest" 0 [expr $cpos - 1]] [lrange $rest [expr $cpos + 1] end]"
   if {[llength $rest]>1} {vote_out $nick "Calling Syntax for Ban Vote: Nick +ban"
                          return 0}
   while {[string index "$rest" [expr [string length $rest] -1]] == " "} {
    set rest [string range $rest 0 [expr [string length $rest] - 2]]
                                                               }
   if {[onchan $rest $vote(chan)]} {#vote_out $nick "$rest Is not on channel $vote(chan)"
                                     #return 0
               set sitemask "*!*[string trimleft [getchanhost $rest $vote(chan)] *!]"
#    set sitemask "*!*[string trimleft [strictmaskhost $rest $vote(chan)] *!]"
                                    } else {
   set sitemask $rest
   if {(![string match -nocase "*!*" "$sitemask"]) ||
       (![string match -nocase "*@*" "$sitemask"])} {vote_out $nick "$sitemask is either not on the channel or is an invalid banmask."; return 0 }
                                            }

   set thand [nick2hand $rest]
   if {[vote_userchk $thand]} {vote_out $nick "Sorry, You can not vote to ban a user with this access level."
                                              return 0}
   set vote(ban) "$sitemask $rest"
   if {($vote(bantype)==1) && ([ischanban $sitemask $vote(chan)])} {vote_out $nick "Sorry, $sitemask is allready banned on $vote(chan)."
                                                   return 0}
   if {($vote(bantype)==2) && ([isban $sitemask $vote(chan)])} {vote_out $nick "Sorry, $sitemask is allready banned."
                                                   return 0}
   if {($vote(bantype)==3) && ([isban $sitemask])} {vote_out $nick "Sorry, $sitemask is allready banned."
                                                   return 0}
   if {($vote(bantype)==11) && (![ischanban $sitemask $vote(chan)])} {vote_out $nick "Sorry, $sitemask isn't banned on $vote(chan)."
                                                   return 0}
   if {($vote(bantype)==12) && (![isban $sitemask $vote(chan)])} {vote_out $nick "Sorry, $sitemask isn't banned."
                                                   return 0}
   if {($vote(bantype)==13) && (![isban $sitemask])} {vote_out $nick "Sorry, $sitemask isn't banned."
                                                   return 0}
   switch $vote(bantype) {
   "1" {set vote(question) "Should $rest be banned from $vote(chan)?"}
   "2" {set vote(question) "Should $rest be banned from $vote(chan) forever?"}
   "3" {set vote(question) "Should $rest be banned from all channels I'm in forever?"}
   "11" {set vote(question) "Should $rest be unbanned from $vote(chan)?"}
   "12" {set vote(question) "Should $rest be unbanned from $vote(chan)"}
   "13" {set vote(question) "Should $rest be unbanned from all channels I'm in?"}
                         }
                   }

 set cpos [lsearch -glob "$rest" "+op"]
if {$cpos != -1} {set vote(optype) 1}

 if {[lsearch -glob "$rest" "+pop"] != -1} {
   set vote(optype) 2
   set cpos [lsearch -glob "$rest" "+pop"]
                                          }
 if {[lsearch -glob "$rest" "+gop"] != -1} {
   set vote(optype) 3
   set cpos [lsearch -glob "$rest" "+gop"]
                                          }

 if {[lsearch -glob "$rest" "-op"] != -1} {
   set cpos [lsearch -glob $rest "-op"]
   set vote(optype) 11
                                        }
 if {[lsearch -glob "$rest" "-pop"] != -1} {
   set vote(optype) 12
   set cpos [lsearch -glob "$rest" "-pop"]
                                          }
 if {[lsearch -glob "$rest" "-gop"] != -1} {
   set vote(optype) 13
   set cpos [lsearch -glob "$rest" "-gop"]
                                          }

  if {$cpos != -1} {
   set rest "[lrange "$rest" 0 [expr $cpos - 1]] [lrange $rest [expr $cpos + 1] end]"
   if {[llength $rest]>1} {vote_out $nick "Calling Syntax for Vote2OP: Nick +op"
                          return 0}
   while {[string index "$rest" [expr [string length $rest] -1]] == " "} {
    set rest [string range "$rest" 0 [expr [string length $rest] - 2]]
                                                               }

   if {($vote(optype)<10) && ![onchan $rest $vote(chan)]} {vote_out $nick "$rest Is not on channel $vote(chan)"
                                     return 0}

   if {$vote(optype)<10} {set thand [nick2hand $rest]} else {
    if {![validuser $rest]} {vote_out $nick "$rest isn't in my userlist"; return 0}
    set thand $rest
                                                             }
#   if {[matchattr $thand o]} {vote_out $nick "$rest is allready a global OP."
#                             return 0}

   if {($vote(optype) == 1) && ([isop $rest $chan] == 1)} {vote_out $nick "$rest is allready OPed non $chan."
                                                           return 0}
   if {($vote(optype) == 2) && ([matchchanattr $thand |o $chan] == 1)} {vote_out $nick "This user is allready an OP on $chan."
                                                                     return 0}
   if {($vote(optype) == 3) && ([matchattr $thand o] == 1)} {vote_out $nick "This user is allready a global OP."
                                                                     return 0}

   if {($vote(optype) == 11) && (![isop $rest $chan] == 1)} {vote_out $nick "$rest is not OPed on $chan."
                                                           return 0}
   if {($vote(optype) == 12) && (![matchchanattr $thand |o $chan] == 1)} {vote_out $nick "This user is not an OP on $chan."
                                                                     return 0}
   if {($vote(optype) == 13) && (![matchattr $thand o] == 1)} {vote_out $nick "This user is not a global OP."
                                                                     return 0}

   set sitemask "*!*[string trimleft [getchanhost $rest $vote(chan)] *!]"
#   set sitemask "*!*[string trimleft [strictmaskhost $rest $vote(chan)] *!]"
   set vote(sitemask) "$sitemask"
   set vote(nick) $rest
   switch $vote(optype) {
   "1" {set vote(question) "Should $rest be OPed in $vote(chan)?"}
   "2" {set vote(question) "Should $rest be a regular OP for $vote(chan)?"}
   "3" {set vote(question) "Should $rest be a global OP?"}
   "11" {set vote(question) "Should $rest be DeOPed in $vote(chan)?"}
   "12" {set vote(question) "Should $rest be DeOPed on $vote(chan)?"}
   "13" {set vote(question) "Should $rest be globally DeOPed?"}
                        }
                   }

 if {$vote(question) == ""} {set vote(question) $rest}

 set vote(yes) 0
 set vote(no) 0
 set vote(voters) ""

 if {[isnum $nick]} { putlog "[idx2hand $nick] Started vote for $chan: $vote(question)"
                    } else {putlog "$nick Started vote for $chan: $vote(question)"}

if {$vote(oponly)} {set tagmsg "(OPs Only)"} else {set tagmsg ""}


if {![info exists vote_displays($vote(display))]} {putlog "VOTE ERROR: display start format #$vote(display) is not defined!"; return 0}

foreach line $vote_displays($vote(display)) {
 regsub -all {%question%} $line "$vote(question)" line
 regsub -all {%tag%} $line "$tagmsg" line
 regsub -all {%cmdchar%} $line "[cmdchar]" line
 regsub -all {%timelimit%} $line "$vote(timelimit)" line
 regsub -all {%ver%} $line "$vote(ver)" line
 regsub -all {%chan%} $line "$vote(chan)" line
 regsub -all {\\001} $line \001 line
 regsub -all {\\002} $line \002 line
 regsub -all {\\026} $line \026 line
 putserv "PRIVMSG $vote(chan) :$line"
}

 set vote(timer) [timer [expr $vote(timelimit) + 1] vote_end]
}

proc vote_userchk {hand} {
global vote
 if {([matchattr $hand o] == 1) ||
     ([matchchanattr $hand o $vote(chan)] == 1) ||
     ([matchattr $hand b] == 1) ||
     ([matchattr $hand m] == 1) ||
     ([matchchanattr $hand m $vote(chan)] == 1)} {return 1} else {return 0}

}

proc vote_end {} {
 global vote botnick vote_displaye
 set chan $vote(chan)
putlog "Vote Ended. $vote(yes) for yes, $vote(no) for no."
set sitemask $vote(sitemask)
set vote(timer) ""


if {![info exists vote_displaye($vote(display))]} {putlog "VOTE ERROR: display end format #$vote(display) is not defined!"; return 0}

set yesvotes $vote(yes)
set novotes $vote(no)
set totvotes [expr $vote(yes) + $vote(no)]

set yesp 0; set nop 0
if {($yesvotes > 0)} {set yesp [expr (${vote(yes)}.0 / ${totvotes}.0) * 100]}
if {($novotes > 0)} {set nop [expr (${vote(no)}.0 / ${totvotes}.0) * 100]}
#putlog "yes:$yesvotes no:$novotes tot:$totvotes yes%:$yesp no%:$nop"
foreach line $vote_displaye($vote(display)) {
 regsub -all {%question%} $line "$vote(question)" line
 regsub -all {%yes%} $line "$vote(yes)" line
 regsub -all {%no%} $line "$vote(no)" line
 regsub -all {%yesp%} $line "$yesp%" line
 regsub -all {%nop%} $line "$nop%" line
 regsub -all {%ver%} $line "$vote(ver)" line
 regsub -all {%chan%} $line "$vote(chan)" line
 regsub -all {\\001} $line \001 line
 regsub -all {\\002} $line \002 line
 regsub -all {\\026} $line \026 line
 putserv "PRIVMSG $vote(chan) :$line"
}


 set vote(question) ""
 if {$vote(ban) != ""} {
           if {$vote(yes) > $vote(no)} {
                        set sitemask [lindex $vote(ban) 0]
                        if {$vote(bantype) == 1} {
                         putserv "mode $vote(chan) +b [lindex $vote(ban) 0]"
                         putserv "KICK $vote(chan) [lindex $vote(ban) 1] :Vote was in favor of you being banned. Goodbye."
                                                 }
                        if {$vote(bantype) == 2} {newchanban $vote(chan) $sitemask QuickVote "Voted to be banned $vote(yes) to $vote(no)"}
                        if {$vote(bantype) == 3} {newban $sitemask QuickVote "Voted to be banned $vote(yes) to $vote(no)"}
                        if {$vote(bantype) == 11} {
                         putserv "mode $vote(chan) -b [lindex $vote(ban) 0]"
                         killchanban $vote(chan) $sitemask
                                                 }
                         if {$vote(bantype) == 12} {killchanban $vote(chan) $sitemask}
                        if {$vote(bantype) == 13} {killban $sitemask}
                                        }
                       }
 if {$vote(optype) > 0} {
           if {$vote(yes) > $vote(no)} {
 if {$vote(optype) == 1} {
                          putserv "mode $vote(chan) +o $vote(nick)"
                          return 1
                         }
 if {$vote(optype) == 11} {
                          putserv "mode $vote(chan) -o $vote(nick)"
                          return 1
                         }
 set thand [nick2hand $vote(nick)]

 if {[validuser $thand] == 1} {
  if {[lsearch [gethosts $thand] $vote(sitemask)] == "-1"} {addhost $thand $vote(sitemask)
                                                            set vote(nick) $thand}
                                   } else {adduser $vote(nick) $vote(sitemask)}
                                       }
  switch $vote(optype) {
   2 {addchanrec $vote(nick) $vote(chan)
      chattr $vote(nick) +p|+of $vote(chan)
     }
   3 {chattr $vote(nick) +ofp}
   12 {chattr $vote(nick) +p|-o $vote(chan)
     }
   13 {chattr $vote(nick) -o}
                       }
 if {$vote(optype) > 0} {
  putserv "NOTICE $vote(nick) :Congradulations $vote(nick)."
  putserv "NOTICE $vote(nick) :Please set a password: ^B/msg $botnick pass <password>^B"
  putserv "NOTICE $vote(nick) :where <password> is your selected password."
  putserv "NOTICE $vote(nick) :You can get ops by: ^B/msg $botnick op <password>^B"
  save
                        }
                            }

}

bind msg - [cmdchar]yes msg_voteyes
proc msg_voteyes {nick uhost hand args} {
 castvote $nick $hand yes
                                        }

bind pub - [cmdchar]yes pub_voteyes
proc pub_voteyes {nick uhost hand chan rest} {
 castvote $nick $hand yes
}

bind msg - [cmdchar]no msg_voteno
proc msg_voteno {nick uhost hand args} {
# pub_voteno $nick $uhost $hand $nick $args 
 castvote $nick $hand no
                                        }

bind pub - [cmdchar]no pub_voteno
proc pub_voteno {nick uhost hand chan rest} {
 global vote
 castvote $nick $hand no
                                             }

proc castvote {nick hand cvote} {
global vote

if {$vote(question) == ""} {putserv "notice $nick :This is no vote at this time."
                            return 0}
if {[string match -nocase "*[string tolower $nick]* " "$vote(voters)"] > 0} {putserv "notice $nick :You have allready voted."
  return 0}

if {$vote(oponly) == 1} {
  if {([matchattr $hand o] == 0) && ([matchchanattr $hand o $vote(chan)] == 0)} {
    vote_out $nick "Sorry, this vote is for OPs of $vote(chan) only."
    return 0}
                        }

putserv "notice $nick :Vote Cast!"
incr vote($cvote)
append vote(voters) "[string tolower $nick] "
                                             }
# isnumber taken from alltools.tcl
proc isnum {string} {
  if {([string compare $string ""]) && (![regexp \[^0-9\] $string])} then {return 1}
  return 0
}


proc vote_out {nick text} {
 if {[isnum $nick]} {putidx $nick "$text"} else {putserv "NOTICE $nick :$text"}
}

# Script modified variables, don't dick with them. :)
set vote(question) ""
set vote(oponly) 0
set vote(ban) ""
set vote(bantype) 0
set vote(nick) ""
set vote(sitemask) ""
set vote(timer) ""

putlog "QuickVote $vote(ver) by David Proper (DrN) -: LoadeD :-"
return "QuickVote $vote(ver) by David Proper (DrN) -: LoadeD :-"

