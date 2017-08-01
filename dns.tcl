##################################
### Dns.tcl                    ###
### Version 2.5                ###
### By Wcc                     ###
### wcc@techmonkeys.org        ###
### http://www.dawgtcl.com:81/ ###
### EFnet #|DAWG|Tcl           ###
##################################

############################################################################
### Copyright © 2000 - 2002 |DAWG| Scripting Group. All rights reserved. ###
############################################################################

########################################################################
## This script preforms dns lookup from the channel or the partyline. ##
########################################################################

##############
## COMMANDS ##
#######################################################################
## DCC ## .dns <host/ip> (Can be changed.)                           ##
######### Preforms a dns lookup on the specified host or ip address. ##
#######################################################################
## PUB ## !nickdns <nick> (Can be changed.)                          ##
######### Preforms a dns lookup on the specified nick's hostname or  ##
######### ip address.                                                ##
######### ---------------------------------------------------------- ##
######### !dns <host/ip> (Can be changed.)                           ##
######### Preforms a dns lookup on the specified host or ip address. ##
#######################################################################

##########################################################
## Just load the script, edit the settings, and rehash. ##
##########################################################

#######################################################
# Set the required flag to use the dns commands here. #
#######################################################

set dns_setting(flag) "+o"

#############################
# Set the dcc command here. #
#############################

set dns_setting(dcc_c) "dns"

#################################
# Set the pub dns command here. #
#################################

set dns_setting(pub_c) "!dns"

#####################################
# Set the pub nickdns command here. #
#####################################

set dns_setting(pubn_c) "!nickdns"

###################################
# Enable use of bold in DCC chat? #
###################################

set dns_setting(bold) 1

#######################################
# Prefix "DNS:" in DCC chat messages? #
#######################################

set dns_setting(DNS:) 1

####################
# Code begins here #
####################

if {![string match 1.6.* $version]} { putlog "\002DNS:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002DNS:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

bind pub $dns_setting(flag) $dns_setting(pub_c) dns_pub
bind pub $dns_setting(flag) $dns_setting(pubn_c) dns_nick_pub
bind dcc $dns_setting(flag) $dns_setting(dcc_c) dns_dcc

proc dns_dopre {} {
	if {!$::dns_setting(DNS:)} { return "" }
	if {!$::dns_setting(bold)} { return "DNS: " }
	return "\002DNS:\002 "
}
proc dns_dcc {hand idx text} {
	if {[scan $text "%s" address] != 1} { putdcc $idx "[dns_dopre]Usage: .dns <host/ip>" ; return }
	dnslookup [split $address] dns_output_dcc $idx [split $address]
}
proc dns_pub {nick uhost hand chan text} {
	if {[scan $text "%s" address] != 1} { putserv "PRIVMSG $chan :Usage: !dns <host/ip>" ; return }
	dnslookup [split $address] dns_output_pub $chan [split $address]
}
proc dns_nick_pub {nick uhost hand chan text} {
	if {[scan $text "%s" rnick] != 1} { putserv "PRIVMSG $chan :Usage: !nickdns <nick>" ; return }
	if {![onchan $rnick $chan]} { putserv "PRIVMSG $chan :$rnick is not on $chan." ; return }
	set tl [lindex [split [getchanhost $rnick] @] 1] 
	dnslookup $tl dns_output_pub $chan $tl $rnick
}
proc dns_output_pub {ip host status chan addr {rnick ""}} {
	if {!$status} { putserv "PRIVMSG $chan :[expr {($rnick != "")?"$rnick's host \($addr\)":"$addr"}] could not be resolved." ; return }
	set iphost [expr {([string match $ip $addr])?$ip:$host}]
	putserv "PRIVMSG $chan :[expr {($rnick != "")?"$rnick's host \($iphost\)":"$iphost"}] has been resolved to [expr {([string match $ip $addr])?$host:$ip}]."
}
proc dns_output_dcc {ip host status idx addr} {
	if {![valididx $idx]} { return }
	if {!$status} { putdcc $idx "[dns_dopre]Could not resolve $addr." ; return }
	putdcc $idx "[dns_dopre][expr {([string match $ip $addr])?$ip:$host}] has been resolved to [expr {([string match $ip $addr])?$host:$ip}]."
}
putlog "\002DNS:\002 Dns.tcl 2.5 by Wcc is loaded."