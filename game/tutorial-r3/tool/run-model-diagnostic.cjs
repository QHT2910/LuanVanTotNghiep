const fs=require('fs'),cp=require('child_process'),path=require('path');
const adb='C:/Users/quang/AppData/Local/Android/Sdk/platform-tools/adb.exe',out=path.resolve(__dirname,'../../evidence-model-fox');
const run=(...a)=>cp.execFileSync(adb,['-s','emulator-5554',...a],{encoding:'utf8',windowsHide:true,timeout:20000});
const delay=n=>new Promise(r=>setTimeout(r,n));
function screen(name){run('shell','screencap','-p','/sdcard/fox.png');run('pull','/sdcard/fox.png',path.join(out,name+'.png'));}
function events(){const pid=run('shell','pidof','com.example.scene_tutorial_r3').trim();const raw=run('logcat','--pid',pid,'-d','-v','brief');fs.writeFileSync(path.resolve(out,'../../.scratch/fox-device-log.txt'),raw);const groups=new Map();for(const l of raw.split('\n')){const p=l.indexOf('model_diag_chunk ');if(p<0)continue;const c=JSON.parse(l.slice(p+17));const key=c.runId+':'+c.seq;if(!groups.has(key))groups.set(key,{total:c.total,parts:[]});groups.get(key).parts[c.index]=c.data;}return [...groups.values()].map(g=>{if(g.parts.filter(x=>x!==undefined).length!==g.total)throw Error('Incomplete event chunks');return JSON.parse(g.parts.join(''));});}
(async()=>{
 if(process.argv[2]==='capture'){fs.writeFileSync(path.join(out,'reopen-events.json'),JSON.stringify(events(),null,2));screen('reopened');console.log('PASS reopen evidence captured; review pending');return;}
 if(!run('shell','dumpsys','window').split('\n').some(l=>/mCurrentFocus/.test(l)&&l.includes('com.example.scene_tutorial_r3')))throw Error('Probe not foreground');
 run('shell','uiautomator','dump','/sdcard/fox.xml');const xml=run('shell','cat','/sdcard/fox.xml');
 const buttons={};for(const n of xml.match(/<node\b[^>]*>/g)||[]){const t=n.match(/(?:text|content-desc)="([^"]+)"/),b=n.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/);if(t&&b){const a=b.slice(1).map(Number);buttons[t[1]]=[(a[0]+a[2])/2,(a[1]+a[3])/2];}}
 async function tap(t){if(!buttons[t])throw Error('Button missing '+t);run('shell','input','tap',...buttons[t]);await delay(180);}
 const ranges=[];async function step(name,fn){const before=events().length;await fn();ranges.push({name,before,after:events().length});fs.writeFileSync(path.join(out,'workflow-ranges.json'),JSON.stringify(ranges,null,2));fs.writeFileSync(path.join(out,'runtime-events.json'),JSON.stringify(events(),null,2));}
 await step('pose0',async()=>{await tap('Pose 0');screen('pose0');});
 await step('pose50',async()=>{await tap('Pose 50%');screen('pose50');});
 await step('pose0-repeat',async()=>{await tap('Pose 0');});
 await step('play-pause',async()=>{await tap('Play');await delay(500);await tap('Pause');screen('paused');});
 await step('pause-samples',async()=>{await tap('Sample');await delay(650);await tap('Sample');});
 await step('replay',async()=>{await tap('Replay');await delay(300);await tap('Pause');});
 await step('root',async()=>{await tap('Pose 50%');await tap('Root transform');screen('root-shifted');await tap('Root transform');});
 await step('lifecycle-paused',async()=>{run('shell','input','keyevent','3');await delay(600);run('shell','am','start','-n','com.example.scene_tutorial_r3/.MainActivity');await delay(500);await tap('Sample');screen('resume-paused');});
 await step('lifecycle-playing',async()=>{await tap('Play');await delay(300);run('shell','input','keyevent','3');await delay(600);run('shell','am','start','-n','com.example.scene_tutorial_r3/.MainActivity');await delay(400);await tap('Pause');screen('resume-playing');});
 console.log('PASS runtime sequence captured; assertions pending');
})().catch(e=>{console.error(e.message);process.exitCode=1;});
