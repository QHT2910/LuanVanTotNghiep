# Sửa theo review độc lập v0.4 — R3, 05/11/2026

Baseline 2e114a1. Phạm vi giới hạn Ch2 và ví dụ thực hành; không chạy lại toàn R2, không đổi kiến trúc game hoặc model/provider, giữ v0.3/v0.4. Research Argon vẫn có blocker saved provider cindy_openai; không retry hoặc nhận lượt Gemini đã chạy.

## Thay đổi đối chiếu review

| Điểm | Sản phẩm sửa |
|---|---|
| R3-01, main315 dòng và helper xuất hiện muộn | Sáu entrypoint A–F tăng dần, host chung tạo trước và source đầy đủ riêng; mã dài nhất trong Ch2 là 77 dòng, không còn main315 dòng |
| R3-02, smoke không cập nhật node | Giữ smoke R2 làm tiền đề; thêm SnapshotReplica một writer và test hai WebSocket clients/two fs.Node riêng, kiểm lịch sử từng packet thay vì chỉ snapshot cuối |
| R3-03, công thức thiếu ví dụ | TR/RT có ma trận/bộ số và hình; FOV/aspect định lượng; bảng directional/point/spot; skinning hai joint cùng hệ tọa độ; bảng roughness/metallic có điều kiện kiểm soát |
| R3-04, placeholder asset | Fox chính thức Khronos tại commit cố định, license/attribution/GLB/hash/clips thực; F có scale0,01 và Walk; BasicSimulation gọi đúng bài trigger, chưa có solver demo |
| R3-05, tổ chức/caption/toán | Chuyển sRGB về texture; 8 hình lý thuyết đánh số theo thứ tự xuất hiện, tên tiếng Việt/nguồn/dẫn trước-sau; ma trận trình bày bằng bảng, không để raw LaTeX |
| R3-06, khảo sát | Thêm Basketball Arena từ publisher và bảng tiêu chí tách công cụ/game; chưa nhận đã chơi/xem video; không đoán tag engine |

## Phân công thực tế

Orca Worker developer (Sol6.1) soạn host/A–F/adapter/test; thesis (Sol6.1) soạn ví dụ/caption/bảng khảo sát và đối chiếu light/camera API; diagrams (Sol6.1) soạn hai Mermaid và bảng FOV. Tất cả chỉ đọc do root cũ, Lead lưu/tích hợp. Không dùng native subagent, không tạo worker trùng. Lead kiểm chứng asset, chạy source, xuất tài liệu. QA được giao rà bản tích hợp riêng.

## Kiểm tra thật

- flutter pub get --offline: đạt; game/evidence-r3/pub-get.txt.
- flutter analyze từng A–F và toàn project: đạt; analyze-a.txt đến analyze-f.txt, analyze-all.txt.
- flutter test test/snapshot_replica_test.dart --reporter expanded: đạt lần cuối; snapshot-test-final.txt. Lần đầu sai tolerance y0,35 do Float32 (~6e-9), đổi1e-9 thành1e-6 có chú thích, không sửa logic guard; log lỗi đầu giữ snapshot-test.txt.
- flutter build bundle --debug --target-platform android-arm64 --target lib/checkpoints/f/main.dart: đạt; build-f.txt, kernel/hash/assetIncluded trong checks.json.
- Fox GLB header/version2/JSON/3 clip/hash kiểm thành công; fox-metadata.json. Chưa chạy importer/animation trên GPU.
- Hai Mermaid render đạt; .scratch/r3-diagram-render.log. Đã xem PNG gốc, không thấy nhãn cắt.
- Word v0.5 XML/citations/16 ảnh đạt; .scratch/r3-word-validate-final.log.
- Microsoft Word COM mở chỉ đọc, repaginate và xuất PDF thật: 64 trang; .scratch/r3-word-pagination-final.log. Bản cuối sau sửa FOV được PDF inspect đủ64/64 verdict ok, không trang trắng, SHA256 08faa48917aa452406e246efa0afb12636e219cdfd75ce2c49b39b8ae05b0d00. PDF review ở .scratch/r3-word-review.pdf, không phải đầu ra nộp thêm.
- Đã xem trang PDF 11 (ma trận),32 (hướng dẫn) và42 (adapter). Mã Consolas10, văn bản13, hình keep-with-caption. Chưa rà thị giác từng trang/TOC/header theo mẫu nộp; không gọi pagination ok là nghiệm thu hoàn chỉnh.

QA R3 đã terminal: xác nhận sáu nhóm sửa, một P1 còn lại là công thức FOV bị viết mơ hồ atan. Lead thay bằng θₕ = 2 × arctan(a × tan(θᵥ / 2)), tạo lại Word/PDF, kiểm XML đúng chuỗi công thức (.scratch/r3-fov-word-check.log) và xem trang19 PDF cuối (.scratch/r3-fov-final.png). Theo điều kiện QA, đóng phạm vi sửa nội dung/source sau xác nhận này; không nhận QA đã chạy lại test hoặc xem PDF. Báo cáo qa/ch02-r3-final.md.

## Sản phẩm và giới hạn

Hiện hành: thesis/Ban_thao_Chuong_1-3_v0.5.docx và Ch2 Markdown; game/tutorial-r3, game/evidence-r3; research/ch02-r3-sources.md; diagrams/2-*-r3. References37 mục, giữ số Ch1/Ch3. v0.4 Word không sửa; Ch2v0.4 lưu riêng. Thay đổi sẵn của Wordv0.3 giữ ngoài staging bằng --exclude.

Chưa có Android/SceneView runtime, trigger runtime, hoạt ảnh Fox, hai Android/Internet hoặc solver demo. Hai-client test chỉ xác nhận snapshot cập nhật hai đối tượng node headless, không phải hai cảnh đã render. Source host đầy đủ tách ngoài chương; người đọc cần bộ source đi kèm trước A. Đường tải lỗi/cleanup và điều khiển trên thiết bị vẫn cần kiểm chứng.
