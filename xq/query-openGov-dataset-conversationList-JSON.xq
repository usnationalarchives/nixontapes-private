import module namespace functx = 'http://www.functx.com' at 'http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq';

(: import module namespace functx = 'http://www.functx.com' at 'functx/functx-1.0-doc-2007-01.xq';  :)

declare option output:method "text";

  <nixonTapes lastModified="{current-dateTime()}">&#123;
&#9;"set": "INSERT SERIES HERE",
&#9;"conversations": &#91;
{
  let $coll := collection("base")
  
  (: let $q := "910" :)
  let $series := "WHT"
  let $open-curly := '&#123;' (: for { :)
  let $closed-curly := '&#125;' (: for } :)
  let $open-square := '&#91;' (: for [ :)
  let $closed-square := '&#93;' (: ] :)
  let $quote := "&#34;" (: quotation marks :)
  let $nl := "&#10;" (: new line :)
  let $tab := '&#9;' (: tab :)
  let $escaped-quote := '&#92;&#34;'
  
  (: for $c in $coll/root/row[not(contains(tapeNo,'test'))][tapeNo3Dig[matches(.,$q)]] :)

  for $c in $coll/root/row[not(contains(tapeNo,'test'))][locationCode[matches(.,$series)]]
  
(: identifying information :)
  let $tapeID := data($c/tapeNo3Dig)
  let $convID := data($c/convNo3Dig)
  let $digitalID := data($c/filename)  
  let $conversation := normalize-space(concat("Conversation ",$tapeID,"-",$convID))

(: participants, seperated by semi-colon :)
  let $participants :=   
    for $p in $c/participantsWithLineBreaks/(persname|corpname)
    let $pEntry := concat(data($p),";")
    return $pEntry

(: full participants, in JSON :)


  let $pJSON := 

    for $pJ in $c/participantsWithLineBreaks/(persname|corpname)
    let $type :=
      if (contains(xs:string(node-name($pJ)),"persname"))
      then "person"
      else "organization or group"
      
    let $pJEntry := concat(
      $tab,$tab,$tab,$tab,$open-curly,$nl,
        $tab,$tab,$tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,data($pJ/attribute::authfilenumber),$quote,",",$nl,
        $tab,$tab,$tab,$tab,$tab,$quote,"name",$quote,": ",$quote,replace(replace(data($pJ),"\(&#34;","(\\&#34;"),"&#34;\)","\\&#34;)"),$quote,", ",$nl,
        $tab,$tab,$tab,$tab,$tab,$quote,"type",$quote,": ",$quote,$type,$quote,$nl,
      $tab,$tab,$tab,$tab,$closed-curly,",",$nl)
    
    (: ",",$nl :)

    order by $pJ/text()
    return $pJEntry


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

(: series section :)

    let $isPartSeries := 
      if (contains($c/locationCode, "CAB"))
      then 
      
        concat($tab,$tab,$tab,$tab,$open-curly,$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,"37-wht-cab",$quote,", ",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"level",$quote,": ",$quote,"series",$quote,", ",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"title",$quote,": ",$quote,"Cabinet Room Sound Recordings",$quote,",",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"uri",$quote,": ",$quote,"https://catalog.archives.gov/id/12006803",$quote,$nl,
        $tab,$tab,$tab,$tab,$closed-curly,$nl)
        
      else
        if (contains($c/locationCode, "EOB"))
        then

        concat($tab,$tab,$tab,$tab,$open-curly,$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,"37-wht-eob",$quote,", ",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"level",$quote,": ",$quote,"series",$quote,", ",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"title",$quote,": ",$quote,"Executive Office Building Sound Recordings",$quote,",",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"uri",$quote,": ",$quote,"https://catalog.archives.gov/id/17409890",$quote,$nl,
        $tab,$tab,$tab,$tab,$closed-curly,$nl)          

        else
          if(contains($c/locationCode, "OVAL"))
          then
                
          concat($tab,$tab,$tab,$tab,$open-curly,$nl,
            $tab,$tab,$tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,"37-wht-oval",$quote,", ",$nl,
            $tab,$tab,$tab,$tab,$tab,$quote,"level",$quote,": ",$quote,"series",$quote,", ",$nl,
            $tab,$tab,$tab,$tab,$tab,$quote,"title",$quote,": ",$quote,"Oval Office Sound Recordings",$quote,",",$nl,
            $tab,$tab,$tab,$tab,$tab,$quote,"uri",$quote,": ",$quote,"https://catalog.archives.gov/id/17409633",$quote,$nl,
          $tab,$tab,$tab,$tab,$closed-curly,$nl)
  
          else
            if(contains($c/locationCode, "WHT"))
            then
            
              concat($tab,$tab,$tab,$tab,$open-curly,$nl,
                $tab,$tab,$tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,"37-wht-wht",$quote,", ",$nl,
                $tab,$tab,$tab,$tab,$tab,$quote,"level",$quote,": ",$quote,"series",$quote,", ",$nl,
                $tab,$tab,$tab,$tab,$tab,$quote,"title",$quote,": ",$quote,"White House Telephone Recordings",$quote,",",$nl,
                $tab,$tab,$tab,$tab,$tab,$quote,"uri",$quote,": ",$quote,"https://catalog.archives.gov/id/17412458",$quote,$nl,
              $tab,$tab,$tab,$tab,$closed-curly,$nl)

            else
              if (contains($c/locationCode, "CDHW"))
              then
                    
                concat($tab,$tab,$tab,$tab,$open-curly,$nl,
                  $tab,$tab,$tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,"37-wht-cdhw",$quote,", ",$nl,
                  $tab,$tab,$tab,$tab,$tab,$quote,"level",$quote,": ",$quote,"series",$quote,", ",$nl,
                  $tab,$tab,$tab,$tab,$tab,$quote,"title",$quote,": ",$quote,"Camp David Hard Wire Sound Recordings",$quote,",",$nl,
                  $tab,$tab,$tab,$tab,$tab,$quote,"uri",$quote,": ",$quote,"https://catalog.archives.gov/id/17408783",$quote,$nl,
                $tab,$tab,$tab,$tab,$closed-curly,$nl)

              else
                if (contains($c/locationCode, "CDSD"))
                then
                
                  concat($tab,$tab,$tab,$tab,$open-curly,$nl,
                    $tab,$tab,$tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,"37-wht-cdsd",$quote,", ",$nl,
                    $tab,$tab,$tab,$tab,$tab,$quote,"level",$quote,": ",$quote,"series",$quote,", ",$nl,
                    $tab,$tab,$tab,$tab,$tab,$quote,"title",$quote,": ",$quote,"Camp David Study Desk Telephone Recordings",$quote,",",$nl,
                    $tab,$tab,$tab,$tab,$tab,$quote,"uri",$quote,": ",$quote,"https://catalog.archives.gov/id/17408953",$quote,$nl,
                  $tab,$tab,$tab,$tab,$closed-curly,$nl)
                
                else
                  if (contains($c/locationCode, "CDST"))
                  then

                    concat($tab,$tab,$tab,$tab,$open-curly,$nl,
                      $tab,$tab,$tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,"37-wht-cdst",$quote,", ",$nl,
                      $tab,$tab,$tab,$tab,$tab,$quote,"level",$quote,": ",$quote,"series",$quote,", ",$nl,
                      $tab,$tab,$tab,$tab,$tab,$quote,"title",$quote,": ",$quote,"Camp David Study Table Telephone Recordings",$quote,",",$nl,
                      $tab,$tab,$tab,$tab,$tab,$quote,"uri",$quote,": ",$quote,"https://catalog.archives.gov/id/17409122",$quote,$nl,
                    $tab,$tab,$tab,$tab,$closed-curly,$nl)


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

order by $conversation ascending
        
  return

  <conversation>
  <access>{concat($tab,$tab,$open-curly,$nl,
    $tab,$tab,$tab,$quote,"access",$quote,": ",$open-square,$nl,
      $tab,$tab,$tab,$tab,$open-curly,$nl,
        $tab,$tab,$tab,$tab,$tab,$quote,"contactPoint",$quote,": ",$open-curly,$nl,
          $tab,$tab,$tab,$tab,$tab,$tab,$quote,"hasEmail",$quote,": ",$quote,"nixon@nara.gov",$quote,", ",$nl,
          $tab,$tab,$tab,$tab,$tab,$tab,$quote,"name",$quote,": ",$quote,"Nixon Presidential Library and Museum",$quote,$nl,
      $tab,$tab,$tab,$tab,$tab,$closed-curly,", ",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"note",$quote,": ",$quote,"The Nixon Presidential Library and Museum, part of the National Archives and Records Administration, is working to digitize the White House Tapes.  For digitized audio recordings and more information about the White House Tapes, please visit: http://www.nixonlibrary.gov/forresearchers/find/tapes/index.php",$quote,",",$nl,
    $tab,$tab,$tab,$tab,$tab,$quote,"type",$quote,": ",$quote,"digital",$quote,$nl,
    $tab,$tab,$tab,$tab,$closed-curly,", ",$nl,
    $tab,$tab,$tab,$tab,$open-curly,$nl,
        $tab,$tab,$tab,$tab,$tab,$quote,"contactPoint",$quote,": ",$open-curly,$nl,
          $tab,$tab,$tab,$tab,$tab,$tab,$quote,"hasEmail",$quote,": ",$quote,"nixon@nara.gov",$quote,", ",$nl,
          $tab,$tab,$tab,$tab,$tab,$tab,$quote,"name",$quote,": ",$quote,"Nixon Presidential Library and Museum",$quote,$nl,
      $tab,$tab,$tab,$tab,$tab,$closed-curly,", ",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"note",$quote,": ",$quote,"Physical copies of White House Tapes conversations may be accessed in two locations: 1) the reading room of the Nixon Presidential Library and Museum in Yorba Linda, California, and 2) the audiovisual reading room of the National Archives at College Park, Maryland.",$quote,", ",$nl,
        $tab,$tab,$tab,$tab,$tab,$quote,"type",$quote,": ",$quote,"physical",$quote,$nl,
    $tab,$tab,$tab,$tab,$closed-curly,$nl,
    $tab,$tab,$tab,$closed-square,", ",$nl)}
  </access>
    <conversationNumber>{concat(
    $tab,$tab,$tab,$quote,"conversationNumber",$quote,": ",$quote,xs:string($convID),$quote,",",$nl)}</conversationNumber>
    
    <dateTime>
      {concat($tab,$tab,$tab,$quote,"dateTime",$quote,": ",$open-curly,$nl,
        $tab,$tab,$tab,$tab,$quote,"dateCertainty",$quote,": ",$quote,data($dateCert),$quote,", ",$nl,
        $tab,$tab,$tab,$tab,$quote,"endDateTime",$quote,": ",$quote,data($c/endDateTime),$quote,", ",$nl,
        $tab,$tab,$tab,$tab,$quote,"startDateTime",$quote,": ",$quote,data($c/startDateTime),$quote,", ",$nl,
        $tab,$tab,$tab,$tab,$quote,"timeCertainty",$quote,": ",$quote,data($timeCert),$quote,$nl,
        $tab,$tab,$tab,$closed-curly,",",$nl)
      }
    </dateTime>

    <description>
      {concat($tab,$tab,$tab,$quote,"description",$quote,": ",$quote,replace(replace($statement,"\(&#34;","(\\&#34;"),"&#34;\)","\\&#34;)"),$quote,",",$nl)}
    </description>
        
    <digitizationID>
      {concat($tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,data($c/filename),$quote,",",$nl)}
    </digitizationID>

    <isPartOf>
      {concat($tab,$tab,$tab,$quote,"isPartOf",$quote,": ",$open-square,$nl,
        $tab,$tab,$tab,$tab,$open-curly,$nl,
        $tab,$tab,$tab,$tab,$tab,$quote,"identifier",$quote,": ",$quote,"37-wht",$quote,",",$nl,        
        $tab,$tab,$tab,$tab,$tab,$quote,"level",$quote,": ",$quote,"collection",$quote,",",$nl,
        $tab,$tab,$tab,$tab,$tab,$quote,"title",$quote,": ",$quote,"White House Tapes: Sound Recordings of Meetings and Telephone Conversations of the Nixon Administration, 1971 to 1973",$quote,",",$nl,
        $tab,$tab,$tab,$tab,$tab,$quote,"uri",$quote,": ",$quote,"https://catalog.archives.gov/id/597542",$quote,$nl,
        $tab,$tab,$tab,$tab,$closed-curly,",",$nl,
        $isPartSeries,
      $tab,$tab,$tab,$closed-square,",",$nl)}
    </isPartOf>

    <lastModified>
      {concat($tab,$tab,$tab,$quote,"lastModified",$quote,": ",$quote,current-dateTime(),$quote,",",$nl)}
    </lastModified>
             
    <location>
      {
        concat($tab,$tab,$tab,$quote,"location",$quote,": ",$open-curly,$nl,
            $tab,$tab,$tab,$tab,$quote,"geo",$quote,": ",$open-curly,$nl,
                $tab,$tab,$tab,$tab,$tab,$quote,"certainty",$quote,": ",$quote,"estimated",$quote,",",$nl,
                $tab,$tab,$tab,$tab,$tab,$quote,"latitude",$quote,": ",$quote,data($c/latitude),$quote,",",$nl,
                $tab,$tab,$tab,$tab,$tab,$quote,"longitude",$quote,": ",$quote,data($c/longitude),$quote,$nl,
                $tab,$tab,$tab,$tab,$closed-curly,", ",$nl,
            $tab,$tab,$tab,$tab,$quote,"locationCode",$quote,": ",$quote,data($c/locationCode),$quote,",",$nl,
            $tab,$tab,$tab,$tab,$quote,"recordingDevice",$quote,": ",$quote,data($c/locationNaturalLanguage),$quote,$nl,
        $tab,$tab,$tab,$closed-curly,",",$nl)
      }
    </location>

    <participants>
      {concat($tab,$tab,$tab,$quote,"participants",$quote,": ",$open-square,$nl)}
      {$pJSON}
      {concat($tab,$tab,$tab,$closed-square,",",$nl)}
    </participants>

    <publicReleases>
      {concat($tab,$tab,$tab,$quote,"publicReleases",$quote,": ", $open-square,$nl)}
        {concat($tab,$tab,$tab,$tab,$open-curly,$nl,          
          $tab,$tab,$tab,$tab,$tab,$quote,"chronCode",$quote,": ",$quote,data($chronNum),$quote,",",$nl,
           $tab,$tab,$tab,$tab,$tab,$quote,"issueDate",$quote,": ",$quote,data($c/(releaseDate-NatLang|releaseDateNatLang)),$quote,",",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"releaseName",$quote,": ",$quote,data($c/releaseChron),$quote,",",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"type",$quote,": ",$quote,"chron",$quote,$nl,
        $tab,$tab,$tab,$tab,$closed-curly,",",$nl)}
       
        {concat($tab,$tab,$tab,$tab,$open-curly,$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"releaseName",$quote,": ",$quote,data($c/AoGP_Release),$quote,",",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"segments",$quote,": ",$quote,data($c/AoGP_Segments),$quote,",",$nl,
          $tab,$tab,$tab,$tab,$tab,$quote,"type",$quote,": ",$quote,"aogp",$quote,$nl,
        $tab,$tab,$tab,$tab,$closed-curly,$nl)}
      {concat($tab,$tab,$tab,$closed-square,",",$nl)}    
    </publicReleases>

    <tapeNumber>
      {concat($tab,$tab,$tab,$quote,"tapeNumber",$quote,": ",$quote,xs:string($tapeID),$quote,",",$nl)}
    </tapeNumber>
    
    <title>
      {concat($tab,$tab,$tab,$quote,"title",$quote,": ",$quote,$conversation,$quote,$nl)}
    </title>    
    
  {concat($tab,$tab,$closed-curly,",",$nl)}
  </conversation>
}
&#9;&#93;
&#125;</nixonTapes>