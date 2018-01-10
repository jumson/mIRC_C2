***********************UNCLASSIFIED*********************
***c2Report-5ws.mrc***

/*
reports must have the dialog name in the filename in the format:
c2Report-XXX.mrc
where XXX is the name of the dialog that gets called for the report
*/

;this effectivly regersters the report with the mc2 dialog
ON 1:LOAD: {
  var %repName 5W's Report
  var %repDName 5ws
  hadd -m repreg %repDName %repName 
  echo -s THE %repName is loaded!
}   

ON 1:DIALOG:5ws:INIT:*: {
  did -r 5ws 11
  did -a 5ws 11 $asctime($gmt,ddd mmm dd HH:nn:ss yyyy)
}

;this creates the layout of the 5Ws report dialog
dialog 5ws {

  title "5 W's Report"
  size %mc2x %mc2y 200 230
  option dbu

  box "Date/Time Report Prepared (in ZULU time)", 10, 10 10 180 20
  edit $fulldate, 11, 12 18 130 10
  button "Refresh",12, 145 18 35 10

  box "Who",20, 10 30 180 30
  edit "",21,12 38 176 20, vsbar, multi, return, rich

  box "What",30, 10 60 180 30
  edit "",31,12 68 176 20, vsbar, multi, return, rich

  box "Where",40, 10 90 180 30
  edit "",41,12 98 176 20, vsbar, multi, return, rich

  box "When",50, 10 120 180 30
  edit "",51,12 128 176 20, vsbar, multi, return, rich

  box "Why",60, 10 150 180 30
  edit "",61,12 158 176 20, vsbar, multi, return, rich

  box "Amplifying Information",70, 10 180 180 30
  edit "",71,12 188 176 20, vsbar, multi, return, rich

  check "Also Send to text file", 80, 100 215 55 10, left
  button "Send",100,165 215 30 10, ok
}

; this catches all sclicks from the "5ws" dialog
ON 1:DIALOG:5ws:sclick:*:{

  ; this is the "refresh" button to put the new time in the box
  IF ($did == 12) {
  did -r 5ws 11
  did -a 5ws 11 $asctime($gmt,ddd mmm dd HH:nn:ss yyyy)
  }

  ; This is the "send" button
  IF ($did == 100) {
    echo -s 5Ws send button depressed

    var %who $+(12Who: 3,$did(5ws,21).text)
    IF ($did(5ws,21).lines > 1) {
      var %amount $did(5ws,21).lines
      var %x 2
      while (%x <= %amount) {
        var %who = $+(%who,$chr(32),$did(5ws,21,%x).text)
        inc %x
      }
    }

    var %what $+(12What: 3,$did(5ws,31).text)
    IF ($did(5ws,31).lines > 1) {
      var %amount $did(5ws,31).lines
      var %x 2
      while (%x <= %amount) {
        var %what = $+(%what,$chr(32),$did(5ws,31,%x).text)
        inc %x
      }
    }

    var %where $+(12Where: 3,$did(5ws,41).text)
    IF ($did(5ws,41).lines > 1) {
      var %amount $did(5ws,41).lines
      var %x 2
      while (%x <= %amount) {
        var %where = $+(%where,$chr(32),$did(5ws,41,%x).text)
        inc %x
      }
    }

    var %when $+(12When: 3,$did(5ws,51).text)
    IF ($did(5ws,51).lines > 1) {
      var %amount $did(5ws,51).lines
      var %x 2
      while (%x <= %amount) {
        var %when = $+(%when,$chr(32),$did(5ws,51,%x).text)
        inc %x
      }
    }

    var %why $+(12Why: 3,$did(5ws,61).text)
    IF ($did(5ws,61).lines > 1) {
      var %amount $did(5ws,61).lines
      var %x 2
      while (%x <= %amount) {
        var %why = $+(%why,$chr(32),$did(5ws,61,%x).text)
        inc %x
      }
    }

    var %amp $+(12Amplifying info: 3,$did(5ws,71).text)
    IF ($did(5ws,71).lines > 1) {
      var %amount $did(5ws,71).lines
      var %x 2
      while (%x <= %amount) {
        var %amp = $+(%amp,$chr(32),$did(5ws,71,%x).text)
        inc %x
      }
    }

    ; returns total number of checked channel lines
    var %numChan $did(mc2,34,0).csel 
    var %x 1
    set %rep.Time $timestamp

    ; sends the report to all the channels
    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aRoom $did(mc2,34,%place).text
      var %rep.Channels $+(%aRoom,$chr(32),%rep.Channels)
      describe %aRoom 4 mIRC_C2: 5Ws from $me prepared: $did(5ws,11).text
      msg %aRoom %who
      msg %aRoom %what
      msg %aRoom %where
      msg %aRoom %when
      msg %aRoom %why
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
      describe %aGuy 4 mIRC_C2: 5Ws from $me prepared: $did(5ws,11).text
      msg %aGuy %who
      msg %aGuy %what
      msg %aGuy %where
      msg %aGuy %when
      msg %aGuy %why
      msg %aGuy %amp
      inc %x
    }

    IF ($did(5ws,80).state == 1) {
      ; testing to try and write the report to a file and open it
      ; make the unique filename
      var %repFileName $+($asctime($gmt,yymmdd-HHnns),-CLEAR-,$me,.doc)

      var %header ****5Ws from $me prepared: $did(5ws,11).text
      ; create a file
      fopen -o repName %repFileName
      ; writes the text to the file
      fwrite -n repName $strip($+(%header,$crlf,%who,$crlf,%what,$crlf,%where,$crlf,%when,$crlf,%why,$crlf,%amp))
      fclose repName
      run %repFileName
    }
    var %rep.Type 5Ws
    var %rep.Sender $me
    ; %rep.Channels and %rep.Time will be defined above as the channels are getting the report

    listerS %rep.Time %rep.Type %rep.Sender %rep.Channels 
    echo -s sent to listerS: %repFileName %rep.Channels %rep.Time %rep.Type %rep.Sender %rep.Channels 
  }
}
