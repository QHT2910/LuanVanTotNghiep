import fs from 'node:fs';
import {getDocument} from '../.local-tools/node_modules/pdfjs-dist/legacy/build/pdf.mjs';
const file=process.argv[2],out=process.argv[3];
const pdf=await getDocument({data:new Uint8Array(fs.readFileSync(file)),useSystemFonts:true}).promise;
const pages=[],chapters=[],captions=[];
for(let n=1;n<=pdf.numPages;n++){
 const p=await pdf.getPage(n),tc=await p.getTextContent(),items=tc.items.filter(x=>x.str?.trim());
 const body=items.filter(x=>x.transform[5]>50&&x.transform[5]<790),text=body.map(x=>x.str).join(' ');
 const tops=body.map(x=>x.transform[5]+(x.height||0)),bottoms=body.map(x=>x.transform[5]);
 pages.push({page:n,text,bodyTop:Math.max(...tops),bodyBottom:Math.min(...bottoms),chars:text.length});
 const c=text.match(/CHƯƠNG\s+[1-4]\s*\.\s*[^\n]{0,65}/);if(c)chapters.push({page:n,title:c[0]});
 for(const m of text.matchAll(/Hình\s+\d+[.-]\d+(?:\([a-z0-9]+\))?\./g))captions.push({page:n,label:m[0]});
 p.cleanup();
}
const result={file,pages:pdf.numPages,chapterStarts:chapters.filter(c=>pages[c.page-1].text.indexOf(c.title)<100),captions,items:pages};
fs.writeFileSync(out,JSON.stringify(result,null,2));console.log(JSON.stringify({pages:result.pages,chapterStarts:result.chapterStarts,captions:captions.length}));await pdf.cleanup();
