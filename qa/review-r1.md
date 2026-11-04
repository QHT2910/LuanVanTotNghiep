# Rà soát QA lượt R1

Ngày 04/11/2026. Đã đọc Chương 1–3, nguồn Mermaid 3-1 đến 3-8, `PROJECT_BRIEF.md`, `thesis/OUTLINE.md` và `research/ch02-sources.md`. Đây là rà soát tài liệu; chưa chạy game, ca thử hoặc phép đo. Không chạy lại công cụ môi trường của developer.

## Vấn đề cần xử lý

Severity phản ánh rủi ro thiếu hoặc mâu thuẫn đặc tả, không phải lỗi phần mềm đã tái hiện.

| Mã | Severity | Vấn đề và vị trí | Đề xuất sửa |
|---|---|---|---|
| Q01 | Cao | 3.1.4 chưa chốt xử kết quả khi mất kết nối. Sơ đồ 3-5 có timeout nhưng thiếu rời chủ động khi đang chơi. | Bổ sung bảng xử lý rời phòng, ngắt một/cả hai máy, xuống nền; xác định trạng thái đích, kết quả và thời điểm dọn phiên. Không mặc định reconnect hoặc xử thua đã được duyệt. |
| Q02 | Cao | UC04 bỏ input cũ/trùng/sai; 3.2.5 và sơ đồ 3-6 dùng `ackSeq` nhưng chưa định nghĩa mốc xác nhận. | Định nghĩa `ackSeq`, cách xử lý input bị từ chối, lỗ thứ tự và phạm vi phiên/trận. Phân biệt thao tác một lần với hướng di chuyển liên tục. |
| Q03 | Cao | 3.1.2 đề xuất hết giờ trước tính điểm; sơ đồ 3-7 ưu tiên Block trước qua rổ; chưa rõ các sự kiện cùng tick. | Chốt thứ tự xử lý và oracle tick biên. Ghi rõ đây là luật đề xuất trước khi được xác nhận. |
| Q04 | Trung bình | UC04 hậu điều kiện thiếu pha check-ball; sơ đồ 3-6 chưa thể hiện chuyển bóng sau điểm chưa kết thúc trận, trong khi 3-7 có. | Đồng bộ use case và sơ đồ: người nhận bóng, vị trí, thời điểm mở lại input; không check-ball sau cú ghi điểm đã kết thúc trận. |
| Q05 | Trung bình | Luật xác định 2/3 điểm tại lúc thả bóng nhưng thiếu đặc tả hình học vạch/vùng rổ và trường hợp bóng vượt vùng giữa hai bước. | Server lưu vị trí thả và `pointValue`; định nghĩa kiểm tra qua rổ từ trên xuống trên đoạn chuyển động. Không tự đặt sai số hoặc tham số vật lý. |
| Q06 | Trung bình | Có `eventId` nhưng chưa rõ event nằm trong snapshot hay gửi riêng, vòng đời lưu và xử lý snapshot cũ. | Snapshot là nguồn điểm/kết quả; event chỉ kích hoạt hiệu ứng. Bổ sung `matchId`, tick, quy tắc bỏ trạng thái cũ và chống lặp event. |
| Q07 | Trung bình | Bảng dữ liệu có score/result và vị trí/thời điểm ném; sơ đồ lớp 3-4 chưa thể hiện. | Bổ sung trường cần thiết hoặc ghi rõ sơ đồ rút gọn, bảng là đặc tả đầy đủ. Không coi hình lớp là API đã triển khai. |

### Làm rõ `ackSeq` — đề xuất chưa chốt

Đề xuất dùng `ackSeq` làm mốc input đã được server xử lý dứt điểm, bao gồm chấp nhận hoặc từ chối; không phải bằng chứng hành động đã thành công. Client chỉ loại input chờ xác nhận theo quy tắc này và đối chiếu lại trạng thái server.

Nếu input bị bỏ qua hoặc thiếu số thứ tự, đặc tả phải quy định server chờ, bỏ hay xác nhận vượt qua như thế nào. Không tăng mốc xác nhận liên tục vượt một input chưa được giải quyết. `seq` cần gắn với phiên/trận để dữ liệu cũ không tác động trận mới.

### Ưu tiên cùng tick — đề xuất chưa chốt

Một phương án phù hợp hướng hiện tại là:

1. Nếu trận đã kết thúc hoặc đồng hồ hết hạn tại đầu tick, không xử lý điểm mới.
2. Nếu còn thời gian, xử lý chuyển động và tương tác; ưu tiên thời điểm va chạm khi xác định được.
3. Nếu Block và qua rổ không phân biệt được thứ tự trong cùng bước, cần một luật phân xử rõ. Ưu tiên Block là một phương án arcade, chưa phải quyết định được duyệt.
4. Sau ghi điểm, kiểm tra điều kiện ít nhất 11 điểm trước khi chuyển pha check-ball.

## Tám nhóm ca thử dự kiến

Tất cả có trạng thái Chưa chạy. Kết quả mong đợi phụ thuộc luật còn mở chỉ được dùng để nghiệm thu sau khi xác nhận.

| Mã / truy vết | Dữ liệu và thao tác | Kết quả mong đợi dự kiến | Trạng thái |
|---|---|---|---|
| QA01 / F04 | Ném trong, ngoài và đúng vạch; đổi vị trí sau thả. Cho bóng qua rổ từ trên xuống, đi ngược lên, chạm vành và vượt vùng giữa hai bước. | Theo bản thảo: 2/3/2 điểm theo vị trí thả do server lưu. Chỉ qua rổ hợp lệ mới cộng một lần; không dùng vị trí hiện tại của người ném. | Chưa chạy |
| QA02 / F03–F04, UC05 | Block trước khi bóng qua rổ; Block khi chưa hết hồi chiêu; Block và qua rổ cùng tick. | Block hợp lệ vô hiệu cú ném và chuyển bóng tự do theo thiết kế. Block không hợp lệ không thay trạng thái. Trường hợp cùng tick chờ Q03. | Chưa chạy |
| QA03 / F04 | Bóng qua rổ trước, đúng và sau tick hết 3 phút; input tới sau Finished; tỷ số hòa và không hòa. | Theo thứ tự hết giờ đã duyệt; không cộng điểm hoặc nhận hành động mới sau kết thúc; hai client cùng kết quả. Quy tắc hòa cần xác nhận riêng. | Chưa chạy |
| QA04 / F04 | Từ 9 điểm ghi 2; từ 10 điểm ghi 3; ghi điểm nhưng chưa đạt 11. | Ít nhất 11 điểm kết thúc ngay, không yêu cầu đúng 11. Nếu chưa kết thúc, chuyển pha và quyền bóng theo check-ball được duyệt. | Chưa chạy |
| QA05 / F03–F04 | Gửi lại input cùng `seq`, xử lý lại `shotId`, nhận lại `eventId`/snapshot; client khai điểm/vị trí giả hoặc gửi input sai quyền. | Tối đa một lần cộng điểm; không lặp hiệu ứng; server không tin điểm client. Ack tuân theo định nghĩa đã chốt, không đồng nghĩa hành động được chấp nhận. | Chưa chạy |
| QA06 / F01–F02 | Rời phòng tại Waiting, Countdown, Playing; cả hai rời đồng thời; chơi lại rồi nhận input/event trận trước. | Không bắt đầu thiếu người; hủy đếm ngược khi thiếu người. Rời giữa trận theo Q01; dọn phiên/kết quả đúng một lần; trận mới không nhận dữ liệu cũ. | Chưa chạy |
| QA07 / F05 | Ngắt một/cả hai kết nối; đóng socket rõ ràng và mất mạng im lặng; heartbeat tới gần ranh timeout. | Input về trung tính theo đặc tả; hiển thị mất kết nối; server quyết định timeout/kết quả. Không mặc định reconnect. Không lấy 10 giây làm ngưỡng đã duyệt. | Chưa chạy |
| QA08 / F05, N03 | Khi có sản phẩm: tăng trễ/gián đoạn truyền; phát lại snapshot/event ở tầng ứng dụng; đo RTT riêng với trễ thao tác–hiển thị. | Bóng, điểm và kết quả hội tụ theo thiết kế; mất event không làm mất điểm. Lưu số đo gốc; không kết luận đạt FPS/RTT khi chưa có ngưỡng. | Chưa chạy |

Với WebSocket, không mặc định thông điệp đảo thứ tự trong một kết nối. Ca dữ liệu cũ/trùng cần mô tả rõ việc phát lại ở tầng ứng dụng hoặc qua phiên kết nối khác.

## Truy vết và bằng chứng

Hồ sơ nguồn có mã LT01–LT12, HT01–HT05 tương ứng tài liệu tham khảo Chương 2; Chương 1 dùng SCENE-01/02. Đây là đối chiếu nội bộ, chưa phải QA truy cập và kiểm chứng lại nguồn web. LT12 không tự chứng minh khả năng xuyên NAT, kiến trúc Internet hoặc chính sách timeout của game.

Chương 1 mục 1.4 và Chương 3 N03 hiện giữ FPS/RTT/số trận ở trạng thái cần thống nhất. Seed, dùng chung Dart và fixed timestep không chứng minh tính tất định đa nền tảng.

Khi chạy thử cần lưu bản dựng, dependency, thiết bị/Android, chế độ build, cấu hình mạng và luật; liên kết log server–client bằng `matchId`, tick, `seq`, `ackSeq`, `shotId`, `eventId`. Một Redmi Note 11 cộng client máy tính/giả lập chỉ hỗ trợ phát triển, không thay bằng chứng hai Android từ hai mạng khác nhau.

## Bàn giao

- Sản phẩm bàn giao: bảy vấn đề đặc tả và tám nhóm ca thử dự kiến để Lead lưu vào `qa/review-r1.md`.
- Bằng chứng: rà soát văn bản Chương 1–3, nguồn Mermaid và hồ sơ nguồn; chưa có kết quả kiểm thử hoặc phép đo.
- Điểm chưa rõ: chính sách rời/timeout, ack, thứ tự cùng tick, check-ball, vòng đời sự kiện và thiết bị Android thứ hai.
- Bước tiếp theo: thống nhất oracle còn mở, đồng bộ chương với sơ đồ; thực thi ca thử khi có bản dựng và nhiệm vụ được giao.

Lead lưu báo cáo trả trực tiếp từ worker do worker không tạo được thư mục đầu ra. Các nhận xét phản ánh bản mà worker đã đọc; xem docs/R1_REVIEW.md để biết sửa đã tích hợp và giới hạn hiện hành.

