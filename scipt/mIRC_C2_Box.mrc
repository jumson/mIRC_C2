***********************UNCLASSIFIED*********************
***mIRC_C2_Box.mrc***
/*
mIRC C2 Box v1.0
1. Integrates the mIRC mc2 and the flashbox concept

Future feature list:
1. include alerts (visual and audio)
2. create text files that can be emailed seperately
3. create KML files based on MGRS (or Lat/Long) grids
(need seperate method to convert MGRS to Lat/Long used by google earth-- may not be possible)
4. send files thru email server (if the IMAP servers are set up for it / or interact w/outlook)
5. track received "reports" that are sent with this system - queue them up and be able to read them in a box - and export them to a file
6. convert into a server/client model with a C2 message traffic director style system
7. allow for reports to be tracked, and saved to be updated with different formats
*/

/*
mIRC C2 Box v1.1
**Added features
1. checkbox next to report send button which puts the report into a textfile too
2. made it so the reports load up next to the C2 box, not on top of it. wherever it may be.
**fixed stuff
1. fixed the initial loading error that requested the user to pick a file
2. fixed the actions on JOIN and PART so that it only works when the dialog is actually loaded
3. fixed the combo button loading the reports (was related to #1)
*/

; this is supossed to add the option to add a nick to the nicklist in the dialog
Menu nicklist {
  Send to C2 Interface: /echo -s $1 sent to C2 interface | /c2sender $1
}

; this function takes the input and sends it to the screen as an alert. one line only.
alias alerts {
  var %alertNum $+(alert,$rand(1111,9999))
  .comopen %alertNum WScript.Shell
  !.echo -q $com(%alertNum, Popup, 3, bstr, $1-)
  !.echo -q $com(%alertNum, echo, 7, bstr, $chr(7))
  .comclose %alertNum
}

alias listerS {
  echo -s a report was sent to listerS
  did -af mc2 63 $+($1,---,$2,---,$3,---,$4-)
}

alias listerR {
  echo -s a report was grabbed!
  var %spaces $+($chr(32),$chr(32),$chr(32))
  echo -s $+($3,$chr(32),from:,$2,$chr(32),in:,$1,$chr(32), at:,$4-)
  did -af mc2 64 $+($3,$chr(32),from:,$2,$chr(32),in:,$1,$chr(32), at:,$4-)
  var %repType $3
  IF (%repType == CLEAR) {
    IF ($hget(alertOPTs,clear.vis) == 1) {
      alerts $+($3,$chr(32),from:,$2,$chr(32),in:,$1,$chr(32), at:,$4-)
    }
  }
  IF (%repType == 5Ws) {
    IF ($hget(alertOPTs,5ws.vis) == 1) {
      alerts $+($3,$chr(32),from:,$2,$chr(32),in:,$1,$chr(32), at:,$4-)
    }
  }
  IF (%repType == 9line) {
    IF ($hget(alertOPTs,9line.vis) == 1) {
      alerts $+($3,$chr(32),from:,$2,$chr(32),in:,$1,$chr(32), at:,$4-)
    }
  }
  IF (%repType == SPOT) {
    IF ($hget(alertOPTs,spot.vis) == 1) {
      alerts $+($3,$chr(32),from:,$2,$chr(32),in:,$1,$chr(32), at:,$4-)
    }
  }
}

alias repParser {
  var %lineH $1-
  ; grab the report type
  var %repS 13
  var %repE $pos(%lineH,Report)
  var %repL %repE - %repS
  set %DrepType $mid(%lineH,%repS,%repL)
  echo -s %DrepType 

  ; grab the report time
  var %repTs $pos(%lineH,prepared)
  echo -s pre add %repTs
  var %repTs %repTs + 9
  echo -s post add %repTs
  var %repTl $len(%lineH) - %repTs
  echo -s repTln %repTl
  var %repT $right(%lineH,%repTl)
  echo -s the time %repT

  listerR $chan $nick %DrepType %repT

  ; create a fileName to save the report

}
menu * {
  mIRC C2 Box:/F4
}

; for testing /debug
alias F7 {
  echo -s this will give the location and dimensions of the mc2 dialog
  echo x: $dialog(mc2).x
  echo y: $dialog(mc2).y
  echo w: $dialog(mc2).w
  echo h: $dialog(mc2).h
}

alias refreshChannels {
  did -r mc2 34
  var %numchan $chan(0)
  var %x 1
  while (%x <= %numchan) {
    did -a mc2 34 $chan(%x)
    inc %x
  }
}

alias c2sender {
  echo -a 4 this went to he c2sender: $1
  did -a mc2 32 $1
}

alias F4 {
  set %tt $replace($mircexe, mirc.exe, ) 
  set %ttc $mircdir
  echo -s %tt
  echo -s %ttc
  dialog -mdo mc2 mc2
}

alias saveUsers {
  ; this establishes what file we are talking about -- either makes a new one, or selects an old one - and sets it into the %defaultHandleFile variable
  echo 8make a new file?
  var %nothing $?!="YES to make a new default file. $crlf NO to use an old one"
  IF ($!) {
    var %defaultFileName $$?="Name your new default file (will save to ttc)"
    set %defaultHandleFile %ttc $+ %defaultFileName $+ .ini
    IF (!%defaultFileName) {
      echo 3 halting
      halt
    }
  }
  else {
    $msfile(%ttc)
    set %defaultHandleFile $msfile(1)
    if (!%defaultHandleFile) {
      echo 3 halting
      halt
    } 
  }

  ; if the old hash was left open, free it first, them make it fresh, this prevents a stopping error
  if ($hget(handleHash, 0).item) {
    hfree handleHash -s
  }
  hmake -s handleHash 50

  ; puts the list into the hash ( hadd -m will create the hash if not made for some reason)
  var %listLen $did(mc2,32).lines 
  ; gets the amount of names to add
  var %x 1
  echo 10 there are %listLen lines in this list - starting with %x
  ; iterates over the list and adds them to the hash
  while (%x <= %listLen) {
    echo 10 %x
    var %tempData $did(mc2,32,%x).text
    echo 5 %tempData
    hadd -m handleHash %x %tempData
    inc %x
  }

  ; saves the hash to the file (-o overwrites, -i makes it an ini format) and frees the hash
  echo 9 $hget(handleHash, 0)
  hsave -io handleHash %defaultHandleFile
  echo 8saved to %defaultHandleFile
  hfree handleHash -s
  echo 5 hash freed
}

alias loadUsers {

  ; this bypasses file selection if given the start argument - and if a file is already set, it uses it
  IF ($1 == start) { 
    IF (%defaultHandleFile) {
      goto loadUP
    }
    ELSE {
      halt
    }
  }

  echo 8select the default file
  ; the user either selects an old file, or creates a new one -- %nothing is used because i think it prevents a non halting error message
  var %nothing $?!="YES if you can find your default file. $crlf NO to create a new one"
  IF ($!) {
    $msfile(%ttc)
    set %defaultHandleFile $msfile(1)
    IF (!%defaultHandleFile) {
      halt
    }
  }
  else {
    var %defaultFileName $$?="Name your new default file (will save to d)"
    set %defaultHandleFile %ttc $+ %defaultFileName $+ .ini
    IF (!%defaultFileName) {
      halt
    }  
  }

  :loadUP

  ; if the old hash was left open, free it first, them make it fresh - prevents a stopping error
  IF ($hget(handleHash, 0).item) {
    hfree handleHash -s
  }
  hmake -s handleHash 50

  ; loads the file into the hash and clears the list
  hload -i handleHash %defaultHandleFile
  did -r mc2 32

  ; iterates over the hash and adds them to the list
  var %listLen $hget(handleHash, 0).item
  var %x 1
  while (%x <= %listLen) {
    var %theItem $hget(handleHash, %x).data
    did -a mc2 32 %theItem
    inc %x
  }     

  ; frees the hash from memory
  hfree handleHash -s
}

;this creates all the sizing and spacing variables adjusted relative to base_ and size_ defaults
ON 1:START: {

  set %tab60_x %base_x + 1
  set %tab60_y %base_y + 1
  set %tab60_width %base_width - 1
  set %tab60_height %base_height - 1
  set %list63_x %tab60_x + 1
  set %list63_y %tab60_y + 30
  set %list63_width %base_width - 200
  set %list63_height %base_height - 200
  set %button_65_x %base_width - 40
  set %button_65_y %base_height - 35
}

; this creates the layout of the mIRC C2 Box
dialog mc2 {
  title "mIRC C2 Box v1.2"
  size %base_x %base_y %base_width %base_height
  option dbu

  ; tabs
  tab "Main",60,%tab60_x %tab60_y %tab60_width %tab60_height
  tab "Sent Reports", 61
  list 63, %list63_x %list63_y %list63_width %list63_height, autohs tab 61
  button "Remove",65, %button_65_x %button_65_y 40 10, tab 61
  tab "Rec'd Reports", 62
  list 64, 0 14 180 125, hsbar tab 62
  button "Remove",67,145 130 30 10, tab 62

  menu "&UserNames",10
  item "&Save Defaults",11, 10
  item "&Load Defaults",12, 10

  menu "&Channels",20
  item "&Create Random Flash event channel",21,20
  item "&Create Custom Flash event channel",22,20

  menu "&Alerts",70
  item "&Set Report channel alerts", 71, 70

  box "Nicks/Users",30,0 14 80 52, tab 60 
  edit "[Add IRC Handle]",31,2 22 76 11, tab 60
  list 32,2 34 76 33, check tab 60

  box "Channels",33,81 14 98 52, tab 60
  list 34,83 22 94 42, check tab 60  

  button "Add",35,2 67 35 10, tab 60
  button "Delete",36,39 67 35 10, tab 60
  button "Set Topic",37,130 67 45 10, tab 60
  button "Invite",46,83 67 45 10, tab 60

  text "Channel Interface",42,0 78 179 33, tab 60
  button "kick",41,2 88 35 10, tab 60
  button "ban",40,2 100 35 10, tab 60
  button "OP",39,39 88 35 10, tab 60
  button "unban",38,39 100 35 10, tab 60

  combo 43,83 88 94 10, drop, tab 60
  button "Create Report",44,83 100 94 10, tab 60

  box "Information Box",45,0 112 178 32, tab 60
  text "Welcome to the mIRC C2 Box v1.0!",24,2 120 170 20, tab 60

}

; this catches all the "mouseOver" events from the "mc2" dialog
; mostly this part is what fills in the "info box" at the bottom.
ON 1:DIALOG:mc2:mouse:*: {
  IF (%lastM == $null) {
    set %lastM 0
  }

  ; this is the "Add IRC Handle" edit box
  IF ($did == 30) {
    IF (%lastM != $did) {
      set %lastM $did
      did -r mc2 24
      did -a mc2 24 type or paste someones nick / username here to add it. The nick(s) that is(are) checked will be actioned upon using the delete button or the channel interface buttons
    }
  }

  ; this is the "channel box" or Channel list
  IF ($did == 33 || $did == 34) {
    IF (%lastM != $did) {
      set %lastM $did
      did -r mc2 24
      did -a mc2 24 The selected channels will receive the report or be the place where other channel interface buttons have an effect.   
    }
  }

  ; this is the "Add" button
  IF ($did == 35) {
    IF (%lastM != $did) {
      set %lastM $did
      did -r mc2 24
      did -a mc2 24 Add the username / Nick to the list        
    }
  }

  ; this is the Delete button
  IF ($did == 36) {
    IF (%lastM != $did) {
      set %lastM $did
      did -r mc2 24
      did -a mc2 24 Deletes the currently selected nick(s) or username(s) from the list 
    }
  }

  ; this is the "invite" button
  IF ($did == 46) {
    IF (%lastM != $did) {
      set %lastM $did
      did -r mc2 24
      did -a mc2 24 Invite the checked Nicks/Users to the checked Channels        
    }
  }

  ; this is the "refresh" button
  IF ($did == 37) {
    IF (%lastM != $did) {
      set %lastM $did
      did -r mc2 24
      did -a mc2 24 Refresh the channel list - will list all your open channels        
    }
  }

  ; this is the "channel interface" box
  IF ($did == 42) {
    IF (%lastM != $did) {
      set %lastM $did
      did -r mc2 24
      did -a mc2 24 Choose and create a report to send to the checked Nicks/Users and channels; You need OP authority in a channel to Kick, Ban, Unban or make someone an OP. Kicking doesn't prevent someone from re-joining.
    }
  }

  ; this is the "Info Box"
  IF ($did == 45) {
    IF (%lastM != $did) {
      set %lastM $did
      did -r mc2 24
      did -a mc2 24 Welcome to the mIRC C2 Box v1.0! Welcome to the mIRC C2 Box v1.0!      
    }
  }
}

; this is all menu items that may be selected
ON 1:DIALOG:mc2:menu:*:{

  ; the menu button "Save Defaults"
  IF ($did == 11) {
    saveUsers
  }

  ; the menu button "Load Defaults"
  IF ($did == 12) {
    loadUsers
  }

  ; the menu button "Create Random Flash event channel"
  IF ($did == 21) {
    echo -s Create Random Flash event channel
    var %evelyn $rand(123,789) 
    ; stores a random three digit number between 123 and 789
    var %estelle = #Flash_Event $+ %evelyn
    join %estelle
    mode %estelle +i
  }

  ; the menu button "Create Custom Flash event channel"
  IF ($did == 22) {
    var %estelle $$?="What would you like to call the Channel? (start it with #)"
    join %estelle
    mode %estelle +i
  }

  ; the set alerts menu button
  IF ($did == 71) {
    set %mc2x $dialog(mc2).x + $dialog(mc2).w
    set %mc2y $dialog(mc2).y

    dialog -mdo alertOps alertOps
  }


}

; this catches all sclicks from the "mc2" dialog
ON 1:DIALOG:mc2:sclick:*:{

  ; button "Remove",65 - in the sent tab - for list 63
  IF ($did == 65) {
    var %lineSel $did(mc2,63,1).sel
    did -d mc2 63 %lineSel
  }

  ; button "Remove",67 - in the sent tab - for list 64
  IF ($did == 67) {
    var %lineSel $did(mc2,64,1).sel
    did -d mc2 64 %lineSel
  }

  ; sent reports tab
  IF ($did == 61) {
    echo -s sent tab clicked

  }

  ; main tab
  IF ($did == 60) {
    echo -s main tab clicked

  }

  ; rec'd reports tab
  IF ($did == 62) {
    echo -s rec'd reports tab clicked

  }



  ; this is the "Add" button
  IF ($did == 35) {
    did -af mc2 32  $$did(31)
    did -r mc2 31
    did -a mc2 31 [Add IRC Handle]
  }

  ; this is the "Delete" button
  IF ($did == 36) {
    while ($did(mc2,32,1).csel != 0) {
      did -d mc2 32 $did(mc2,32,1).csel
    }
  }

  ; this is the "set topic" button
  IF ($did == 37) {
    echo -s Change chosen channel topic
    ; returns total number of checked channel lines
    var %numChan $did(mc2,34,0).csel 
    echo -s %numChan channels
    var %x 1

    ; changes the topic in each channel selected
    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aRoom $did(mc2,34,%place).text
      topic %aRoom $$?="What is the topic for %aRoom ?"
      inc %x
    }
  }


  ; this is what happens when the "Create Report" button is clicked
  IF ($did == 44) {
    set %mc2x $dialog(mc2).x + $dialog(mc2).w
    set %mc2y $dialog(mc2).y

    ; here we use %numReps to be the amount of reports that exist
    ; and the array %reports.X to be the dialog names (all of which are set on initialization of the mc2 dialog)
    var %x 1
    echo -s numReps = %numReps
    echo -s selection = $did(mc2,43).sel
    while (%x <= %numReps) {
      IF ($did(mc2,43).sel == %x) {
        var %ddlog %reports. [ $+ [ %x ] ]
        dialog -mdo %ddlog %ddlog
      }
      inc %x
    }
  }

  ; the kick button
  IF ($did == 41) {
    ; returns total number of checked channels and nicks
    var %numChan $did(mc2,34,0).csel 
    var %numNick $did(mc2,32,0).csel
    var %x 1
    var %y 1
    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aroom $did(mc2,34,%place).text
      while (%y <= %numNick) {
        var %place2 $did(mc2,32,%y).csel
        var %aGuy $did(mc2,32,%place2).text
        kick %aroom %aGuy
        inc %y
      }
      var %y 1
      inc %x
    }
  }

  ; the OP button
  IF ($did == 39) {
    ; returns total number of checked channels and nicks
    var %numChan $did(mc2,34,0).csel 
    var %numNick $did(mc2,32,0).csel
    var %x 1
    var %y 1
    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aroom $did(mc2,34,%place).text
      while (%y <= %numNick) {
        var %place2 $did(mc2,32,%y).csel
        var %aGuy $did(mc2,32,%place2).text
        mode %aroom +o %aGuy
        inc %y
      }
      var %y 1
      inc %x
    }
  }

  ; the ban button
  IF ($did == 40) {
    ; returns total number of checked channels and nicks
    var %numChan $did(mc2,34,0).csel 
    var %numNick $did(mc2,32,0).csel
    var %x 1
    var %y 1
    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aroom $did(mc2,34,%place).text
      while (%y <= %numNick) {
        var %place2 $did(mc2,32,%y).csel
        var %aGuy $did(mc2,32,%place2).text
        mode %aroom +b %aGuy
        inc %y
      }
      var %y 1
      inc %x
    }
  }

  ; the unban button
  IF ($did == 38) {
    ; returns total number of checked channels and nicks
    var %numChan $did(mc2,34,0).csel 
    var %numNick $did(mc2,32,0).csel
    var %x 1
    var %y 1
    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aroom $did(mc2,34,%place).text
      while (%y <= %numNick) {
        var %place2 $did(mc2,32,%y).csel
        var %aGuy $did(mc2,32,%place2).text
        mode %aroom -b %aGuy
        inc %y
      }
      var %y 1
      inc %x
    }
  }

  ; the invite button
  IF ($did == 46) {
    ; returns total number of checked channels and nicks
    var %numChan $did(mc2,34,0).csel 
    var %numNick $did(mc2,32,0).csel
    var %x 1
    var %y 1
    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aroom $did(mc2,34,%place).text
      while (%y <= %numNick) {
        var %place2 $did(mc2,32,%y).csel
        var %aGuy $did(mc2,32,%place2).text
        invite %aGuy %aroom
        inc %y
      }
      var %y 1
      inc %x
    }
  }

}

; this is for doubleclicks in mc2
ON 1:DIALOG:mc2:dclick:*:{

  ;if a sent report is doubleclicked
  IF ($did == 63) {
    echo -s $did(mc2,63).seltext
    /*
    var %fileSel $did(mc2,63).seltext
    var %startF $pos(%fileSel,:)
    var %endF $pos(%fileSel,.)   
    var %lenF %endF - %startF
    var %startF %startF + 1
    var %fileName $mid(%fileSel,%startF,%lenF)
    var %fileName $+(%fileName,doc)
    var %fullFile $+($mircdir,reports\,%fileName)
    run %fullFile
    */
  }
  ;if a recieved report is doubleclicked
  IF ($did == 64) {
    echo -s $did(mc2,64).seltext
    /*
    var %lineH $did(mc2,64).seltext
    var %atc $+(at,$chr(58))
    var %roomS $pos(%lineH,$chr(35))
    var %roomE $pos(%lineH,%atc)
    var %roomL %roomE - %roomS
    var %room $mid(%lineH,%roomS,%roomL)
    echo -s report from room:   %room
    window -aC %room
    echo -s $len(%room)
    ; echo -s the report starts on line: $fline(%room,*CLEAR*,2)
    */

  }

}

alias loadReports {
  echo -s Loaded scripts: $script(0)
  var %x 1
  set %numReps 0
  while (%x <= $script(0)) {
    var %scripts $script(%x)
    if ($pos(%scripts,c2Report,0)) {
      var %poss1 $pos(%scripts,c2Report)
      var %poss2 $pos(%scripts,.mrc)
      inc %poss1 9
      var %poss2 %poss2 - %poss1
      var %report $mid(%scripts,%poss1,%poss2)
      echo -s %report    
      echo the nice name of the report is $hget(repreg,%report)
      did -a mc2 43 $hget(repreg,%report)
      inc %numReps
      echo -s numReps = %numReps
      set %reports. [ $+ [ %numReps ] ] %report
    }
    inc %x
  }
}

; this happens when the mc2 dialog is opened
ON 1:DIALOG:mc2:INIT:*: {
  echo -s initiated
  refreshChannels
  loadReports
  did -c mc2 43 1
  loadUsers start
}

ON 1:DIALOG:mc2:CLOSE:*: {
  echo -s mc2 closed
}


; this happens when the a channel is closed
ON 1:CLOSE:*: {
  IF ($dialog(mc2) == mc2) {
    echo -s closed window!
    timer1 1 1 refreshChannels
  }
}

; this happens when a channel opens
ON 1:JOIN:*: {
  IF ($nick == $me) {
    IF ($dialog(mc2) == mc2) {
      refreshChannels
    }
  }
}

ON 1:ACTION:*mIRC_C2*:*: {

  echo -s mIRC C2 was triggered from $nick on channel $chan
  ; alerts You have a report from $nick on channel $chan
  repParser $1-
}

dialog alertOps {

  title "Report Alert Options"
  size %mc2x %mc2y 100 100
  option dbu
  
  text "Visual Alert",10,50 0 50 10

  text "5Ws Report",20,5 12 40 10
  check "",21,52 10 10 10
  ; check "",22,72 10 10 10

  text "9Line Report",30,5 24 40 10
  check "",31,52 22 10 10
  ; check "",32,72 22 10 10

  text "SPOT Report",40,5 36 40 10
  check "",41,52 34 10 10
  ; check "",42,72 34 10 10

  text "CLEAR Report",50,5 48 40 10
  check "",51,52 46 10 10
  ; check "",52,72 46 10 10

  button "Close",60,50 58 30 10,ok

}

ON 1:DIALOG:alertOps:sclick:*: {
  IF ($did == 60) {
    hadd -m alertOPTs 5ws.vis $did(alertOps,21).state
    ; hadd -m alertOPTs 5ws.aud $did(alertOps,22).state
    hadd -m alertOPTs 9line.vis $did(alertOps,31).state
    ; hadd -m alertOPTs 9line.aud $did(alertOps,32).state
    hadd -m alertOPTs spot.vis $did(alertOps,41).state
    ; hadd -m alertOPTs spot.aud $did(alertOps,42).state
    hadd -m alertOPTs clear.vis $did(alertOps,51).state
    ; hadd -m alertOPTs clear.aud $did(alertOps,52).state
    hsave alertOPTs alertOPTs.txt 
  }
}

ON 1:DIALOG:alertOps:INIT:*: {
  IF ($hget(alertOPTs, 0).item) {
    hfree -s alertOPTs
  }
  hmake -s alertOPTs 5
  hload -s alertOPTs alertOPTs.txt

  IF ($hget(alertOPTs,5ws.vis) == 1) {
    did -c alertOps 21
  }
  IF ($hget(alertOPTs,5ws.aud) == 1) {
    did -c alertOps 22
  }
  IF ($hget(alertOPTs,9line.vis) == 1) {
    did -c alertOps 31
  }
  IF ($hget(alertOPTs,9line.aud) == 1) {
    did -c alertOps 32
  }
  IF ($hget(alertOPTs,spot.vis) == 1) {
    did -c alertOps 41
  }
  IF ($hget(alertOPTs,spot.aud) == 1) {
    did -c alertOps 42
  }
  IF ($hget(alertOPTs,clear.vis) == 1) {
    did -c alertOps 51
  }
  IF ($hget(alertOPTs,clear.aud) == 1) {
    did -c alertOps 52
  }

}
