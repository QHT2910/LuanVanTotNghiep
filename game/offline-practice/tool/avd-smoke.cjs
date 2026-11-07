// Bounded manual-workflow smoke: uses the running AVD, never boots or closes it.
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const serial=process.argv[2];if(!serial)throw Error('Pass the active AVD target');
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe');
const out=path.resolve(__dirname,'../../evidence-m1');fs.mkdirSync(out,{recursive:true});
function run(...args){return cp.execFileSync(adb,['-s',serial,...args],{encoding:'utf8',stdio:['ignore','pipe','pipe'],windowsHide:true,timeout:20000});}
const delay=ms=>new Promise(r=>setTimeout(r,ms));
function hierarchy(){run('shell','uiautomator','dump','/sdcard/practice-window.xml');return run('shell','cat','/sdcard/practice-window.xml');}
function center(label,xml=hierarchy()){const nodes=xml.match(/<node\b[^>]*>/g)||[];const node=nodes.find(s=>s.includes(label));if(!node)throw Error('Missing semantics '+label);const a=node.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/);if(!a)throw Error('No bounds '+label);return [Math.round((+a[1]+ +a[3])/2),Math.round((+a[2]+ +a[4])/2)];}
function hold(label,ms){const [x,y]=center(label);run('shell','input','swipe',String(x),String(y),String(x),String(y),String(ms));}
function tap(label){const [x,y]=center(label);run('shell','input','tap',String(x),String(y));}
function events(){const pid=run('shell','pidof','com.example.offline_practice').trim();return run('logcat','--pid',pid,'-d','-v','brief').split('\n').filter(s=>s.includes('practice_event ')).map(s=>{try{return JSON.parse(s.slice(s.indexOf('practice_event ')+15));}catch{return null;}}).filter(Boolean);}
function capture(name){run('shell','screencap','-p','/sdcard/practice-'+name+'.png');run('pull','/sdcard/practice-'+name+'.png',path.join(out,'offline-'+name+'.png'));fs.writeFileSync(path.join(out,'offline-'+name+'-ui.xml'),hierarchy());}
async function settle(){
 for(let i=0;i<40;i++){
  const es=events(),release=es.filter(e=>e.event==='shot_release').at(-1);
  if(!release||es.some(e=>e.event==='round_reset'&&e.eventId>release.eventId))return;
  await delay(500);
 }
 throw Error('Shot did not reset within bounded runtime wait');
}
(async()=>{
 const mode=process.argv[3]||'render';
 if(mode==='render'){capture('render');}
 else if(mode==='shot'){await settle();const before=events().filter(e=>e.event==='shot_release').at(-1)?.shotId||0;const ms=Number(process.argv[4]||720),label=process.argv[5]||'shot';hold('shoot_hold_release',ms);await delay(250);if(!(events().some(e=>e.event==='shot_release'&&e.shotId>before)))throw Error('No new released shot; workflow failed');await settle();capture(label);}
 else if(mode==='move'){hold(process.argv[4]||'move_toward_rim',Number(process.argv[5]||1400));capture('moved');}
 else if(mode==='reset'){tap('new_round');capture('reset');}
 else if(mode==='reset-flight'){
   const xml=hierarchy(),[sx,sy]=center('shoot_hold_release',xml),[rx,ry]=center('new_round',xml);
   run('shell','input','swipe',String(sx),String(sy),String(sx),String(sy),'720');
   run('shell','input','tap',String(rx),String(ry));
   await settle();capture('reset-flight');
   run('shell','input','swipe',String(sx),String(sy),String(sx),String(sy),'720');
   await settle();capture('continued');
 }
 else if(mode==='background'){const [x,y]=center('shoot_hold_release');run('shell','input','motionevent','DOWN',String(x),String(y));await delay(250);run('shell','input','keyevent','KEYCODE_HOME');run('shell','input','motionevent','UP',String(x),String(y));await delay(400);run('shell','am','start','-n','com.example.offline_practice/.MainActivity');await delay(1500);capture('resumed');}
 else throw Error('Unknown mode');
 fs.writeFileSync(path.join(out,'offline-runtime-events.json'),JSON.stringify(events(),null,2));console.log('PASS ADB workflow '+mode+'; captured evidence, assertions require event review');
})().catch(e=>{console.error(e.message);process.exit(1);});
