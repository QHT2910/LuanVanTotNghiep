// Isolate each PDF page/font cache; keep a complete native-PDF review trail.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {createCanvas,loadImage} from '../.local-tools/node_modules/@napi-rs/canvas/index.js';
import {getDocument} from '../.local-tools/node_modules/pdfjs-dist/legacy/build/pdf.mjs';
const [input,out,pageArgument]=process.argv.slice(2),root=path.resolve('.');
if(!input||!out)throw Error('PDF and review directory required');
for(const p of [input,out])if(!path.resolve(p).startsWith(root+path.sep))throw Error('Outside project');
fs.mkdirSync(out,{recursive:true});
const pdf=await getDocument({data:new Uint8Array(fs.readFileSync(input)),useSystemFonts:true}).promise;
if(pageArgument){
 const n=Number(pageArgument);if(!Number.isInteger(n)||n<1||n>pdf.numPages)throw Error('Invalid page');
 const page=await pdf.getPage(n),viewport=page.getViewport({scale:2}),canvas=createCanvas(Math.ceil(viewport.width),Math.ceil(viewport.height));
 await page.render({canvasContext:canvas.getContext('2d'),viewport}).promise;
 fs.writeFileSync(path.join(out,`page-${n}.png`),canvas.toBuffer('image/png'));
 const tc=await page.getTextContent(),items=tc.items.filter(x=>x.str?.trim());
 const outside=items.filter(i=>i.transform[4]<0||i.transform[4]+i.width>page.view[2]+2||i.transform[5]<0||i.transform[5]>page.view[3]+2).map(i=>i.str.slice(0,100));
 fs.writeFileSync(path.join(out,`page-${n}.json`),JSON.stringify({page:n,text:items.map(i=>i.str).join(' '),outside}));
 await pdf.cleanup();
}else{
 const count=pdf.numPages;if(count>400)throw Error('Review page budget exceeded');await pdf.cleanup();
 const items=[],outside=[];
 for(let n=1;n<=count;n++){
  const r=spawnSync(process.execPath,[fileURLToPath(import.meta.url),input,out,String(n)],{encoding:'utf8',windowsHide:true,maxBuffer:1024*1024});
  if(r.status!==0)throw Error(`Page ${n}: ${r.stderr||r.error||r.status}`);
  const p=JSON.parse(fs.readFileSync(path.join(out,`page-${n}.json`),'utf8'));
  items.push({page:n,chars:p.text.length,preview:p.text.slice(0,220)});outside.push(...p.outside.map(text=>({page:n,text})));
  if(n%10===0)console.log(`Rendered ${n}/${count}`);
 }
 for(let start=1;start<=count;start+=4){
  const c=createCanvas(1220,1750),ctx=c.getContext('2d');ctx.fillStyle='white';ctx.fillRect(0,0,c.width,c.height);
  for(let k=0;k<4&&start+k<=count;k++){
   const im=await loadImage(path.join(out,`page-${start+k}.png`)),x=10+(k%2)*610,y=30+Math.floor(k/2)*875;
   ctx.fillStyle='black';ctx.font='18px sans-serif';ctx.fillText('Page '+(start+k),x,y-8);ctx.drawImage(im,x,y,590,834);
  }
  fs.writeFileSync(path.join(out,`sheet-${String(Math.ceil(start/4)).padStart(2,'0')}.png`),c.toBuffer('image/png'));
 }
 fs.writeFileSync(path.join(out,'pages.json'),JSON.stringify({pages:count,renderer:'PDF.js isolated process per page, scale2',textOutsidePhysicalPage:outside,items},null,2));
 console.log(JSON.stringify({rendered:count,sheets:Math.ceil(count/4),textOutsidePhysicalPage:outside.length,isolated:true}));
}
