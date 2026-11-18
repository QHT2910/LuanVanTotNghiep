# QA lifecycle clarification — v0.11_corrected

Orca Worker tester bkm37d3uiwhgp757im7y9hov,18/11/2026. **PASS trong phạm vi closure**, không phát hiện P1/P2 về thứ tự hook, phạm vi hình/caption hoặc reflow đã kiểm. Đây không phải Cindy acceptance hoặc full111page review mới.

## Đối chiếu nguồn mới

Worker đọc độc lập component.dart/node.dart của **flutter_scene0.24.3**: attachTo gán node rồi onAttach; addComponent attachTo trước mount; mount đặt mounted=true rồi onMount và onLoad khi chưa loaded. Completion chỉ đặt loaded nếu đang mounted. tick/fixedTick cần cả enabled,mounted,loaded. Rời cảnh chỉ unmount; removeComponent khi live unmount rồi detachFrom; onDetach trước xóa node.

Guard async chỉ là boolean mounted, không có generation/load-in-flight token. Remount khi load trước chưa xong có thể khởi động onLoad lần nữa; không được suy ra completion thuộc lần mount hiện tại hoặc race đã được giải quyết. Prose corrected giữ đúng giới hạn này.

XML thực và ảnh15: p211/213/215/216 theo IDbaseline đúng sửa dự kiến; giữ onAttach→onMount→onLoad, không đảo hook. Caption minh họa một đường đi thành công, không claim hình vẽ ownership. Guard3điều kiện và scope gỡ node đang trong cảnh rõ; ownership/dispose riêng, không nhận sharedGPU giải phóng đồng bộ.

## Kiểm độc lập

- DOCX4887584bytes SHA256 **1dc017ada44d9ba7a56b9f81b4e5fe3d456e58dab6b9e61af2308185dc809b38**.
- PDF2861263bytes SHA256 **9d91ad849e224f4a9ce07e44ede5de311db3cc04cfe0b68f350e72d874db3c3f**.
- So với v0.11_final cũ, chỉ document.xml và image5.png khác.38drawings/27tables,24OMML serialized exact,44refs text exact;4diagram khác/11Figma giữ byte.
- Hash111PNG xác nhận chỉ12trang đổi:1,15–25.99trang còn lại byteexact với render đã QA trước.
- Đã xem sheet04–07,page1 và zoom15/16, bao phủ12trang đổi cùng trang lân cận. Hình/guard/caption15 đọc rõ; remount/ownership đủ trước footer. Bảng16 tiếp17 có header,17–25 không thấy cắt chữ/hình hoặc trang trắng lỗi; hình skinning26 giữ nguyên. Không coi đây là xem lại111trang.
- NativeWord111/chapter1/6/67/101 và0textOutside là gate Lead xuất/render, worker đọc logs, không chạy Word.

## Gates của worker

Get-Content pinned source/revise/review | PASS order/guard/scope | logpath=none.

node stdin crypto2files | PASS hashes/bytes | logpath=none.

node stdin ZIP/XML corrected-vs-final | PASS2parts/24math44refs/38drawing27tables | logpath=none.

node stdin SHA111PNG | PASS12changed/99same | logpath=none.

view_image sheet04–07+page1/15/16 | PASS boundedreflow/lifecycle | logpath=none.

Get-Content corrected logs | PASS đọc Leadgates, không chạy writer | logpath=none.

Giới hạn: chưa thực nghiệm lỗi/remount, print/crossWord hoặc tái thẩm định mọiOMML/refs. Bản corrected có hash mới; QA trước chỉ tái sử dụng cho phần không đổi, không gọi cùng artifact cũ. Numbering16 có yêu cầu bổ sung riêng sau terminal này; xem source review và ảnh corrected-page-16-fresh.png, không suy từ raster cũ bị thiếu prefix.
## Bổ sung terminal numbering16 — PASS

Orca Worker QA bkm gửi cùng một supplement hai lần; Lead lưu một lần, không chạy lại. QA độc lập xem corrected-page-16-fresh.png thấy đủ2.4.3/2.4.4; đọc XML correctedDOCX trong RAM xác nhận hai w:t nguyên vẹn, không numPr. PDF.js đọc trực tiếp cùng correctedPDF: mục2.4.3 tại x85.3/y772.15 và2.4.4 tại x85.3/y454.52, text đầy đủ. Không cần sửa numbering hoặc xuất lại Word/PDF.

Đính chính coverage: lần review trước đã xem PNG16 cũ nhưng ảnh đó chưa đủ căn cứ xác nhận prefix. Supplement này mới xác minh độc lập cả XML/PDFtext/freshPNG. Không xác định nguyên nhân kỹ thuật sâu của raster cũ trong scope, không khái quát mọi lỗi render. Lifecycle closure không đổi; không replay111pages.

view_image fresh16 | PASS2heading | logpath=none.
node stdin JSZip/DOM heading/numPr | PASS haiheading/numPr0 | logpath=none.
node stdin PDF.js page16text | PASS haiitem/tọađộ | logpath=none.

Cindy đã tự xem fresh16/hashcorrectedWordPDF/sourceproof/ảnh15 và ACCEPT bounded corrections để userreview. Tất cả QA liên quan đã terminal; không còn task worker chờ. Correctedartifacts1dc017/9d91ad không đổi, vẫn111trang. Khôngready-to-submit/allacademicclaim. Primary95stop giữ; chỉ lưu report, chưa commit/push correction cho tới liveverifiedreset.
