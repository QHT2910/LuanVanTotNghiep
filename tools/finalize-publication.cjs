const fs=require('node:fs');
const Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser,XMLSerializer}=require('../.local-tools/node_modules/@xmldom/xmldom');
const W='http://schemas.openxmlformats.org/wordprocessingml/2006/main';
(async()=>{
 const file=process.argv[2];if(!/v0\.(?:6|7|8|9|10)\.docx$/.test(file||''))throw Error('Only v0.6/v0.7/v0.8');
 const z=await Zip.loadAsync(fs.readFileSync(file)),parse=s=>new DOMParser().parseFromString(s,'text/xml'),d=parse(await z.file('word/document.xml').async('string'));
 const all=(n,t)=>Array.from(n.getElementsByTagNameNS(W,t));let count=0;
 function set(n,t,v){let x=Array.from(n.childNodes).find(x=>x.localName===t);if(!x){x=d.createElementNS(W,'w:'+t);n.appendChild(x);}x.setAttributeNS(W,'w:val',v);}
 for(const table of all(d,'tbl')){const rows=Array.from(table.childNodes).filter(x=>x.localName==='tr');
 if(rows.length&&/ID ca/.test(rows[0].textContent)&&/KT01/.test(table.textContent)){
  let pr=Array.from(rows[0].childNodes).find(x=>x.localName==='trPr');
  if(!pr){pr=d.createElementNS(W,'w:trPr');rows[0].insertBefore(pr,rows[0].firstChild);}set(pr,'tblHeader','1');
 }
 if(rows.length>10||table.textContent.length>=2400)continue;count++;
 for(let i=0;i<rows.length;i++)for(const p of all(rows[i],'p')){let pp=Array.from(p.childNodes).find(x=>x.localName==='pPr');if(!pp){pp=d.createElementNS(W,'w:pPr');p.insertBefore(pp,p.firstChild);}set(pp,'keepNext',i<rows.length-1?'1':'0');}
 }
 if(/v0\.(?:8|9|10)\.docx$/.test(file))require('./normal-publication.cjs')(d);
 z.file('word/document.xml',new XMLSerializer().serializeToString(d));const c=parse(await z.file('docProps/core.xml').async('string'));
 for(const n of Array.from(c.getElementsByTagName('*')))if(['creator','lastModifiedBy'].includes(n.localName))n.textContent='Cindy';
 z.file('docProps/core.xml',new XMLSerializer().serializeToString(c));fs.writeFileSync(file,await z.generateAsync({type:'nodebuffer',compression:'DEFLATE'}));console.log('PASS short-table groups '+count+'; neutral document metadata');
})().catch(e=>{console.error(e);process.exit(1);});
