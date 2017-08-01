##############################################################
# Tozi script zabraniava na potrebiteli koito niamat +n flag #
# da pishat na private s CS, NS i MS.                        #
# Napisan e poradi za4estilite problemi koito praviat        #
# masteri i drugi potrebiteli na bota kato izpolzvat pravata #
# na bota v CS.                                              #
##############################################################

set ChanServ_nick "CS"
set NickServ_nick "NS"
set MemoServ_nick "MS"

bind dcc -|- msg check_msg

proc check_msg { arg1 arg2 arg3 } {
    global ChanServ_nick NickServ_nick MemoServ_nick
    set saob [lrange $arg3 1 end]
    set kamkogo [lindex $arg3 0]
    set kamkogo [string toupper $kamkogo 0 end]
    if {![matchattr $arg1 +n]} {
	if {$kamkogo == $ChanServ_nick || $kamkogo == $NickServ_nick || $kamkogo == $MemoServ_nick} {
	    putlog "$arg1, samo useri s +n flag mogat da pishat na private s $kamkogo!"
	    return 0
	}
    }
    putserv "PRIVMSG $kamkogo :$saob"
}

putlog "<<< No services privmsg loaded >>>"