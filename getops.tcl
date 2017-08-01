# Getops 2.6
# For 1.6.x (maybe others too)

# This script is used for bots to request and give ops to each other. 
# For this to work, you'll need:

# - Bots must be linked in a botnet
# - Every bot that should be ops on your channels must load this script
# - Add all bots you wanna op with this one using the .+bot nick address
#   command. The "nick" should be exactly the botnet-nick of the other bot
# - Add the hostmasks that uniquely identify this bot on IRC
# - Add a global or channel +o flag on all bots to be opped
# - Do exactly the same on all other bots

# The security of this relies on the fact that the bot which wants to have
# ops must be 1) linked to the current botnet (which requires a password),
# 2) have an entry with +o on the bot that he wants ops from and 3) must match
# the hostmask that is stored on each bots userfile (so it is good to keep the
# hostmasks up-to-date).

# -----------------------------------------------------------------------------

# 2.6 by Flash (Julien Wajsberg <flash@minet.net>)
# - Fixed a little typo
# - Removed some unused code
# - Patched the isvo function to make it work again with 1.6.x
# - TODO : maybe play around the new "bind NEED" command, but it would make
# this script 1.6.x-specific, and I don't think it's worth doing this.

# 2.5 by aerosoul
# - added random delay to give op procedure so channels with big
#   botnets won't be mode flooded on bot join
#   you can turn this off with set go_delay 0

# 2.4 by fantomas again
#  - console +d shows you requests from bots
# - copyleft info was too long, truncated

# 2.3 by fantomas
#  - rewritten back to english
#  - little bug (forgot to match chan attributes)

# 2.2 by Cron (Arkadiusz Miskiewicz <misiek@zsz2.starachowice.pl>)
#  - works good (tested on eggdrop 1.3.11)
#  - asks from unknown (and bots without +bo) are ignored
#  - all messages in Polish language
#  - better response from script to users
#  - fixed several bugs

# 2.1 by Ernst
# - asks for ops right after joining the channel: no wait anymore
# - sets "need-op/need-invite/etc" config right after joining dynamic channels
# - fixed "You aren't +o" being replied when other bot isn't even on channel
# - better response from bots, in case something went wrong
#   (for example if bot is not recognized (hostmask) when asking for ops)
# - removed several no-more-used variables
# - added the information and description above

# 2.0.1 by beldin (1.3.x ONLY version)
# - actually, iso needed to be modded for 1.3 :P, and validchan is builtin
#   and I'll tidy a couple of functions up to

# 2.0 by DarkDruid
# - It'll work with dynamic channels(dan is a dork for making it not..)
# - It will also only ask one bot at a time for ops so there won't be any more
#   annoying mode floods, and it's more secure that way
# - I also took that annoying wallop and resynch stuff out :P
# - And I guess this will with with 1.3.x too

# Previously by The_O, dtM and poptix.

# -----------------------------------------------------------------------------

# [0/1] do you want GetOps to notice when some unknown (unauthorized) bot
#       sends request to your bot
set go_bot_unknown 0

# [0/1] do you want your bot to request to be unbanned if it becomes banned?
set go_bot_unban 1

# [0/1] do you want GetOps to notice the channel if there are no ops?
set go_cycle 0

# set this to the notice txt for the above (go_cycle)
set go_cycle_msg "Please leave the channel so the bots can get op."

# [0/1] do you want GetOps to have random delay for the give op procedure?
set go_delay 1

# if go_delay is turned on: 
# how many seconds should the bot at least wait before giving ops?
set go_mindelay 5

# -----------------------------------------------------------------------------

set bns ""
proc gain_entrance {what chan} {
 global botnick botname go_bot_unban go_cycle go_cycle_msg bns
 switch -exact $what {
  "limit" {
   foreach bs [lbots $chan] {
    putbot $bs "gop limit $chan $botnick"
    putlog "GetOps: Requested limit raise from $bs on $chan."
   }
  }
  "invite" {
   foreach bs [lbots $chan] {
    putbot $bs "gop invite $chan $botnick"
    putlog "GetOps: Requested invite from $bs for $chan."
   }  
  }
  "unban" {
   if {$go_bot_unban} {
    foreach bs [lbots $chan] {
     putbot $bs "gop unban $chan $botname"
     putlog "GetOps: Requested unban on $chan from $bs."
    }
   }
  }
  "key" {
   foreach bs [lbots $chan] {
    putbot $bs "gop key $chan $botnick"
    putlog "GetOps: Requested key on $chan from $bs."
   }
  }
  "op" {
   if {[hasops $chan]} {
    set bot [getbot $chan]
    if {$bot == ""} {
     set bns ""
     set bot [getbot $chan]
    }
    lappend bns "$bot"
    if {$bot != ""} {
     putbot $bot "gop op $chan $botnick"
     putlog "Requesting ops from $bot on $chan.."
    }
   } {
    if {$go_cycle} {
     puthelp "NOTICE $chan :$go_cycle_msg"
    }
   }
  }
 }
}
proc hasops {chan} {
  foreach user [chanlist $chan] {
    if {[isop $user $chan]} {
      return 1
    }
  }
  return 0
}

proc getbot {chan} {
  global bns
  foreach bn [bots] {
    if {[lsearch $bns $bn] < 0} {
      if {([isvo $bn $chan])} {
        if {([onchan [hand2nick $bn $chan] $chan]) && ([isop [hand2nick $bn $chan] $chan])} {
          return $bn
          break
        }
      }
    }
  }
}

proc botnet_request {bot com args} {
 global botnick go_bot_unban go_bot_unknown go_delay go_mindelay
 set args [lindex $args 0]
 set subcom [lindex $args 0]
 set chan [string tolower [lindex $args 1]]
 set nick [lindex $args 2]

 putloglev d * "botnet_request: bot $bot chan $chan nick $nick com $subcom"

  if {([matchattr $bot b] == 0 || [isvo $bot $chan] == 0) && ($subcom != "takekey" ) } {
   if { $go_bot_unknown == 1} {
   putlog "GetOps: Request for $subcom from $bot - unauthorised bot (IGNORED)"
  }
  return 0
  }

 switch -exact $subcom {
  "op" {
   if {[onchan $nick $chan] == 0} {
    putbot $bot "gop_resp You're not on $chan."
    return 1
   }
   set bothand [finduser $nick![getchanhost $nick $chan]]
   if {$bothand == "*"} {
    putlog "GetOps: $bot requested ops on $chan. Ident not recognized: $nick![getchanhost $nick $chan]."
    putbot $bot "gop_resp I don't know you from this ident: $nick![getchanhost $nick $chan]"
    return 1
   }
   if {[string tolower $bothand] == [string tolower $nick]} {
    putlog "GetOps: $bot requested for op on $chan."
   } {
    putlog "GetOps: $bot requested for op as $nick on $chan."
   }
   if {[iso $nick $chan] && [matchattr $bothand b]} {
    if {[botisop $chan]} {
     if {[isop $nick $chan] == 0} {
	if {$go_delay == 1} {
	 utimer [expr $go_mindelay + [rand 10]] [split "ngop_op $chan $nick $bot"]
	} else {
	 putlog "GetOps: $nick opped on $chan."
	 putbot $bot "gop_resp opping $nick on $chan."
	 pushmode $chan +o $nick
	}	
     }
    } {
     putbot $bot "gop_resp I am not +o on $chan."
    }
   } {
    putbot $bot "gop_resp You're noe in my +o list on $chan."
   }
   return 1
  }
  "unban" {
   if {$go_bot_unban} {
    putlog "GetOps: $bot requested for unban on $chan (unbanning)."
    foreach ban [chanbans $chan] {
     if {[string compare $nick $ban]} {
      set bug_1 [lindex $ban 0]
      pushmode $chan -b $bug_1
     }
    }
    return 1
   } {
    putlog "GetOps: Refused request to unban $bot ($nick) on $chan."
    putbot $bot "gop_resp I won't unban you on $chan."
   }
  }
  "invite" {
   putlog "GetOps: $bot requested for invite on $chan."
   if {[matchattr $bot b]} {
    putserv "invite $nick $chan"
   }
   return 1
  }
  "limit" {
   putlog "GetOps: $bot requested for limit raise on $chan."
   if {[matchattr $bot b]} {
    pushmode $chan +l [expr [llength [chanlist $chan]] + 1]
   }
   return 1
  }
  "key" {
   putlog "GetOps: $bot requested for key for $chan."
   if {[onchan $botnick $chan] == 0} {
    putbot $bot "gop_resp I'm not on $chan."
    return 1
    }
   if {[string match *k* [lindex [getchanmode $chan] 0]]} {
    putbot $bot "gop takekey $chan [lindex [getchanmode $chan] 1]"
   } {
    putbot $bot "gop_resp There's no key needed on $chan!"
   }
   return 1
  }
  "takekey" {
   putlog "GetOps: $bot ($nick) gave me key for $chan."
   foreach channel [string tolower [channels]] {
    if {$chan == $channel} {
     putserv "JOIN $channel $nick"
     return 1
    }
   }
  }
  default {
   putlog "GetOps: ALERT! $bot send fake 'gop' message! ($subcom)"
  }
 }
}

proc gop_resp {bot com msg} {
 putlog "GetOps: MSG from $bot: $msg"
 return 1
}

proc lbots {chan} {
 set unf ""
 foreach users [userlist b] {
  foreach bs [bots] {
   if {($users == $bs) && ([matchattr o|o $chan])} {
    lappend unf $users
   }
  }
 }
 return $unf
}

# Returns list of bots in the botnet and +o in my userfile on that channel
proc lobots { channel } {
 set unf ""
 foreach users [userlist b] {
  if {[isvo $users $channel] == 0} { continue }
  foreach bs [bots] {
   if {$users == $bs} {	lappend unf $users }
  }
 }
 return $unf
}

proc isvo {hand chan} {
 if {[matchattr $hand o] || [matchattr $hand |o $chan]} {
  return 1
 } {
  return 0
 }
}

proc iso {nick chan1} {
 return [isvo [nick2hand $nick $chan1] $chan1]
}

proc do_channels {} {
 global go_chanset
 foreach a [string tolower [channels]] {
  if {[info exist go_chanset($a)] == 0} {
   channel set $a need-op "gain_entrance op $a"
   channel set $a need-key "gain_entrance key $a"
   channel set $a need-invite "gain_entrance invite $a"
   channel set $a need-unban "gain_entrance unban $a"
   channel set $a need-limit "gain_entrance limit $a"
   set go_chanset($a) 1
  }
 }
 if {[string match "*do_channels*" [timers]] == 0} { timer 5 do_channels }
}

if {[string match "*do_channels*" [utimers]] == 0} {
 # Set things up one second after starting (dynamic things already loaded)
 utimer 1 do_channels
}

bind bot - gop botnet_request
bind bot - gop_resp gop_resp

# Ask for ops when joining a channel
bind join - * gop_join

proc requestop { chan } {
 global botnick
 set chan [string tolower $chan]
 putlog "hopla on arrive dans requestop : chan = $chan"
 foreach thisbot [lobots $chan] {
  # Send request to all, because the bot does not have the channel info yet
  putbot $thisbot "gop op $chan $botnick"
  lappend askedbot $thisbot
 }
 if {[info exist askedbot]} {
  regsub -all " " $askedbot ", " askedbot
  putlog "GetOps: Requested Ops from $askedbot on $chan."
 } {
  putlog "GetOps: There are no opped bots on $chan."
 }
 return 0
}

proc gop_join { nick uhost hand chan } {
 global botnick
 # Check if it was me joining
 if {$nick != $botnick} { return 0 }
 # Adjust channel settings, if needed (e.g when a dynamic channel was added)
 do_channels
 # Already done in requestop
 #set chan [string tolower $chan]
 # Wait 5 sec, because IRC-lag > Botnet-Lag
 utimer 5 "requestop $chan"
 return 0
}

proc ngop_op {chan nick bot} {
 if {![isop $nick $chan] && [botisop $chan]} {
        putlog "GetOps: gave $nick delayed op on $chan."
        putbot $bot "gop_resp opping $nick on $chan."
        pushmode $chan +o $nick
 }
}

set getops_loaded 1

putlog "GetOps v2.6 loaded."
