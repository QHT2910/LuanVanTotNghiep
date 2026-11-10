# Bố cục sơ bộ theo yêu cầu sinh viên — 2026-11-04

Cập nhật 07/11/2026: thêm 2.4.4 khai báo/thao tác trực tiếp; mở rộng 2.7 về loading/warm-up; thêm 2.11.4 hot reload và 2.11.5 editor; 2.12.13 bài khai báo tùy chọn, 2.12.14 kiểm hot reload có điều kiện. Giữ các mục lớn, A–F và thứ tự hiện hành; không đổi kiến trúc game.

Đây là phiên bản làm việc, có thể sửa khi sinh viên thông báo. Không khẳng định đã được GVHD phê duyệt.

## Chương 1. Giới thiệu
1.1 Đặt vấn đề, mục tiêu luận văn
1.1.1 Đặt vấn đề
1.1.2 Mục tiêu của đề tài
1.2 Những thách thức cần giải quyết
1.3 Nội dung, phạm vi thực hiện
1.4 Kết quả cần đạt và tiêu chí đánh giá

## Chương 2. Cơ sở lý thuyết
2.1. Các hệ thống tương tự
2.2. Nền tảng Flutter Scene và pipeline kết xuất
2.3. Cơ sở toán học của không gian 3D
2.4. Đồ thị cảnh, thành phần và vòng đời
2.5. Hình học, vật liệu và shader
2.6. Camera, ánh sáng và môi trường
2.7. Tài nguyên, mô hình và hoạt ảnh
2.8. Vòng lặp, nhập liệu và giao diện hiển thị
2.9. Chuyển động và mô phỏng vật lý
2.10. Kết nối và đồng bộ trạng thái thời gian thực
2.11. Hiệu năng và giới hạn đánh giá
2.12. Hướng dẫn xây dựng một cảnh mẫu xuyên suốt

Mục 2.1–2.11 dành cho lý thuyết; 2.12 hướng dẫn riêng xuyên suốt theo yêu cầu ngày 05/11/2026.

## Chương 3. Xây dựng game Bóng rổ đối kháng 3D
3.1 Mô tả game
3.1.1 Ý tưởng, người chơi, bối cảnh và mục tiêu
3.1.2 Phạm vi, luật chơi và vòng chơi
3.1.3 Điều khiển, kỹ năng và trạng thái
3.1.4 Kết nối hai người, tình huống biên và giới hạn
3.2 Thiết kế game
3.2.1 Phân tích yêu cầu chức năng/phi chức năng và quy trình nghiệp vụ
3.2.2 Sơ đồ chức năng
3.2.3 Tác nhân và use case tổng quát
3.2.4 Đặc tả use case chi tiết
3.2.5 Kiến trúc hệ thống và thiết kế mạng
3.2.6 Mô hình dữ liệu và sơ đồ lớp
3.2.7 Mô hình xử lý: trạng thái, tuần tự, hoạt động
3.2.8 Thiết kế cảnh 3D và tài nguyên
3.2.9 Truy vết yêu cầu–thiết kế và các quyết định còn mở

Không ép mô hình cơ sở dữ liệu quan hệ nếu demo chỉ giữ trạng thái trong bộ nhớ. Sơ đồ trạng thái có ích cho phòng/trận/bóng; sơ đồ lớp mô tả cấu trúc mã dự kiến, không thay cho sơ đồ dữ liệu.

3.3 Hệ thống màn hình
3.3.1 Danh sách màn hình và luồng chuyển
3.3.2 Thiết kế giao diện
3.3.3 Quy tắc cập nhật và phản hồi

## Chương 4. Kiểm thử — kết quả bước đầu của bản tập offline
4.1 Môi trường và phạm vi kiểm thử
4.2 Kịch bản và phương pháp kiểm tra
4.2.1 Các mức kiểm tra
4.2.2 Nhóm kịch bản
4.2.3 Các ca trọng yếu và tiêu chí đối chiếu
4.3 Kết quả theo từng mốc M1, M2, M3a, M3b
4.4 Giới hạn đánh giá

Chỉ kết quả một AVD đã ghi nhận; chưa đánh giá máy thật, hiệu năng, Internet hoặc toàn bộ game 1v1.

## Chương 5. Kết luận — chờ kết quả
Kết quả theo mục tiêu, hạn chế, hướng phát triển. Không viết kết luận hoàn thành khi chưa có bằng chứng.
