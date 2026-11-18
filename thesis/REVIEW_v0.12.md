# Bản v0.12 để tác giả rà soát

Biên tập trực tiếp từ bản v0.11_corrected do tác giả sửa tay ngày 18/11/2026, không dựng lại từ Markdown. Bản gốc và bản sao lưu được giữ nguyên.

- Chuyển sang văn phong báo cáo cuối cùng; bỏ lời hẹn và các câu nhắc chưa thử trên điện thoại thật. Chương 4 vẫn ghi đúng môi trường AVD và các kết quả đã có.
- Gom cấu hình, kịch bản và kết quả kiểm tra bộ bài Scene vào Chương 4; bổ sung mục 4.3.6. Các tổng 13/22/34/47 của ứng dụng giữ riêng với kết quả tutorial.
- Chuẩn hóa 27 sơ đồ theo phông Times New Roman, nét đen và nền trắng/xám; ba panel lớp bố trí ngang, giữ tên lớp, thuộc tính, bội số và loại liên kết. Giữ sơ đồ vòng đời đã đối chiếu Scene 0.24.3.
- 38 chú thích hình dùng nhãn in đậm, nghiêng, gạch dưới; dấu hai chấm và tên hình normal. Chú thích bảng giữ normal.
- Rút gọn đoạn giới hạn phạm vi Chương 1 để chú thích bảng không đứng riêng ở một trang gần trống. Bảng kết quả mới ở Chương 4 lặp hàng tiêu đề khi sang trang.

Bảo toàn: 38 hình, 27 bảng, 24 công thức OMML, 44 mục tài liệu tham khảo; 11 ảnh Figma giữ nguyên từng byte. Các phần XML khác ngoài nội dung chính và 27 ảnh sơ đồ không thay đổi. Cỡ chữ nội dung TNR13, Before6pt, Multiple1.3; giữ After có sẵn.

Phân trang được kiểm bằng PDF xuất từ Microsoft Word, không dùng HTML để suy ra số trang. Baseline sửa tay có 109 trang; ứng viên sau biên tập có 108 trang. Một số sơ đồ tuần tự vẫn chiếm trang riêng để giữ khả năng đọc.

Tác giả cần xem lại:

- Hai nhãn con trong mục 2.12.13 và phương án đưa mã đầy đủ sang phụ lục là quyết định cấu trúc, chưa thay đổi trong lượt này.
- Bản final đã thêm ngắt dòng Word thực giữa chú thích và câu lệnh `_material.baseColorFactor = _tint();`, giữ nguyên mọi token. Chưa biên dịch lại listing chỉnh trong Word.
- Kết quả Chương 4 thuộc ứng dụng tập offline và bộ bài thực hành được nêu; không nhận hệ thống đối kháng, Internet hoặc toàn bộ UI thiết kế đã triển khai.

Ghi chú biên tập cho lượt sau: trang 59 lặp nhãn “Mã ví dụ (tiếp)” trong cùng một trang, làm ngắt mạch đọc mã. Có thể gom nhãn khi tác giả rà cấu trúc khối mã; không cần thay bản xuất chỉ vì điểm này.

Trạng thái: Lead đã xem toàn bộ 108 trang qua bản render và các trang sửa cuối; Cindy đã đóng lỗi ngắt dòng mã và chấp nhận phạm vi bố cục đã xem. Orca Worker QA đã kiểm bảo toàn, caption, phạm vi kết quả và đóng lỗi mã ở bản final. Các lượt này không phải thẩm định học thuật toàn bộ. Tệp bàn giao là Ban_thao_Chuong_1-4_v0.12_final.docx và PDF cùng tên. Đây là bản để tác giả review, không phải kết luận sẵn sàng nộp.
