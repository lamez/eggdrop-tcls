##########################################################################
# ChanToolz.tcl by ShakE <shake@abv.bg>		                         #
##########################################################################
# Edin ot nai-dobrite tcl za komandi ot roda !op !deop !rehash !adduser..#
# Napi6i v kanala !help i 6te ti izkara vsi4ki vazmojni komandi. 		 #
# Za da izpolzva6 tezi komandi parvo trqbva da se ident s 			 #
#                /msg botnick auth tvoqpass					 #
##########################################################################
# Ako imate nqkakvi vaprosi, predlojenia ili kritiki posetete foruma na	 #
# http://shake.hit.bg i pi6ete tam!                                      #
##########################################################################

##### COMMANDS USED BY THIS SCRIPT #####
proc say {who what} {
	puthelp "PRIVMSG $who :$what"
}
proc notice {who what} {
	puthelp "NOTICE $who :$what"
}
proc cleanarg {arg} {
 set temp ""
	for {set i 0} {$i < [string length $arg]} {incr i} {
  set char [string index $arg $i]
  if {($char != "\12") && ($char != "\15")} {
   append temp $char
  }
 }
 set temp [string trimright $temp "\}"]
 set temp [string trimleft $temp "\{"]
	return $temp
}

##### AUTH SECTION #####
# The auth is a protection script so that ip spoofers won't be able to
# use the commands, and take over channels. once you singoff, the auth
# will expire.
# Owners will be able to disable a user from using commands. This will
# not allow them to auth themselves.

# The binds:
bind pub n !disable pub:disable
bind pub n !enable pub:enable
bind msg - auth auth:auth
bind sign - * auth:signcheck
bind msg - deauth auth:deauth

# This is the command for owners to disable a user.
# Usage: !disable <hand>
proc pub:disable {nick host hand chan arg} {
	if {[llength $arg] < 1} {
		notice $nick "Usage: !disable <handle>"
		return 0
	}
	set who [lindex $arg 0]
	if {![validuser $who]} {
		notice $nick "$who is not a valid user."
		return 0
	}
	setuser $who XTRA AUTH "DEAD"
	notice $nick "Disabled $who"
	putcmdlog "<<$nick>> !$hand! disable $who"
}

proc pub:enable {nick host hand chan arg} {
	if {[llength $arg] < 1} {
		notice $nick "Usage: !disable <handle>"
		return 0
	}
	set who [lindex $arg 0]
	if {![validuser $who]} {
		notice $nick "$who is not a valid user."
		return 0
	}
	setuser $who XTRA AUTH 0
	notice $nick "Enabled $who"
	putcmdlog "<<$nick>> !$hand! enable $who"
}

# Usage: /msg $botnick auth <password>
proc auth:auth {nick uhost hand arg} {
	global botnick
	set found 0
	foreach n [channels] {
		if {[onchan $nick $n]} {
			set found 1
		}
	}
	if {$found == 0} {return 0}
	if {[llength $arg] <1} {
		notice $nick "Usage: /msg $botnick auth <pass>"
		return 0
	}
	set pass [lindex $arg 0]
	if {$hand == "*"} {
		say $nick "You are not permitted to use my commands."
		return 0
	}
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		say $nick "Sorry, but you have been disabled from using my commands."
		return 0
	}
	if {[passwdok $hand $pass]} {
		setuser $hand XTRA "AUTH" "1"
		putcmdlog "<<$nick>> ($uhost) !$hand! AUTH ..."
		notice $nick "Password accepted."
		return 0
	} else {
		notice $nick "Password denied."
	}
}

proc auth:signcheck {nick uhost hand chan reason} {
	if {$hand == "*"} {return 0}
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		return 0
	}
	setuser $hand XTRA "AUTH" "0"
	putlog "Auth for $hand expired."
}

proc auth:check {hand} {
	set auth [getuser $hand XTRA "AUTH"]
	if {($auth == "") || ($auth == "0") || ($auth == "DEAD")} {
		return 0
	} else { return 1}
}

proc auth:deauth {nick uhost hand arg} {
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		say $nick "Sorry, but you have been disabled from using my commands."
		return 0
	}
	if {$hand != "*"} {
		setuser $hand XTRA "AUTH" "0"
		putcmdlog "<<$nick>> ($uhost) !$hand! DEAUTH"
		notice $nick "Authentication has been removed."
	}
}

##### BINDS #############################
bind pub p !bots pub:bots
bind pub m|m !channels pub:channels
bind pub o|o !ignore pub:ignore
bind pub o|o !unignore pub:unignore
bind pub n !chanset pub:chanset
bind pub m|m !status pub:status
bind pub m|m !flags pub:flags
bind pub o|o !ignorelist pub:ignorelist
bind pub o|o !banlist pub:banlist
bind pub m !save pub:save
bind pub m !reload pub:reload
bind pub n !rehash pub:rehash
bind pub n !restart pub:restart
bind pub n !backup pub:backup
bind pub n !forcebans pub:forcebans
bind pub m !jump pub:jump
bind pub - !time pub:time
bind pub n !die pub:die
bind pub o !act pub:act
bind pub o !say pub:say
bind pub - !mode pub:mode
bind pub - !kick pub:kick
bind pub - !ban pub:ban
bind pub - !unban pub:unban
bind pub - !voice pub:voice
bind pub - !devoice pub:devoice
bind pub n !link pub:link
bind pub n !unlink pub:unlink
bind pub p !ping pub:ping
bind ctcr - PING pub:pingr
bind pub - !op pub:op
bind pub - !deop pub:deop
bind pub o|o !opme pub:opme
bind pub n !adduser pub:adduser
bind pub n !broadcast pub:broadcast
bind pub n !join pub:join
bind pub n !part pub:part
bind pub - !help pub:help
bind pub - help pub:helpa
bind pub n !chattr pub:chattr
bind pub n !deluser pub:deluser
bind pub n !addbot pub:addbot
bind pub n !rmbot pub:rmbot
bind pub n !addhost pub:addhost
bind pub n !rmhost pub:rmhost

##### BADWORD SECTION #####
# Comment out the next lines if you would like to disable badword.
# If you want to add one, just type this:
#            bind pubm - "*<your bad word>*" badword:kick
#                   BE SURE TO KEEP THE STARS (*)
# Script will not kick owners or masters of the bot.
# If you would like to use this part, uncomment the following lines
#bind pubm - "*fuck*" badword:kick
#bind pubm - "*shit*" badword:kick
#bind pubm - " ass*" badword:kick
#bind pubm - "*cunt*" badword:kick
#bind pubm - "*whore*" badword:kick
#bind pubm - "*slut*" badword:kick
#########################################

##### GLOBALS #####
set pub_pingchan ""

##### PROCS #####

# Tells someone the time and date
# Usage: !time
proc pub:time {nick host hand chan arg} {
	notice $nick "[ctime [unixtime]]"
}

# Tells the bot to stop running
# Usage: !die [reason]
proc pub:die {nick host hand chan arg} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	notice $nick "Shutting down... later!"
	putcmdlog "<<$nick>> !$hand! die $arg"
	die $arg
}

# Jumps to a new server
# Usage: !jump <server>[:port]
proc pub:jump {nick host hand chan arg} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	notice $nick "Jumping to $arg..."
	jump $arg
	putlog "<<$nick>> !$hand! jump $arg"
}

# Resets all bans to what they should be on the bot's banlist
# Usage: !forcebans
proc pub:forcebans {nick host hand chan arg} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	notice $nick "Resetting all bans to match my banlist..."
	resetbans $chan
	putcmdlog "<<$nick>> !$hand! forcebans"
}

# Rehashes the bot
# Usage: !rehash
proc pub:rehash {nick host hand chan arg} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	notice $nick "Rehashing..."
	rehash
	putcmdlog "<<$nick>> !$hand! rehash"
}

# Reloads the userfile
# Usage: !reload
proc pub:reload {nick host hand chan arg} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	notice $nick "Reloading..."
	reload
	putcmdlog "<<$nick>> !$hand! reload"
}

# Restarts the bot
# Usage: !restart
proc pub:restart {nick host hand chan arg} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	notice $nick "restart..."
	restart
	putcmdlog "<<$nick>> !$hand! restart"
}


# Saves the userfile and channel file
# Usage: !save
proc pub:save {nick host hand chan arg} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	notice $nick "Saving channel file and user file..."
	save
	putcmdlog "<<$nick>> !$hand! save"
}

# Makes a backup of the userfile
# Usage: !backup
proc pub:backup {nick host hand chan arg} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	notice $nick "Backing up the userfile..."
	backup
	putcmdlog "<<$nick>> !$hand! backup"
}


# Prints out a ban list
# Usage: !banlist
proc pub:banlist {nick host hand chan arg} {
	notice $nick "\002Global bans:\002"
	if {[banlist] == ""} {
		notice $nick "none"
	} else {
	foreach ig [banlist] {
		set what [lindex $ig 0]
		set by [lindex $ig 1]
		set comment [lindex $ig 4]
		notice $nick "$what - made by $by - $comment"
	}}
	notice $nick "\002Bans for $chan:\002"
	if {[banlist $chan] == ""} {
		notice $nick "none"
	} else {
	foreach b [banlist $chan] {
		set what [lindex $b 0]
		set by [lindex $b 5]
		set comment [lindex $b 1]
		notice $nick "$what - made by $by - $comment"
	}}
}

# Prints out an ignore list
# Usage: !ignorelist
proc pub:ignorelist {nick host hand chan arg} {
	if {[ignorelist] == ""} {
		notice $nick "I don't have any ignores."
		return 0
	}
	notice $nick "Ignore list:"
	foreach ig [ignorelist] {
		set what [lindex $ig 0]
		set by [lindex $ig 4]
		set comment [lindex $ig 1]
		notice $nick "$what - made by $by - $comment"
	}
}

# Gives the global bot flags for a person
# Usage: !flags <handle>
proc pub:flags {nick host hand chan arg} {
	if {[llength $arg]<1} {
		notice $nick "Usage: !flags <handle>"
		return 0
	}
	set who [lindex $arg 0]
	if {![validuser $who]} {
		notice $nick "I don't know who $who is."
		return 0
	}
	set flags [chattr $who]
	notice $nick "Global flags for $who: $flags"
	putcmdlog "<<$nick>> !$hand! flags $who"
}

# Gives a bunch of statistics
# Usage: !status
proc pub:status {nick host hand chan arg} {
	global server botname version
	notice $nick "\002Bot statistics:\002"
	notice $nick "User records: [countusers]"
	notice $nick "My channels: [channels]"
	notice $nick "Linked bots: [bots]"
	notice $nick "My date: [date]"
	notice $nick "My time: [time]"
	notice $nick "My operating system: [unames]"
	notice $nick "Server: $server"
	notice $nick "My host: $botname"
	notice $nick "Eggdrop version: [lindex $version 0]"
	putcmdlog "<<$nick>> !$hand! status"
}

# Changes the channel settings for a channel
# Usage: !chanset <chan> <what> [args]
proc pub:chanset {nick host hand chan arg} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	if {[llength $arg] < 2} {
		notice $nick "Usage: !chanset <#channel> <mode> \[args\]"
		return 0
	}
	set thechan [lindex $arg 0]
	set mode [lindex $arg 1]
	set a [lrange $arg 2 end]
	if {![validchan $thechan]} {
		notice $nick "I don't monitor that channel."
		return 0
	}
	channel set $thechan $mode $a
	putcmdlog "<<$nick>> !$hand! chanset $thechan $mode $a"
}

# Lists the bots on the botnet
# Usage: !bots
proc pub:bots {nick host hand chan arg} {
	set bots [bots]
	notice $nick "Bots: $bots"
	putcmdlog "<<$nick>> !$hand! bots"
}

# Lists the channels the bot is on
# Usage: !channels
proc pub:channels {nick host hand chan arg} {
	set chans [chanlist]
	notice $nick "Channels: $chans"
	putcmdlog "<<$nick>> !$hand! channels"
}

# Makes a new ignore
# Usage: !ignore <who/host> <life> <reason>
proc pub:ignore {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args] < 3} {
		notice $nick "Usage: !ignore <nick/host> <time> <reason>"
		return 0
	}
	set who [lindex $args 0]
	set time [expr [lindex $args 1]]
	set reason [lrange $args 2 end]
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		if {![onchan $who $chan]} {
			set theban $who
		} else {
			set host [getchanhost $who $chan]
			set host [maskhost $host]
			set shost [split $host "!"]
			set theban "*!*[lindex $shost 1]"
		}
		newignore $theban $nick $reason $time
		putcmdlog "<<$nick>> !$hand! ignore $args"
	} else {
		notice $nick "You can't do that!"
	}
}

# Kills an ignore
# Usage: !unignore <ignore mask>
proc pub:unignore {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		notice $nick "Usage: !unignore <host>"
		return 0
	}
	set theban [lindex $args 0]
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		killignore $theban
		putcmdlog "<<$nick>> !$hand! unignore $chan $theban"
	} else {
		notice $nick "You can't do that!"
	}
}


# Says something on any channel
# Usage: !say <chan> <what>
proc pub:say {nick host hand chan arg} {
	global botnick
	if {![auth:check $hand]} {return 0}
	if {[llength $arg] < 2} {
		notice $nick "Usage: !say <chan> <what>"
		return 0
	}
	set thechan [lindex $arg 0]
	set what [lrange $arg 1 end]
	if {![onchan $botnick $thechan]} {
		notice $nick "I'm not on that channel."
		return 0
	}
	puthelp "PRIVMSG $chan :$what"
	notice $nick "Said to $thechan: $what"
	putcmdlog "<<$nick>> !$hand! ($thechan) !say $what"
}

# Puts an action (/me) on a channel
# Usage: !act <chan> <what>
proc pub:act {nick host hand chan arg} {
	global botnick
	if {![auth:check $hand]} {return 0}
	if {[llength $arg] < 2} {
		notice $nick "Usage: !act <chan> <what>"
		return 0
	}
	set thechan [lindex $arg 0]
	set what [lrange $arg 1 end]
	if {![onchan $botnick $thechan]} {
		notice $nick "I'm not on that channel."
		return 0
	}
	puthelp "PRIVMSG $chan :\001ACTION $what\001"
	notice $nick "Act to $thechan: $what"
	putcmdlog "<<$nick>> !$hand! ($thechan) !act $what"
}

# Changes a mode on the channel
# Usage: !mode <mode change>
# Ex: !mode +m, !mode +k booger
proc pub:mode {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [cleanarg $args]
	if {[llength $args]<1} {
		notice $nick "Usage: !mode <mode change>"
		return 0
	}
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		putserv "MODE $chan $args"
		putcmdlog "<<$nick>> !$hand! mode $args"
	} else {
	notice $nick "You can't do that!"
	}
	
}

# Kicks someone off the channel
# Usage: !kick <nick> <reason>
# Ex: !kick Joe You suck!
proc pub:kick {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args] < 2} {
		notice $nick "Usage: !kick <nick> <reason>"
		return 0
	}
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		set who [lindex $args 0]
		set reason [lrange $args 1 end]
		putserv "KICK $chan $who :$reason"
		putcmdlog "<<$nick>> !$hand! kick $args"
	} else {
		notice $nick "You can't do that!"
	}
}

# Bans a nick/host off the channel
# Usage: !ban <nick/host> <time> <reason>
#	nick/host :If you put a nick in, it will mask the host, but if you
#		put a host in, it will ban the host.
#	time: The time the ban will last (in minutes). 0 for permanent.
proc pub:ban {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args] < 3} {
		notice $nick "Usage: !ban <nick/host> <time> <reason>"
		return 0
	}
	set who [lindex $args 0]
	set time [expr [lindex $args 1]]
	set reason [lrange $args 2 end]
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		if {![onchan $who $chan]} {
			set theban $who
		} else {
			set host [getchanhost $who $chan]
			set host [maskhost $host]
			set shost [split $host "!"]
			set theban "*!*[lindex $shost 1]"
		}
		newchanban $chan $theban $nick $reason $time
		putcmdlog "<<$nick>> !$hand! ban $args"
	} else {
		notice $nick "You can't do that!"
	}
}

# Unbans a host from the channel
# Usage: !unban <host>
proc pub:unban {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		notice $nick "Usage: !unban <host>"
		return 0
	}
	set theban [lindex $args 0]
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		killchanban $chan $theban
		putcmdlog "<<$nick>> !$hand! unban $chan $theban"
	} else {
		notice $nick "You can't do that!"
	}
}

# Adds a user
# Usage: !adduser <nick> [host]
#	If you leave out 'host', it will take the 'nick', and mask a host.
proc pub:adduser {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	global botnick admin
	if {[llength $args]<1} {
		notice $nick "Usage: !adduser <nick> \[host\]"
		return 0
	}
	if {$nick == $botnick} {return 0}
	if {[getting-users]} {
		notice $nick "Sorry, there is currently a userfile transfer going on. Try back in a couple of seconds."
		return 0
	}
	set who [lindex $args 0]
	if {[llength $args]==2} {
		set host [lindex args 1]
	} else {
		if {![onchan $who $chan]} {
			say $chan "$nick: $who is not on this channel."
			return 0
		}
		set host [maskhost [getchanhost $who $chan]]
	}
	set err [adduser $who $host]
	if {$err == 0} {
		say $chan "That nick already exists."
		return 0
	}
	putcmdlog "<<$nick>> !$hand! adduser $who $host"

	if {![onchan $who $chan]} {return 0}
	notice $who "Your account has been added with the hostmask $host."
	notice $who "Type /msg $botnick PASS <yourpass> to set your password."
	notice $who "After you have set your password, type /dcc chat $botnick to start a dcc chat session."
	notice $who "If you have any problems, please contact $admin"
}

# Gives someone voice in the channel
# Usage: !voice <nick>
proc pub:voice {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		notice $nick "Usage: !voice <nick>"
		return 0
	}
	set who [lindex $args 0]
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		putserv "MODE $chan +v $who"
	} else {
		notice $nick "You can't do that!"
	}
	putcmdlog "<<$nick>> !$hand! voice $chan $who"
}

# Takes away voice from someone in the channel
# Usage: !devoice <nick>
proc pub:devoice {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		notice $nick "Usage: !devoice $nick"
		return 0
	}
	set who [lindex $args 0]
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		putserv "MODE $chan -v $who"
	} else {
		notice $nick "You can't do that!"
	}
	putcmdlog "<<$nick>> !$hand! devoice $chan $who"
}

# Trys to link to another bot
# Usage: !link <bot>
proc pub:link {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		notice $nick "Usage: !link <bot>"
		return 0
	}
	if {[getting-users]} {
		notice $nick "Sorry, there is currently a userfile transfer going on. Try back in a couple of seconds."
		return 0
	}
	set who [lindex $args 0]
	say $chan "$nick: Trying to link to $who..."
	set err [link $who]
	if {$err == 0} {
		say $chan "$nick: An error occured."
	}
}

# Unlink from a bot
# Usage: !unlink <bot>
proc pub:unlink {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		notice $nick "Usage: !unlink <bot>"
		return 0
	}
	if {[getting-users]} {
		notice $nick "Sorry, there is currently a userfile transfer going on. Try back in a couple of seconds."
		return 0
	}
	set who [lindex $args 0]
	say $chan "$nick: Trying to unlink from $who..."
	set err [link $who]
	if {$err == 0} {say $chan "AAAH! An error occured!"}
	if {$err == 1} {say $chan "And... SUCCESS!"}
}

# Pings a person from the bot
# Usage: !ping <nick>
proc pub:ping {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		set who $nick
	} else {
		set who [lindex $args 0]
	}
	global pub_pingchan
	set time [unixtime]
	say $who "\001PING $time\001"
	set pub_pingchan $chan
	putcmdlog "<<$nick>> !$hand! PING $who : $time"
}

# This is the ping reply function.
proc pub:pingr {nick uhost hand dest keyword args} {
	global pub_pingchan
	set temp [unixtime]
	set time [expr $temp - $args]
	putlog "PING reply from $nick: $time seconds"
	say $pub_pingchan "PING reply from $nick: $time seconds"
}

# Op someone in the channel
# Usage: !op <nick>
proc pub:op {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args] == 0 && ([matchattr $hand n] || [matchattr $hand "|n" $chan] || [matchattr $hand o $chan] || [matchattr $hand "|o" $chan])} {
		putserv "MODE $chan +o $nick"
	}
	if {[llength $args]<1} {
		notice $nick "Usage: !op <nick>"
		return 0
	}
	set who [lindex $args 0]
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		putserv "MODE $chan +o $who"
		putcmdlog "<<$nick>> !$hand! op $chan $who"
	} else {
		notice $nick "You can't do that!"
	}
}

# Deop someone in the channel
# Usage: !deop <nick>
proc pub:deop {nick uhost hand chan args} {
	if {(![auth:check $hand]) && (![isop $nick $chan])} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		notice $nick "Usage: !deop <nick>"
		return 0
	}
	set who [lindex $args 0]
	if {$hand == "*"} {return 0}
	if {([isop $hand $chan]) || ([matchattr $hand "|o" $chan]) || ([matchattr $hand "o"])} {
		putserv "MODE $chan -o $who"
		putcmdlog "<<$nick>> !$hand! deop $chan $who"
	} else {
		notice $nick "You can't do that!"
	}
}

# Ops you if you have op status on the bot
# Usage: !opme
proc pub:opme {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	putserv "MODE $chan +o $nick"
}

# Broadcasts a message to every channel the bot is on
# Usage: !broadcast <message>
# Ex: !broadcast The bot is coming down now!
proc pub:broadcast {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set msg [cleanarg $args]
	foreach n [channels] {
		say $n $msg
	}
}

# Makes the bot join a channel
# Usage: !join <#channel>
proc pub:join {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [cleanarg $args]
	if {[llength $args]<1} {
		notice $nick "Usage: !join <#channel>"
		return 0
	}
	channel add $args {+greet -bitch -autoop -bitch -stopnethack}
}

# Makes the bot part a channel
proc pub:part {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [cleanarg $args]
	if {[llength $args]<1} {
		notice $nick "Usage: !part <#channel>"
		return 0
	}
	channel remove $args
}

# Changes the attr of a user
# Usage: !chattr <nick> <options> [channel]
proc pub:chattr {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<2} {
		notice $nick "Usage: !chattr <handle> <options> \[channel\]"
		return 0
	}
	if {[getting-users]} {
		notice $nick "Sorry, there is currently a userfile transfer going on. Try back in a couple of seconds."
		return 0
	}
	set who [lindex $args 0]
	set modes [lindex $args 1]
	set channel ""
	if {[llength $args]==3} {
		set channel [lindex $args 2]
		set temp "|"
		append temp $modes
		set modes $temp
	}
	if {$channel != ""} {
		set rt [chattr $who $modes $channel]
	} else {
		set rt [chattr $who $modes]
	}
	putcmdlog "<<$nick>> !$hand! chattr $args"
	if {$channel != ""} {
		set rt [lindex [split $rt "|"] 1]
		say $chan "Modes for $who on $channel are now $rt"
	} else {
		say $chan "Global modes for $who are now $rt"
	}
}

# Deletes a user record
# Usage: !deluser <handle>
proc pub:deluser {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		notice $nick "Usage: !deluser <handle>"
		return 0
	}
	if {[getting-users]} {
		notice $nick "Sorry, there is currently a userfile transfer going on. Try back in a couple of seconds."
		return 0
	}
	set who [lindex $args 0]
	set err [deluser $who]
	if {$err == 0} {
		say $chan "Attempt to remove $who failed."
		return 0
	}
	putcmdlog "<<$nick>> !$hand! deluser $who"
}

# Adds a bot
# Usage: !addbot <handle> <address:port>
proc pub:addbot {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<2} {
		notice $nick "Usage: !addbot <handle> <address:port>"
		return 0
	}
	if {[llength [split [lindex $args 1] ":"]]!=2} {
		notice $nick "Usage: !addbot <handle> <address:port>"
		return 0
	}
	if {[getting-users]} {
		notice $nick "Sorry, there is currently a userfile transfer going on. Try back in a couple of seconds."
		return 0
	}
	set addr [lindex $args 1]
	set who [lindex $args 0]
	addbot $who $addr
	putcmdlog "<<$nick>> !$hand! addbot $who $addr"
}

# Removes a bot
# Usage: !rmbot <handle>
proc pub:rmbot {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
		notice $nick "Usage: !rmbot <handle>"
		return 0
	}
	if {[getting-users]} {
		notice $nick "Sorry, there is currently a userfile transfer going on. Try back in a couple of seconds."
		return 0
	}
	set who [lindex $args 0]
	deluser $who
	putcmdlog "<<$nick>> !$hand! rmbot $who"
}

# Adds hostmask for user
# Usage: !addhost <handle> <host>
proc pub:addhost {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<2} {
		notice $nick "Usage: !addhost <handle> <host>"
		return 0
	}
	if {[getting-users]} {
		notice $nick "Sorry, there is currently a userfile transfer going on. Try back in a couple of seconds."
		return 0
	}
	set who [lindex $args 0]
	set host [lindex $args 1]
	setuser $who HOSTS $host
	putcmdlog "<<$nick>> !$hand! addhost $who $host"
}

# Removes host from user
# Usage: !rmhost <handle> <host>
proc pub:rmhost {nick uhost hand chan args} {
	if {![auth:check $hand]} {return 0}
	set args [split [cleanarg $args]]
	if {[llength $args]<2} {
		notice $nick "Usage: !rmhost <handle> <host>"
		return 0;
	}
	if {[getting-users]} {
		notice $nick "Sorry, there is currently a userfile transfer going on. Try back in a couple of seconds."
		return 0
	}
	set who [lindex $args 0]
	set host [lindex $args 1]
	delhost $who $host
	putcmdlog "<<$nick>> !$hand! rmhost $who $host"
}

##### HELP SECTION (QUITE LONG) #####
proc pub:help {nick uhost hand chan args} {
	global botnick
	set args [split [cleanarg $args]]
	if {[llength $args]<1} {
notice $nick "------\002ChanToolz Help: \002---------------------------"
notice $nick "!op <nick> - ops \002nick\002"
notice $nick "!deop <nick> - deops \002nick\002"
notice $nick "!ban <nick/host> <time> <reason> - bans a \002nick/host\002"
notice $nick "!unban <host> - unbans \002host\002 from channel"
notice $nick "!voice <nick> - gives \002nick\002 voice"
notice $nick "!devoice <nick> - takes away \002nick\002's voice"
notice $nick "!opme - ops you if you have access"
notice $nick "!addbot <handle> <address:port> - adds a bot"
notice $nick "!rmbot <handle> - removes a bot"
notice $nick "!link <bot> - attempts to link to \002bot\002"
notice $nick "!unlink <bot> - attempts to unlink from \002bot\002"
notice $nick "!ping \[nick\] - pings \002nick\002, or you"
notice $nick "!mode <mode change> - changes a mode setting on the channel"
notice $nick "!adduser <handle/nick> \[host\] - adds a user"
notice $nick "!deluser <handle> - removes \002handle\002 from user list"
notice $nick "!chattr <handle> <options> \[channel\] - changes attributes for user"
notice $nick "!part <#channel> - makes the bot leave the channel"
notice $nick "!join <#channel> - makes the bot join a channel"
notice $nick "!addhost <handle> <host> - adds a host to a user"
notice $nick "!rmhost <handle> <host> - removes a host from a user"
notice $nick "!disable <handle> - disables a handle from these commands"
notice $nick "!enable <handle> - enables a disabled user"
notice $nick "!act <chan> <what> - posts an action on chan"
notice $nick "!say <chan> <what> - says something to chan"
notice $nick "!bots - lists the bots linked on the botnet"
notice $nick "!channels - lists the channels the bot is on"
notice $nick "!ignore <nick/host> <time> <reason> - adds a new ignore"
notice $nick "!unignore <host> - removes an ignore"
notice $nick "!time - gives you the date and time"
notice $nick "!die \[reason\] - shuts down the bot for \[reason\]"
notice $nick "!jump <server>\[:port\] - makes the bot jump to a server"
notice $nick "!forcebans - makes all bans match bans on bot"
notice $nick "!rehash - rehashes the bot"
notice $nick "!reload - reloads the userfile"
notice $nick "!restart - restarts the bot"
notice $nick "!save - saves the userfile and channel file"
notice $nick "!backup - backs up the userfile"
notice $nick "!banlist - gives you a banlist for global & channel bans"
notice $nick "!ignorelist - gives you a list of ignores"
notice $nick "!flags <handle> - gives you handle's global flags"
notice $nick "!status - gives you some statistics"
notice $nick "!chanset <chan> <mode> \[args\] - changes a channel setting"
notice $nick "!help <command> - gives a detailed explaination of \002command\002"
notice $nick "---------------------------------------------------------"
notice $nick "------- type \002 !help <command>\002 to get more info ----------"
notice $nick "\002NOTE: Predi da izpolzva6 nekoq ot tezi komandi, parvo trqbva\002"
notice $nick "\002da se ident v bota kato napi6ee6:\002"
notice $nick "\002/msg $botnick auth <tvoqta parola>\002"
		#end
	} else {
		#start another long section
switch [lindex $args 0] {
	"time" {
notice $nick "\002-----time-----\002"
notice $nick "Usage: !time"
notice $nick "Flags Needed: none"
notice $nick "     Tells you the current date and time."
	}
	"bots" {
notice $nick "\002-----bots-----\002"
notice $nick "Usage: !bots"
notice $nick "Flags Needed: party line (+p)"
notice $nick "     Tells you the bots on the botnet."
	}
	"channels" {
notice $nick "\002-----channels-----\002"
notice $nick "Usage: !channels"
notice $nick "Flags Needed: channel or bot master"
notice $nick "     Tells you the channels the bot is on."
	}
	"ignore" {
notice $nick "\002-----ignore-----\002"
notice $nick "Usage: !ignore <nick/host> <time> <reason>"
notice $nick "Flags Needed: global op"
notice $nick "     Creates a new ignore. If nick is on the channel,"
notice $nick "     it will get a hostmask from him, otherwise, it will"
notice $nick "     get it from the one you specify."
	}
	"unignore" {
notice $nick "\002-----unignore-----\002"
notice $nick "Usage: !unignore <host>"
notice $nick "Flags Needed: global op"
notice $nick "     Removes the ignore matching host."
	}
	"chanset" {
notice $nick "\002-----chanset-----\002"
notice $nick "Usage: !chanset <chan> <mode> \[args\]"
notice $nick "Flags Needed: bot owner"
notice $nick "     Works just like the .chanset dcc command."
	}
	"status" {
notice $nick "\002-----status-----\002"
notice $nick "Usage: !status"
notice $nick "Flags Needed: channel or bot master"
notice $nick "     Gives you some statistics about the bot."
	}
	"channels" {
notice $nick "\002-----flags-----\002"
notice $nick "Usage: !flags <handle>"
notice $nick "Flags Needed: channel or bot master"
notice $nick "     Gives you the global flags of handle."
	}
	"ignorelist" {
notice $nick "\002-----ignorelist-----\002"
notice $nick "Usage: !ignorelist"
notice $nick "Flags Needed: channel or bot op"
notice $nick "     Gives you a list of active ignores."
	}
	"banlist" {
notice $nick "\002-----banlist-----\002"
notice $nick "Usage: !banlist"
notice $nick "Flags Needed: channel or bot op"
notice $nick "     Gives you a list of bans."
	}
	"save" {
notice $nick "\002-----save-----\002"
notice $nick "Usage: !save"
notice $nick "Flags Needed: bot master"
notice $nick "     Saves the userfile and channel file to disk."
	}
	"reload" {
notice $nick "\002-----reload-----\002"
notice $nick "Usage: !reload"
notice $nick "Flags Needed: bot master"
notice $nick "     Reloads the userfile from disk."
	}
	"rehash" {
notice $nick "\002-----rehash-----\002"
notice $nick "Usage: !rehash"
notice $nick "Flags Needed: bot owner"
notice $nick "     Rehashes the bot."
	}
	"restart" {
notice $nick "\002-----restart-----\002"
notice $nick "Usage: !restart"
notice $nick "Flags Needed: bot owner"
notice $nick "     Restarts the bot."
	}
	"backup" {
notice $nick "\002-----backup-----\002"
notice $nick "Usage: !backup"
notice $nick "Flags Needed: bot owner"
notice $nick "     Backs up the user file."
	}
	"forcebans" {
notice $nick "\002-----forcebans-----\002"
notice $nick "Usage: !forcebans"
notice $nick "Flags Needed: bot owner"
notice $nick "     Makes the bans on the channel match all bans in the bot's"
notice $nick "     ban list."
	}
	"jump" {
notice $nick "\002-----jump-----\002"
notice $nick "Usage: !jump <server>\[:port\]"
notice $nick "Flags Needed: bot master"
notice $nick "     Jumps to server on optional port."
	}
	"die" {
notice $nick "\002-----die-----\002"
notice $nick "Usage: !die \[reason\]"
notice $nick "Flags Needed: bot owner"
notice $nick "     Shuts down the bot for optional reason."
	}
	"help" {
		notice $nick "you're Lame :>"
	}
	"say" {
notice $nick "\002-----say-----\002"
notice $nick "Usage: !say <chan> <what>"
notice $nick "Flags Needed: global op on bot"
notice $nick "     Will say \002what\002 to \002chan\002."
	}
	"act" {
notice $nick "\002-----act-----\002"
notice $nick "Usage: !act <chan> <what>"
notice $nick "Flags Needed: global op on bot"
notice $nick "     Will post an action of \002what\002 to \002chan\002."
	}
	"op" {
notice $nick "\002-----op-----\002"
notice $nick "Usage: !op <nick>"
notice $nick "Flags Needed: op on channel, or op on bot"
notice $nick "     Ops \002nick\002 on the current channel."
	}
	"disable" {
notice $nick "\002-----disable-----\002"
notice $nick "Usage: !disable <handle>"
notice $nick "Flags Needed: owner on bot"
notice $nick "     Disables \002handle\002 from using all ! commands."
	}
	"enable" {
notice $nick "\002-----enable-----\002"
notice $nick "Usage: !enable <handle>"
notice $nick "Flags Needed: owner on bot"
notice $nick "     Enables \002handle\002 to use all ! commands."
notice $nick "     NOTE: Only needed if user has been \002!disable\002'ed."
	}
	"deop" {
notice $nick "\002-----deop-----\002"
notice $nick "Usage: !deop <nick>"
notice $nick "Flags Needed: op on channel, or op on bot"
notice $nick "     Deops \002nick\002 on the current channel."
	}
	"ban" {
notice $nick "\002-----ban-----\002"
notice $nick "Usage: !ban <nick/host> <time> <reason>"
notice $nick "Flags Needed: op on channel, or op on bot"
notice $nick "     If \002nick\002 is on the channel, it will get a"
notice $nick "     hostmask and ban that. If not, it will take the"
notice $nick "     host and ban that instead. \002time\002 is the amount"
notice $nick "     of time in minutes that the ban will last. Putting 0"
notice $nick "     in this field means a permanent ban. \002reason\002 is"
notice $nick "     the reason why you banned the nick (can be anything)."
	}
	"unban" {
notice $nick "\002-----unban-----\002"
notice $nick "Usage: !unban <host>"
notice $nick "Flags Needed: op on channel, or op on bot"
notice $nick "     Unbans \002host\002 from the channel. It can contain"
notice $nick "     wildcards. Ex: !unban *!*Candy*@*.aol.com"
	}
	"voice" {
notice $nick "\002-----voice-----\002"
notice $nick "Usage: !voice <nick>"
notice $nick "Flags Needed: op on channel, or op on bot"
notice $nick "     Gives voice to \002nick\002 on current channel."
	}
	"devoice" {
notice $nick "\002-----devoice-----\002"
notice $nick "Usage: !devoice <nick>"
notice $nick "Flags Needed: op on channel, or op on bot"
notice $nick "     Takes away op from \002nick\002."
	}
	"opme" {
notice $nick "\002-----opme-----\002"
notice $nick "Usage: !opme"
notice $nick "Flags Needed: op on bot"
notice $nick "     Gives you op on the channel"
	}
	"link" {
notice $nick "\002-----link-----\002"
notice $nick "Usage: !link <bot>"
notice $nick "Flags Needed: bot owner"
notice $nick "     Attempts to link to \002bot\002."
	}
	"unlink" {
notice $nick "\002-----unlink-----\002"
notice $nick "Usage: !unlink <bot>"
notice $nick "Flags Needed: bot owner"
notice $nick "     Attempts to unlink from \002bot\002."
	}
	"ping" {
notice $nick "\002-----ping-----\002"
notice $nick "Usage: !ping \[nick\]"
notice $nick "Flags Needed: partyline access"
notice $nick "     Pings \002nick\002 and prints the time on the channel."
notice $nick "     If no nick is given, it will ping you."
	}
	"mode" {
notice $nick "\002-----mode-----\002"
notice $nick "Usage: !mode <mode change>"
notice $nick "Flags Needed: op on channel, or op on bot"
notice $nick "     Changes a mode on the channel specified by \002mode change\002."
notice $nick "     Ex: !mode +m"
	}
	"adduser" {
notice $nick "\002-----adduser-----\002"
notice $nick "Usage: !adduser <nick> \[host\]"
notice $nick "Flags Needed: bot owner"
notice $nick "     Adds a user to the userlist with \002nick\002 as their"
notice $nick "     handle. If they are on the channel, and no \002host\002"
notice $nick "     is specified, it will get a hostmask from the channel."
notice $nick "     Otherwise, it will use the host you specify."
	}
	"part" {
notice $nick "\002-----part-----\002"
notice $nick "Usage: !part <#channel>"
notice $nick "Flags Needed: bot owner"
notice $nick "     Makes the bot part a channel."
	}
	"join" {
notice $nick "\002-----join-----\002"
notice $nick "Usage: !join <#channel>"
notice $nick "Flags Needed: bot owner"
notice $nick "     Makes the bot leave the channel."
	}
	"chattr" {
notice $nick "\002-----chattr-----\002"
notice $nick "Usage: !chattr <handle> <options> \[channel\]"
notice $nick "Flags Needed: bot owner"
notice $nick "     Changes the flags (\002options\002) of a user (\002handle\002)."
notice $nick "     If \002channel\002 is specified, it will change the channel flags for"
notice $nick "     the user."
	}
	"deluser" {
notice $nick "\002-----deluser-----\002"
notice $nick "Usage: !deluser <handle>"
notice $nick "Flags Needed: bot owner"
notice $nick "     Completely removes a user record from the bot."
	}
	"addbot" {
notice $nick "\002-----addbot-----\002"
notice $nick "Usage: !addbot <handle> <address:port>"
notice $nick "Flags Needed: bot owner"
notice $nick "     Adds a bot to the user file. You should know how to use"
notice $nick "     this if you are an owner of the bot."
	}
	"rmbot" {
notice $nick "\002-----rmbot-----\002"
notice $nick "Usage: !rmbot <handle>"
notice $nick "Flags Needed: bot owner"
notice $nick "     Removes a bot user record from the bot."
	}
	"addhost" {
notice $nick "\002-----addhost-----\002"
notice $nick "Usage: !addhost <handle> <host>"
notice $nick "Flags Needed: bot owner"
notice $nick "     Adds \002host\002 to user record for \002handle\002."
	}
	"rmhost" {
notice $nick "\002-----rmhost-----\002"
notice $nick "Usage: !rmhost <handle> <host>"
notice $nick "Flags Needed: bot owner"
notice $nick "     Removes host from \002handle\002."
	}
	"sex" {
notice $nick "Go talk to a shrink."
	}
	"me" {
notice $nick "I can do that!"
notice $nick "Just type \002!help\002 for commands."
	}
	"him" {
notice $nick "Sorry, I can't help him."
	}
}
}
}

proc pub:helpa {nick uhost hand chan args} {
	pub:help $nick $uhost $hand $chan $args
}

##### BADWORD #####
proc badword:kick {nick uhost hand chan text} {
	if {$hand != "*"} {
		if {([matchattr $hand "n"]) || ([matchattr $hand "m"]) || ([matchattr $hand "|m" $chan]) || ([matchattr $hand "|n" $chan]) || ([matchattr $hand "f"]) || ([matchattr $hand "|f" $chan])} {
			return 0
		}
	}
	putserv "KICK $chan $nick :Ne ta lii sram da izpolzva6 tezi dumi v kanala!"
}
putlog "Loading ChanToolz by ShakE"
putlog "Type !help in a public chat for more info."

##### REMIND USERS #####
proc toolz:remind_users {} {
	global botnick
	foreach n [userlist] {
		if {[passwdok $n ""]} {
			say $n "Your password on me has not been set yet. Please set it by typing /msg $botnick PASS <password>. This message is relayed every 30 minutes."
                  say $n "s drugi dumi setni si pass v bota 4e o6te nema6 takava"
			putlog "Reminded $n to set his/her password."
		}
	}
	timer 30 toolz:remind_users
}

set found 0
foreach n [timers] {
	if {[lindex $n 1] == "toolz:remind_users"} {
		set found 1
	}
}
if {$found == 0} {
	timer 5 toolz:remind_users
}
unset found
