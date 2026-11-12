// Read the reviewed DOCX into a self-contained print view when native Word PDF export stalls.
const fs=require('node:fs'),path=require('node:path');
const Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser}=require('../.local-tools/node_modules/@xmldom/xmldom');
const W='http://schemas.openxmlformats.org/wordprocessingml/2006/main',M='http://schemas.openxmlformats.org/officeDocument/2006/math';
const esc=s=>s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
const elems=n=>Array.from(n.childNodes||[]).filter(x=>x.nodeType===1);
const find=(n,ns,t)=>Array.from(n.getElementsByTagNameNS(ns,t));
(async()=>{
 const z=await Zip.loadAsync(fs.readFileSync(process.argv[2]));
 const parse=s=>new DOMParser().parseFromString(s,'text/xml');
 const d=parse(await z.file('word/document.xml').async('string')),rel=parse(await z.file('word/_rels/document.xml.rels').async('string'));
 const links=Object.fromEntries(elems(rel.documentElement).map(n=>[n.getAttribute('Id'),n.getAttribute('Target')]));
 const media={};for(const n of Object.keys(z.files).filter(n=>/^word\/media\/.+png$/.test(n)))media[n]=await z.file(n).async('base64');
 function math(n){const children=()=>elems(n).map(math).join('');switch(n.localName){
 case 'r':return '<mi>'+esc(find(n,M,'t').map(x=>x.textContent).join(''))+'</mi>';
 case 'sSub':return '<msub>'+math(elems(n).find(x=>x.localName==='e'))+math(elems(n).find(x=>x.localName==='sub'))+'</msub>';
 case 'sSup':return '<msup>'+math(elems(n).find(x=>x.localName==='e'))+math(elems(n).find(x=>x.localName==='sup'))+'</msup>';
 case 'nary':{const pr=elems(n).find(x=>x.localName==='naryPr'),symbol=find(pr,M,'chr')[0]?.getAttributeNS(M,'val')||'∫',sub=elems(n).find(x=>x.localName==='sub'),body=elems(n).find(x=>x.localName==='e');return '<mrow><munder><mo>'+esc(symbol)+'</mo>'+math(sub)+'</munder>'+math(body)+'</mrow>';}
 case 'oMath':return '<math xmlns="http://www.w3.org/1998/Math/MathML">'+children()+'</math>';
 case 'oMathPara':return '<div class="equation">'+children()+'</div>';
 default:return '<mrow>'+children()+'</mrow>';
 }}
 function inline(n){if(n.namespaceURI===M)return math(n);switch(n.localName){case 't':return esc(n.textContent);case 'tab':return '    ';case 'br':return '<br>';case 'rPr':case 'pPr':return '';default:return elems(n).map(inline).join('');}}
 function para(n){
  const picture=find(n,'http://schemas.openxmlformats.org/drawingml/2006/main','blip')[0];
  if(picture){const target=links[picture.getAttributeNS('http://schemas.openxmlformats.org/officeDocument/2006/relationships','embed')],key=path.posix.normalize('word/'+target),ex=find(n,'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing','extent')[0];const width=Number(ex.getAttribute('cx'))/12700;return '<figure><img style="width:'+width+'pt" src="data:image/png;base64,'+media[key]+'"></figure>';}
  const text=find(n,W,'t').map(x=>x.textContent).join(''),pp=elems(n).find(x=>x.localName==='pPr'),style=pp?find(pp,W,'pStyle')[0]?.getAttributeNS(W,'val')||'':'',level=/Heading([1-4])/i.exec(style),code=pp&&find(pp,W,'shd').some(x=>x.getAttributeNS(W,'fill')==='F2F3F5');
  const content=elems(n).map(inline).join('');if(!content)return '';
  if(code)return '<div class="code-line">'+content+'</div>';
  if(level)return '<h'+level[1]+'>'+content+'</h'+level[1]+'>';
  return '<p'+(/^Hình [23]\.\d/.test(text)?' class="caption"':/^Bảng [123][.-]/.test(text)?' class="table-caption"':'')+'>'+content+'</p>';
 }
 const body=find(d,W,'body')[0],out=[];
 for(const n of elems(body)){
  if(n.localName==='p')out.push(para(n));
  if(n.localName==='tbl'){
   const short=elems(n).filter(x=>x.localName==='tr').length<=10&&n.textContent.length<2400;
   const rows=elems(n).filter(x=>x.localName==='tr');
   const rowHTML=row=>'<tr>'+elems(row).filter(x=>x.localName==='tc').map(cell=>'<td>'+elems(cell).filter(x=>x.localName==='p').map(para).join('')+'</td>').join('')+'</tr>';
   const header=rows.length&&find(rows[0],W,'tblHeader').some(x=>!['0','false'].includes(x.getAttributeNS(W,'val')));
   out.push('<table'+(short?' class="short"':'')+'>'+(header?'<thead style="display:table-header-group">'+rowHTML(rows[0])+'</thead><tbody>'+rows.slice(1).map(rowHTML).join('')+'</tbody>':rows.map(rowHTML).join(''))+'</table>');
  }
 }
 let bodyHtml=out.join('\n');bodyHtml=bodyHtml.replace(/(<div class="code-line">[\s\S]*?<\/div>)(?:\n)?(?=<div class="code-line">)/g,'$1');bodyHtml=bodyHtml.replace(/(?:<div class="code-line">[\s\S]*?<\/div>)+/g,m=>'<section class="code-chunk">'+m+'</section>');
 const html='<!doctype html><html lang="vi"><meta charset="utf-8"><title>Luận văn — bản thảo v0.6</title><style>@page{size:A4;margin:20mm 20mm 20mm 30mm}body{font-family:"Times New Roman",serif;font-size:13pt;line-height:1.3;color:#000}h1,h2,h3,h4{font-weight:normal;break-after:avoid;margin:16pt 0 9pt}h1{font-size:24pt;break-before:page;text-align:right}h1:first-child{break-before:auto}h2{font-size:15pt}h3{font-size:14pt}h4{font-size:13pt}p{margin:0 0 6pt;orphans:3;widows:3;overflow-wrap:anywhere}table{border-collapse:collapse;width:100%;margin:8pt 0;font-size:11pt}td{border:0.5pt solid #999;padding:4pt;vertical-align:top}td p{margin:0}tr{break-inside:avoid}table.short{break-inside:avoid}figure{text-align:center;margin:8pt 0 4pt;break-inside:avoid;break-after:avoid}img{max-width:100%;height:auto}.caption{break-inside:avoid;text-align:center;font-weight:normal;font-style:normal}.table-caption{text-align:center;font-weight:normal;font-style:normal;break-before:avoid}.code-chunk{break-inside:avoid;margin:8pt 0}.code-line{font:10pt/1.15 Consolas,monospace;white-space:pre-wrap;overflow-wrap:anywhere;margin:0}math{font-family:"Cambria Math",math;font-size:13pt}.equation{margin:9pt 0;text-align:center;break-inside:avoid}math mi{font-style:normal}</style><body>'+bodyHtml+'</body></html>';
 const finalHtml=html.replace('</style>','body{line-height:1.2}p{margin-bottom:4pt}h1:first-child{margin-top:0}td:first-child{min-width:54pt}table{break-after:avoid}</style>');
 const v08=/v0\.(?:8|9|10)\.docx$/.test(process.argv[2]||'');
 const publicationVersion=/v0\.10\.docx$/.test(process.argv[2]||'')?'v0.10':'v0.9';
 const output=v08?finalHtml.replace('Luận văn — bản thảo v0.6','Luận văn — DRAFT '+publicationVersion+', Chương 1–4; bổ sung thiết kế giao diện').replace('</style>','body{line-height:1.3}p{margin:6pt 0 6pt}h1,h2,h3,h4{margin:6pt 0 6pt;font-family:"Times New Roman",serif;line-height:1.3}h1:first-child{margin-top:6pt}h1,h2,h3{font-weight:bold}h1,h2{text-transform:uppercase}h4{font-weight:normal;text-decoration:underline}table{font-size:13pt;line-height:1.3}td p{margin:6pt 0 6pt}.code-line{font:13pt/1.3 "Times New Roman",serif;margin:6pt 0 0}.code-chunk{margin:6pt 0 0}.equation{margin:6pt 0}math{font-size:13pt}</style>'):finalHtml.replace('Luận văn — bản thảo v0.6','Luận văn — bản thảo');
 fs.writeFileSync(process.argv[3],output);console.log('PASS self-contained publication HTML from reviewed Word: '+Object.keys(media).length+' images; '+(v08?'v0.8 user styles':'legacy styles'));
})().catch(e=>{console.error(e);process.exit(1);});
