import fs from 'node:fs';
import path from 'node:path';
import {createCanvas,loadImage} from '../.local-tools/node_modules/@napi-rs/canvas/index.js';
import {getDocument} from '../.local-tools/node_modules/pdfjs-dist/legacy/build/pdf.mjs';
const file=process.argv[2],out=process.argv[3];if(!file||!out)throw Error('PDF and review directory required');
const root=path.resolve('.');for(const p of [file,out]){const full=path.resolve(p);if(!full.startsWith(root+path.sep))throw Error('Outside project');}
fs.mkdirSync(out,{recursive:true});const pdf=await getDocument({data:new Uint8Array(fs.readFileSync(file)),useSystemFonts:true}).promise;
const pages=[],bounds=[];
for(let n=1;n<=pdf.numPages;n++){const p=await pdf.getPage(n),v=p.getViewport({scale:1.2}),c=createCanvas(Math.ceil(v.width),Math.ceil(v.height));await p.render({canvasContext:c.getContext('2d'),viewport:v}).promise;fs.writeFileSync(path.join(out,`page-${n}.png`),c.toBuffer('image/png'));const text=await p.getTextContent();const items=text.items.filter(i=>i.str?.trim());for(const i of items)if(i.transform[4]<0||i.transform[4]+i.width>p.view[2]+2||i.transform[5]<0||i.transform[5]>p.view[3]+2)bounds.push({page:n,text:i.str.slice(0,80)});pages.push({page:n,chars:items.map(i=>i.str).join('').length,preview:items.map(i=>i.str).join(' ').slice(0,220)});p.cleanup();}
for(let start=1;start<=pdf.numPages;start+=4){const c=createCanvas(1220,1750),ctx=c.getContext('2d');ctx.fillStyle='white';ctx.fillRect(0,0,c.width,c.height);for(let k=0;k<4&&start+k<=pdf.numPages;k++){const img=await loadImage(path.join(out,`page-${start+k}.png`)),x=10+(k%2)*610,y=30+Math.floor(k/2)*875;ctx.fillStyle='black';ctx.font='18px sans-serif';ctx.fillText('Page '+(start+k),x,y-8);ctx.drawImage(img,x,y,590,834);}fs.writeFileSync(path.join(out,`sheet-${String(Math.ceil(start/4)).padStart(2,'0')}.png`),c.toBuffer('image/png'));}
fs.writeFileSync(path.join(out,'pages.json'),JSON.stringify({pages:pdf.numPages,textOutsidePhysicalPage:bounds,items:pages},null,2));console.log(JSON.stringify({rendered:pdf.numPages,sheets:Math.ceil(pdf.numPages/4),textOutsidePhysicalPage:bounds.length}));await pdf.cleanup();
