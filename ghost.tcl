#################################################################################
## Imeto koeto botyt wi polzwa w IRC.
set ImeNaBota "NickName"

## Parolata na botyt wi s koqto se identificira w NS-a.
set Parola "Password"

## Alternatiwniqt psewdonim na botyt. Tozi koito shte polzwa ako $ImeNaBota e zaet.
set AltImeNaBota "NickName2"

## Parolata za identifikaciq na Alternatiwniqt psewdonim.
set AltParola "Password2"

## uhost na NS (za UniBG go ostawete taka!)
set NSnuh "NS!NickServ@UniBG.Services"



###############################################################################################
##       AKO NEZNAETE KAKWO PRAWITE NEDEITE DA SE MESITE S KODYT KOJTO SLEDWA !!!!!!!!!!!    ##
###############################################################################################



bind notc - * serv_check

## Fuck the rules.
set keep-nick 0

proc strlwr {string} {
  string tolower $string
}

if {[strlwr $nick] != [strlwr $ImeNaBota]} {
  set nick $ImeNaBota
  putquick "NICK $ImeNaBota"
}

set altnick $AltImeNaBota

set IdPls "This nickname is owned by someone else"
set IdOrDie "If you do not \001IDENTIFY\001 within one minute, you will be disconnected"
set PassAcc "Password accepted - you are now recognized"
set WrongPass "Password Incorrect"

set NS(Critic) 0
set NS(SentPass) 0
set NS(NotId) 0
set NS(NotReg) 0
set NS(Critic) 0

proc serv_check {nick uhost hand text dest} {
  global botnick NS NSnuh IdPls IdOrDie PassAcc WrongPass
  global Parola AltParola ImeNaBota AltImeNaBota 
  if {[strlwr $botnick] != [strlwr $dest]} {
	return -1
  }
  if {[strlwr "$nick!$uhost"] == [strlwr $NSnuh]} {
	if {[strlwr $text] == [strlwr $IdPls]} {
	  set NS(Critic) 1
	  set NS(SentPass) 1
	  set NS(NotId) 1
	  set NS(NotReg) 0
	  botnsidentify
	} elseif {[strlwr $text] == [strlwr $IdOrDie]} {
	  set NS(Critic) 2
	  set NS(NotId) 1
	  set NS(NotReg) 0
	  if {$NS(SentPass) == 0} {
		set NS(SentPass) 1
		botnsidentify
	  }
	} elseif {[strlwr $text] == [strlwr $PassAcc]} {
	  set NS(Critic) 0
	  set NS(SentPass) 0
	  set NS(NotReg) 0
	  set NS(NotId) 0
	} elseif {[strlwr $text] == [strlwr $WrongPass]} {
	  set NS(NotReg) 0
	  if {$NS(Critic) == 1} {
		if {[strlwr $botnick] == [strlwr $ImeNaBota]} {
		  set NS(Critic) 0
		  set NS(SentPass) 0
		  set NS(NotId) 0
		  putquick "NICK $AltImeNaBota"
		}
		return 1
	  }
	  set NS(Critic) 0
	  set NS(SentPass) 0
	  set NS(NotReg) 0
	  set NS(NotId) 0
	}
  }
}

# From alltools.tcl.

proc botnsidentify {} {
  global botnick ImeNaBota AltImeNaBota NS NSnuh Parola AltParola
  if {[strlwr $botnick] == [strlwr $ImeNaBota]} {
	putquick "PRIVMSG [lindex [split $NSnuh "!"] 0] :identify $Parola"
  } elseif {[strlwr $botnick] == [strlwr $AltImeNaBota]} {
	putquick "PRIVMSG [lindex [split $NSnuh "!"] 0] :identify $AltParola"
  }
}

proc botnsregister {} {
  global botnick ImeNaBota AltImeNaBota NS NSnuh Parola AltParola

  if {[strlwr $botnick] == [strlwr $ImeNaBota]} {
	putquick "PRIVMSG [lindex [split $NSnuh "!"] 0] :register $Parola $Parola"
  } elseif {[strlwr $botnick] == [strlwr $AltImeNaBota]} {
	putquick "PRIVMSG [lindex [split $NSnuh "!"] 0] :register $AltParola $AltParola"
  }
}

bind raw - 303 bot_is_online

proc bot_is_online {* 303 arg} {
global botnick ImeNaBota AltImeNaBota Parola AltParola NSnuh

  foreach nqh [lrange $arg 1 end] {
  set nqh [lindex [split $nqh ":"] 1]
  if {[strlwr $nqh] == [strlwr $ImeNaBota] && [strlwr $nqh] != [strlwr $botnick]} {
    putserv "PRIVMSG [lindex [split $NSnuh "!"] 0] :ghost $ImeNaBota $Parola"
    putserv "NICK $ImeNaBota"
  } elseif {[strlwr $nqh] == [strlwr $AltImeNaBota] && [strlwr $nqh] != [strlwr $botnick]} {
    putserv "PRIVMSG [lindex [split $NSnuh "!"] 0] :ghost $AltImeNaBota $AltParola"
    putserv "NICK $AltImeNaBota"
	}
  }
}

proc cycle_ison {} {
global botnick ImeNaBota AltImeNaBota
  putserv "ISON :$ImeNaBota $AltImeNaBota"
  if {![string match *cycle_ison* [utimers]]} { utimer 60 cycle_ison }
}

if {![string match *cycle_ison* [utimers]]} { utimer 60 cycle_ison }

putlog "NS/CS support TCL by IRCHelp.UniBG.Org Team Loaded!!!"
