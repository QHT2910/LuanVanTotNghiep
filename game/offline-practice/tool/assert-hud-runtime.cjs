const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const variant=process.argv[2]||'verified';assert(['final','verified'].includes(variant));
const dir=path.resolve(__dirname,'../../evidence-ui-offline-2',variant);
const events=JSON.parse(fs.readFileSync(path.join(dir,'runtime-events.json'),'utf8'));
const ranges=JSON.parse(fs.readFileSync(path.join(dir,'workflow-ranges.json'),'utf8'));
const range=mode=>{const r=ranges.find(r=>r.mode===mode);assert(r,'Missing workflow '+mode);return events.slice(r.beforeEventCount,r.afterEventCount);};
const of=(list,name)=>list.filter(e=>e.event===name),near=(a,b,t=1e-8)=>assert(Math.abs(a-b)<=t,`${a} != ${b}`);
const move=range('move-shot'),jump=range('jump-shot'),m=of(move,'shot_release'),j=of(jump,'shot_release');
assert.equal(m.length,1);assert.equal(j.length,1);assert(m[0].feetX>0.1);assert(j[0].feetX>m[0].feetX+0.1,'Joystick must keep moving after release');assert(j[0].releasePlayerY>0);near(j[0].originY,j[0].releasePlayerY+1.8);assert.equal(j[0].feetY,0);assert.equal(of(jump,'jump_start').length,1);assert.equal(of(jump,'jump_land').length,1);
const scores=[...of(move,'score'),...of(jump,'score')];assert.deepEqual(scores.map(e=>[e.shotId,e.points,e.score]),[[1,3,3],[2,3,6]]);
const d=range('dash-duration'),starts=of(d,'dash_start'),ends=of(d,'dash_end');assert.equal(starts.length,1);assert.equal(ends.length,1);assert.equal(ends[0].reason,'duration');near(ends[0].dashEndSimTime-starts[0].simTime,0.2);near(Math.hypot(ends[0].x-starts[0].x,ends[0].z-starts[0].z),1.6);
const boundsMode=ranges.some(r=>r.mode==='bounds')?'bounds':'move-dash';
const bounds=of(range(boundsMode),'dash_end');assert.equal(bounds.length,1);assert.equal(bounds[0].reason,'bounds');near(bounds[0].x,3.78);const bs=of(range(boundsMode),'dash_start')[0];assert(bs.x<3.78);near(bounds[0].dashEndSimTime-bs.simTime,(3.78-bs.x)/8);
const cancel=range('cancel');assert.equal(of(cancel,'shot_release').length,0);assert(of(cancel,'charge_cancel').some(e=>e.reason==='pointer_cancel'));
const reset=range('reset'),rr=of(reset,'round_reset').find(e=>e.reason==='manual');assert(rr?.jumpCancelled);assert.equal(rr.playerY,0);assert.equal(rr.score,6);assert.equal(of(reset,'shot_release').length,0);
const bg=range('background'),paused=of(bg,'paused')[0],resumed=of(bg,'resumed')[0];assert(paused&&resumed);near(paused.simTime,resumed.simTime);near(paused.playerY,resumed.playerY);assert(paused.playerY>0);assert.equal(of(bg,'jump_start').length,1);assert.equal(of(bg,'jump_land').length,1);assert.equal(of(bg,'shot_release').length,0);const bgCancel=of(bg,'charge_cancel').find(e=>['background','pointer_cancel'].includes(e.reason));assert(bgCancel&&bgCancel.eventId<paused.eventId); 
const exit=range('exit');assert.equal(of(exit,'shot_release').length,0);assert(of(exit,'charge_cancel').some(e=>e.reason==='return_menu'));assert.equal(of(exit,'paused').length,1);
assert(range('system-back').some(e=>e.event==='paused'));
const layout=ranges.find(r=>r.mode==='layout').bounds,scale=(layout.move_joystick[2]-layout.move_joystick[0])/152;const boxes=Object.values(layout);
for(const b of boxes){assert((b[2]-b[0])/scale>=48-0.1);assert((b[3]-b[1])/scale>=48-0.1||b===layout.Menu,'Minimum gameplay touch area');}
for(let a=0;a<boxes.length;a++)for(let b=a+1;b<boxes.length;b++){const x=boxes[a],y=boxes[b];assert(!(x[0]<y[2]&&x[2]>y[0]&&x[1]<y[3]&&x[3]>y[1]),'Touch rectangles overlap');}
const result={pass:true,scope:'Final HUD build, one AVD, separate two-pointer sequences; not three pointers',releaseCount:2,scores:scores.map(e=>[e.shotId,e.points,e.score]),airborneRelease:{playerY:j[0].releasePlayerY,originY:j[0].originY,feetY:j[0].feetY},dash:{duration:0.2,distance:1.6,heldBeyondCooldownStarts:starts.length,boundsX:bounds[0].x,boundsFromInside:true},pauseResume:{simTime:paused.simTime,playerY:paused.playerY,chargeCancelReason:bgCancel.reason,cancelBeforePause:true},cancelNoShot:true,resetGroundedScore:rr.score,exitChargeNoShot:true,systemBackPaused:true,touchRectsNonOverlapping:true,limitations:['Individual-pointer cancel and races remain unit/widget evidence','No real phone/Internet/performance claim','Scene/background/model still the probe, not full Figma scene']};
fs.writeFileSync(path.join(dir,'runtime-assertions.json'),JSON.stringify(result,null,2)+'\n');console.log('PASS final HUD oracle: move+shoot, jump+shoot, 3+3, Dash duration/bounds/no-repeat, cancel/reset/pause-resume/exit');
