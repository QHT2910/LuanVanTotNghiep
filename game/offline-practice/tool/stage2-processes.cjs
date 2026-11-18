// Owned foreground diagnostic process group. stdin commands go to native peer.
const fs=require('fs'),path=require('path'),cp=require('child_process'),readline=require('readline');
const app=path.resolve(__dirname,'..'),root=path.resolve(app,'../..');
const variant=process.argv[2]||'processes';if(!/^[a-z0-9-]+$/.test(variant))throw Error('Invalid variant');
const out=path.resolve(app,'../evidence-network-stage2',variant);fs.mkdirSync(out,{recursive:true});
const dart='D:/flutter/bin/cache/dart-sdk/bin/dart.exe';
const children=[];let peer,server,stopping=false;
const wait=ms=>new Promise(r=>setTimeout(r,ms));
function launch(name,args){
 const child=cp.spawn(dart,args,{cwd:app,windowsHide:true,stdio:['pipe','pipe','pipe']});children.push(child);
 const log=fs.createWriteStream(path.join(out,name+'-'+child.pid+'.jsonl'),{flags:'wx'});
 const err=fs.createWriteStream(path.join(root,'.scratch','stage2-'+name+'-stderr.txt'));
 child.stderr.pipe(err);const lines=readline.createInterface({input:child.stdout});
 const notices=[],record={child,notices,welcome:null,ready:null};lines.on('line',line=>{log.write(line+'\n');try{const e=JSON.parse(line);notices.push(e);if(notices.length>6000)notices.shift();
  if(e.event==='welcome')record.welcome=e;if(e.event==='server_ready')record.ready=e;
  if(e.event==='server_ready'||e.event==='welcome'||e.event==='status')console.log(name+' '+JSON.stringify(e));
 }catch(_){}});
 child.on('exit',code=>{log.end();err.end();console.log(name+' exit='+code);});
 return record;
}
async function until(p){for(let i=0;i<200;i++){if(p())return;await wait(50);}throw Error('Process readiness timeout');}
async function stop(){
 if(stopping)return;stopping=true;
 if(peer&&!peer.child.killed)peer.child.stdin.end('quit\n');
 if(server&&!server.child.killed)server.child.stdin.end('quit\n');
 await wait(1500);
 for(const c of children)if(c.exitCode===null)c.kill();
 process.exitCode=0;
}
(async()=>{
 server=launch('server',['run','tool/stage1_server.dart']);
 await until(()=>server.ready);
 peer=launch('peer',['run','tool/stage2_peer.dart']);
 await until(()=>peer.welcome);
 fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify({scope:'Separate server/native-peer processes; AVD separate Android process',
  serverWrapperPid:server.child.pid,peerWrapperPid:peer.child.pid,serverPid:server.ready.pid,peerPid:peer.welcome.pid,commands:[['dart','run','tool/stage1_server.dart'],['dart','run','tool/stage2_peer.dart']],startedAt:new Date().toISOString()},null,2));
 console.log('READY separate processes; commands move x z/stop/charge/release/cancel/jump/dash/quit');
 const input=readline.createInterface({input:process.stdin});
 let busy=false;
 input.on('line',async line=>{if(line.trim()==='quit'){input.close();stop();return;}if(stopping||busy)return;
  busy=true;try{
   if(line.trim()==='shot'){
    const latest=()=>peer.notices.filter(x=>x.event==='snapshot_core').at(-1);
    const s=latest(),slot=peer.welcome.slot;if(!s||!s.ready||s.owner!==slot)throw Error('Native peer not current owner');
    peer.child.stdin.write('charge\n');
    await until(()=>{const n=latest();return n&&n.epoch===s.epoch&&n.phase==='charging'&&n.players[slot].charge>=.6;});
    const n=latest();peer.child.stdin.write('release\n');
    const proof={event:'native_shot_command',epoch:n.epoch,tick:n.tick,charge:n.players[slot].charge};
    fs.appendFileSync(path.join(out,'commands.jsonl'),JSON.stringify(proof)+'\n');console.log(JSON.stringify(proof));
   }else if(line.trim()==='restart-peer'){
    peer.child.stdin.end('quit\n');await until(()=>peer.child.exitCode!==null);
    peer=launch('peer-reconnected',['run','tool/stage2_peer.dart']);await until(()=>peer.welcome);
    console.log('PEER_RECONNECTED '+JSON.stringify(peer.welcome));
   }else if(line.trim()==='invalid-snapshot'){server.child.stdin.write('invalid-snapshot\n');}
   else peer.child.stdin.write(line+'\n');
  }catch(e){console.log('COMMAND_REJECTED '+e.message);}finally{busy=false;}
 });
 input.on('close',()=>stop());
})().catch(async e=>{console.error(e.message);await stop();process.exitCode=1;});
