// Read-only DOCX inventory; paragraph IDs refer to the actual supplied manuscript.
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser}=require('../.local-tools/node_modules/@xmldom/xmldom');
const input=process.argv[2],out=process.argv[3];if(!input||!out)throw Error('DOCX and output directory required');
const W='http://schemas.openxmlformats.org/wordprocessingml/2006/main',M='http://schemas.openxmlformats.org/officeDocument/2006/math';
const WP='http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',A='http://schemas.openxmlformats.org/drawingml/2006/main';
const R='http://schemas.openxmlformats.org/officeDocument/2006/relationships';
const all=(n,ns,t)=>Array.from(n.getElementsByTagNameNS(ns,t));
const direct=(n,t)=>Array.from(n?.childNodes||[]).find(x=>x.namespaceURI===W&&x.localName===t);
const val=n=>n?(n.hasAttributeNS(W,'val')?n.getAttributeNS(W,'val'):'1'):null;
(async()=>{
 fs.mkdirSync(out,{recursive:true});const bytes=fs.readFileSync(input),z=await Zip.loadAsync(bytes);
 const parse=s=>new DOMParser().parseFromString(s,'text/xml');
 const d=parse(await z.file('word/document.xml').async('string'));
 const rel=parse(await z.file('word/_rels/document.xml.rels').async('string'));
 const targets=Object.fromEntries(Array.from(rel.documentElement.childNodes).filter(n=>n.nodeType===1).map(n=>[n.getAttribute('Id'),n.getAttribute('Target')]));
 const styleDoc=parse(await z.file('word/styles.xml').async('string'));
 const styles={};for(const s of all(styleDoc,W,'style')){const pp=direct(s,'pPr');styles[s.getAttributeNS(W,'styleId')]={basedOn:val(direct(s,'basedOn')),keepNext:val(direct(pp,'keepNext')),keepLines:val(direct(pp,'keepLines'))};}
 const media=[];for(const name of Object.keys(z.files).filter(n=>n.startsWith('word/media/')&&!z.files[n].dir)){
  const b=await z.file(name).async('nodebuffer');let width=null,height=null;
  if(b.subarray(1,4).toString()==='PNG'){width=b.readUInt32BE(16);height=b.readUInt32BE(20);}
  media.push({name,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex'),width,height});
 }
 const paragraphs=all(d,W,'p').map((p,index)=>{
  const pp=direct(p,'pPr'),text=all(p,W,'t').map(n=>n.textContent).join(''),math=all(p,M,'t').map(n=>n.textContent).join('');
  let ancestor=p.parentNode,inTable=false;while(ancestor){if(ancestor.namespaceURI===W&&ancestor.localName==='tc')inTable=true;ancestor=ancestor.parentNode;}
  const spacing=direct(pp,'spacing');
  const drawings=all(p,W,'drawing').map(draw=>{const extent=all(draw,WP,'extent')[0],blip=all(draw,A,'blip')[0],rid=blip?.getAttributeNS(R,'embed');
   return {rid,target:targets[rid],widthPt:Number(extent?.getAttribute('cx'))/12700,heightPt:Number(extent?.getAttribute('cy'))/12700};});
  return {id:index,text,math,inTable,style:val(direct(pp,'pStyle')),keepNext:val(direct(pp,'keepNext')),keepLines:val(direct(pp,'keepLines')),
   pageBreakBefore:val(direct(pp,'pageBreakBefore')),explicitPageBreaks:all(p,W,'br').filter(n=>n.getAttributeNS(W,'type')==='page').length,
   before:spacing?.getAttributeNS(W,'before'),after:spacing?.getAttributeNS(W,'after'),line:spacing?.getAttributeNS(W,'line'),drawings,
   sectPr:!!direct(pp,'sectPr'),empty:!text.trim()&&!math&&!drawings.length};
 });
 const sections=all(d,W,'sectPr').map(s=>({type:val(direct(s,'type')),
  pageSize:direct(s,'pgSz')?.toString(),margins:direct(s,'pgMar')?.toString()}));
 const result={input,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),paragraphCount:paragraphs.length,
  drawings:paragraphs.reduce((n,p)=>n+p.drawings.length,0),tables:all(d,W,'tbl').length,omml:all(d,M,'oMath').length,
  trackedInsertions:all(d,W,'ins').length,trackedDeletions:all(d,W,'del').length,
  emptyParagraphs:paragraphs.filter(p=>p.empty).length,sections,styles,media,paragraphs};
 fs.writeFileSync(path.join(out,'docx-inventory.json'),JSON.stringify(result,null,2));
 fs.writeFileSync(path.join(out,'paragraphs.txt'),paragraphs.map(p=>`[p${p.id}${p.inTable?' table':''}${p.style?' '+p.style:''}] ${p.text}${p.math?' [MATH '+p.math+']':''}${p.drawings.length?' [IMAGE '+p.drawings.map(x=>x.target+' '+x.widthPt.toFixed(1)+'x'+x.heightPt.toFixed(1)+'pt').join(';')+']':''}`).join('\n'));
 console.log(JSON.stringify({paragraphs:result.paragraphCount,drawings:result.drawings,tables:result.tables,omml:result.omml,empty:result.emptyParagraphs,tracked:[result.trackedInsertions,result.trackedDeletions],sections}));
})().catch(e=>{console.error(e.message);process.exitCode=1;});
