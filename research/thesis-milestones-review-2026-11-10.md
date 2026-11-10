Báo cáo rà source luận văn sau M1–M3a — 10/11/2026

Phạm vi: đọc theo nền Lead cung cấp ab9bf92; không chạy git để xác nhận HEAD live, không ghi root nào, không export/build/test/ADB. Đã đọc và áp dụng research-paper-writing/humanizer. Không nhận đã xem ảnh/video hoặc chạy lại các gate milestone.

Ưu tiên review:
P1 — Phạm vi Ch3: đoạn mở đầu đang mô tả hai client/máy chủ và nhiều chức năng bằng thì hiện tại, trong khi sản phẩm được kiểm mới là tập offline. Cần gắn phạm vi thiết kế ngay đầu chương và thêm ranh giới hiện thực tại phần ném; không đổi toàn bộ sơ đồ hoặc luật 1v1.
P1 — Cách ghi kết quả: số test 13/22/34 là các tổng theo mốc, không cộng thành 69 test của một bản. Probe Scene/Fox, tutorial headless và app offline là sản phẩm khác nhau; kết quả của probe không chứng minh model Fox đã tích hợp vào game.
P2 — Ch2: thêm ngắn pointer ownership/cancel, ánh xạ joystick và tách pause logic khỏi ticker. Phương pháp số thuộc lý thuyết; giá trị deadzone/config và kết quả runtime thuộc hiện thực/đánh giá.
P2 — Ch2/Ch3: giải thích quỹ đạo analytic, độ cao thả và crossing đúng chiều; không trình bày như solver bảng-vành.
P2 — Định dạng: đã đọc nguyên bản THESIS_FORMAT_2026-11-09.md. User override cho STYLE tiêu đề ưu tiên hơn quy tắc cũ “không bold/caps”. Khi Lead xuất: TNR13, Before6pt, Multiple1.3; TOC18 bold CAPS center, chapter24 bold CAPS right, cấp2=15 bold CAPS, cấp3=14 bold chữ thường, cấp4=13 underline, lowest13. Không tự gán After, căn lề cấp chưa quy định hoặc thông số trang khác. Markdown dưới đây chỉ là nội dung; chưa xác nhận Word đã mang style này.

Các patch ngắn sẵn để lưu. Nhãn nguồn mới để Lead cấp số liên tục sau [41]; không tự ấn định số. Các anchor/thao tác và phần claim map không đưa vào manuscript.

Patch 1 — 2.8.2, thay đoạn “Cần phân biệt trạng thái giữ và sự kiện cạnh…” đến “…tránh lệnh tồn tại ngoài ý muốn.”

Nội dung:
Cần phân biệt trạng thái giữ và sự kiện cạnh. Một nút giữ có thể tạo lệnh trong nhiều bước mô phỏng; một lần nhấn chỉ nên tạo một yêu cầu nếu chức năng cần như vậy. Flutter cung cấp định danh pointer cho từng tương tác và các callback down, move, up, cancel qua Listener. Ứng dụng phải tự quy định pointer nào sở hữu từng điều khiển; cancel là kết thúc tương tác bị hủy, không được mặc định diễn giải như thả để thực hiện hành động. [NGUỒN-POINTER], [NGUỒN-LISTENER]

Khi nhiều ngón hoạt động đồng thời, mỗi điều khiển cần kiểm tra định danh trước khi cập nhật hoặc kết thúc lệnh. Hủy thao tác ném không mặc nhiên xóa hướng di chuyển còn được pointer khác giữ. Khi reset hoặc mất khả năng tương tác, ứng dụng cần đưa đầu vào về trung tính và loại bỏ callback thuộc trạng thái cũ. Đây là chính sách của lớp nhập liệu, không phải quyền sở hữu do Listener tự thiết lập.

Patch 2 — 2.8.2, chèn sau Patch 1 và trước “Với một điểm màn hình, picking đổi tọa độ đó thành tia…”

Nội dung:
Với joystick tròn, độ dời so với tâm cần được chia cho bán kính hành trình để thu vector không thứ nguyên u. Có thể giới hạn vector vào đĩa đơn vị bằng u_c = u/max(1,||u||), rồi áp dụng vùng chết xuyên tâm δ với 0 ≤ δ < 1. Nếu r = ||u_c|| ≤ δ, đầu ra bằng 0; nếu r > δ, đầu ra là (u_c/r)(r−δ)/(1−δ). Cách ánh xạ này giữ hướng, tăng liên tục độ lớn từ 0 tới 1 ngoài vùng chết và không làm thao tác chéo có độ lớn vượt quá 1. Việc luôn chuẩn hóa mọi vector khác 0 thành độ dài 1 sẽ làm mất mức điều khiển analog. Dữ liệu không hữu hạn cần bị loại hoặc đưa về trung tính trước phép tính.

Ghi chú nguồn ngoài manuscript: công thức Patch 2 là diễn giải toán của radialJoystickAxis/clampJoystickUnit thực đọc trong source ứng dụng; không gán nó thành hành vi sẵn có của Flutter. Không đưa deadzone0,15 vào phần lý thuyết. Lead có thể truy vết source nội bộ trong claim map thay vì thêm citation official giả cho công thức.

Patch 3 — 2.8.3, chèn sau đoạn cuối hiện hành kết thúc “…thao tác lên Scene. [10], [17]”, ngay trước tiêu đề 2.9.

Nội dung:
Pause logic và vòng đời ticker cần được quản lý riêng. Một mô phỏng có thể ngừng nhận lệnh và không tiêu thụ thời gian khi ứng dụng không ở trạng thái tương tác, trong khi cấu trúc điều phối khung hình vẫn được giữ. Trong Scene 0.24.3, SceneView dùng SingleTickerProviderStateMixin; việc đổi autoTick có nhánh dispose và tạo ticker. Do đó, không nên dùng chu kỳ tắt–bật autoTick như một thay thế mặc định cho cơ chế pause mô phỏng. [41]

Khi nhận thay đổi vòng đời, ứng dụng cần xác định chính sách cho đầu vào đang giữ, bộ tích lũy thời gian và khoảng thời gian đầu tiên sau resume. Nếu bỏ hoặc giới hạn khoảng thời gian này, thời gian mô phỏng không còn đồng nhất với thời gian thực đã trôi qua. Flutter cũng không bảo đảm ứng dụng luôn nhận đủ mọi thông báo vòng đời, nên các callback đó không thay thế cơ chế lưu trạng thái khi tiến trình bị kết thúc. [NGUỒN-LIFECYCLE]

Patch 4 — 2.9.1, chèn sau đoạn nghiệm gia tốc không đổi kết thúc “…phải xét mô hình tiếp theo.”, trước đoạn “Động lực học liên hệ chuyển động với lực.”

Nội dung:
Với một bước nhảy lý tưởng bắt đầu và kết thúc ở cùng mặt phẳng, mô hình y(t) = v_jt − gt²/2, g > 0, cho thời điểm trở về mặt phẳng t_land = 2v_j/g khi v_j > 0. Phát hiện đã đến mốc này cho phép đưa trạng thái về tiếp đất một lần thay vì tiếp tục nhận độ cao âm. Đây là mô hình động học; nó chưa giải quyết bề mặt dốc hoặc tiếp xúc với vật cản.

Độ cao thả bóng là điều kiện đầu của quỹ đạo. Nếu cần bóng đi tới độ cao y_target sau khoảng T > 0, thành phần vận tốc đứng được giải từ cùng phương trình: v_y = (y_target − y_origin + gT²/2)/T. Khi y_origin thay đổi do nhân vật nhảy, phải tính lại vận tốc theo mô hình đã chọn; cộng thêm vận tốc nhảy vào một nghiệm đã được giải cho cùng mục tiêu sẽ làm thay đổi quỹ đạo đó. Các hệ thức là phép biến đổi từ mô hình gia tốc không đổi, không phải bằng chứng hệ vật lý đã được chạy.

Patch 5 — 2.9.4, chèn sau đoạn cuối kết thúc “…mọi loại ứng dụng.”, trước 2.10.

Nội dung:
Với quỹ đạo giải tích, có thể giải thời điểm giao mặt phẳng trong khoảng giữa hai bước thay vì chỉ so khoảng cách tại cuối bước. Giao cắt theo chiều đi xuống còn yêu cầu vận tốc đứng tại thời điểm đó âm; chạm mặt phẳng ở nhánh đi lên không đáp ứng cùng điều kiện. Vùng giao cắt, hướng đi và cờ sự kiện đã xử lý cần được kiểm tra riêng để tránh cộng tác dụng nhiều lần. Cách này xử lý một điều kiện hình học trên quỹ đạo đã biết; nó không thay thế solver tiếp xúc, phản lực, bật nảy hoặc va chạm với bảng và vành.

Patch 6 — Ch3, chèn một đoạn ngay sau tiêu đề chương, trước “## 3.1. Mô tả game”.

Nội dung:
Chương này trình bày thiết kế mục tiêu của game 1v1, gồm luật chơi, phòng đấu và đồng bộ giữa hai client. Phần đã hiện thực đến M3a là ứng dụng tập offline với nhân vật hình khối, di chuyển bằng joystick, giữ–thả ném và nhảy; chưa có Dash, Block, multiplayer hoặc vòng trận 11 điểm/3 phút. Các mô tả máy chủ, phòng, phân xử giữa hai người và kỹ năng còn lại dưới đây là thiết kế đề xuất, không phải danh sách chức năng đã được nghiệm thu.

Patch 7 — 3.1.3, thay đúng đoạn bắt đầu “Phương án ném ban đầu sử dụng mô hình arcade: máy chủ tính xác suất…” đến hết câu “…trên mọi nền tảng.”

Nội dung:
Thiết kế 1v1 từng đề xuất để máy chủ chọn quỹ đạo bằng xác suất có seed và phân xử tương tác phòng thủ. Phương án đó chưa được triển khai trong bản tập offline hiện hành. Bản M3a dùng quỹ đạo giải tích với sai lệch mục tiêu theo mức giữ nút: điểm thả lấy từ mẫu vị trí bóng đang được hiển thị, vận tốc được giải lại theo độ cao thả và không cộng vận tốc đứng của nhân vật. Giá trị 2 hoặc 3 điểm lấy từ vị trí chân chiếu xuống mặt sân khi thả, độc lập với độ cao bật nhảy.

Bản tập offline chỉ ghi nhận cú ném đi qua vùng rổ theo chiều xuống và chưa được tính trước đó; chưa có solver bảng–vành hoặc bóng bị Block. Kết quả của mô hình này không chứng minh phương án máy chủ, xác suất hoặc vật lý tiếp xúc đã hoạt động. Bước thời gian cố định và mã dùng chung cũng chưa đủ để kết luận tất định trên mọi nền tảng.

Patch 8 — Ch4: đoạn kết quả ngắn chờ Lead tích hợp theo bố cục đã duyệt

Không tìm thấy tệp Ch4 riêng trong danh sách source thesis đã rà. Không tạo bố cục chương mới và không chèn kết quả dưới mục lý thuyết 2.1–2.11. Khối dưới dành cho mục môi trường/kết quả bước đầu khi Lead mở Ch4; đây là bản soạn, chưa lưu.

Nội dung:
Các lần kiểm tra M1–M3a được thực hiện trên một AVD Pixel_9a, Android API 37, kiến trúc x86_64, với backend Impeller OpenGLES theo hồ sơ chạy. Đây là giả lập, không phải điện thoại Pixel vật lý hoặc Redmi Note 11. Các kết quả dưới đây giới hạn ở bản tập offline và các ca đã ghi nhận.

| Mốc | Bằng chứng và kết quả được ghi nhận | Giới hạn |
|---|---|---|
| M1 | 13 test đạt; luồng offline có sáu lần thả, ba cú ghi điểm với tổng cuối 7; có reset giữa bay và hai chu kỳ background/resume | Probe Scene/Fox được kiểm riêng, không chứng minh Fox đã tích hợp vào app offline |
| M2 | 22 test đạt; hai pointer phối hợp joystick và ném; hai cú ghi điểm 3+3, tổng 6; cancel toàn bộ và ném lại sau resume | Hủy riêng từng pointer và một số race được kiểm ở mức widget, chưa bao phủ toàn bộ trên AVD |
| M3a | 34 test đạt; oracle ghi sáu lần bắt đầu nhảy, năm lần tiếp đất và một lần reset hủy nhảy; hai cú ném trên không ghi 3+2, tổng 5; kiểm no-double-jump và giữ độ cao qua pause/resume đạt | Joystick+jump và jump+shoot là hai ca hai pointer riêng, không phải ba ngón đồng thời |

Số test là tổng của từng bản theo mốc, không cộng dồn giữa ba hàng. Kết quả kiểm tra logic, widget và runtime hỗ trợ các kết luận khác nhau; một ca widget không thay bằng chứng tích hợp Scene. Chưa có đánh giá hiệu năng máy thật, thử hai Android qua Internet hoặc nghiệm thu toàn bộ game 1v1. UI dùng khi thử là giao diện tạm, chưa phải bộ thiết kế Figma chính thức.

--- Hồ sơ review riêng; không chèn các phần dưới vào manuscript ---

Nguồn tự đọc và registry chờ cấp số:
1. [NGUỒN-POINTER] Flutter API, PointerEvent.pointer, https://api.flutter.dev/flutter/gestures/PointerEvent/pointer.html — mở và đọc 10/11/2026. Xác nhận ID pointer thay đổi theo mỗi pointer down, không đồng nhất với device ID.
2. [NGUỒN-LISTENER] Flutter API, Listener, https://api.flutter.dev/flutter/widgets/Listener-class.html — mở và đọc 10/11/2026. Xác nhận down/move/up/cancel; không gán chính sách ownership/cancel-to-shot cho framework.
3. [NGUỒN-LIFECYCLE] Flutter API, AppLifecycleState, https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html — mở và đọc 10/11/2026. Xác nhận state và giới hạn không luôn nhận đủ notification.
Ba nhãn này CHƯA có số. Lead cấp số liên tục từ registry hiện hành 41, kiểm URL trùng trước khi cấp. Không đổi [1]–[41].
4. Source SDK tự đọc: D:/flutter/packages/flutter/lib/src/gestures/events.dart (pointer), widgets/basic.dart (Listener callbacks), widgets/ticker_provider.dart (SingleTickerProvider chỉ cung cấp ticker một lần). Phiên bản Flutter3.47.8 theo hồ sơ build M1–M3a; không chạy flutter --version trong lượt này. Trang API online là hiện hành, không coi trang đó là tag3.47.8.
5. [41] source cache flutter_scene0.24.3/lib/src/widgets/scene_view.dart: đã tìm đọc phần mixin/autoTick/createTicker. Registry [41] đã bao gồm tệp này; thêm ngày đối chiếu10/11/2026 vào hồ sơ, không xóa lịch đọc07/11.
6. Công thức joystick và quỹ đạo: đọc trực tiếp game/offline-practice/lib/joystick.dart, practice.dart và main.dart. Đây là nguồn hiện thực nội bộ, không gán thành tính năng official Scene. Công thức giải tích là biến đổi từ mô hình đã trình bày 2.9.1; không tự thêm nguồn official giả.
7. Evidence/QA: docs/MILESTONE_1_REVIEW.md, MILESTONE_2_PROGRESS.md, MILESTONE_3A_PROGRESS.md; qa/milestone-1-final.md, milestone-2-final.md, milestone-3a-final.md; game/evidence-m1/runtime-assertions.json, evidence-m2/runtime-assertions.json, evidence-m3a/runtime-assertions.json. Đọc oracle được lưu, KHÔNG tự chạy assertion script ghi output.
8. Không xem ảnh/video/screenshot trong lượt này. Các nhận xét trực quan trong báo cáo QA là bằng chứng kế thừa, không phải quan sát mới của thesis.

Mini reverse-outline:
- Patch1: event thô/ID → owner mỗi điều khiển → cancel khác release → reset/callback cũ.
- Patch2: quy đổi độ dời → clamp tròn → deadzone/rescale → bảo toàn analog. Không lẫn tham số0,15 vào lý thuyết.
- Patch3: pause logic → một ticker → lifecycle/delta → giới hạn thông báo OS.
- Patch4–5: điều kiện đầu → giải jump/release → crossing đi xuống → phân biệt solver.
- Patch6–7: thiết kế 1v1 → bản offline hiện có → giới hạn chưa triển khai.
- Patch8: môi trường → từng milestone → mức bằng chứng và giới hạn.

Claim map:
| Khẳng định | Bằng chứng thực đọc | Trạng thái |
|---|---|---|
| Pointer ID và callbacks | Official API + source SDK events/basic | Có nguồn, chưa test lại |
| Ownership/cancel/epoch và deadzone | joystick.dart/main.dart + QA M2 | Chính sách source ứng dụng, không tính năng Flutter mặc định |
| Fixed-step không đồng nghĩa fixed ticker | practice.advance dùng accumulator; main giữ autoTick, pause logic, skipFrame | Đã đọc source; không thay thông số SDK/ticker |
| SingleTickerProvider và toggle autoTick | cacheScene0.24.3/scene_view.dart + SDK ticker_provider.dart | Có source; tránh khái quát thành lỗi mọi phiên bản Scene |
| Jump/release-height | practice.dart + assertionsM3a: playerY0,906904/originY2,706904 và playerY0,884193/originY2,684193; feetY0 | Oracle lưu sẵn; không chạy lại hoặc suy full physics |
| Descending crossing/mỗi shot một lần | practice.dart; QA/events oracle M1–M3a | Không chứng minh contact solver hoặc Block |
| 34test/no doublejump/jump counts | M3a progress/QA/runtime-assertions.json | Kế thừa gate Lead, không tự nhận thực chạy |
| Một AVD/backend | M1 review và checkpoint/currentstatus | Không máy thật, không hai Android/Internet |
| Thiết kế phòng/server/Dash/Block | Ch3 + giới hạn milestone | Đề xuất/chưa triển khai tới M3a |
| Styles title override | THESIS_FORMAT_2026-11-09.md | Đã đọc; chưa áp dụng hoặc kiểm Word |

Tự review:
- Đóng góp: sửa chỗ dễ hiểu nhầm và bổ sung nguyên lý phục vụ source hiện có, không viết lại chương.
- Mạch văn: lý thuyết giữ ở2.8/2.9, không thêm walkthrough A–F hoặc thủ tục nội bộ vào manuscript.
- Bằng chứng: phân loại số test theo bản, widget/runtime, probe/offline, AVD/máy thật; không nhận QAđạt là nghiệm thu fullgame.
- Giới hạn: không đo FPS/RTT, không suy Androidruntime từ build hoặc loopback, không chốt Dash/Block/mạng.
- Định dạng: không tự thêm After hoặc thuộc tính chưa quy định. Useroverride title bold/caps chỉ tác động styles, không tự bold nội dung; chưa xuất Word/PDF.

Gates thực chạy:
- Get-Content -LiteralPath hồ sơ/outline/style/Ch2/Ch3/QA/evidence/source được liệt kê -Encoding UTF8 | PASS phạm vi đọc | logpath=none.
- rg source app, source SDK, cacheScene và danh sách thesis | PASS tìm anchor/API/source hiện hành | logpath=none.
- web.open PointerEvent.pointer / Listener / AppLifecycleState | PASS đọc ba trang official | logpath=none.
- Build/test/ADB/git/export/Word/PDF/video/screenshot | NOT RUN | logpath=none.
Không lưu log ở root nào vì chỉ đọc; không dùng kết quả gate kế thừa như gate mới của thesis.

Sản phẩm bàn giao: review ưu tiên và tám patch ngắn, nguồn chờ cấp số, reverse-outline/claimmap/selfreview riêng.
Bằng chứng: official API và source phiên bản đọc độc lập; hồ sơ M1–M3a/QA/oracle lưu sẵn.
Điểm chưa rõ: Ch4 chưa có source riêng; Word chưa áp style mới trong lượt này; máy thật/ba ngón/Internet/fullgame và Figma chưa có bằng chứng mới.
Bước tiếp theo: Lead lưu các patch cần chọn, cập nhật registry nguồn và giữ Wordv0.3/các v0.7 cũ; sau tích hợp source mới quyết định lượt xuất bản và gate phù hợp. Chưa xuất Word/PDF.

