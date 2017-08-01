bind dcc n|- die dcc:die
bind msg n|- die msg:die
proc dcc:die {hand idx text} {
 global botnick owner
 if {$owner != $hand} {
  putidx $idx "Only perm owners can .die me!"
  putlog "$hand has tryed to .die me!"
  sendnote $botnick $owner "$hand has tryed to .die me!"
  return 0
 }
 putlog "$hand has .die me!"
 die $text
}
proc msg:die {nick uhost hand text} {
 global botnick owner
 if {$owner != $hand} {
  putserv "notice $nick :Only perm owners can .die me!"
  putlog "$hand * $nick has tryed to .die me!"
  sendnote $botnick $owner "$hand * $nick has tryed to /msg $botnick die me!"
  return 0
 }
 putlog "$hand has /msg $botnick die me!"
 die $text
}
