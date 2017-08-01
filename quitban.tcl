# quitban.tcl v1.1 (25 November 1999)
# copyright © 1999 by slennox <slennox@egghelp.org>
# slennox's eggdrop page - http://www.egghelp.org/
#
# This script bans people who quit with a specified quit message (except
# for +f and +o users). Requested by Ahmed.
#
# v1.0 - Initial release.
# v1.1 - Fixed 'stl' error for users without netbots.tcl.

# Specify the list of quit messages to ban on. Use lower case characters
# only. You can use standard wildcards (? and *) in the list. 
set qb_quitmsgs {
  "*www.*"
  "*http://*"
  "*elate*v*"
  "*join*kanal*"
  "*#*"
}

# Channels in which to enable the script. This can be one channel like
# "#red", a list of channels like "#red #green #blue", or "" for all
# channels.
set qb_chans ""

# Length of time to ban for (in minutes).
set qb_bantime 10

# Ban reason.
set qb_reason "forbidden quit message (please check your quit msg, you maybe infected!"


# Don't edit below unless you know what you're doing.

proc qb_quit {nick uhost hand chan reason} {
  global qb_bantime qb_chans qb_quitmsgs qb_reason
  if {(($qb_chans != "") && ([lsearch -exact $qb_chans [string tolower $chan]] == -1))} {return 0}
  if {[matchattr $hand fo|fo $chan]} {return 0}
  set reason [string tolower $reason]
  foreach quitmsg $qb_quitmsgs {
    if {[string match $quitmsg $reason]} {
      newchanban $chan *!*[string tolower [string range $uhost [string first @ $uhost] end]] quitban $qb_reason $qb_bantime
      return 0
    }
  }
  return 0
}

set qb_chans [split [string tolower $qb_chans]]

bind sign - * qb_quit

putlog "Loaded quitban.tcl by g0d"

return
