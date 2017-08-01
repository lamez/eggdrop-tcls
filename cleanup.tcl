# This TCL will remove users for the userlist who are not seen in 60 days
# You may try the dcc command .cleanup too... does the same, but does it
# right away.

# Christian Felde
# email: cfelde@powertech.no or cfelde@geocities.com

bind time - "00 04 * * *" time_scan_userfile
bind dcc +m cleanup dcc_scan_userfile

proc dcc_scan_userfile {hand idx args} {
    putlog "$hand started userfile scan... Time: [time]"
    scan_userfile
}

proc time_scan_userfile {min hour day month year} {
    putlog "Stated auto-scan of userfile. Time: [time]"
    scan_userfile
}

proc scan_userfile { } {
    set rmusers 0
    set errors 0
    foreach hand [userlist] {
	set leave 0
	if {[lindex [getuser $hand LASTON] 0] < [expr [unixtime] - 5184000]} {
	    if {[matchattr $hand +n] == 1} {
		set leave 1
	    }
	    if {[matchattr $hand +m] == 1} {
		set leave 1
	    }
	    if {[matchattr $hand +f] == 1} {
		set leave 1
	    }
	    if {[matchattr $hand +o] == 1} {
		set leave 1
	    }
	    if {$leave == 0} {
		set okdel [deluser $hand]
		if {$okdel == 1} {
		    putlog "Deleted: $hand"
		    incr rmusers
		}
		if {$okdel != 1} {
		    putlog "Error in deleting: $hand"
		    incr errors
		}
	    }
	}
    }
    putlog "CleanUp stats:"
    putlog "Current time: [time]"
    putlog "Users deleted: $rmusers"
    putlog "Errors: $errors"
}

putlog "cleanup.tcl loaded..."