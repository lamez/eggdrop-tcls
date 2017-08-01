### Smiling Script ###
# by Laurababe, goddess of TCL programming code.
# Programming code (only) responses to laurababe1@hotmail.com
### Start Smiling Script ###

# This script makes the bot respond to smile face characters. :-)

# Typical replies to the face symbol. :-)
set ransmile {
  ":-)"
  ":P"
  ":>"
  ":)"
  ";=)"
  ":-))"
  ":-D"
  "&:-)"
  ":-p"
  ";-)"
  ";-))"
  ":-O"
  ":-1"
}
bind pub - {:-)} pub_smiling
bind pub - {:)} pub_smiling
bind pub -|- {smile} pub_smiling


# random smile proc
proc pub_smiling {nick uhost hand chan $ran:-)} {
  global ransmile
  if [rand 2] {
    putchan $chan "[lindex $ransmile [rand [llength $ransmile]]]"
    }
    return 1
}

putlog "Smiling TCL script by Laurababe loaded."
