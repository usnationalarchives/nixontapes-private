import module namespace functx = 'http://www.functx.com' at 'http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq';

declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";

<csv>
{
  
let $coll := collection("base")

let $pres := "37-wht-eac-00002003"

for $p in subsequence($coll/nixonNames/participant,1,10)
(: for $p in $coll/nixonNames/participant :)
let $name := $p/directOrder/text()
let $id := data($p/(persname|corpname)/attribute::authfilenumber)
let $row := $coll/root/row[not(contains(tapeNo,'test'))][participantsWithLineBreaks/(persname|corpname)/attribute::authfilenumber[matches(.,$pres)]]
let $count := count($row[participantsWithLineBreaks/(persname|corpname)/attribute::authfilenumber[matches(.,$id)]]
)
order by $count descending
return 
<record>
  <person1>President Richard Nixon</person1>
  <person2>{$name}</person2>
  <frequency>{$count}</frequency>
</record>
}
</csv>
