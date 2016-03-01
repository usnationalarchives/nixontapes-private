xquery version "1.0";

(:~
 : Script Name: Base to EAC
 : Author: Amanda T. Ross
 : Script Version: 1.0
 : Date: 2016 February
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

for $n in $coll/nixonNames/participant
let $id := functx:trim(data($n//attribute::authfilenumber))
let $type := node-name($n/persname|corpname)
let $entityType :=
  if (string(data($type)) eq "persname")
    then "person"
      else 
        if (string(data($type)) eq "corpname")
          then "corporateBody"
            else ""

let $gender := data($coll/csv/record[matches(attribute::Identifier,$id)]/genderTerms)
let $genderScore := data($coll/csv/record[matches(attribute::Identifier,$id)]/scale)

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
        <recordId></recordId>
        <!-- <otherRecordId localType="http://catalog.archives.gov/id/"></otherRecordId> -->
        <!-- <otherRecordId localType="http://viaf.org/viaf/terms#viafID"></otherRecordId> -->
        <otherRecordId localType="http://www.loc.gov/standards/mads/rdf/v1.html#Authority"></otherRecordId>
        
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
            <citation xlink:href="http://www.rda-jsc.org/rda.html" xlink:type="simple" lastDateTimeVerified="2016-02-19">Joint Steering Committee for the Development of RDA. RDA: Resource Description and Access. Chicago: American Library Association, 2010-</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>USNARA-LCDRG</abbreviation>
            <citation xlink:href="http://www.archives.gov/research/search/lcdrg/" xlink:type="simple" lastDateTimeVerified="2016-02-19">United States National Archives and Records Administration. Lifecycle Data Requirements Guide, 2nd edition. Washington, D.C.: U.S National Archives and Records Administration, 2002-.</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>DACS-2nd</abbreviation>
            <citation xlink:href="http://www2.archivists.org/standards/DACS" xlink:type="simple" lastDateTimeVerified="2015-03-18">Society of American Archivists. Describing Archives: A Content Standard, 2nd edition. Chicago: Society of American Archivists, 2013.</citation>
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
                <eventDescription>Converted base/source data to EAC-CPF through XQuery script written by Amanda T. Ross of the United States National Archives and Records Administration.</eventDescription>
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
            
            <source xlink:href="https://catalog.archives.gov" xlink:type="simple" lastDateTimeVerified="2016-02-29">
                <sourceEntry>National Archives and Records Administration Authority List</sourceEntry>
            </source>
             -->
            <source xlink:href="http://id.loc.gov/authorities/names" xlink:type="simple" lastDateTimeVerified="[dateTime]">
                <sourceEntry>Library of Congress Name Authority File</sourceEntry>
            </source>
            <source xlink:href="http://viaf.org" xlink:type="simple" lastDateTimeVerified="2016-02-29">
                <sourceEntry>Virtual International Authority File</sourceEntry>
            </source>
        </sources>
      
    </control>
    
    <cpfDescription>
        
        
        <identity>
            <entityType>{$entityType}</entityType>

            if ($entityType eq "person")
              then
              
            <nameEntry localType="marcfield:100">
                <part localType="marcfield:100$a"></part>
                <part localType="marcfield:100$d"></part>
                <authorizedForm>lcnaf</authorizedForm>
                <!-- <authorizedForm>VIAF</authorizedForm>
                <authorizedForm>WorldCat</authorizedForm>
                <authorizedForm>USNARA-LCDRG</authorizedForm> -->
            </nameEntry>
              
            <nameEntry localType="nixonNames">
                <part localType="familyName">{$n/lastName}</part>
                <part localType="givenName">{$n/firstPart}</part>
                <part localType="nickname">{$n/nickname}</part>
                <part localType="maiden name"></part>
                <part localtype="generational marker"></part>
                <part localType="military rank or official title"></part>
                <part localType="Mrs."></part>
                <authorizedForm>NixonTapesIndex</authorizedForm>
            </nameEntry>

            <nameEntry localType="marcfield:400">
                <part localType="marcfield:400$a"></part>
                <alternativeForm>USNARA-LCDRG</alternativeForm>
            </nameEntry>

            <nameEntry localType="marcfield:400">
                <part localType="marcfield:400$a"></part>
                <alternativeForm>USNARA-LCDRG</alternativeForm>
            </nameEntry>
            

      else
      <nameEntry localType="marcfield:110">
                <part localType="marcfield:110$a"></part>
                <part localType="marcfield:110$d"></part>
                <authorizedForm>lcnaf</authorizedForm>
                <!-- <authorizedForm>VIAF</authorizedForm>
                <authorizedForm>WorldCat</authorizedForm>
                <authorizedForm>USNARA-LCDRG</authorizedForm> -->
            </nameEntry>
              
            <nameEntry localType="nixonNames">
                <part localType="directOrder">{$n/directOrder}</part>
                <alternativeForm>NixonTapesIndex</alternativeForm>
            </nameEntry>

            <nameEntry localType="marcfield:410">
                <part localType="marcfield:410$a"></part>
                <alternativeForm>USNARA-LCDRG</alternativeForm>
            </nameEntry>

            <nameEntry localType="marcfield:410">
                <part localType="marcfield:410$a"></part>
                <alternativeForm>USNARA-LCDRG</alternativeForm>
            </nameEntry>
            
        </identity>
        
        <description>
            <existDates localType="marcfield:046">
                <dateRange>
                    <fromDate standardDate=""></fromDate>
                    <toDate />
                </dateRange>
            </existDates>
            
            <occupations>
                <occupation localType="marcfield:374$a">
                    <term vocabularySource="lcsh"></term>
                </occupation>
                <occupation localType="marcfield:374$a">
                    <term vocabularySource="lcsh"></term>
                </occupation>
                <occupation localType="marcfield:374$a">
                    <term vocabularySource="lcsh"></term>
                    <dateRange>
                        <fromDate standardDate="2009-11-13">November 13, 2009</fromDate>
                        <toDate />
                    </dateRange>
                </occupation>
                <occupation localType="marcfield:374$a">
                    <term vocabularySource="lcsh"></term>
                </occupation>
            </occupations>
            
            <languageUsed>
                <language languageCode="eng">English</language>
                <script scriptCode="Latn">Latin</script>
            </languageUsed>
            
            <localDescriptions localType="http://viaf.org/viaf/terms#gender">
                <localDescription localType="marcfield:375">
                    <term>{$gender}</term>
                    <descriptiveNote>Gender certainty score, via Namsor: {$genderScore}</descriptiveNote>
                </localDescription>
            </localDescriptions>
            
            <localDescriptions localType="http://viaf.org/viaf/terms#AssociatedSubject">
                <localDescription localType="marcfield:372$a">
                    <term vocabularySource="lcsh"></term>
                </localDescription>
            </localDescriptions>
            
            
            <localDescription localType="http://viaf.org/viaf/terms#nationalityOfEntity">
                <placeEntry vocabularySource="lcsh" countryCode="US">United States</placeEntry>
            </localDescription>
            
            <places localType="http://socialarchive.iath.virginia.edu/control/term#AssociatedPlace">
                <place localType="marcfield:370$c">
                    <placeRole>associated country</placeRole>
                    <placeEntry vocabularySource="lcsh" countryCode="US" latitude="39.76" longitude="-98.5">United States</placeEntry>
                </place>
                
                <place localType="marcfield:370$a">
                    <placeRole>birthplace</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="" longitude=""></placeEntry>
                    <date standardDate=""></date>
                </place>
                
            </places>
            
            <biogHist>
                
                <abstract>{data($n/directOrder)} ...</abstract>
                
                <p>{data($n/directOrder)} ...</p>
              
                <!-- Footnotes/Endnotes -->
                <citation></citation>
            </biogHist>
            
        </description>
        
        <relations>
            
            <!-- Relationships to Corporate Bodies -->
            
                 <!-- Education -->
            
                 <!-- Employers -->
           
            <!-- Relationships to Persons-->
            
                <!-- Family Members -->                 
                <!-- Professional Relationships -->
           
            
            <!-- Relationship to Resources, creatorOf -->
            
            <resourceRelation xmlns:xlink="http://www.w3.org/1999/xlink" xlink:arcrole="participantIn" xlink:href="" xlink:role="archivalResource" xlink:type="simple" lastDateTimeVerified="2016-02-29">
                <relationEntry></relationEntry> 
            </resourceRelation>                   
            <!-- Relationship to Resources, subjectOf -->
            
            <resourceRelation xlink:arcrole="subjectOf" xlink:role="archivalResource" xlink:type="simple" xlink:href="" lastDateTimeVerified="">
                <relationEntry></relationEntry>
            </resourceRelation>  
            
        </relations>
    </cpfDescription>
</eac-cpf>

return

  let $dir := concat(file:parent(file:parent(static-base-uri())),file:dir-separator(),"37-wht",file:dir-separator(),"authorities",file:dir-separator())
  let $filename := concat(data($id),".xml")
  let $path := concat($dir, $filename)
  return file:write($path, $my-doc)
