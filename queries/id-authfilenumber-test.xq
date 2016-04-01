let $coll := collection("nixontapes-private-base")
for $nn in $coll/nixonNames/participant
let $id := data($nn/attribute::identifier)
let $auth := data($nn/(persname|corpname)/attribute::authfilenumber)
let $string := substring-after($auth,"37-wht-eac-")
return $string