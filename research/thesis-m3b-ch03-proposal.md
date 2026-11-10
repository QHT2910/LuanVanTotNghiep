# Patch đề xuất Ch3 sau M3b

Nguồn: terminal report Orca Worker thesis i5ekkscj1rnt90hdtb8zk3n2. Chưa tích hợp vào manuscript. Các anchor bên dưới là chỉ dẫn tích hợp, không đưa vào luận văn.

## A1 — thay đoạn mở đầu chương

Chương này phân biệt thiết kế mục tiêu của game 1v1 với ứng dụng tập offline đã hiện thực đến M3b. Bản tập hiện có di chuyển bằng joystick, giữ–thả ném, nhảy và Dash với nhân vật hình khối. Phòng đấu, máy chủ, Block, đồng bộ hai người và vòng trận 11 điểm/3 phút vẫn thuộc thiết kế đề xuất; kết quả kiểm tra bản offline không xác nhận các chức năng đó đã hoạt động.

## A2 — thay đoạn Thiết kế 1v1 từng đề xuất trong3.1.3

Thiết kế 1v1 từng đề xuất để máy chủ chọn quỹ đạo bằng xác suất có seed và phân xử tương tác phòng thủ. Bản tập offline M3b chưa triển khai phương án đó. Nó dùng quỹ đạo giải tích với sai lệch mục tiêu theo mức giữ nút. Khi thả, điểm xuất phát được lấy từ mẫu vị trí bóng đã đồng bộ để hiển thị; vận tốc được giải lại theo độ cao này, không cộng thêm vận tốc đứng của nhân vật. Vị trí chân chiếu xuống mặt sân quyết định giá trị 2 hoặc 3 điểm và được lưu cùng cú ném, nên di chuyển hoặc thay đổi độ cao sau khi thả không làm đổi giá trị đã xác định.

## A3 — chèn trước3.1.4

Dash đã được hiện thực trong bản tập M3b. Khi nhận hành động hợp lệ trên mặt sân, hệ mô phỏng chốt hướng từ joystick hoặc hướng nhìn hiện có; trong thời gian Dash, hướng này không bị đổi và vận tốc đi bộ không được cộng thêm. Cấu hình thử nghiệm dùng tốc độ 8 đơn vị cảnh/giây, thời lượng 0,2 giây và khoảng hồi 0,8 giây sau thời điểm kết thúc dự kiến. Đây là tham số của bản tập, chưa phải cấu hình cân bằng cho game 1v1.

Dash hủy thao tác canh ném đang giữ; khi đang Dash, yêu cầu nhảy và ném bị từ chối. Nút giữ không tự xếp hàng Dash tiếp theo. Reset hoặc xuống nền có thể kết thúc Dash sớm nhưng không rút ngắn mốc sẵn sàng đã xác lập; pause làm dừng thời gian mô phỏng và hồi chiêu. Những quy tắc này thuộc hiện thực offline, còn tương tác Dash với đối thủ và Block chưa được triển khai.

## A4 — chèn đầu3.2.5, trước Phương án đề xuất gồm ứng dụng Flutter

Ứng dụng offline hiện hành tách ba trách nhiệm: nhập liệu, mô phỏng và trình bày. Cách tổ chức này đã có trong source, trong khi phần máy chủ và kết nối trình bày phía sau vẫn là phương án cho game 1v1.

| Lớp hiện thực | Trách nhiệm |
|---|---|
| Nhập liệu | Nhận pointer, quản lý ngón sở hữu joystick/nút, chuyển thao tác thành yêu cầu di chuyển, nhảy, Dash hoặc giữ–thả ném |
| Mô phỏng | Giữ trạng thái và cấu hình, tiến bước thời gian, kiểm điều kiện hành động, tính quỹ đạo và ghi điểm; không phụ thuộc widget hoặc node Scene |
| Trình bày | Kết nối vòng cập nhật với mô phỏng, đồng bộ trạng thái sang node Scene và HUD, xử lý vòng đời và đưa đầu vào về trung tính khi cần |

Mỗi lần cập nhật hợp lệ, lớp trình bày cho mô phỏng tiến trước rồi đồng bộ cảnh và HUD. Khi mất trạng thái tương tác, đầu vào được hủy và logic pause được áp dụng; ticker không được dùng như nơi lưu luật game. Việc tách lớp hỗ trợ kiểm tra logic độc lập nhưng chưa chứng minh cùng một mô phỏng đã được dùng trên máy chủ hoặc đồng bộ qua mạng.

## A5 — thay đoạn đầu3.3.2 Các màn hình sẽ được thiết kế

Figma đã được chọn làm công cụ thiết kế UI01–UI06. Concept UI04 V3 đã được duyệt theo hướng nền sân và HUD tách lớp, chưa có nhân vật trong phạm vi thiết kế này. Việc duyệt concept chưa đồng nghĩa hoàn tất bộ màn hình hoặc có ảnh xuất Figma chính thức. Bản thảo hiện chưa có bộ hình xuất được xác minh để dùng thay thiết kế giao diện; UI của bản tập offline chỉ phục vụ kiểm tra thao tác.

## A6 — chèn trước Các trạng thái logic dự kiến của nhân vật và bóng trong3.2.7

Bảng trạng thái sau mô tả phạm vi đầy đủ của thiết kế. Các hành vi nhảy và Dash đã có biến thể offline, nhưng điều kiện máy chủ, tương tác với đối thủ và Block trong bảng chưa được nghiệm thu trên một trận 1v1.
