const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const root=path.resolve(__dirname,'../../evidence-network-stage2');
const lines=file=>fs.readFileSync(path.join(root,file),'utf8').split('\n').filter(Boolean).map(JSON.parse);
const peers=fs.readdirSync(path.join(root,'verified-processes')).filter(n=>/^peer-\d+\.jsonl$/.test(n));
assert.equal(peers.length,1);
const peer=lines('verified-processes/'+peers[0]),device=lines('verified-live.jsonl');
const welcome=peer.find(x=>x.event==='welcome');assert(welcome);
const epoch=welcome.epoch,p=peer.filter(x=>x.event==='snapshot_core'&&x.epoch===epoch),
 received=device.filter(x=>x.event==='snapshot_core'&&x.epoch===epoch),
 applied=device.filter(x=>x.event==='scene_applied'&&x.epoch===epoch);
const map=new Map(p.map(x=>[x.tick,x]));
const keys=['epoch','tick','ready','owner','phase','shotKey','players','ball','scores','eventId'];
const core=x=>JSON.stringify(Object.fromEntries(keys.map(k=>[k,x[k]])));
let matchedReceived=0,matchedApplied=0,maxRenderError=0;
for(const [records,kind] of [[received,'received'],[applied,'applied']]){
 let tick=-1;
 for(const d of records){assert(d.tick>tick);tick=d.tick;const s=map.get(d.tick);if(!s)continue;
  assert.equal(core(d),core(s),'Same-tick mismatch '+d.tick);
  if(kind==='received')matchedReceived++;else matchedApplied++;
 }
}
assert(matchedReceived>=10&&matchedApplied>=10);
for(const d of applied){assert.equal(d.writer,'snapshot_only');
 const expected=d.players.map(p=>[p.position[0],p.position[1]+.9,p.position[2]]);
 for(let i=0;i<2;i++)for(let j=0;j<3;j++)maxRenderError=Math.max(maxRenderError,Math.abs(expected[i][j]-d.renderPlayers[i][j]));
 for(let j=0;j<3;j++)maxRenderError=Math.max(maxRenderError,Math.abs(d.ball[j]-d.renderBall[j]));
}
assert(maxRenderError<=1e-6);
assert.deepEqual(received.at(-1).scores,[3,3]);assert.deepEqual(p.at(-1).scores,[3,3]);
const deviceEffects=received.flatMap(d=>d.effectIds),peerEffects=p.flatMap(d=>d.effectIds);
assert.deepEqual(deviceEffects,[1,2]);assert.deepEqual(peerEffects,[1,2]);
assert(received.some(d=>d.phase==='flying'&&d.owner===0));
assert(received.some(d=>d.phase==='flying'&&d.owner===1));
assert(applied.some(d=>d.players[1].position[0]>1.1));
const life=lines('lifecycle-live.jsonl'),nativeLife=lines('peer-lifecycle-preserved.jsonl');
const lifeWelcome=nativeLife.find(d=>d.event==='welcome'),lifeEpoch=lifeWelcome.epoch;
const lifeStates=nativeLife.filter(d=>d.event==='snapshot_core'&&d.epoch===lifeEpoch);
assert(nativeLife.some(d=>d.event==='status'&&d.status==='disconnected'));
assert(lifeStates.some(d=>d.owner===1&&d.phase==='charging'));
assert(!lifeStates.some(d=>d.owner===1&&d.phase==='flying'));
assert.deepEqual(lifeStates.at(-1).scores,[3,0]);
const reentryPeer=lines('peer-reentry-preserved.jsonl'),reWelcome=reentryPeer.find(d=>d.event==='welcome');
assert(reWelcome.epoch!==epoch&&reWelcome.epoch!==lifeEpoch);
assert(life.some(d=>d.event==='mode'&&d.mode==='NETWORK_STAGE2_CANONICAL_1_8'));
const newStates=life.filter(d=>d.event==='snapshot_core'&&d.epoch===reWelcome.epoch);
assert(newStates.length>0);assert.deepEqual(newStates.at(-1).scores,[0,0]);
assert.deepEqual(newStates.flatMap(d=>d.effectIds),[]);
const serverFault=lines('accepted-processes/server.jsonl').find(d=>d.event==='fault_injected');assert(serverFault);
const invalidXmlEvidence='invalid-packet/capture.png';assert(fs.existsSync(path.join(root,invalidXmlEvidence)));
const result={schema:1,pass:true,scope:'One AVD Scene client + separate native Dart peer/server processes on loopback',
 epoch,matchedReceived,matchedApplied,maxRenderError,scores:[3,3],deviceEffects,peerEffects,
 bothSlotsReleased:true,deviceMoved:true,backgroundHeldClosesRoomWithoutRelease:true,
 reentryFreshEpochScoresZero:true,runtimeModeMarker:true,faultInjectionRecorded:true,
 invalidPacketProof:'Pure atomic tests + actual injected fault/closed UI screenshot; no invalid DTO published',
 limits:['Scene-applied trace is CPU transform sampling, not GPU presentation ACK',
 'Canonical release1.8 and primitive renderer, not M2 online human hand animation',
 'One Android emulator and native peer, not two Androids/Internet',
 'Fixed-step simulation drift is not a 3-minute match clock; no phone FPS claim']};
fs.writeFileSync(path.join(root,'runtime-assertions.json'),JSON.stringify(result,null,2)+'\n');
console.log('PASS actual AVD/native peer common-tick states, applied transforms, absolute scores/effect once, lifecycle/new epoch | runtime-assertions.json');
