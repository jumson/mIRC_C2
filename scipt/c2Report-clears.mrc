***********************UNCLASSIFIED*********************
***c2Report-clears.mrc***

/*
	reports must have the dialog name in the filename in the format:
	c2Report-XXX.mrc
	where XXX is the name of the dialog that gets called for the report

	report upgrades give unique filename (done)
	always create/store the report, don't always open it
	give an option to add it to an email
	identify the linefeed and preserve the formatting.
*/

;this effectivly regersters the report with the mc2 dialog
ON 1:LOAD: {
  var %repName CLEAR Report
  var %repDName clears
  hadd -m repreg %repDName %repName
  echo -s THE %repName is loaded!
}   

ON 1:DIALOG:clears:INIT:*: {
  did -r clears 11
  did -a clears 11 $asctime($gmt,ddd mmm dd HH:nn:ss yyyy)
}

;this creates the layout of the Clear report dialog
dialog clears {

  title "CLEAR Report"
  size %mc2x %mc2y 200 150
  option dbu

  box "Date/Time Report Prepared (in ZULU time)", 10, 10 10 180 20
  edit $fulldate, 11, 12 18 130 10
  button "Refresh",12, 145 18 35 10

  box "Text of the CLEAR Report",20, 10 30 180 100
  edit "",21,12 38 176 90, vsbar, multi, return

  check "Also Send to text file", 80, 100 132 55 10, left
  button "Send",100,165 132 30 10, ok
}

; this catches all sclicks from the "clears" dialog
ON 1:DIALOG:clears:sclick:*:{

  ; this is the "refresh" button to put the new time in the box
  IF ($did == 12) {
    did -r clears 11
    did -a clears 11 $asctime($gmt,ddd mmm dd HH:nn:ss yyyy)
  }

  ; This is the "send" button
  IF ($did == 100) {
    echo -s clears send button depressed

    ; returns total number of checked channel lines
    var %numChan $did(mc2,34,0).csel 
    var %x 1
    set %rep.Time $timestamp
    ; sends the report to all the channels

    while (%x <= %numChan) {
      var %place $did(mc2,34,%x).csel
      var %aRoom $did(mc2,34,%place).text
      var %rep.Channels $+(%aRoom,$chr(32),%rep.Channels)
      describe %aRoom 4 mIRC_C2: CLEAR Report from $me prepared: $did(clears,11).text
      msg %aRoom 12Report: 
      msg %aRoom $+(3,-->,$did(clears,21,1).text)
      var %amount $did(clears,21).lines
      var %y 2
      while (%y <= %amount) {
        var %repClr $+(3,-->,$did(clears,21,%y).text)
        msg %aRoom %repClr
        inc %y
      }
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
      var %rep.Channels $+(%aGuy,$chr(32),%rep.Channels)
      describe %aGuy 4 mIRC_C2: CLEAR Report from $me prepared: $did(clears,11).text
      msg %aGuy 12Report: 
      msg %aGuy $+(3,-->,$did(clears,21,1).text)
      var %amount $did(clears,21).lines
      var %y 2
      while (%y <= %amount) {
        var %repClr $+(3,-->,$did(clears,21,%y).text)
        msg %aGuy %repClr
        inc %y
      }
      inc %x
    }

    ; if the box is checked - write the report to a file and open it
    IF ($did(clears,80).state == 1) {
      ; make the unique filename
      var %repFileName $+($asctime($gmt,yymmdd-HHnns),-CLEAR-,$me,.)
      var %repFileName-doc $+(%repFileName,doc)
      var %repFileName-txt $+(%repFileName,txt)

      var %header ****CLEAR Report from $me prepared: $did(clears,11).text
      ; create a word document
      if ($fopen(repName) == repName) {
        echo repName is open!!!
        fclose repName
        echo -s repName is closed
      }
      fopen -o repName $+($mircdir,reports\,%repFileName-doc)
      ; writes the text to the file
      var %header mIRC_C2: CLEAR Report from $me prepared: $did(clears,11).text
      fwrite -n repName %header
      fwrite -n repName Report:
      var %repNext $did(clears,21,1).text
      fwrite -n repName %repNext

      var %amount $did(clears,21).lines
      var %y 2
      while (%y <= %amount) {
        var %repNext $did(clears,21,%y).text
        fwrite -n repName %repNext
        inc %y
      }
      fclose repName
      run $+($mircdir,reports\,%repFileName-doc)

      /*
      ; create a plaintext document
      fopen -o repName $+($mircdir,reports\,%repFileName-txt)
      ; writes the text to the file
      fwrite -n repName $strip($+(%header,$crlf,%clrRep))
      fclose repName
      ; run $+($mircdir,reports\,%repFileName-txt)
      */
      ; register it in the list (report List Hash?)
      ; send info to the "lsiter" alias
      ; send report %repFileName an channel(period delimit the channels - no spaces) report time

    }
    var %rep.Type CLEAR
    var %rep.Sender $me
    ; %rep.Channels will be defined above as the channels are geting the report

    listerS %rep.Time %rep.Type %rep.Sender %rep.Channels 
    echo -s sent to listerS: %repFileName %rep.Channels %rep.Time %rep.Type %rep.Sender %rep.Channels 
  }
}
