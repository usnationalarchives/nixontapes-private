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


let $coll := collection("37-wht")
return data(($coll/eac:eac-cpf)[3]//eac:recordId)

(:

let $epochAll := doc("37-wht/intermediate-files/37-wht-conversation-epoch-times.xml")

for $conversation in $eac//resourceRelation
let $cID := data($eac/relationEntry)


let $my-doc :=
{}
where 

return
  let $dir := concat(file:parent(file:parent(static-base-uri())),file:dir-separator(),"37-wht",file:dir-separator(),"intermediate-files",file:dir-separator(),"37-wht-epoch-times")
  let $filename := concat(data($id),".xml")
  let $path := concat($dir, $filename)
  return file:write($path, $my-doc)
  
  :)