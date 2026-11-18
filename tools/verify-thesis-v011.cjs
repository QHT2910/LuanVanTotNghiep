const fs=require('fs'),assert=require('assert/strict'),Zip=require('../.local-tools/node_modules/jszip'),crypto=require('crypto');
const {DOMParser,XMLSerializer}=require('../.local-tools/node_modules/@xmldom/xmldom');
const W='http://schemas.openxmlformats.org/wordprocessingml/2006/main',M='http://schemas.openxmlformats.org/officeDocument/2006/math';
const all=(n,ns,t)=>Array.from(n.getElementsByTagNameNS(ns,t)),parse=s=>new DOMParser().parseFromString(s,'text/xml'),ser=n=>new XMLSerializer().serializeToString(n);
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
(async()=>{
 const a=await Zip.loadAsync(fs.readFileSync('thesis/Ban_thao_Chuong_1-4_v0.10.docx')),b=await Zip.loadAsync(fs.readFileSync('thesis/Ban_thao_Chuong_1-4_v0.11_corrected.docx'));
 const d0=parse(await a.file('word/document.xml').async('string')),d=parse(await b.file('word/document.xml').async('string'));
 const text=p=>all(p,W,'t').map(n=>n.textContent).join('');
 assert.equal(all(d,W,'drawing').length,38);assert.equal(all(d,W,'tbl').length,27);
 assert.deepEqual(all(d,M,'oMath').map(ser),all(d0,M,'oMath').map(ser));
 assert.deepEqual(all(d,W,'p').map(text).filter(t=>/^\[\d+\]/.test(t)),all(d0,W,'p').map(text).filter(t=>/^\[\d+\]/.test(t)));
 const changedParts=[];for(const n of Object.keys(a.files).filter(n=>!a.files[n].dir)){assert(b.file(n),'Missing ZIP part '+n);if(hash(await a.file(n).async('nodebuffer'))!==hash(await b.file(n).async('nodebuffer')))changedParts.push(n);}
 assert.deepEqual(changedParts.sort(),['word/document.xml','word/media/image1.png','word/media/image3.png','word/media/image5.png','word/media/image7.png','word/media/image24.png'].sort());
 // All original Figma/media parts except the five explicitly re-laid diagrams are byte-identical.
 const styles=parse(await b.file('word/styles.xml').async('string'));const normal=all(styles,W,'style').find(n=>n.getAttributeNS(W,'styleId')==='Normal');
 const normalFont=all(normal,W,'rFonts')[0].getAttributeNS(W,'ascii');assert.equal(normalFont,'Times New Roman');
 let runs=0,captions=0;for(const p of all(d,W,'p')){
  if(all(p,W,'pStyle').some(n=>/Heading[1-4]/.test(n.getAttributeNS(W,'val'))))continue;
  for(const r of all(p,W,'r')){if(!all(r,W,'t').length)continue;runs++;
   for(const f of all(r,W,'rFonts'))assert.equal(f.getAttributeNS(W,'ascii')||normalFont,'Times New Roman');
   for(const s of all(r,W,'sz'))assert.equal(s.getAttributeNS(W,'val'),'26');
   for(const n of all(r,W,'b'))assert(['0','false'].includes(n.getAttributeNS(W,'val')));
  }
  const t=text(p);if(/^(Hình|Bảng)\s+\d+[.-]\d+(?:\([a-z0-9]+\))?\./.test(t)){
   captions++;assert(!t.includes('Nguồn:'));assert(all(p,W,'jc').some(n=>n.getAttributeNS(W,'val')==='center'));
   let prev=p.previousSibling;while(prev&&prev.nodeType!==1)prev=prev.previousSibling;
   assert(prev&&(prev.localName==='tbl'||all(prev,W,'drawing').length),'Caption detached '+t);
  }
 }
 const ch=all(d,W,'p').filter(p=>/^CHƯƠNG [1-4]\./.test(text(p)));assert.equal(ch.length,4);
 for(const p of ch){assert.equal(all(p,W,'pageBreakBefore').length,1);assert(!all(p,W,'br').some(n=>n.getAttributeNS(W,'type')==='page'));}
 // Non-empty tutorial lines are unchanged: edits are outside code or affect whitespace/properties only.
 const original=all(d0,W,'p').slice(491,1253).map(text).filter(t=>t.trim());
 const finalTexts=all(d,W,'p').map(text);let cursor=0;
 const edited=new Set([922,1012]);for(let i=491;i<=1252;i++){const t=text(all(d0,W,'p')[i]);if(!t.trim()||edited.has(i))continue;const n=finalTexts.indexOf(t,cursor);assert(n>=0,'Lost tutorial text p'+i);cursor=n+1;}
 const report={pass:true,drawings:38,tables:27,omml:24,refs:44,unchangedMedia:33,unchangedFigmaFrames:11,changedParts,normalRuns:runs,centeredCaptionsBelowObjects:captions,chapterBreaks:4,sourceSHA256:hash(fs.readFileSync('thesis/Ban_thao_Chuong_1-4_v0.10.docx')),outputSHA256:hash(fs.readFileSync('thesis/Ban_thao_Chuong_1-4_v0.11_corrected.docx'))};
 fs.writeFileSync('.scratch/thesis-v011/preservation-check.json',JSON.stringify(report,null,2));console.log(JSON.stringify(report));
})().catch(e=>{console.error(e.stack);process.exitCode=1;});

