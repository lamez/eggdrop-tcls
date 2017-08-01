# Scan Port v1.0 (26 April 2001) By irco <irco@mail.com> EFnet #Q8Help
# you can scan any port you want 
# Notes: I wrote this on eggdrop 1.3.x, don't complain if you load it up
# on your prehistoric 1.1.5 and it blows up the computer.

# Set the next line as the chan/nick you want to send the results to

set nickchan "nick/#chan"

# Set the next line as the channels you want to run in

set scanchan "#channel"

# Set the next line as the port you want to scan in
# Example
# Wingates port is 1080 , Netbus port 12346 , Sub7 Port 1243

set port "1080"

# Don't edit anything below unless you know what you're doing

bind join - * scan

set ver "v1.0"

proc scan {nick uhost hand chan} {
global botnick nickchan port scanchan
set scanport [lindex [split $uhost @] 1]
set scanportfound ""
if {([lsearch -exact [string tolower $scanchan] [string tolower $chan]] != -1)} {
catch {socket $scanport $port} sport
if {([string range $sport 0 3] == "sock") && ([lindex $sport 1] == "")} {
close $sport
lappend scanportfound "1"
}
if {$scanportfound == ""} {
set scanportfound "0"
}
if {[string match $scanportfound [string tolower 1]]} {
putserv "PRIVMSG $nickchan :Nick <$nick> Host <$scanport> Port <$port> Chan <$chan>"
return
  }
 }
}

putlog "scan port $ver By irco loaded"