const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const root=path.resolve(__dirname,'../../evidence-m2-hand-action');
const variants=['guard-idle-side','guard-idle-front','guard-jog-side-zero','guard-jog-front',
 'guard-low-side','guard-low-front'];
const results=[];
for(const variant of variants){
 const dir=path.join(root,variant),e=JSON.parse(fs.readFileSync(path.join(dir,'events.json'))),
  r=JSON.parse(fs.readFileSync(path.join(dir,'ranges.json'))).at(-1),a=e.slice(r.before,r.after);
 const releases=a.filter(x=>x.event==='shot_release');assert.equal(releases.length,1,variant);
 const release=releases[0],g=a.find(x=>x.event==='release_visual_guard');assert(g,variant);
 const prepared=variant.includes('-low-');assert.equal(g.authoredRecovery,prepared,variant);
 const h=a.find(x=>x.event==='release_latched'),f=a.find(x=>x.event==='first_flight');assert(h&&f);
 for(const v of [h.hand,h.lastRenderBall,h.origin,[release.originX,release.originY,release.originZ]])
  v.forEach((n,i)=>assert(Math.abs(n-h.displayed[i])<1e-8,variant+' origin'));
 const before=a.filter(x=>x.event==='joint_boundary'&&x.stage==='release'),
  after=a.filter(x=>x.event==='joint_boundary'&&x.stage==='first_flight');
 assert.equal(before.length,65,variant+' release joints');assert.equal(after.length,65,variant+' flight joints');
 let error=0;
 for(const b of before){const next=after.find(x=>x.joint===b.joint);assert(next);
  assert.equal(next.local.length,16);
  for(let i=0;i<16;i++)error=Math.max(error,Math.abs(b.local[i]-next.local[i]));
  if(!prepared){assert.equal(next.clip,b.clip);assert.equal(next.clipTime,b.clipTime);}
 }
 if(!prepared){assert.equal(release.charge,0);assert(error<=1e-6,variant+' joint jump '+error);}
 const clock=a.find(x=>x.event==='release_pose_clock');assert(clock);
 if(prepared)assert(Math.abs(clock.before-clock.after)<1e-8);else assert.equal(clock.after,null);
 results.push({variant,shotId:release.shotId,charge:release.charge,
  authoredRecovery:prepared,joints:65,maxLocalMatrixDelta:error,
  exactLatchedOrigin:true,clipBefore:g.clipBefore});
}
fs.writeFileSync(path.join(root,'guard-runtime-assertions.json'),JSON.stringify({schema:1,pass:true,
 scope:'One AVD CPU submitted pose at release versus first flight; not every GPU frame',results,
 limits:['Zero-frame taps retain base pose without a shooting animation',
 'Prepared matrix changes are expected animation, not a freeze assertion',
 'No layered airborne shooting, physical-device or network acceptance']},null,2)+'\n');
console.log('PASS six guard AVD cases, four zero-frame taps preserve 65 joint local matrices | log=game/evidence-m2-hand-action/guard-runtime-assertions.json');
