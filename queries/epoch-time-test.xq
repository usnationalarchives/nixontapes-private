xquery version "1.0";

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';

declare namespace xlink="http://www.w3.org/1999/xlink";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";   

let $coll := collection("nixontapes-private-base")

let $nl := "&#10;"
let $quote := "&#34;"

for $st in distinct-values($coll/root/row[not(contains(tapeNo,'test'))]/startDateTime)
  
  let $stEpoch := (xs:dateTime($st) - xs:dateTime("1970-01-01T00:00:00-00:00")) div xs:dayTimeDuration('PT1S')
  
  let $convoCount := count($coll/root/row[not(contains(tapeNo,'test'))][contains(startDateTime,$st)])
  
  let $heat := concat($quote,data($stEpoch),$quote,": ",$convoCount,",")
  
order by $stEpoch ascending
  
return $heat