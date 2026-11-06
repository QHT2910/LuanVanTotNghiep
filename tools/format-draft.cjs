// Run after generating the initial DOCX; local document utilities only.
const fs=require('node:fs'),path=require('node:path');
const Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser,XMLSerializer}=require('../.local-tools/node_modules/@xmldom/xmldom');
const W='http://schemas.openxmlformats.org/wordprocessingml/2006/main';
const R='http://schemas.openxmlformats.org/officeDocument/2006/relationships';
const root=path.resolve(__dirname,'..');
const file=path.resolve(root,process.argv[2]||'thesis/Ban_thao_Chuong_1-3_v0.3.docx');
const parse=x=>new DOMParser().parseFromString(x,'text/xml');
const serial=x=>new XMLSerializer().serializeToString(x);
const all=(n,name)=>Array.from(n.getElementsByTagNameNS(W,name));
function child(n,name){let el=Array.from(n.childNodes).find(x=>x.namespaceURI===W&&x.localName===name);if(!el){el=n.ownerDocument.createElementNS(W,'w:'+name);n.appendChild(el);}return el;}
function attr(el,key,value){el.setAttributeNS(W,'w:'+key,String(value));}
(async()=>{
 const z=await Zip.loadAsync(fs.readFileSync(file)),d=parse(await z.file('word/document.xml').async('string'));
 const rel=parse(await z.file('word/_rels/document.xml.rels').async('string'));
 const types=parse(await z.file('[Content_Types].xml').async('string'));
 if(!Array.from(types.documentElement.childNodes).some(n=>n.getAttribute?.('Extension')==='png')){
  const e=types.createElementNS(types.documentElement.namespaceURI,'Default');e.setAttribute('Extension','png');e.setAttribute('ContentType','image/png');types.documentElement.appendChild(e);
 }
 let images=0;
 for(const p of all(d,'p')){
  const text=all(p,'t').map(x=>x.textContent).join('');
  const match=text.match(/^\[图片: Thiết kế đề xuất — ([23]-.*\.(?:mmd|svg))\]$/);
  if(match){
   const name=match[1].replace(/\.(mmd|svg)$/,'.png'),png=fs.readFileSync(path.join(root,'diagrams',name));
   const width=png.readUInt32BE(16),height=png.readUInt32BE(20);
   const publication=/v0\.6\.docx$/.test(file);
   const maxHeight=/^3-6/.test(name)?560:520;
   const ratio=publication?Math.min(431*12700/width,maxHeight*12700/height,0.34*12700):Math.min(5700000/width,7100000/height);
   const cx=Math.round(width*ratio),cy=Math.round(height*ratio);
   const id='rIdDiagram'+(++images);z.file('word/media/'+name,png);
   const re=rel.createElementNS(rel.documentElement.namespaceURI,'Relationship');re.setAttribute('Id',id);re.setAttribute('Type',R+'/image');re.setAttribute('Target','media/'+name);rel.documentElement.appendChild(re);
   const fragment=parse(`<w:p xmlns:w="${W}" xmlns:r="${R}" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0"><wp:extent cx="${cx}" cy="${cy}"/><wp:docPr id="${9000+images}" name="${name}" descr="Thiết kế đề xuất, chưa triển khai"/><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:nvPicPr><pic:cNvPr id="${images}" name="${name}"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip r:embed="${id}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="${cx}" cy="${cy}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>`);
   const imageParagraph=d.importNode(fragment.documentElement,true);
   if(/v0\.[56]\.docx$/.test(file))attr(child(child(imageParagraph,'pPr'),'keepNext'),'val',1);
   p.parentNode.replaceChild(imageParagraph,p);continue;
  }
  const pp=child(p,'pPr'),style=Array.from(pp.childNodes).find(n=>n.localName==='pStyle')?.getAttributeNS(W,'val')||'';
  const level=/Heading([1-4])/i.exec(style);
  const code=/v0\.[56]\.docx$/.test(file)&&all(pp,'shd').some(n=>n.getAttributeNS(W,'fill')==='F2F3F5');
  const size=code?20:level?({1:48,2:30,3:28,4:26}[level[1]]):26;
  const spacing=child(pp,'spacing');attr(spacing,'after',120);attr(spacing,'line',312);attr(spacing,'lineRule','auto');
  if(level){attr(child(pp,'keepNext'),'val',1);if(level[1]==='1'){attr(child(pp,'jc'),'val','right');attr(child(pp,'pageBreakBefore'),'val',1);}}
  if(code){attr(spacing,'before',0);attr(spacing,'after',0);attr(spacing,'line',240);}
  if(code&&/v0\.6\.docx$/.test(file)){
   let next=p.nextSibling;while(next&&next.nodeType!==1)next=next.nextSibling;
   const nextCode=next?.localName==='p'&&all(next,'shd').some(n=>n.getAttributeNS(W,'fill')==='F2F3F5');
   attr(child(pp,'keepNext'),'val',nextCode?1:0);
  }
  if(text==='Mã ví dụ (tiếp):')attr(child(pp,'keepNext'),'val',1);
  if(/^Hình [23]\.\d+/.test(text))attr(child(pp,'keepLines'),'val',1);
  for(const r of all(p,'r')){const rp=child(r,'rPr'),font=child(rp,'rFonts');for(const a of ['ascii','hAnsi','eastAsia','cs'])attr(font,a,code?'Consolas':'Times New Roman');attr(child(rp,'sz'),'val',size);attr(child(rp,'szCs'),'val',size);attr(child(rp,'color'),'val','000000');for(const name of ['b','bCs','caps','smallCaps'])attr(child(rp,name),'val',0);}
 }
 for(const s of all(d,'sectPr')){const sz=child(s,'pgSz');attr(sz,'w',11906);attr(sz,'h',16838);const m=child(s,'pgMar');for(const [key,value]of Object.entries({top:1134,bottom:1134,left:1701,right:1134,gutter:0}))attr(m,key,value);}
 let math={};
 if(/v0\.6\.docx$/.test(file)){
  math=require('./word-math.cjs')(d);
  for(const table of all(d,'tbl')){
   const rows=Array.from(table.childNodes).filter(n=>n.localName==='tr');
   const short=rows.length<=10&&table.textContent.length<2400;
   for(let i=0;i<rows.length;i++){
    attr(child(child(rows[i],'trPr'),'cantSplit'),'val',1);
    if(short&&i<rows.length-1)for(const p of all(rows[i],'p'))attr(child(child(p,'pPr'),'keepNext'),'val',1);
   }
  }
 }
 z.file('word/document.xml',serial(d));z.file('word/_rels/document.xml.rels',serial(rel));z.file('[Content_Types].xml',serial(types));
 const styles=parse(await z.file('word/styles.xml').async('string'));
 for(const rp of all(styles,'rPr'))for(const name of ['b','bCs','caps','smallCaps'])attr(child(rp,name),'val',0);
 z.file('word/styles.xml',serial(styles));
 const expectedImages=/v0\.6\.docx$/.test(file)?27:/v0\.5\.docx$/.test(file)?16:/v0\.4\.docx$/.test(file)?14:8;
 if(images!==expectedImages)throw Error('Expected '+expectedImages+' embedded diagrams (UI mockup excluded), got '+images);
 fs.writeFileSync(file,await z.generateAsync({type:'nodebuffer',compression:'DEFLATE'}));
 console.log(JSON.stringify({images,...math}));
})().catch(e=>{console.error(e);process.exit(1)});
