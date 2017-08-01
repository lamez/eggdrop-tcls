##  
### What is this?
##  
#            Lamer.tcl V1.0 [24.11.2001] tested on 1.6.x
#                  by acenoid ace@clan-octagon.de
#
# Greetings to:
# Shasta, Sup & Johoho for introducing me to TCL!
# and all other folks @ #eggdrop !
#
##
### Overview / Installation
##
# 
# This small TCL bans and then kicks users that you specify in a
# public command, so they will not auto-rejoin. Please note that
# this script is not tested very well yet.
#
# Please send me comments, flames, suggestions and questions if you 
# have any. Tell me if you think that this tcl is useful. Please 
# give me credit, if you use the code or any parts of it in your tcl.
#
# To install the script simply put the following line into your 
# eggdrop.conf file: "source scripts/lamer.tcl" and copy lamer.tcl to 
# /path/to/eggdrop/scripts on your shell.
#
# Next time your bot restarts / rehashs the script gets loaded.
#
## 
### Disclaimer
## 
# Of course I cannot take any responsibility if this Script damages 
# your hard- software etc. in any way. Use it at your own risk.
#
##  
### New Commands
##  
# Public Commands:
# !lamer <nick1> <nick2> <nick3> <...>
#
##
### Bugs / Limitations / Planned
##
#
# ./. 
#
##
### Configuration
##
#

# How long (in minutes) do you want to have the user banned from your
# channel?
set lmrbt "60"

# What Channels should I work on? Ex. #octagon #eggdrop Leave empty
# to enable on all channels the bot is on.
set lmrchn ""

# Flags of users who are protected (default "bomn|omn")
set lmrflg "bomn|omn"

##
### End of the configuration. 
##

## Who I am ##
set lmr(version) "V1.0"
set lmr(rdate) "Sat 24 Nov 2001"

## Public Bindings ##
bind pub o|o !lamer lmr:kb

## Procs ##
proc lmr:kb {nick uhost hand chan who} {
   global lmrbt lmrchn lmrflg botnick
   if {(($lmrchn == "") || ([lsearch -exact $lmrchn [string tolower $chan]] != -1)) } {
      if {[botisop $chan]} {
         if { $who != "" } {
            foreach targets $who {   
               set bwho [nick2hand $targets $chan]
               set bmatch [matchattr $bwho $lmrflg $chan]
               set bonchan [onchan $targets $chan]
               if { [string tolower $targets] != [string tolower $botnick] && $bmatch != "1" && $bonchan == "1" } { 
                  set bhost [getchanhost $targets $chan]
                  newchanban $chan *!*$bhost $nick lmr-ban $lmrbt
                  utimer 2 "putkick $chan $targets"
               } else { 
                  putlog "$nick on $chan failed to lmr-ban $targets"
               }
            }
         }
      }
   }
}

## Report that iam here
putlog "LMR: Lamer.tcl $lmr(version) - $lmr(rdate) by acenoid (ace@clan-octagon.de) loaded sucessfully."

# Version History
# 24.11. V1.0
#        * initial release