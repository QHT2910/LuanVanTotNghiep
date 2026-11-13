// Existing AVD only. Semantics-derived touch bounds, two-pointer shell harness.
const fs=require('fs'),path=require('path'),cp=require('child_process');
const serial=process.argv[2],mode=process.argv[3];
if(!serial||!['layout','move-shot','jump-shot','move-dash','bounds','dash-duration','reset','cancel','background','exit','reentry','system-back'].includes(mode))throw Error('Existing serial and supported mode required');
if(process.argv[4]&&!['final','verified'].includes(process.argv[4]))throw Error('Only final/verified output suffix supported');
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe'),out=path.resolve(__dirname,'../../evidence-ui-offline-2',process.argv[4]||'');fs.mkdirSync(out,{recursive:true});
const run=(...args)=>cp.execFileSync(adb,['-s',serial,...args].map(String),{encoding:'utf8',windowsHide:true,timeout:20000,stdio:['ignore','pipe','pipe']});
const delay=ms=>new Promise(r=>setTimeout(r,ms));
function image(name){run('shell','screencap','-p','/sdcard/hud2.png');run('pull','/sdcard/hud2.png',path.join(out,name+'.png'));}
function events(){const pid=run('shell','pidof','com.example.offline_practice').trim();return run('logcat','--pid',pid,'-d','-v','brief').split('\n').filter(s=>s.includes('practice_event ')).map(s=>JSON.parse(s.slice(s.indexOf('practice_event ')+15)));}
function ui(){run('shell','uiautomator','dump','/sdcard/hud2.xml');return run('shell','cat','/sdcard/hud2.xml');}
function bounds(xml,label){const nodes=xml.match(/<node\b[^>]*>/g)||[],node=nodes.find(n=>n.includes('content-desc="'+label+'"')||n.includes('text="'+label+'"'));if(!node)throw Error('Missing semantics: '+label);return node.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/).slice(1).map(Number);}
const center=b=>[(b[0]+b[2])/2,(b[1]+b[3])/2];
(async()=>{
if(!run('shell','dumpsys','window').split('\n').some(s=>/mCurrentFocus|mFocusedApp/.test(s)&&s.includes('com.example.offline_practice')))throw Error('Demo not foreground; no input');
const before=events().length;let xml=ui();const record={mode,beforeEventCount:before};
if(mode==='reentry'){run('shell','input','tap',...center(bounds(xml,'Tập luyện')));await delay(500);image('hud-reentry');}
else if(mode==='system-back'){run('shell','input','keyevent','4');await delay(300);image('menu-system-back');}
else if(mode==='layout') {image('hud-neutral');record.bounds={};for(const label of ['move_joystick','jump_button','dash_button','shoot_hold_release','Menu'])record.bounds[label]=bounds(xml,label);}
else {
const stick=bounds(xml,'move_joystick'),s=center(stick),scale=(stick[2]-stick[0])/152,shoot=center(bounds(xml,'shoot_hold_release')),jump=center(bounds(xml,'jump_button')),dash=center(bounds(xml,'dash_button'));
let first=s,target=[s[0]-27*scale,s[1]],second=shoot,hold=720,kind='shoot',lead=100;
if(mode==='jump-shot'){first=jump;target=jump;lead=50;}
if(mode==='move-dash'){second=dash;hold=900;}
if(mode==='bounds'){run('shell','input','swipe',...s,s[0]+27*scale,s[1],500);await delay(100);second=dash;hold=0;}
if(mode==='dash-duration'){second=dash;target=[s[0]+27*scale,s[1]];hold=1200;}
if(mode==='reset'){first=jump;target=jump;second=center(bounds(xml,'new_round'));lead=180;hold=0;}
if(mode==='cancel'){kind='cancel';hold=250;}
if(mode==='background'){first=jump;target=jump;kind='background';hold=0;lead=120;}
if(mode==='exit'){first=shoot;target=shoot;second=center(bounds(xml,'Menu'));hold=0;lead=300;}
record.touch={first,target,second,hold,kind,lead,scope:'two pointers; harness stdout labels are historical'};
const child=cp.spawn(adb,['-s',serial,'shell','CLASSPATH=/data/local/tmp/dash-m3b.dex','app_process','/','DashTouch',...first,...target,...second,hold,kind,lead].map(String),{windowsHide:true,stdio:['ignore','pipe','pipe']});
let stdout='',stderr='',captured=false;child.stdout.on('data',b=>{stdout+=b;if(!captured&&stdout.includes('BOTH_DOWN')){captured=true;if(mode!=='background')image('hud-'+mode+'-active');}});child.stderr.on('data',b=>stderr+=b);
const timer=setTimeout(()=>child.kill(),15000),code=await new Promise(r=>child.on('close',r));clearTimeout(timer);fs.writeFileSync(path.join(out,'touch-'+mode+'.txt'),stdout+'\n'+stderr);if(code!==0)throw Error('Touch harness failed');
if(mode==='background'){await delay(250);run('shell','am','start','-n','com.example.offline_practice/.MainActivity');image('hud-resume');}
await delay(mode.includes('shot')?3100:1500);image(mode==='exit'?'menu-charge-exit':'hud-'+mode+'-finished');
}
const trace=events();record.afterEventCount=trace.length;const rangesFile=path.join(out,'workflow-ranges.json'),ranges=fs.existsSync(rangesFile)?JSON.parse(fs.readFileSync(rangesFile,'utf8')):[];ranges.push(record);fs.writeFileSync(rangesFile,JSON.stringify(ranges,null,2)+'\n');fs.writeFileSync(path.join(out,'runtime-events.json'),JSON.stringify(trace,null,2)+'\n');console.log('PASS input workflow '+mode+'; assertions/visual review separate');
})().catch(e=>{console.error(e.message);process.exit(1)});
