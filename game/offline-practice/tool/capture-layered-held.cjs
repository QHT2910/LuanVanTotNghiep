const fs=require('fs'),path=require('path'),cp=require('child_process');
const mode=process.argv[2];
const stopMode=mode.startsWith('stop-')?mode.slice(5):null;
if(!['low','full','air','interrupt'].includes(mode)&&!['jump','dash','reset','background','exit','cancel'].includes(stopMode))throw Error('Unknown capture mode');
const out=path.resolve(__dirname,'../../evidence-m2-layered',mode==='full'?'held-full-charge':'held-'+mode);
fs.mkdirSync(out,{recursive:true});
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe');
const run=(...args)=>cp.execFileSync(adb,['-s','emulator-5554',...args].map(String),{encoding:'utf8',windowsHide:true,timeout:20000});
const wait=ms=>new Promise(r=>setTimeout(r,ms));
function ui(){run('shell','uiautomator','dump','/sdcard/layered-held.xml');return run('shell','cat','/sdcard/layered-held.xml');}
function center(xml,label){
 const node=(xml.match(/<node\b[^>]*>/g)||[]).find(n=>n.includes('text="'+label+'"')||n.includes('content-desc="'+label+'"'));
 if(!node)throw Error('Missing '+label);
 const b=node.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/).slice(1).map(Number);
 return[(b[0]+b[2])/2,(b[1]+b[3])/2];
}
function image(name){run('shell','screencap','-p','/sdcard/layered-held.png');run('pull','/sdcard/layered-held.png',path.join(out,name+'.png'));}
function events(){
 const pid=run('shell','pidof','com.example.offline_practice').trim();
 const raw=run('logcat','--pid',pid,'-d','-v','brief');
 fs.writeFileSync(path.resolve(__dirname,'../../../.scratch/layered-held-device-log.txt'),raw);
 const result=[];
 for(const line of raw.split('\n'))for(const prefix of ['practice_event ','practice_actor ','hand_event ']){
  const i=line.indexOf(prefix);if(i>=0)result.push({kind:prefix.trim(),...JSON.parse(line.slice(i+prefix.length))});
 }
 return result;
}
(async()=>{
 if(!run('shell','dumpsys','window').split('\n').some(l=>l.includes('mCurrentFocus')&&l.includes('com.example.offline_practice')))throw Error('Game not foreground');
 let xml=ui();run('shell','input','tap',...center(xml,'new_round'));await wait(150);
 const before=events().length;xml=ui();
 const shoot=center(xml,'shoot_hold_release'),freeze=center(xml,'Giữ ảnh');
 const jump=mode==='air'?center(xml,'jump_button'):[-1,-1];
 const child=cp.spawn(adb,['-s','emulator-5554','shell','CLASSPATH=/data/local/tmp/held-inspection.dex','app_process','/','HeldInspectionTouch',...shoot,...freeze,mode==='full'?1400:100,...jump,...(mode==='interrupt'?['recharge']:[])].map(String),{windowsHide:true,stdio:['pipe','pipe','pipe']});
 let stdout='',stderr='',ended=false;child.stderr.on('data',b=>stderr+=b);
 const done=new Promise(resolve=>child.on('close',code=>{ended=true;resolve(code);}));
 const frozen=new Promise((resolve,reject)=>{
  const timer=setTimeout(()=>reject(Error('Freeze timeout '+stderr)),10000);
  child.stdout.on('data',b=>{stdout+=b;if(stdout.includes('FREEZE_TAPPED_OWNER_HELD')){clearTimeout(timer);resolve();}});
  child.on('error',reject);
 });
 try{
  await frozen;xml=ui();if(!xml.includes('FROZEN inspection'))throw Error('No frozen charging inspection');
  if(stopMode){
   if(['jump','dash','reset','exit'].includes(stopMode)){
    const label={jump:'jump_button',dash:'dash_button',reset:'new_round',exit:'Menu'}[stopMode];
    child.stdin.write('tap '+center(xml,label).join(' ')+'\n');await wait(150);
   }else if(stopMode==='background'){
    run('shell','input','keyevent','KEYCODE_HOME');await wait(250);
    run('shell','am','start','-n','com.example.offline_practice/.MainActivity');await wait(500);
   }
   child.stdin.write('cancel\n');if(await done!==0)throw Error('Harness '+stderr);
   await wait(300);xml=ui();assertNotFrozen(xml);image('inspection-cleared');
   const all=events(),a=all.slice(before);
   if(a.some(e=>e.event==='shot_release'))throw Error('Unexpected release on '+mode);
   fs.writeFileSync(path.join(out,'events.json'),JSON.stringify(all,null,2));
   fs.writeFileSync(path.join(out,'range.json'),JSON.stringify({mode,before,after:all.length,inspectionCleared:true,releaseCount:0},null,2));
   fs.writeFileSync(path.join(out,'touch.txt'),stdout+'\n'+stderr);
   console.log('PASS inspection clears/no release '+mode);return;
  }
  for(const angle of ['front','side']){
   child.stdin.write('tap '+center(xml,angle==='front'?'Cận trước':'Cận bên').join(' ')+'\n');
   await wait(350);image(angle+'-held');
  }
  const held=events().slice(before).filter(e=>e.event==='held_contact_capture');
  if(held.length<3||held.some(e=>!e.frozen||e.phase!=='charging'))throw Error('Held markers missing/invalid');
  child.stdin.write('release\n');if(await done!==0)throw Error('Harness '+stderr);
  await wait(500);image('after-release');await wait(2300);image('settled');
  const all=events();fs.writeFileSync(path.join(out,'events.json'),JSON.stringify(all,null,2));
  fs.writeFileSync(path.join(out,'range.json'),JSON.stringify({mode,before,after:all.length,held},null,2));
  fs.writeFileSync(path.join(out,'touch.txt'),stdout+'\n'+stderr);
  console.log('PASS held owner/frozen charging captures '+mode+'; visual/oracle review pending');
 }finally{if(!ended){child.stdin.write('cancel\n');await done;}}
})().catch(e=>{console.error(e.message);process.exitCode=1;});
function assertNotFrozen(xml){if(xml.includes('FROZEN inspection'))throw Error('Inspection did not clear');}
