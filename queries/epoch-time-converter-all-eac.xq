xquery version "1.0";

(:~
 : Script Name: Epoch Time Converter: All Tapes
 : Author: Amanda Ross
 : Script Version: 1.0
 : Date: 2016 April
 : Copyright: Public Domain
 : Proprietary XQuery Extensions Used: None
 : XQuery Specification: January 2007
 : Script Overview: This script converts conversation start dateTime for each Nixon Tapes EAC-CPF record.
:)

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace eac='urn:isbn:1-931666-33-4';
declare namespace ead='http://www.loc.gov/ead/ead.xsd';
declare namespace xpath='http://www.w3.org/2005/xpath-functions';

let $coll := collection("37-wht")

let $quot := "&#34;"

  for $eac in ($coll/eac:eac-cpf)
  let $eacID := data($eac//eac:recordId)
  
  let $conversations :=
    <conversations>
    {
    for $cID in data($eac//eac:resourceRelation/attribute::xlink:href)
    return <cID>{$cID}</cID>
  }
  </conversations>

  let $epoch := 
    <epoch>
    { 
    for $c in data($conversations/cID)
      let $cMatch := $coll/epochTimes/conversation[id eq $c]
      let $eStart := data($cMatch/startEpochTime) 
      order by xs:integer($eStart) ascending    
      return 
        <cEpoch>{$eStart}</cEpoch>
     }
     </epoch> 
  
  let $keyValue :=
    for $e in distinct-values($epoch/cEpoch)
    let $count := count(matches($epoch/cEpoch,$e))
    return concat($quot,data($e),$quot,": ",$count)
    
  let $join := string-join($keyValue,",")


let $my-doc :=

    concat("{",$join,"}")

return
  let $dir := concat(file:parent(file:parent(static-base-uri())),file:dir-separator(),"37-wht",file:dir-separator(),"intermediate-files",file:dir-separator(),"37-wht-authorities-epoch-times",file:dir-separator())
  let $filename := concat(data($eacID),"-epoch-times_data.json")
  let $path := concat($dir, $filename)
  return file:write($path, $my-doc)