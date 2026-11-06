// Local review images only: all pages plus 4-page layout contact sheets.
import fs from 'node:fs';
import path from 'node:path';
import {createCanvas} from '../.local-tools/node_modules/@napi-rs/canvas/index.js';
import {getDocument} from '../.local-tools/node_modules/pdfjs-dist/legacy/build/pdf.mjs';
const input=process.argv[2],out=process.argv[3];if(!input||!out)throw Error('Provide PDF and review directory');
fs.mkdirSync(out,{recursive:true});
const doc=await getDocument({data:new Uint8Array(fs.readFileSync(input)),useSystemFonts:true}).promise;
const pages=[],sheets=[];let montage;
for(let n=1;n<=doc.numPages;n++){
 const p=await doc.getPage(n),v=p.getViewport({scale:1.4});
 const c=createCanvas(v.width,v.height);await p.render({canvasContext:c.getContext('2d'),viewport:v}).promise;
 fs.writeFileSync(path.join(out,'page-'+n+'.png'),c.toBuffer('image/png'));
 const t=await p.getTextContent();pages.push({page:n,text:t.items.map(x=>x.str).join(' '),chars:t.items.reduce((sum,x)=>sum+x.str.length,0)});
 if((n-1)%4===0){montage=createCanvas(1000,1460);const ctx=montage.getContext('2d');ctx.fillStyle='white';ctx.fillRect(0,0,1000,1460);}
 const i=(n-1)%4,ctx=montage.getContext('2d');ctx.drawImage(c,(i%2)*500,Math.floor(i/2)*730,500,707);ctx.fillStyle='black';ctx.font='16px sans-serif';ctx.fillText('Page '+n,(i%2)*500+10,Math.floor(i/2)*730+725);
 if(n%4===0||n===doc.numPages){const name='sheet-'+Math.ceil(n/4)+'.png';fs.writeFileSync(path.join(out,name),montage.toBuffer('image/png'));sheets.push(name);}
}
fs.writeFileSync(path.join(out,'pages.json'),JSON.stringify({pages:doc.numPages,sheets,text:pages},null,2));
console.log(JSON.stringify({result:'PASS',pages:doc.numPages,sheets:sheets.length,reviewDir:out}));await doc.cleanup();
