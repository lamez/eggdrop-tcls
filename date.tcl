#### Date.tcl by Evo|ver @ ircnet
#### Last update Mar 17 2001
#### 
#### Purpose of the script: 
#### Storing birthdays and events and checking in how many days it is.
#### The script also sets a topic when it's someones birthday.i
#### The script CAN use stats.mod for recognising people, but it should
#### work well without it. 
#### Use !date --help for all the commands. 
####
#### Comments, suggestions, fanmail, marriage proposals: evolver@blue.penguin.nl
####
#### Thanks to HCl for testing.
#### Thanks to webmind for some advise about programming.
#### Thanks to #eggdrop @ircnet for... ehm.. the lame times between sleep.
#### Thanks to G`quann for coding stats.mod
#### Thanks to the people at #mainsource @irc.pulltheplug.com for letting me 
#### debug the script with HCl.
####
#### Version 1.3 	Made the --help a puthelp in stead of putserv, HCl's bot
####			had problems with it.
####			Fixed a minor bug in --help, I had [time] should be 
####			\[time\]
####			Stupid bug fixed at the check if today is the birthday.
####			I did day +1, that causes problems on last day of the
####			month.
#### Version 1.2	The year of an event wasn't handled correctly, it 
####			took the current year. This caused a bug for events in 
####			future years. ;-)
#### Version 1.1 	Had some putlogs that I used for debugging.. forgot 
####			to take them out... 
####			With an event, the script now also shows the date...
####			people found that that was usefull....
#### Version 1.0	Releasing the script, tested it for a month, no
####			errors so I thought it could be released.
####			Only some changes in the comment.
#### Version 0.7	Finally found a strange bug.. BitchX adds a " " after
####			a nickcompletion (<tab>).
#### Version 0.6	I think it should be wise if I read the manual. 
####			Made a stupid mistake with clock scan.... 
#### Version 0.5	It's know possible to set a time for
####			an event. Changes something in the filetype for it. 
####			Fixed a bug, there was no check for the year. So you
####			could just enter no year and you didn't know nothing 
####			happened. :-)
####			If someone's birthday is today, the script will say that
####			in stead of 52 week... when you do !date. 
#### Version 0.4	I forgot something in the help.
####			Script now supports a # in the description of an event.
####			Script now says in the channel when it's someones 
####			birthday and it can't set the topic.
####			Script now sets the topic back after one day.
#### Version 0.3.5	I didn't fix the timedate bug, now I did!
#### Version 0.3	Cleaned up a bit of my code.
####			Found and fixed a bug in timedate.
####			Fixed another bug in nick2suser
#### Version 0.2	Fixed a bug with 29 Febuary 
####			Fixed a bug in my nick2suser replacement
#### Version 0.1	Initial script. 
####			Coded from scratch since my own (non-released)
####			bday.tcl would work anymore with stats.mod1.3.x
####
#### Todo		A warning msg a few days/weeks/months/etc before 
#### 			a date. So you can send your birthday card on time ;-)	
#### 			To be really nice, I should make !channel support, 
####			but who uses those ;-)
####			There should be more features, if someone has an idea..

## put here the name of the file where the script stores the data
set datafile .datafile

## the flag someone must have to be able to remove ALL data. 
## NOTE: if someone has the same hostmask of the person who set the date
## he will be able to remove the date too, therefor someone IS able to change
## or remove his/her own birthday or an event he/she set, and someone with 
## this flag can always do that.
set date_remove_flag n

## Don't change anything below, unless you know what you're doing.
## All guarentee will be lost when changing anything :-P

bind pub - !date pub_date

## proc to handle everything with one bind 
proc pub_date {nick host hand chan arg} {
	global botnick
	if {[llength $arg] == 0} {
		set reply [getdate [string tolower [nick2suser $nick $chan]]]
		if {[lindex $reply 0] == "pub"} {
			putserv "PRIVMSG $chan :[lrange $reply 1 end]"
		} else {
			putserv "PRIVMSG $nick :[lrange $reply 1 end]"
		}	
		return 1
	}
	if {[lindex $arg 0] == "--help"} {
		datehelp $nick
		return 1
	}	
	if {[llength $arg] == 1} {
 		set arg [string trimright $arg " "]
		if {[nick2suser $arg $chan] != "\*"} {
			set arg [nick2suser $arg $chan]
		}
		set reply [getdate [string tolower $arg]]
		if {[lindex $reply 0] == "pub"} {
			putserv "PRIVMSG $chan :[join [lrange $reply 1 end]]"
		} else {
			putserv "PRIVMSG $nick :[join [lrange $reply 1 end]]"
		}	
		return 1
	}
	if {[llength $arg] == 2} {
		if {[lindex $arg 0] == "remove"} {
			putserv "PRIVMSG $nick :[deldate [string tolower [lindex $arg 1]] $nick $host]"
			return 1
		}
		if {[lindex $arg 0] == "whoset"} {
			set reply [whodate [lindex [string tolower $arg] 1]]
			if {[lindex $reply 0] == "pub"} {
				putserv "PRIVMSG $chan :[lrange $reply 1 end]"
			} else {
				putserv "PRIVMSG $nick :[lrange $reply 1 end]"
			}	
			return 1
		}	
		putserv "PRIVMSG $nick :[lindex $arg 0] not a known command. Try !date --help"
		return 1
	}
	if {[llength $arg] == 3} {
		putserv "PRIVMSG $nick :[setdate [string tolower [nick2suser $nick $chan]] 00 00 [string toupper [lindex $arg 0]] [lindex $arg 1] [lindex $arg 2] b $nick $host $chan]"
		return 1
	}
	set len [llength [lrange $arg 3 end]]
	set numhash 0
	foreach args [lrange $arg 3 end] {
		if {[regexp (#) $args]} {
			set numhash [expr $numhash + 1]
		}
	}
	if {$numhash == $len} {	
		if {[lsearch [string tolower [lrange $arg 3 end]] $chan] == -1} {
			set chans "[lrange $arg 3 end] $chan"
		} else { 
			set chans [lrange $arg 3 end]
		}	
		putserv "PRIVMSG $nick :[setdate [string tolower [nick2suser $nick $chan]] 00 00 [string toupper [lindex $arg 0]] [lindex $arg 1] [lindex $arg 2] b $nick $host $chans]"
		return 1
	}	
	if {[lindex $arg 4] == ""} {
		putserv "PRIVMSG $nick :Please enter a desciption"
		return 0
	}
	if {[regexp {:} [lindex $arg 4]]} { 
		regsub {:} [lindex $arg 4] { } time
		putserv "PRIVMSG $nick :[setdate [string tolower [lindex $arg 0]] [lindex $time 1] [lindex $time 0] [string toupper [lindex $arg 1]] [lindex $arg 2] [lindex $arg 3] e $nick $host [lrange $arg 5 end]]" 
		return 1
	}
	putserv "PRIVMSG $nick :[setdate [string tolower [lindex $arg 0]] 00 00 [string toupper [lindex $arg 1]] [lindex $arg 2] [lindex $arg 3] e $nick $host [lrange $arg 4 end]]"
	return 1
}	
	
## proc which provides the help 

proc datehelp {nick} {
	global evdatever
	puthelp "NOTICE $nick :Help of Date.tcl version $evdatever"
	puthelp "NOTICE $nick :To input your birthday: !date <month> <day> <year> \[other chan\]"
	puthelp "NOTICE $nick :To input an event: !date <event> <month> <day> <year> \[time\] <description>"
	puthelp "NOTICE $nick :<month> like Jan, Feb, etc. The other chans that you can input are chans where I put your birthday in the topic."
	puthelp "NOTICE $nick :example 1: You're birthday is October 2 1981 and you want it in the topic of #foo and #bar (note: I must be ops in those chans to let me set the topic :-)). You say in #foo: !date Oct 2 1981 #bar" 
	puthelp "NOTICE $nick :example 2: You're channelmeeting is Febuary 10 2001 at 19:30. You say: !date mychanmeeting Feb 10 2001 19:30 Meeting of #mychan (Note: the time is in an 24-hour clock. 3pm doesn't work, 15:00 does. The time isn't necessary, but might be handy :-))" 
	puthelp "NOTICE $nick :To request a date: !date <birthday\\event>"
	puthelp "NOTICE $nick :To remove a date: !date remove <birthday\\event>"
	puthelp "NOTICE $nick :To see who set the date: !date whoset <birthday\\event>"
	return 1
}

## proc for setting the date	
proc setdate {name min hr mm dd yy type snick shost rest} {
	global datafile
	if {[file exists $datafile]} {
		set datedata [open $datafile r]
		while {![eof $datedata]} {
			set curline [gets $datedata]
			if {[lindex $curline 0] == $name} {
				if {$type == "e"} {
					return "Event already known by me. Remove it first to re-input it."
				}
				if {$type == "b"} {
					return "Your birthday is already known by me. Remove it first to re-input it."
				} 
				putlog "Somethings wrong... $name is not a birthday AND not an event."
			}
		}
		close $datedata
	}
        regsub -all {[0-9]} $yy {1} myresult
        if {$myresult != 1111} {
        	return "Wrong year. Please use a year like 2001, 1984, 1945, etc."
        }
	set nmm [lsearch "JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC" $mm]
	if {$nmm == "-1"} {
		return "Wrong month. Please input a month like: Jan, Feb, Mar, etc..."
	}
	if {[expr $yy % 4] == 0} {
                set days "31 29 31 30 31 30 31 31 30 31 30 31"
        } else {
                set days "31 28 31 30 31 30 31 31 30 31 30 31"
        }
        if {[lindex $days $nmm] < $dd || $dd == 0} {
        	return "Wrong day. There is no $dd th day in $mm."
        }
	regsub -all {[0-9]} $min {1} myresult
	if {$myresult != 11} {
		return "Wrong kind of minutes.... a minute is a number between 00 and 60"
	}
	if {$min >= 60} {
		return "Wrong kind of minutes.... a minute is a number between 00 and 60"
	}
	regsub -all {[0-9]} $hr {1} myresult
	if {$myresult != 11} {
		return "Wrong kind of hours.... an hour is a number between 00 and 24"
	}
	if {$hr >= 24} {
		return "Wrong kind of hours.... an hour is a number between 00 and 24"
	}
## writing the data to the file        
        set datedata [open $datafile a]
	set rest [join $rest]
        puts $datedata "$name $min $hr $mm $dd $yy $type $snick $shost $rest"
        flush $datedata
        close $datedata
        if {$type == "b"} { 
		return "$name 's birthday is $mm $dd $yy"
	}
	if {$type == "e"} {
		return "$name is $mm $dd $yy at $hr:$min,  $rest"
	}
## if you ever see such a line, you really have a problem :-)
	return "Housten, we have a problem."	
}       

## proc for finding the date
proc getdate {target} {
	global datafile
	if {![file exists $datafile]} {
		return "msg $target is not set \/ $target has no birthday set"
	}
	set rline ""
	set datedata [open $datafile r]
	while {![eof $datedata]} {		
		set curline [gets $datedata]
		if {[lindex $curline 0] == $target} {
			set rline $curline
		}
	}
	close $datedata
	if {$rline == ""} {
		return "msg $target is not set \/ $target has no birthday set"
	}
	if {[lindex $rline 6] == "b"} {
		set thisyear [lindex [ctime [unixtime]] 4]
	} else {
		set thisyear [lindex $rline 5]
	}
## If someone is born on 29 Feb. you also need a check for that in this proc. Tcl doesn't like [clock scan "Feb 29 2001"]  :-)
	if {[lindex $rline 3] == "FEB" && [lindex $rline 4] == "29" && (![expr $thisyear %4] == 0) } {
		set thisdate [clock scan "MAR 1 [lindex $rline 2]:[lindex $rline 1] $thisyear"]
	} else {
		set thisdate [clock scan "[lrange $rline 3 4] [lindex $rline 2]:[lindex $rline 1] $thisyear"] 
	}
	if {[lindex $rline 6] == "b"} {
		if {$thisdate < [unixtime]} {
# Is the moment at 00:00:00 already over, but has the moment + day not yet passed??
			if {[expr $thisdate + 86400] > [unixtime]} {
				return "pub $target 's birthday is TODAY!!! $target is now [expr $thisyear - [lindex $rline 5]]" 
			} else { 
				set thisyear [expr $thisyear + 1]
				if {[lindex $rline 3] == "FEB" && [lindex $rline 4] == "29" && (![expr $thisyear %4] == 0) } {
					set thisdate [clock scan "MAR 1 [lindex $rline 2]:[lindex $rline 1] $thisyear"]
				} else {
					set thisdate [clock scan "[lrange $rline 3 4] [lindex $rline 2]:[lindex $rline 1] $thisyear"]
				}
			}
		}
		return "pub $target 's birthday in [duration [expr $thisdate - [unixtime]]]. $target will be [expr $thisyear - [lindex $rline 5]]"
	} else {
		if {$thisdate < [unixtime]} {
			return "pub $target was [duration [expr [unixtime] - $thisdate]] ago. ([lrange $rline 3 4] [lindex $rline 2]:[lindex $rline 1]) [join [lrange $rline 9 end]]." 
		} else {
			return "pub $target is in [duration [expr $thisdate - [unixtime]]]. ([lrange $rline 3 4] [lindex $rline 2]:[lindex $rline 1]) [join [lrange $rline 9 end]]." 
		}
	}
## Next line is a quote from "Something's wrong" from K's Choice	
	return "msg Your pubic hair 's on fire!"
}

## proc for deleting date
proc deldate {target nick host} {
	global datafile date_remove_flag
	if {![file exists $datafile]} {
		return "$target is not set \/ $target has no birthday set"
	}
	set dates ""
	set datedata [open $datafile r]
	while {![eof $datedata]} {
		set curline [gets $datedata]
		if {$curline != ""} {
			set dates [linsert $dates end $curline]
		}
	}
	close $datedata
	set line "-1"
	set checkthis ""
	foreach date $dates {
		set line [expr $line + 1]
		if {[lindex $date 0] == $target} {
			set checkthis $date
			break
		}
	}
	if {$checkthis == "" } {return "$target is not set \/ $target has no birthday set"}
	if {[maskhost $host] == [maskhost [lindex $date 8]] || [matchattr [nick2hand $nick] $date_remove_flag]} {
		if {[expr $line >= 0] && [expr $line < [llength $dates]]} {
			set newdata [lreplace $dates $line $line]
			set datedata [open $datafile w]
			foreach newdate $newdata {
				puts $datedata $newdate
			}
			flush $datedata
			close $datedata
			return "$target is deleted"
		} 
	} 
	putlog "You are not allowed to remove that date."
}

## proc wich looks everyday for a birthday
bind time - "00 00 * * *" timedate
proc timedate {min hr day month year} {
	global datafile evdtopics
	if {![file exists $datafile]} {
		return 0
	}
	set dates ""
	set datedata [open $datafile r]
	while {![eof $datedata]} {
		set curline [gets $datedata]
		if {$curline != ""} {
			set dates [linsert $dates end $curline]
		}
	}
	close $datedata
	set bdays ""
	foreach date $dates {		
		if {[lindex $date 6] == "b"} {
			if {[string trimleft $day 0] == [string trimleft [lindex $date 4] 0]} {
				set month [string trimleft $month 0]
				if {$month == ""} {set month 0}
				set mnth [lindex "JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC" $month]
				if {$mnth == [string toupper [lindex $date 3]]} {
					set bdays [linsert $bdays end $date]
				}
			}	
		}
	}
	if {$bdays == ""} {return 0}
	set chans ""
	foreach bday $bdays {
		foreach chan [lrange $bday 9 end] {
			lappend name($chan) "[lindex $bday 0],"
			lappend age($chan) "[expr $year - [lindex $bday 5]],"
		}
	}
	foreach chan [array names name] {
		if {[llength $name($chan)] == 1} {
			putserv "TOPIC $chan :[string trimright $name($chan) ,] 's birthday! [string trimright $name($chan) ,] is now [string trimright $age($chan) ,]"
			return 1
		}
		if {(![regexp {t} [lindex [getchanmode $chan] 0]]) || [botisop $chan]} {	
			set evdtopics($chan-b) [topic $chan]
			putserv "TOPIC $chan :Happy birthday: [string trimright $name($chan) ,]. They are now [string trimright $age($chan) ,]!" 
			set evdtopics($chan-a) "Happy birthday: [string trimright $name($chan) ,]. They are now [string trimright $age($chan) ,]!"
			timer 1438 "evdresettopic $chan"
		} else {
			putserv "PRIVMSG $chan :\002Happy birthday: [string trimright $name($chan) ,]. They are now [string trimright $age($chan) ,]!\002" 
		}
	}	
}	

proc evdresettopic {chan} {
	global evdtopics
	putlog "[topic $chan] == $evdtopics($chan-a)"
	if {"[topic $chan]" == "$evdtopics($chan-a)"} {
		putserv "TOPIC $chan :$evdtopics($chan-b)"
	}
}		
	
## proc which looksup who set the date
proc whodate {target} {
	global datafile
	if {![file exists $datafile]} {
		return "msg $target is not set \/ $target has no birthday set"
	}
	set rline ""
	set datedata [open $datafile r]
	while {![eof $datedata]} {		
		set curline [gets $datedata]
		if {[lindex $curline 0] == $target} {
			set rline $curline
		}
	}
	close $datedata
	if {$rline == ""} {
		return "msg $target is not set \/ $target has no birthday set"
	}
	return "pub $target was set by [lindex $rline 7]![lindex $rline 8]"
}	

proc telldate {nick host target when} {
	global datafile notefile
}


## proc which is called if you don't run stats.mod 1.3.* 
## I use the tcl-command from stats.mod because it autoadds hostnames.
set modcheck "1"
foreach mod [modules] {
	if {[lindex $mod 0] == "stats" && [lindex $mod 1] >= 1.3} {set modcheck "0"} 
}
if {$modcheck} {
	proc nick2suser {nick chan} {
		if {[nick2hand $nick $chan] == "\*" || [nick2hand $nick $chan] == ""} {
			return $nick
		} else {
			return [nick2hand $nick $chan]
		}
	}
}
	

set evdatever "1.3"
putlog "Date.tcl version $evdatever by Evo|ver loaded"			
