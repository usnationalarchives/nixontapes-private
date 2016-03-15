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
let $entityType :=
  if (exists($n/persname))
  then "person"
  else "corporateBody"

let $lcnaf :=
  if (exists($n/persname))
  then
  <nameEntry localType="marcfield:100" scriptCode="Latn" xml:lang="eng">
    <part localType="marcfield:110$a"></part>
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
      <part localType="marcfield:100$n"></part>
      <part localType="marcfield:100$d"></part>
      <part localType="marcfield:100$c"></part>
      <authorizedForm>lcnaf</authorizedForm>
      <!-- 
        <authorizedForm>VIAF</authorizedForm>
        <authorizedForm>WorldCat</authorizedForm>
        <authorizedForm>USNARA-LCDRG</authorizedForm>
       -->
    </nameEntry>
    
let $familyName :=
  if(exists($n/lastName))
  then 
    <part localType="familyName">{data($n/lastName)}</part>
  else ""
  
let $givenName :=
  if(exists($n/firstPart))
  then 
    <part localType="givenName">{data($n/firstPart)}</part>
  else "" 
  
let $nickname :=
  if(exists($n/nickname))
  then 
    <part localType="nickname">{data($n/nickname)}</part>
  else ""
  
let $maidenName :=
  if(exists($n/maidenName))
  then 
    <part localType="maidenName">{data($n/maidenName)}</part>
  else ""

let $generationalMarker :=
  if(exists($n/generationalMarker))
  then 
    <part localType="generationalMarker">{data($n/maidenName)}</part>
  else ""
  
let $nixonEntry :=  
  if (exists($n/persname))
  then
    <nameEntry localType="nixonNames" scriptCode="Latn" xml:lang="eng">
      {$familyName} 
      {$givenName}
      {$nickname}
      {$maidenName}
      {$maidenName}
      {$generationalMarker}
      <part localType="militaryRankOrOfficialTitle"/>
      <part localType="Mrs."/>
      <alternativeForm>NixonTapesIndex</alternativeForm>
    </nameEntry>
  else
    ""
 
let $indirect := data($n/indirectOrder)
let $direct := data($n/directOrder)

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
            <citation xlink:href="http://www.rda-jsc.org/rda.html" xlink:type="simple" lastDateTimeVerified="2015-03-18">Joint Steering Committee for the Development of RDA. RDA: Resource Description and Access. Chicago: American Library Association, 2010-</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>USNARA-LCDRG</abbreviation>
            <citation xlink:href="http://www.archives.gov/research/search/lcdrg/" xlink:type="simple" lastDateTimeVerified="2015-03-18">United States National Archives and Records Administration. Lifecycle Data Requirements Guide, 2nd edition. Washington, D.C.: U.S National Archives and Records Administration, 2002-.</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>DACS-2nd</abbreviation>
            <citation xlink:href="http://www2.archivists.org/standards/DACS" xlink:type="simple" lastDateTimeVerified="2015-03-18">Society of American Archivists. Describing Archives: A Content Standard, 2nd edition. Chicago: Society of American Archivists, 2013.</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>NixonTapesIndex</abbreviation>
            <citation xlink:href="https://nixonlibrary.gov/forresearchers/find/tapes" xlink:type="simple" lastDateTimeVerified="2016-01-21">Index to the White House Tapes of the Nixon Administration</citation>
        </conventionDeclaration>
        
        <!-- Convention Declarations for Controlled Vocabularies -->
        
        <conventionDeclaration>
            <abbreviation>lcsh</abbreviation>
            <citation xlink:href="http://id.loc.gov/authorities/subjects.html" xlink:type="simple" lastDateTimeVerified="2015-03-18">Library of Congress Subject Headings</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>lcnaf</abbreviation>
            <citation xlink:href="http://id.loc.gov/authorities/names.html" xlink:type="simple" lastDateTimeVerified="2015-03-18">Library of Congress Name Authority File</citation>
        </conventionDeclaration>
        
        <conventionDeclaration>
            <abbreviation>marc:relators</abbreviation>
            <citation xlink:href="http://id.loc.gov/vocabulary/relators.html" xlink:type="simple" lastDateTimeVerified="2015-03-18">MARC Code List for Relators</citation>
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
                <eventDescription>Local source XML data about the Nixon-era White House Tapes participants was converted to EAC records using base-to-eac.xq script written by Amanda T. Ross</eventDescription>
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
            
            <nameEntry localType="nixonIndirectOrder" scriptCode="Latn" xml:lang="eng">
            <part>{$indirect}</part>
            <authorizedForm>NixonTapesIndex</authorizedForm>
            </nameEntry>

            <nameEntry localType="nixonDirectOrder" scriptCode="Latn" xml:lang="eng">
            <part>{$direct}</part>
            <alternativeForm>NixonTapesIndex</alternativeForm>
            </nameEntry>
            
            {$lcnaf}
            
            {$nixonEntry}
            

            <nameEntry localType="marcfield:400">
                <part localType="marcfield:400$a">Ferriero, David</part>
                <alternativeForm>USNARA-LCDRG</alternativeForm>
            </nameEntry>

            <nameEntry localType="marcfield:400">
                <part localType="marcfield:400$a">Ferriero, David Sean</part>
                <alternativeForm>USNARA-LCDRG</alternativeForm>
            </nameEntry>
            
            <nameEntry localType="marcfield:400">
                <part localType="marcfield:400$a">Ferriero, Dave</part>
                <alternativeForm>USNARA-LCDRG</alternativeForm>
            </nameEntry>
            
        </identity>
        
        <description>
            <existDates localType="marcfield:046">
                <dateRange>
                    <fromDate standardDate="1945-12-31">1945-12-31</fromDate>
                    <toDate />
                </dateRange>
            </existDates>
            
            <occupations>
                <occupation localType="marcfield:374$a">
                    <term vocabularySource="lcsh">Librarians</term>
                </occupation>
                <occupation localType="marcfield:374$a">
                    <term vocabularySource="lcsh">Library administrators</term>
                </occupation>
                <occupation localType="marcfield:374$a">
                    <term vocabularySource="lcsh">National archivists</term>
                    <dateRange>
                        <fromDate standardDate="2009-11-13">November 13, 2009</fromDate>
                        <toDate />
                    </dateRange>
                </occupation>
                <occupation localType="marcfield:374$a">
                    <term vocabularySource="lcsh">Psychiatric aides</term>
                </occupation>
            </occupations>
            
            <languageUsed>
                <language languageCode="eng">English</language>
                <script scriptCode="Latn">Latin</script>
            </languageUsed>
            
            <localDescriptions localType="http://viaf.org/viaf/terms#gender">
                <localDescription localType="marcfield:375">
                    <term>male</term>
                </localDescription>
            </localDescriptions>
            
            <localDescriptions localType="http://viaf.org/viaf/terms#AssociatedSubject">
                <localDescription localType="marcfield:372$a">
                    <term vocabularySource="lcsh">Libraries</term>
                </localDescription>
                <localDescription localType="marcfield:372$a">
                    <term vocabularySource="lcsh">Library administration</term>
                </localDescription>
                <localDescription localType="marcfield:372$a">
                    <term vocabularySource="lcsh">Archives</term>
                </localDescription>
                <localDescription localType="marcfield:372$a">
                    <term vocabularySource="lcsh">Archives -- Administration</term>
                </localDescription>
                <localDescription localType="marcfield:372$a">
                    <term vocabularySource="lcsh">Public records</term>
                </localDescription>
            </localDescriptions>
            
            <localDescriptions localType="http://viaf.org/viaf/terms#titleOrHonorific">
                <localDescription localType="marcfield:368$d">
                    <term vocabularySource="lcsh">Archivist of the United States</term>
                    <dateRange>
                        <fromDate standardDate="2009-11-13">November 13, 2009</fromDate>
                        <toDate />
                    </dateRange>
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
                    <placeEntry vocabularySource="lcsh" latitude="42.575" longitude="70.93">Danvers (Mass.)</placeEntry>
                    <date standardDate="1945-12-31">December 31, 1945</date>
                </place>
                
                <place localType="marcfield:370$e">
                    <placeRole>residence</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="42.558" longitude="-70.88">Beverly (Mass.)</placeEntry>
                </place>             
                <place localType="marcfield:370$e">
                    <placeRole>residence</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="42.358" longitude="-71.060">Boston (Mass.)</placeEntry>
                </place>
                <place localType="marcfield:370$e">
                    <placeRole>residence</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="42.375" longitude="-71.106">Cambridge (Mass.)</placeEntry>
                </place>
                <place localType="marcfield:370$e">
                    <placeRole>residence</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="42.485" longitude="-71.433">Acton (Mass.)</placeEntry>
                </place>
                <place localType="marcfield:370$e">
                    <placeRole>residence</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="35.994" longitude="-78.899">Durham (N.C.)</placeEntry>
                </place>
                <place localType="marcfield:370$e">
                    <placeRole>residence</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="40.711" longitude="-74.006">New York (N.Y.)</placeEntry>
                </place>
                <place localType="marcfield:370$e">
                    <placeRole>residence</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="38.917" longitude="-77">Washington (D.C.)</placeEntry>
                </place>
                
                <place localType="marcfield:370$f">
                    <placeRole>duty station location</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="16.067" longitude="108.217">Đà Nẵng (Vietnam)</placeEntry>
                    <dateRange>
                        <fromDate>1970</fromDate>
                        <toDate>1970</toDate>
                    </dateRange>
                </place>
                <place localType="marcfield:370$f">
                    <placeRole>duty station location</placeRole>
                    <placeEntry vocabularySource="lcsh" latitude="16.131" longitude="108.177">Đà Nẵng Harbor (Vietnam)</placeEntry>
                    <dateRange>
                        <fromDate>1970</fromDate>
                        <toDate>1971</toDate>
                    </dateRange>
                </place>
            </places>
            
            <biogHist>
                
                <abstract>David S. Ferriero (1945- ), an American librarian and library administrator, has held leadership positions at the Massachusetts Institute of Technology, Duke University, New York Public Library, and National Archives and Records Administration.  In November 2009, Ferriero became the tenth Archivist of the United States.</abstract>
                
                <p>Born on December 31, 1945 in Danvers, Massachusetts <span style="sup" localType="#fn01" xml:id="ref01">[1]</span> to Anthony P. and Marie (Toomey) Ferriero <span style="sup" localType="#fn02" xml:id="ref02">[2]</span>, David Sean Ferriero has Italian and Irish ancestry.<span style="sup" localType="#fn03" xml:id="ref03">[3]</span>  David Ferriero's paternal grandparents, Paolo Ferriero and Antonia Giorgio, emigrated from Naples, Italy to Boston at the turn of the century.<span style="sup" localType="#fn04" xml:id="ref04">[4]</span>  His maternal great-grandparents were Irish immigrants to America.<span style="sup" localType="#fn05" xml:id="ref05">[5]</span></p>
                
                <p>Ferriero grew up in nearby Beverly, Massachusetts with his siblings, Anthony, Marie, and Kathleen.  After graduating from Beverly High School, he enrolled at Northeastern University in Boston as an education major.  As part of Northeastern's work co-op program, he worked at a psychiatric hospital and then shelved books at MIT's Humanities Library in Cambridge, Massachusetts.  Ferriero has credited this early experience at the MIT Library with the eventual direction of his career.<span localType="#fn06" style="sup" xml:id="ref06">[6]</span></p>
                
                <p>In 1967, Ferriero left his undergraduate studies and joined the United States Navy during the Vietnam War.  Due to his work experience at the psychiatric hospital, interest in a medical career, and desire to remain stateside, Ferriero volunteered for hospital service.  He received hospital corps training at the Great Lakes Naval Training Center and neuropsychiatric training at Bethesda Naval Hospital in Maryland and St. Elizabeth's Psychiatric Hospital in Washington, D.C.  From 1967 to 1969, he served as a senior corpsman on the psychiatric ward in Chelsea Naval Hospital in Chelsea, Massachusetts.<span style="sup" xml:id="ref07" localType="#fn07">[7]</span></p>
                
                <p>In January 1970, Ferriero deployed to Da Nang, Vietnam.  There, he was assigned to the psychiatric ward of the Da Nang hospital of the 1st Medical Battalion, 1st Marine Division.  After two months, Ferriero was transferred to the hospital ship <span style="font-style:italic">U.S.S. Sanctuary</span>, based in the Da Nang harbor.  Aboard the <span style="font-style:italic">Sanctuary</span>, he provided medical support to U.S. service members and Vietnamese citizens, including humanitarian aid to Vietnamese children.  After his tour of duty, Ferriero returned to the United States in January 1971.<span localType="#fn08" style="sup" xml:id="ref08">[8]</span></p>  
                
                <p>Returning to Boston, Ferriero took courses at Harvard University and completed his bachelor's and master's degrees in English literature at Northeastern University.  During this time, he also returned to employment at MIT's Humanities Library.  These experiences led Ferriero to pursue a second master's degree from Simmons College's School of Library and Information Science in Boston.</p>
                
                <p>At MIT, a number of professionals mentored Ferriero, including humanities librarian Frances Sumner, chief cataloger Frances Needleman, and library director Natalie N. Nicholson.<span localType="#fn09" style="sup" xml:id="ref09">[9]</span>  With their support, he assumed new assignments and greater responsibilities over time.  Ferriero's career with MIT spanned 31 years, culminating in his tenure as Acting Co-Director of Libraries.</p>
                
                <p>Moving to Duke University in Durham, North Carolina, Ferriero served as University Librarian and Vice Provost for Library Affairs from 1996 to 2004.  He shepherded a 50-million dollar fundraising effort for the expansion and renovation of Duke's West Campus libraries.  Under Ferriero's leadership, Duke Libraries developed instructional technology initiatives, launched its preservation program, and actively participated in the evolution of North Carolina's Triangle Research Libraries Network.</p>
                
                <p>In 2004, the New York Public Library recruited Ferriero to lead as Chief Executive of the Research Libraries.<span localType="#fn10" style="sup" xml:id="ref10">[10]</span>  Three years later, he was appointed Andrew W. Mellon Director of NYPL, the largest public library system in the United States.  With his expanded role, Ferriero became responsible for integrating the four research libraries and 87 branch libraries of New York City.  During his tenure, NYPL joined the Google Books Library Project as an institutional partner, supplying public domain works for full scanning and indexing.  The NYPL Labs also received recognition for innovative digital engagement initiatives.</p>
                
                <p>Ferriero's achievements with the New York Public Library system drew the notice of President-elect Barack Obama's appointments team.  As part of his open government initiative, Obama sought a new Archivist of the United States who would be &quot;integral to establishing a new level of transparency&quot; in the federal government.<span localType="#fn11" style="sup" xml:id="ref11">[11]</span>  On July 28, 2009, President Obama nominated David Ferriero to head the National Archives and Records Administration (NARA).  The U. S. Senate confirmed the appointment on November 6, 2009.  On November 13, 2009, Ferriero was sworn in as the tenth Archivist of the United States (AOTUS), the first librarian to occupy this post.</p>
                
                <p>On December 30, 2009, Ferriero established the National Declassification Center (NDC) within NARA, in accordance with Executive Order 13526, Section 3.7.  The NDC advances a mission &quot;to align people, processes, and technologies to advance the declassification and public release of historically valuable permanent records while maintaining national security.&quot;<span localType="#fn12" style="sup" xml:id="ref12">[12]</span>  The NDC has initially concentrated on resolving a declassification review backlog of 400 million pages of federal records and presidential materials.<span localType="#fn12" style="sup" xml:id="ref13">[13]</span></p>
                
                <p>At the National Archives, Ferriero's agenda has focused on agency reorganization, technological transformation, &quot;citizen archivists&quot;, social media and other outreach mechanisms, and the creation and strengthening of external partnerships, including NARA's relationship with Wikipedia.  In his role as Archivist, Ferriero has testified before Congress on matters relating to federal records, such as NARA's mission and operations, the National Historical Publications and Records Commission (NHPRC), government transparency and accountability, records management, and the retention of email accounts of federal agency officials, including Lois Lerner of the Internal Revenue Service.</p>
                
                <p>During Ferriero's administration, the National Archives has cooperated with the Office of Management and Budget to implement the President Obama's 2011 Memorandum on Managing Government Records.  In August 2012, NARA produced the Managing Government Records Directive to modernize and improve federal records management practices.<span localType="#fn12" style="sup" xml:id="ref14">[14]</span>  The National Archives advocated for revisions to the 1950 Federal Records Act, which led to the bipartisan passage of the Presidential and Federal Records Act Amendments of 2014.  On November 26, 2014, President Obama signed H.R. 1233 into law, modernizing federal records management by focusing more directly on electronic records.<span localType="#fn12" style="sup" xml:id="ref15">[15]</span></p> 
                
                <p>Ferriero is married to Gail Zimmermann, a public television manager.  As of 2015, the couple resides in Durham, North Carolina and Washington, D.C.</p>
              
                <!-- Footnotes/Endnotes -->
                
                <citation xml:id="fn01" xlink:href="#ref01" xlink:type="simple">[1] Department of Public Health, Registry of Vital Records and Statistics. Massachusetts Vital Records Index to Births [1916–1970], vol. 61. Ancestry.com. Viewed online March 6, 2015.</citation>
                <citation xml:id="fn02" xlink:href="ref02" xlink:type="simple">[2] &quot;Anthony Ferriero: Obituary,&quot; Danvers, Massachusetts: <span style="font-style:italic" localType="title">The Danvers Herald</span>, March 2012. Legacy.com. (Accessed online March 6, 2015: http://www.legacy.com/obituaries/wickedlocal-danvers/obituary.aspx?n=anthony-ferriero&amp;pid=156593174)</citation>
                
                <citation xml:id="fn03" xlink:href="#ref03" xlink:type="simple">[3] Sam Roberts, &quot;Collector in Chief Hoards Nation’s Irreplaceable Stuff,&quot; <span style="font-style:italic" localType="title">New York Times</span>, March 31, 2010, (Accessed online March 6, 2015: http://www.nytimes.com/2010/04/01/arts/design/01archives.html)</citation>
                <citation xml:id="fn04" xlink:href="#ref04" xlink:type="simple">[4] David S. Ferriero, &quot;Prepared remarks of Archivist of the United States David S. Ferriero at the Bill of Rights Day Naturalization Ceremony,&quot; Washington, DC., December 15, 2010, (Accessed online March 6, 2015: http://www.archives.gov/about/speeches/2010/12-15b-2010.html)</citation>
                <citation xml:id="fn05" xlink:href="#ref05" xlink:type="simple">[5] Ibid.</citation>
                <citation xml:id="fn06" xlink:href="#ref06" xlink:type="simple">[6] &quot;David Ferriero, Vietnam Vet Who Is Now Our National Archivist,&quot; republished July 24, 2013 (Accessed online March 6, 2015: http://www.historynet.com/interview-david-ferriero-vietnam-vet-who-is-now-our-national-archivist.htm)</citation>
                <citation xml:id="fn07" xlink:href="#ref07" xlink:type="simple">[7] Ibid.</citation>
                <citation xml:id="fn08" xlink:href="#ref08" xlink:type="simple">[8] Ibid.</citation>
                <citation xml:id="fn09" xlink:href="#ref09" xlink:type="simple">[9] David Ferriero, e-mail message to John Martinez, March 13, 2015</citation>
                <citation xml:id="fn10" xlink:href="#ref10" xlink:type="simple">[10] &quot;David Ferriero, Vietnam Vet Who Is Now Our National Archivist,&quot; ibid.</citation>
                <citation xml:id="fn11" xlink:href="#ref11" xlink:type="simple">[11] Ibid.</citation>
                <citation xml:id="fn12" xlink:href="#ref12" xlink:type="simple">[12] National Archives and Records Administration, &quot;Sheryl Jasielum Shenberger Named Director of the National Archives National Declassification Center,&quot; May 20, 2010 (Accessed online March 13, 2015: http://www.archives.gov/press/press-releases/2010/nr10-98.html)</citation>
                <citation xml:id="fn13" xlink:href="#ref13" xlink:type="simple">[13] David Ferriero, &quot;Prepared Remarks of Archivist of the United States David S. Ferriero at the National Declassification Center Open Forum, National Archives Building,&quot; June 23, 2010 (Accessed online March 13, 2015: http://www.archives.gov/about/speeches/2010/6-23b-2010.html)</citation>
                <citation xml:id="fn14" xlink:href="#ref14" xlink:type="simple">[14] &quot;Biography of David S. Ferriero, Archivist of the United States,&quot; National Archives and Records Administration (Accessed online March 13, 2014: http://www.archives.gov/about/archivist/archivist-biography-ferriero.html)</citation>
                <citation xml:id="fn15" xlink:href="#ref15" xlink:type="simple">[15] National Archives and Records Administration, &quot;National Archives Welcomes Presidential and Federal Records Act Amendments of 2014,&quot; December 1, 2014 (Accessed online March 13, 2014: http://www.archives.gov/press/press-releases/2015/nr15-23.html)</citation>
            </biogHist>
            
        </description>
        
        <relations>
            
            <!-- Relationships to Corporate Bodies -->
            
            <!-- Education -->
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#associatedWith">
                <relationEntry>Northeastern University (Boston, Mass.)</relationEntry>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#associatedWith">               
                <relationEntry>Simmons College (Boston, Mass.). Graduate School of Library and Information Science</relationEntry>
            </cpfRelation>
            
            <!-- Employers -->
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://vocab.org/relationship/employedBy">
                <relationEntry>Massachusetts Institute of Technology</relationEntry>
                <dateSet>
                    <dateRange>
                        <fromDate>1965</fromDate>
                        <toDate>1967</toDate>
                    </dateRange>
                    <dateRange>
                        <fromDate>1971</fromDate>
                        <toDate>1996</toDate>
                    </dateRange>                    
                </dateSet>
            </cpfRelation>
                        
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://vocab.org/relationship/employedBy">
                <relationEntry>United States. Navy</relationEntry>
                <dateRange>
                    <fromDate>1967</fromDate>
                    <toDate>1971</toDate>
                </dateRange>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#associatedWith">
                <relationEntry>United States. Marine Corps. Medical Battalion, 1st</relationEntry>
                <dateRange>
                    <fromDate>1970</fromDate>
                    <toDate>1971</toDate>
                </dateRange>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#associatedWith">
                <relationEntry>Sanctuary (Ship)</relationEntry>
                <dateRange>
                    <fromDate>1970</fromDate>
                    <toDate>1971</toDate>
                </dateRange>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://vocab.org/relationship/employedBy">
                <relationEntry>Duke University</relationEntry>
                <dateRange>
                    <fromDate>1996</fromDate>
                    <toDate>2004</toDate>
                </dateRange>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://vocab.org/relationship/employedBy">
                <relationEntry>New York Public Library</relationEntry>
                <dateRange>
                    <fromDate>2004</fromDate>
                    <toDate>2009</toDate>
                </dateRange>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#associatedWith">
                <relationEntry>United States. National Archives and Records Administration</relationEntry>
                <dateRange>
                    <fromDate standardDate="2009-11-13">November 13, 2009</fromDate>
                    <toDate />
                </dateRange>
            </cpfRelation>
                        
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#associatedWith">
                <relationEntry>National Declassification Center (U.S.)</relationEntry>
                <dateRange>
                    <fromDate standardDate="2009-12-30">December 30, 2009</fromDate>
                    <toDate />
                </dateRange>
            </cpfRelation>
 
            <!-- Relationships to Persons-->
            
                <!-- Family Members -->
            
            <cpfRelation cpfRelationType="family" xlink:arcrole="http://vocab.org/relationship/spouseOf.html">
                <relationEntry>Zimmermann, Gail</relationEntry>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="family" xlink:arcrole="http://vocab.org/relationship/childOf.html">
                <relationEntry>Ferriero, Marie Toomey</relationEntry>
            </cpfRelation>

            <cpfRelation cpfRelationType="family" xlink:arcrole="http://vocab.org/relationship/childOf.html">
                <relationEntry>Ferriero, Anthony P.</relationEntry>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="family" xlink:arcrole="http://vocab.org/relationship/grandchildOf.html">
                <relationEntry>Ferriero, Antonia Griorgio</relationEntry>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="family" xlink:arcrole="http://vocab.org/relationship/grandchildOf.html">
                <relationEntry>Ferriero, Paolo</relationEntry>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="family" xlink:arcrole="http://vocab.org/relationship/siblingOf.html">
                <relationEntry>Ferriero, Anthony Charles</relationEntry>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="family" xlink:arcrole="http://vocab.org/relationship/siblingOf.html">
                <relationEntry>Clarke, Marie A.</relationEntry>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="family" xlink:arcrole="http://vocab.org/relationship/siblingOf.html">
                <relationEntry>Ramos, Kathleen Toni</relationEntry>
            </cpfRelation>
            
                <!-- Professional Mentors -->

            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://vocab.org/relationship/apprenticeTo.html">
                <relationEntry>Needleman, Frances</relationEntry>
                <placeEntry vocabularySource="lcsh" latitude="42.375" longitude="-71.106">Cambridge (Mass.)</placeEntry>
                <descriptiveNote>
                    <p>Frances Needleman, head of cataloging, mentored David Ferriero at Massachusetts Institute of Technology's Humanities Library.</p>
                </descriptiveNote>  
            </cpfRelation>
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://vocab.org/relationship/apprenticeTo.html">
                <relationEntry>Nicholson, Natalie N.</relationEntry>
                <placeEntry vocabularySource="lcsh" latitude="42.375" longitude="-71.106">Cambridge (Mass.)</placeEntry>
                <descriptiveNote>
                    <p>Library director Natalie Nicholson mentored David Ferriero at Massachusetts Institute of Technology's Humanities Library.</p>
                </descriptiveNote>
            </cpfRelation>
            
            <cpfRelation cpfRelationType="associative" xlink:arcrole="http://vocab.org/relationship/apprenticeTo.html">
                <relationEntry>Sumner, Frances</relationEntry>
                <placeEntry vocabularySource="lcsh" latitude="42.375" longitude="-71.106">Cambridge (Mass.)</placeEntry>
                <descriptiveNote>
                    <p>Humanities librarian Frances Sumner mentored David Ferriero at Massachusetts Institute of Technology's Humanities Library.</p>
                </descriptiveNote>  
            </cpfRelation>
            
            <!-- Relationship to NARA Records -->
            
            <resourceRelation xmlns:xlink="http://www.w3.org/1999/xlink" xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#creatorOf" xlink:href="https://catalog.archives.gov/id/7717865" xlink:role="http://socialarchive.iath.virginia.edu/control/term#ArchivalResource" xlink:type="simple" lastDateTimeVerified="2015-03-19">
                <relationEntry>White House Central Files (Eisenhower Administration): Alphabetical Files: FERRI: Letter from David Ferriero to President Eisenhower, circa March 1960</relationEntry>
                <objectXMLWrap>
                    <did>
                        <unittitle>Letter from David Ferriero to President Eisenhower</unittitle>
                        <unitdate>March 10, 1960</unitdate>
                        <unitid repositorycode="DNA" type="naId">7717865</unitid>
                        <origination>
                            <persname rules="rda" source="lcnaf" role="author">Ferriero, David S., 1945-</persname>
                            <persname rules="rda" source="lcnaf" role="correspondent">Eisenhower, Dwight D. (Dwight David), 1890-1969</persname>
                        </origination>
                        <repository>
                            <corpname rules="rda" source="lcnaf">United States. National Archives and Records Administration</corpname>
                            <corpname rules="rda" source="lcnaf">Dwight D. Eisenhower Library</corpname>
                            <address>
                                <addressLine>200 SE 4th Street</addressLine>
                                <addressLine>Abilene, KS 67410-2900</addressLine>
                            </address>                            
                        </repository>
                        <physdesc>
                            <extent>1 item</extent>
                        </physdesc>
                        <physdesc>1 page</physdesc>
                        <abstract>This handwritten letter was written by Dave Ferriero, 14 years of age, to President Dwight D. Eisenhower, requesting an autographed photograph of the President.  The letter was written from Beverly, Massachusetts.  David S. Ferriero became the tenth Archivist of the United States.</abstract>
                    </did>
                </objectXMLWrap>
            </resourceRelation>

            <!-- Relationship to Bibliographic Works, creatorOf/contributorOf -->
            
            <resourceRelation xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#creatorOf" xlink:role="http://socialarchive.iath.virginia.edu/control/term#BibliographicResource" xlink:type="simple" xlink:href="http://www.worldcat.org/oclc/648480758" lastDateTimeVerified="2015-03-19">
                <relationEntry>Discovering the Civil War</relationEntry>
            </resourceRelation>
         
            <resourceRelation xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#creatorOf" xlink:role="http://socialarchive.iath.virginia.edu/control/term#BibliographicResource" xlink:type="simple" xlink:href="http://www.worldcat.org/oclc/719429660" lastDateTimeVerified="2015-03-19">
                <relationEntry>Eating with Uncle Sam : recipes and historical bites from the National Archives</relationEntry>
            </resourceRelation>            
            
            <resourceRelation xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#creatorOf" xlink:role="http://socialarchive.iath.virginia.edu/control/term#BibliographicResource" xlink:type="simple" xlink:href="http://www.worldcat.org/oclc/813862016" lastDateTimeVerified="2015-03-19">
                <relationEntry>Searching for the seventies : the DOCUMERICA photography project</relationEntry>
            </resourceRelation>   
            
            <!-- Relationship to Bibliographic Works, subjectOf -->
            
            <resourceRelation xlink:arcrole="http://socialarchive.iath.virginia.edu/control/term#subjectOf" xlink:role="http://socialarchive.iath.virginia.edu/control/term#BibliographicResource" xlink:type="simple" xlink:href="http://www.worldcat.org/oclc/658044625" lastDateTimeVerified="2015-03-19">
                <relationEntry>Nomination of David S. Ferriero : hearing before the Committee on Homeland Security and Governmental Affairs, United States Senate of the One Hundred Eleventh Congress, first session : nomination of David S. Ferriero to be archivist of the United States, National Archives and Records Administration, October 1, 2009</relationEntry>
            </resourceRelation>  
            
        </relations>
    </cpfDescription>
</eac-cpf>

(:
return

  let $dir := concat(file:parent(file:parent(static-base-uri())),file:dir-separator(),"37-wht",file:dir-separator(),"authorities")
  let $filename := concat(data($n/attribute::identifier),".xml")
  let $path := concat($dir, $filename)
  return file:write($path, $my-doc)
:)