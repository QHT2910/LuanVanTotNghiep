const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const dir=path.resolve(__dirname,'../../evidence-m3a'),e=JSON.parse(fs.readFileSync(path.join(dir,'runtime-events.json'),'utf8'));
for(let i=1;i<e.length;i++){assert(e[i].eventId>e[i-1].eventId);assert(e[i].simTime>=e[i-1].simTime);}
const starts=e.filter(x=>x.event==='jump_start'),lands=e.filter(x=>x.event==='jump_land'),releases=e.filter(x=>x.event==='shot_release'),scores=e.filter(x=>x.event==='score');
assert.equal(starts.length,6);assert.equal(lands.length,5);assert.equal(releases.length,2);
assert.deepEqual(scores.map(x=>[x.shotId,x.points,x.score]),[[1,3,3],[2,2,5]]);
assert.equal(new Set(scores.map(x=>x.shotId)).size,2);
for(const r of releases){assert(r.releasePlayerY>0);assert.equal(r.feetY,0);assert(Math.abs(r.originY-r.releasePlayerY-1.8)<1e-9);assert.equal(r.grounded,false);}
for(const s of starts){const land=lands.filter(x=>x.jumpId===s.jumpId),reset=e.filter(x=>x.event==='round_reset'&&x.jumpId===s.jumpId&&x.jumpCancelled);assert.equal(land.length+reset.length,1);if(land.length){assert.equal(land[0].playerY,0);assert(land[0].grounded);assert(Math.abs(land[0].landingSimTime-s.plannedLandingSimTime)<1e-8);}}
assert(e.some(x=>x.event==='jump_rejected'&&x.reason==='airborne'));
const pause=e.find(x=>x.event==='paused'),resume=e.find(x=>x.event==='resumed'&&x.eventId>pause.eventId);
assert(pause.playerY>0);assert.equal(resume.playerY,pause.playerY);assert.equal(resume.simTime,pause.simTime);assert.equal(resume.jumpId,pause.jumpId);
assert(e.some(x=>x.event==='charge_cancel'&&x.reason==='background'));
assert(!releases.some(x=>x.jumpId===pause.jumpId));assert(lands.some(x=>x.jumpId===pause.jumpId&&x.eventId>resume.eventId));
const reset=e.find(x=>x.event==='round_reset'&&x.jumpCancelled);assert.equal(reset.playerY,0);assert(reset.grounded);assert.equal(reset.score,3);
const result={pass:true,jumps:starts.length,lands:lands.length,resetCancelledJump:reset.jumpId,scores:scores.map(x=>[x.shotId,x.points,x.score]),airborneReleases:releases.map(x=>({shotId:x.shotId,playerY:x.releasePlayerY,originY:x.originY,feetY:x.feetY,pointValue:x.pointValue})),pauseResumeSameHeight:true,noDoubleJump:true,limits:'One AVD; joystick+jump and jump+shoot are separate two-pointer cases, not three concurrent fingers. Per-pointer cancellation covered by widget tests only.'};
fs.writeFileSync(path.join(dir,'runtime-assertions.json'),JSON.stringify(result,null,2));console.log('PASS 6 jumps, 5 lands + 1 reset, airborne releases, scores 3+2 once, pause/resume; runtime-assertions.json');
