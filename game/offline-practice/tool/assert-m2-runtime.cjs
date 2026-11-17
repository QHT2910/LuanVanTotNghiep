// Read existing AVD events; write a separate, reproducible assertion summary.
const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const variant=process.argv[2]||'accepted';
if(!/^[a-z0-9-]+$/.test(variant))throw Error('Invalid evidence variant');
const out=path.resolve(__dirname,'../../evidence-m2-hand-action',variant);
const events=JSON.parse(fs.readFileSync(path.join(out,'events.json')));
const ranges=JSON.parse(fs.readFileSync(path.join(out,'ranges.json')));
const close=(a,b,t=1e-8)=>assert(Math.abs(a-b)<=t,`${a} != ${b}`);
const vector=(a,b)=>{assert.equal(a.length,b.length);a.forEach((v,i)=>close(v,b[i]));};
const releases=events.filter(e=>e.event==='shot_release');
const scores=events.filter(e=>e.event==='score');
assert.equal(releases.length,Number(process.argv[3]||7));assert.deepEqual(scores.map(e=>e.points),[3,3,3,2,2]);
assert.equal(scores.at(-1).score,13);
for(const r of releases){
 const h=events.find(e=>e.event==='release_latched'&&e.shotId===r.shotId);
 const f=events.find(e=>e.event==='first_flight'&&e.shotId===r.shotId);
 const c=events.find(e=>e.event==='release_pose_clock'&&e.shotId===r.shotId);
 assert(h&&f&&c);vector(h.displayed,h.hand);vector(h.displayed,h.lastRenderBall);
 vector(h.displayed,h.origin);vector(h.origin,[r.originX,r.originY,r.originZ]);
 close(h.sampleTime,r.simTime);assert.equal(h.sampleRound,r.round);
 assert(h.sampleEpoch>=0&&h.sampleGeneration>=0&&h.sampleFrame>0);
 close(c.before,c.after);assert.equal(c.clip,'Authored_Basketball_v1');
 const expectedPoints=Math.hypot(r.feetX,r.feetZ+3)>=5-1e-9?3:2;
 assert.equal(r.pointValue,expectedPoints);assert.equal(r.feetY,0);
 const o=h.origin,dist=Math.hypot(-o[0],-3-o[2]),err=(r.charge-.6)*4;
 const tx=(-o[0]/dist)*err,tz=-3+((-3-o[2])/dist)*err;
 const t=f.flightTime,T=1.4,g=9.81;
 assert(t>0&&t<=.1);
 vector(f.ball,[o[0]+(tx-o[0])/T*t,
  o[1]+(3.05-o[1]+.5*g*T*T)/T*t-.5*g*t*t,
  o[2]+(tz-o[2])/T*t]);
 assert(scores.filter(e=>e.shotId===r.shotId).length<=1);
}
const negativeModes=['cancel','dash-cancel','reset-held','reset-jump','background','exit-held'];
for(const mode of negativeModes){
 const r=ranges.find(r=>r.mode===mode);assert(r,mode);
 const a=events.slice(r.before,r.after);assert(!a.some(e=>e.event==='shot_release'),mode);
}
const bg=ranges.find(r=>r.mode==='background'),b=events.slice(bg.before,bg.after);
const paused=b.find(e=>e.event==='paused'),resumed=b.find(e=>e.event==='resumed');
assert(paused&&resumed);close(paused.simTime,resumed.simTime);close(paused.playerY,resumed.playerY);
const actors=events.filter(e=>e.event==='actor_asset');
assert(actors.length>=1);
const report={schema:1,pass:true,scope:'One AVD M2 submitted CPU pose/ball samples and simulation events',
 releases:releases.length,scoredPoints:scores.map(e=>e.points),totalScore:13,
 airborneReleases:releases.filter(e=>!e.grounded).length,
 groundAndAirTwoAndThree:[2,3].every(p=>[true,false].every(g=>releases.some(e=>e.pointValue===p&&e.grounded===g))),
 exactLatchedOrigins:true,firstFlightMatchesAnalytic:true,continuousClockAtRelease:true,
 negativeModes,lifecycleFreeze:true,
 limits:['CPU submitted sample is not proof of GPU presentation timing','No per-frame/full skin binding assertion',
 'Authored arms use Idle-backed full-body clip while charging airborne; no layered jump legs',
 'Single AVD debug; not physical-device performance or network acceptance']};
fs.writeFileSync(path.join(out,'runtime-assertions.json'),JSON.stringify(report,null,2)+'\n');
console.log('PASS M2 runtime assertions | output=game/evidence-m2-hand-action/'+variant+'/runtime-assertions.json');
