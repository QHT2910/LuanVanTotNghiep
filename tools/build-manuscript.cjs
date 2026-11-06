const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const chapters=['thesis/01-gioi-thieu.md','thesis/02-co-so-ly-thuyet.md','thesis/03-xay-dung-game.md'];
let text=chapters.map(read).join('\n\n');
if(fs.existsSync(path.join(root,'thesis/REFERENCES.md')))text+='\n\n'+read('thesis/REFERENCES.md');
fs.writeFileSync(path.join(root,'thesis/BAN_THAO_CHUONG_1-3.md'),text);
const word=text.replace(/<!-- diagram: ([^\r\n]+) -->\s*```mermaid\s*[\s\S]*?```/g,(_,name)=>`![Thiết kế đề xuất — ${name}](../diagrams/${name.replace('.mmd','.png')})`)
 .replace(/!\[([^\n]*?)\]\((\.\.\/diagrams\/(2-[^)]+)\.png)\)/g,(_,caption,url,name)=>`![Thiết kế đề xuất — ${name}.mmd](${url})`)
 .replace(/<!--[\s\S]*?-->/g,'')
 .replace(/```(\w*)\n([\s\S]*?)```/g,(whole,lang,body)=>{
  const lines=body.trimEnd().split('\n');if(lines.length<=32)return whole;
  const chunks=[];while(lines.length){let count=Math.min(28,lines.length);if(lines.length>28){for(let n=28;n>=20;n--)if(!lines[n-1].trim()){count=n;break;}}chunks.push('```'+lang+'\n'+lines.splice(0,count).join('\n')+'\n```');}
  return chunks.join('\n\nMã ví dụ (tiếp):\n\n');
 });
fs.mkdirSync(path.join(root,'.scratch'),{recursive:true});
fs.writeFileSync(path.join(root,'.scratch/word-input.md'),word);
if(process.argv.includes('--json'))console.log(JSON.stringify({markdown:word,chars:word.length}));
else console.log('Updated combined Markdown and .scratch/word-input.md.');
