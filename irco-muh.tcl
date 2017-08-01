# muh v1.0 (23 April 2001) By irco <irco@mail.com> EFnet #Q8Help
# you can make your bots joined to muh server
# Notes: I wrote this on eggdrop 1.3.x, don't complain if you load it up
# on your prehistoric 1.1.5 and it blows up the computer.

# Set this for the muh Hostname or IP and Port and Password

set servers "hostname:port:password"

# Don't edit anything below unless you know what you're doing

bind raw - 465 muh

set ver "v1.0"

proc muh {from keyword arg} {
global servers
putserv "CONN $servers"
}

putlog "Muh $ver By irco loaded ..."