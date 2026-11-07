Bàn giao bổ sung Ch2 từ nền v0.6 — 07/11/2026

Chỉ đọc mọi root; không ghi tệp, dựng Word hoặc chạy lại R3. Đã dùng research-paper-writing và humanizer. Các dòng “Vị trí/Thao tác” là chỉ dẫn tích hợp, không đưa vào manuscript. Giữ các mục lớn 2.1–2.12 và hướng dẫn A–F; bài khai báo do developer phụ trách.

A. Cuối 2.4 — chèn tiểu mục mới

Vị trí: sau đoạn cuối 2.4.3, trước “## 2.5. Hình học, vật liệu và shader”. Không thay lifecycle hiện hành.

Nội dung:

### 2.4.4. Biểu diễn khai báo và thao tác trực tiếp

Scene cung cấp hai cách điều khiển cây cảnh. Với cách thao tác trực tiếp, ứng dụng giữ Scene, tạo node và gọi API để thay đổi thuộc tính hoặc cấu trúc. Với cách khai báo, các widget như SceneNode và SceneMesh mô tả cấu trúc mong muốn theo trạng thái Flutter. Phần mô tả được đối chiếu với cây đối tượng engine còn được giữ lại, gọi là retained graph. Quá trình đối chiếu và áp dụng khác biệt này được gọi là reconciliation. [39], [41]

Widget là mô tả bất biến, còn State của widget cảnh giữ đối tượng engine và cập nhật nó khi cấu hình thay đổi. Vì vậy, một lần build không mặc nhiên tạo lại mọi node hoặc toàn bộ tài nguyên GPU. Identity của geometry và material có ý nghĩa khi đối chiếu; tạo một đối tượng tài nguyên mới trong mỗi build có thể làm mất lợi ích của việc giữ và tái sử dụng đối tượng. [39], [41]

| Trách nhiệm | Thao tác trực tiếp | Khai báo |
|---|---|---|
| Biểu diễn cấu trúc | Ứng dụng tạo, thêm và gỡ node | Widget và children mô tả cấu trúc theo state |
| Áp dụng thay đổi | Mã ghi thuộc tính hoặc cập nhật qua component | State đối chiếu cấu hình mới với đối tượng engine được giữ lại |
| Sở hữu Scene | Ứng dụng giải phóng Scene do mình tạo | SceneView.declarative tạo và giải phóng Scene nội bộ |
| Kết hợp hai cách | Có thể gắn cây con khai báo vào Scene của ứng dụng | Có cầu nối để truy cập node hoặc đặt cây con thao tác trực tiếp |
| Ranh giới cần giữ | Xác định một nơi chịu trách nhiệm cho mỗi thuộc tính | Không để mã khác đồng thời sửa cấu trúc hoặc thuộc tính do widget quản lý |

SceneNodeController cung cấp tham chiếu tới node do widget quản lý nhưng không chuyển quyền sở hữu cho mã gọi. Đối với một node được tạo theo khai báo, mã thao tác trực tiếp cần tránh sửa những thuộc tính mà widget cũng khai báo hoặc tự tổ chức lại cấu trúc của nó. SceneView nhận Scene từ ứng dụng không chịu trách nhiệm dispose Scene đó; SceneView.declarative chịu trách nhiệm cho Scene nội bộ của mình. Hai cách có thể phối hợp trong cùng hệ thống nếu ranh giới này được giữ rõ. [41]

B. Mục 2.7 — phân giai đoạn chuẩn bị và hiển thị

B1. Vị trí: 2.7.1. Thay đúng đoạn bắt đầu “Scene có đường nạp GLB tại thời điểm chạy…” và kết thúc “…phiên bản đầu ra để tái hiện nội dung. [15]”. Giữ các đoạn glTF/buffer/accessor khác.

Nội dung:

Scene có hai đường chuẩn bị mô hình: nhập GLB lúc chạy hoặc chuyển đổi nội dung biết trước khi build rồi nạp đầu ra đã tiền xử lý. Tiền xử lý chuyển một phần công việc chuẩn bị sang giai đoạn tạo sản phẩm; nó không loại bỏ mọi việc phải làm lúc chạy. Cả hai đường vẫn cần quản lý phiên bản dữ liệu nguồn, cấu hình chuyển đổi và tài nguyên đầu ra. [15]

B2. Vị trí: 2.7.2. Thay đoạn đầu “Nạp tài nguyên là quá trình chuyển dữ liệu…” bằng đoạn và bảng dưới. Giữ nguyên đoạn tiếp theo về trạng thái tải và công thức bộ nhớ W×H×4.

Nội dung:

Chuẩn bị tài nguyên cần được phân biệt theo loại công việc và thời điểm thực hiện. Các giai đoạn có thể đan xen; tiền xử lý khi build là một đường chuẩn bị thay thế cho một phần công việc runtime, không phải bước luôn diễn ra sau khi ứng dụng đã đọc GLB.

| Giai đoạn | Công việc chính | Giới hạn của dấu hiệu hoàn tất |
|---|---|---|
| I/O | Đọc byte từ bundle, tệp hoặc nguồn dữ liệu | Đọc xong chưa có nghĩa đã hiểu cấu trúc mô hình |
| Phân tích và chuyển đổi dữ liệu | Diễn giải mô hình, vật liệu, ảnh và quan hệ node | Cây dữ liệu chưa chứng minh các tài nguyên kết xuất đã sẵn sàng |
| Tiền xử lý khi build | Chuyển nội dung biết trước sang dạng chuẩn bị cho engine | Không thay cho mọi khởi tạo tại runtime |
| Chuẩn bị cho kết xuất | Tạo hoặc chuyển dữ liệu tới tài nguyên cần dùng để vẽ | Chưa bảo đảm mọi pipeline của khung hình đầu đã được chuẩn bị |
| Warm-up | Chuẩn bị pipeline cho các view và nội dung hiện có | Không bao phủ tự động mọi nội dung hoặc cấu hình sẽ thêm về sau |

Phân biệt các giai đoạn giúp giải thích vì sao hoàn tất đọc tệp và hiển thị khung hình đầu là hai mốc khác nhau. Khi đánh giá thời gian mở cảnh, cần chỉ rõ khoảng thời gian đo bắt đầu và kết thúc ở mốc nào. [15], [41]

B3. Vị trí: 2.7.2. Thay đoạn cuối bắt đầu “Tài liệu Scene phân biệt nạp tài nguyên và xây dựng cấu trúc cảnh…” bằng hai đoạn dưới; không tạo tiểu mục mới để tránh đẩy 2.7.3/2.7.4.

Nội dung:

Trong Scene 0.24.3, loading của SceneView nhận ResourceGroup để theo dõi nhóm tác vụ trước khi hiện cảnh; loadingBuilder tạo phần giao diện chờ. Cơ chế này khác với warmUp, có giá trị mặc định false và yêu cầu SceneView chuẩn bị pipeline trước khi cho thấy cảnh. Cây con khai báo vẫn được giữ mounted và tiếp tục tải khi view đang chờ; màn hình chờ không có nghĩa quá trình tạo nội dung phải dừng. [41]

Trong đường reveal đã đối chiếu, view chờ tài nguyên tĩnh dùng chung, nhóm tải được truyền vào, các tác vụ nạp của cây con và tài nguyên trì hoãn liên quan. Nếu warmUp được bật, nó tiếp tục gọi Scene.warmUp với các view sẽ dùng rồi mới cho hiện cảnh. Nội dung cần được đưa vào cảnh trước bước này. Scene.initializeStaticResources(), nhóm tải và warm-up vì thế phục vụ những phạm vi khác nhau. Việc bật các tùy chọn này chưa chứng minh thời gian mở cảnh, mức dùng bộ nhớ hoặc tốc độ hiển thị trên thiết bị cụ thể. [41]

C. Mục 2.11 — vòng phản hồi phát triển

Vị trí: sau các đoạn của 2.11.3, trước đoạn chuyển “Các phần trên tạo cơ sở giải thích…”. Chèn hai tiểu mục dưới. Giữ đoạn chuyển ngay trước 2.12; không chèn mã thực hành ở đây.

Nội dung:

### 2.11.4. Hot reload và vòng phản hồi phát triển

Vòng chỉnh sửa–quan sát–kiểm chứng giúp liên hệ thay đổi trong mã hoặc tài nguyên với trạng thái ứng dụng. Cần phân biệt rebuild cây mô tả, hot reload mã Dart, reload tài nguyên và khởi động lại: chúng tác động tới các phạm vi trạng thái khác nhau.

| Cơ chế | Phạm vi cần xét | Điều không được suy ra |
|---|---|---|
| Rebuild widget | Đối chiếu lại mô tả với đối tượng được giữ lại | Mọi tài nguyên GPU đều bị tạo lại |
| Hot reload mã Dart | Áp dụng sửa mã trong phiên phát triển, liên quan vòng reassemble | Mọi bước khởi tạo ứng dụng đều đã chạy lại |
| Reload tài nguyên | Đọc lại và cập nhật tài nguyên có cơ chế theo dõi tương ứng | Mọi tệp ngoài đều được tự phát hiện |
| Khởi động lại | Tạo lại phiên chạy và trạng thái khởi tạo tương ứng | Kết quả giống một phiên được duy trì qua reload |
| Bản release | Kiểm chứng bản dựng và luồng nạp thực tế khi phát hành | Kết quả phiên debug tự đại diện cho bản release |

Trong nguồn 0.24.3, SceneView.reassemble gọi HotReloadCoordinator. Bộ điều phối có thể làm mới những scene, texture, môi trường và vật liệu đã đăng ký khi nội dung thay đổi. Các nhánh này được giới hạn bởi kDebugMode; chúng không phải cơ chế reload của bản release. Sự có mặt của hook cũng không bảo đảm một tài nguyên bất kỳ do ứng dụng tự đọc đã tham gia cơ chế theo dõi. [41]

Một lượt kiểm tra nên ghi nội dung trước sửa, chỉ thay một yếu tố, rồi đối chiếu ảnh và trạng thái sau cập nhật: node có bị nhân đôi không, thuộc tính nào cần giữ và tài nguyên mới có thay cho bản cũ không. Sau đó kiểm tra lại từ phiên khởi động mới và bản dựng tương ứng với mục tiêu đánh giá. Đây là nguyên tắc kiểm chứng quy trình phát triển, chưa phải kết quả đã thử của đề tài.

### 2.11.5. Vai trò của công cụ biên tập cảnh

Scene Editor là ứng dụng desktop phục vụ tạo, quan sát và chỉnh cảnh. Công cụ biên tập hỗ trợ vòng chuẩn bị nội dung, còn ứng dụng runtime sử dụng dữ liệu để xử lý và kết xuất. Tài liệu yêu cầu xét phiên bản editor cùng phiên bản package của dự án. Đề tài hiện chưa dùng editor để tạo sản phẩm; phần này chỉ giới thiệu vai trò, không xác nhận tính tương thích hoặc hiệu năng của một cấu hình editor cụ thể. [40]

--- Kết thúc các khối manuscript; phần dưới chỉ dành cho hồ sơ tích hợp ---

Registry đề xuất theo chỉ định Lead, chưa sửa REFERENCES trên đĩa:
[38] Brandon DeRosier, Scene: A complete 3D engine for Flutter — Brandon DeRosier | Flutter & Friends 2026, video, https://www.youtube.com/watch?v=BPAg7qt5Dz0 . Ngày đăng theo trang YouTube được Cindy ghi nhận: 01/10/2026; truy cập/xem chọn đoạn bởi Cindy ngày 07/11/2026. Không có full transcript hoặc xác nhận xem toàn bộ. Thesis chỉ đọc báo cáo Cindy, không mở lại video.
[39] Flutter Scene, Declarative scenes: https://fscene.dev/guides/declarative-scenes/ . Thesis đọc trang hiện hành ngày 07/11/2026; API/version-specific được đối chiếu cache [41].
[40] Flutter Scene, The Flutter Scene Editor: https://fscene.dev/editor/ . Thesis đọc ngày 07/11/2026. Trang đang hiển thị editor 0.24.0, ngày 05/10/2026; không suy rằng đã xác minh tương thích riêng editor 0.24.0 với package 0.24.3.
[41] Gói flutter_scene 0.24.3, mã nguồn phân phối: lib/src/widgets/scene_view.dart; lib/src/widgets/declarative.dart; lib/src/hot_reload/hot_reload_coordinator.dart. https://pub.dev/packages/flutter_scene/versions/0.24.3 . Thesis đối chiếu cache ngày 07/11/2026; URL định danh bản phân phối, không nhận đã checkout tag GitHub. Có đọc bổ trợ resource_group.dart, nhưng patch không đưa tên hàm/semantics chi tiết từ tệp đó.
[15] Flutter Scene, Assets and loading: https://fscene.dev/guides/assets-and-loading/ . Giữ mục [15] và ngày truy cập 04/11/2026 hiện có; bổ sung riêng lượt đọc 07/11/2026 trong registry/claim map. Không thay hoặc xóa dấu vết khảo sát cũ.
Giữ [1]–[37] hiện hành. [38] là nguồn định hướng kế thừa từ Cindy, không được gán thành lượt quan sát video trực tiếp của thesis. Các khối manuscript trên không dùng [38] làm căn cứ API; các khẳng định kỹ thuật dẫn tài liệu/source trực tiếp.

Claim map:
| Khẳng định trong patch | Nguồn thực dùng | Phạm vi và giới hạn |
|---|---|---|
| Hai kiểu API; retained graph và reconciliation | [39] trang đọc mới; [41] phần đầu declarative.dart và constructor SceneView | Không suy rebuild luôn tạo lại scene/GPU |
| Geometry/material diff theo identity | [39], [41] mô tả lớp khai báo | Không biến “cheap rebuild” thành benchmark hoặc độ phức tạp đã đo |
| Scene ứng dụng so với scene nội bộ; children phối hợp được | [41] scene_view.dart constructors, scene/children fields, dispose | Không chuyển ownership chỉ vì có controller |
| Controller và writer xung đột | [41] declarative.dart, SceneNodeController/ownership | Không bảo đảm trạng thái imperative tùy ý được giữ qua mọi reconciliation |
| Hai đường GLB runtime/build preprocessing | [15] đọc 07/11 | Không suy mọi extension glTF hoặc asset đều đã chạy |
| Các mốc I/O/phân tích/chuẩn bị/pipeline khác nhau | [15] và [41] reveal/warm-up | Là phân tích quy trình, không trình bày như trace đã đo |
| loading/ResourceGroup và warmUp mặc định false | [41] scene_view.dart constructor và field comments | Không suy ResourceGroup.progress là phần trăm byte hoặc dự báo thời gian |
| Reveal chờ nhóm ngoài/cây con/deferred resources, rồi warmUp tùy chọn | [41] _startRevealWatch, _warmUpViews | Chỉ đường mã được đọc; không nhận đã chạy trên thiết bị |
| SceneView.reassemble gọi coordinator, refresh giới hạn debug | [41] scene_view.dart reassemble; coordinator onReassemble/refresh/kDebugMode | Không bảo đảm reload mọi file do app tự nạp hoặc giữ mọi state |
| Vòng edit–observe–verify, đối chiếu restart/release | Nguyên tắc kiểm chứng được đề xuất; [41] cho ranh giới debug/release | Không gán kết quả chưa chạy |
| Editor là công cụ desktop cho authoring/inspection, cần xét version | [40] trang đã đọc | Chưa tải, mở editor hoặc xác nhận tương thích 0.24.0/0.24.3 |
| Video có ví dụ khai báo/reload/editor | [38] chỉ qua báo cáo Cindy ngày 07/11 | Cindy xem 10 mốc, không full transcript; thesis không nhận đã xem |

Nguồn thực đọc và thao tác:
- Đã đọc AGENTS.md, PROJECT_BRIEF.md, docs/CONTEXT_HANDOFF.md, docs/CURRENT_STATUS.md, thesis/OUTLINE.md; đối chiếu các đoạn đích Ch2 và registry hiện có.
- Đã đọc báo cáo Cindy tại đường dẫn Lead cung cấp. Không mở video hoặc lấy screenshot/transcript.
- Đã mở ba trang official theo yêu cầu; web hiện hành không được coi là source 0.24.3 tự động.
- Đã đọc cache package 0.24.3 bằng đường dẫn tuyệt đối: scene_view.dart, declarative.dart, hot_reload_coordinator.dart, resource_group.dart. Không tải dependency.
- Không sửa R2 metadata-only, không gán quan sát mới cho lần R2; lịch sử đó vẫn đúng với mức truy cập khi ấy.

Tự rà soát:
- Bố cục: chỉ thêm 2.4.4 và 2.11.4–2.11.5; sửa đúng các đoạn 2.7, giữ các mục lớn và số hoạt ảnh/skinning.
- Văn phong: mỗi đoạn giải thích một quan hệ; bảng so sánh theo trách nhiệm. Không thêm bold, tiêu đề caps, đường dẫn máy hoặc checklist vào manuscript.
- Khẳng định: tách retained description/engine object, external/owned Scene, load/warm-up, debug/release.
- Bằng chứng: không có benchmark, Android render, GLB runtime, editor runtime hoặc Internet mới.
- Phạm vi: không viết bài khai báo/code thay developer, không thay A–F, không mở rộng audio/AI/ragdoll.

Gates thực chạy:
- Get-Content -LiteralPath (các path hồ sơ/project/Cindy source nêu trên) -Encoding UTF8 | PASS: đọc được tài liệu và vị trí đích | logpath=none; read-only, không lưu log mới.
- web.open https://fscene.dev/guides/declarative-scenes/ | PASS: có nội dung trang | logpath=none; tool transcript.
- web.open https://fscene.dev/guides/assets-and-loading/ | PASS: có nội dung runtime/preprocessing/loading/warm-up | logpath=none.
- web.open https://fscene.dev/editor/ | PASS: có nội dung editor/version/requirements | logpath=none.
- Get-Content và rg source cache flutter_scene-0.24.3/lib/src/{widgets/scene_view.dart,widgets/declarative.dart,hot_reload/hot_reload_coordinator.dart,resource_group.dart} | PASS: đã đọc các đoạn nêu trong claim map; không chạy source | logpath=none.
- Analyze/build/runtime/Word export/video screenshots/editor/git/commit/push | NOT RUN | logpath=none.

- JS in-memory patch checks (subsections, no bold/code walkthrough/machine paths, default warmUp, registry/video limits) | PASS | logpath=none.

Sản phẩm bàn giao: toàn văn patch A–C, registry đề xuất [38]–[41], bổ sung lịch đọc [15] và claim map; không có tệp được ghi.
Bằng chứng: đọc độc lập ba trang official và source cache đúng phiên bản; quan sát video là bằng chứng kế thừa có phạm vi rõ.
Điểm chưa rõ: hành vi bài khai báo sẽ do developer/Lead kiểm; editor chưa dùng, reload/warm-up chưa đo trên điện thoại; metadata [38] chưa được thesis kiểm trực tiếp.
Bước tiếp theo: Lead đối chiếu registry [38]–[41], lưu patch, ghép bài khai báo nếu đạt gate và xuất phiên bản mới; giữ nguyên v0.6 và lịch sử R2.

