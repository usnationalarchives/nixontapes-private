xquery version "1.0";

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace eac='urn:isbn:1-931666-33-4';
declare namespace ead='http://www.loc.gov/ead/ead.xsd';
declare namespace xpath='http://www.w3.org/2005/xpath-functions';

declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";

<csv>
{

let $coll := collection("37-wht")

for $eac in ($coll//eac:eac-cpf)
  let $eacID := data($eac//eac:recordId)
  let $authName := data($eac//eac:nameEntry[eac:authorizedForm="NixonTapesIndex"]/eac:part)
  let $possibleDuplicate :=
    for $match in $coll/eac:cpf[matches(//eac:part,$authName)]//recordId
    return concat($match,"; ")
  
  return 
  <record>
    <eacID>{$eacID}</eacID>
    <nixonName>{$authName}</nixonName>
    <possibleDuplicate>{$possibleDuplicate}</possibleDuplicate>
  </record>
  
}
</csv>