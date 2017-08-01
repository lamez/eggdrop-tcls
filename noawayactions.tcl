# noawayactions.tcl v1.03 [11 November 2000] 
# Copyright (C) 1999-2000 Teemu Hjelt <temex@iki.fi>
#
# Latest version can be found from http://www.iki.fi/temex/eggdrop/
# 
# If you have any suggestions, questions or you want to report 
# bugs, please feel free to send me email to temex@iki.fi
#
# This script punish people who use away 
# actions on the channels you have specified. 
#
# Tested on eggdrop1.4.4 with TCL 7.6
#
# Version history:
# v1.00 - The very first version!
# v1.01 - Little bug in ctcp:naa_action proc fixed.
# v1.02 - The user can now also be given a   
#         warning when (s)he uses away actions.
# v1.03 - Fixed a very minor bug in the ctcp:naa_action proc.

## Punish people who are using away actions on the following channels.
# Note: Set this to "" to enable punishing on all channels.
set naa_chans "#lamest #botcentral"

## What is the reason for the punishment?
set naa_reason "Don't use away actions!"

## [0/1] Kick the user?
set naa_kick 1

## [0/1] Give the user a warning?
set naa_givewarning 1

## Give what kind of warning?
# Note: You can use %chan to indicate the name of the 
# channel and %nick to indicate the nick of the user.
set naa_warning "Away actions are forbidden on %chan, so please don't use them."

## [0/1] Ban the user?
set naa_ban 1

## Ban for how long time (min)?
set naa_bantime 10

## [0/1] Ignore the user?
set naa_ignore 0

## Ignore for how long time (min)?
set naa_ignoretime 10

## People with the following global flags can use away actions. 
set naa_globflags "m n o"

## People with the following channel flags can use away actions.
set naa_chanflags "m n o"

###### You don't need to edit below this ######

### Misc Things ###

set naa_ver "1.03"

### Bindings ###

bind ctcp - ACTION ctcp:naa_action

### Procs ###

proc ctcp:naa_action {nick uhost hand dest key arg} {
global botnick naa_chans naa_globflags naa_chanflags
	if {[string tolower $nick] != [string tolower $botnick]} {
		foreach globflag $naa_globflags { if {[matchattr $hand $globflag]} { return 1 } }
		foreach chanflag $naa_chanflags { if {[matchattr $hand |$chanflag $dest]} { return 1 } }
		if {(naa_chans == "") || ([lsearch -exact [split [string tolower $naa_chans]] [string tolower $dest]] != -1)} {
			if {([string match "*away*" [string tolower $arg]]) || ([string match "*gone*" [string tolower $arg]])} {
				naa_punish $nick $uhost $dest
			}
		}
	}
}

proc naa_punish {nick uhost chan} {
global botnick naa_chans naa_reason naa_kick naa_givewarning naa_warning naa_ban naa_bantime naa_ignore naa_ignoretime
set hostmask "*!*[string range $uhost [string first "@" $uhost] end]"
set dowhat ""
	if {[string tolower $nick] != [string tolower $botnick]} {
		if {$naa_givewarning} { 
			lappend dowhat "giving warning"
			set warning $naa_warning
			regsub -all -- "%chan" $warning $chan warning
			regsub -all -- "%nick" $warning $nick warning
			putserv "NOTICE $nick :$warning" 
		}
		if {($naa_ignore) && (![isignore $hostmask])} { 
			lappend dowhat "ignoring"
			newignore $hostmask $botnick $naa_reason $naa_ignoretime 
		}
		if {($naa_ban) && (![isban $hostmask $chan]) && ([onchan $nick $chan])} {
			lappend dowhat "banning"
			newchanban $chan $hostmask $botnick $naa_reason $naa_bantime 
		}
		if {($naa_kick) && ([botisop $chan]) && ([onchan $nick $chan])} {
			lappend dowhat "kicking"
			putserv "KICK $chan $nick :$naa_reason" 
		}
		if {$dowhat != ""} {
			set dowhat "-- [join $dowhat " & "]"
		}
		putlog "noawayactions: $nick ($uhost) used away action on $chan $dowhat"
	}
}

### End ###

putlog "TCL loaded: noawayactions.tcl v$naa_ver by Sup <temex@iki.fi>"