# voicebitch.tcl v0.1 (11 February 2001) by tequila <tequila@norges.net>

# Set the channels to activate voicebitch on (this can be one channel, or a
# list of channels like "#chan1 #chan2 #chan3"), setting this to "" will
# activate superbitch on all channels the bot is on
set sb_chans "#chan1 #chan2"

# Set the flag(s) for users who are allowed to voice anyone (this can be one
# flag, or a list of flags with no spaces between them), setting it to ""
# is a valid option
set sb_canopany "b"

# Set the flag(s) for users who are allowed to voice +f/+o/+m/+n users only,
# (this can be one flag, or a list of flags with no spaces between them)
# setting it to "" is a valid option
set sb_canopops "mn"



proc sb_bitch {nick uhost hand chan mode voiced} {
  global botnick sb_chans sb_canopany sb_canopops
  if {$mode != "+v" || [string tolower $voiced] == [string tolower $botnick] || [string tolower $nick] == [string tolower $botnick] || ![onchan $nick $chan] || [isop $voiced $chan]} {return 0}
  if {$sb_chans != "" && [lsearch -exact $sb_chans [string tolower $chan]] == -1} {return 0}
  if {![matchattr [nick2hand $voiced $chan] fmno|fmno $chan]} {
    if {$sb_canopany != "" && [matchattr $hand $sb_canopany|$sb_canopany $chan]} {return 0}
    pushmode $chan -v $voiced
    pushmode $chan -o $nick
  } else {
    if {$sb_canopany != "" && [matchattr $hand $sb_canopany|$sb_canopany $chan]} {return 0}
    if {$sb_canopops != "" && [matchattr $hand $sb_canopops|$sb_canopops $chan]} {return 0}
    pushmode $chan -v $voiced
    pushmode $chan -o $nick
  }
}

set sb_chans [string tolower $sb_chans]

bind mode - * sb_bitch

if {$sb_chans == ""} {
  putlog "Loaded voicebitch.tcl v0.1 by tequila (active on all channels)"
} else {
  putlog "Loaded voicebitch.tcl v0.1 by tequila (active on: $sb_chans)"
}
