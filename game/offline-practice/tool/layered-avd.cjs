const fs=require('fs'),path=require('path'),cp=require('child_process');
const mode=process.argv[2],variant=process.argv[3]||'calibration';
if(!/^[a-z0-9-]+$/.test(variant))throw Error('Invalid evidence variant');
const out=path.resolve(__dirname,'../../evidence-m2-layered',variant);fs.mkdirSync(out,{recursive:true});
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe');
const run=(...a)=>cp.execFileSync(adb,['-s','emulator-5554',...a].map(String),{encoding:'utf8',windowsHide:true,timeout:20000});
const wait=n=>new Promise(r=>setTimeout(r,n));
function ui(){run('shell','uiautomator','dump','/sdcard/m2.xml');return run('shell','cat','/sdcard/m2.xml');}
function center(xml,label){const n=(xml.match(/<node\b[^>]*>/g)||[]).find(n=>n.includes('text="'+label+'"')||n.includes('content-desc="'+label+'"'));if(!n)throw Error('Missing UI '+label);const b=n.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/).slice(1).map(Number);return[(b[0]+b[2])/2,(b[1]+b[3])/2];}
function image(n){run('shell','screencap','-p','/sdcard/m2.png');run('pull','/sdcard/m2.png',path.join(out,n+'.png'));}
function events(){const pid=run('shell','pidof','com.example.offline_practice').trim(),raw=run('logcat','--pid',pid,'-d','-v','brief');fs.writeFileSync(path.resolve(out,'../../../.scratch/layered-device-log.txt'),raw);const result=[];for(const l of raw.split('\n'))for(const p of ['practice_event ','practice_actor ','hand_event ']){const i=l.indexOf(p);if(i>=0)result.push({kind:p.trim(),...JSON.parse(l.slice(i+p.length))});}return result;}
(async()=>{
 if(!run('shell','dumpsys','window').split('\n').some(l=>/mCurrentFocus/.test(l)&&l.includes('com.example.offline_practice')))throw Error('M2 not foreground');
 const before=events().length,xml=ui();
 if(mode==='enter'){run('shell','input','tap',...center(xml,'Tập luyện'));await wait(600);}
 else if(mode==='system-back'){run('shell','input','keyevent','KEYCODE_BACK');await wait(250);image('system-back-menu');}
 else if(['front','side','court'].includes(mode)){run('shell','input','tap',...center(xml,{front:'Cận trước',side:'Cận bên',court:'Góc sân'}[mode]));await wait(200);image(mode+'-idle');}
 else if(mode==='inside'){const s=center(xml,'move_joystick'),n=(xml.match(/<node\b[^>]*>/g)||[]).find(n=>n.includes('content-desc="move_joystick"')),b=n.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/).slice(1).map(Number);run('shell','input','swipe',...s,s[0],s[1]-(b[2]-b[0])/152*44,1200);await wait(150);image('inside-position');}
 else if(mode==='jump-only'){run('shell','input','tap',...center(xml,'jump_button'));image('jump-only-start');await wait(250);image('jump-only-air');await wait(500);image('jump-only-land');}
 else if(mode==='capture'){image('capture');}
 else {
  const stick=center(xml,'move_joystick'),shoot=center(xml,'shoot_hold_release'),jump=center(xml,'jump_button');
  let first=['jump-shot','background','reset-jump'].includes(mode)?jump:stick;
  if(['dash-cancel','reset-held','exit-held'].includes(mode))first=shoot;
  const target=['move-shot','short-jog'].includes(mode)?[stick[0]-70,stick[1]]:first;
  let second=shoot,hold=mode.startsWith('inspect')?1800:mode==='cancel'?400:720,kind=mode==='cancel'?'cancel':'shoot',lead=mode==='jump-shot'?50:100;
  if(mode==='short-idle'){hold=0;lead=0;}
  if(mode==='short-jog'){hold=0;lead=200;}
  if(mode==='low-charge'){hold=120;lead=100;}
  if(mode==='dash-cancel'){second=center(xml,'dash_button');hold=0;lead=300;}
  if(mode.startsWith('reset-')){second=center(xml,'new_round');hold=0;lead=180;}
  if(mode==='exit-held'){second=center(xml,'Menu');hold=0;lead=300;}
  if(mode==='background'){kind='background';hold=0;lead=120;}
  const child=cp.spawn(adb,['-s','emulator-5554','shell','CLASSPATH=/data/local/tmp/dash-m3b.dex','app_process','/','DashTouch',...first,...target,...second,hold,kind,lead].map(String),{windowsHide:true,stdio:['ignore','pipe','pipe']});
  let stdout='',stderr='',releaseCaptured=false;const down=new Promise((resolve,reject)=>{child.stdout.on('data',b=>{stdout+=b;if(stdout.includes('BOTH_DOWN'))resolve();if(stdout.includes('SHOOT_UP_JOYSTICK_STILL_DOWN')&&!releaseCaptured){releaseCaptured=true;if(['ground-shot','jump-shot','move-shot'].includes(mode)||mode.startsWith('inspect'))image(mode+'-release');}});child.on('error',reject);});
  child.stderr.on('data',b=>stderr+=b);const done=new Promise(r=>child.on('close',r));
  await down;await wait(mode.startsWith('inspect')?250:120);image(mode+'-prepare');
  if(mode.startsWith('inspect')){await wait(500);image(mode+'-hold');}
  if(await done!==0)throw Error('Harness failed '+stderr);
  if(mode==='background'){run('shell','am','start','-n','com.example.offline_practice/.MainActivity');await wait(600);}
  image(mode+'-after');await wait(2000);image(mode+'-settled');
  fs.writeFileSync(path.join(out,'touch-'+mode+'.txt'),stdout+'\n'+stderr);
 }
 const all=events(),rangesPath=path.join(out,'ranges.json'),ranges=fs.existsSync(rangesPath)?JSON.parse(fs.readFileSync(rangesPath)):[];
 ranges.push({mode,before,after:all.length});fs.writeFileSync(rangesPath,JSON.stringify(ranges,null,2));fs.writeFileSync(path.join(out,'events.json'),JSON.stringify(all,null,2));
 console.log('PASS capture '+mode+'; assertions/visual acceptance pending');
})().catch(e=>{console.error(e.message);process.exitCode=1;});
