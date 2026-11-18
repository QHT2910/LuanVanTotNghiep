# Rà layout baseline v0.10

Orca Worker diagram-designer ub7cjeu5ajbo6e9kxn475jsn, 18/11/2026, READONLY. Đã xem đủ 30 contact sheets/117 trang native Word; zoom trang 9/15/27/83/93/94/99/100. Không dùng PDF cũ 107 trang, không chạy Word hoặc sửa tài liệu.

## Findings chính

| Trang baseline | Nguyên nhân / đề nghị |
|---|---|
| 99–100 | Hình3.8 cao520pt + caption không lọt phần trang99 sau ba đoạn. Không phải pagebreak cưỡng bức. Đưa diễn giải p1534–35 sau caption để hình xuất hiện sớm, giữ kích thước và mạch dẫn. |
| 9/13 | Hình2.1/2.3 rộng431pt nhưng chỉ cao29.69/31.34pt, nhãn quá nhỏ. Cần tái bố trí nguồn, không kéo méo hoặc tăng DPI đơn thuần. |
| 27 | Hình2.7 rộng431 cao83.56pt, nhãn nhỏ; nên tái bố trí nhãn lớn hơn. |
| 82–84 | Class panels còn trắng nhưng chữ đã nhỏ; không thu đồng loạt để ghép trang. |
| 86–90 | Sequence panels cao265–560pt; giữ nhãn/connector, không ép hai panel lớn vào một trang. |
| 91–94 | Activity panels cao398–520pt; khoảng trắng do hình nguyên khối. Compact nguồn có thể giúp; thu PNG sẽ làm chữ nhỏ. |
| 38–67 | Các dòng mã riêng có Before6/Multiple1.3 và chain keepNext dài tới13 đoạn. Bẻ chain ở ranh giới hợp lý, không bỏ keepNext heading/hình. |
| 116–117 | Ref41 bị chia đoạn qua trang; dùng keepLines từng entry, không keepNext nối 44 nguồn. |
| 101–106 | 11 ảnh UI đúng tỷ lệ/kích thước có thể giữ, không redraw hoặc đồng nhất chiều cao. |

Không có trang trắng hoàn toàn hoặc caption hình orphan quan sát được. Khoảng cuối Ch1 trang5, Ch2 trang70, Ch3 trang106, Ch4 trang113 hợp lệ do chương kế tiếp phải sang trang mới. Không xóa ngắt chương để lấp chỗ trống. Table split có lặp header không tự là lỗi; UC01 trang76–77 có ít dòng đầu nên cần kiểm lại bản cuối.

Gate: view_image30sheet+8zoom | PASS117/117 coverage | logpath=none. Get-Content/node inventory | PASS | logpath=none. New DOCX/export/pagination | NOT RUN bởi worker. Các kích thước compact chỉ là gợi ý, chưa được render xác nhận.
