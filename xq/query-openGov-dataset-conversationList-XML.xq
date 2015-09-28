import module namespace functx = 'http://www.functx.com' at 'http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq';

declare option output:method "xml";

<nixonTapes lastModified="{current-dateTime()}">
{
  let $coll := collection("base")
  
  for $c in $coll/root/row[not(contains(tapeNo,'test'))]
  
(: identifying information :)
  let $tapeID := data($c/tapeNo3Dig)
  let $convID := data($c/convNo3Dig)
  let $digitalID := data($c/filename)  
  let $conversation := normalize-space(concat("Conversation ",$tapeID,"-",$convID))

(: participants, seperated by semi-colon :)
  let $participants := $c/participantsWithLineBreaks/(persname|corpname)

(: startDateTime, adjusted for Daylight Savings:)
let $sdt := $c/startDateTime
let $sdtAdjusted := 
  if (functx:between-inclusive(
    xs:dateTime($sdt),
    xs:dateTime("1971-04-25T02:00:00-05:00"), 
    xs:dateTime("1971-10-31T01:59:59-05:00")
    ))
  then concat(substring-before(data($sdt),"-05:00"),"-04:00")
  else
    if (functx:between-inclusive(
      xs:dateTime($sdt),
      xs:dateTime("1972-04-30T02:00:00-05:00"), 
      xs:dateTime("1972-10-29T01:59:59-05:00")
      ))
    then concat(substring-before(data($sdt),"-05:00"),"-04:00")
    else
      if (functx:between-inclusive(
        xs:dateTime($sdt),
        xs:dateTime("1973-04-29T02:00:00-05:00"), 
        xs:dateTime("1973-10-28T01:59:59-05:00")
        ))
      then concat(substring-before(data($sdt),"-05:00"),"-04:00")
      else $sdt 

(: endDateTime, adjusted for Daylight Savings Time:)
let $edt := $c/endDateTime
let $edtAdjusted := 
  if (functx:between-inclusive(
    xs:dateTime($edt),
    xs:dateTime("1971-04-25T02:00:00-05:00"), 
    xs:dateTime("1971-10-31T01:59:59-05:00")
    ))
  then concat(substring-before(data($edt),"-05:00"),"-04:00")
  else
    if (functx:between-inclusive(
      xs:dateTime($edt),
      xs:dateTime("1972-04-30T02:00:00-05:00"), 
      xs:dateTime("1972-10-29T01:59:59-05:00")
      ))
    then concat(substring-before(data($edt),"-05:00"),"-04:00")
    else
      if (functx:between-inclusive(
        xs:dateTime($edt),
        xs:dateTime("1973-04-29T02:00:00-05:00"), 
        xs:dateTime("1973-10-28T01:59:59-05:00")
        ))
      then concat(substring-before(data($edt),"-05:00"),"-04:00")
      else $edt

(: date certainty :)
  let $dateCert :=
    if (contains(data($c/convoDate-NaturalLanguage-Cap),"unknown"))
    then "estimated"
    else data($c/dateCertainty)  

(: time certainty :)
  let $timeCert :=
    if (contains(data($c/convTime-Extended-Lower),"unknown"))
    then "estimated"
    else data($c/timeCertainty)
    
(: human-readable start time, 12 hr clock :)
  let $startTime := xs:time($c/startTime-hhmmss)
    let $sTime :=
      concat(
        (
          if (hours-from-time($startTime) > 12)
          then (hours-from-time($startTime) - 12)
          else 
            if (hours-from-time($startTime) = 0)
            then "12"
            else hours-from-time($startTime)
        )
        ,
        ":",
        functx:pad-integer-to-length(minutes-from-time($startTime),2),
          (
            if (hours-from-time($startTime) >= 12)
            then " pm"
            else " am"
          )  
      )

(: human-readable end time, 12 hr clock :)
  let $endTime := xs:time($c/endTime-hhmmss)
    let $eTime := 
      concat(
        (
          if (hours-from-time($endTime) > 12)
          then (hours-from-time($endTime) - 12)
          else 
            if (hours-from-time($endTime) = 0)
            then "12"
            else hours-from-time($endTime))
        ,
        ":",
        functx:pad-integer-to-length(minutes-from-time($endTime),2),
          (
            if (hours-from-time($endTime) >= 12)
            then " pm"
            else " am"
          )  
        )

(: chron in sortable number :)
  let $chronNum :=
    if (contains($c/releaseChron,"First"))
    then "1"
    else
      if (contains($c/releaseChron,"Second"))
      then "2"
      else
        if (contains($c/releaseChron,"Third"))
        then "3"
        else
          if (contains($c/releaseChron,"Fourth"))
          then "4"
          else
            if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part IV"))
            then "5.4"
            else
              if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part V"))
              then "5.5"
              else
                if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part III"))
                then "5.3"
                else
                  if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part II"))
                  then "5.2"
                  else
                    if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part I"))
                    then "5.1"
                    else
                      if (contains($c/releaseChron,"Cabinet"))   
                      then "Cabinet"
                      else "!"
                      
(: description section :)

  (: participants listed in natural language, with find/replace; different sources by chron :)
  
  let $descPart := 
    (: base phrase, adding comma if contains 'including' :)
    if (contains(data($c/partNatLang | $c/participantsNaturalLanguage),", including"))
    then concat (data($c/partNatLang | $c/participantsNaturalLanguage),",")
    (: base phrase, wihtout 'including' :)
    else data($c/partNatLang | $c/participantsNaturalLanguage)

  (: case substituions for middle of sentence :)
  let $pFr := ("During ", "Unknown")
  let $pTo := ("during ", "unknown")
  
  let $descLower := functx:replace-multi($descPart,$pFr,$pTo)

  (: location phrase :)
    let $location := 
      if (contains($c/locationCode, "CAB"))
      then "met in the Cabinet Room of the White House"
      else
        if (contains($c/locationCode, "EOB"))
        then "met in the President's office in the Old Executive Office Building"
        else
          if(contains($c/locationCode, "OVAL"))
          then "met in the Oval Office of the White House"
          else
            if(contains($c/locationCode, "WHT"))
            then "talked on the telephone"
            else
              if (contains($c/locationCode, "CDHW"))
              then "met in the Aspen Lodge study at Camp David"
              else
                if (contains($c/locationCode, "CDSD"))
                then "talked on the telephone at Camp David"
                else
                  if (contains($c/locationCode, "CDST"))
                  then "talked on the telephone at Camp David"
                  else ""

  (: device phrase :)
  let $device :=  concat("The ",$c/locationNaturalLanguage," taping system captured this recording, which is known as ",$conversation," of the White House Tapes.")
  
  (: if/then statements for content :)
    let $statement :=
    (: 1 :)
    if ($c/startDate eq $c/endDate and $c/startTime-hhmmss eq $c/endTime-hhmmss)
    then
      if (contains($descPart, "Appears to be blank"))
      then concat("On ",$c/startDate-NaturalLanguage,", the recording device engaged at ",$sTime,", but the conversation appears to be blank. ",$device)
        else
          if (contains($descPart, "[Uncompleted call]"))
          then concat("On ",$c/startDate-NaturalLanguage,", a telephone call was attempted at ",$sTime,", but the call was not completed. ",$device)
          else concat("On ",$c/startDate-NaturalLanguage,", ",$descLower," ",$location," at ",$sTime,". ",$device)
      else    
        (: 2 :)    
        if ($c/startDate eq $c/endDate and (data($timeCert) eq "certain"))
        then 
          if (contains($descPart, "Appears to be blank"))
          then concat("On ",$c/startDate-NaturalLanguage,", the recording device engaged from ",$sTime," to ",$eTime,", but the conversation appears to be blank. ",$device)
            else
              if (contains($descPart, "[Uncompleted call]"))
              then concat("On ",$c/startDate-NaturalLanguage,", a telephone call was attempted from ",$sTime," to ",$eTime, ", but the call was not completed. ",$device)
              else concat("On ",$c/startDate-NaturalLanguage,", ",$descLower," ",$location," from ",$sTime," to ",$eTime,". ",$device)
    else
        (: 3 :)
        if ($c/startDate eq $c/endDate and data($timeCert) eq "estimated")
        then
           if (contains($descPart, "Appears to be blank"))
          then concat("On ",$c/startDate-NaturalLanguage,", the recording device engaged at an unknown time between ",$sTime," and ",$eTime,", but the conversation appears to be blank. ",$device)
            else
              if (contains($descPart, "[Uncompleted call]"))
              then concat("On ",$c/startDate-NaturalLanguage,", a telephone call was attempted at an unknown time between ",$sTime," and ",$eTime,", but the call was not completed. ",$device)
              else concat("On ",$c/startDate-NaturalLanguage,", ",$descLower," ",$location," at an unknown time between ",$sTime," and ",$eTime,". ",$device)
        else
          (: 4 :)
          if (data($dateCert) eq "certain")
          then
             if (contains($descPart, "Appears to be blank"))
            then concat("The recording device engaged from ",$sTime," on ",$c/startDate-NaturalLanguage," to ",$eTime," on ",$c/endDate-NaturalLanguage,", but the conversation appears to be blank. ",$device)
              else
                if (contains($descPart, "[Uncompleted call]"))
                then concat("On ",$c/startDate-NaturalLanguage,", a telephone call was attempted from ",$sTime," on ",$c/startDate-NaturalLanguage," to ",$eTime," on ",$c/endDate-NaturalLanguage,", but the call was not completed. ",$device)
                else concat($descPart," ",$location," from ",$sTime," on ",$c/startDate-NaturalLanguage," to ",$eTime," on ",$c/endDate-NaturalLanguage,". ",$device)
          else
            (: 5 :)
            if (data($dateCert) eq "estimated")
            then 
              if (contains($descPart, "Appears to be blank"))
              then concat("The recording device engaged on an unknown date, sometime between ",$sTime," on ",$c/startDate-NaturalLanguage," and ",$eTime," on ",$c/endDate-NaturalLanguage,", but the conversation appears to be blank. ",$device)
              else
                if (contains($descPart, "[Uncompleted call]"))
                then concat("A telephone call was attempted at an unknown date, sometime between ",$sTime," on ",$c/startDate-NaturalLanguage," and ",$eTime," on ",$c/endDate-NaturalLanguage,", but the call was not completed. ",$device)
                else concat($descPart," ",$location," on an unknown date, sometime between ",$sTime," on ",$c/startDate-NaturalLanguage," and ",$eTime," on ",$c/endDate-NaturalLanguage,". ",$device)
            else "!"
            
  where $tapeID eq "001"
  order by $conversation       
  return
  
  <conversation>
    <collection uri="https://catalog.archives.gov/id/597542">White House Tapes: Sound Recordings of Meetings and Telephone Conversations of the Nixon Administration, 1971-1973</collection>   
    <conversationNumber>{xs:string($convID)}</conversationNumber>
    <dateTime>
        <dateCertainty>{data($dateCert)}</dateCertainty>
        <startDateTime dateTime="{data($sdtAdjusted)}">
            <startDate>{data($c/startDate-NaturalLanguage)}</startDate>
            <startTime>{data($sTime)}</startTime>
        </startDateTime>
        <endDateTime dateTime="{data($edtAdjusted)}">
            <endDate>{data($c/endDate-NaturalLanguage)}</endDate>
            <endTime>{data($eTime)}</endTime>        
        </endDateTime>
        <timeCertainty>{data($timeCert)}</timeCertainty>
    </dateTime>
    <description>{functx:capitalize-first($statement)}</description>
    <digitizationID>{data($c/filename)}</digitizationID>
    <lastModified>{current-dateTime()}</lastModified>
    <location>
      <latitude certainty="estimated">{data($c/latitude)}</latitude>
      <locationCode>{data($c/locationCode)}</locationCode>
      <longitude certainty="estimated">{data($c/longitude)}</longitude>
      <recordingDevice>{data($c/locationNaturalLanguage)}</recordingDevice>
    </location>
    <participants>{$participants}</participants>
    <publicReleases>
      <release type="chron" chronCode="{data($chronNum)}" issued="{data($c/(releaseDate-NatLang|releaseDateNatLang))}">{data($c/releaseChron)}</release>
      <release type="aogpRelease">{data($c/AoGP_Release)}
        <segment type="aogpSegment">{data($c/AoGP_Segments)}</segment>
      </release>
    </publicReleases>
    <tapeNumber>{xs:string($tapeID)}</tapeNumber>
    <title>{$conversation}</title>
  </conversation>
}
</nixonTapes>
