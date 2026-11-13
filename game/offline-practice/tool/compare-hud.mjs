// Evidence presentation only: original PNGs unchanged, contain resize, no retouch.
import fs from 'node:fs';
import path from 'node:path';
import {createCanvas,loadImage} from '../../../.local-tools/node_modules/@napi-rs/canvas/index.js';
const variant=process.argv[2]||'verified';if(!['final','verified'].includes(variant))throw Error('Supported evidence variant required');
const root=path.resolve(import.meta.dirname,'../../..'),out=path.join(root,'game/evidence-ui-offline-2',variant);
const ref=await loadImage(path.join(root,'design/figma/exports/user-revised-v010/ui04-revised.png'));
const actual=await loadImage(path.join(out,'hud-neutral.png'));
function fit(ctx,img,x,y,w,h,source){const sw=source?.[2]||img.width,sh=source?.[3]||img.height,s=Math.min(w/sw,h/sh),dw=sw*s,dh=sh*s;if(source)ctx.drawImage(img,...source,x+(w-dw)/2,y+(h-dh)/2,dw,dh);else ctx.drawImage(img,x+(w-dw)/2,y+(h-dh)/2,dw,dh);}
const c=createCanvas(940,1160),ctx=c.getContext('2d');ctx.fillStyle='white';ctx.fillRect(0,0,c.width,c.height);ctx.fillStyle='black';ctx.font='20px sans-serif';ctx.fillText('Figma Page 3 / node 35:2 — 898 × 505',20,28);fit(ctx,ref,20,40,900,505);ctx.fillText('AVD — contain at the same 898:505 comparison ratio; no stretching',20,580);fit(ctx,actual,20,594,900,505);ctx.font='16px sans-serif';ctx.fillText('Offline adaptation: practice score/round, Menu, reset and Dash status. Scene remains the probe.',20,1132);fs.writeFileSync(path.join(out,'figma-vs-avd.png'),c.toBuffer('image/png'));
const ranges=JSON.parse(fs.readFileSync(path.join(out,'workflow-ranges.json'),'utf8')),b=ranges.find(r=>r.mode==='layout').bounds;
const controls=['jump_button','dash_button','shoot_hold_release'].map(k=>b[k]);const x=Math.max(0,Math.min(...controls.map(r=>r[0]))-16),y=Math.max(0,Math.min(...controls.map(r=>r[1]))-145),right=Math.min(actual.width,Math.max(...controls.map(r=>r[2]))+16),bottom=Math.min(actual.height,Math.max(...controls.map(r=>r[3]))+16);
const crop=createCanvas(940,560),cc=crop.getContext('2d');cc.fillStyle='white';cc.fillRect(0,0,940,560);cc.fillStyle='black';cc.font='18px sans-serif';cc.fillText('Figma action controls (crop)',20,26);fit(cc,ref,20,38,900,220,[590,340,308,165]);cc.fillText('AVD action controls (semantics-derived crop; contain, no stretch)',20,294);fit(cc,actual,20,306,900,230,[x,y,right-x,bottom-y]);fs.writeFileSync(path.join(out,'hud-controls-comparison.png'),crop.toBuffer('image/png'));console.log('PASS comparison boards; original reference/runtime PNGs unchanged');
