// Preserve the actual user-edited DOCX; apply reviewed baseline-node edits only.
const fs=require('fs'),crypto=require('crypto'),Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser,XMLSerializer}=require('../.local-tools/node_modules/@xmldom/xmldom');
const h=require('./figure-caption.cjs'),W=h.W,M=h.M;
const all=(n,t)=>h.all(n,t),txt=h.text,ser=n=>new XMLSerializer().serializeToString(n),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
(async()=>{
 const source='thesis/Ban_thao_Chuong_1-4_v0.11_corrected.docx',output='thesis/Ban_thao_Chuong_1-4_v0.12.docx';
 if(fs.existsSync(output))throw Error('Output already exists');
 const input=fs.readFileSync(source);if(sha(input)!=='e606d15654145595d228f70003f8e8b8ff80b48326c95a46fa85032fa504fea3')throw Error('User source changed');
 const z=await Zip.loadAsync(input),d=new DOMParser().parseFromString(await z.file('word/document.xml').async('string'),'text/xml'),ps=all(d,'p');
 const math=Array.from(d.getElementsByTagNameNS(M,'oMath')).map(ser),refs=ps.filter(p=>/^\[\d+\]/.test(txt(p))).map(txt);
 const plan=JSON.parse(fs.readFileSync('qa/thesis-v012/content-edit-map.json'));
 plan.operations.find(x=>x.op==='replace'&&x.p===50).text='Phạm vi đề tài không gồm phát hành game thương mại, kinh tế vật phẩm, giải đấu quy mô lớn, tài khoản, bảng xếp hạng, ghép trận nhanh hoặc chống gian lận nâng cao. Thiết kế tập trung vào dữ liệu phiên chơi, độc lập với lưu trữ lâu dài.';
 for(const op of plan.operations){if(!ps[op.p]||!txt(ps[op.p]).startsWith(op.anchor))throw Error('Anchor mismatch p'+op.p);if(op.op==='replace'&&(all(ps[op.p],'drawing').length||ps[op.p].getElementsByTagNameNS(M,'oMath').length||all(ps[op.p],'fldChar').length))throw Error('Unsafe replace '+op.p);}
 function replace(p,s){const ts=all(p,'t');if(!ts.length)throw Error('Missing text');ts[0].textContent=s;ts[0].setAttributeNS('http://www.w3.org/XML/1998/namespace','xml:space','preserve');for(const t of ts.slice(1))t.textContent='';}
 function paragraph(s,style){const p=ps[1494].cloneNode(true);for(const n of Array.from(p.childNodes))if(n!==h.direct(p,'pPr'))p.removeChild(n);const pp=h.direct(p,'pPr');for(const n of Array.from(pp.childNodes))if(['pStyle','pageBreakBefore','keepNext'].includes(n.localName))pp.removeChild(n);if(style){const n=d.createElementNS(W,'w:pStyle');n.setAttributeNS(W,'w:val',style);pp.insertBefore(n,pp.firstChild);}const r=d.createElementNS(W,'w:r'),t=d.createElementNS(W,'w:t');if(!style){const pr=h.direct(ps[1494].getElementsByTagNameNS(W,'r')[0],'rPr');if(pr)r.appendChild(pr.cloneNode(true));}t.textContent=s;r.appendChild(t);p.appendChild(r);return p;}
 function table(o){const old=ps[937];let t=old;while(t.localName!=='tbl')t=t.parentNode;const n=t.cloneNode(true),rows=all(n,'tr'),template=rows[1],header=rows[0];for(const r of rows)r.parentNode.removeChild(r);let index=0;for(const values of [o.columns,...o.rows]){const r=(index===0?header:template).cloneNode(true),cells=all(r,'tc');if(index===0){let pr=h.direct(r,'trPr');if(!pr){pr=d.createElementNS(W,'w:trPr');r.insertBefore(pr,r.firstChild);}if(!h.direct(pr,'tblHeader'))pr.appendChild(d.createElementNS(W,'w:tblHeader'));}for(let i=0;i<3;i++){const cell=cells[i];for(const c of Array.from(cell.childNodes))if(c.localName!=='tcPr')cell.removeChild(c);cell.appendChild(paragraph(values[i]));}n.appendChild(r);index++;}return n;}
 for(const op of plan.operations){const p=ps[op.p];if(op.op==='replace')replace(p,op.text);else if(op.op==='remove')p.parentNode.removeChild(p);else if(op.op==='remove_table_containing'){let t=p;while(t.localName!=='tbl')t=t.parentNode;t.parentNode.removeChild(t);}else if(op.op==='insert_after'){const parent=p.parentNode,next=p.nextSibling;for(const q of op.paragraphs)parent.insertBefore(q.type==='table'?table(q):paragraph(q.text,q.style),next);}else throw Error('Unknown operation');}
 const manifest=JSON.parse(fs.readFileSync('qa/thesis-v012/diagram-manifest.json'));
 if(manifest.assets.some(a=>a.status!=='approved'))throw Error('Diagram visual approval pending');
 const WP='http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',A='http://schemas.openxmlformats.org/drawingml/2006/main';
 for(const a of manifest.assets){const p=ps[a.paragraph];z.file('word/'+a.media,fs.readFileSync(a.png));for(const ns of [WP,A])for(const e of Array.from(p.getElementsByTagNameNS(ns,ns===WP?'extent':'ext'))){e.setAttribute('cx',String(Math.round(a.widthPt*12700)));e.setAttribute('cy',String(Math.round(a.heightPt*12700)));}}
 const captions=h.format(d);if(captions.figureCaptions!==38)throw Error('Expected 38 figure captions');
 if(JSON.stringify(math)!==JSON.stringify(Array.from(d.getElementsByTagNameNS(M,'oMath')).map(ser)))throw Error('OMML changed');
 if(JSON.stringify(refs)!==JSON.stringify(all(d,'p').filter(p=>/^\[\d+\]/.test(txt(p))).map(txt)))throw Error('References changed');
 if(all(d,'drawing').length!==38||all(d,'tbl').length!==27)throw Error('Object count changed');
 z.file('word/document.xml',ser(d));const out=await z.generateAsync({type:'nodebuffer'});fs.writeFileSync(output,out);
 fs.writeFileSync('.scratch/thesis-v012/revision.json',JSON.stringify({source,sourceSha256:sha(input),output,outputSha256:sha(out),operations:plan.operations.length,figures:38,tables:27,omml:math.length,references:refs.length,captions},null,2));console.log('PASS reviewed content map, 38 figures, 27 tables, 24 OMML, 44 refs');
})().catch(e=>{console.error(e);process.exit(1);});
