// Recreate the preceding generated candidate IN MEMORY for comparison only.
// All writes of the old generator are intercepted; the user's DOCX is read-only.
const fs=require('fs'),path=require('path'),vm=require('vm'),{createRequire}=require('module');
const Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser}=require('../.local-tools/node_modules/@xmldom/xmldom');
const root=path.resolve(__dirname,'..'),out=path.join(root,'.scratch/thesis-v012'),writes=new Map();
const key=p=>path.resolve(root,String(p));
(async()=>{
 const generatedFS=new Proxy(fs,{get(target,prop){
  if(prop==='writeFileSync')return(p,b)=>writes.set(key(p),Buffer.isBuffer(b)?b:Buffer.from(b));
  if(prop==='mkdirSync')return()=>undefined;
  if(prop==='readFileSync')return(p,enc)=>writes.has(key(p))?(enc?writes.get(key(p)).toString(typeof enc==='string'?enc:enc.encoding):writes.get(key(p))):fs.readFileSync(p,enc);
  return target[prop];
 }});
 const req=createRequire(path.join(root,'tools/revise-thesis-v011.cjs'));
 const code=fs.readFileSync(path.join(root,'tools/revise-thesis-v011.cjs'),'utf8');
 const sandbox={require:n=>n==='fs'?generatedFS:req(n),process:{exitCode:0},console:{log(){},error:console.error},Buffer,__dirname:path.join(root,'tools')};
 await vm.runInNewContext(code,sandbox);
 if(sandbox.process.exitCode)throw Error('Reference generator failed');
 const prior=writes.get(key('thesis/Ban_thao_Chuong_1-4_v0.11_corrected.docx'));if(!prior)throw Error('No prior candidate captured');
 const current=fs.readFileSync(path.join(root,'thesis/Ban_thao_Chuong_1-4_v0.11_corrected.docx'));
 const a=await Zip.loadAsync(prior),b=await Zip.loadAsync(current),W='http://schemas.openxmlformats.org/wordprocessingml/2006/main';
 const paras=async z=>{const d=new DOMParser().parseFromString(await z.file('word/document.xml').async('string'),'text/xml');return Array.from(d.getElementsByTagNameNS(W,'p')).map(p=>Array.from(p.getElementsByTagNameNS(W,'t')).map(n=>n.textContent).join(''));};
 const old=await paras(a),now=await paras(b),m=old.length,n=now.length,dp=Array.from({length:m+1},()=>new Uint16Array(n+1));
 for(let i=m-1;i>=0;i--)for(let j=n-1;j>=0;j--)dp[i][j]=old[i]===now[j]?1+dp[i+1][j+1]:Math.max(dp[i+1][j],dp[i][j+1]);
 let i=0,j=0;const removed=[],added=[];
 while(i<m||j<n){if(i<m&&j<n&&old[i]===now[j]){i++;j++;}else if(j<n&&(i===m||dp[i][j+1]>=dp[i+1][j])){added.push({currentId:j,text:now[j++]});}else removed.push({priorId:i,text:old[i++]});}
 const crypto=require('crypto'),hash=x=>crypto.createHash('sha256').update(x).digest('hex');
 const media=[];for(const f of Object.keys(a.files).filter(x=>x.startsWith('word/media/')&&!a.files[x].dir)){const ab=await a.file(f).async('nodebuffer'),bb=await b.file(f).async('nodebuffer');if(hash(ab)!==hash(bb))media.push(f);}
 fs.writeFileSync(path.join(out,'prior-generated-reference.docx'),prior);
 const result={priorRecreatedSHA256:hash(prior),expectedPriorSHA256:'1dc017ada44d9ba7a56b9f81b4e5fe3d456e58dab6b9e61af2308185dc809b38',priorExactHash:hash(prior)==='1dc017ada44d9ba7a56b9f81b4e5fe3d456e58dab6b9e61af2308185dc809b38',currentSHA256:hash(current),priorParagraphs:m,currentParagraphs:n,changedMedia:media,removed,added};
 fs.writeFileSync(path.join(out,'manual-edit-diff.json'),JSON.stringify(result,null,2));console.log(JSON.stringify({priorExactHash:result.priorExactHash,priorParagraphs:m,currentParagraphs:n,removed:removed.length,added:added.length,changedMedia:media}));
})().catch(e=>{console.error(e.stack);process.exitCode=1;});
