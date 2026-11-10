# Bản soạn Ch4 chờ bố cục

Không phải source chương đã nghiệm thu; chưa xuất Word/PDF.

Các lần kiểm tra M1–M3a được thực hiện trên một AVD Pixel_9a, Android API 37, kiến trúc x86_64, với backend Impeller OpenGLES theo hồ sơ chạy. Đây là giả lập, không phải điện thoại Pixel vật lý hoặc Redmi Note 11. Các kết quả dưới đây giới hạn ở bản tập offline và các ca đã ghi nhận.

| Mốc | Bằng chứng và kết quả được ghi nhận | Giới hạn |
|---|---|---|
| M1 | 13 test đạt; luồng offline có sáu lần thả, ba cú ghi điểm với tổng cuối 7; có reset giữa bay và hai chu kỳ background/resume | Probe Scene/Fox được kiểm riêng, không chứng minh Fox đã tích hợp vào app offline |
| M2 | 22 test đạt; hai pointer phối hợp joystick và ném; hai cú ghi điểm 3+3, tổng 6; cancel toàn bộ và ném lại sau resume | Hủy riêng từng pointer và một số race được kiểm ở mức widget, chưa bao phủ toàn bộ trên AVD |
| M3a | 34 test đạt; oracle ghi sáu lần bắt đầu nhảy, năm lần tiếp đất và một lần reset hủy nhảy; hai cú ném trên không ghi 3+2, tổng 5; kiểm no-double-jump và giữ độ cao qua pause/resume đạt | Joystick+jump và jump+shoot là hai ca hai pointer riêng, không phải ba ngón đồng thời |

Số test là tổng của từng bản theo mốc, không cộng dồn giữa ba hàng. Kết quả kiểm tra logic, widget và runtime hỗ trợ các kết luận khác nhau; một ca widget không thay bằng chứng tích hợp Scene. Chưa có đánh giá hiệu năng máy thật, thử hai Android qua Internet hoặc nghiệm thu toàn bộ game 1v1. UI dùng khi thử là giao diện tạm, chưa phải bộ thiết kế Figma chính thức.