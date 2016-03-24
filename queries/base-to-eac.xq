xquery version "1.0";

(:~
 : Script Name: Base to EAC
 : Author: Amanda Ross
 : Script Version: 1.0
 : Date: 2016 January
 : Copyright: Public Domain
 : Proprietary XQuery Extensions Used: None
 : XQuery Specification: January 2007
 : Script Overview: This script converts base/source data about the Nixon-era White House Tapes participants to preliminary EAC-CPF records
:)

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

declare namespace xlink="http://www.w3.org/1999/xlink";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";   
declare option output:method "xml";
declare option output:omit-xml-declaration "no";
declare option output:encoding "UTF-8";
declare option output:indent "yes"; 

let $coll := collection("nixontapes-private-base")

for $n in $coll/nixonNames/participant

let $id := $n//attribute::authfilenumber

let $indirect := data($n/indirectOrder)
let $direct := data($n/directOrder)
let $nDirect :=
    if (exists($n/corpname))
    then concat("Representatives of the ",replace($direct,'\.','&apos;s'))
    else $direct

let $entityType :=
  if (exists($n/persname))
  then "person"
  else "corporateBody"

let $marcfield :=
  if ($entityType eq "person")
  then "marcfield:100"
  else "marcfield:110"

let $orgParts :=
  if (exists($n/corpname))
  then 
    let $orgSeq :=
      for $token in tokenize($direct,"\. ")
      return <part>{$token}</part> 
    for $p in $orgSeq
    let $position := index-of($orgSeq,$p)
    let $subfield :=
      if ($position = 1)
      then "marcfield:110$a"
      else "marcfield:110$b"
    return <part xmlns="urn:isbn:1-931666-33-4" localType="{$subfield}">{data($p)}</part>

  else null

let $familyName := data($n/lastName)   
let $familyNameEntry :=
  if (exists($n/lastName))
  then 
    <part xmlns="urn:isbn:1-931666-33-4" localType="familyName">{$familyName}</part>
  else null
  
let $givenName := data($n/firstPart)
let $givenNameEntry :=
  if (exists($n/firstPart))
  then 
    <part xmlns="urn:isbn:1-931666-33-4" localType="givenName">{$givenName}</part>
  else null 

let $nickname := data($n/nickname)
let $nicknameEntry :=
  if (exists($n/nickname))
  then 
    <part xmlns="urn:isbn:1-931666-33-4" localType="nickname">{$nickname}</part>
  else null
  
let $maidenName := data($n/maidenName)
let $maidenNameEntry :=
  if (exists($n/maidenName))
  then 
    <part xmlns="urn:isbn:1-931666-33-4" localType="maidenName">{$maidenName}</part>
  else null

let $generationalMarker := data($n/generationalMarker)  
let $generationalMarkerEntry :=
  if (exists($n/generationalMarker))
  then 
    <part xmlns="urn:isbn:1-931666-33-4" localType="generationalMarker">{$generationalMarker}</part>
  else null

let $titleHonorific := data($n/titleHonorific)
let $titleHonorificEntry :=
  if(exists($n/titleHonorific))
  then 
    <part xmlns="urn:isbn:1-931666-33-4" localType="titleHonorific">{$titleHonorific}</part>
  else null
  
let $marriedDesignator := data($n/marriedMrs)
let $marriedDesignatorEntry :=
  if (exists($n/marriedMrs))
  then 
    <part xmlns="urn:isbn:1-931666-33-4" localType="marriedDesignator">{$marriedDesignator}</part>
  else null
 
let $nixonEntry :=  
  if (exists($n/persname))
  then
    <nameEntry xmlns="urn:isbn:1-931666-33-4" localType="nixonNames/nameEntry/#parsed" scriptCode="Latn" xml:lang="en">
      {$familyNameEntry}
      {$givenNameEntry}
      {$nicknameEntry}
      {$maidenNameEntry}
      {$generationalMarkerEntry}
      {$titleHonorificEntry}
      {$marriedDesignatorEntry}
      <alternativeForm>NixonTapesIndex</alternativeForm>
    </nameEntry>
  else
    <nameEntry xmlns="urn:isbn:1-931666-33-4" localType="marcfield:110" scriptCode="Latn" xml:lang="en">
      {$orgParts}
      <alternativeForm>NixonTapesIndex</alternativeForm>
    </nameEntry>


let $lcnaf :=
  if (exists($n/persname))
  then
  <nameEntry xmlns="urn:isbn:1-931666-33-4" localType="marcfield:100" scriptCode="Latn" xml:lang="en">
    <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:100$a"></part>
    <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:100$b"></part>
    <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:100$c"></part>
    <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:100$q"></part>
    <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:100$d"></part>
    <authorizedForm>lcnaf</authorizedForm>
    <!-- 
    <authorizedForm>VIAF</authorizedForm>
    <authorizedForm>USNARA-LCDRG</authorizedForm>
     -->
  </nameEntry>
  else

    <nameEntry xmlns="urn:isbn:1-931666-33-4" localType="marcfield:110" scriptCode="Latn" xml:lang="en">
      <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:110$a"></part>
      <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:110$b"></part>
      <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:110$b"></part>
      <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:110$n"></part>
      <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:110$d"></part>
      <part xmlns="urn:isbn:1-931666-33-4" localType="marcfield:110$c"></part>
      <authorizedForm>lcnaf</authorizedForm>
      <!-- 
      <authorizedForm>VIAF</authorizedForm>
      <authorizedForm>USNARA-LCDRG</authorizedForm>
       -->
    </nameEntry>

let $genderRecord := $coll/csv/record[matches(data(Identifier),data($id))]
let $genderTerm := data($genderRecord/genderTerms)
let $genderScore := data($genderRecord/scale)
let $genderChange := 
  if(exists($n/marriedMrs))
  then <p xmlns="urn:isbn:1-931666-33-4">For name entries qualified by the 'Mrs.' designator, NamSor originally scored the names based on the husband&apos;s name, generating 'male.' The gender term was flipped manually to 'female.'</p>
  else null

let $genderEntry :=
  if (exists($n/persname))
  then
      <localDescriptions xmlns="urn:isbn:1-931666-33-4" localType="http://viaf.org/viaf/terms#gender">
        <localDescription xmlns="urn:isbn:1-931666-33-4" localType="marcfield:375">
          <term vocabularySource="namSor">{$genderTerm}</term>
          <descriptiveNote>
            <p>This gender term has been predicted based on given and family names using NamSor gender analytics, which generated a certainty scale of <span localType="certainty">{$genderScore}</span>.</p>
            {$genderChange}
          </descriptiveNote>
                </localDescription>
      </localDescriptions>
  else null

let $rowMatch := $coll/root/row[participantsWithLineBreaks/(persname|corpname)/attribute::authfilenumber=$id]
  
let $conversations :=
  for $row in $rowMatch
  let $c := data($row/filename)
  let $cTitle := concat("Conversation ",data($row/tapeNo3Dig),"-",data($row/convNo3Dig)) 
  order by $c
  return 
<resourceRelation xmlns="urn:isbn:1-931666-33-4" resourceRelationType="creatorOf" xlink:arcrole="nixonTapes/#participantIn" xlink:href="{$c}">
  <relationEntry>White House Tapes: {$cTitle}</relationEntry>
  <descriptiveNote>
    <p>{$nDirect} participated in {$cTitle} on the White House Tapes of the Nixon Administration</p>
  </descriptiveNote>
</resourceRelation>

let $corporateRelations :=
  for $cpfCorp in functx:distinct-deep($coll/root/row[participantsWithLineBreaks/(persname|corpname)/attribute::authfilenumber=$id]/participantsWithLineBreaks/corpname)
  let $cpfCorpID := data($cpfCorp/attribute::authfilenumber)
  let $cpfCorpName := data($cpfCorp)
  let $cpfCorpDirect := data($coll/nixonNames/participant[(persname|corpname)/attribute::authfilenumber=$cpfCorpID]/directOrder)
  let $cpfCorpFreq := count($rowMatch[participantsWithLineBreaks/(persname|corpname)/attribute::authfilenumber=$cpfCorpID])
  let $cpfCorpTimes :=
     if ($cpfCorpFreq eq 1)
     then ' time'
     else ' times'
  where not($id = $cpfCorpID)
  order by data($cpfCorpName)
  return
  <cpfRelation xmlns="urn:isbn:1-931666-33-4" cpfRelationType="associative" xlink:href="" xlink:type="simple">
  <relationEntry xmlns="urn:isbn:1-931666-33-4" localType="nixonTapes/#conversedWith" scriptCode="Latn" xml:lang="en">{$cpfCorpName}</relationEntry>
    <descriptiveNote>
      <p>{$nDirect} and representatives of the {$cpfCorpDirect} conversed <span localType="frequency">{$cpfCorpFreq}</span> {$cpfCorpTimes} on the White House Tapes of the Nixon Administration.</p>
    </descriptiveNote>
  </cpfRelation>
  
let $personRelations :=

  for $cpfPers in functx:distinct-deep($coll/root/row[participantsWithLineBreaks/(persname|corpname)/attribute::authfilenumber=$id]/participantsWithLineBreaks/persname)
  let $cpfPersID := data($cpfPers/attribute::authfilenumber)
  let $cpfPersName := data($cpfPers)
  let $cpfPersDirect := data($coll/nixonNames/participant[(persname|corpname)/attribute::authfilenumber=$cpfPersID]/directOrder)
  let $cpfPersNum := 
    for $cpfPersRow in $coll/root/row
    where $cpfPersRow/participantsWithLineBreaks[contains(.,$cpfPers)] and $cpfPersRow/participantsWithLineBreaks[contains(.,$n)]
    return $cpfPersRow/filename

  let $cpfPersFreq := count($rowMatch[participantsWithLineBreaks/(persname|corpname)/attribute::authfilenumber=$cpfPersID])
  let $cpfPersTimes :=
     if ($cpfPersFreq eq 1)
     then ' time'
     else ' times'

    where not($id = $cpfPersID)
    order by $cpfPersName
  return
  <cpfRelation xmlns="urn:isbn:1-931666-33-4" cpfRelationType="associative" xlink:href="{$cpfPersID}" xlink:type="simple">
  <relationEntry xmlns="urn:isbn:1-931666-33-4" localType="nixonTapes/#conversedWith" scriptCode="Latn" xml:lang="en">{$cpfPersName}</relationEntry>
  <descriptiveNote>
    <p>{$nDirect} and {$cpfPersDirect} conversed <span localType="frequency">{$cpfPersFreq}</span> {$cpfPersTimes} on the White House Tapes of the Nixon Administration.</p>
    </descriptiveNote>
  </cpfRelation>  

(: return :)
let $my-doc :=


<eac-cpf
    xmlns="urn:isbn:1-931666-33-4"
    xmlns:mads="http://www.loc.gov/mads/"
    xmlns:marcxml="http://www.loc.gov/MARC21/slim"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:snac="http://socialarchive.iath.virginia.edu/"
    xmlns:xlink="http://www.w3.org/1999/xlink">
    
    <control>
        <recordId>{data($n//attribute::authfilenumber)}</recordId>
        
        <maintenanceStatus>new</maintenanceStatus>
        
        <maintenanceAgency>
            <agencyCode>US-DNA</agencyCode>
            <agencyName>United States. National Archives and Records Administration</agencyName>
        </maintenanceAgency>

        <languageDeclaration>
            <language languageCode="eng">English</language>
            <script scriptCode="Latn">Latin alphabet</script>
        </languageDeclaration>
        
        <!-- Convention Declarations for Content Standards -->
        
        <conventionDeclaration>
            <abbreviation>RDA</abbreviation>
            <citation xlink:href="http://www.rda-jsc.org/rda.html" xlink:type="simple" lastDateTimeVerified="2016-02-29">Joint Steering Committee for the Development of RDA. RDA: Resource Description and Access. Chicago: American Library Association, 2010-</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>USNARA-LCDRG</abbreviation>
            <citation xlink:href="http://www.archives.gov/research/search/lcdrg/" xlink:type="simple" lastDateTimeVerified="2016-02-29">United States National Archives and Records Administration. Lifecycle Data Requirements Guide, 2nd edition. Washington, D.C.: U.S National Archives and Records Administration, 2002-.</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>DACS-2nd</abbreviation>
            <citation xlink:href="http://www2.archivists.org/standards/DACS" xlink:type="simple" lastDateTimeVerified="2016-02-29">Society of American Archivists. Describing Archives: A Content Standard, 2nd edition. Chicago: Society of American Archivists, 2013.</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>NixonTapesIndex</abbreviation>
            <citation xlink:href="https://nixonlibrary.gov/forresearchers/find/tapes" xlink:type="simple" lastDateTimeVerified="2016-02-29">Index to the White House Tapes of the Nixon Administration</citation>
        </conventionDeclaration>
        
        <!-- Convention Declarations for Controlled Vocabularies -->
        
        <conventionDeclaration>
            <abbreviation>lcsh</abbreviation>
            <citation xlink:href="http://id.loc.gov/authorities/subjects.html" xlink:type="simple" lastDateTimeVerified="2016-02-29">Library of Congress Subject Headings</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>lcnaf</abbreviation>
            <citation xlink:href="http://id.loc.gov/authorities/names.html" xlink:type="simple" lastDateTimeVerified="2016-02-29">Library of Congress Name Authority File</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>marc:relators</abbreviation>
            <citation xlink:href="http://id.loc.gov/vocabulary/relators.html" xlink:type="simple" lastDateTimeVerified="2016-02-29">MARC Code List for Relators</citation>
        </conventionDeclaration>
        
        <!-- Convention Declarations for Style Guides -->
        
        <conventionDeclaration>
            <abbreviation>CMOS-16th</abbreviation>
            <citation>University of Chicago Press. The Chicago Manual of Style, 16th edition. Chicago and London: The University of Chicago Press, 2010.</citation>
        </conventionDeclaration>
        
        <maintenanceHistory>
            <maintenanceEvent>
                <eventType>created</eventType>
                <eventDateTime>{current-dateTime()}</eventDateTime>
                <agentType>machine</agentType>
                <agent>base-to-eac.xq</agent>
                <eventDescription>Converted base/source XML data about the Nixon-era White House Tapes participants to EAC-CPF records using base-to-eac.xq script written by Amanda T. Ross of the United States National Archives and Records Administration</eventDescription>

            </maintenanceEvent>
            <!--
            <maintenanceEvent>
                <eventType>revised</eventType>
                <eventDateTime></eventDateTime>
                <agentType></agentType>
                <agent></agent>
                <eventDescription></eventDescription>
            </maintenanceEvent>
            <maintenanceEvent>
                <eventType>revised</eventType>
                <eventDateTime></eventDateTime>
                <agentType></agentType>
                <agent></agent>
                <eventDescription></eventDescription>
            </maintenanceEvent> 
            -->
        </maintenanceHistory>

        <!--         
        <sources>
            <source xlink:actuate="onRequest" xlink:show="new" xlink:type="simple" xlink:href="https://catalog.archives.gov/id/[NARA ID]" xlink:type="simple" lastDateTimeVerified="[Current Date]">
                <sourceEntry>National Archives and Records Administration Authority List: [NARA ID]</sourceEntry>
            </source>
            <source xlink:actuate="onRequest" xlink:show="new" xlink:type="simple" xlink:href="http://id.loc.gov/authorities/names/[LOC ID]" xlink:type="simple" lastDateTimeVerified="[Current Date]">
                <sourceEntry>Library of Congress Name Authority File: [LOC ID]</sourceEntry>
            </source>
            <source xlink:actuate="onRequest" xlink:show="new" xlink:type="simple" xlink:href="http://viaf.org/viaf/[VIAF ID]" xlink:type="simple" lastDateTimeVerified="[Current Date]">
                <sourceEntry>Virtual International Authority File: [VIAF ID]</sourceEntry>
            </source>
        </sources>
        -->        
    </control>
    
    <cpfDescription>
        
        <identity>
          <entityType>{$entityType}</entityType>
          
          <!-- Authorized Name Entries -->
          
          <nameEntry localType="{$marcfield}" scriptCode="Latn" xml:lang="en">
            <part localType="{$marcfield}$a">{$indirect}</part>
            <authorizedForm>NixonTapesIndex</authorizedForm>
          </nameEntry>

          {$lcnaf}
            
          <!-- Variant Name Entries -->
          
          <nameEntry localType="nixonNames" scriptCode="Latn" xml:lang="en">
            <part localType="directOrder">{$direct}</part>
            <alternativeForm>NixonTapesIndex</alternativeForm>
          </nameEntry>
            
          {$nixonEntry}
            
        </identity>
        
        <description>
            <!-- Insert Exist Dates, if relevant -->
            
            <!-- Insert Occupations, if relevant -->
            
            <!-- Insert Functions, if relevant -->

            <!-- Insert Language Used, if relevant -->

            <!-- Insert Gender, if relevant -->
            
            {$genderEntry}
            
            <!-- Insert Nationality, if relevant -->

            <!-- Insert Citizenship, if relevant -->
            
            <!-- Insert Title or Honorific, if relevant -->

            <!-- Insert Topical Subjects, if relevant -->

            <!-- Insert Associated Places, if relevant -->

            
            <biogHist>
                <!-- Abstract -->

                <abstract><!-- Insert Abstract --></abstract>
                
                <!-- Biography or Administrative History Note -->
                
                <!-- Insert biogHist content -->
                
                                <!-- Chronology -->
              
                <!-- Footnotes/Endnotes -->
                
                  <!-- Insert citations -->

            </biogHist>

            <!-- Insert structureOrGenealogy, if relevant -->

            
        </description>
        
        <relations>
        
            <!-- CPF RELATIONS -->
            
              <!-- Relationships to Persons-->
              {$personRelations}
              
              <!-- Relationships to Families -->
              
              <!-- Relationships to Corporate Bodies -->
              
              {$corporateRelations}
            
            
            <!-- RESOURCE RELATIONS -->

              <!-- Relationship to Nixon Tapes Conversations -->
              {$conversations}

              <!-- Relationship to Bibliographic Works, creatorOf/contributorOf -->
                           
              <!-- Relationship to Bibliographic Works, subjectOf -->  
            
        </relations>
    </cpfDescription>
</eac-cpf>

where $n[not(attribute::identifier="00002003")]

return

  let $dir := concat(file:parent(file:parent(static-base-uri())),file:dir-separator(),"37-wht",file:dir-separator(),"authorities",file:dir-separator())
  let $filename := concat(data($id),".xml")
  let $path := concat($dir, $filename)
  return file:write($path, $my-doc)
