***********************UNCLASSIFIED*********************
***c2Report-9line.mrc***

/*
reports must have the dialog name in the filename in the format:
c2Report-XXX.mrc
where XXX is the name of the dialog that gets called for the report
*/

;this effectivly regersters the report with the mc2 dialog
ON 1:LOAD: {
  var %repName 9-Line MEDEVAC
  var %repDName 9line
  hadd -m repreg %repDName %repName  
  echo -s THE %repName is loaded!
}   

ON 1:DIALOG:9line:INIT:*: {
  did -r 9line 11
  did -a 9line 11 $asctime($gmt,ddd mmm dd HH:nn:ss yyyy)
}

;this creates the layout of the 9-line MEDEVAC report dialog
dialog 9line {
  title "9 Line MEDEVAC Report"
  size %mc2x %mc2y 200 270
  option dbu

  box "Date/Time Report Prepared (in ZULU time)", 10, 10 10 180 20
  edit $fulldate, 11, 12 18 130 10
  button "Refresh",12, 145 18 35 10

  box "Line 1:",20, 10 30 88 20
  edit "Location of Pick-up",21,12 38 84 10, vsbar, multi, return

  box "Line 2",30, 100 30 88 20
  edit "Call Sign / Freq",31,102 38 84 10, vsbar, multi, return

  box "Line 3",40, 10 50 180 30
  edit "Number of Patience by type: A-Urgent, B-Urgent Surgery, C-Priority, D-Routine, E-Convenience",41,12 58 176 20, vsbar, multi, return

  box "Line 4",50, 10 80 180 20
  edit "Special Equipment Required",51,12 88 176 10, vsbar, multi, return  

  box "Line 5",60, 10 100 180 30
  edit "Number of Patients by type (Litter / Ambulatory)",61,12 108 176 20, vsbar, multi, return

  box "Line 6",80, 10 130 180 20
  edit "Security situation of pick-up site",81,12 138 176 10, vsbar, multi, return

  box "Line 7",82, 10 150 180 30
  edit "Method of Marking: A-Panels, B-Pyrotechnic Signal, C-Smoke Signal, D-None",83,12 158 176 20, vsbar, multi, return

  box "Line 8",84, 10 180 180 30
  edit "Patient Nationality and Status: A-US MIL, B-US CIV, C-Non-US MIL, D-Non-US CIV, E-ENY Prisoner of War",85,12 188 176 20, vsbar, multi, return

  box "Line 9",86, 10 210 180 20
  edit "Terrain Description / Obstacles on the HLZ, or NBC status: N-Nuclear, B-Biological, C-Chemical",87,12 218 176 10, vsbar, multi, return

  box "Amplifying Information",70, 10 230 180 30
  edit "",71,12 238 176 20, vsbar, multi, return

  check "Also Send to text file", 90, 100 260 55 10, left  
  button "Send",100,165 260 30 10, ok
}

; this catches all sclicks from the "9line" dialog
ON 1:DIALOG:9line:sclick:*: {
  ; this is the "refresh" button to put the new time in the box
  IF ($did == 12) {
    did -r 9line 11
    did -a 9line 11 $asctime($gmt,ddd mmm dd HH:nn:ss yyyy)
  }

  ; This is the "send" button
  IF ($did == 100) {
    echo -s 9line send button depressed

    var %line1 12Line 1: $+ 3 $did(9line,21,1).text
    IF ($did(9line,21).lines > 1) {
      var %amount $did(9line,21).lines
      var %x 2
      while (%x <= %amount) {
        var %line1 $+(%line1,$chr(32),$did(9line,21,%x).text)
        inc %x
      }
    }

    var %line2 12Line 2: $+ 3 $did(9line,31).text
    IF ($did(9line,31).lines > 1) {
      var %amount $did(9line,31).lines
      var %x 2
      while (%x <= %amount) {
        var %line2 $+(%line2,$chr(32),$did(9line,31,%x).text)
        inc %x
      }
    }

    var %line3 12Line 3: $+ 3 $did(9line,41).text
    IF ($did(9line,41).lines > 1) {
      var %amount $did(9line,41).lines
      var %x 2
      while (%x <= %amount) {
        var %line3 $+(%line3,$chr(32),$did(9line,41,%x).text)
        inc %x
      }
    }

    var %line4 12Line 4: $+ 3 $did(9line,51).text
    IF ($did(9line,51).lines > 1) {
      var %amount $did(9line,51).lines
      var %x 2
      while (%x <= %amount) {
        var %line4 $+(%line4,$chr(32),$did(9line,51,%x).text)
        inc %x
      }
    }

    var %line5 12Line 5: $+ 3 $did(9line,61).text
    IF ($did(9line,61).lines > 1) {
      var %amount $did(9line,61).lines
      var %x 2
      while (%x <= %amount) {
        var %line5 $+(%line5,$chr(32),$did(9line,61,%x).text)
        inc %x
      }
    }
    	
    var %line6 12Line 6: $+ 3 $did(9line,81).text
    IF ($did(9line,81).lines > 1) {
      var %amount $did(9line,81).lines
      var %x 2
      while (%x <= %amount) {
        var %line6 $+(%line6,$chr(32),$did(9line,81,%x).text)
        inc %x
      }
    }
    	
    var %line7 12Line 7: $+ 3 $did(9line,83).text
    IF ($did(9line,83).lines > 1) {
      var %amount $did(9line,83).lines
      var %x 2
      while (%x <= %amount) {
        var %line7 $+(%line7,$chr(32),$did(9line,83,%x).text)
        inc %x
      }
    }

    var %line8 12Line 8: $+ 3 $did(9line,85).text
    IF ($did(9line,85).lines > 1) {
      var %amount $did(9line,85).lines
      var %x 2
      while (%x <= %amount) {
        var %line8 $+(%line8,$chr(32),$did(9line,85,%x).text)
        inc %x
      }
    }

    var %line9 12Line 9: $+ 3 $did(9line,87).text
    IF ($did(9line,87).lines > 1) {
      var %amount $did(9line,87).lines
      var %x 2
      while (%x <= %amount) {
        var %line9 $+(%line9,$chr(32),$did(9line,87,%x).text)
        inc %x
      }
    }

    var %amp 12Amplifying info: $+ 3 $did(9line,71).text
    IF ($did(9line,71).lines > 1) {
      var %amount $did(9line,71).lines
      var %x 2
      while (%x <= %amount) {
        var %amp $+(%amp,$chr(32),$did(9line,71,%x).text)
        inc %x
      }
    }

    ; returns total number of checked channel lines
    var %numChan $did(mc2,34,0).csel 
    echo -s %numChan channels
    var %x 1
    set %rep.Time $timestamp
    	
    ; sends the report out to each channel
    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aRoom $did(mc2,34,%place).text
      var %rep.Channels $+(%aRoom,$chr(32),%rep.Channels)
      describe %aRoom 4 mIRC_C2: 9line Report from $me prepared: $did(9line,11).text
      msg %aRoom %line1
      msg %aRoom %line2
      msg %aRoom %line3
      msg %aRoom %line4
      msg %aRoom %line5
      msg %aRoom %line6
      msg %aRoom %line7
      msg %aRoom %line8
      msg %aRoom %line9
      msg %aRoom %amp
      inc %x
    }

    ;  get the total number of checked names/nicks
    var %numNick $did(mc2,32,0).csel
    echo -s %numNick nicks
    var %x 1

    ;  sends the report to all the nicks
    while (%x <= %numNick) {
      var %place $did(mc2,32,%x).csel
      var %aGuy $did(mc2,32,%place).text
      describe %aGuy 4 mIRC_C2: 9line Report from $me prepared: $did(9line,11).text
      msg %aGuy %line1
      msg %aGuy %line2
      msg %aGuy %line3
      msg %aGuy %line4
      msg %aGuy %line5
      msg %aGuy %line6
      msg %aGuy %line7
      msg %aGuy %line8
      msg %aGuy %line9
      msg %aGuy %amp
      inc %x
    }

    IF ($did(9line,90).state == 1) {
      ; testing to try and write the report to a file and open it
      ; make the unique filename
      var %repFileName $+($asctime($gmt,yymmdd-HHnns),-9LINE-,$me,.doc)

      var %header ****9-Line MEDEVAC from $me prepared: $did(9line,11).text
      ; create a file
      fopen -o repName %repFileName
      ; writes the text to the file
      fwrite -n repName $strip($+(%header,$crlf,%line1,$crlf,%line2,$crlf,%line3,$crlf,%line4,$crlf,%line5,$crlf,%line6,$crlf,%line7,$crlf,%line8,$crlf,%line9,$crlf,%amp))
      fclose repName
      run %repFileName
    }    
    var %rep.Type 9line
    var %rep.Sender $me
    ; %rep.Channels will be defined above as the channels are geting the report

    listerS %rep.Time %rep.Type %rep.Sender %rep.Channels 
    echo -s sent to listerS: %repFileName %rep.Channels %rep.Time %rep.Type %rep.Sender %rep.Channels 
  }
}

***********************UNCLASSIFIED*********************