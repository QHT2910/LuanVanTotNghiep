// New layered evidence only. CPU submission invariants are not GPU presentation ACKs.
const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const root=path.resolve(__dirname,'../../evidence-m2-layered');
const read=(d,n)=>JSON.parse(fs.readFileSync(path.join(root,d,n),'utf8'));
const of=(a,event)=>a.filter(e=>e.event===event);
const near=(a,b,t=1e-8)=>assert(Math.abs(a-b)<=t,`${a} != ${b}`);
const vector=(a,b,t=1e-8)=>{assert.equal(a.length,b.length);a.forEach((v,i)=>near(v,b[i],t));};
function releaseChecks(a){
 for(const r of of(a,'shot_release')){
  const h=a.find(e=>e.event==='release_latched'&&e.shotId===r.shotId);
  const f=a.find(e=>e.event==='first_flight'&&e.shotId===r.shotId);
  const c=a.find(e=>e.event==='release_pose_clock'&&e.shotId===r.shotId);
  assert(h&&f&&c);
  for(const v of [h.hand,h.lastRenderBall,h.origin,[r.originX,r.originY,r.originZ]])vector(h.displayed,v);
  near(h.sampleTime,r.simTime);assert.equal(h.sampleRound,r.round);
  assert(h.sampleFrame>0&&h.sampleGeneration>=0&&h.sampleEpoch>=0);
  if(c.authoredRecovery)near(c.before,c.after);else assert.equal(c.after,null);
  // Footprint touching the arc is two: configured arc5 + footRadius.22.
  const expected=Math.hypot(r.feetX,r.feetZ+3)-5.22>1e-9?3:2;
  assert.equal(r.pointValue,expected);assert.equal(r.feetY,0);
  const o=h.origin,dist=Math.hypot(-o[0],-3-o[2]),error=(r.charge-.6)*4;
  const tx=(-o[0]/dist)*error,tz=-3+((-3-o[2])/dist)*error;
  const t=f.flightTime,T=1.4,g=9.81;assert(t>0&&t<=.1);
  vector(f.ball,[o[0]+(tx-o[0])/T*t,o[1]+(3.05-o[1]+.5*g*T*T)/T*t-.5*g*t*t,o[2]+(tz-o[2])/T*t]);
  assert(of(a,'score').filter(s=>s.shotId===r.shotId).length<=1);
 }
}
const e=read('regression','events.json'),ranges=read('regression','ranges.json');
assert.equal(of(e,'shot_release').length,5);
assert.deepEqual(of(e,'score').map(x=>x.points),[3,3,3,2,2]);
assert.equal(of(e,'score').at(-1).score,13);
assert([2,3].every(p=>[true,false].every(g=>of(e,'shot_release').some(r=>r.pointValue===p&&r.grounded===g))));
releaseChecks(e);
const negative=['cancel','dash-cancel','reset-held','reset-jump','background','exit-held'];
for(const mode of negative){const r=ranges.find(r=>r.mode===mode);assert(r,mode);assert.equal(of(e.slice(r.before,r.after),'shot_release').length,0,mode);}
const br=ranges.find(r=>r.mode==='background'),bg=e.slice(br.before,br.after);
const paused=of(bg,'paused')[0],resumed=of(bg,'resumed')[0];assert(paused&&resumed);
near(paused.simTime,resumed.simTime);near(paused.playerY,resumed.playerY);
const asset=of(e,'actor_asset')[0];assert(asset&&asset.warnings.length===0);
assert.equal(asset.skins[0].joints,65);assert.equal(asset.skins[0].nullJoints,0);
assert(asset.binding.every(x=>x.targets===65&&x.uniqueMatches));
const states=of(e,'actor_state');
assert(states.some(x=>x.transitionStart&&x.armAlpha===0));
assert(states.some(x=>x.transitionEnd&&x.armAlpha===1));
assert(states.some(x=>x.clip.startsWith('Jump_')&&x.armClip==='Authored_Basketball_v1'));
const maxBodyCopyError=Math.max(...states.map(x=>x.bodyCopyError));
const maxArmStartError=Math.max(...states.map(x=>x.armStartError));
assert(maxBodyCopyError<=1e-6&&maxArmStartError<=1e-6);
const contacts=[];
for(const dir of ['held-low','held-full-charge','held-air','held-interrupt']){
 const r=read(dir,'range.json'),all=read(dir,'events.json'),a=all.slice(r.before,r.after),markers=r.held;
 assert(markers.length>=3);const first=markers[0];
 assert(markers.some(x=>x.camera==='Cận trước')&&markers.some(x=>x.camera==='Cận bên'));
 for(const m of markers){
  assert(m.frozen&&m.phase==='charging');near(m.simTime,first.simTime);near(m.charge,first.charge);
  near(m.bodyTime,first.bodyTime);near(m.armTime,first.armTime);near(m.alpha,first.alpha);
  vector(m.hand,m.ball);vector(m.hand,first.hand);assert(m.bodyCopyError<=1e-6);
 }
 if(dir==='held-full-charge')assert.equal(first.charge,1);
 if(dir==='held-air')assert(first.body.startsWith('Jump_'));
 if(dir==='held-interrupt'){
  assert(of(a,'charge_start').length===2&&of(a,'charge_cancel').length>=1);
  assert(of(a,'actor_state').some(s=>s.transitionStart&&s.armStartError<=1e-6));
 }
 assert.equal(of(a,'shot_release').length,1);releaseChecks(a);
 contacts.push({dir,charge:first.charge,body:first.body,arms:first.arms,alpha:first.alpha,handBallError:0,frozenTime:first.simTime});
}
const guards=[];
for(const dir of ['early-idle-side','early-idle-front','early-jog-side','early-jog-front']){
 const all=read(dir,'events.json'),r=read(dir,'ranges.json').at(-1),a=all.slice(r.before,r.after);
 assert.equal(of(a,'shot_release').length,1);releaseChecks(a);
 assert.equal(of(a,'release_visual_guard')[0].authoredRecovery,false);
 const before=of(a,'joint_boundary').filter(x=>x.stage==='release');
 const after=of(a,'joint_boundary').filter(x=>x.stage==='first_flight');
 assert.equal(before.length,65);assert.equal(after.length,65);
 let error=0;
 for(const b of before){const n=after.find(x=>x.joint===b.joint);assert(n);for(let i=0;i<16;i++)error=Math.max(error,Math.abs(b.local[i]-n.local[i]));}
 assert(error<=1e-6,dir+' mixed pose jump '+error);
 guards.push({dir,charge:of(a,'shot_release')[0].charge,joints:65,maxLocalMatrixDelta:error});
}
const inspectionNegative=['jump','dash','reset','cancel','background','exit'];
for(const mode of inspectionNegative){
 const dir='held-stop-'+mode,r=read(dir,'range.json'),all=read(dir,'events.json'),a=all.slice(r.before,r.after);
 assert(r.inspectionCleared);assert.equal(of(a,'shot_release').length,0);
 assert(of(a,'held_contact_capture').some(m=>m.frozen&&m.phase==='charging'));
}
const re=read('final-reentry','events.json'),rr=read('final-reentry','ranges.json');
const back=rr.find(r=>r.mode==='system-back');assert(back&&of(re.slice(back.before,back.after),'paused').length===1);
const entries=rr.filter(r=>r.mode==='enter');assert.equal(entries.length,2);
for(const entry of entries)assert.equal(of(re.slice(entry.before,entry.after),'actor_asset').length,1);
const result={schema:1,pass:true,scope:'Layered Scene0.24.3, one AVD debug; CPU pose samples and stable held captures',
 regression:{releases:5,score:[3,3,3,2,2],total:13,groundAirTwoThree:true,exactOrigin:true,analyticFirstFlight:true,negative,lifecycleFreeze:true},
 maxBodyCopyError,maxArmStartError,contacts,guards,inspectionClearedWithoutRelease:inspectionNegative,systemBackPausedAndTwoFreshActorEntries:true,
 limits:['CPU submitted frame is not GPU presentation ACK or every-frame joint proof','Grip/finger contact and authored motion remain simple, not motion capture','Base clip changes and landing are not full-body blended','Zero-authored-contribution taps freeze mixed pose; no shooting animation in that branch','Single AVD debug; no physical-device FPS/network/full-game acceptance']};
fs.writeFileSync(path.join(root,'runtime-assertions.json'),JSON.stringify(result,null,2)+'\n');
console.log('PASS layered contact/transition/mixed65 guard/physics/negative oracles | game/evidence-m2-layered/runtime-assertions.json');
