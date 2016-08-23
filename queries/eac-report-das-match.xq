xquery version "1.0";

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace eac='urn:isbn:1-931666-33-4';
declare namespace ead='http://www.loc.gov/ead/ead.xsd';
declare namespace xpath='http://www.w3.org/2005/xpath-functions';

let $coll := collection("37-wht")

let $ampersand := '&#38;'

for $eac in ($coll//eac:eac-cpf)[not(matches(data(//part),"Klein, John V. N."))]
  let $eacID := data($eac//eac:recordId)
  let $authName := data($eac//eac:nameEntry[eac:authorizedForm="NixonTapesIndex"]/eac:part)

 
let $matchString := replace(lower-case(replace($authName,'\p{P}','')),'[\s]+','+')
  
(: let $matchStringDirect := replace(lower-case(replace($eac//eac:nameEntry[attribute::localType="nixonNames/nameEntry/#directOrder"]/eac:part,'[,."]+','')),'[\s]+','+') :)

let $dasURL := concat('https://catalog.archives.gov/api/v1/?authority.person.name=',$matchString,$ampersand,'resultTypes=person',$ampersand,'format=xml')

let $dasMatch := 

  if (contains(doc($dasURL)/opaResponse/attribute::status,"200"))
  then
  
      for $dasResult in doc($dasURL)//result
        let $position := data($dasResult/num)
        let $naID := data($dasResult/naId)
        let $naraURL := concat('https://catalog.archives.gov/id/',$naID)
        let $naraURLname := concat('naraURL',$position)
        let $naraTerm := data($dasResult/authority/person/termName)
        let $naraAPI := xs:string(concat('https://catalog.archives.gov/api/v1/?authority.person.naId=',$naID,$ampersand,'resultTypes=person',$ampersand,'format=xml'))
        let $score := compare(lower-case($naraTerm),lower-case($authName))
        
        order by $score descending, $naraTerm ascending
      return 
        <dasHit>
          <naraURL>{$naraURL}</naraURL>
          <naraTerm>{$naraTerm}</naraTerm>
          <naraAPI>{$naraAPI}</naraAPI>
        </dasHit>      
    
    else 
    
      for $dasResult in doc($dasURL)
      return 
      <dasHit/>

order by $eac//eac:recordId ascending
return
  <record>
    <eacID>{$eacID}</eacID>
    <nixonName>{$authName}</nixonName>
    <dasMatch>
      {$dasMatch}
    </dasMatch>
  </record>
  
  