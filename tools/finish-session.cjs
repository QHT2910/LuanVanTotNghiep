const {spawnSync} = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname,'..');
function git(args, allowed=[0]) {
 const r=spawnSync('git',['-C',root,...args],{encoding:'utf8',windowsHide:true});
 if(!allowed.includes(r.status)) throw new Error(`git ${args.join(' ')}: ${r.stderr || r.error || r.status}`);
 return r;
}
try {
 if(git(['remote','get-url','origin']).stdout.trim()!=='https://github.com/QHT2910/LuanVanTotNghiep.git') throw new Error('Unexpected origin');
 if(git(['branch','--show-current']).stdout.trim()!=='main') throw new Error('Expected main branch');
 if(process.argv.includes('--check')) {console.log(git(['status','--short']).stdout);console.log('Check only: no staging, commit or push.');process.exit(0);}
 if(git(['ls-files','-u']).stdout.trim()) throw new Error('Unresolved merge conflicts');
 const allowed=['AGENTS.md','.gitignore','README.md','thesis','diagrams','research','tools','docs','game','qa','design'];
 const staged=git(['diff','--cached','--name-only']).stdout.trim().split('\n').filter(Boolean);
 const excluded=[];
 for(let i=2;i<process.argv.length;i++)if(process.argv[i]==='--exclude'){
  const value=process.argv[++i];
  if(!value||value.includes('..')||!/^[-a-zA-Z0-9_/.]+$/.test(value)||!allowed.includes(value.split('/')[0]))throw Error('Invalid --exclude project path');
  if(staged.includes(value))throw Error('Excluded path is already staged: '+value);
  excluded.push(':(exclude)'+value);
 }
 for(const file of staged) if(!allowed.includes(file.split('/')[0])) throw new Error(`Already staged path outside allowlist: ${file}`);
 const present=allowed.filter(x=>fs.existsSync(path.join(root,x)));
 if(git(['status','--porcelain=v1','--',...present]).stdout.trim() && fs.existsSync(path.join(root,'docs/CONTEXT_HANDOFF.md'))){
  const checkpoint=spawnSync(process.execPath,[path.join(__dirname,'checkpoint-context.cjs')],{encoding:'utf8',windowsHide:true});
  if(checkpoint.status!==0)throw new Error(checkpoint.stderr||'Checkpoint update failed; no commit or push performed');
  console.log(checkpoint.stdout.trim());
 }
 git(['add','--',...present,...excluded]);
 const diff=git(['diff','--cached','--quiet'],[0,1]);
 if(diff.status===1){ const idx=process.argv.indexOf('--message');const msg=idx>=0?process.argv[idx+1]:null;if(!msg)throw new Error('Provide --message for session changes');console.log(git(['commit','-m',msg]).stdout); }
 const pushed=git(['push','--set-upstream','origin','main']);console.log(pushed.stdout,pushed.stderr);
 console.log('Session changes committed (if any) and pushed successfully.');
} catch(e) {console.error(e.message);process.exit(1);}
