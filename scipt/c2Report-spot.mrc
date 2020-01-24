***********************UNCLASSIFIED*********************
***c2Report-spot.mrc***

/*
reports must have the dialog name in the filename in the format:
c2Report-XXX.mrc
where XXX is the name of the dialog that gets called for the report
*/

;this effectivly regersters the report with the mc2 dialog
ON 1:LOAD: {
  var %repName SPOT Report
  var %repDName spot
  hadd -m repreg %repDName %repName
  echo -s THE %repName is loaded!
}   

ON 1:DIALOG:spot:INIT:*: {
  did -r spot 11
  did -a spot 11 $asctime($gmt,ddd mmm dd HH:nn:ss yyyy)
}

;this creates the layout of the SPOT report dialog
dialog spot {
  title "SPOT Report"
  size %mc2x %mc2y 200 260
  option dbu

  box "Date/Time Report Prepared (in ZULU time)", 10, 10 10 180 20
  edit $fulldate, 11, 12 18 130 10
  button "Refresh",12, 145 18 35 10

  box "Size",20, 10 30 180 30
  edit "",21,12 38 176 20, vsbar, multi, return
  check "",121,2 30 10 10

  box "Activity",30, 10 60 180 30
  edit "",31,12 68 176 20, vsbar, multi, return
  check "",131,2 60 10 10

  box "Location",40, 10 90 180 30
  edit "",41,12 98 176 20, vsbar, multi, return
  check "",141,2 90 10 10

  box "Unit",50, 10 120 180 30
  edit "",51,12 128 176 20, vsbar, multi, return  
  check "",151,2 120 10 10

  box "Time",60, 10 150 180 30
  edit "",61,12 158 176 20, vsbar, multi, return
  check "",161,2 150 10 10

  box "Equipment",65, 10 180 180 30
  edit "",66,12 188 176 20, vsbar, multi, return
  check "",166,2 180 10 10

  box "Amplifying Information",70, 10 210 180 30
  edit "",71,12 218 176 20, vsbar, multi, return
  check "",171,2 210 10 10

  check "Also Send to text file", 80, 100 245 55 10, left
  button "Send",100,165 245 30 10, ok
}

; this catches all sclicks from the "spot" dialog
ON 1:DIALOG:spot:sclick:*:{
  ; this is the "refresh" button to put the new time in the box
  IF ($did == 12) {
    did -r spot 11
    did -a spot 11 $asctime($gmt,ddd mmm dd HH:nn:ss yyyy)
  }

  ; This is the "send" button
  IF ($did == 100) {
    echo -s spot send button depressed

    var %size 12Size: $+ 3 $did(spot,21,1).text
    IF ($did(spot,21).lines > 1) {
      var %amount $did(spot,21).lines
      var %x 2
      while (%x <= %amount) {
        var %size $+(%size,$chr(32),$did(spot,21,%x).text)
        inc %x
      }
    }

    var %activity 12Activity: $+ 3 $did(spot,31).text
    IF ($did(spot,31).lines > 1) {
      var %amount $did(spot,31).lines
      var %x 2
      while (%x <= %amount) {
        var %activity $+(%activity,$chr(32),$did(spot,31,%x).text)
        inc %x
      }
    }

    var %location 12Location: $+ 3 $did(spot,41).text
    IF ($did(spot,41).lines > 1) {
      var %amount $did(spot,41).lines
      var %x 2
      while (%x <= %amount) {
        var %location $+(%location,$chr(32),$did(spot,41,%x).text)
        inc %x
      }
    }

    var %unit 12Unit: $+ 3 $did(spot,51).text
    IF ($did(spot,51).lines > 1) {
      var %amount $did(spot,51).lines
      var %x 2
      while (%x <= %amount) {
        var %unit $+(%unit,$chr(32),$did(spot,51,%x).text)
        inc %x
      }
    }

    var %times 12Time: $+ 3 $did(spot,61).text
    IF ($did(spot,61).lines > 1) {
      var %amount $did(spot,61).lines
      var %x 2
      while (%x <= %amount) {
        var %times $+(%times,$chr(32),$did(spot,61,%x).text)
        inc %x
      }
    }

    var %equips 12Equipment: $+ 3 $did(spot,66).text
    IF ($did(spot,66).lines > 1) {
      var %amount $did(spot,66).lines
      var %x 2
      while (%x <= %amount) {
        var %equips $+(%equips,$chr(32),$did(spot,66,%x).text)
        inc %x
      }
    }

    var %amp 12Amplifying info: $+ 3 $did(spot,71).text
    IF ($did(spot,71).lines > 1) {
      var %amount $did(spot,71).lines
      var %x 2
      while (%x <= %amount) {
        var %amp $+(%amp,$chr(32),$did(spot,71,%x).text)
        inc %x
      }
    }

    ; returns total number of checked channels
    var %numChan $did(mc2,34,0).csel 
    echo -s %numChan channels
    var %x 1
    set %rep.Time $timestamp
    
    	
    ; sends the report out to each channel
    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aroom $did(mc2,34,%place).text
      var %rep.Channels $+(%aroom,$chr(32),%rep.Channels)
      describe %aroom 4 mIRC_C2: SPOT Report from $me prepared: $did(spot,11).text
      msg %aroom %size
      msg %aroom %activity
      msg %aroom %location
      msg %aroom %unit
      msg %aroom %times
      msg %aroom %equips
      msg %aroom %amp
      inc %x
    }

    ; get the total number of checked names/nicks
    var %numNick $did(mc2,32,0).csel
    echo -s %numNick nicks
    var %x 1

    ;  sends the report to all the nicks
    while (%x <= %numNick) {
      var %place $did(mc2,32,%x).csel
      var %aGuy $did(mc2,32,%place).text
      describe %aGuy 4 mIRC_C2: SPOT Report from $me prepared: $did(spot,11).text
      msg %aGuy %size
      msg %aGuy %activity
      msg %aGuy %location
      msg %aGuy %unit
      msg %aGuy %times
      msg %aGuy %equips
      msg %aGuy %amp
      inc %x
    }

    ; if the box is checked - write the report to a file and open it
    IF ($did(spot,80).state == 1) {
      ; testing to try and write the report to a file and open it
      ; make the unique filename
      var %repFileName $+($asctime($gmt,yymmdd-HHnns),-SPOT-,$me,.doc)

      var %header ****SPOT Report from $me prepared: $did(spot,11).text
      ; create a file
      fopen -o repName %repFileName
      ; writes the text to the file
      fwrite -n repName $strip($+(%header,$crlf,%size,$crlf,%activity,$crlf,%location,$crlf,%unit,$crlf,%times,$crlf,%equips,$crlf,%amp))
      fclose repName
      run %repFileName
    }    
    var %rep.Type SPOT
    var %rep.Sender $me
    ; %rep.Channels and %rep.Time will be defined above as the channels are getting the report

    listerS %rep.Time %rep.Type %rep.Sender %rep.Channels 
    echo -s sent to listerS: %repFileName %rep.Channels %rep.Time %rep.Type %rep.Sender %rep.Channels 
  }
}

ON 1:DIALOG:spot:INIT:*: {
  did -c spot 121
  did -c spot 131
  did -c spot 141
  did -c spot 151
  did -c spot 161
  did -c spot 166
  did -c spot 171
}

