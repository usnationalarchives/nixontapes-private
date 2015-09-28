import module namespace functx = 'http://www.functx.com' at 'http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq';

import module namespace simp = 'http://zorba.io/modules/data-cleaning/phonetic-string-similarity' at 'https://raw.githubusercontent.com/28msec/zorba-data-cleaning-module/master/src/phonetic-string-similarity.xq';

let $a := simp:soundex-key('ross')
let $b := simp:soundex-key('rouseau')
where $a = $b
return <line>match</line>