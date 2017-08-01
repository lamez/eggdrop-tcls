# chanscan.tcl v1.05 [1 August 2000]
# Copyright (C) 1999-2000 Teemu Hjelt <temex@iki.fi>
#
# Latest version can be found from http://www.iki.fi/temex/eggdrop/
# 
# If you have any suggestions, questions or you want to report 
# bugs, please feel free to send me email to temex@iki.fi
#
# With this script you can scan the entire channel 
# for ircops, people who are away, ops or voiced people
#
# Current DCC Commands:
#    ircopscan, awayscan, opscan, voicescan
#
# Tested on eggdrop1.4.4 with TCL 7.6
#
# Version history:
# v1.00 - The very first version!
# v1.01 - Made the channel option an optional option.
# v1.02 - Little bugs fixed.
# v1.03 - Removed cshelp command. Help is now included in chanscan command.
# v1.04 - Fixed little bug in dcc:cs_chanscan proc.
# v1.05 - Removed chanscan command because it was a bit confusing,
#         changed putlogs to putidxs and fixed few minor bugs. 
    

### Settings ###

## What users can use the commands?
set cs_flag "m"

###### You don't need to edit below this ######

### Misc Things ###

set cs_ver "2001"

### Bindings ###

bind dcc $cs_flag ircopscan dcc:cs_ircopscan
bind dcc $cs_flag awayscan dcc:cs_awayscan
bind dcc $cs_flag opscan dcc:cs_opscan
bind dcc $cs_flag voicescan dcc:cs_voicescan

### Ircopscan Procs ###

proc dcc:cs_ircopscan {hand idx arg} {
global cs_idx
	putcmdlog "#$hand# ircopscan $arg"
	if {[lindex [split $arg] 0] != ""} { 
		set chan [lindex [split $arg] 0] 
	} else { 
		set chan [lindex [console $idx] 0] 
	}
	if {($chan == "") || ($chan == "*")} {
		putidx $idx "Usage: .ircopscan <channel>"
	} else {
		if {![cs_botonchan $chan]} {
			putidx $idx "I'm not on $chan."
		} else {
			set cs_idx $idx
			cs_ircopscan $chan
		}
	}
}

proc cs_ircopscan {chan} {
global cs_ichan cs_iamount cs_idx
	if {$chan != ""} {
		bind raw - 352 raw:cs_ircop352
		bind raw - 315 raw:cs_ircop315
		set cs_ichan $chan
		set cs_iamount 0
		putserv "WHO $chan"
		putidx $cs_idx "--- Ircopscan $cs_ichan"
	}
}

proc raw:cs_ircop352 {from key arg} {
global cs_ichan cs_iamount cs_idx
	if {[string match "*\\**" [lindex [split $arg] 6]]} { 
		putidx $cs_idx " [lindex [split $arg] 5] ([lindex [split $arg] 2]@[lindex [split $arg] 3]) on [lindex [split $arg] 4]"
		incr cs_iamount
	}
}

proc raw:cs_ircop315 {from key arg} {
global cs_ichan cs_iamount cs_idx
	putidx $cs_idx "--- End of Ircopscan ($cs_iamount)"
	unbind raw - 352 raw:cs_ircop352
	unbind raw - 315 raw:cs_ircop315
}

### Awayscan Procs ###

proc dcc:cs_awayscan {hand idx arg} {
global cs_idx
	putcmdlog "#$hand# awayscan $arg"
	if {[lindex [split $arg] 0] != ""} { 
		set chan [lindex [split $arg] 0] 
	} else { 
		set chan [lindex [console $idx] 0] 
	}
	if {($chan == "") || ($chan == "*")} {
		putidx $idx "Usage: .awayscan <channel>"
	} else {
		if {![cs_botonchan $chan]} {
			putidx $idx "I'm not on $chan."
		} else {
			set cs_idx $idx
			cs_awayscan $chan
		}
	}
}

proc cs_awayscan {chan} {
global cs_achan cs_aamount cs_idx
	if {$chan != ""} {
		bind raw - 352 raw:cs_away352
		bind raw - 315 raw:cs_away315
		set cs_achan $chan
		set cs_aamount 0
		putserv "WHO $chan"
		putidx $cs_idx "--- Awayscan $cs_achan"
	}
}

proc raw:cs_away352 {from key arg} {
global cs_achan cs_aamount cs_idx
	if {[string match "*G*" [lindex [split $arg] 6]]} { 
		putidx $cs_idx " [lindex [split $arg] 5] ([lindex [split $arg] 2]@[lindex [split $arg] 3]) on [lindex [split $arg] 4]"
		incr cs_aamount
	}
}

proc raw:cs_away315 {from key arg} {
global cs_achan cs_aamount cs_idx
	putidx $cs_idx "--- End of Awayscan ($cs_aamount)"
	unbind raw - 352 raw:cs_away352
	unbind raw - 315 raw:cs_away315
}

### Opscan Procs ###

proc dcc:cs_opscan {hand idx arg} {
global cs_idx
	putcmdlog "#$hand# opscan $arg"
	if {[lindex [split $arg] 0] != ""} { 
		set chan [lindex [split $arg] 0] 
	} else {
		set chan [lindex [console $idx] 0] 
	}
	if {($chan == "") || ($chan == "*")} {
		putidx $idx "Usage: .opscan <channel>"
	} else {
		if {![cs_botonchan $chan]} {
			putidx $idx "I'm not on $chan."
		} else {
			set cs_idx $idx
			cs_opscan $chan
		}
	}
}

proc cs_opscan {chan} {
global cs_ochan cs_oamount cs_idx
	if {$chan != ""} {
		bind raw - 352 raw:cs_op352
		bind raw - 315 raw:cs_op315
		set cs_ochan $chan
		set cs_oamount 0
		putserv "WHO $chan"
		putidx $cs_idx "--- Opscan $cs_ochan"
	}
}

proc raw:cs_op352 {from key arg} {
global cs_ochan cs_oamount cs_idx
	if {[string match "*@*" [lindex [split $arg] 6]]} { 
		putidx $cs_idx " [lindex [split $arg] 5] ([lindex [split $arg] 2]@[lindex [split $arg] 3]) on [lindex [split $arg] 4]"
		incr cs_oamount
	}
}

proc raw:cs_op315 {from key arg} {
global cs_ochan cs_oamount cs_idx
	putidx $cs_idx "--- End of Opscan ($cs_oamount)"
	unbind raw - 352 raw:cs_op352
	unbind raw - 315 raw:cs_op315
}

### Voicescan Procs ###

proc dcc:cs_voicescan {hand idx arg} {
global cs_idx
	putcmdlog "#$hand# voicescan $arg"
	if {[lindex [split $arg] 0] != ""} {
		set chan [lindex [split $arg] 0] 
	} else { 
		set chan [lindex [console $idx] 0] 
	}
	if {($chan == "") || ($chan == "*")} {
		putidx $idx "Usage: .voicescan <channel>"
	} else {
		if {![cs_botonchan $chan]} {
			putidx $idx "I'm not on $chan."
		} else {
			set cs_idx $idx
			cs_voicescan $chan
		}
	}
}

proc cs_voicescan {chan} {
global cs_vchan cs_vamount cs_idx
	if {$chan != ""} {
		bind raw - 352 raw:cs_voice352
		bind raw - 315 raw:cs_voice315
		set cs_vchan $chan
		set cs_vamount 0
		putserv "WHO $chan"
		putidx $cs_idx "--- Voicescan $cs_vchan"
	}
}

proc raw:cs_voice352 {from key arg} {
global cs_vchan cs_vamount cs_idx
	if {[string match "*+*" [lindex [split $arg] 6]]} { 
		putidx $cs_idx " [lindex [split $arg] 5] ([lindex [split $arg] 2]@[lindex [split $arg] 3]) on [lindex [split $arg] 4]"
		incr cs_vamount
	}
}

proc raw:cs_voice315 {from key arg} {
global cs_vchan cs_vamount cs_idx
	putidx $cs_idx "--- End of Voicescan ($cs_vamount)"
	unbind raw - 352 raw:cs_voice352
	unbind raw - 315 raw:cs_voice315
}

### Other Procs ###

proc cs_botonchan {chan} {
global botnick numversion
	if {$numversion < 1032400} {
		if {([validchan $chan]) && ([onchan $botnick $chan])} {
			return 1
		} else {
			return 0
		}
	} else {
		if {([validchan $chan]) && ([botonchan $chan])} {
			return 1
		} else {
			return 0
		}
	}
}

### End ###

putlog "TCL loaded: chanscan.tcl"
