const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const serial=process.argv[2],mode=process.argv[3];if(!serial)throw Error('Pass existing AVD');
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe'),out=path.resolve(__dirname,'../../evidence-m3b');
const run=(...a)=>cp.execFileSync(adb,['-s',serial,...a],{encoding:'utf8',windowsHide:true,stdio:['ignore','pipe','pipe'],timeout:20000});
const delay=ms=>new Promise(r=>setTimeout(r,ms));
function capture(name){run('shell','screencap','-p','/sdcard/m3b.png');run('pull','/sdcard/m3b.png',path.join(out,'2026-11-10-'+name+'.png'));}
function events(){const pid=run('shell','pidof','com.example.offline_practice').trim();return run('logcat','--pid',pid,'-d','-v','brief').split('\n').filter(s=>s.includes('practice_event ')).map(s=>JSON.parse(s.slice(s.indexOf('practice_event ')+15)));}
(async()=>{
 if(!['layout','bounds','move-dash','repeat','charge-dash','background','cancel','after-resume','shot'].includes(mode))throw Error('Unknown mode');
 if(!run('shell','dumpsys','window').split('\n').some(s=>/mCurrentFocus|mFocusedApp/.test(s)&&s.includes('com.example.offline_practice')))throw Error('Demo not foreground; no input sent');
 run('shell','uiautomator','dump','/sdcard/m3b.xml');const xml=run('shell','cat','/sdcard/m3b.xml');fs.writeFileSync(path.join(out,'ui-'+mode+'.xml'),xml);
 function bounds(label){const node=(xml.match(/<node\b[^>]*>/g)||[]).find(s=>s.includes(label));if(!node)throw Error('Missing '+label);return node.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/).slice(1).map(Number);}
 const center=b=>[(b[0]+b[2])/2,(b[1]+b[3])/2],stickBox=bounds('move_joystick'),stick=center(stickBox),dash=center(bounds('dash_button')),shoot=center(bounds('shoot_hold_release')),scale=(stickBox[2]-stickBox[0])/152;
 const beforeId=events().at(-1)?.eventId||0;
 if(mode==='layout')capture('dash-layout');
 else if(mode==='bounds'){
  run('shell','input','swipe',...stick.map(String),String(stick[0]+44*scale),String(stick[1]),'3000');run('shell','input','tap',...dash.map(String));await delay(300);capture('dash-bounds');
 }else{
  const charge=mode==='charge-dash',first=charge?shoot:stick,target=charge?shoot:mode==='shot'?stick:[stick[0]+(mode==='move-dash'?36:-36)*scale,stick[1]],hold=mode==='move-dash'?1100:mode==='shot'?720:mode==='cancel'?30:0,kind=mode==='repeat'?'repeat':mode==='background'?'background':mode==='cancel'?'cancel':'shoot',second=mode==='shot'?shoot:dash;
  const child=cp.spawn(adb,['-s',serial,'shell','CLASSPATH=/data/local/tmp/dash-m3b.dex','app_process','/','DashTouch',...first,...target,...second,hold,kind,charge?300:50].map(String),{windowsHide:true,stdio:['ignore','pipe','pipe']});
  let text='',err='',captured=false;child.stdout.on('data',b=>{text+=b;if(!captured&&text.includes('BOTH_DOWN')){captured=true;if(mode!=='background')capture('dash-'+mode+'-active');}});child.stderr.on('data',b=>err+=b);
  const timer=setTimeout(()=>child.kill(),15000),code=await new Promise(r=>child.on('close',r));clearTimeout(timer);fs.writeFileSync(path.join(out,'touch-'+mode+'.txt'),text+'\n'+err);if(code!==0)throw Error('Input harness failed');
  if(mode==='background'){await delay(200);run('shell','am','start','-n','com.example.offline_practice/.MainActivity');}
  await delay(1300);capture('dash-'+mode+'-finished');
 }
 if(mode==='shot'){await delay(3000);capture('dash-shot-scored');}
 const trace=events();fs.writeFileSync(path.join(out,'runtime-events.json'),JSON.stringify(trace,null,2));
 const rangesPath=path.join(out,'workflow-ranges.json'),ranges=fs.existsSync(rangesPath)?JSON.parse(fs.readFileSync(rangesPath,'utf8')):[];
 ranges.push({mode,beforeId,afterId:trace.at(-1)?.eventId||beforeId});fs.writeFileSync(rangesPath,JSON.stringify(ranges,null,2));
 console.log('PASS '+mode+' input workflow; review events/images');
})().catch(e=>{console.error(e.message);process.exit(1);});
