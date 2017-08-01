## -----------------------------------------------------------------------
##           CYborg ENT.TCL ver 1.0 Disign by Skyone (hendra asianto)                               
## -----------------------------------------------------------------------
## FOR MORE INFORMATION VISIT OUR CHANNEL (bot home #Cyborg) , #PALU AND #GRESIK @DalNet
## my email : hendra_asianto@hotmail.com
## Cyborg ent.tcl V1.0
## by Skyone (hendra asianto)
## 
## All newsheadlines parsed by this script are (C) cyborg`eggdrop`team 
## 
## Cyborg Version History:1 Command      V1.0  - Public command like (botnick) (command) 
##                        2 protection   v1.0  - This script i just made medium protection
##                                              if some one flood color or say bad word or what on channel
##                                              the bot will lock channel for a moment (mode +mi).
##                                              ( i have been tried it on Channel #palu #gresik @Dalnet)                                       
##                        3 entertainment v1.0 - Auto speak and respon :).
##                                        v1.1 - Auto speak when some one change they nickname
##                                        v1.2 - Auto speak when some get kick or join channel.          
## The author takes no responsibility whatsoever for the usage and working of this script !
## 

## ----------------------------------------------------------------
## Set global variables and specificic
## ----------------------------------------------------------------

## -=[ SPEAK ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "#channel1 #channel2"

set speaks_chans "*"
# Set you want in XXX minute you bot always talk on minute 
set speaks_time 8


## -=[ Hello ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "#channel1 #channel2"
set hello_chans "*"

## -=[ BRB ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "#channel1 #channel2"
set brb_chans "*"

## -=[ BYE ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "#channel1 #channel2"
set bye_chans "*"

## -=[ PING ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "#channel1 #channel2"
set ping_chans "*"


## ----------------------------------------------------------------
## --- Don't change anything below here if you don't know how ! ---
## ----------------------------------------------------------------

######################################################################
##--------------------------------------------------------------------
##--- F O R     ---   E N T E R T A I N M E N T  ---    CHANNEL   ----
##--------------------------------------------------------------------
######################################################################         
### SPEAK ###
set spoken.v "Auto talk"
# Set the next lines as the random speaks msgs you want to say
set speaks_msg {
{"Best file compression around: 'DEL *.*' = 100% compression"}
{"If debugging is the process of removing bugs, then programming must be the process of putting them in."}
{"Programmers don't die, they just GOSUB without RETURN."}
{"Programmer - A red-eyed, mumbling mammal capable of conversing with inanimate objects."}
{"Real programmers don't document. 'If it was hard to write, it should be hard to understand.'"}
{"Be nice to your kids. They'll choose your nursing home."}
{"Beauty is in the eye of the beer holder..."}
{"There are 3 kinds of people: those who can count & those who can't."}
{"Why is 'abbreviation' such a long word?"}
{"Don't use a big word where a diminutive one will suffice."}
{"Every morning is the dawn of a new error..."}
{"A flying saucer results when a nudist spills his coffee."}
{"For people who like peace and quiet: a phoneless cord."}
{"I can see clearly now, the brain is gone..."}
{"The beatings will continue until morale improves."}
{"I used up all my sick days, so I'm calling in dead."}
{"Mental Floss prevents Moral Decay."}
{"Madness takes its toll. Please have exact change."}
{"Proofread carefully to see if you any words out."}
{"There cannot be a crisis today; my schedule is already full."}
{"I'd explain it to you, but your brain would explode."}
{"Ever stop to think, and forget to start again?"}
{"A conclusion is simply the place where you got tired of thinking."}
{"I don't have a solution but I admire the problem."}
{"Don't be so open-minded your brains will fall out."}
{"If at first you DO succeed, try not to look astonished!"}
{"Diplomacy is the art of saying 'Nice doggie!'... till you can find a rock."}
{"Diplomacy - the art of letting someone have your way."}
{"If one synchronized swimmer drowns, do the rest have to drown too?"}
{"If things get any worse, I'll have to ask you to stop helping me."}
{"If I want your opinion, I'll ask you to fill out the necessary forms."}
{"Don't look back, they might be gaining on you."}
{"It's not hard to meet expenses, they're everywhere."}
{"Help Wanted: Telepath. You know where to apply."}
{"Look out for #1. Don't step in #2 either."}
{"Budget: A method for going broke methodically."}
{"Car service: If it ain't broke, we'll break it."}
{"Shin: A device for finding furniture in the dark."}
{"Do witches run spell checkers?"}
{"Demons are a Ghouls best Friend."}
{"Copywight 1994 Elmer Fudd. All wights wesewved."}  
{"Dain bramaged."}
{"Department of Redundancy Department"}
{"Headline: Bear takes over Disneyland in Pooh D'Etat!"}
{"What has four legs and an arm? A happy pit bull."}
{"Cannot find REALITY.SYS. Universe halted."}
{"COFFEE.EXE Missing - Insert Cup and Press Any Key"}
{"Buy a Pentium 586/90 so you can reboot faster."}
{"2 + 2 = 5 for extremely large values of 2."}
{"Computers make very fast, very accurate mistakes."}
{"Computers are not intelligent. They only think they are."}
{"My software never has bugs. It just develops random features."}
{"<-------- The information went data way --------"}
{"The Definition of an Upgrade: Take old bugs out, put new ones in."}
{"BREAKFAST.COM Halted...Cereal Port Not Responding"}
{"The name is Baud......, James Baud."}
{"BUFFERS=20 FILES=15 2nd down, 4th quarter, 5 yards to go!"}
{"Access denied--nah nah na nah nah!"}
{"C:\ Bad command or file name! Go stand in the corner."}
{"Bad command. Bad, bad command! Sit! Stay! Staaay.."}
{"Why doesn't DOS ever say 'EXCELLENT command or filename!'"}
{"As a computer, I find your faith in technology amusing."}
{"Southern DOS: Y'all reckon? (Yep/Nope)"}
{"Backups? We don' *NEED* no steenking backups."}
{"E Pluribus Modem"}
{"File not found. Should I fake it? (Y/N)"}
{"Ethernet (n): something used to catch the etherbunny"}
{"A mainframe: The biggest PC peripheral available."}
{"An error? Impossible! My modem is error correcting."}
{"CONGRESS.SYS Corrupted: Re-boot Washington D.C (Y/n)?"}
{"Does fuzzy logic tickle?"}
{"A computer's attention span is as long as it's power cord."}
{"11th commandment - Covet not thy neighbor's Pentium."}
{"24 hours in a day...24 beers in a case...coincidence?"}
{"Disinformation is not as good as datinformation."}
{"Windows: Just another pain in the glass."}
{"SENILE.COM found . . . Out Of Memory . . ."}
{"Who's General Failure & why's he reading my disk?"}
{"Ultimate office automation: networked coffee."} 
{"RAM disk is *not* an installation procedure."}
{"Shell to DOS... Come in DOS, do you copy? Shell to DOS..."}
{"All computers wait at the same speed."}
{"DEFINITION: Computer - A device designed to speed and automate errors."}
{"Press Smash forehead on keyboard to continue....."}
{"Enter any 11-digit prime number to continue..."}
{"ASCII stupid question, get a stupid ANSI!"}
{"E-mail returned to sender -- insufficient voltage."}
{"Help! I'm modeming... and I can't hang up!!!"}
{"All wiyht. Rho sritched mg kegtops awound?"}
{"Error: Keyboard not attached. Press F1 to continue."}
{"'640K ought to be enough for anybody.' - Bill Gates, 1981"}
{"DOS Tip #17: Add DEVICE=FNGRCROS.SYS to CONFIG.SYS"}
{"Hidden DOS secret: add BUGS=OFF to your CONFIG.SYS"}
{"Press any key... no, no, no, NOT THAT ONE!"}
{"Press any key to continue or any other key to quit..."}
{"Excuse me for butting in, but I'm interrupt-driven."}
{"REALITY.SYS corrupted: Reboot universe? (Y/N/Q)"}
{"Sped up my XT; ran it on 220v! Works greO?_~"}
{"Error reading FAT record: Try the SKINNY one? (Y/N)"}
{"Read my chips: No new upgrades!"}
{"Hit any user to continue."}
{"2400 Baud makes you want to get out and push!!"}
{"I hit the CTRL key but I'm still not in control!"}
}

if {![string match "*time_speaks*" [timers]]} {
 timer $speaks_time time_speaks
}

proc time_speaks {} {
 global speaks_msg speaks_chans speaks_time
 if {$speaks_chans == "*"} {
  set speaks_temp [channels]
 } else {
  set speaks_temp $speaks_chans
 }
 foreach chan $speaks_temp {
  set speaks_rmsg [lindex $speaks_msg [rand [llength $speaks_msg]]]
  foreach msgline $speaks_rmsg {
   puthelp "PRIVMSG $chan :[subst $msgline]"
  }
 }
 if {![string match "*time_speaks*" [timers]]} {
  timer $speaks_time time_speaks
 }
}



##  PING PONG ##
set Reponden2.v "Ping Respon"
bind pub - !ping ping_speak 
bind pub - `ping ping_speak
bind pub - .ping ping_speak
  
set ranping {
  ",pong"
  ",kamu ping-in punya anak atau ping-in punya cucu hehe.."
  ",waw masih suka nonton film ping-uin yah kekek...ajak-ajak donk"
  ",Your Not that lagged. Ping Reply :7 second"
  ",waw kamu lagg banget sampai 10 menit 10 second keke.. becanda"
  ",Ping..pong.. ayo kita maen ping pong kamu bisa kan :)"
  ",jangan ping melulu donk gue juga lagg nich bukan kamu aja"
  ",minta ping ni ye.. :) ping aku juga donk :)"
  ",ping...pong"
  ",Your ping reply took 180 seconds"
  ",jangan serius banget ping nya nanti kena kena pong kan bisa brb loh"
  "waduh.. minta ping sampai.. gue lupa menghitung berapa second lagg kamu sorry :P"
  "ehm.. menurut saya lagg kamu ngak begitu lag kali ya.. ;p"
  "Your lagged, but not to bad. Ping Reply:12 ops... salah hitung.."
  "ping-in kamu mau berapa second ping nya. kalau mau 10 anggap aja 10 second :) mudahkan"
  "pinguuin yang ada di gambar pada linux program yah"
  "bosan ni.. elo minta ping melulu sekali2 ke minta yang lain ;p kayak kiss atau apa"
  "anda ngak begitu lag kok cuman 1 second ;p becanda"
  "waw kasihan kamu lagg nya minta ampun sampai 1 menit perline kekek.. "
  "ping pong itu apa sih??"
  ",jangan becanda lah massa kamu pingin kawin lagi kekeke.."
  "bener ni minta ping.."
  "ping-in apa lu ? pingin diriku ato pingin sex?"
  "ping teh naon ? bahan pembuat emping ? ato semacam penyakit kuping?"
  "ping-in apa? cucu ya? cucu dancow? ato cucu milo?"
  ",bener-bener minta ping ni kalau di suruh pilih mau di kiss atau mau minta ping"
  "ketik aja /ctcp yournickname ping"
  "ping sini ping sana, lag sini lag sana, pakailah server vancouver"
  "gimana sih rasanya di ping?"
  "kenapa dengan ping-gang gua? sexy ya hueuheue"
  "PING sendiri donk :P"
  "gimana rasanya di pong? tanpa ping"
  "ada yang pingsan ya?"
  "sini gua ping-in, bayar cepek dulu yah ^_*"
  "ping ping mulu, lagi ngidem ya? ohh udah hamil brapa bulan nich hehehe"
  "[PING reply]: 2 seconds -[hehehe..]-"
  "eh tolong tuh , ada orang minta PING"
  "lu mo pingsan jangan disini!! dipelukanku saja hihihihiihih"
  "di ping itu di apain sih? dibikin pingsan ya? ato di kasih liat pinggang sexy?"
  "ping yang lu maksud apa nih? dedenya pinguin musuh batman? ato semacam olahraga?"
  "ping teh naon ? bahan pembuat emping ? ato semacam penyakit kuping?"
  "ping (boongan) elo adalah 3,123456789 detik, hehehehehe"
  "ping mulu, kebanyakan ping, ntar lumalah jadi LAG lhooooo"
}

proc ping_speak {nick uhost hand chan text} {
 global botnick ping_chans ranping
if {(([lsearch -exact [string tolower $ping_chans] [string tolower $chan]] != -1) || ($ping_chans == "*"))} {
set pings [lindex $ranping [rand [llength $ranping]]]
putserv "PRIVMSG $chan :$nick $pings"
  }
} 

##  hello ##
set Reponden3.v "hello Respon"
bind pub - hello hello_speak 
bind pub - alo hello_speak 
bind pub - hallo hello_speak 
bind pub - hai hello_speak 
bind pub - hi hello_speak 

set ranhello {
  "hello there, nice to meet you"
  "hello how are you ^_^"
  "ramein channel donk saayyyy"
  "halo halo bandung, wakil bos gua orang bandung"
  "Hi too, ohh ur so cutee xP~"
  "halooooooooo"
  "apaaaaaaa , suka yaaaaa"
  "chat in channel please"
  "yes, Hello too, do I know ya ?"
  "alo sayank"
  "Hi there"
  "hello, whats up"
  "oi oi oi oi oi"  
  "Halo juga nich, kamu sapa nich, kok sok kenal banget =P"
  "hello how are you ^_^"
  "Hai bro apa kabarmu, bagaimana dengan kabar keluargamu ?"
  "hey whats up"
  "yeah, yeah hi HI"
  "hello, nice to see yea!"
  "Hi i'm happy today!!"
  "hai hai hai hai juga"
  "apa khbar nich nama kamu siapa"
  "halo juga perkenalkan nama ku sarisha kalau kamu siapa?"
  "asl gua = 24 f jkt, rumah gua di Daan Mogot, tebak yg mana :P"
  "hi ,  =)  , kenalan yukk"
  "asl pls, I like to chat with you in channel"
  "Hi juga, kamu makin kiyut aja dech, gemesssss"
  "alo juga, siapa disitu ?"
  ",konnichiwa (halo dalam bahasa jepang)<== maklum baru belajar :P"
  ",how do you do? i'm happy to meet you"
  ",halo juga saya senang dapat berjumpa dengan anda lagi"
  "it was nice meeting you"
  "menyenakan dapat bertemu dengan anda lagi"
  "how are you today ? are you okay ?"
}

proc hello_speak {nick uhost hand chan text} {
 global botnick hello_chans ranhello
if {(([lsearch -exact [string tolower $hello_chans] [string tolower $chan]] != -1) || ($hello_chans == "*"))} {
set helos [lindex $ranhello [rand [llength $ranhello]]]
putserv "PRIVMSG $chan :$nick $helos"
  }
} 

##  Brb  ##
set Reponden4.v "Brb Respon"
bind pub - brb brb_speak 
set ranbrb {
  "ok"
  "where you going?"
  "me too, smoke time!"
  "when you coming back. miss ya already! ;)"
  "brb mo kemana nich, kok ga ngajak ngajak hehehe"
  ",BRB nya jangan lama lama yah :))"
  "kalo brb ke WC aku ikut, kalo ke kamar juga hehehehhe"
  "u want to brb ? ok darling, but don't be so long ok pls, I need You honey"
  ",Alesan .. paling juga gebetan"
  "brbnya 5 menit aja hehehehehee"
  "ikut brb ahhhhhh"
  ",ape ?? mo kmana lu jang ? TEGA LUH tinggalin gua sendiri ?? co macam apa pulak kau :("
  "brb boleh tapi nicknamenya tetep disini kan ?"
  "ok,  saya tunggu yah.. jangan lama2 kangen nich kekek.."
  "brb mau kemana.. mau beli makanan yah.. ikut donk.."
  "ye.. baru juga elo masuk udah brb payah.. loe..."
}

proc brb_speak {nick uhost hand chan text} {
 global botnick brb_chans ranbrb
if {(([lsearch -exact [string tolower $brb_chans] [string tolower $chan]] != -1) || ($brb_chans == "*"))} {
set brbs [lindex $ranbrb [rand [llength $ranbrb]]]
putserv "PRIVMSG $chan :$nick $brbs"
  }
} 

##  Bye  ##
set Reponden5.v "Bye respon"
bind pub - bye bye_speak 
set ranbye {
  "ati ati dijalan yahh, byeee, kalo jatoh, bangun sendiri yahhh"
  "sampe jumpa besok di waktu dan jam yang sama hihihihi tha tha"
  "thathaaa"
  "nice to meet you today, hope can see you agaiin tomorrow"
  "ati-ati di jalan bro!!"
  "ok see u later fren"
  "kok buru-buru amat tadikan baru datang kok udah mau pergi.."
  "ok deh.. bye.. juga"
  "see u tommorow night"
  "see u tonight"
  "mata ashita (sampai jumpa besok)"
  "sayoonara fren :)"
  "sampai besok sobat"
  "iyah..take care yaahh ^_^"
  "take care fren, nice to meet u :)"
  "good bye.. juga :)"
  "nice to meet you today, hope can see you agaiin tomorrow"
  "makacih ya udah join dan maen disini"
}

proc bye_speak {nick uhost hand chan text} {
 global botnick bye_chans ranbye
if {(([lsearch -exact [string tolower $bye_chans] [string tolower $chan]] != -1) || ($bye_chans == "*"))} {
set byes [lindex $ranbye [rand [llength $ranbye]]]
putserv "PRIVMSG $chan : $nick $byes"
  }
} 


## -----------------------------------------------------------------------
putlog "-=-=   ENTERTAINMENT  PROSES   =-=-=-=-=-"
putlog "Entertainment Channel (auto/respon) Ver 1.0:"
putlog "1.${spoken.v},2.${Reponden2.v},3.${Reponden3.v}"
putlog "4.${Reponden4.v},5.${Reponden5.v}"
putlog "loaded Successfuly..."
##------------------------------------------------------------------------
##                      ***    E N D   OF  ENT1.0.TCL ***
## -----------------------------------------------------------------------