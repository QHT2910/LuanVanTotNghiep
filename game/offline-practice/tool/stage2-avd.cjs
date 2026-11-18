const fs=require('fs'),path=require('path'),cp=require('child_process');
const mode=process.argv[2],variant=process.argv[3]||'runtime';
if(!/^[a-z0-9-]+$/.test(variant))throw Error('Invalid variant');
const root=path.resolve(__dirname,'../../..'),out=path.join(root,'game/evidence-network-stage2',variant);fs.mkdirSync(out,{recursive:true});
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe');
const run=(...args)=>cp.execFileSync(adb,['-s','emulator-5554',...args].map(String),{encoding:'utf8',windowsHide:true,timeout:20000,maxBuffer:32*1024*1024});
const wait=ms=>new Promise(r=>setTimeout(r,ms));
function events(){const pid=run('shell','pidof','com.example.offline_practice').trim();
 const raw=run('logcat','--pid',pid,'-d','-t','3000','-v','brief');fs.writeFileSync(path.join(root,'.scratch/network-stage2-device.log'),raw);
 const fresh=raw.split('\n').flatMap(line=>{const i=line.indexOf('network_stage2 ');return i<0?[]:[{devicePid:Number(pid),...JSON.parse(line.slice(i+15))}];});
 const file=path.join(out,'events.json'),old=fs.existsSync(file)?JSON.parse(fs.readFileSync(file)):[];
 const combined=new Map();for(const e of [...old,...fresh]){combined.set([e.devicePid,e.event,e.epoch,e.tick,e.mode].join('|'),e);}
 return [...combined.values()];}
function ui(){run('shell','uiautomator','dump','/sdcard/stage2.xml');return run('shell','cat','/sdcard/stage2.xml');}
function center(xml,label){const node=(xml.match(/<node\b[^>]*>/g)||[]).find(n=>n.includes('text="'+label+'"')||n.includes('content-desc="'+label+'"')||n.includes('content-desc="'+label+'&#10;'));
 if(!node)throw Error('Missing '+label);const b=node.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/).slice(1).map(Number);return[(b[0]+b[2])/2,(b[1]+b[3])/2];}
(async()=>{
 if(!run('shell','dumpsys','window').split('\n').some(l=>l.includes('mCurrentFocus')&&l.includes('com.example.offline_practice')))throw Error('Network app not foreground');
 const previous=events(),before=previous.length,start=previous.filter(e=>e.event==='scene_applied').at(-1);
 if(mode==='capture'){}
 else if(mode==='back'){run('shell','input','keyevent','KEYCODE_BACK');}
 else if(mode==='background'){run('shell','input','keyevent','KEYCODE_HOME');await wait(250);run('shell','am','start','-n','com.example.offline_practice/.MainActivity');}
 else if(mode==='background-held'){
  const p=center(ui(),'network_shoot_hold_release');
  run('shell','CLASSPATH=/data/local/tmp/dash-m3b.dex','app_process','/','DashTouch',...p,...p,...p,0,'background',120);
  await wait(250);run('shell','am','start','-n','com.example.offline_practice/.MainActivity');
 }
 else{
  const xml=ui();
  if(mode==='shoot'){const p=center(xml,'network_shoot_hold_release');run('shell','input','swipe',...p,...p,720);
   run('shell','screencap','-p','/sdcard/stage2-release.png');run('pull','/sdcard/stage2-release.png',path.join(out,'shoot-release.png'));}
  else if(mode==='move-x'){const p=center(xml,'network_move_X+');run('shell','input','swipe',...p,...p,500);}
  else if(mode==='move-z'){const p=center(xml,'network_move_Z−');run('shell','input','swipe',...p,...p,500);}
  else if(['Connect','Jump','Dash'].includes(mode))run('shell','input','tap',...center(xml,mode));
  else throw Error('Unknown mode');
 }
 await wait(mode==='shoot'?2200:300);
 run('shell','screencap','-p','/sdcard/stage2.png');run('pull','/sdcard/stage2.png',path.join(out,mode+'.png'));
 const all=events(),file=path.join(out,'ranges.json'),ranges=fs.existsSync(file)?JSON.parse(fs.readFileSync(file)):[];
 const end=all.filter(e=>e.event==='scene_applied').at(-1);
 ranges.push({mode,before,after:all.length,start:start?{epoch:start.epoch,tick:start.tick}:null,end:end?{epoch:end.epoch,tick:end.tick}:null});fs.writeFileSync(file,JSON.stringify(ranges,null,2));
 fs.writeFileSync(path.join(out,'events.json'),JSON.stringify(all,null,2));
 console.log('PASS input/capture '+mode+'; state/visual assertions pending');
})().catch(e=>{console.error(e.message);process.exitCode=1;});
