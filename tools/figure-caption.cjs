'use strict';
const W='http://schemas.openxmlformats.org/wordprocessingml/2006/main';
const M='http://schemas.openxmlformats.org/officeDocument/2006/math';
const XML='http://www.w3.org/XML/1998/namespace';
const all=(n,t)=>Array.from(n.getElementsByTagNameNS(W,t));
const direct=(n,t)=>Array.from(n?.childNodes||[]).find(x=>x.namespaceURI===W&&x.localName===t);
const text=p=>all(p,'t').map(n=>n.textContent).join('');
function set(d,n,t,v){let x=direct(n,t);if(!x){x=d.createElementNS(W,'w:'+t);n.appendChild(x);}x.setAttributeNS(W,'w:val',v);return x;}
function previousObject(p){
 let q=p.previousSibling;
 while(q){if(q.nodeType===1){
  if(q.namespaceURI!==W)return null;
  if(q.localName==='tbl')return 'table';
  if(q.localName!=='p')return null;
  if(all(q,'drawing').length||all(q,'pict').length)return 'figure';
  if(text(q).trim()||all(q,'fldChar').length||all(q,'instrText').length||all(q,'br').length||all(q,'sectPr').length||q.getElementsByTagNameNS(M,'oMath').length)return null;
 }q=q.previousSibling;}return null;
}
function inventory(d){
 const body=all(d,'body')[0],out=new Map();let chapter=null;
 for(const p of Array.from(body.childNodes).filter(x=>x.nodeType===1&&x.namespaceURI===W&&x.localName==='p')){
  const t=text(p),ch=/^\s*CHƯƠNG\s+([1-5])(?:\s|[.:]|$)/iu.exec(t),pp=direct(p,'pPr');
  const heading=direct(pp,'pStyle')?.getAttributeNS(W,'val')||'';
  if(ch&&(/Heading1/i.test(heading)||direct(pp,'outlineLvl')?.getAttributeNS(W,'val')==='0')){chapter=Number(ch[1]);continue;}
  if(p.getElementsByTagNameNS(M,'oMath').length||p.getElementsByTagNameNS(M,'oMathPara').length)continue;
  const m=/^((Hình|Bảng)\s+(\d+)[.](\d+)(?:\s*\([a-z]\d*\))?)\s*([.:])/u.exec(t);if(!m)continue;
  const kind=previousObject(p);if(kind!==(m[2]==='Hình'?'figure':'table'))continue;
  if(chapter==null||Number(m[3])!==chapter)throw Error('Caption/chapter mismatch: '+t);
  if(all(p,'drawing').length||all(p,'pict').length)throw Error('Embedded object inside caption');
  out.set(p,{kind,labelEnd:m[1].length,separator:m[0].length-1,text:t,chapter});
 }return out;
}
function plainOrLabel(d,r,label){
 let pr=direct(r,'rPr');if(!pr){pr=d.createElementNS(W,'w:rPr');r.insertBefore(pr,r.firstChild);}
 for(const t of ['b','bCs','i','iCs'])set(d,pr,t,label?'1':'0');
 set(d,pr,'u',label?'single':'none');set(d,pr,'sz','26');set(d,pr,'szCs','26');
 let f=direct(pr,'rFonts');if(!f){f=d.createElementNS(W,'w:rFonts');pr.appendChild(f);}
 for(const k of ['asciiTheme','hAnsiTheme','eastAsiaTheme','cstheme','csTheme'])f.removeAttributeNS(W,k);
 for(const k of ['ascii','hAnsi','eastAsia','cs'])f.setAttributeNS(W,'w:'+k,'Times New Roman');
}
function splitRun(d,r,start,end){
 const pr=direct(r,'rPr'),pieces=[];let offset=start,current=null,currentRole=null;
 function part(role){if(!current||currentRole!==role){current=r.cloneNode(false);if(pr)current.appendChild(pr.cloneNode(true));pieces.push({node:current,role});currentRole=role;}return current;}
 for(const child of Array.from(r.childNodes)){
  if(child===pr)continue;
  if(child.namespaceURI===W&&child.localName==='t'){
   const value=child.textContent;let i=0;
   while(i<value.length){const role=offset<end,n=Math.min(value.length-i,role?end-offset:value.length-i),node=child.cloneNode(false);node.textContent=value.slice(i,i+n);node.setAttributeNS(XML,'xml:space','preserve');part(role).appendChild(node);i+=n;offset+=n;}
   if(!value.length)part(offset<end).appendChild(child.cloneNode(true));
  }else part(offset<end).appendChild(child.cloneNode(true));
 }
 for(const item of pieces){if(all(item.node,'t').some(n=>n.textContent.length))plainOrLabel(d,item.node,item.role);r.parentNode.insertBefore(item.node,r);}
 r.parentNode.removeChild(r);return offset;
}
function format(d){
 const inv=inventory(d);let figures=0;
 for(const [p,info] of inv){if(info.kind!=='figure')continue;
  let offset=0;for(const t of all(p,'t')){const v=t.textContent;if(info.separator>=offset&&info.separator<offset+v.length){const i=info.separator-offset;t.textContent=v.slice(0,i)+':'+v.slice(i+1);}offset+=v.length;}
  offset=0;for(const r of all(p,'r')){
   let ancestor=r.parentNode;while(ancestor&&!(ancestor.namespaceURI===W&&ancestor.localName==='p'))ancestor=ancestor.parentNode;
   if(ancestor!==p)throw Error('Nested paragraph inside caption');offset=splitRun(d,r,offset,info.labelEnd);
  }
  let pp=direct(p,'pPr');if(!pp){pp=d.createElementNS(W,'w:pPr');p.insertBefore(pp,p.firstChild);}
  set(d,pp,'jc','center');set(d,pp,'keepLines','1');set(d,pp,'keepNext','0');
  const sp=set(d,pp,'spacing','');sp.removeAttributeNS(W,'val');sp.setAttributeNS(W,'w:before','120');sp.setAttributeNS(W,'w:line','312');sp.setAttributeNS(W,'w:lineRule','auto');
  figures++;
 }return {figureCaptions:figures,mode:'caption-only'};
}
module.exports={W,M,all,direct,text,inventory,format};
