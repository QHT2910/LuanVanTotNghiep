const fs=require('fs'),path=require('path'),cp=require('child_process'),readline=require('readline');
const variant=process.argv[2]||'device-live';if(!/^[a-z0-9-]+$/.test(variant))throw Error('Invalid log variant');
const root=path.resolve(__dirname,'../../..'),out=path.join(root,'game/evidence-network-stage2',variant+'.jsonl');
const adb=path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe');
const pid=cp.execFileSync(adb,['-s','emulator-5554','shell','pidof','com.example.offline_practice'],{encoding:'utf8',windowsHide:true}).trim();
if(!/^\d+$/.test(pid))throw Error('App process missing');
const file=fs.createWriteStream(out,{flags:'wx'});
const child=cp.spawn(adb,['-s','emulator-5554','logcat','--pid',pid,'-v','brief','-T','1'],{windowsHide:true,stdio:['ignore','pipe','pipe']});
const lines=readline.createInterface({input:child.stdout});let count=0,stopped=false;
lines.on('line',line=>{const i=line.indexOf('network_stage2 ');if(i<0)return;
 try{const e=JSON.parse(line.slice(i+15));file.write(JSON.stringify({devicePid:Number(pid),...e})+'\n');count++;}catch(_){console.error('Malformed structured device log');}});
const input=readline.createInterface({input:process.stdin});
const timer=setTimeout(stop,180000);
function stop(){if(stopped)return;stopped=true;clearTimeout(timer);child.kill();input.close();}
input.on('line',line=>{if(line.trim()==='quit')stop();});input.on('close',stop);
child.on('exit',()=>{lines.close();file.end();console.log('DEVICE_LOG_CLOSED '+JSON.stringify({devicePid:Number(pid),events:count,file:path.basename(out)}));});
console.log('DEVICE_LOG_READY '+JSON.stringify({devicePid:Number(pid),file:path.basename(out),maximumSeconds:180}));
