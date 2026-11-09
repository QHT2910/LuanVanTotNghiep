const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const serial=process.argv[2],mode=process.argv[3];if(!serial)throw Error('Pass existing AVD');
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe'),out=path.resolve(__dirname,'../../evidence-m3a');
const run=(...a)=>cp.execFileSync(adb,['-s',serial,...a],{encoding:'utf8',windowsHide:true,stdio:['ignore','pipe','pipe'],timeout:20000});
const delay=ms=>new Promise(r=>setTimeout(r,ms));
function shot(name){run('shell','screencap','-p','/sdcard/m3.png');run('pull','/sdcard/m3.png',path.join(out,'2026-11-09-'+name+'.png'));}
function events(){const pid=run('shell','pidof','com.example.offline_practice').trim();return run('logcat','--pid',pid,'-d','-v','brief').split('\n').filter(s=>s.includes('practice_event ')).map(s=>JSON.parse(s.slice(s.indexOf('practice_event ')+15)));}
(async()=>{
 if(!run('shell','dumpsys','window').split('\n').some(s=>/mCurrentFocus|mFocusedApp/.test(s)&&s.includes('com.example.offline_practice')))throw Error('Demo not foreground; no input sent');
 run('shell','uiautomator','dump','/sdcard/m3.xml');const xml=run('shell','cat','/sdcard/m3.xml');fs.writeFileSync(path.join(out,'ui-'+mode+'.xml'),xml);
 function bounds(label){const n=(xml.match(/<node\b[^>]*>/g)||[]).find(s=>s.includes(label));if(!n)throw Error('Missing '+label);return n.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/).slice(1).map(Number);}
 const center=b=>[(b[0]+b[2])/2,(b[1]+b[3])/2],stickBox=bounds('move_joystick'),stick=center(stickBox),jump=center(bounds('jump_button')),shoot=center(bounds('shoot_hold_release')),reset=center(bounds('new_round'));
 const tap=p=>run('shell','input','tap',...p.map(String));
 if(mode==='inside'){run('shell','input','swipe',...stick.map(String),String(stick[0]),String(stick[1]-(stickBox[2]-stickBox[0])*.27),'1300');shot('inside');}
 else if(mode==='reset'){tap(jump);await delay(120);tap(reset);shot('reset-grounded');}
 else if(mode==='repeat'){tap(jump);await delay(120);tap(jump);shot('repeat-air');await delay(1300);shot('repeat-land');}
 else {
  const moving=mode==='move-jump',first=moving?stick:jump,target=moving?[stick[0]+(stickBox[2]-stickBox[0])*.23,stick[1]]:jump,second=moving?jump:shoot;
  const child=cp.spawn(adb,['-s',serial,'shell','CLASSPATH=/data/local/tmp/joystick-m3.dex','app_process','/','JoystickTouch',...first,...target,...second,moving?0:720,'shoot',moving?300:50].map(String),{windowsHide:true,stdio:['ignore','pipe','pipe']});
  let text='',err='',active=false,released=false;
  child.stdout.on('data',b=>{text+=b;if(!active&&text.includes('BOTH_DOWN')){active=true;setTimeout(()=>{shot(mode+'-air');if(mode==='background')run('shell','input','keyevent','KEYCODE_HOME');},120);}if(!released&&text.includes('SHOOT_UP_JOYSTICK_STILL_DOWN')){released=true;if(mode!=='background')shot(mode+'-release');}});
  child.stderr.on('data',b=>err+=b);const timer=setTimeout(()=>child.kill(),15000);const code=await new Promise(r=>child.on('close',r));clearTimeout(timer);fs.writeFileSync(path.join(out,'touch-'+mode+'.txt'),text+'\n'+err);if(code!==0)throw Error('Input harness failed');
  if(mode==='background'){await delay(300);run('shell','am','start','-n','com.example.offline_practice/.MainActivity');}
  await delay(4200);shot(mode+'-land');
 }
 fs.writeFileSync(path.join(out,'runtime-events.json'),JSON.stringify(events(),null,2));console.log('PASS '+mode+' input workflow; inspect event/image oracle');
})().catch(e=>{console.error(e.message);process.exit(1);});
