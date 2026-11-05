# Minh họa nguyên lý R3

Orca Worker diagrams ub7cjeu5ajbo6e9kxn475jsn, Sol 6.1, chỉ đọc; Lead lưu/render hai Mermaid và bảng FOV. Không phải ảnh render Scene.

- Transform: p=(1,0,0), Rz(+90°) và T(2,0,0); vector cột, quy tắc tay phải. TRp=(2,1,0); RTp=(0,3,0). Nguồn nền tảng [28]; bộ số tác giả tính.
- Skinning: mesh world identity; joint0 identity; joint1 bind translation(1,0,0), current T(1,0,0)Rz90. Đỉnh p=(2,0,0), weight0=0,25, weight1=0,75, kết quả world=(1,25;0,75;0). Giữ B_j là inverse bind như Ch2, khác ký hiệu bind matrix B rồi B^-1 trong bàn giao worker; không đảo thêm lần nữa. Nguồn [33].
- FOV: giữ vertical60°, d=3m, H=3,464m, W16:9=6,158m, W4:3=4,619m. Bảng dễ đọc hơn flowchart, không thêm hình trang trí.

Worker đã kiểm số bằng node-e, không lưu log do chỉ đọc. Lead render mmdc PASS, .scratch/r3-diagram-render.log; còn cần xem PNG và kích thước in khi tích hợp Word. Không chạy lại R2.
