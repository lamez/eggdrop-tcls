#
# Ami tezi nesta sa zadyljitelni da se naprawq w conf-a ti:
#
set max-logsize 0
set log-time 1
set quick-logs 1
set keep-all-logs 1
set logfile-suffix ".%d%m%Y"

#
# Bez tqh nqma da stane!! Po-dolu mojesh da widish sintaksisa na komandata greplog.
# Imeto na log fajla na kanala WINAGI trqbwa da e s malki bukwi i da e w logs/
# Po tozi na4in moje da si grepnesh i nesto koeto ne e kanal, t.e.:
# /msg $botnick greplog $botnick 12.12.1212 10-12 bombme@sadam.ir
# I ste wzemesh log-a logs/$botnick.log.12121212 ot 10 do 12 4asa i ste go imash na dadeniq e-mail.
# TRQBWA mashinata da ima mail i cat (koeto wsi4ki imat). Tozi tcl ne raboti za windrop!
#
bind msg - greplog msg_greplog

proc msg_greplog {nick uhost hand arg} {
  global botnick

  if {[llength $arg] != 4} {
	putquick "NOTICE $nick :Usage: greplog <channel> <day.month.year> <sourcehour-destinationhour>"
	putquick "NOTICE $nick :Day, month are always in 2 digit format year is 4 digit. The hours are two digits too."
	putquick "NOTICE $nick :Example: /msg $botnick greplog #IRCHelp 10.12.2003 10-12 bombme@sadam.ir"
	return 0
  }

  # Please read me :) Use //echo $decode(), mIRC kiddies
  set filename "logs/[string tolower [lindex $arg 0]].log.[lindex [split [lindex $arg 1] "."] 0][lindex [split [lindex $arg 1] "."] 1][lindex [split [lindex $arg 1] "."] 2]"

  if {![file exists $filename]} {
    putquick "NOTICE $nick :There's no such channel record."
    return 0
  }

  set tmp $filename.tmp.[unixtime]

  set file [open $filename r]
  set filetmp [open $tmp w]

  while {![eof $file]} {
    set line [gets $file]
	# mIRC kludge, kludge ur ass
	if {[string range [lindex [split [lindex $line 0] ":"] 0] 1 end] >= [lindex [split [lindex $arg 2] "-"] 0] && [string range [lindex [split [lindex $line 0] ":"] 0] 1 end] <= [lindex [split [lindex $arg 2] "-"] 1]} {
	  puts $filetmp "$line"
	}
  }

  close $filetmp
  close $file

  exec cat $tmp | mail -s "Greplog from $botnick on [lindex $arg 1]" [lindex $arg 3]

  file delete -force $tmp
}
putlog "Greplog TCL by \002IRCHelp.UniBG.Org\002 Loaded!"