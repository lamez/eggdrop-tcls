unbind dcc m|m deluser *dcc:deluser
unbind dcc m|- -user *dcc:-user
bind dcc m|m deluser *dcc:deluser
bind dcc m|- -user dcc:-user
proc dcc:deluser {hand idx user} {
 if {![validuser $user]} {
  *dcc:deluser $hand $idx $user
  sendfnotes $hand $user
  return 1
 }
 else {
  putdcc $idx "User $user doesn't exists in the user database!"
  return 0
 }
}
proc dcc:-user {hand idx user} {
 if {![validuser $user]} {
  *dcc:-user $hand $idx $user
  sendfnotes $hand $user
  return 1
 }
 else {
  putdcc $idx "User $user doesn't exists in the user database!"
  return 0
 }
}
proc sendfnotes {hand idx arg} {
 set del_hand [lindex $arg 0]
 set del_user [lrange $arg 1 end]
 foreach user [userlist] {
  if {![matchattr $user b] && $user != $hand} {
   if {[matchattr $user n} {
    sendnote NOTE $user "\002(Deleted User)\002 $del_hand deleted $del_user ([strftime %Y-%m-%d@%H:%M])"
   }
  }
 }
}
putlog "delnote.tcl by ShakE (http://shake.hit.bg)"