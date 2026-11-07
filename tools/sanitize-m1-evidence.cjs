// Preserve raw local logs, publish redacted copies of this milestone's evidence.
const fs=require('node:fs'),path=require('node:path');
const dir=path.resolve(__dirname,'../game/evidence-m1'),backup=path.resolve(__dirname,'../.scratch/m1-raw');fs.mkdirSync(backup,{recursive:true});
for(const name of fs.readdirSync(dir).filter(n=>n.endsWith('.txt'))){
 const file=path.join(dir,name),buf=fs.readFileSync(file);if(!fs.existsSync(path.join(backup,name)))fs.writeFileSync(path.join(backup,name),buf);
 let text=buf[0]===255&&buf[1]===254?buf.subarray(2).toString('utf16le'):buf.toString('utf8').replace(/^\uFEFF/,'');
 text=text.replace(/C:\\Users\\[^\\\s"']+/gi,'<USERPROFILE>').replace(/C:\/Users\/[^/\s"']+/gi,'<USERPROFILE>')
 .replace(/https?:\/\/(?:127\.0\.0\.1|localhost):\d+\/[^\s)]+/g,'<LOCAL_DEBUG_SERVICE>')
 .replace(/\b(?:\d{1,3}\.){3}\d{1,3}\b/g,'<IP>').replace(/\b[0-9a-f]{2}(?::[0-9a-f]{2}){5}\b/gi,'<MAC>');
 fs.writeFileSync(file,text);
}
console.log('PASS redacted milestone text logs; raw copies retained only in .scratch/m1-raw');
for(const name of fs.readdirSync(dir).filter(n=>n.endsWith('.json'))){
 const file=path.join(dir,name),buf=fs.readFileSync(file);
 const text=buf[0]===255&&buf[1]===254?buf.subarray(2).toString('utf16le'):buf.toString('utf8').replace(/^\uFEFF/,'');
 fs.writeFileSync(file,JSON.stringify(JSON.parse(text),null,2));
}
const events=JSON.parse(fs.readFileSync(path.join(dir,'offline-runtime-events.json'),'utf8'));
fs.writeFileSync(path.join(dir,'runtime-core-events.json'),JSON.stringify(events.filter(e=>e.event!=='dt_clamped'),null,2));
