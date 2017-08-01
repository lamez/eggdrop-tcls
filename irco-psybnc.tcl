# psybnc v1.0 (23 April 2001) By irco <irco@mail.com> EFnet #Q8Help
# you can make your bots joined to psybnc server
# Notes: I wrote this on eggdrop 1.3.x, don't complain if you load it up
# on your prehistoric 1.1.5 and it blows up the computer.

# Set this for the psybnc HOSTNAME or IP
set servers host:port

# Your psybnc password
set psybnc_pass "password"

# Don't edit anything below unless you know what you're doing

bind notc - "Your IRC Client did not support a password. Please type /QUOTE PASS yourpassword to connect." psybnc

set ver "v1.0"

proc psybnc {nick uhost hand arg}  {
 global psybnc_pass
 putserv "PASS $psybnc_pass"
}

putlog "PsyBnc $ver By irco loaded ..."