# Rà soát sơ đồ và truy vết R1

Ngày rà soát: 2026-11-04. Phạm vi: Chương 3 hiện hành và các nguồn diagrams/3-1 đến 3-8. Đây là rà soát thiết kế trên tài liệu, không phải kiểm thử sản phẩm. Chưa có code hoặc kết quả chạy để đối chiếu.

## Use case UML thay thế

Nguồn vector chỉnh sửa trực tiếp: `3-2-usecase-uml.svg`. Hình dùng actor hình người, system boundary bao gồm client và server, các use case hình ellipse và association nét liền không mũi tên. Một actor Người chơi đại diện cho vai trò chung của hai người; máy chủ nằm trong boundary nên không phải actor. Không dùng include/extend vì các use case hiện tại không chứng minh quan hệ tái sử dụng bắt buộc hoặc mở rộng có điều kiện. Kiểm tra input, tính điểm và snapshot vẫn là xử lý nội bộ.

Giữ mã UC01–UC07 theo mục 3.2.3. Thêm UC08 Rời phòng để biểu diễn phần F01 đã nêu ở 3.2.1; Lead đã chấp nhận UC08 vì biểu diễn yêu cầu rời phòng hiện có của F01, không thêm tính năng; việc tích hợp đặc tả vào bản thảo do Lead thực hiện. UC01 giữ tên gộp Tạo hoặc vào phòng nhằm giữ tương thích với đặc tả hiện có; khi tách cần phân biệt hai luồng và cập nhật mã nhất quán. Không thêm ghép trận nhanh vào hình vì là bổ sung sau.

Cách tạo thực tế: dựng XML SVG trực tiếp bằng PowerShell/.NET, lưu UTF-8; các đối tượng có id để sửa bằng trình biên tập XML hoặc phần mềm vector hỗ trợ SVG. Không dùng Figma, draw.io, PlantUML hay xuất từ công cụ UML. Đây là ký pháp use case UML bằng vector, không đổi tên flowchart Mermaid thành UML. Giữ nguyên toàn bộ ảnh và nguồn cũ làm lịch sử.

Chưa có PNG: không tìm thấy Inkscape/ImageMagick trên PATH và không phân giải được sharp, Playwright, Puppeteer hoặc resvg từ Node trong dự án. Không cài thêm renderer. Kiểm tra XML, số lượng đối tượng và nhãn bằng công cụ đọc XML; bố trí ellipse theo hàng với khoảng cách 100, chiều cao 72, font 18 và bán kính ngang 210. Chưa render/kiểm tra trực quan ảnh raster hoặc glyph theo font của máy người đọc; không tuyên bố đã export PNG. Lead cần render và kiểm tra trực quan trước khi dùng trong Word. Nguồn SVG không phải giao diện game và không thay bộ thiết kế UI bên thứ ba.

## Truy vết và sai lệch cần tích hợp

| Mục | Đối chiếu yêu cầu–luật–lớp–trạng thái–tuần tự | Sai lệch hoặc khoảng trống và đề xuất |
|---|---|---|
| F01, UC01/UC08 | 3.2.1 yêu cầu tạo/vào/rời; RoomState–SessionState, Waiting/Closed | Use case cũ thiếu rời phòng. Hình mới thêm UC08 nhưng bản thảo chưa có đặc tả/mã này. UC01 gộp hai mục tiêu trong một luồng tạo rồi đối thủ vào; cần phân biệt hai người thực hiện hai nhánh. |
| F02, UC02 | Hai người sẵn sàng; Waiting → Countdown → Playing | Bảng dữ liệu nói có ready nhưng lớp không có trường sẵn sàng; Countdown chưa có dữ liệu/guard đếm ngược. Sơ đồ không có nhánh Countdown → Closed nếu phòng rỗng; cần nêu quy tắc chuyển qua Waiting hay đóng trực tiếp. |
| F03, UC03–UC05 | Di chuyển/nhảy/Dash/Block, giữ bóng và hồi chiêu; PlayerState, BallState | PlayerState chỉ có position/velocity/action; chưa thể hiện hồi chiêu và hướng như bảng. Không có sơ đồ trạng thái nhân vật/bóng hoặc bảng chuyển trạng thái tương đương; MatchPhase chưa đủ mô tả việc cấm ném khi Dash và Block chỉ với bóng đang bay. |
| F04, UC04/UC06 | 2/3 điểm theo vị trí thả bóng, một cú ném cộng tối đa một lần; ShotState | Bảng có vị trí/thời điểm ném, lớp chỉ shotId/shooterId/pointValue/scored. Cần lưu/diễn giải căn cứ chốt pointValue tại lúc thả bóng, gồm trường hợp trên vạch; hiện chưa truy vết đầy đủ từ luật đến lớp. |
| F04, kết quả | ≥11 điểm hoặc 3 phút, hòa khi bằng điểm; WorldState, Finished | Bảng dữ liệu có score/result, lớp WorldState chưa thể hiện; trạng thái Finished chưa mô tả thắng/thua/hòa. UC06 nói kết quả xác nhận nhưng thiếu cấu trúc kết quả/lý do kết thúc trong sơ đồ lớp. |
| UC04, thứ tự xử lý | 3.1.2 đề xuất ưu tiên hết giờ; hoạt động 3-7 kiểm hết giờ trước điểm | Tuần tự 3-6 để cộng điểm sau loop tick bóng bay, không ở trong từng tick và thiếu điều kiện dừng loop. Cần đưa các nhánh hết giờ/Block/ghi điểm vào vòng xử lý cùng điểm thoát, tránh hiểu vẫn bay sau sự kiện kết thúc. |
| UC04, pha mới | 3.1.2 cấp bóng cho người bị ghi điểm và bố trí lại hai người; 3-7 có Check-ball | Tuần tự không thể hiện reset pha/cấp bóng khi ghi điểm mà chưa đủ điểm thắng. BallState thiếu vận tốc so với bảng, chưa có trạng thái chuyển từ bóng bay sang tự do/giữ bóng/pha mới. Cần bảng chuyển bóng hoặc sơ đồ riêng khi được giao. |
| Luật nhặt bóng | 3.1.2 ưu tiên khoảng cách rồi thứ tự vị trí phòng | Lớp slots chỉ là quan hệ 0..2, chưa thể hiện thứ tự ổn định để phân xử bằng nhau; không có luồng nhặt bóng trong tuần tự. Chỉ báo khoảng trống, không tự thêm luật. |
| F05 | SessionState/lastSeen, heartbeat, Playing → Finished/Closed | Lớp thiếu lastSeen như bảng, chưa có mô hình kết nối hoặc guard phân biệt timeout một người/cả hai. Hai cạnh kết thúc có thể cạnh tranh; cần thứ tự ưu tiên và bảo đảm xử kết quả một lần. Ngưỡng heartbeat/timeout vẫn là đề xuất, không phải kết quả đo. |
| F06, UC07; N01–N03 | Âm thanh cục bộ; phiên bản/đo đạc và UI | Không cần ép use case hoặc lớp máy chủ cho cài đặt cục bộ. N01–N03 cần tài liệu môi trường, UI và kế hoạch đo riêng; không thể chứng minh bằng hình UML hoặc thông số 60/20 Hz, 100 ms chưa thử. |
| Trạng thái sau trận | Finished → Waiting khi chơi lại; 3.3.1 yêu cầu đặt lại ready | Chưa biểu diễn thao tác reset ready và phân biệt ở lại phòng/rời về menu trong mô hình; cần khớp UC06/UC08 và trạng thái phòng. |
| Tích hợp bản thảo | 3.2.3 và comment diagram vẫn trỏ nguồn flowchart cũ | Lead cần thay liên kết hình và đoạn mô tả sau khi duyệt SVG. Worker giữ nguyên manuscript, ảnh/source cũ. 3-7 là flowchart xử lý, chưa nên gọi là sơ đồ hoạt động UML chuẩn. |

Các thiết kế lớp, máy chủ, giao thức, quỹ đạo và chính sách ngoại lệ vẫn là đề xuất. Gameplay được đồng ý không đồng nghĩa kiến trúc đã được phê duyệt. Rà soát này không chốt backend, vật lý, ngưỡng mạng hoặc thiết kế UI.

## Bàn giao

- Sản phẩm bàn giao: SVG use case UML và tài liệu truy vết này; không có PNG, không sửa manuscript hoặc nguồn cũ.
- Bằng chứng: đọc AGENTS.md, PROJECT_BRIEF.md, thesis/OUTLINE.md, thesis/03-xay-dung-game.md và các nguồn Mermaid hiện có; kiểm tra cấu trúc XML và nhãn SVG. Không build game hoặc kiểm thử hai Android.
- Điểm chưa rõ: quyết định kiến trúc, chính sách ngoại lệ, thông số và đặc tả chi tiết còn thiếu; hình SVG chưa được render trực quan.
- Bước tiếp theo: Lead duyệt UC08 và các sai lệch, tích hợp hình/mô tả trong bản thảo; render và kiểm tra font trước xuất Word. Không commit/push ở worker.
## Cập nhật nguồn lớp và tuần tự sau rà soát

Theo giao việc bổ sung R1 ngày 2026-11-04, đã tạo hai nguồn mới, không ghi đè `3-4-lop.mmd` hoặc `3-6-tuan-tu-nem.mmd`. Bảng sai lệch phía trên ghi nhận trạng thái trước khi sửa; các mục đã xử lý ở nguồn mới được xác định dưới đây, không có nghĩa manuscript đã tự cập nhật.

- `3-4-lop-r1.mmd`: bổ sung ready, lastSeen, connection và slotIndex trong SessionState; facing/cooldowns trong PlayerState; velocity trong BallState; releasePosition/releaseTick trong ShotState; score/result trong WorldState. slotIndex giữ ổn định và duy nhất trong phòng, score có hai phần tử đối chiếu cùng chỉ số. Các trường là dữ liệu dự kiến, không phải API Scene. ConnectionRef, Cooldowns và MatchResult là tên kiểu mô tả; không lựa chọn backend, thư viện hoặc giá trị hồi chiêu. lastSeen chưa chốt đơn vị/nguồn đồng hồ. result gồm kết quả và lý do kết thúc, chỉ có nghĩa khi kết thúc; holderId và shot có thể vắng theo trạng thái bóng. Các chi tiết tuần tự hóa/nullable cần cụ thể hóa khi triển khai.
- `3-6-tuan-tu-nem-r1.mmd`: đưa ưu tiên hết giờ/trận đã kết thúc, Block, qua rổ, trượt vào trong vòng tick; mỗi nhánh giải quyết cú ném đặt resolved = true, nhánh còn bay tiếp tục tick. resolved là cờ điều khiển xử lý trong sơ đồ, không phải yêu cầu thêm trường mạng. Điểm chỉ do máy chủ cộng khi shotId hiện hành và chưa scored; nếu chưa đủ điểm thắng thì check-ball cấp bóng cho người bị ghi điểm và đặt lại vị trí hai nhân vật. Không thêm backend hoặc ngưỡng. Không thay quy tắc ưu tiên hết giờ của thiết kế cũ; quy tắc đó vẫn cần được chốt cùng luật chi tiết.
- Các khoảng trống dữ liệu ready/lastSeen/velocity/facing/cooldowns/vị trí và tick thả bóng/score/result/slotIndex đã xử lý trong nguồn lớp mới. Sai lệch vị trí nhánh xử lý sau loop và thiếu check-ball đã xử lý trong nguồn tuần tự mới. Đây là khắc phục trên nguồn sơ đồ, chưa phải bằng chứng chạy đúng hoặc chứng minh tính tất định.
- Khoảng trống trạng thái bóng/nhân vật vẫn cần đối chiếu; Lead có thể dùng bảng chuyển trạng thái trong manuscript thay vì tạo sơ đồ mới. Bảng cần khớp trạng thái giữ/bay/tự do, điều kiện nhặt bóng, cấm ném khi Dash, điều kiện Block, reset pha và kết thúc; không xem MatchPhase là đủ thay thế. Các vấn đề Countdown khi phòng rỗng, ưu tiên timeout một/cả hai, reset ready sau trận và chi tiết kiểu dữ liệu vẫn cần Lead tích hợp/xác định. Bounded pass này không sửa các nguồn trạng thái hoặc manuscript.

Cách tạo thực tế: ghi văn bản Mermaid UTF-8 trực tiếp bằng PowerShell/.NET. Worker tự rà soát trường, guard, nhãn và cặp khối điều khiển; không xuất PNG. Lead cho biết dùng renderer trong `.local-tools` tại root mới để render SVG use case và các nguồn Mermaid; việc render/kiểm tra trực quan đầu ra thuộc Lead, không gán kết quả render đó cho worker. Đoạn ghi chưa có renderer ở lần bàn giao đầu mô tả đúng thời điểm kiểm tra ban đầu, không còn là blocker cho Lead.

### Bàn giao bổ sung

- Sản phẩm bàn giao: hai nguồn Mermaid R1 và cập nhật truy vết; nguồn cũ giữ nguyên làm lịch sử.
- Bằng chứng: đối chiếu bảng dữ liệu/luật đã đọc của Chương 3, kiểm tra danh sách trường và các nhánh kết thúc trong vòng tick. Không chạy game hoặc bịa kết quả kiểm thử.
- Điểm chưa rõ: các quyết định thiết kế/kiểu dữ liệu còn mở và bảng chuyển trạng thái do Lead tích hợp; PNG chờ Lead render.
- Bước tiếp theo: Lead render, kiểm tra labels và tích hợp nguồn R1 vào bản thảo. Worker không sửa manuscript, cài package, commit hoặc push.