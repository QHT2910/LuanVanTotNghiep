import fs from 'node:fs';
import {createRequire} from 'node:module';
import {getDocument} from '../.local-tools/node_modules/pdfjs-dist/legacy/build/pdf.mjs';
const require=createRequire(import.meta.url),{assertClean}=require('./publication-checks.cjs');
const file=process.argv[2];if(!file)throw Error('Provide PDF path');
const doc=await getDocument({data:new Uint8Array(fs.readFileSync(file)),useSystemFonts:true}).promise;
const pages=[];
for(let n=1;n<=doc.numPages;n++){
 const p=await doc.getPage(n),t=(await p.getTextContent()).items.map(x=>x.str).join(' ');
 assertClean(t,'PDF page '+n);pages.push({page:n,chars:t.length});
}
console.log(JSON.stringify({result:'PASS',pages:doc.numPages,technicalMarkers:false,pageTextCounts:pages},null,2));await doc.cleanup();
