(: import module namespace functx = 'http://www.functx.com' at 'http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq'; :)


import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

declare namespace xlink="http://www.w3.org/1999/xlink";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";   
declare option output:method "xml";
declare option output:omit-xml-declaration "no";
declare option output:indent "yes"; 

let $coll := collection("nixontapes-private-base")

for $c in $coll/root/row[not(contains(tapeNo,'test'))]

let $my-doc :=  

(: identifying information :)
  let $tapeID := data($c/tapeNo3Dig)
  let $convID := data($c/convNo3Dig)
  let $digitalID := data($c/filename)
  let $audiotapeNARAid := data($coll/audiotapes/catalogRecord[audiotapeNumber[matches(.,$tapeID)]]/attribute::naraID)
    
  let $conversation := normalize-space(concat("Conversation ",$tapeID,"-",$convID))

(: participants, with encodinganalog removed :)
(:  let $participants :=   
    for $p in $c/participantsWithLineBreaks/(persname|corpname)
    let $pEntry := functx:remove-attributes($p,('xmlns'))
    return $pEntry
:)

  let $participants := $c/participantsWithLineBreaks
  
  let $topicPers :=
  
    for $partPers in $participants//persname
    order by $partPers/. ascending
    return
      functx:update-attributes($partPers/.,(xs:QName('encodinganalog'),xs:QName('role')),('600$a','subject'))
    
    
  let $topicCorp :=
  for $partCorp in $participants/corpname
  order by $partCorp/. ascending
  return
    functx:update-attributes($partCorp/.,(xs:QName('encodinganalog'),xs:QName('role')),('610$a','subject'))
  
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
        
let $releaseChron := $c/releaseChron

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
            then "5-4"
            else
              if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part V"))
              then "5-5"
              else
                if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part III"))
                then "5-3"
                else
                  if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part II"))
                  then "5-2"
                  else
                    if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part I"))
                    then "5-1"
                    else
                      if (contains($c/releaseChron,"Cabinet"))   
                      then "cabinet"
                      else "!"
  
(: Chron Abbreviation :)

(: chron in sortable number :)
  let $chronCode :=
    if (contains($c/releaseChron,"First"))
    then "Chron I"
    else
      if (contains($c/releaseChron,"Second"))
      then "Chron II"
      else
        if (contains($c/releaseChron,"Third"))
        then "Chron III"
        else
          if (contains($c/releaseChron,"Fourth"))
          then "Chron IV"
          else
            if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part IV"))
            then "Chron V, Part IV"
            else
              if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part V"))
              then "Chron V, Part V"
              else
                if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part III"))
                then "Chron V, Part III"
                else
                  if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part II"))
                  then "Chron V, Part II"
                  else
                    if (contains($c/releaseChron,"Fifth") and contains($c/releaseChron,"Part I"))
                    then "Chron V, Part I"
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
  
  let $locationNaturalLanguage := $c/locationNaturalLanguage/text()

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
  
  (: startDateTime :)
  
  let $startDateTime := data($c/startDateTime)
  
 (: endDateTime :)
 
 let $endDateTime := data($c/endDateTime)
  
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
        concat("on an unknown date between ",data($c/startDate-NaturalLanguage)," and ",data($c/endDate-NaturalLanguage)) 
 
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


let $locationCodeLower := lower-case($c/locationCode)

let $deedReviewChron :=

  if (contains($c/releaseChron,"Fifth"))
    then $coll/deedReview/chron5/p
      else $coll/deedReview/chron1-4/p

let $roomRecordingHistory :=
  $coll/roomDescriptions/room[attribute::id[matches(.,$locationCodeLower)]]/bioghist

let $roomScopeContentRecordingNotes := $coll/roomDescriptions/room[attribute::id[matches(.,$locationCodeLower)]]/scopecontent[attribute::id[matches(.,"recordingNotes")]]

let $roomAbstract := $coll/roomDescriptions/room[attribute::id[matches(.,$locationCodeLower)]]/abstract

let $roomArchrefSeries := $coll/roomDescriptions/room[attribute::id[matches(.,$locationCodeLower)]]/archref

let $roomArchrefAdded := functx:add-attributes($roomArchrefSeries,xs:QName('xlink:href'),"37-wht-series-{$locationCodeLower}.xml")

let $releaseDate-MachineReadable := $c/releaseDate-MachineReadable

let $releaseDate-NatLang := $c/(releaseDate-NatLang|releaseDateNatLang)

let $sDate := $c/startDate-NaturalLanguage

let $eDate := $c/endDate-NaturalLanguage

let $latitude := $c/latitude

let $longitude := $c/longitude

let $dateOfEAD-NL := concat(functx:month-name-en(current-date())," ",day-from-date(current-date()),", ",year-from-date(current-date()))

let $dateOfEAD-MR := functx:substring-before-match(xs:string(data(current-date())),"-0[0-9]:00")

  order by $conversation       
  return

<ead xmlns="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="urn:isbn:1-931666-22-9 http://www.loc.gov/ead/ead.xsd">

	<eadheader audience="internal" countryencoding="iso3166-1" dateencoding="iso8601" langencoding="iso639-2b"
		repositoryencoding="iso15511" relatedencoding="DC" scriptencoding="iso15924">
    
  <eadid encodinganalog="856$u" countrycode="US" mainagencycode="US-DNA"
			publicid="-//us::us-dna::37-wht-conversation-{$tapeID}-{$convID}//National Archives and Records Administration::Richard Nixon Presidential Library and Museum::White House Tapes::Conversation {$tapeID}-{$convID})//EN"
			url="http://nixonlibrary.gov/tapes/audiotape-{$tapeID}/37-wht-conversation-{$tapeID}-{$convID}.xml">
      37-wht-conversation-{$tapeID}-{$convID}</eadid>
     
     <filedesc>
			<titlestmt>

				<titleproper encodinganalog="Title" type="formal">White House Tapes: Conversation {$tapeID}-{$convID}, <date>{$dateDateRange}</date></titleproper>
				<titleproper type="filing">Conversation {$tapeID}-{$convID}</titleproper>
				<subtitle>A Subject Log of the Conversation between {$descPart}</subtitle>

				<author encodinganalog="Creator">Richard Nixon Presidential Library and Museum</author>

				<sponsor>Description, encoding, and public access to the White House Tapes subject logs are supported by a partnership between the Richard Nixon Presidential Library and Museum and the Office of Innovation at the National Archives and Records Administration.
        <lb/> 
        Digitization of the White House Tapes and related activities by the Richard Nixon Presidential Library and Museum are supported by the Preservation Programs Division and the Office of Innovation at the National Archives and Records Administration.</sponsor>

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
						<extptr xlink:role="license" xlink:href="http://i.creativecommons.org/p/zero/1.0/88x31.png" xlink:show="embed" xlink:title="Creative Commons License 0"/>
					</extref>
					<lb/>
					<extref xlink:href="http://creativecommons.org/publicdomain/mark/1.0/" xlink:show="new"
						xlink:title="Public Domain Mark 1.0">
						<extptr xlink:role="license" xlink:href="http://i.creativecommons.org/p/mark/1.0/88x31.png" xlink:show="embed" xlink:title="Public Domain Mark"/>
					</extref>
				</p>

			</publicationstmt>

		</filedesc> 

		<profiledesc>
			<creation>Base machine-readable finding aid derived using XQuery scripts written by Amanda T. Ross<lb/>
				<date normal="{$dateOfEAD-MR}">{$dateOfEAD-NL}</date>
			</creation>
			<langusage>Description is in <language encodinganalog="Language" langcode="eng" scriptcode="Latn"
					>English</language>
			</langusage>

			<descrules>This finding aid was prepared using <bibref><title render="italic">Describing Archives: A Content Standard</title>, <edition>2nd edition</edition>, <imprint><geogname>Chicago</geogname>: <publisher>Society of American Archivists</publisher>, <date type="publication" normal="2013">2013</date> </imprint></bibref> (DACS).</descrules>

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
    
	</eadheader>
  
  	<frontmatter>
		<titlepage>
			<titleproper>White House Tapes: Conversation {$tapeID}-{$convID}, <date>{$dateDateRange}</date>
			</titleproper>

			<publisher>Richard Nixon Presidential Library and Museum</publisher>

			<date normal="2015" encodinganalog="Date" type="publication">2015</date>
			<p>Under United States copyright laws, the portions of this finding aid produced as part of United States federal government work are not subject to copyright restrictions.</p>

			<sponsor id="descriptiveSponsor" encodinganalog="536$a">Description, encoding, and public access to the White House Tapes subject logs are supported by a partnership between the Richard Nixon Presidential Library and Museum and the Office of Innovation at the National Archives and Records Administration.</sponsor>

			<sponsor id="digitizationSponsor" encodinganalog="536$a">Digitization of the White House Tapes and related esidential Library and Museum are supported by the Preservation Programs Division and the Office of Innovation at the National Archives and Records Administration.</sponsor>

		</titlepage>
	</frontmatter>
  
  	<archdesc level="otherlevel" otherlevel="item" relatedencoding="MARC21">
		<did>
			<head>Descriptive Summary</head>
			<unittitle label="Title" encodinganalog="245$a">White House Tapes: Conversation {$tapeID}-{$convID}</unittitle>
			<unitdate label="Date" encodinganalog="245$d" normal="1971-02-16/1971-02-16" type="inclusive" certainty="supplied">{$dateDateRange}</unitdate>
			<origination id="participants" label="Participants">
      {$participants/child::*}
      </origination>
			<origination id="isPartOf" label="Parent Materials (Is Part Of)">
				<archref id="parentCollection" xlink:href="37-wht">
        
					<unitid identifier="http://catalog.archives.gov/id/597542" type="naId" label="National Archives Identifier">597542</unitid>
					<unittitle id="collectionTitle" label="Collection">White House Tapes</unittitle>
				</archref>

				<archref id="parentSeries" xlink:href="37-wht-audiotape-{$locationCodeLower}">
					{$roomArchrefSeries/child::node()}
				</archref>
        
        <archref id="parentFile" xlink:href="37-wht-audiotape-{$tapeID}">
					<unitid identifier="http://catalog.archives.gov/id/{$audiotapeNARAid}" type="naId" label="National Archives Identifier">{$audiotapeNARAid}</unitid>
					<unittitle id="audiotapeTitle" label="File">Audiotape {$tapeID}</unittitle>
          
				</archref>
			</origination>
			<!-- <physdesc label="Duration">
				<extent encodinganalog="300$a" type="totalTime" unit="hhmmss">00:00:00</extent>
			</physdesc> -->
			<repository label="Repository">
				<corpname source="nixonTapesIndex" authfilenumber="37-wht-eac-00003482" normal="RNPLM">Richard Nixon Presidential Library and Museum</corpname>
			</repository>
			<!-- <unitid countrycode="US" repositorycode="US-DNA" encodinganalog="099$a" identifier="######" type="naId" label="National Archives Identifier">######</unitid> -->
			<unitid countrycode="US" repositorycode="US-DNA" encodinganalog="099$a" type="nixonTapesID"
				label="Local Call Number">{$c/locationCode} {$tapeID}-{$convID}</unitid>
			<!-- <container id="wht-audiotape-{$tapeID}_track-{$trackNo}" type="track" label="Track">{$trackNo}</container> -->
			<abstract id="summaryAbstract" encodinganalog="520$a" label="Abstract (Conversation Summary)">{$statement} Topics of conversation included ....</abstract>
			<!-- <abstract id="biographicalAbstract" encodinganalog="545$a" label="Abstract (Biographical Context)">[Bio/Hist sentence]</abstract> -->
			{$roomAbstract}
      <langmaterial label="Language of Conversation" encodinganalog="546$a">Material in <language
					langcode="eng" scriptcode="Latn">English</language></langmaterial>
		</did>
		<odd id="conversationDateTime" encodinganalog="518$d" altrender="{$startDateTime}/{$endDateTime}" type="eventNote">
			<p id="startDate">{data($sDate)}</p>
			<p id="endDate">{data($eDate)}</p>
			<p id="dateCertainty">{$dateCert}</p>
			<p id="startTime">{$sTime}</p>
			<p id="endTime">{$eTime}</p>
			<p id="timeCertainty">{$timeCert}</p>
		</odd>
		   
		{$roomRecordingHistory}
		   
		<!-- possibly import brief biogHist notes for participants -->
		   
		<scopecontent>
			
			<head>Collection Overview</head>
			<scopecontent id="conversationSummary">
				<head>Conversation Summary</head>
				<p>{$statement}</p>
				<p>Topics of conversation included ...</p>
			</scopecontent>
			
			{$roomScopeContentRecordingNotes}
			
			<arrangement>
				<head>Collection Arrangement</head>
				
				<arrangement id="subjectLogArrangement">
					<head>About the Subject Log</head>
					<p>To assist listeners in understanding the conversation and finding segments pertinent to their own interests, a team of archivists has created a Subject Log, which outlines major topics, names, and organizations in sequential order.</p>
					<list id="loggingNotes" type="marked">
						<item>Logs include action statements, which indicate when someone entered or exited a room. Action statements are underlined.</item> <item>If a conversation recorded in one of the offices also captures a telephone conversation, a cross-reference to the corresponding telephone recording is provided.</item>
						<item>If a telephone recording also captures a conversation taking place in one of the offices, a cross-reference to the corresponding room conversation is provided.</item>
						<item>Logs indicate which portions, if any, were reviewed under the <title authfilenumber="deedOfGift2007">2007 Deed of Gift</title>.</item>
						<item>In some cases, the Watergate Special Prosecution Force or court-ordered mandates resulted in a transcript of the entire conversation or portions of conversation. For these portions, archivists have provided a citation to the related transcript<!--, in place of subject logging -->.</item>
					</list>
				</arrangement>
				
				<arrangement id="audioFormat">
					<head>Audio Format</head>
					<p>This conversation was recorded to audiotape on a system maintained by the United States Secret Service. The National Archives transferred the original audiotape to Digital Audio Tape (DAT), which, in turn, was later converted to digital audio files.</p>
          <p>The audio recording of this conversation has been digitized and made available to the public. <!-- For portions that have been deemed withdrawn (withheld), a _ten-second tone_ replaces the removed portion. --></p>
						<note id="digitalRemastering" label="Digital Remastering Project">
						<p>The White House Tapes are currently undergoing preservation remastering, from which digital derivatives will be made and released to the public as appopriate.</p>
						</note>
					<p/>
				</arrangement>
				
			</arrangement>
			
		</scopecontent>
		<controlaccess> 
			
			<controlaccess id="PRMPAdeedCategories">
				<head>Determination Categories</head>
				<p>These processing categories are governed by the <title
					xlink:href="http://www.archives.gov/presidential-libraries/laws/1974-act.html" xlink:show="new"
					authfilenumber="PRMPA">Presidential Recordings and Materials Preservation Act of 1974 (PRMPA)</title> and the 2007 Deed of Gift. These categories are based upon the constitutional and statutory duties of the President of the United States, as well as the Watergate investigation.</p>
				<!--
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01">Abuse of Governmental Powers / Watergate</function>
          <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01-01">Misuse of Government Agencies</function>
          <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01-02">Watergate Break-In</function>
          <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01-03">Watergate Cover-Up</function>
          <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01-04">Campaign Practices</function>
          <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01-05">Obstruction of Justice</function>
          <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01-07">Milk Fund</function>
          <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01-08">Hughes-Rebozo Investigation</function>
          <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01-09">Emoluments and Tax Evasion</function>
          <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination01-10">International Telephone and Telegraph</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination02">Administrative Powers</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination03">Department Policies, Agency Policies, and Executive Decisions</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination04">Legislative Leader</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination05">Presidential Foreign Relations Power</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination06">Commander-in-Chief</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination07">White House Internal or Institutional Organization</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination08">Ceremonial Duties of the President</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination09">Official Travel, Head of State, and Foreign Visits</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination10">Presidential Statements</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination11">Presidential Appointments and Personnel Management</function>
        <function encodinganalog="657$a" source="PRMPA" authfilenumber="determination12">White House Entertainment and Social Affairs</function>
        
        <function encodinganalog="657$a" source="deedOfGift2007" authfilenumber="deedOfGift2007">Deed of Gift, 2007</function>
        -->
			</controlaccess>
			
			<controlaccess id="recordingLocation">
				<head>Location of Recording</head>
				<geogname encodinganalog="518$p" normal="{$latitude}, {$longitude}" source="GeoHack" role="location">{$c/locationNaturalLanguage}</geogname>
			</controlaccess>
			
			<controlaccess id="relatedTopics">
				<head>Related Topics</head>
        
        <corpname encodinganalog="610" role="subject" rules="rda" source="lcnaf" authfilenumber="http://id.loc.gov/authorities/names/n79007288">United States. President (1969-1974 : Nixon)</corpname>
        
        <genreform encodinganalog="655" rules="rda" source="lcnaf" authfilenumber="http://id.loc.gov/authorities/subjects/sh85101069">Audiotapes</genreform>
        
        <geogname encodinganalog="651" role="subject" rules="rda" source="lcsh" authfilenumber="http://id.loc.gov/authorities/subjects/sh85140471">United States -- Politics and government -- 1969-1974</geogname>
        
        <persname encodinganalog="600" role="subject" rules="rda" source="lcnaf" authfilenumber="http://id.loc.gov/authorities/names/n79018757">Nixon, Richard M. (Richard Milhous), 1913-1994</persname>
        
        <subject encodinganalog="650" rules="rda" source="lcsh" authfilenumber="http://id.loc.gov/authorities/subjects/sh85106465">Presidents -- United States</subject>
			
			</controlaccess>
            
			<controlaccess id="topicsOfConversation">
				<head>Topics of Conversation</head>
                
				<controlaccess id="peopleDiscussed">
          <head>People</head>
          <!-- Remove xmlns -->
          {$topicPers/.}
				</controlaccess>        
                
				<controlaccess id="placesDiscussed">
          <head>Places</head>
				</controlaccess>

				<controlaccess id="organizationsDiscussed">
          <head>Organizations</head>
          <!-- Remove xmlns -->
          {$topicCorp/.}
				</controlaccess>  
        
				<controlaccess id="topicsDiscussed">
          <head>Topics</head>
				</controlaccess>  
        
			</controlaccess>
			
		</controlaccess>
		
		<!-- Use separated materials and related materials clips here to enter in information. -->
		
		<!-- Indicate alternative formats / digitized audio below -->

		<altformavail type="audio">
		<head>Digitized Audio</head>
		
			<altformavail id="audiofile-37-wht-conversation-{$tapeID}-{$convID}.mp3" type="mp3" encodinganalog="530$a">
				<p>The original audio has been converted to digital format and is available to the public as an MP3 file.</p>
			</altformavail>
			
			<altformavail id="audiofile-37-wht-conversation-{$tapeID}-{$convID}.wav" type="bwf" encodinganalog="530$a">
				<p>The original audio has been converted to digital format and is available to the public as a Broadcast WAVE Format (BWF) file.</p>
			</altformavail>
			
		</altformavail>

		
		<dsc type="combined">
			<head>Conversation Subject Log</head>
			<!-- Logging here -->
		</dsc>
		
		<descgrp type="admininfo">
			<head>Administrative Information</head>
			<accessrestrict>
				<head>Access Restrictions</head>
				<!-- if/then accessrestrict
				
				1) <accessrestrict encodinganalog="506" type="accessUnrestricted">
					<p>This conversation has no restrictions and is fully open to the public.</p>
				</accessrestrict>
				
				2) <accessrestrict encodinganalog="506" type="accessPartiallyRestricted">
					<p>Portions of this conversation are closed to the public: _ withdrawal(s) for _.</p>
				</accessrestrict>
				
				3) <accessrestrict encodinganalog="506" type="accessFullyRestricted">
					<p>This conversation is closed to the public in its entirety: 1 withdrawal for _.</p>
				</accessrestrict>
				-->
				
				<p>Access is governed by the <title xlink:href="http://www.archives.gov/presidential-libraries/laws/1974-act.html" xlink:show="new"
 authfilenumber="PRMPA">Presidential Recordings and Materials Preservation Act of 1974 (PRMPA)</title>; <title xlink:href="http://go.usa.gov/3zNZJ" xlink:show="new">Nixon Public Access Regulations 36 CFR 1275 of the NARA Code of Federal Regulations</title>, including the 1996 Tapes Settlement Agreement (Appendix A); and protocols related to classified national security information, including <title xlink:href="https://www.federalregister.gov/articles/2010/01/05/E9-31418/classified-national-security-information" xlink:show="new">Executive Order 13526</title>.</p>
				
				<p>For more information, please contact the Tapes Team at the <corpname source="nixonTapesIndex" authfilenumber="37-wht-eac-00003482" normal="RNPLM">Richard Nixon Presidential Library and Museum</corpname>: <extref xlink:actuate="onLoad" xlink:href="mailto:nixon@nara.gov" xlink:type="simple" >nixon@nara.gov</extref> or (301) 837-3290.</p>
			</accessrestrict>
			
			<userestrict encodinganalog="540">
				<head>Copyright Notice</head>
				
				<p id="ccZero">
					<extref id="cc0" xlink:href="http://creativecommons.org/publicdomain/zero/1.0/" xlink:show="new"
						xlink:title="Creative Commons License CC0">
						<extptr xlink:role="license" xlink:href="http://i.creativecommons.org/p/zero/1.0/88x31.png" xlink:show="embed" xlink:title="Creative Commons License 0"/>
					</extref>
				</p>
				
				<p id="publicDomain">
					<extref id="pdm" xlink:href="http://creativecommons.org/publicdomain/mark/1.0/" xlink:show="new" xlink:title="Public Domain Mark 1.0">
						<extptr xlink:role="license" xlink:href="http://i.creativecommons.org/p/mark/1.0/88x31.png" xlink:show="embed" xlink:title="Public Domain Mark"/>
					</extref>
				</p>
				
				<p>The materials processed and released under the <title xlink:href="http://www.archives.gov/presidential-libraries/laws/1974-act.html" xlink:show="new" authfilenumber="PRMPA">Presidential Recordings and Materials Preservation Act of 1974 (PRMPA)</title> are considered United States government works and, as such, are not eligible for copyright protection in the United States. Thus, they may be treated as being in the public domain. Materials processed and released under the 2007 Deed of Gift are also considered property of the United States and therefore may be treated as being in the public domain.</p>
        <p>Unless expressly stated otherwise, the organization that made this item available makes no warranties about the item and cannot guarantee the accuracy of this rights statement. You are responsible for your own use.</p>
        <p>According to 36 C.F.R. &#167; 1254.62, you are responsible for obtaining any necessary permission for use, copying, and publication from copyright holders and for any other applicable provisions of the Copyright Act (Title 17, United States Code).</p>
				<p>Certain individuals recorded may claim rights in their recorded voices, under state law. Use of such recorded voices found in this conversation may be subject to these claims. You may need to obtain other permissions for your intended use. For example, other rights such as publicity, privacy, or moral rights may limit how you use the material.</p>
        <p>Any materials used for academic research or otherwise should be fully credited with the source.</p>
			</userestrict>
			
			<prefercite>
				<head>Preferred Citation</head>
					<p>Conversation {$tapeID}-{$convID}<!-- (National Archives Identifier ######) -->, Audiotape {$tapeID}, {$locationNaturalLanguage} Sound Recordings, White House Tapes, Richard Nixon Presidential Library and Museum, National Archives and Records Administration.</p>
			</prefercite>
			
			<acqinfo encodinganalog="541">
				<head>Acquisitions Information</head>
				
				<acqinfo id="acqPRMPA">
					<head>Presidential Recordings and Materials Preservation Act of 1974</head>
					<p>The Nixon-era White House Tapes are subject to the Presidential Recordings and Materials Preservation Act of 1974 (PRMPA). PRMPA, which applies only to the Nixon Presidential Materials, stipulates that those materials relevant to the understanding of Abuse of Governmental Power and Watergate are to be processed and released to the public prior to the release of all other materials. Materials related to the Abuse of Governmental Power and the constitutional and statutory duties of the President and his White House staff are retained by the National Archives. PRMPA mandated the promulgation of access restrictions for the processing of the Nixon Tapes.</p>
            <p>The resulting Nixon Public Acccess Regulations 36 CFR 1275 state that the National Archives must segregate and return to the estate of former President Nixon those materials identified as purely &quot;personal-private&quot; or &quot;personal-political,&quot; and unrelated to the President&#39;s constitutional and statutory duties. This conversation has been processed under these regulations.</p>
				</acqinfo>
				
				<acqinfo id="acqDeed2007">
					<head>2007 Deed of Gift</head>
					<p>However, in 2007, the estate of Richard Nixon negotiated a Deed of Gift with the Richard Nixon Presidential Library and Museum. By this agreement, materials deemed &quot;personal-political&quot; have been deeded back to the National Archives for release to the public. Materials originally deemed &quot;person-private&quot; have been deeded back to the National Archives, with the exception of materials concerning the medical history or non-Watergate-related personal finances of Richard Nixon or the non-public activities of the First Family.</p>
            
					{$deedReviewChron}
          
				</acqinfo>
				
			</acqinfo>
			
			<processinfo encodinganalog="583$z">
				<head>Processing Information</head>
				<processinfo type="chronRelease">
					<p>Processed by the <corpname encodinganalog="583$k" source="nixonTapesIndex" authfilenumber="37-wht-eac-00004831" normal="Richard Nixon Presidential Library and Museum. Tapes Team">Tapes Team of the Richard Nixon Presidential Library and Museum</corpname>, as part of the <archref id="chronRelease" xlink:href="37-wht-chron{$chronNum}" xlink:show="new">
              <unittitle encodinganalog="583$b">{data($releaseChron)}</unittitle> (<unitid id="chron{$chronNum}">{$chronCode}</unitid>)
						</archref>, and released on <date encodinganalog="583$c" normal="{$releaseDate-MachineReadable}" type="releaseDate">{data($releaseDate-NatLang)}</date>.</p>
				</processinfo>
				
				<note id="supportNote">
					<p>Description, encoding, and public access to the White House Tapes subject logs are supported by a partnership between the <corpname source="nixonTapesIndex" role="repository" authfilenumber="37-wht-eac-00003482" normal="RNPLM">Richard Nixon Presidential Library and Museum</corpname> and the <corpname role="sponsor" source="nixonTapesIndex" authfilenumber="37-wht-eac-00004829" normal="United States. National Archives and Records Administration. Office of Innovation">Office of Innovation</corpname> at the National Archives and Records Administration.</p>
          <p>Digitization of the White House Tapes and related activities by the Richard Nixon Presidential Library and Museum are supported by the <corpname role="sponsor" source="nixonTapesIndex" authfilenumber="37-wht-eac-00004830" normal="United States. National Archives and Records Administration. Preservation Programs Division">Preservation Programs Division</corpname> and the <corpname role="sponsor" source="nixonTapesIndex" authfilenumber="37-wht-eac-00004829" normal="United States. National Archives and Records Administration. Office of Innovation">Office of Innovation</corpname> at the National Archives and Records Administration.</p>
				</note>
				
				<note id="encodingHistory">
					<p>Encoded by Amanda T. Ross, <date normal="{$dateOfEAD-MR}">{$dateOfEAD-NL}</date></p>
					<!-- Edited by ?, Mm yyyy -->
				</note>
			</processinfo>
		</descgrp>
	</archdesc>
  
</ead>

return

let $audiotape := $c/tapeNo3Dig

(: Relative file path [parent of parent directory] :)
(: let $dir := concat(file:parent(file:parent(static-base-uri())),"/37-wht/findingaids/audiotape-",$audiotape,"/")
:)

(: Experiment with filepath separators :)
let $dir := concat(file:parent(file:parent(static-base-uri())),file:dir-separator(),"37-wht",file:dir-separator(),"findingaids",file:dir-separator(),"audiotape-",$audiotape,file:dir-separator())

let $filename := concat($c/filename,".xml")

(: join directory path + file name; adjust to native file path format for OS
let $path := file:path-to-native(concat($dir, $filename))
 :)
 
let $path := concat($dir, $filename)
where data($audiotape) ge "001" and data($audiotape) le "002"

return file:write($path, $my-doc)