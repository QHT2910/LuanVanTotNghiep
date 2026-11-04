# Rà soát bản thảo v0.2

## Phạm vi chỉnh sửa

- Giữ cấu trúc Ch1, đổi 1.1.2 thành Mục tiêu của đề tài.
- Ch2: bổ sung khảo sát 2.1 có nguồn, dịch các mục cũ sang 2.2–2.10; tách thông tin mô tả nguồn khỏi kết quả thực nghiệm.
- Ch3: tên tạm Bóng rổ đối kháng 3D, cập nhật gameplay được sinh viên đồng ý; khôi phục mục 3.3 Hệ thống màn hình theo PDF trang 1.
- Bỏ lời dẫn bản nháp và đoạn Căn cứ nội bộ khỏi bản luận văn. Giữ lịch sử/rà soát trong docs, không dùng file quản lý nội bộ làm tài liệu tham khảo học thuật.
- Loại hình wireframe tự sinh 3-9 khỏi bản hiện hành. Các tệp cũ chỉ lưu lịch sử, không đủ căn cứ coi giao diện đã được vẽ bằng công cụ bên thứ ba.
- Bỏ định dạng đậm trong nội dung và các nhãn, dùng kiểu chữ thường cho tiêu đề; giữ nguyên tên API, nút ACTION/JUMP/DASH và mã kỹ thuật.

## Tổ chức lập luận và vai trò đoạn

| Phần | Vai trò các đoạn | Nội dung giữ lại |
|---|---|---|
| 1.1 | Bối cảnh, vấn đề, mục tiêu | Nghiên cứu Scene qua demo, không tuyên bố kết quả |
| 1.2–1.4 | Thách thức, phạm vi, đánh giá | Cơ chế cần kiểm chứng, phạm vi người dùng đồng ý, tiêu chí chưa đo |
| 2.1 | Khảo sát, so sánh, giới hạn | Công cụ phát triển và game cùng thể loại, không suy đoán hiệu năng/kiến trúc đóng |
| 2.2–2.10 | Khái niệm, cách dùng, ví dụ, giới hạn | API có nguồn, hướng dẫn chưa thực thi |
| 3.1–3.2 | Đặc tả, thiết kế, ràng buộc | Luật demo và mô hình dự kiến, không khẳng định đã code |
| 3.3 | Danh sách màn hình, thiết kế, cập nhật | Chưa có bộ frame thiết kế từ phần mềm, nêu hành vi cần vẽ |

## Bản đồ khẳng định và bằng chứng

| Khẳng định | Bằng chứng | Trạng thái |
|---|---|---|
| Flutter Scene có các thành phần dùng trong Ch2 | SCENE-01/02, LT01–LT12 trong nguồn | Được tài liệu hỗ trợ; chưa chạy dự án |
| Godot hỗ trợ 2D/3D và xuất Android | HT01–HT02 | Được tài liệu hỗ trợ; không có benchmark so sánh |
| Flame có hướng 3D thử nghiệm | HT03–HT04 | Được tài liệu hỗ trợ; không khẳng định chỉ có 2.5D |
| Basketball Stars là game bóng rổ multiplayer mobile | HT05 từ nhà phát hành | Có nguồn; chưa quan sát chơi hoặc biết kiến trúc bên trong |
| Tên game/gameplay trong bản sửa là phạm vi demo | Người dùng xác nhận trong phiên ngày 04/11/2026 | Đã xác nhận phạm vi, chưa thực hiện |
| Game chạy được hoặc đạt chỉ tiêu trên hai điện thoại | Chưa có bản dựng và thiết bị thứ hai | Cần thực nghiệm, không đưa thành kết quả |
| Giao diện đáp ứng yêu cầu công cụ bên thứ ba | Chưa có file thiết kế và ảnh xuất từ phần mềm | Còn thiếu, đã bỏ hình tự sinh khỏi bản Word mới |

## Tự rà soát theo năm khía cạnh

1. Đóng góp: phạm vi là nghiên cứu cách dùng engine và demo; chưa có cơ sở tuyên bố thuật toán mới hoặc tốt hơn engine khác.
2. Diễn đạt: đã loại ghi chú nội bộ, nhấn đậm và lời dẫn không phục vụ người đọc. Thuật ngữ/mã kỹ thuật được giữ để truy vết.
3. Thực nghiệm: chưa có; không đổi mục tiêu thành kết quả. Hướng dẫn Ch2 vẫn phải compile/chạy sau.
4. Độ đầy đủ đánh giá: Ch4–5 chờ sản phẩm; hiện chỉ một Redmi Note11. Không thay kiểm thử hai Android bằng client máy tính.
5. Thiết kế: quyền quyết định điểm ở máy chủ; vật lý/mạng/tham số còn cần kiểm chứng. Cần bổ sung bộ giao diện, use case UML chuẩn và đặc tả chi tiết các use case còn thiếu trước bản nộp.

## Mục 3.3 còn thiếu gì

- Chọn phần mềm vẽ và lưu nguồn có thể chỉnh sửa.
- Thống nhất frame ngang, vùng an toàn, bộ màu, font và nút.
- Vẽ Menu, Tạo/vào phòng, Sảnh, Trận đấu, Kết quả, Cài đặt và các trạng thái lỗi/chờ/hồi chiêu.
- Nối luồng màn hình và xuất hình; ghi phiên bản nguồn và mô tả thành phần để đưa vào luận văn.
- Kiểm tra vùng chạm sau khi có giao diện chạy được. Chưa cần kết quả kiểm thử để bắt đầu thiết kế.
