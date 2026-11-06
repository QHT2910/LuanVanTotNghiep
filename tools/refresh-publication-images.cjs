const fs=require('node:fs'),path=require('node:path');
const Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser,XMLSerializer}=require('../.local-tools/node_modules/@xmldom/xmldom');
const W='http://schemas.openxmlformats.org/wordprocessingml/2006/main';
const root=path.resolve(__dirname,'..'),file=path.resolve(root,process.argv[2]||'');
if(!file.endsWith('v0.6.docx')||!file.startsWith(root+path.sep))throw Error('Only current v0.6 publication may be refreshed');
(async()=>{
 const z=await Zip.loadAsync(fs.readFileSync(file)),parse=s=>new DOMParser().parseFromString(s,'text/xml');
 const d=parse(await z.file('word/document.xml').async('string')),rel=parse(await z.file('word/_rels/document.xml.rels').async('string'));let updated=0;
 for(const p of Array.from(d.getElementsByTagName('wp:inline'))){
  const name=p.getElementsByTagName('wp:docPr')[0]?.getAttribute('name');if(!/^3-6.*v06\.png$/.test(name||''))continue;
  const id=p.getElementsByTagName('a:blip')[0].getAttribute('r:embed'),link=Array.from(rel.documentElement.childNodes).find(n=>n.getAttribute?.('Id')===id);
  const png=fs.readFileSync(path.join(root,'diagrams',name)),w=png.readUInt32BE(16),h=png.readUInt32BE(20),r=Math.min(431*12700/w,560*12700/h,0.34*12700),cx=Math.round(w*r),cy=Math.round(h*r);
  z.file('word/'+link.getAttribute('Target'),png);
  const e=p.getElementsByTagName('wp:extent')[0];e.setAttribute('cx',String(cx));e.setAttribute('cy',String(cy));
  for(const x of Array.from(p.getElementsByTagName('a:ext'))){x.setAttribute('cx',String(cx));x.setAttribute('cy',String(cy));}updated++;
 }
 const core=z.file('docProps/core.xml');if(core){const c=parse(await core.async('string'));for(const n of Array.from(c.getElementsByTagName('cp:lastModifiedBy')))n.textContent='Cindy';z.file('docProps/core.xml',new XMLSerializer().serializeToString(c));}
 z.file('word/document.xml',new XMLSerializer().serializeToString(d));fs.writeFileSync(file,await z.generateAsync({type:'nodebuffer',compression:'DEFLATE'}));if(updated!==5)throw Error('Expected five sequence panels, got '+updated);console.log('PASS refreshed five sequence panels');
})().catch(e=>{console.error(e.message);process.exit(1);});
