const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const out=path.resolve(__dirname,'../../evidence-actor-integration/verified');
const events=JSON.parse(fs.readFileSync(path.join(out,'actor-events.json')));
const assets=events.filter(e=>e.event==='actor_asset'),states=events.filter(e=>e.event==='actor_state');
assert(assets.length>=3);for(const a of assets){assert.equal(a.bytes,7618436);assert.equal(a.yawOffset,Math.PI);assert.equal(a.warnings.length,0);assert(a.binding.every(b=>b.targets===65&&b.uniqueMatches));assert(a.skins.every(s=>s.joints===65&&s.nullJoints===0));}
for(const s of states){assert(s.acceptedDelta>=0&&s.acceptedDelta<=.1+1e-8);if(s.pose==='held'){assert.equal(s.clip,'Idle_Loop');assert.equal(s.clipTime,0);}else{assert.equal(s.clip,s.pose==='jog'?'Jog_Fwd_Loop':'Idle_Loop');assert(Math.abs(s.clipTime-s.acceptedDelta)<1e-8);}}
for(const [x,z]of [[-1,0],[1,0],[0,-1],[0,1]])assert(states.some(s=>s.pose==='jog'&&s.facingX===x&&s.facingZ===z),'Direction state missing');
const result={pass:true,scope:'Actor asset and state-transition logs only; not every-frame joint pose',assetLoads:assets.length,stateTransitions:states.length,allDirectionsLogged:true,heldUsesIdleZero:true,transitionClipTimeMatchesAcceptedDelta:true,limits:['Clip time between transitions reviewed from source/policy tests, not independent per-frame matrix oracle','Idle/Jog only; no basketball shooting clip or hand attachment','Full-body game images small; detailed skin acceptance inherited from human diagnostic']};
fs.writeFileSync(path.join(out,'actor-assertions.json'),JSON.stringify(result,null,2)+'\n');console.log('PASS actor asset/state-transition/direction assertions');
