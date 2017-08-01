#  ChanLimit.tcl by Nils Ostbjerg <shorty@business.auc.dk>
#  
#  tozi script ne e pisan ot men 
#  scripta postavia limit na kanala kato vzema za baza 4isloto
#  na potrebitelite v nego i dobavia kam tiah jelanoto ot vas 4islo
#  tova e i podobrenieto /ako moje da se nare4e taka/ koeto sam mu napravil :)

# zadaite 4isloto koeto da se pribavia kam broia na potrebitelite
set nomer 5

#########################################
# nasam ne e nujno nishto da promeniate #
#########################################

bind time - "* * * * *" time:ChanLimit

proc time:ChanLimit {min hour day month year} {
    global nomer
    foreach chan [channels] {
	set newlimit [expr [llength [chanlist $chan]] + $nomer]
	set currentlimit [currentlimit $chan]
	if {$currentlimit < [expr $newlimit - 1] || $currentlimit > [expr $newlimit + 1]} {
	    putserv "mode $chan +l $newlimit"
	}
    }    
}



proc currentlimit {chan} {
    set currentmodes [getchanmode $chan]
    if {[string match "*l*" [lindex $currentmodes 0]]} {
	return [lindex $currentmodes end] 
    }
    return 0
}


 
putlog "<<< Channel Limit loaded >>>"