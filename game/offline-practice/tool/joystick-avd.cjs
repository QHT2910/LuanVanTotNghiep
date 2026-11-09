const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const serial=process.argv[2],mode=process.argv[3]||'render';if(!serial)throw Error('Pass one running AVD target');
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe'),out=path.resolve(__dirname,'../../evidence-m2');
const run=(...a)=>cp.execFileSync(adb,['-s',serial,...a],{encoding:'utf8',stdio:['ignore','pipe','pipe'],windowsHide:true,timeout:20000});
const delay=ms=>new Promise(r=>setTimeout(r,ms));
function hierarchy(){run('shell','uiautomator','dump','/sdcard/joystick-m2.xml');return run('shell','cat','/sdcard/joystick-m2.xml');}
function bounds(label,xml){const n=(xml.match(/<node\b[^>]*>/g)||[]).find(s=>s.includes(label));if(!n)throw Error('Missing semantics '+label);const m=n.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/);return m.slice(1).map(Number);}
const center=b=>[(b[0]+b[2])/2,(b[1]+b[3])/2];
function capture(name){run('shell','screencap','-p','/sdcard/m2-'+name+'.png');run('pull','/sdcard/m2-'+name+'.png',path.join(out,name+'.png'));}
function events(){const pid=run('shell','pidof','com.example.offline_practice').trim();return run('logcat','--pid',pid,'-d','-v','brief').split('\n').filter(s=>s.includes('practice_event ')).map(s=>{try{return JSON.parse(s.slice(s.indexOf('practice_event ')+15));}catch{return null;}}).filter(Boolean);}
async function settle(){for(let i=0;i<40;i++){const e=events(),r=e.filter(x=>x.event==='shot_release').at(-1);if(!r||e.some(x=>x.event==='round_reset'&&x.eventId>r.eventId))return;await delay(500);}throw Error('Round wait timed out');}
(async()=>{
 const focus=run('shell','dumpsys','window');
 if(!focus.split('\n').some(s=>/mCurrentFocus|mFocusedApp/.test(s)&&s.includes('com.example.offline_practice')))throw Error('Demo is not foreground; no input sent');
 const xml=hierarchy();fs.writeFileSync(path.join(out,'ui-'+mode+'.xml'),xml);
 const box=bounds('move_joystick',xml),stick=center(box),shoot=center(bounds('shoot_hold_release',xml));
 if(mode==='render'){capture('2026-11-09-joystick-neutral');}
 else if(mode==='move'){
   run('shell','input','swipe',String(stick[0]),String(stick[1]),String(stick[0]),String(stick[1]-0.25*(box[2]-box[0])),'1200');capture('2026-11-09-joystick-moved');
 }else if(mode==='multi'||mode==='multi-resumed'||mode==='cancel'){
   const scale=(box[2]-box[0])/152,target=[stick[0]+36*scale,stick[1]],hold=mode==='cancel'?350:720;
   const args=['shell','CLASSPATH=/data/local/tmp/joystick-m2.dex','app_process','/','JoystickTouch',...stick,...target,...shoot,hold,mode==='cancel'?'cancel':'shoot'].map(String);
   const child=cp.spawn(adb,['-s',serial,...args],{windowsHide:true,stdio:['ignore','pipe','pipe']});let text='',err='',captured=false;
   child.stdout.on('data',buf=>{text+=buf.toString();if(!captured&&text.includes('BOTH_DOWN')){captured=true;setTimeout(()=>{try{capture('2026-11-09-'+mode+'-active');}catch(e){err+=e.message;}},150);}});
   child.stderr.on('data',b=>err+=b.toString());
   const timer=setTimeout(()=>child.kill(),15000);const code=await new Promise((resolve,reject)=>{child.on('error',reject);child.on('close',resolve);});clearTimeout(timer);
   fs.writeFileSync(path.join(out,'touch-'+mode+'.txt'),text+'\n'+err);if(code!==0)throw Error('Multi-pointer injection failed: '+err);await settle();capture('2026-11-09-'+mode+'-finished');
 }else if(mode==='background'){
   run('shell','input','motionevent','DOWN',String(stick[0]+30),String(stick[1]));await delay(250);run('shell','input','keyevent','KEYCODE_HOME');run('shell','input','motionevent','UP',String(stick[0]+30),String(stick[1]));run('shell','am','start','-n','com.example.offline_practice/.MainActivity');await delay(1500);capture('2026-11-09-joystick-resumed');
 }else throw Error('Unknown mode');
 fs.writeFileSync(path.join(out,'runtime-events.json'),JSON.stringify(events(),null,2));console.log('PASS AVD '+mode+' workflow; event/image oracle review required');
})().catch(e=>{console.error(e.message);process.exit(1);});
