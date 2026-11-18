// One bounded normal-case run with continuous logs from both actual clients.
const fs=require('fs'),path=require('path'),cp=require('child_process');
const root=path.resolve(__dirname,'../../..'),out=path.join(root,'game/evidence-network-stage2');
const children=[];const wait=ms=>new Promise(r=>setTimeout(r,ms));
function start(script,args){const child=cp.spawn(process.execPath,[path.join(__dirname,script),...args],{cwd:root,windowsHide:true,stdio:['pipe','pipe','pipe']});
 const state={child,text:'',error:'',done:false};children.push(state);
 child.stdout.on('data',b=>state.text+=b);child.stderr.on('data',b=>state.error+=b);
 child.on('close',code=>{state.done=true;state.code=code;});return state;}
async function until(p,limit=15000){const start=Date.now();while(!p()){if(Date.now()-start>limit)throw Error('Bounded proof wait timeout');await wait(50);}}
function action(mode){const r=cp.spawnSync(process.execPath,[path.join(__dirname,'stage2-avd.cjs'),mode,'verified'],{cwd:root,windowsHide:true,encoding:'utf8',timeout:30000,maxBuffer:32*1024*1024});
 fs.appendFileSync(path.join(out,'verified-actions.txt'),r.stdout+'\n'+r.stderr);if(r.status!==0)throw Error('AVD action failed '+mode);}
(async()=>{
 let controller,logger;
 try{
  controller=start('stage2-processes.cjs',['verified-processes']);await until(()=>controller.text.includes('READY separate processes'));
  logger=start('stage2-device-log.cjs',['verified-live']);await until(()=>logger.text.includes('DEVICE_LOG_READY'));
  action('Connect');controller.child.stdin.write('shot\n');await until(()=>controller.text.includes('native_shot_command'));
  action('move-x');action('shoot');action('capture');
  logger.child.stdin.end('quit\n');await until(()=>logger.done);
  controller.child.stdin.end('quit\n');await until(()=>controller.done);
  if(logger.code!==0||controller.code!==0)throw Error('Process cleanup failed');
  fs.writeFileSync(path.join(out,'verified-process-output.txt'),controller.text+'\n'+logger.text);
  console.log('PASS bounded separate-server/native-peer + AVD run; compare raw states before acceptance');
 }finally{
  for(const c of children)if(!c.done){c.child.stdin.end('quit\n');}
  await wait(1500);for(const c of children)if(!c.done)c.child.kill();
 }
})().catch(e=>{console.error(e.message);process.exitCode=1;});
