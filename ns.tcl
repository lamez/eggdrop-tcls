# Here type botnick and altnick. These nicks must be registered in NS. 
# WARNING! Possible cycle .....so ...when using this script be SURE 
# that ALL nicks in $regnick are REGISTERED in NS
set regnick "Boteca"

# Botnicks MUST be with ONE pass..... if you want to modify for different nicks - welcome....:)
set nspass "parolkataetuk"

# Name Service hostmask ....must be FULL. This  
# protect your eggdrop from users using splits 
# to gain nick NS and monitor user's pass
set nsserv "NS!NickServ@UniBG.services"

# Chan Service hostmask ..........
set csserv "CS!ChanServ@UniBG.services"

# set nicks...
set csnick "CS"
set nsnick "NS"

# well ...gain unban if banned.
proc deban {arg} {
global botnick regnick csnick
if {[string match "*[string toupper $botnick]*" [string toupper $regnick]]} {
	set c [lindex $arg 0]
	putlog "Requesting UNBAN on $c from CS.."
	putserv "PRIVMSG $csnick :UNBAN $c"
# Ask INVITE for fast rejoin.
	putserv "PRIVMSG $csnick :INVITE $c"
	}
}


# Gain op.....
proc getop {arg} {
global botnick regnick csnick
if {[string match "*[string toupper $botnick]*" [string toupper $regnick]]} {
	set c [lindex $arg 0]
	putlog "Requesting OP on $c from CS ..."
	putserv "PRIVMSG $csnick :OP $c $botnick"
	}
}

# Gain invite.....if channel is +i.
proc invite {arg} {
global botnick regnick
if {[string match "*[string toupper $botnick]*" [string toupper $regnick]]} {
	set c [lindex $arg 0]
	putlog "Requesting INVITE on $c from CS.."
	putserv "PRIVMSG CS :INVITE $c"
	}
}



# This command turns on/off service support of channels.
# .cssup #lame     -> turn ON service support.
# .cssup #lame off -> turn OFF service support.

proc sup_proc {hand idx  arg} {
if {[lindex $arg 1]!="off"} {
	channel set [lindex $arg 0] need-op "getop [lindex $arg 0]"
	channel set [lindex $arg 0] need-unban "deban [lindex $arg 0]"
	channel set [lindex $arg 0] need-invite "invite [lindex $arg 0]"
	putlog "Now supporting [lindex $arg 0] with ChanService."
	} {
	channel set [lindex $arg 0] need-op ""
	channel set [lindex $arg 0] need-unban ""	
	channel set [lindex $arg 0] need-invite ""
	putlog "No longer supporting [lindex $arg 0] with ChanService."
}
}

# Identify when needed ....
proc notice_a {from keyword arg} {
global nsnick csnick nspass nsserv csserv
set servresp [lindex $arg 1]
set msg [lrange $arg 0 end]

if {$from==$nsserv} {
        if {[lindex $arg 1]==":This"} {
        putserv "PRIVMSG $nsnick :IDENTIFY $nspass"
        putlog "$nsnick want IDENTIFY..." }
	}


# This using standart message "Access denied." returned by CS when user try to perform a 
# command without identification.
# Your eggdrop must use only  REGISTERED nicks. If not - CS allways will return Access denied .
# and your egg will identify every time ...........that gotta hurt..;)
# If you are not sure what are you doing - do NOT uncomment next 5 lines

if {$from==$csserv} {
        if {[lindex $arg 2]=="denied."} {
        	putlog "$csnick can't recognized me ..identifing.."
        	putserv "PRIVMSG $nsnick :IDENTIFY $nspass" }
	}

##return $from $keyword $arg
}



# Display "LAME No such nick/channel" when needed.
##proc n_311 {a b c} {
##putlog "$c"
##return $a $b $c
##}


# BINDS......
# Let only owners have control on .msg (it's danger when everyone can op and deop via egg ...)
unbind dcc o|o msg *dcc:msg
bind dcc n|- msg *dcc:msg

bind dcc n cssup sup_proc
##bind raw - 311 n_311
bind raw - notice notice_a

putlog "NS/CS script (fixed by ShakE) loaded"
# That's all.
