const fs=require('fs'),cp=require('child_process'),path=require('path');
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe');
const out=path.resolve(__dirname,'../../evidence-actor-integration/verified');
const run=(...args)=>cp.execFileSync(adb,['-s','emulator-5554',...args].map(String),{encoding:'utf8',windowsHide:true,timeout:20000});
const delay=n=>new Promise(r=>setTimeout(r,n));
(async()=>{
 if(!run('shell','dumpsys','window').split('\n').some(l=>/mCurrentFocus/.test(l)&&l.includes('com.example.offline_practice')))throw Error('Game not foreground');
 run('shell','uiautomator','dump','/sdcard/actor.xml');const xml=run('shell','cat','/sdcard/actor.xml');
 const node=(xml.match(/<node\b[^>]*>/g)||[]).find(n=>n.includes('content-desc="move_joystick"'));
 if(!node)throw Error('Joystick not available');const b=node.match(/bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/).slice(1).map(Number);
 const x=(b[0]+b[2])/2,y=(b[1]+b[3])/2,d=(b[2]-b[0])/152*44;
 for(const [name,dx,dy]of [['world-left',1,0],['world-right',-1,0],['toward-rim',0,-1],['away-rim',0,1]]){
  const child=cp.spawn(adb,['-s','emulator-5554','shell','input','swipe',x,y,x+dx*d,y+dy*d,900].map(String),{windowsHide:true,stdio:'ignore'});
  const done=new Promise(r=>child.on('close',r));await delay(550);
  run('shell','screencap','-p','/sdcard/actor.png');run('pull','/sdcard/actor.png',path.join(out,'actor-'+name+'.png'));
  if(await done!==0)throw Error('Swipe failed');await delay(150);
 }
 const pid=run('shell','pidof','com.example.offline_practice').trim(),raw=run('logcat','--pid',pid,'-d','-v','brief');
 fs.writeFileSync(path.resolve(out,'../../../.scratch/actor-device-log.txt'),raw);
 const events=raw.split('\n').filter(l=>l.includes('practice_actor ')).map(l=>JSON.parse(l.slice(l.indexOf('practice_actor ')+15)));
 fs.writeFileSync(path.join(out,'actor-events.json'),JSON.stringify(events,null,2)+'\n');
 console.log('PASS directional captures and actor events; visual/oracle review pending');
})().catch(e=>{console.error(e.message);process.exitCode=1;});
