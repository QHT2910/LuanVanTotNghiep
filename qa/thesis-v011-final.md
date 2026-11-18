# QA final luận văn v0.11 — 18/11/2026

Kênh: **Orca Worker tester bkm37d3uiwhgp757im7y9hov**, chỉ đọc. Lead nhận terminal và rà lại kết luận. Verdict: **PASS theo phạm vi bảo toàn, sửa nội dung có mục tiêu và layout PDF native đã xuất; không có P1/P2 chặn bàn giao**. Không nhận ready-to-submit hoặc thẩm định học thuật toàn bộ.

## Kiểm độc lập mới

- Actual v0.10 SHA256 a3bfb35b02d69e7c941841afe9bfd793e14978946e1d0e361ef2039624e617c1.
- Final DOCX 4858227bytes SHA256 d7884362ed1775d87a3e1e205c41bc754f2830318b3ca868cb72c0c55e3a3e76.
- Final PDF 2842568bytes SHA256 7878b05833fdced7b3a6a7b8de357f0fda30c426f45678cbd02a4a608ef6704d.
- So tất cả file part ZIP trong RAM: chỉ document.xml và image1/3/5/7/24.png thay đổi. Hai directory entries word/ và word/media/ bổ sung không phải nội dung part mới.
- 38 drawing,27 bảng;24 OMML serialized XML và44 reference text giống nguyên bản.33 media giữ byte, trong đó toàn bộ11 Figma image28–38.
- Ghép tuần tự các paragraph vùng mã baseline p491–1252: không mất/thay dòng không rỗng ngoài prose922/1012 được giao;95 keepNext thay đổi và66 paragraph trắng được bỏ.
- Bốn chương mỗi chương đúng một pageBreakBefore, không inline pagebreak kép. Normal kế thừa TNR; không coi thiếu ascii ở run là font sai. Năm tỷ lệ extent/PNG khớp, residual dưới8e-7 do EMU rounding.

## Quan sát thật

QA xem **28/28 contact sheets,111/111 trang** của final2-render, zoom **10/13/15/27/88/93/94/111**. Không thấy trang trắng hoàn toàn, cắt nhãn, text tràn khổ, caption hình đứng một mình, méo hình hoặc bảng chồng chữ. Chương bắt đầu1/6/67/101. Khoảng cuối chương5/66/100/107 và đuôi refs111 hợp lệ.

Năm hình đối chiếu .mmd gốc, shapes trong script và PDF: Hình2.1 giữ Dart→Scene→FlutterGPU→Impeller→GPU;2.3 giữ Local–M→World–V→View–P→Clip;2.5 giữ hai nhóm vòng đời và loaded-khi-mounted/nét đứt onDetach;2.7 giữ hai state, alpha, Nội suy, Render và cạnh h;3.7(b2) giữ V/F/G và nhánh Có/Không/ball-free/end. Không phát hiện thay graph/label/API semantics.

Trang93 bảng màn hình/lời dẫn bớt trống;94 hình3.8/caption/hai đoạn diễn giải cùng trang.95–100 giữ đủ11 Figma.111 ref41 giữ toàn entry/URL/ngày cùng trang, sau đó42–44. Một số class/sequence/activity còn chiếm trang riêng; không đề nghị thu chữ đồng loạt để lấp trắng.

Đối chiếu nội dung có mục tiêu: p22 giữ bằng chứng AVD lịch sử; tutorial gắn lượt bundle; Internet là mục tiêu; p216 giữ ownership/dispose giới hạn; ACK processed không thành accepted; resolved/Block/connector/practice được rút lặp nhưng giữ guard. Ch4 trang101 có cutoff M1–M3b;103–107 không nâng logic/widget thành runtime hoặc hai pointer thành ba, không đưa kết quả game/network mới vào bảng cũ.

## Gates và giới hạn

QA chỉ hash/read/so RAM/view_image; native Word117→111, export, renderer và verify/check-chapter là **Lead thực thi, QA đọc kế thừa**. Không chạy lại các script ghi output. Baseline117allpages thuộc Orca Worker diagrams, không nhận QA xem lại117trang.

| Lệnh/quan sát QA | Kết quả | Log |
|---|---|---|
| node stdin crypto3artifact | PASS3hash/bytes | none |
| node stdin ZIP/XML/tutorial sequential | PASS bảo toàn | none |
| node stdin keepNext/chapter/PNG ratios | PASS95/4/5 | none |
| view_image28sheet+8zoom | PASS111pages | none |
| Get-Content rules/reviews/scripts/final2logs | PASS đọc theo phạm vi | none |
| Get-Content qa/layout-baseline.md | FAIL PathNotFound; đã tìm/đọc đúng qa/thesis-v011-layout-baseline.md | none |

Phép dò keepNext theo đoạn trùng đầu tiên cho81 đã bị loại, ghép tuần tự cho95. Regex chapter thử đầu không match Unicode đã được sửa để xác nhận4chương; không dùng kết quả rỗng làm lỗi tài liệu. Lead ghi riêng false-fail checker cũ về font inheritance/PDF footer-first; không coi đó là failure mới của artifact.

Chưa kiểm bản in/máy in/Word phiên bản khác; chưa thẩm định lại từng công thức hoặc44nguồn, chưa chạy tutorial/game. Hai nhãn con2.12.13 và việc chuyển code sang phụ lục vẫn để tác giả quyết định. Không nhận game/network đã hoàn chỉnh. Worker không ghi tệp/Git/GUI/build/dispatch, không mở task tiếp. Lead lưu báo cáo này từ terminal để bàn giao Cindy.
