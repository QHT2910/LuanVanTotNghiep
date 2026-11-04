const fs=require('node:fs'),path=require('node:path');
const {spawnSync}=require('node:child_process');
const root=path.resolve(__dirname,'..'),file=path.join(root,'docs/CONTEXT_HANDOFF.md');
function git(args,allowMissing=false){const r=spawnSync('git',['-C',root,...args],{encoding:'utf8',windowsHide:true});if(r.status!==0){if(allowMissing)return '(chưa có)';throw Error('Git snapshot failed: '+args.join(' '));}return r.stdout.trim();}
try{
 const body=fs.readFileSync(file,'utf8');
 const start='<!-- checkpoint-git:start -->',end='<!-- checkpoint-git:end -->';
 if(body.split(start).length!==2||body.split(end).length!==2||body.indexOf(end)<body.indexOf(start))throw Error('Checkpoint markers must occur exactly once in order');
 const head=git(['rev-parse','HEAD']),branch=git(['branch','--show-current'])||'(detached)',tracking=git(['rev-parse','--verify','refs/remotes/origin/main'],true);
 if(!/^[a-f0-9]{40}$/.test(head))throw Error('Unexpected commit format');
 const status=git(['status','--porcelain=v1']);
 const count=status?status.split(/\r?\n/).length:0;
 const snapshot=[start,'Ghi UTC: '+new Date().toISOString()+'. Snapshot trước commit chứa checkpoint, không phải HEAD cuối phiên.',
  '- Branch: `'+branch+'`; HEAD cơ sở: `'+head+'`.',
  '- Local tracking origin/main: `'+tracking+'` (không tự fetch hoặc suy ra remote live).',
  '- Git status lúc ghi: '+(count?'có '+count+' mục thay đổi chưa commit.':'sạch.')+' Khi khôi phục đọc lại `git status --short` và HEAD thật.',end].join('\n');
 const a=body.indexOf(start),b=body.indexOf(end,a)+end.length;
 fs.writeFileSync(file,body.slice(0,a)+snapshot+body.slice(b));
 console.log('Updated Git snapshot in docs/CONTEXT_HANDOFF.md; no semantic history, session or model changes.');
}catch(e){console.error(e.message);process.exit(1);}
