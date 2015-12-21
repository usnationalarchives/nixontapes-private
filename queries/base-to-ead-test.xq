import module namespace functx = 'http://www.functx.com' at 'http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq';

declare namespace xlink="http://www.w3.org/1999/xlink";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";   
declare option output:method "xml";
declare option output:omit-xml-declaration "no";
declare option output:indent "yes"; 


let $coll := collection("nixontapes-private-base")

for $c in $coll/root/row[not(contains(tapeNo,'test'))]
(: identifying information :)
  let $tapeID := data($c/tapeNo3Dig)
  let $convID := data($c/convNo3Dig)
  let $digitalID := data($c/filename)  
  let $conversation := normalize-space(concat("Conversation ",$tapeID,"-",$convID))

(: participants, with encodinganalog removed :)
  let $participants :=   
    for $p in $c/participantsWithLineBreaks/(persname|corpname)
    let $pEntry := functx:remove-attributes($p,('encodinganalog','normal'))
    return $pEntry

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
    (: base phrase, without 'including' :)
    else data($c/partNatLang | $c/participantsNaturalLanguage)

  (: case substitutions for middle of sentence :)
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
  
  (: dateDateRange :)
  
  let $dateDateRange :=
  
    (: 1 :)
    if ($c/startDate eq $c/endDate and (data($dateCert) eq "certain"))
    then
      data($c/startDate-NaturalLanguage)
        else  
        (: 2 :)
        if (data($dateCert) eq "certain")
    then
      concat(
        data($c/startDate-NaturalLanguage),
        " to ",
        data($c/endDate-NaturalLanguage)
      )
        else 
        (: 3 :)
        concat("at an unknown date between ",data($c/startDate-NaturalLanguage)," and ",data($c/endDate-NaturalLanguage)) 
  
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

  where data($conversation) eq "Conversation 040-001"
  order by $conversation       
  return

<ead xmlns="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="urn:isbn:1-931666-22-9 http://www.loc.gov/ead/ead.xsd">

	<eadheader audience="internal" countryencoding="iso3166-1" dateencoding="iso8601" langencoding="iso639-2b"
		repositoryencoding="iso15511" relatedencoding="DC" scriptencoding="iso15924">
    
  <eadid encodinganalog="856$u" countrycode="US" mainagencycode="US-DNA"
			publicid="-//Richard Nixon Presidential Library and Museum//TEXT (US::US-DNA::{$tapeID}-{$convID}::White House Tapes:
			Conversation {$tapeID}-{$convID})//EN"
			url="http://nixonlibrary.gov/tapes/37-wht-conversation-{$tapeID}-{$convID}.html"
			>37-wht-conversation-{$tapeID}-{$convID}</eadid>
     
     <filedesc>
			<titlestmt>

				<titleproper encodinganalog="Title" type="formal">White House Tapes: Conversation {$tapeID}-{$convID},
					<date>{$dateDateRange}</date></titleproper>
				<titleproper type="filing">Conversation {$tapeID}-{$convID}</titleproper>
				<subtitle>A Subject Log of the Conversation between {$descPart}</subtitle>

				<author encodinganalog="Creator">Richard Nixon Presidential Library and Museum</author>

				<sponsor>Description, encoding, and public access to the White House Tapes subject logs are supported by
					a partnership between the Richard Nixon Presidential Library and Museum and the Office of Innovation
					at the National Archives and Records Administration.<lb/> Digitization of the White House Tapes and
					related activities by the Richard Nixon Presidential Library and Museum are supported by the
					Preservation Programs Division and the Office of Innovation at the National Archives and Records
					Administration. </sponsor>

			</titlestmt>

			<publicationstmt>

				<publisher encodinganalog="Publisher">National Archives and Records Administration</publisher>
				<address>
				<addressline>College Park, MD</addressline>
			</address>

				<date normal="2015" encodinganalog="Date" type="publication">2015</date>

				<p id="findingAidCopyright">This finding aid is considered United States government works and, as such,
					is not eligible for copyright protection in the United States. Thus, this document may be treated as
					being in the public domain. <lb/>
					<extref xlink:href="http://creativecommons.org/publicdomain/zero/1.0/" xlink:show="new"
						xlink:title="Creative Commons License CC0">
						<extptr xlink:role="license" xlink:href="http://i.creativecommons.org/p/zero/1.0/88x31.png"
							xlink:show="embed" xlink:title="Creative Commons License 0"/>
					</extref>
					<lb/>
					<extref xlink:href="http://creativecommons.org/publicdomain/mark/1.0/" xlink:show="new"
						xlink:title="Public Domain Mark 1.0">
						<extptr xlink:role="license" xlink:href="http://i.creativecommons.org/p/mark/1.0/88x31.png"
							xlink:show="embed" xlink:title="Public Domain Mark"/>
					</extref>
				</p>

			</publicationstmt>

		</filedesc> 

		<profiledesc>
			<creation>Base machine-readable finding aid derived using XQuery scripts written by Amanda T. Ross<lb/>
				<date normal="2015-12-21">December 21, 2015</date>
			</creation>
			<langusage>Description is in <language encodinganalog="Language" langcode="eng" scriptcode="Latn"
					>English</language>
			</langusage>

			<descrules>This finding aid was prepared using <bibref><title render="italic">Describing Archives: A Content
						Standard</title>, <edition>2nd edition</edition>, <imprint><geogname>Chicago</geogname>:
							<publisher>Society of American Archivists</publisher>, <date type="publication"
							normal="2013">2013</date>
					</imprint></bibref> (DACS).</descrules>

		</profiledesc>
    
    		<!-- <revisiondesc>
			<change>
				<date normal="" type="addition"></date>
				<item></item>
			</change>
			<change>
				<date normal="" type="edit"></date>
				<item></item>
			</change>
		</revisiondesc> -->
    
	<frontmatter>
		<titlepage>
			<titleproper>White House Tapes: Conversation {$tapeID}-{$convID}, <date>{$dateDateRange}</date>
			</titleproper>

			<publisher>Richard Nixon Presidential Library and Museum</publisher>

			<date normal="2015" encodinganalog="Date" type="publication">2015</date>
			<p>Under United States copyright laws, the portions of this finding aid produced as part of United States
				federal government work are not subject to copyright restrictions.</p>

			<sponsor id="descriptiveSponsor" encodinganalog="536$a">Description, encoding, and public access to the
				White House Tapes subject logs are supported by a partnership between the Richard Nixon Presidential
				Library and Museum and the Office of Innovation at the National Archives and Records
				Administration.</sponsor>

			<sponsor id="digitizationSponsor" encodinganalog="536$a">Digitization of the White House Tapes and related
				activities by the Richard Nixon Presidential Library and Museum are supported by the Preservation
				Programs Division and the Office of Innovation at the National Archives and Records
				Administration.</sponsor>

		</titlepage>
	</frontmatter>
    
	</eadheader>
  
</ead>