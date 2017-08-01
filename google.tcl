# google.tcl v0.2.1
#
# !google keywords - displays the first related website found from google in the channel
# !image keywords  - displays the first related image found on google in the channel
# !file keywords   - displays the first mirror download link found on filemirrors in the channel
#
# by aNa|0Gue - analogue@glop.org - http://www.glop.org/
#
# 04/17/2002 v0.2.1 useragent fix by FAN

package require http

bind pub - !google pub:google
bind pub - !image pub:image
bind pub - !file pub:file

set agent "Mozilla"

proc pub:google { nick uhost handle channel arg } {
 global agent
	if {[llength $arg]==0} {
		putserv "PRIVMSG $channel :hey ! tappes des mots boulet !"
	} else {
		set query "http://www.google.de/search?btnI=&q="
		for { set index 0 } { $index<[llength $arg] } { incr index } {
			set query "$query[lindex $arg $index]"
			if {$index<[llength $arg]-1} then {
				set query "$query+"
			}
		}
		#putserv "PRIVMSG $channel :$query"
                set token [http::config -useragent $agent]
		set token [http::geturl $query]
		puts stderr ""
		upvar #0 $token state
		set max 0
		foreach {name value} $state(meta) {
			if {[regexp -nocase ^location$ $name]} {
				set newurl [string trim $value]
				putserv "PRIVMSG $channel :$newurl"
			}
		}
	}
}

proc pub:image { nick uhost handle channel arg } {
 global agent
	if {[llength $arg]==0} {
		putserv "PRIVMSG $channel :hey ! tappes des mots boulet !"
	} else {
		set query "http://images.google.de/images?btnI=&q="
		for { set index 0 } { $index<[llength $arg] } { incr index } {
			set query "$query[lindex $arg $index]"
			if {$index<[llength $arg]-1} then {
				set query "$query+"
			}
		}
		append query &imgsafe=off
	#	putserv "PRIVMSG $channel :$query"
                set token [http::config -useragent $agent]
		set token [http::geturl $query]
		puts stderr ""
		upvar #0 $token state
		set max 0
		foreach {name value} $state(meta) {
			if {[regexp -nocase ^location$ $name]} {
				set starturl "http://"
				set newurl [string trim $value]
				set newurl [string range $newurl [expr [string first = $newurl]+1] [expr [string first & $newurl]-1]]
				append starturl $newurl
				putserv "PRIVMSG $channel :$starturl"
			}
		}
	}
}

proc pub:file { nick uhost handle channel arg } {
 global agent
	if {[llength $arg]==0} {
		putserv "PRIVMSG $channel :hey ! tappes un nom de fichier boulet !"
	} else {
		set query "http://www.filemirrors.com/find.src?file="
		set query "$query[lindex $arg 0]"
	#	putserv "PRIVMSG $channel :$query"
                set token [http::config -useragent $agent]
		set token [http::geturl $query]
		set html  [http::data $token]
		puts stderr ""
		upvar #0 $token state
		set max 0
	#	foreach {name value} $state(meta) {
	#		putserv "PRIVMSG $channel :$value"
	#	}
	#	putserv "PRIVMSG $channel :$html"
		set result "[lindex $html 1]"
		set result [string range $result [expr [string first = $result]+2] [expr [string first > $result]-2]]
		putserv "PRIVMSG $channel :$result"
	}
}

putlog "Google v0.2.1 - LOADED!"
