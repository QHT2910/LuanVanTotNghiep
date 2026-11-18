# Bản rà soát v0.11 — 18/11/2026

Bản gửi đọc lại: [Word](Ban_thao_Chuong_1-4_v0.11_final.docx) · [PDF](Ban_thao_Chuong_1-4_v0.11_final.pdf).

Xuất trực tiếp bằng Microsoft Word: **117 → 111 trang**, giảm 6 trang. Không dùng số 107 trang của PDF cũ để so sánh vì PDF đó được tạo trước lần sửa tay trong Word.

## Những gì đã chỉnh

| Phần | Thay đổi |
|---|---|
| Mã hướng dẫn Ch2 | Bỏ 66 đoạn trắng giữa các dòng mã; chia nhỏ 95 điểm keepNext để tránh giữ cả khối dài sang trang sau. Giữ nguyên mọi dòng mã không rỗng, Before6pt và Multiple1,3. |
| Hình2.1,2.3,2.7 | Bố trí lại nguồn vector, nhãn lớn hơn; giữ nguyên các nút, nhãn và chiều mũi tên. Không kéo méo PNG. |
| Hình2.5 | Chuyển chuỗi vòng đời cao/hẹp thành hai hàng theo hai nhóm gắn/nạp và tham gia/rời cảnh, giữ kết nối và mũi tên đứt. |
| Hình3.7(b2) | Bố trí lại nhánh Block, giữ V/F/G và hai nhánh Có/Không; hình thấp hơn nhưng chữ lớn hơn. Ghép được cùng trang với panel trước. |
| Hình3.8 | Đưa hai đoạn diễn giải sau caption, để hình xuất hiện sớm hơn và giảm trang gần trống trước hình. |
| Caption | Căn giữa tám caption sơ đồ còn lệch, bỏ hậu tố nguồn dài của hình tự xây dựng; không gán nguồn số giả. |
| Tham khảo | Giữ từng entry trên một trang khi có thể, tránh tách URL/ngày truy cập khỏi phần đầu entry. |
| Nội dung | Sửa câu phủ định kết quả AVD; gắn trạng thái tutorial với lượt kiểm lịch sử; làm rõ Internet là mục tiêu; gộp/cắt các đoạn lặp về resolved/Block, bảng trạng thái, lifecycle, danh tính phiên và nhánh Tập luyện. |

## Trang nên xem trước

| Đối tượng | Trang v0.10 native Word | Trang v0.11 |
|---|---:|---:|
| Hình2.1 — pipeline | 9 | 10 |
| Hình2.3 — Local/World/View/Clip | 13 | 13 |
| Hình2.5 — vòng đời | 15 | 15 |
| Hình2.7 — nội suy | 27 | 27 |
| Hình3.7(b2) — Block | 93 | 88 |
| Dẫn luồng màn hình/Hình3.8 | 99–100 | 93–94 |
| Bộ UI Figma | 101–106 | 95–100 |

Chương 1/2/3/4 lần lượt bắt đầu tại trang **1/6/67/101**. Ngắt trước mỗi chương vẫn đúng một lần; các khoảng trắng cuối chương được giữ. Không thu chữ để ép giảm trang.

## Nội dung còn cần tác giả quyết định

1. Hai tiêu đề con trong mục2.12.13 (“So sánh với bài A và quyền sở hữu”, “Loading và warm-up”) có nên chuyển thành cấp4 hoặc nhãn đoạn? Bản này giữ cấp hiện tại để tránh tự đổi cấu trúc/mục lục.
2. Khối hướng dẫn và mã Ch2 còn dài. Có thể chuyển code đầy đủ sang phụ lục, nhưng đó là thay đổi cấu trúc lớn nên chưa thực hiện.
3. Ch4 giữ kết quả lịch sử M1–M3b và thêm câu giới hạn phạm vi. Các kết quả human/network mới chưa được tổng hợp trong chương; không đưa số test mới vào bảng cũ hoặc viết game/Internet đã hoàn chỉnh.
4. Một số panel lớp/sequence/activity vẫn chiếm trang riêng để giữ nhãn đọc được. Muốn gọn hơn cần tái bố trí nguồn từng panel, không thu nhỏ đồng loạt. Vùng cuối chương và đuôi tài liệu tham khảo không phải trang trắng lỗi.

## Bảo toàn và cách kiểm

- Bắt đầu từ DOCX v0.10 thực tế đã sửa tay, SHA256 a3bfb35b02d69e7c941841afe9bfd793e14978946e1d0e361ef2039624e617c1. Bản gốc và backup timestamp/hash được giữ, không ghi đè.
- Còn đủ **38 hình,27 bảng,24 OMML,44 tài liệu tham khảo**. Nội dung OMML và 44 entry tham khảo không đổi; 33 media giữ byte, 5 sơ đồ có nguồn SVG/PNG mới. Toàn bộ **11 ảnh Figma** giữ nguyên byte, tỷ lệ và nguồn người dùng.
- Chỉ document.xml và 5 media sơ đồ thay đổi trong gói DOCX; các phần khác giữ nguyên. Font nội dung kế thừa Times New Roman từ style Normal, cỡ13; không đổi After chưa được quy định.
- Microsoft Word bản cài trên máy thực hiện phân trang và xuất PDF. Sau đó PDF.js render toàn bộ111trang thành28contact sheets, đồng thời kiểm không có text ngoài khổ giấy. Rà pixel/caption/nhãn là bước riêng, không coi kiểm cấu trúc là thay quan sát.
- Baseline117trang đã được Orca Worker diagram-designer xem toàn bộ; nội dung được Orca Worker thesis-writer rà có mục tiêu. Orca Worker QA độc lập đã xem đủ111trang/28contact sheets và8trang zoom, tự so hash/ZIP/XML, kết luận PASS trong phạm vi này, không có P1/P2 chặn bàn giao. Lead đã rà trang/hình thay đổi thực tế. Cindy review được yêu cầu riêng; chưa tự ghi nhận acceptance thay Cindy.

Giới hạn: chưa kiểm bản in giấy hoặc mọi phiên bản Word/máy in; chưa thẩm định lại từng công thức và từng nguồn từ đầu. Công thức/nguồn được bảo toàn nguyên bản, không nhận việc bảo toàn là xác minh nội dung học thuật toàn bộ.
