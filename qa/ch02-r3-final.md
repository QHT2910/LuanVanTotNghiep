# QA R3 v0.5 — 05/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov, Sol6.1, rà chỉ đọc. Kết luận trước sửa cuối: sáu điểm R3 có căn cứ, chỉ một P1 cần sửa công thức FOV; không có P2 chặn khóa.

Đã xác nhận A–F tăng dần, A31dòng/maxblock77; sáu source trong chương khớp project. Adapter và test2WS/2Node kiểm lịch sử accepted/position/tick và packet sai; không đồng nhất smoke với node hoặc headless vớiSceneView. Ví dụ TR/RT, skinning, roughness/light có tiền đề; Fox clip/commit/license/scale khớp hồ sơ. Caption2.1–2.8 đúng thứ tự, sRGB ở texture, khảo sátpublisher không nhận chơi/video. WordXML có16ảnh; 37refs; quétencoding sạch. QA không chạy chương trình hoặc xem PDFpages/PNG.

P1: θₕ=2arctan(atan(θᵥ/2)) mơ hồ/sai dấu nhân. Câu sửa yêu cầu: h=2×d×tan(θᵥ/2); w=a×h; θₕ=2×arctan(a×tan(θᵥ/2)). Lead đã sửa nguồn, tạo lại Word/PDF và xác minh chuỗi trong XML; đã xem trang19 PDF công thức rõ. Evidence .scratch/r3-fov-word-check.log và r3-fov-final.png. QA cho phép khóa phạm vi nội dung/source sau sửa và xác nhận bản xuất này; không có lượt QA chạy lại được tuyên bố.

Gates của QA: Get-Content/regex comparison PASS source/checkpoints/encoding, ZipFile/XML PASS16ảnh/caption và phát hiện FOV; logpath=none theo ranh giới chỉ đọc, transcript worker giữ bằng chứng gốc. Gates của Lead: source analyze/test/bundle và Word/PDF theo docs/R3_REVIEW.md. Lần test đầu Float32tolerance được sửa dựaactual, không bỏ guard.

Chưa nghiệm thu Android/trigger/Fox runtime, Internet, haiAndroid, rà thị giác toàn bộ Word hoặc GVHD chấp nhận.
