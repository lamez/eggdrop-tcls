##################################
### KillLog.tcl                ###
### Version 2.5.1              ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

###################################################################
## This script logs kills seen in the channel to a log file and  ##
## generates an html file. You can also optionally not log ghost ##
## kills. WARNING: If you are upgrading from version 2.4 or      ##
## earlier, you MUST erase the old database file before running  ##
## the script.                                                   ##
###################################################################

##############
## COMMANDS ##
####################################
## DCC ## .khtml (Can be changed) ##
######### Manually updates the    ##
######### kill log page.	  ##
####################################

##########################################################
## Just load the script, edit the settings, and rehash. ##
##########################################################

###################################################################
# Set the command used to manually update the kill log page here. #
###################################################################

set killlog_setting(command) "khtml"

####################################################################
# Set the flag required to manually update the kill log page here. #
####################################################################

set killlog_setting(flag) "+m"

#########################################################################
# Would you like to also log ghost kills? (DALnet and similar networks) #
#########################################################################

set killlog_setting(logghost) 0

###############################
# Set the html filename here. #
###############################

set killlog_setting(page) "./web/kills.html"

##################################################################
# Set the maximum number of kills to store in the database here. #
# Do not set this higher then 999999999.                         #
##################################################################

set killlog_setting(trim) "100"

#######################################
# Completely disable web page output? #
#######################################

set killlog_setting(html_disable) 0

##################################################################
# Set here the path to the DAWG template file you would like to  #
# use. You can obtain templates by visiting http://dawg.dynu.com #
# and clicking the templates link.                               #
##################################################################

set killlog_setting(tpl) "./scripts/KillLog_OGGBO.tpl"

##############################
# Set the log filename here. #
##############################

set killlog_setting(log) "./scripts/kills.log"

###################################
# Set the database filename here. #
###################################

set killlog_setting(logdb) "./scripts/kills.db"

###################################
# Enable use of bold in DCC chat? #
###################################

set killlog_setting(bold) 1

###########################################
# Prefix "KILLLOG:" in DCC chat messages? #
###########################################

set killlog_setting(KILLLOG:) 1

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002KILLLOG:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002KILLLOG:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

bind sign - * killlog_log
bind dcc $killlog_setting(flag) $killlog_setting(command) killlog_update
set killlog_setting(version) "2.5.1"

set killlog_notpl 0
if {![info exists killlog_setting(tpl)] || [catch {source $killlog_setting(tpl)}]} {
	putlog "\002KILLLOG:\002 The template file could not be opened; using default."
	set killlog_notpl 1	
}
foreach {s v} [list Page_CC #000000 Page_HC #000000 Page_LinkC #0000FF Page_TTextC #000000 Page_TextC #000000 Page_BGC \
	#FFFFFF Page_TCC_2 #E0E0E0 Page_TCC_1 #C0C0C0 Page_THC_2 #8080E0 Page_THC_1 #8080C0 Page_TCS 4 Page_THS 5 Page_TitleS \
	6 Page_Title {Kill Log} Page_TitleTag {Kill Log} Page_Img {}] {
	if {$killlog_notpl || ![info exists killlog_setting($s)]} { set killlog_setting($s) $v  }
}
proc killlog_dopre {} {
	global killlog_setting
	if {!$killlog_setting(KILLLOG:)} { return "" }
	if {!$killlog_setting(bold)} { return "KILLLOG: " }
	return "\002KILLLOG:\002 "
}
proc killlog_log {nick host hand chan kill} {
	global killlog_setting
	if {[regexp {^killed|^autokilled|^klined|^svskill} [string tolower $kill]] && ($killlog_setting(logghost) || ![regexp {^killed \(nickserv \(ghost} [string tolower $kill]])} { killlog_putkilllog $nick $host $chan $kill }
}
proc killlog_putkilllog {nick host chan kill} {
	global killlog_setting
	regsub -all -- " " [clock format [clock seconds] -format "%I:%M:%S %p %x"] "\\&" time
	regsub -all -- " " "$kill" "\\&" kill 
	puts [set databaseid [open $killlog_setting(logdb) a]] "$time $nick $host $chan $kill"
	puts [set logid [open $killlog_setting(log) a]] "[clock format [clock seconds] -format "%I:%M:%S %p %x"] $nick!$host \($kill\)"
	close $databaseid
	close $logid
	killlog_do_html
}
proc killlog_update {hand idx text} {
	killlog_do_html
	putdcc $idx "[killlog_dopre]Web page updated."
}
proc killlog_do_html {} {
	global killlog_setting
	if {$killlog_setting(html_disable)} { return }
	set killpageid [open $killlog_setting(page) w]	
	puts $killpageid "<html>\n<head>\n<title>$killlog_setting(Page_TitleTag)</title>\n<META NAME=\"description\" CONTENT=\"Kill Log\">" 
	puts $killpageid "<META NAME=\"keywords\" CONTENT=\"kill, akill, kline, svskill, stats, IRCd, IRC, server, clones, abuse, flood\">\n</head>"
	puts $killpageid "<body bgcolor=\"$killlog_setting(Page_BGC)\">"
	if {$killlog_setting(Page_Img) != ""} { puts $killpageid "<center><img src=\"$killlog_setting(Page_Img)\"></img></center>" }
	puts $killpageid "<font size=\"$killlog_setting(Page_TitleS)\" color=$killlog_setting(Page_TextC)><center>$killlog_setting(Page_Title)</center></font><br>"
	puts $killpageid "<center>\n<table>\n<tr>"
	foreach {a b} [list 1 Time 2 Nick 1 Host 2 Channel 1 Kill] { puts $killpageid "<td align=left bgcolor=$killlog_setting(Page_THC_${a})><font size=\"$killlog_setting(Page_THS)\"><center>$b</center></font></td>" }
	puts $killpageid "</tr>"
	if {[catch {set databaseid [open $killlog_setting(logdb) r]} error]} {
		puts $killpageid "<tr>"
		foreach a [list 1 2 1 2 1] { puts $killpageid "<td align=left bgcolor=$killlog_setting(Page_TCC_${a})><font size=\"$killlog_setting(Page_TCS)\"><center>-</center></font></td>" }
		puts $killpageid "</tr>"
	} {
		set data [split [read $databaseid] \n]
		close $databaseid
		foreach line [lrange $data [expr [llength $data] - ($killlog_setting(trim) + 1)] end] {
			if {[string length [join $line]] <= 0} { continue }
			for {set i 0} {$i <= 4} {incr i} { regsub -all -- "\\&" [join [lindex $line $i]] " " arg[expr $i + 1] }
			puts $killpageid "<tr>"
			foreach {a b} [list 1 $arg1 2 $arg2 1 $arg3 2 $arg4 1 $arg5] { puts $killpageid "<td align=left bgcolor=$killlog_setting(Page_TCC_${a})><font size=\"$killlog_setting(Page_TCS)\"><center>$b</center></font></td>" }
			puts $killpageid "</tr>"
		}
	}
	puts $killpageid "</table>\n<br>\n<br>"
	puts $killpageid "<font color=$killlog_setting(Page_TextC)>Last Updated: [clock format [clock seconds] -format %D] [clock format [clock seconds] -format "%I:%M %p"]</font>"
	puts $killpageid "</center>\n</body>\n</html>\n<!--<DAWGID>KillLog $killlog_setting(version)</DAWGID>-->"
	close $killpageid
}
putlog "\002KILLLOG:\002 KillLog.tcl Version $killlog_setting(version) by Wcc is loaded."