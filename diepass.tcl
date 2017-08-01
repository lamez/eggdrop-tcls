##############################
# Set your die password here.#
##############################

set pass "parolkazashutdown"

##################################################################
# Would you like to log all die attempts with invalid passwords? #
##################################################################

set useinfo "1"

###################################################################################################
# Set the channel or nick to private message when an attempt is made. (Only if useinfo is enabled) #
###################################################################################################

set infodest "#ShakE"

##################################################################################################################
# Message to send on failure, NOTE: only enter what would come after the users handle, the handle is hard-coded. #
##################################################################################################################

set failmsg "Nekoi se opitva da me die sys .die no o6te ne e ulu4il parolata!!"

####################
# Code begins here #
####################

bind dcc n|- die dcc:die
unbind msg n|- die *msg:die

proc dcc:die {hand idx text} {
	global useinfo infodest failmsg pass
	if {$text == ""} {
		putidx $idx "Napishi: .die <password> \[reason\]"
		return 0
	}
	set chkpass [lindex $text 0]
	if {$chkpass == $pass} { 
		if {[llength $text] > 1} {
			set reason [lrange $text 1 end]
		} else {
			set reason "upalnomo6ten ot $hand"
		}
		die $reason 
		return 1
	} else {
		putidx $idx "DIEPASS: Invalid die password, attempt has been logged."
		if {$useinfo == 1} { 
			puthelp "PRIVMSG $infodest :DIEPASS: $hand $failmsg."
			putlog "DIEPASS: $hand се опитва да ме die със .die но още не е улучил паролата!! \"$chkpass\" "
			return 0
		} 
		return 0
	}
}

#putlog "DIEPASS: DiePass.tcl 1.4 by Nilsy and Wcc is loaded."
#if {$useinfo} {
#	putlog "DIEPASS: Info logging is enabled."
#	putlog "DIEPASS: Info Destination = $infodest."
#}