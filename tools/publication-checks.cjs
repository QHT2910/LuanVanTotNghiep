function assertClean(text,label='document'){
 const compact=text.replace(/\s+/g,'');
 if(/<!--|diagram-svg:|\[图片:|@@EQ|\[\[EQUATION:/.test(compact))throw Error('Technical marker in '+label);
}
module.exports={assertClean};
if(require.main===module){
 const assert=require('node:assert/strict');
 for(const text of ['<!-- diagram-svg: 3-2-usecase-uml.svg -->','diagram-svg:','[图片: missing.png]'])assert.throws(()=>assertClean(text));
 assert.doesNotThrow(()=>assertClean('Hình 3.2. Use case tổng quát.'));
 console.log('PASS publication marker regression cases');
}
