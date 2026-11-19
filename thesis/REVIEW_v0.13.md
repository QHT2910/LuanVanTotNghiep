# Bản v0.13 để tác giả review — 19/11/2026

Nguồn là bản Word v0.12_final thực tế, 6.360.390 byte, SHA256 488390fb4e387c318099ee572b28c5d20b28af7b845437455f1fdf18bab6ca89. Đã đối chiếu không có sửa tay mới và sao lưu có timestamp/hash trước khi sửa. Không dựng lại từ Markdown hoặc ghi đè bản cũ.

## Thay đổi

- Chương 2 bỏ toàn bộ listing, lệnh chạy, pseudocode và nhãn “Mã ví dụ (tiếp)”. Mục 2.12 thay bằng 50 đoạn, giữ 14 tiểu mục, giải thích vai trò và trình tự API, quyền cập nhật, điều kiện vòng đời, tham số, thu hồi tài nguyên, snapshot và cơ chế rebuild/reload. Ba bảng liên quan hướng dẫn mã được thay bằng diễn giải; không chuyển mã sang phụ lục.
- Ngoài 2.12, ba đoạn về lifecycle, tham số ánh sáng và lời nối được sửa có giới hạn. Công thức toán và tên API trong lý thuyết/UML được giữ.
- 44 nguồn bỏ trường ngày truy cập/đối chiếu. Giữ số nguồn, tác giả, tiêu đề, URL, liên kết và ngày xuất bản; nguồn [38] vẫn giữ ngày đăng 01/10/2026. Không thêm nguồn hoặc kết quả thử.
- Quy định và outline đồng bộ yêu cầu mới; đường xuất HTML cũ bị chặn cho v0.13 để tránh thay phân trang native Word.

## Bảo toàn và phân trang

Word xuất PDF native: 108 → 84 trang. Chương 1/2/3/4 bắt đầu trang 1/5/42/74; tài liệu tham khảo trang 82–84. Phần diễn giải thay mã ở trang 35–41. Không có mục lục trường TOC trong nguồn hoặc bản mới; số tiểu mục và dẫn chiếu 2.12.11/13/14 được giữ.

38 hình (gồm 11 frame Figma), 24 OMML và tất cả media giữ nguyên byte; XML caption hình giữ nguyên. Chương 1, 3, 4 giữ nguyên chữ. Số bảng 27 → 24 do ba bảng mã được thay có chủ đích. Ngoài document.xml, 52 ZIP parts giữ nguyên byte. TNR13/Before6/Multiple1.3 và caption nhãn BIU-only qua checker; không áp normalizer toàn văn lên bản sửa tay.

Lead đã xem 21/21 contact sheet, đủ 84 trang, và phóng trang 36/39/40/84. Không thấy trang trắng hoàn toàn, tràn khổ, caption hình riêng trang hoặc hình méo. Các khoảng trắng cuối chương và trước hình nguyên khối được giữ khi cần để nhãn đọc rõ. Một số sơ đồ sequence/class vẫn chiếm phần lớn trang; không thu nhỏ thêm. Renderer ghi textOutsidePhysicalPage=0. Pipeline: native Microsoft Word → PDF → PDF.js/render từng trang trong process riêng → contact sheet và ảnh đọc rõ. Đây là kiểm phân trang trên Word hiện có, không chứng nhận bản in hoặc Word trên máy khác.

## Đối chiếu nội dung và giới hạn

Đã đối chiếu source tutorial host, declarative và SnapshotReplica; pinned Scene 0.24.3 component/node/light/widgets xác nhận onAttach trước onMount rồi onLoad, guard mounted/enabled/loaded, getter transform trả bản sao, kiểu loading ResourceGroup và phạm vi controller. Phần lifecycle giữ caveat async/remount và unmount không đồng nghĩa detach. SnapshotReplica dùng close, kiểm dữ liệu trước ghi node; không nâng ví dụ thành game mạng hoàn chỉnh.

Các kết quả analyze/bundle/headless ở Chương 4 là bằng chứng lịch sử của bộ bài; không chạy lại code, build, game hoặc network trong lượt này. Bỏ listing không làm phát sinh bằng chứng runtime mới. Chưa thẩm định lại từng công thức và toàn bộ nội dung 44 nguồn; bản này để tác giả review, không tuyên bố ready-to-submit.

QA Orca Worker đã kiểm độc lập cấu trúc/bảo toàn và toàn bộ diễn giải mới, xem trang35–41/82–84: đạt phạm vi này; yêu cầu bỏ ghi chú quy trình còn sót trong refs. Cindy tự hash candidate và xem36/39/40/84, chấp nhận phần đã xem, yêu cầu cleanup refs. Không bên nào nhận đã xem toàn84trang hoặc thẩm định học thuật toàn bộ.

Bản bàn giao hiện hành là v0.13_final.docx/PDF. Đã bỏ riêng ba ghi chú quy trình ở [36], [38], [40], giữ ngày đăng 01/10/2026 và toàn bộ thông tin nguồn/URL. Bản final vẫn84trang; so render candidate, chỉ83–84 đổi, 82PNG khác byte-identical. Lead đã xem hai trang mới, không clipping; own Word đã đóng sau xuất. Danh tính final: DOCX7ae85ae3ffcc28dee7116011f5318bebf03d156346e2f09314addb29c8376aa7 /6080056byte; PDFaa7489781e24ee6a154fcf87923e7baed6111b6e0eec3ee01a2ac513bbb1bd69 /3400704byte. Xem qa/thesis-v013/artifacts-final.json, refs-closure.json và *-final-check logs. Cindy đã tự xem final83/84 và hash cả hai tệp, đóng finding tham khảo; QA Orca Worker terminal PASS closure với hash/XML/ảnhfinal độc lập, chỉ ba reference text đổi. Không dùng hash candidate thay final. Bản này được bàn giao để tác giả review; các giới hạn học thuật/bản in nêu trên vẫn áp dụng.
