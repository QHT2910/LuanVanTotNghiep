// Publication-only OMML conversion; never rewrites Dart code paragraphs.
const M='http://schemas.openxmlformats.org/officeDocument/2006/math';
const W='http://schemas.openxmlformats.org/wordprocessingml/2006/main';
module.exports=function applyMath(doc){
 const el=n=>doc.createElementNS(M,'m:'+n);
 function run(s){const r=el('r'),wp=doc.createElementNS(W,'w:rPr'),f=doc.createElementNS(W,'w:rFonts');f.setAttributeNS(W,'w:ascii','Cambria Math');f.setAttributeNS(W,'w:hAnsi','Cambria Math');wp.appendChild(f);const z=doc.createElementNS(W,'w:sz');z.setAttributeNS(W,'w:val','26');wp.appendChild(z);r.appendChild(wp);const t=el('t');t.setAttribute('xml:space','preserve');t.appendChild(doc.createTextNode(s));r.appendChild(t);return r;}
 function sub(base,index){const s=el('sSub'),e=el('e'),b=el('sub');e.appendChild(run(base));b.appendChild(run(index));s.appendChild(e);s.appendChild(b);return s;}
 function sup(base,index){const s=el('sSup'),e=el('e'),b=el('sup');e.appendChild(run(base));b.appendChild(run(index));s.appendChild(e);s.appendChild(b);return s;}
 const vars=/(L|f|J|G|B|w|p|M|W|ω|Σ|∫)_(o|i|r|j|clip|model|world|local|parent|child|root|ndc|Ω)\b|M\(t\)⁻¹/g;
 function terms(s){const a=[];let last=0;for(const m of s.matchAll(vars)){if(m.index>last)a.push(run(s.slice(last,m.index)));a.push(m[0]==='M(t)⁻¹'?sup('M(t)','−1'):sub(m[1],m[2]));last=m.index+m[0].length;}if(last<s.length)a.push(run(s.slice(last)));return a;}
 function nary(symbol,index,body){const n=el('nary'),pr=el('naryPr'),c=el('chr'),l=el('limLoc'),hide=el('supHide');c.setAttributeNS(M,'m:val',symbol);l.setAttributeNS(M,'m:val','subSup');hide.setAttributeNS(M,'m:val','1');pr.appendChild(c);pr.appendChild(l);pr.appendChild(hide);n.appendChild(pr);const b=el('sub'),su=el('sup'),e=el('e');b.appendChild(run(index));for(const t of terms(body))e.appendChild(t);n.appendChild(b);n.appendChild(su);n.appendChild(e);return n;}
 let displays=0,inlines=0;
 for(const p of Array.from(doc.getElementsByTagNameNS(W,'p'))){
  const sh=Array.from(p.getElementsByTagNameNS(W,'shd'));if(sh.some(n=>n.getAttributeNS(W,'fill')==='F2F3F5'))continue;
  const text=Array.from(p.getElementsByTagNameNS(W,'t')).map(t=>t.textContent).join('');
  if(/^(L_o\(|J_j\(|p′ = Σ_j)/.test(text)){
   const om=el('oMath'),para=el('oMathPara');
   const op=text.includes('∫_Ω')?'∫_Ω':text.includes('Σ_j')?'Σ_j':null;
   if(op){const at=text.indexOf(op);for(const n of terms(text.slice(0,at)))om.appendChild(n);om.appendChild(nary(op[0],op.slice(2),text.slice(at+op.length)));}
   else for(const n of terms(text))om.appendChild(n);
   for(const n of Array.from(p.childNodes))if(n.localName!=='pPr')p.removeChild(n);
   para.appendChild(om);p.appendChild(para);displays++;continue;
  }
  for(const r of Array.from(p.childNodes).filter(n=>n.namespaceURI===W&&n.localName==='r')){
   const ts=Array.from(r.getElementsByTagNameNS(W,'t'));if(ts.length!==1)continue;const s=ts[0].textContent;
   if(!/(?:L|f|J|G|B|w|p|M|W|ω|Σ|∫)_(?:o|i|r|j|clip|model|world|local|parent|child|root|ndc|Ω)\b/.test(s))continue;
   const rx=/(L|f|J|G|B|w|p|M|W|ω|Σ|∫)_(o|i|r|j|clip|model|world|local|parent|child|root|ndc|Ω)\b/g;let last=0;
   function plain(t){if(!t)return;const clone=r.cloneNode(true);clone.getElementsByTagNameNS(W,'t')[0].textContent=t;p.insertBefore(clone,r);}
   for(const m of s.matchAll(rx)){plain(s.slice(last,m.index));const om=el('oMath');om.appendChild(sub(m[1],m[2]));p.insertBefore(om,r);last=m.index+m[0].length;inlines++;}plain(s.slice(last));p.removeChild(r);
  }
 }
 return {displayEquations:displays,inlineSubscripts:inlines};
};
