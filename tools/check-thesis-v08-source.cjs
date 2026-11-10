const fs=require('node:fs'),assert=require('node:assert/strict');
const {execFileSync}=require('node:child_process');
const read=p=>fs.readFileSync(p,'utf8');
const files=['thesis/01-gioi-thieu.md','thesis/02-co-so-ly-thuyet.md','thesis/03-xay-dung-game.md','thesis/04-kiem-thu.md'];
const refs=read('thesis/REFERENCES.md');
const numbers=[...refs.matchAll(/^\[(\d+)\]/gm)].map(m=>Number(m[1]));
assert.deepEqual(numbers,Array.from({length:44},(_,i)=>i+1));
for(const n of [3,4])assert.equal(read(`thesis/BAN_THAO_CHUONG_1-${n}.md`),files.slice(0,n).map(read).join('\n\n')+'\n\n'+refs);
for(const p of files){const s=read(p),prose=s.replace(/```[\s\S]*?```/g,'');assert.equal((s.match(/^```/gm)||[]).length%2,0,p);assert(!/D:\\|C:\\|D:\/|C:\/|logpath=|PROJECT_BRIEF\.md|THESIS_M3B|NGUỒN-|\*\*/.test(prose),p);for(const m of prose.matchAll(/\[(\d+(?:\s*,\s*\d+)*)\]/g))for(const id of m[1].split(/\s*,\s*/))assert(numbers.includes(Number(id)),p+': unknown citation '+id);}
for(const p of ['thesis/02-co-so-ly-thuyet.md','thesis/REFERENCES.md'])assert.equal(read(p),execFileSync('git',['show','HEAD:'+p],{encoding:'utf8'}),'Unplanned Ch2/reference edit');
const ch3=read(files[2]),ch4=read(files[3]);
assert(!ch3.includes('Thiết kế 1v1 từng đề xuất'));
for(const dir of ['lib/src/input','lib/src/simulation','lib/src/presentation'])assert(ch3.includes(dir));
assert(ch4.includes('| Thư viện kết xuất 3D | flutter_scene 0.24.3 |'));
const cases=[...ch4.matchAll(/^\| (KT\d{2}) \|/gm)].map(m=>m[1]);assert.deepEqual(cases,Array.from({length:13},(_,i)=>'KT'+String(i+1).padStart(2,'0')));
for(const id of ['4.1.','4.2.','4.3.','4.4.'])assert(ch4.includes('## '+id));
for(const term of ['| M1 | 13 |','| M2 | 22 |','| M3a | 34 |','| M3b | 47 |','hai ca hai pointer riêng','phác thảo UI01–UI06 đã được duyệt'])assert(ch4.includes(term),term);
console.log(JSON.stringify({result:'PASS',chapters:4,references:44,cases:cases.length,combinedExact:true,ch2Unchanged:true,wordOrPDFValidated:false},null,2));
