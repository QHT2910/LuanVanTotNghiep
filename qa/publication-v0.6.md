# QA bản xuất v0.6

Orca Worker tester `bkm37d3uiwhgp757im7y9hov`, Sol 6.1. Báo cáo chỉ đọc ngày 06/11/2026, Lead lưu lại. Đạt phạm vi source, Word XML và 15 PNG panel; không phát hiện P1/P2 cần sửa. Chưa nghiệm thu PDF cuối hoặc pagination.

Đã đối chiếu 3.1(a,b), 3.4(a,b,c), 3.6(a,b1,b2,c1,c2), 3.7(a,b1,b2,c1,c2). Giữ đủ chức năng, sáu lớp và thuộc tính, bội số/aggregation/composition, guard resolved, nhánh hết giờ/Block/qua rổ/event cũ/trượt/còn bay, connector và vòng quay lại. Q3 vẫn chạy cuối tick kết thúc; ack riêng từng client; Z không luôn là kết thúc trận. Nhãn rút gọn được giải thích trong văn bản.

Đã xem đủ 15 PNG hiện hành và đọc bộ dựng năm SVG sequence. Nhãn không thấy bị cắt; đầu mũi tên self-message/input/snapshot đúng hướng. Hai snapshot từ server về A/B. Đây là quan sát ảnh riêng, chưa xác nhận kích thước in trong PDF.

Word được kiểm có 37 refs liên tục, 27 ảnh, ba display OMML. UML 3.2 và năm ảnh sequence khớp PNG. Không thấy comment/marker/placeholder hoặc mẫu encoding lỗi trong phạm vi quét. Caption 3.x và FOV có × đúng. PBR và skinning có cấu trúc toán; flutter_scene không bị chuyển vào OMML. Đã đọc publication-checks, word-math, refresh-publication-images và render-sequence-panels; không thấy thay đổi logic hình trong phạm vi đối chiếu.

Gates do worker thực hiện:

```text
Get-Content/Select-String source và panel | PASS bảo toàn thuộc tính/bội số/branch/loop/guard/connector | logpath=none
view_image 15 PNG | PASS nhãn và hướng mũi tên ở ảnh riêng | logpath=none
ZipFile.OpenRead + XML/hash | PASS 37 refs,27 ảnh,3 OMML,UML và5 sequence PNG khớp | logpath=none
XML marker/comment/encoding/API-in-math scan | PASS trong mẫu kiểm | logpath=none
```

Không ghi tệp, render lại hoặc chạy chương trình. Sau báo cáo này Lead dựng lại cùng nguồn và cùng PNG vì Word export bản đã refresh bị treo; phải chạy lại validator và rà PDF cuối. Báo cáo không thay gate đó.
