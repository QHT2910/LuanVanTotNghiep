// Deterministic SVG layout of the existing sequence source: no semantic edits.
const fs=require('node:fs');
const {createCanvas,loadImage}=require('../.local-tools/node_modules/@napi-rs/canvas');
const esc=s=>s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
function lines(s,max){const result=[];let line='';for(const w of s.split(/\s+/)){if(line&&(line+' '+w).length>max){result.push(line);line=w;}else line+=(line?' ':'')+w;}if(line)result.push(line);return result;}
(async()=>{
for(const name of process.argv.slice(2)){
 const source=fs.readFileSync('diagrams/'+name+'.mmd','utf8');const actors=[];
 for(const m of source.matchAll(/^\s*(participant|actor) (\w+) as (.+)$/gm))actors.push([m[2],m[3],m[1]==='actor']);
 const width=760,x={};actors.forEach(([id],i)=>x[id]=actors.length===1?210:95+i*190);
 let y=100;const shapes=[],frames=[],stack=[];
 function text(str,px,py,anchor='start',size=20){shapes.push(`<text x="${px}" y="${py}" font-family="Arial" font-size="${size}" text-anchor="${anchor}">${esc(str)}</text>`);}
 for(const raw of source.split('\n')){
  const line=raw.trim();let m;
  if(!line||/^sequenceDiagram|^participant |^actor /.test(line))continue;
  if((m=/^(loop|alt|opt) (.+)$/.exec(line))){const depth=stack.length;stack.push({kind:m[1],label:m[2],top:y,depth});text(m[1]+' ['+m[2]+']',30+depth*16,y+25);y+=45;continue;}
  if((m=/^else(?: (.+))?$/.exec(line))){const f=stack[stack.length-1];shapes.push(`<line x1="${20+f.depth*16}" y1="${y}" x2="740" y2="${y}" stroke="#777" stroke-dasharray="5 4"/>`);text('else ['+(m[1]||'')+']',30+f.depth*16,y+25);y+=45;continue;}
  if(line==='end'){const f=stack.pop();if(!f)throw Error('Unbalanced end in '+name);frames.push(`<rect x="${20+f.depth*16}" y="${f.top}" width="${720-f.depth*16}" height="${y-f.top+6}" fill="none" stroke="#777"/>`);y+=22;continue;}
  if((m=/^Note over ([\w,]+): (.+)$/.exec(line))){const ls=lines(m[2],64),h=ls.length*25+14;shapes.push(`<rect x="25" y="${y}" width="710" height="${h}" fill="#f2f2f2" stroke="#aaa"/>`);ls.forEach((l,i)=>text(l,38,y+26+i*25));y+=h+20;continue;}
  if((m=/^(\w+)(-->>|->>)(\w+): (.+)$/.exec(line))){const a=x[m[1]],b=x[m[3]];if(a===undefined||b===undefined)throw Error('Unknown actor');const self=a===b,px=self?a+60:(a+b)/2,max=self?Math.max(20,Math.floor((width-px-25)/10)):Math.max(20,Math.floor(Math.abs(a-b)/10)),ls=lines(m[4],max);ls.forEach((l,i)=>text(l,px,y+20+i*25,self?'start':'middle'));const ay=y+ls.length*25+8;if(self)shapes.push(`<path d="M ${a} ${ay} h 90 v 20 h -90" fill="none" stroke="black" marker-end="url(#arrow)"/>`);else shapes.push(`<line x1="${a}" y1="${ay}" x2="${b}" y2="${ay}" stroke="black" ${m[2]==='-->>'?'stroke-dasharray="6 4"':''} marker-end="url(#arrow)"/>`);y=ay+(self?43:25);continue;}
  throw Error('Unsupported source line: '+line);
 }
 // Materialize arrowheads: the local SVG rasterizer does not reliably paint marker-end.
 for(const shape of shapes.slice()){
  let m=/^<line x1="([\d.]+)" y1="([\d.]+)" x2="([\d.]+)" y2="([\d.]+)".*marker-end=/.exec(shape);
  if(m){const x1=+m[1],yy=+m[2],x2=+m[3],dir=x2>x1?1:-1;shapes.push(`<polygon points="${x2},${yy} ${x2-dir*10},${yy-5} ${x2-dir*10},${yy+5}" fill="black"/>`);}
  m=/^<path d="M ([\d.]+) ([\d.]+) h 90 v 20 h -90".*marker-end=/.exec(shape);
  if(m){const xx=+m[1],yy=+m[2]+20;shapes.push(`<polygon points="${xx},${yy} ${xx+10},${yy-5} ${xx+10},${yy+5}" fill="black"/>`);}
 }
 if(stack.length)throw Error('Unclosed frame');const height=y+25;
 const heads=actors.map(([id,label,actor])=>actor?`<circle cx="${x[id]}" cy="20" r="9" fill="white" stroke="black"/><path d="M ${x[id]} 29 v 28 m -18 -17 h 36 m -18 17 l -16 18 m 16 -18 l 16 18" stroke="black" fill="none"/><text x="${x[id]}" y="94" font-family="Arial" font-size="20" text-anchor="middle">${esc(label)}</text><line x1="${x[id]}" y1="100" x2="${x[id]}" y2="${height}" stroke="#999" stroke-dasharray="4 4"/>`:`<rect x="${x[id]-82}" y="12" width="164" height="48" fill="white" stroke="black"/><text x="${x[id]}" y="43" font-family="Arial" font-size="20" text-anchor="middle">${esc(label)}</text><line x1="${x[id]}" y1="60" x2="${x[id]}" y2="${height}" stroke="#999" stroke-dasharray="4 4"/>`).join('');
 const svg=`<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}"><defs><marker id="arrow" markerWidth="9" markerHeight="9" refX="8" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 Z" fill="black"/></marker></defs><rect width="100%" height="100%" fill="white"/>${heads}${frames.join('')}${shapes.join('')}</svg>`;
 fs.writeFileSync('diagrams/'+name+'.svg',svg);const img=await loadImage(Buffer.from(svg)),canvas=createCanvas(width*2,height*2);canvas.getContext('2d').drawImage(img,0,0,width*2,height*2);fs.writeFileSync('diagrams/'+name+'.png',canvas.toBuffer('image/png'));console.log(name+': '+width+'x'+height+' source, '+actors.length+' actors');
}
})().catch(e=>{console.error(e.message);process.exit(1);});
