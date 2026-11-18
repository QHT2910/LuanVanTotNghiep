// Caption-only export. Never overwrite a user manuscript in place.
const fs=require('fs'),path=require('path'),Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser,XMLSerializer}=require('../.local-tools/node_modules/@xmldom/xmldom');
(async()=>{
 const [file,out]=process.argv.slice(2);if(!file||!out||path.resolve(file)===path.resolve(out))throw Error('Distinct input and output DOCX paths required');
 const z=await Zip.loadAsync(fs.readFileSync(file)),d=new DOMParser().parseFromString(await z.file('word/document.xml').async('string'),'text/xml');
 const result=require('./figure-caption.cjs').format(d);z.file('word/document.xml',new XMLSerializer().serializeToString(d));
 fs.writeFileSync(out,await z.generateAsync({type:'nodebuffer',compression:'DEFLATE'}));console.log(JSON.stringify(result));
})().catch(e=>{console.error(e.message);process.exitCode=1;});
