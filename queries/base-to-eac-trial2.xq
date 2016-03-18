xquery version "1.0";

(:~
 : Script Name: Base to EAC
 : Author: Amanda Ross
 : Script Version: 1.0
 : Date: 2016 January
 : Copyright: Public Domain
 : Proprietary XQuery Extensions Used: None
 : XQuery Specification: January 2007
 : Script Overview: This script converts base/source data about the Nixon-era White House Tapes participants to EAC records
:)

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

declare namespace xlink="http://www.w3.org/1999/xlink";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";   
declare option output:method "xml";
declare option output:omit-xml-declaration "no";
declare option output:indent "yes"; 

let $coll := collection("nixontapes-private-base")

for $n in $coll/nixonNames/participant[1]

let $id := $n//attribute::authfilenumber

let $indirect := data($n/indirectOrder)
let $direct := data($n/directOrder)

let $entityType :=
  if (exists($n/persname))
  then "person"
  else "corporateBody"
  
let $orgParts :=
  if (exists($n/corpname))
  then 
    for $orgPart in tokenize($direct,"\. ")
      return  
         <part localType="marcfield:110$a">{$orgPart}</part>  
  else null
(: Continue to work on scripting parts! First equals 100$a, thereafter 100$b :)
    
let $familyName :=
  if(exists($n/lastName))
  then 
    <part localType="familyName">{data($n/lastName)}</part>
  else null
  
let $givenName :=
  if(exists($n/firstPart))
  then 
    <part localType="givenName">{data($n/firstPart)}</part>
  else null 
  
let $nickname :=
  if(exists($n/nickname))
  then 
    <part localType="nickname">{data($n/nickname)}</part>
  else null
  
let $maidenName :=
  if(exists($n/maidenName))
  then 
    <part localType="maidenName">{data($n/maidenName)}</part>
  else null
  
let $generationalMarker :=
  if(exists($n/generationalMarker))
  then 
    <part localType="generationalMarker">{data($n/generationalMarker)}</part>
  else null

let $titleHonorific :=
  if(exists($n/titleHonorific))
  then 
    <part localType="titleHonorific">{data($n/titleHonorific)}</part>
  else null
  
let $marriedDesignator :=
  if(exists($n/marriedMrs))
  then 
    <part localType="marriedDesignator">{data($n/marriedMrs)}</part>
  else null
 
let $nixonEntry :=  
  if (exists($n/persname))
  then
    <nameEntry localType="nixonNames/#parsed" scriptCode="Latn" xml:lang="eng">
      {$familyName}
      {$givenName}
      {$nickname}
      {$maidenName}
      {$maidenName}
      {$generationalMarker}
      {$titleHonorific}
      {$marriedDesignator}
      <alternativeForm>NixonTapesIndex</alternativeForm>
    </nameEntry>
  else
    <nameEntry localType="marcfield:110" scriptCode="Latn" xml:lang="eng">
      {$orgParts}
      <alternativeForm>NixonTapesIndex</alternativeForm>
    </nameEntry>


let $lcnaf :=
  if (exists($n/persname))
  then
  <nameEntry localType="marcfield:100" scriptCode="Latn" xml:lang="eng">
    <part localType="marcfield:100$a"></part>
    <part localType="marcfield:100$b"></part>
    <part localType="marcfield:100$c"></part>
    <part localType="marcfield:100$q"></part>
    <part localType="marcfield:100$d"></part>
    <authorizedForm>lcnaf</authorizedForm>
    <!-- 
      <authorizedForm>VIAF</authorizedForm>
      <authorizedForm>WorldCat</authorizedForm>
      <authorizedForm>USNARA-LCDRG</authorizedForm>
     -->
  </nameEntry>
  else
    <nameEntry localType="marcfield:110" scriptCode="Latn" xml:lang="eng">
      <part localType="marcfield:110$a"></part>
      <part localType="marcfield:110$b"></part>
      <part localType="marcfield:110$b"></part>
      <part localType="marcfield:110$n"></part>
      <part localType="marcfield:110$d"></part>
      <part localType="marcfield:110$c"></part>
      <authorizedForm>lcnaf</authorizedForm>
      <!-- 
        <authorizedForm>VIAF</authorizedForm>
        <authorizedForm>WorldCat</authorizedForm>
        <authorizedForm>USNARA-LCDRG</authorizedForm>
       -->
    </nameEntry>

let $genderRecord := $coll/csv/record[matches(data(Identifier),data($id))]
let $genderTerm := data($genderRecord/genderTerms)
let $genderScore := data($genderRecord/scale)

let $genderEntry :=
  if (exists($n/persname))
  then
      <localDescriptions localType="http://viaf.org/viaf/terms#gender">
        <localDescription localType="marcfield:375">
          <term vocabularySource="namSor">{$genderTerm}</term>
          <descriptiveNote>Gender term predicted by NamSor gender analytics, with a certainty scale of {$genderScore}</descriptiveNote>
                </localDescription>
      </localDescriptions>
  else null

(: let $my-doc :=  :)

(: Edit this Ferriero record :)
return
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
<<<<<<< HEAD
                <eventDescription>Converted base/source XML data about the Nixon-era White House Tapes participants to EAC-CPF records using base-to-eac.xq script written by Amanda T. Ross of the United States National Archives and Records Administration</eventDescription>
=======
                <eventDescription>Local source XML data about the Nixon-era White House Tapes participants was converted to EAC records using base-to-eac.xq script written by Amanda T. Ross</eventDescription>
>>>>>>> usnationalarchives/master
            </maintenanceEvent>
            <!--
            <maintenanceEvent>
                <eventType>revised</eventType>
                <eventDateTime></eventDateTime>
                <agentType></agentType>
                <agent></agent>
            </maintenanceEvent>
            <maintenanceEvent>
                <eventType>revised</eventType>
                <eventDateTime></eventDateTime>
                <agentType></agentType>
                <agent></agent>
            </maintenanceEvent> 
            -->
        </maintenanceHistory>
        
        <sources>
            <!-- 
            <source xlink:actuate="onRequest" xlink:show="new" xlink:type="simple" xlink:href="https://catalog.archives.gov/id/[NARA ID]" xlink:type="simple" lastDateTimeVerified="[Current Date]">
                <sourceEntry>National Archives and Records Administration Authority List: [NARA ID]</sourceEntry>
            </source>
            <source xlink:actuate="onRequest" xlink:show="new" xlink:type="simple" xlink:href="http://id.loc.gov/authorities/names/[LOC ID]" xlink:type="simple" lastDateTimeVerified="[Current Date]">
                <sourceEntry>Library of Congress Name Authority File: [LOC ID]</sourceEntry>
            </source>
            <source xlink:actuate="onRequest" xlink:show="new" xlink:type="simple" xlink:href="http://viaf.org/viaf/[VIAF ID]" xlink:type="simple" lastDateTimeVerified="[Current Date]">
                <sourceEntry>Virtual International Authority File: [VIAF ID]</sourceEntry>
            </source>
             -->
        </sources>
        
    </control>
    
    <cpfDescription>
        
        <identity>
            <entityType>{$entityType}</entityType>
            
            <nameEntry localType="marcfield:100" scriptCode="Latn" xml:lang="eng">
            <part localType="marcfield:100$a">{$indirect}</part>
            <authorizedForm>NixonTapesIndex</authorizedForm>
            </nameEntry>

            <nameEntry localType="nixonNames" scriptCode="Latn" xml:lang="eng">
            <part localType="directOrder">{$direct}</part>
            <alternativeForm>NixonTapesIndex</alternativeForm>
            </nameEntry>

            {$nixonEntry}
            
            {$lcnaf}
            
          <!-- Insert variant names -->
            
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
                
                <abstract><!-- Insert Abstract --></abstract>
                
                <p><!-- Insert biogHist --></p> 
              
                <!-- Footnotes/Endnotes -->
                
                  <!-- Insert citation -->

            </biogHist>
            
        </description>
        
        <relations>
            
            <!-- Relationships to Corporate Bodies -->
             
            <!-- Relationships to Persons-->
            
            <!-- Relationships to Families -->
            
            <!-- Relationship to Nixon Tapes Conversations --> 

            <!-- Relationship to Bibliographic Works, creatorOf/contributorOf -->
                         
            <!-- Relationship to Bibliographic Works, subjectOf -->  
            
        </relations>
    </cpfDescription>
</eac-cpf>

(:
return

  let $dir := concat(file:parent(file:parent(static-base-uri())),file:dir-separator(),"37-wht",file:dir-separator(),"authorities",file:dir-separator())
  let $filename := concat(data($id),".xml")
  let $path := concat($dir, $filename)
  return file:write($path, $my-doc)
:)