const fs=require('node:fs'),path=require('node:path');
const Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser}=require('../.local-tools/node_modules/@xmldom/xmldom');
const root=path.resolve(__dirname,'..'),read=p=>fs.readFileSync(path.join(root,p),'utf8');
const expected=['1.1.2. Mục tiêu của đề tài','2.1. Các hệ thống tương tự','2.2. Nền tảng Flutter Scene','2.12. Hướng dẫn','3.3. Hệ thống màn hình'];
const current=['thesis/01-gioi-thieu.md','thesis/02-co-so-ly-thuyet.md','thesis/03-xay-dung-game.md'];
function check(ok,msg){if(!ok)throw Error(msg);}
(async()=>{
 const combined=read('thesis/BAN_THAO_CHUONG_1-3.md');
 for(const term of expected)check(combined.includes(term),'Missing section: '+term);
 for(const f of current){const s=read(f);check((s.match(/^```/gm)||[]).length%2===0,'Unbalanced fences: '+f);}
 const prose=combined.replace(/```[\s\S]*?```/g,'');
 check(!/\[\s*(SCENE-|LT\d|HT\d)/.test(prose),'Legacy citation IDs remain');
 check(!/PROJECT_BRIEF\.md|OUTLINE\.md|reviewed\.docx|Căn cứ nội bộ/.test(prose),'Internal management text in manuscript');
 check(!/\*\*/.test(prose),'Unexpected bold markup');
 check(!/3-9-wireframe/.test(combined),'Unaccepted generated UI in current manuscript');
 const ref=read('thesis/REFERENCES.md');const known=new Set([...ref.matchAll(/^\[(\d+)\]/gm)].map(m=>m[1]));
 check(known.size>0,'No numbered reference registry');
 for(const m of prose.matchAll(/\[(\d+(?:\s*,\s*\d+)*)\]/g))for(const n of m[1].split(/\s*,\s*/))check(known.has(n),'Unresolved citation ['+n+']');
 const ch3=read(current[2]);
 const diagrams=[...ch3.matchAll(/<!-- diagram: ([^\r\n]+) -->\s*```mermaid\s*([\s\S]*?)```/g)];
 for(const m of diagrams){check(read('diagrams/'+m[1]).trim()===m[2].trim(),'Diagram source mismatch: '+m[1]);check(fs.existsSync(path.join(root,'diagrams',m[1].replace('.mmd','.png'))),'Missing rendered diagram: '+m[1]);}
 check(ch3.includes('3-2-usecase-uml.svg'),'Current use case UML not referenced');
 const file=process.argv[2]||'thesis/Ban_thao_Chuong_1-3_v0.3.docx',z=await Zip.loadAsync(fs.readFileSync(path.join(root,file)));
 let xmlErrors=[];
 for(const name of Object.keys(z.files).filter(n=>/\.xml$|\.rels$/.test(n)))new DOMParser({onError:(level,msg)=>{if(level!=='warning')xmlErrors.push(name+': '+msg);}}).parseFromString(await z.file(name).async('string'),'text/xml');
 check(xmlErrors.length===0,xmlErrors.join('\n'));
 const doc=new DOMParser().parseFromString(await z.file('word/document.xml').async('string'),'text/xml'),W='http://schemas.openxmlformats.org/wordprocessingml/2006/main';
 const text=Array.from(doc.getElementsByTagNameNS(W,'t')).map(n=>n.textContent).join(' ');
 check(!/PROJECT_BRIEF\.md|OUTLINE\.md|reviewed\.docx|Căn cứ nội bộ|3-9-wireframe|\[图片:/.test(text),'Internal text or unresolved image placeholder in Word');
 for(const name of ['b','bCs','caps','smallCaps'])for(const el of Array.from(doc.getElementsByTagNameNS(W,name)))check(['0','false','off'].includes(el.getAttributeNS(W,'val')),'Unexpected emphasis in Word: '+name);
 const expectedImages=/v0\.5\.docx$/.test(file)?16:14;
 const media=Object.keys(z.files).filter(n=>/^word\/media\/.+\.png$/.test(n));check(media.length===expectedImages,'Expected '+expectedImages+' embedded diagrams');
 check(media.some(n=>n.includes('3-2-usecase-uml')),'New UML not embedded');
 console.log(JSON.stringify({result:'PASS',chapters:3,numberedReferences:known.size,mermaidSourcesCompared:diagrams.length,embeddedDiagrams:media.length,xmlWellFormed:true,paginationVisuallyVerified:false},null,2));
})().catch(e=>{console.error(e.message);process.exit(1);});
