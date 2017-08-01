bind msg C kickass kickass

### kickass <password> <mask> <chan> [time] [reason]


proc kickass {nick host hand arg} {
	if {[llength $arg] < 3} {
		
		return 0
	}
	set mask [lindex $arg 1]
	set hosta [lindex $arg 5]
	if {[string first "!" $mask] == -1 && [string first "@" $mask] == -1} {set mask $mask!*@*}
#	if {[string first "!" $mask] == -1} {set mask *!*$mask}
	if {[string first "@" $mask] == -1} {set mask $mask*@*}
	set chan [lindex $arg 2]
	set ti [lindex $arg 3]
	set invitera [lindex $arg 4]
	set reason "$invitera - $hosta makes invites on $chan !!"
	if {![passwdok $hand [lindex $arg 0]]} {
		
		return 0
	}
	if {[passwdok $hand ""]} {
		
		return 0
	}
	if {![validchan $chan]} {
               
		return 0
	}
	if {![matchattr $hand C $chan]} {
           
		return 0
	}
	if {[botisop $chan]} {pushmode $chan +b $mask
	putserv "Kick $chan $invitera :$invitera - $hosta makes invites"}
	switch $ti {
		""
		{
			newchanban $chan $mask $nick $reason
                   
		}
		0
		{
			newchanban $chan $mask $nick $reason $ti
		
		}
		default
		{
			newchanban $chan $mask $nick $reason $ti
           
		}
	}
	return 0
}



	
