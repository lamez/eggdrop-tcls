#         Script : NoComics v1.00 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2000 Radical Computer Systems
#
#       Platform : Linux 2.0.36
#                  Eggdrop v1.2.0+bel1
#
#    Description : Painfully simple script. It will kick out anyone using 
#                  MS Comic Chat clients in "comic" mode.
#                  I hate those bastereds. lol.
#
#        History : 04/19/2000 - First Release
#
#
#   Future Plans : Nothing that I know of. EMail me with suggestions.
#                 
#
# Author Contact :     Email - DProper@bigfoot.com
#                  Home Page - http://www.chaotix.net/~dproper
#                        IRC - Nick: DrN  UnderNet/DALnet/ChatNet
#
#   Radical Computer Systems - http://www.chaotix.net/rcs/
# To subscribe to the RCS mailing list: mail majordomo@chaotix.net and in
#  BODY of message, type  subscribe rcs-list
#
#  Feel free to Email me any suggestions/bug reports/etc.
# 
# You are free to use this TCL/script as long as:
#  1) You don't remove or change author credit
#  2) You don't release it in modified form. (Only the original)
# 
# If you have a "too cool" modification, send it to me and it'll be
# included in the official. (With your credit)
#
# Commands Added:
#  Where     F CMD       F CMD         F CMD        F CMD
#  -------   - --------- - ----------- - ---------- - --------- - -------
#  Public:   - N/A             
#     MSG:   - N/A
#     DCC:   - N/A
#
# Public Matching: *# Appears as *
#

#
# A Special thanks would out to the Alpha Team.. If there was one :)
#

#\
# |##### NOTE: Anything on the Chaotix.Net domain is currently offline
# |#####       until we can get the money to pay the ISP bill.
# |#####       Email me at dproper@bigfoot.com if you want to help.
#/

set ncc_ver "v1.00"

# Set this to 1 if you want it to tell them in channel why thier being banned.
set ncc_showpubmsg 0

# This is how long in seconds the ban will last. 3 seconds is good enough
# to kill auto-rejoin scripts.
set ncc_banlength 3

bind pubm - "*# Appears as *" pub_nocomic
proc pub_nocomic {nick uhost hand chan rest} {
global ncc_showpubmsg ncc_banlength
if {([matchattr $hand b] != 0)} {return 1}

if {[botisop $chan] == 0} {
   putserv "PRIVMSG $chan :\001ACTION yells "MS Comic Chat Fucking Sucks!"\001"
                           return 0
                          }
 putserv "PRIVMSG $nick :\002We don't allow MS Comic Chat clients in \"comic\" mode to be used.\002"
 putserv "PRIVMSG $nick :\002Either goto text mode or visit http://www.pirchat.com for a real client.\002"

if {($ncc_showpubmsg == 1)} {
 putserv "PRIVMSG $chan :\002$nick : We don't allow MS Comic Chat clients in \"comic\" mode to be used.\002"
 putserv "PRIVMSG $chan :\002$nick : Either goto text mode or visit http://www.pirchat.com for a real client.\002"
                        }
 putserv "MODE $chan +b [maskhost $nick!$uhost]"
 flushmode $chan
 putserv "KICK $chan $nick :\002MS Comic Chat auto-removal\002"
 timer $ncc_banlength "timedeban $chan [maskhost $nick!$uhost]"
 return 0
}

return "NoComics $ncc_ver by DrN Loaded."


