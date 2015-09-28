import module namespace functx = 'http://www.functx.com' at 'http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq';

declare option output:method "csv";
declare option output:csv "header=yes, separator=comma";

let $doc :=

<csv>
{
  
let $coll := collection("base")

for $p in subsequence($coll/nixonNames/participant,1,10)
(: for $p in $coll/nixonNames/participant :)
let $name := $p/directOrder/text()
let $id := data($p/(persname|corpname)/attribute::authfilenumber)
let $match :=
  for $p2 in $coll/nixonNames/participant
  let $p2name := $p2/directOrder/text()
  let $p2id := data($p2/(persname|corpname)/attribute::authfilenumber)
  let $row := subsequence($coll/root/row[not(contains(tapeNo,'test'))][participantsWithLineBreaks/(persname|corpname)/attribute::authfilenumber[matches(.,$p2id)]],1,10)
  let $count := count($row[participantsWithLineBreaks/(persname|corpname)/attribute::authfilenumber[matches(.,$id)]]
)
  order by $count descending
  return 
  <record>
    <person1>{$name}</person1>
    <person2>{$p2name}</person2>
    <frequency>{$count}</frequency>
  </record>
return
 
  $match
}
</csv>

return $doc