xquery version "1.0";

(:~
 : Script Name: Epoch Time Converter: All Tapes
 : Author: Amanda Ross
 : Script Version: 1.0
 : Date: 2016 April
 : Copyright: Public Domain
 : Proprietary XQuery Extensions Used: None
 : XQuery Specification: January 2007
 : Script Overview: This script converts conversation start dateTime to Unix/epoch time across the entire dataset.
:)

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

declare namespace xlink="http://www.w3.org/1999/xlink";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";   
declare option output:method "xml";
declare option output:omit-xml-declaration "no";
declare option output:encoding "UTF-8";
declare option output:indent "yes"; 

<epochTimes>
{

let $coll := collection("nixontapes-private-base")

for $row in $coll/root/row[not(contains(tapeNo,'test'))]

let $c := data($row/filename) 

let $sDateTime := $row/startDateTime
  
let $sEpoch := (xs:dateTime($sDateTime) - xs:dateTime("1970-01-01T00:00:00-00:00")) div xs:dayTimeDuration('PT1S')

let $eDateTime := $row/endDateTime

let $eEpoch := (xs:dateTime($eDateTime) - xs:dateTime("1970-01-01T00:00:00-00:00")) div xs:dayTimeDuration('PT1S')
  
order by $c ascending
  
return 
  <conversation>
    <id>{$c}</id>
    <startEpochTime>{$sEpoch}</startEpochTime>
    <endEpochTime>{$eEpoch}</endEpochTime>
  </conversation>
}
</epochTimes>  