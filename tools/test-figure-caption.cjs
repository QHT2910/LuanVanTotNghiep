const assert=require('node:assert/strict');
const {DOMParser,XMLSerializer}=require('../.local-tools/node_modules/@xmldom/xmldom');
const h=require('./figure-caption.cjs'),ser=n=>new XMLSerializer().serializeToString(n);
const parse=x=>new DOMParser().parseFromString('<w:document xmlns:w="'+h.W+'" xmlns:m="'+h.M+'" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body>'+x+'</w:body></w:document>','text/xml');
const head='<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:t>CHƯƠNG 3</w:t></w:r></w:p>';
const image='<w:p><w:r><w:drawing/></w:r></w:p>';
const d=parse(head+image+'<w:p><w:pPr><w:spacing w:after="77"/></w:pPr><w:bookmarkStart w:id="1" w:name="cap"/><w:r><w:t>Hì</w:t></w:r><w:r><w:t>nh 3.</w:t></w:r><w:r><w:t>6(b1). Tên initState [7].</w:t></w:r><w:bookmarkEnd w:id="1"/></w:p><w:tbl/><w:p><w:r><w:t>Bảng 3.1. Tên bảng</w:t></w:r></w:p><w:p><w:r><w:t>Hình 3.6(b1) mô tả SceneNode.</w:t></w:r></w:p><w:p><m:oMath><m:r><m:t>x</m:t></m:r></m:oMath></w:p>');
const ps=h.all(d,'p'),unchanged=ps.slice(3).map(ser);assert.equal(h.format(d).figureCaptions,1);
assert.equal(h.text(ps[2]),'Hình 3.6(b1): Tên initState [7].');assert.equal(h.all(ps[2],'bookmarkStart').length,1);assert.equal(h.all(ps[2],'bookmarkEnd').length,1);
assert.equal(h.direct(h.direct(ps[2],'pPr'),'spacing').getAttributeNS(h.W,'after'),'77');assert.deepEqual(ps.slice(3).map(ser),unchanged);
let pos=0;for(const r of h.all(ps[2],'r')){const t=h.text(r);if(!t)continue;const label=pos<12,pr=h.direct(r,'rPr');for(const tag of ['b','bCs','i','iCs'])assert.equal(h.direct(pr,tag).getAttributeNS(h.W,'val'),label?'1':'0');assert.equal(h.direct(pr,'u').getAttributeNS(h.W,'val'),label?'single':'none');pos+=t.length;}
const once=ser(d);h.format(d);assert.equal(ser(d),once);
const field=parse(head+image+'<w:p><w:bookmarkStart w:id="2"/><w:r><w:t>Hình 3.</w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText>SEQ Figure</w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>19</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r><w:hyperlink r:id="rId1"><w:r><w:t>: Tên [7].</w:t></w:r></w:hyperlink><w:bookmarkEnd w:id="2"/></w:p>');
const p=h.all(field,'p')[2],nontext=()=>[...h.all(p,'fldChar').map(n=>n.getAttributeNS(h.W,'fldCharType')),...h.all(p,'instrText').map(n=>n.textContent)];const order=nontext();h.format(field);assert.deepEqual(nontext(),order);assert.equal(h.all(p,'hyperlink')[0].getAttribute('r:id'),'rId1');assert.equal(h.text(p),'Hình 3.19: Tên [7].');assert.equal(h.all(p,'bookmarkStart').length,1);
assert.throws(()=>h.format(parse(head+image+'<w:p><w:r><w:t>Hình 2.1. Sai chương</w:t></w:r></w:p>')),/mismatch/);
const reference=parse(head+'<w:p><w:r><w:t>Hình 3.1: dùng trong đoạn dẫn chiếu.</w:t></w:r></w:p>');const raw=ser(reference);assert.equal(h.format(reference).figureCaptions,0);assert.equal(ser(reference),raw);
console.log('PASS split-label/panel/title/colon, bookmarks/fields/hyperlink, unchanged table/prose/OMML/After, idempotence, chapter mismatch');
