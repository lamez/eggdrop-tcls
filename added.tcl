## Bind # Shows master/owner added users.
set showusers 1

unbind dcc m|m adduser *dcc:adduser  
unbind dcc m|- +user *dcc:+user 
unbind dcc m|- -user *dcc:-user 
unbind dcc t|- +bot *dcc:+bot 
bind dcc m|m adduser dcc:adduser 
bind dcc m|- +user dcc:+user 
bind dcc m|- -user dcc:-user 
bind dcc t|- +bot dcc:+bot 
bind dcc n listmaster dcc:listmaster
bind dcc n listowner dcc:listowner
## Initiliaze  

if {![info exists whois-fields]} {     
  set whois-fields "" 
} 

set Addedapp 0 
set Usersapp 0 
set Botsapp 0 

foreach z [split ${whois-fields}] {     
  if {[string tolower $z] == [string tolower "Added"]} {         
	set Addedapp 1     
  }     
  if {[string tolower $z] == [string tolower "Users"]} {         
	set Usersapp 1     
  }     
  if {[string tolower $z] == [string tolower "Bots"]} {         
	set Botsapp 1     	
  } 
}  
  
if {$Addedapp == 0} { append whois-fields " " "Added" } 
if {$Usersapp == 0} { append whois-fields " " "Users" } 
if {$Botsapp == 0} { append whois-fields " " "Bots" }  

## dcc:adduser start  
proc dcc:adduser {hand idx paras} {   
  global botnick     
  set user [lindex $paras 1]     
  set userorbot "user"     
  if {$user == ""} { 	
	if {[string index $paras 0] == "!"} { 	    
	  set user [string range [lindex $paras 0] 1 end] 	
	} else { 	    
	  set user [lindex $paras 0] 	
	  }    
   }     
   if {[validuser $user]} { 	
    *dcc:adduser $hand $idx $paras     
  } else { 	
	*dcc:adduser $hand $idx $paras 	
  if {[validuser $user]} {             
	setuser $user xtra Added "by $hand"           
	userxtra $hand $userorbot 	    
	tellabout $hand $user 	
    }     
  } 
}      

## dcc:adduser end  
## dcc:+user start  
proc dcc:+user {hand idx paras} {   
  global botnick     
  set user [lindex $paras 0]     
  set userorbot "user"     
  if {[validuser $user]} {         
	*dcc:+user $hand $idx $paras     
  } else {        
	*dcc:+user $hand $idx $paras         
  if {[validuser $user]} {             
	setuser $user xtra Added "by $hand"           
	userxtra $hand $userorbot 	    
	tellabout $hand $user         
	}     
  } 
}  

## dcc:+user end  
## dcc:+bot start  
proc dcc:+bot {hand idx paras} {   
  global botnick     
  set user [lindex $paras 0]     
  set userorbot "bot"     
  if {[validuser $user]} {         
	*dcc:+bot $hand $idx $paras     
  } else {         
	*dcc:+bot $hand $idx $paras         
  if {[validuser $user]} {             
	setuser $user xtra Added "by $hand"           
	userxtra $hand $userorbot 	    
	tellabout $hand $user         
	}     
  } 
}  
## dcc:+bot end  
## dcc:-user start  
proc dcc:-user {hand idx paras} {   
  global botnick   
  set user [lindex $paras 0]   
  if {[validuser $user]} {     
	set umaster "[lindex [getuser $user xtra Added] 1]"     
  if {[matchattr $user b]} {       
	set userorbot "bot"     
  } else { 
	set userorbot "user"
  }     
  *dcc:-user $hand $idx $paras     
  if {![validuser $user]} {       
	if {[validuser $umaster]} {         
	  sendnote $botnick $umaster "$user deleted. $hand ($botnick)"         
	  userxtradel $umaster $userorbot       
		}     
	}   
  } else {     
	*dcc:-user $hand $idx $paras   
  } 
}  

## dcc:-user end  
## tellabout start  
proc tellabout {hand user} {     
global nick notify-newusers     
  foreach ppl ${notify-newusers} { 	
	sendnote $nick $ppl "introduced to $user by $hand"     
  } 
}      
## tellabout end  
## xtras start 
proc userxtra {hand arg} {   
  if {$arg == "user"} {     
	if {[getuser $hand xtra Users] == ""} {       
	  setuser $hand xtra Users "(1)"     
	} else {      
	   set a [string trimleft [getuser $hand xtra Users] (] ; set a [string trimright $a )]       
	   setuser $hand xtra Users "([expr $a + 1])"     
	   }   
	 }   
  if {$arg == "bot"} {     
	if {[getuser $hand xtra Bots] == ""} {       
	  setuser $hand xtra Bots "(1)"     
	} else {       
	  set a [string trimleft [getuser $hand xtra Bots] (] ; set a [string trimright $a )]       
	  setuser $hand xtra Bots "([expr $a + 1])"     
    }   
  } 
}  
proc userxtradel {hand arg} {   
  if {$arg == "user"} {     
	if {[getuser $hand xtra Users] == ""} {       
	  return 0     
	} else {       
	  set a [string trimleft [getuser $hand xtra Users] (] ; set a [string trimright $a )]       
	if {$a == 0} { 
	  return 0 
	}       
	  setuser $hand xtra Users "([expr $a - 1])"     
    }   
  }   
  if {$arg == "bot"} {     
	if {[getuser $hand xtra Bots] == ""} {       
	  return 0     
	} else {       
	  set a [string trimleft [getuser $hand xtra Bots] (] ; set a [string trimright $a )]       
	if {$a == 0} { 
	  return 0 
	}       
	setuser $hand xtra Bots "([expr $a - 1])"     
	}   
  } 
} 
proc dcc:listmaster {hand idx param} {
  if {$param == ""} {
	foreach master [userlist m|m] {
	  added:usercheck $master $idx m n
    }
  } else {
	if {$param == "help"} {
	  putdcc $idx "Usage: .listmaster \[handle(s)\]"
	  return
	}
    set notknown ""
    set count 0
	foreach handly $param {
	  if {![validuser $handly]} {
		append notknown " $handly"
		incr count
	  } else {
		added:usercheck $handly $idx m n
	  }
	}
	if {$notknown != ""} {
	  regsub -all {^ } $notknown {} notknown
	  regsub -all { } $notknown {, } notknown

	  if {$count != 1} {
	    putdcc $idx "$notknown are not known to me."
	  } else {
	    putdcc $idx "$notknown is not known to me."
	  }
	}
  }
}

proc dcc:listowner {hand idx param} {
  if {$param == ""} {
    foreach owner [userlist n|n] {
	  added:usercheck $owner $idx n -
    }
  } else {
	if {$param == "help"} {
	  putdcc $idx "Usage: .listowner \[handle(s)\]"
	  return
	}
    set notknown ""
    set count 0
	foreach handly $param {
	  if {![validuser $handly]} {
		append notknown " $handly"
		incr count
	  } else {
		added:usercheck $handly $idx n -
	  }
	}
	if {$notknown != ""} {
	  regsub -all {^ } $notknown {} notknown
	  regsub -all { } $notknown {, } notknown

	  if {$count != 1} {
	    putdcc $idx "$notknown are not known to me."
	  } else {
	    putdcc $idx "$notknown is not known to me."
	  }
	}
  }
}

proc added:usercheck {hand idx flag dopflags} {
  global showusers
  if {![matchattr $hand $dopflags|$dopflags] || $dopflags == "-"} {
	set UsersAdded [string trimleft [getuser $hand xtra Users] (] ; set UsersAdded [string trimright $UsersAdded )]     
	set BotsAdded [string trimleft [getuser $hand xtra Bots] (] ; set BotsAdded [string trimright $BotsAdded )] 
    set answer ""

    if {$UsersAdded == ""} {
	  set UsersAdded 0
	} else {
	  if {$UsersAdded == 1} {
	    set answer "$UsersAdded User"
	  } else {
	    set answer "$UsersAdded Users"
	  }
	}

	if {$BotsAdded == ""} {
	  set BotsAdded 0
	} else {
	  if {$answer != ""} {
	    append answer " And "
	  }
  	  if {$BotsAdded == 1} {
    	append answer "$BotsAdded Bot"
      } else {
        append answer "$BotsAdded Bots"
      }
	}

	if {[matchattr $hand $flag]} {
	  set globorloc "Global"
	} else {
	  set allchan ""
	  foreach chanz [channels] {
		if {[matchattr $hand -|$flag $chanz]} {
		  append allchan " $chanz"
		}
	  }
	  regsub -all {^ } $allchan {} allchan
	  regsub -all { } $allchan {, } allchan
	  set globorloc "Local $allchan"
	}

	if {[expr $UsersAdded + $BotsAdded] != 0} {
	  putdcc $idx "$hand ($globorloc) - Added: $answer"
	  if {$showusers == 1} {
		set botko ""
		set luzeri ""
	    foreach luzer [userlist -|-] {
		  if {[getuser $luzer xtra Added] == "by $hand"} {
			if {[matchattr $luzer b]} {
			  append luzeri " $luzer"
			} else {
			  append botko " $luzer"
			}
		  }
		}
	  regsub -all {^ } $botko {} botko
	  regsub -all { } $botko {, } botko
	  regsub -all {^ } $luzeri {} luzeri
	  regsub -all { } $luzeri {, } luzeri
		if {$luzeri != ""} {
		  putdcc $idx "Users - $luzeri"
		}
		if {$botko != ""} {
		  putdcc $idx "Bots - $botko"
		}
	  }
	}
  }
}
