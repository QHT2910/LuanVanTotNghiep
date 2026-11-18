// Surgical review of the user's actual v0.10; never rebuild from Markdown.
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const Zip=require('../.local-tools/node_modules/jszip');
const {DOMParser,XMLSerializer}=require('../.local-tools/node_modules/@xmldom/xmldom');
const {createCanvas,loadImage}=require('../.local-tools/node_modules/@napi-rs/canvas');
const W='http://schemas.openxmlformats.org/wordprocessingml/2006/main',M='http://schemas.openxmlformats.org/officeDocument/2006/math';
const WP='http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',A='http://schemas.openxmlformats.org/drawingml/2006/main';
const all=(n,ns,t)=>Array.from(n.getElementsByTagNameNS(ns,t));
const direct=(n,t)=>Array.from(n?.childNodes||[]).find(x=>x.namespaceURI===W&&x.localName===t);
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const source='thesis/Ban_thao_Chuong_1-4_v0.10.docx',output='thesis/Ban_thao_Chuong_1-4_v0.11_final.docx';
const out='.scratch/thesis-v011';
(async()=>{
 const bytes=fs.readFileSync(source);if(hash(bytes)!=='a3bfb35b02d69e7c941841afe9bfd793e14978946e1d0e361ef2039624e617c1')throw Error('Actual v0.10 changed; stop for review');
 const z=await Zip.loadAsync(bytes),parse=s=>new DOMParser().parseFromString(s,'text/xml'),ser=n=>new XMLSerializer().serializeToString(n);
 const d=parse(await z.file('word/document.xml').async('string')),ps=all(d,W,'p'),changes=[];
 const txt=p=>all(p,W,'t').map(t=>t.textContent).join('');
 const beforeMath=all(d,M,'oMath').map(ser),beforeRefs=ps.filter(p=>/^\[\d+\]/.test(txt(p))).map(txt);
 function text(id,value){const p=ps[id];if(all(p,M,'oMath').length||all(p,W,'drawing').length)throw Error('Unsafe text paragraph '+id);const ts=all(p,W,'t');if(!ts.length)throw Error('No text '+id);ts[0].textContent=value;for(const t of ts.slice(1))t.textContent='';changes.push({kind:'text',baselineParagraph:id});}
 function replace(id,old,value){if(!txt(ps[id]).includes(old))throw Error('Missing anchor '+id);text(id,txt(ps[id]).replace(old,value));}
 function remove(id){ps[id].parentNode.removeChild(ps[id]);changes.push({kind:'remove_repetition',baselineParagraph:id});}
 function prop(id,name,value='1'){const p=ps[id];let pp=direct(p,'pPr');if(!pp){pp=d.createElementNS(W,'w:pPr');p.insertBefore(pp,p.firstChild);}let n=direct(pp,name);if(!n){n=d.createElementNS(W,'w:'+name);pp.appendChild(n);}n.setAttributeNS(W,'w:val',value);}
 text(22,'Điều kiện thử nghiệm còn giới hạn: bản tập offline đã được kiểm tra trên một giả lập Android, nhưng chưa có kết quả trên Redmi Note 11 hoặc hai điện thoại thật. Máy khách trên máy tính hoặc giả lập hỗ trợ phát triển nhưng không thay bằng chứng thử hai điện thoại.');
 text(473,'Mỗi mốc có mục tiêu, tiền đề, tệp, mã mới, lệnh và dấu hiệu dự kiến. Phân tích tĩnh không thay thế quan sát thiết bị. Trong lượt kiểm bộ bài thực hành này, A–F và toàn project qua analyze, bundle F tạo được, còn phép kiểm snapshot→node hai client đạt trong Flutter test headless. Lượt kiểm đó chưa bao gồm quan sát SceneView trên Android hoặc phát hoạt ảnh Fox; bằng chứng AVD của các mốc sau được trình bày riêng ở Chương 4.');
 replace(476,'Bộ source đã kiểm tra bundle chưa chứa Android runner.','Lượt kiểm bundle được mô tả ở đây chưa bao gồm việc tạo và kiểm Android runner.');
 text(479,txt(ps[479]).replace(/^[^.]+\./,'Việc tạo runner không thuộc lượt kiểm bundle nêu trên.'));
 text(922,txt(ps[922]).replace(/^[^.]+\./,'Trong lượt kiểm bundle của bài F, nhánh GLB đã được phân tích và đóng gói; lượt kiểm đó chưa xác nhận việc nạp, giải mã hoặc phát clip trên GPU.'));
 text(1012,'Chưa chạy trong lượt kiểm tutorial được tổng hợp ở bảng này');
 replace(1258,'Hai người kết nối đến cùng một máy chủ có địa chỉ tiếp cận được qua Internet.','Trong thiết kế mục tiêu, hai người dự kiến kết nối đến cùng một máy chủ có địa chỉ tiếp cận được qua Internet.');
 remove(1443);text(1444,'Bảng sau mô tả các trạng thái logic của thiết kế 1v1, không phải tên API đã triển khai. Nhảy và Dash đã có biến thể offline; các guard và tham số dành cho đối kháng, điều kiện máy chủ và Block vẫn cần được xác nhận.');remove(1445);
 text(1477,'Các connector cùng nhãn nối các phần của Hình 3.7: T tới kiểm tra thời gian ở (b1), V tới kiểm Block ở (b2), G tới kiểm qua rổ ở (c1), L tới kiểm trượt ở (c2), E tới kết thúc không điểm mới ở (b1), F tới bóng tự do ở (b2). Z kết thúc xử lý use case, không mặc định kết thúc trận. Nhánh trượt–Không quay về T để tiếp tục vòng cập nhật.');ps[1442].parentNode.insertBefore(ps[1477],ps[1442].nextSibling);
 remove(1544);text(216,'Trong hình, quyền sở hữu Scene là trách nhiệm riêng: ứng dụng dispose Scene do mình tạo; SceneView.declarative chịu trách nhiệm với Scene nội bộ khi view được dispose. Đây không phải bước tiếp nối của mọi component. Hình không bao quát mọi trường hợp lỗi hoặc remount và không khẳng định mọi tài nguyên GPU dùng chung được hủy đồng bộ khi gọi dispose.');
 replace(1384,'Định danh phiên lấy từ kết nối, không lấy từ mã người chơi tự khai báo trong gói tin.','');
 for(const id of [1422,1424,1426,1428,1435,1437,1439,1442]){replace(id,' Nguồn: thiết kế đề xuất của tác giả.','');prop(id,'jc','center');}
 // Preserve the historical experiment cut-off explicitly; no new results inserted.
 text(1583,txt(ps[1583])+' Phạm vi kết quả của chương giới hạn ở các bản M1–M3b; các bước phát triển sau các mốc này chưa được tổng hợp trong chương.');
 // Move explanations after the screen-flow figure to allow the figure earlier.
 const anchor=ps[1538].nextSibling;for(const id of [1534,1535])ps[1538].parentNode.insertBefore(ps[id],anchor);
 replace(1536,'như đã mô tả ở trên','như phần diễn giải bên dưới');
 // Code paragraphs retain exact non-empty text and spacing; release long keepNext chains.
 let removedBlank=0,released=0,run=0;
 for(let id=491;id<=1252;id++){
  const p=ps[id],t=txt(p),pp=direct(p,'pPr');
  if(!p.parentNode||direct(pp,'pStyle')||all(p,W,'drawing').length||all(p,M,'oMath').length){run=0;continue;}
  const empty=!t.trim()&&!all(p,W,'br').length&&!all(p,W,'bookmarkStart').length&&!all(p,W,'fldChar').length&&!all(p,W,'sectPr').length;
  if(empty){p.parentNode.removeChild(p);removedBlank++;run=0;continue;}
  const kn=direct(pp,'keepNext');
  if(kn&&kn.getAttributeNS(W,'val')!=='0'){
   run++;if((run>=3&&/[;}\]]\s*$/.test(t))||run>=6){kn.setAttributeNS(W,'w:val','0');released++;run=0;}
  }else run=0;
 }
 // References may split between entries, never within an individual entry.
 for(let id=1728;id<ps.length;id++)if(/^\[\d+\]/.test(txt(ps[id])))prop(id,'keepLines');
 // Re-layout five vector diagrams without changing nodes, arrows or labels.
 const dir='diagrams/review-v011';fs.mkdirSync(dir,{recursive:true});
 const esc=s=>s.replaceAll('&','&amp;').replaceAll('<','&lt;');
 const box=(x,y,w,label)=>`<rect x="${x}" y="${y}" width="${w}" height="48" rx="3" fill="white" stroke="black" stroke-width="1.5"/><text x="${x+w/2}" y="${y+30}" text-anchor="middle" font-family="Times New Roman" font-size="22">${esc(label)}</text>`;
 const arrow=(x1,y1,x2,y2,label='')=>{const dx=x2-x1,dy=y2-y1,l=Math.hypot(dx,dy),ux=dx/l,uy=dy/l;return `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="black" stroke-width="1.5"/><polygon points="${x2},${y2} ${x2-ux*10-uy*4},${y2-uy*10+ux*4} ${x2-ux*10+uy*4},${y2-uy*10-ux*4}"/><text x="${(x1+x2)/2+12}" y="${(y1+y2)/2-6}" font-family="Times New Roman" font-size="21">${esc(label)}</text>`;};
 const diagrams=[
  {id:145,media:'image1.png',name:'2-1-rendering-layers',w:700,h:185,shapes:box(15,10,160,'Dart')+box(265,10,160,'Scene')+box(515,10,170,'Flutter GPU')+box(515,125,170,'Impeller')+box(265,125,160,'GPU')+arrow(175,34,265,34)+arrow(425,34,515,34)+arrow(600,58,600,125)+arrow(515,149,425,149)},
  {id:199,media:'image3.png',name:'2-3-mvp-spaces',w:640,h:175,shapes:box(20,10,180,'Local')+box(440,10,180,'World')+box(440,115,180,'View')+box(20,115,180,'Clip')+arrow(200,34,440,34,'M')+arrow(530,58,530,115,'V')+arrow(440,139,200,139,'P')},
  {id:374,media:'image7.png',name:'2-7-fixed-render-interpolation',w:700,h:230,shapes:box(15,10,180,'S tại t − h')+box(505,10,180,'S tại t')+box(255,90,190,'Nội suy')+box(15,170,180,'α = a/h')+box(505,170,180,'Render')+arrow(195,34,505,34,'h')+arrow(105,58,255,110)+arrow(595,58,445,110)+arrow(195,194,255,130)+arrow(445,130,505,194)},
  {id:214,media:'image5.png',name:'2-5-lifecycle-ownership',w:760,h:290,shapes:
   '<rect x="5" y="5" width="750" height="100" fill="none" stroke="#777"/><text x="380" y="29" text-anchor="middle" font-family="Times New Roman" font-size="23">Gắn và nạp thành công</text>'+box(20,45,200,'onAttach')+box(280,45,200,'onMount')+box(540,45,200,'onLoad')+arrow(220,69,280,69)+arrow(480,69,540,69)+
   '<path d="M 640 93 V 128 H 120 V 213" fill="none" stroke="black" stroke-width="1.5"/><polygon points="120,213 116,203 124,203"/><text x="380" y="121" text-anchor="middle" font-family="Times New Roman" font-size="21">loaded khi còn mounted</text><rect x="5" y="165" width="750" height="115" fill="none" stroke="#777"/><text x="380" y="193" text-anchor="middle" font-family="Times New Roman" font-size="23">Tham gia và rời cảnh</text>'+box(20,213,220,'update / fixedUpdate')+box(290,213,200,'onUnmount')+box(540,213,200,'onDetach')+arrow(240,237,290,237)+arrow(490,237,540,237).replace('<line ','<line stroke-dasharray="5 4" ')},
  {id:1436,media:'image24.png',name:'3-7b2-block',w:760,h:300,shapes:
   '<circle cx="40" cy="70" r="22" fill="white" stroke="black"/><text x="40" y="78" text-anchor="middle" font-family="Times New Roman" font-size="22">V</text><polygon points="235,20 345,70 235,120 125,70" fill="white" stroke="black"/><text x="235" y="78" text-anchor="middle" font-family="Times New Roman" font-size="22">Block hợp lệ?</text>'+arrow(62,70,125,70)+arrow(345,70,450,70,'Có')+
   '<rect x="450" y="36" width="285" height="68" fill="white" stroke="black"/><text x="592" y="63" text-anchor="middle" font-family="Times New Roman" font-size="22">Bóng tự do,</text><text x="592" y="90" text-anchor="middle" font-family="Times New Roman" font-size="22">vô hiệu cú ném</text>'+arrow(235,120,235,209,'Không')+
   '<circle cx="235" cy="232" r="23" fill="white" stroke="black"/><text x="235" y="240" text-anchor="middle" font-family="Times New Roman" font-size="22">G</text><circle cx="390" cy="174" r="22" fill="white" stroke="black"/><text x="390" y="182" text-anchor="middle" font-family="Times New Roman" font-size="22">F</text><path d="M 412 174 H 592 V 104" fill="none" stroke="black" stroke-width="1.5"/><polygon points="592,104 588,114 596,114"/>'+arrow(680,104,680,215)+box(470,215,265,'Kết thúc use case')}
 ];
 for(const item of diagrams){
  const svg=`<svg xmlns="http://www.w3.org/2000/svg" width="${item.w}" height="${item.h}" viewBox="0 0 ${item.w} ${item.h}"><rect width="100%" height="100%" fill="white"/>${item.shapes}</svg>`;
  fs.writeFileSync(path.join(dir,item.name+'.svg'),svg);const im=await loadImage(Buffer.from(svg)),c=createCanvas(item.w*3,item.h*3);c.getContext('2d').drawImage(im,0,0,c.width,c.height);const png=c.toBuffer('image/png');fs.writeFileSync(path.join(dir,item.name+'.png'),png);z.file('word/media/'+item.media,png);
  const drawing=all(ps[item.id],W,'drawing')[0],cx=Math.round(431*12700),cy=Math.round(431*item.h/item.w*12700);
  for(const e of [...all(drawing,WP,'extent'),...all(drawing,A,'ext')]){e.setAttribute('cx',String(cx));e.setAttribute('cy',String(cy));}
  changes.push({kind:'diagram_relayout',baselineParagraph:item.id,media:item.media,widthPt:431,heightPt:cy/12700});
 }
 if(all(d,M,'oMath').map(ser).join('')!==beforeMath.join(''))throw Error('Math changed');
 if(JSON.stringify(all(d,W,'p').filter(p=>/^\[\d+\]/.test(txt(p))).map(txt))!==JSON.stringify(beforeRefs))throw Error('References changed');
 if(all(d,W,'drawing').length!==38)throw Error('Drawing count changed');
 z.file('word/document.xml',ser(d));fs.writeFileSync(output,await z.generateAsync({type:'nodebuffer',compression:'DEFLATE'}));
 const report={source,sourceSHA256:hash(bytes),output,outputSHA256:hash(fs.readFileSync(output)),removedBlankCodeParagraphs:removedBlank,releasedCodeKeepNext:released,drawings:38,omml:beforeMath.length,references:beforeRefs.length,changes};
 fs.writeFileSync(out+'/surgical-changes.json',JSON.stringify(report,null,2));console.log(JSON.stringify(report));
})().catch(e=>{console.error(e.stack);process.exitCode=1;});

