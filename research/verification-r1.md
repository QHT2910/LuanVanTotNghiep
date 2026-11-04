# Kiểm chứng nguồn Chương 2, lượt R1

Ngày rà soát: 04/11/2026. Đọc PROJECT_BRIEF.md, thesis/OUTLINE.md, thesis/02-co-so-ly-thuyet.md và research/ch02-sources.md tại workspace hiện hành. Không sửa manuscript, cài dependency, compile hoặc chạy ví dụ. Số dòng dưới đây thuộc bản đọc đầu lượt; kèm mục và cụm từ để tìm lại khi bản thảo đổi.

## Phạm vi bằng chứng

Các trang đánh dấu R đã đọc lại qua HTTP công khai, trả mã 200 ngày 04/11/2026. Công cụ web không tải được ba trang đầu; HTTP đọc được HTML, tên API và nội dung hướng dẫn. Dấu câu tiếng Anh đôi chỗ bị sai encoding; không dùng phần đó làm trích dẫn nguyên văn. Không đồng nhất đọc tài liệu với kiểm chứng mã chạy.

| Mã | Nguồn chính thức | Phiên bản và trạng thái |
|---|---|---|
| R1 | https://fscene.dev/getting-started/core-concepts/ | Tài liệu hiện hành, không gắn tag; đọc lại thành công |
| R2 | https://fscene.dev/guides/scene-graph/ | Hiện hành; đọc lại thành công |
| R3 | https://fscene.dev/guides/animation/ | Hiện hành; đọc lại thành công |
| R4 | https://fscene.dev/getting-started/installation/ | Hiện hành, yêu cầu Flutter ≥3.47; đọc lại thành công, LT01 không còn chỉ là nguồn kế thừa trong báo cáo này |
| R5 | https://pub.dev/packages/flutter_scene | Hiển thị 0.24.3; đọc lại thành công; chưa resolve dependency |
| R6 | https://pub.dev/packages/flutter_scene_rapier | Hiển thị 0.5.2, ví dụ dùng Scene ^0.24.0; đọc lại thành công |
| R7 | https://fscene.dev/guides/picking-and-input/ | Hiện hành; đọc lại thành công |
| R8 | https://docs.flutter.dev/perf/impeller | Trang phản ánh Flutter 3.47, ghi cập nhật 21/08/2026; đọc lại thành công |
| R9 | https://www.miniclip.com/games/basketball-stars/ | Trang sản phẩm không ghi phiên bản game; đọc lại thành công |

LT05–LT08, LT12 và HT01–HT04 được kế thừa từ ch02-sources.md; chưa đọc lại trong R1. Không nâng trạng thái của chúng thành kiểm chứng mới. Riêng nội dung chung về GLB/build hook còn được R4/R5 hỗ trợ. Chưa xác minh source theo tag của mọi API.

## Bảng khẳng định và đề xuất sửa

P1 cần sửa trước tích hợp; P2 làm rõ khi hoàn thiện hướng dẫn. Không phát hiện tuyên bố đã chạy ví dụ trong bản đọc.

| Vị trí, khẳng định | Nguồn, phiên bản | Vấn đề | Đề xuất sửa chính xác |
|---|---|---|---|
| P1 — 2.3.2 dòng 59: getter biến đổi “có thể trả về bản sao” | R5, 0.24.3; R2 hiện hành | R5 nói các getter trả bản sao và debug có thể báo lỗi khi sửa không tới node; cách nói hiện tại quá mơ hồ để học API. R1 còn minh họa sửa localTransform tại chỗ kèm markTransformDirty, nên không sao chép máy móc giữa trang. | Thay hai câu đầu bằng: “Theo README 0.24.3, các getter thành phần biến đổi trả về bản sao. Ví dụ sử dụng `node.position = vm.Vector3(0, 1, 0)` để gán lại; khi đổi ma trận, ưu tiên gán một `localTransform` mới và đối chiếu API của phiên bản đã khóa.” |
| P1 — 2.3.3 dòng 63: vòng đời tóm tắt, thiếu hook | R1 hiện hành | Thiếu onDetach và điều kiện update chờ onLoad; người đọc chưa đủ thông tin để viết component. Widget ghi đè thuộc tính là vấn đề ownership riêng. | Bổ sung thứ tự tài liệu: `onAttach → onLoad → onMount → update/fixedUpdate → onUnmount → onDetach`; giải thích onLoad thiết lập bất đồng bộ một lần, update chờ hoàn tất, update theo frame và fixedUpdate theo bước vật lý. Đây là mô tả tài liệu, chưa thử tái gắn node. |
| P1 — 2.10 bước 4: “chờ tài nguyên engine cần thiết sẵn sàng” | R5 0.24.3; R1 hiện hành | Mã giả được gắn nhãn đúng nhưng bỏ tên bước khởi tạo dễ khiến người đọc tạo geometry/material quá sớm. | Sau câu này thêm: “Ví dụ khối cơ bản của 0.24.3 chờ `Scene.initializeStaticResources()` trước khi tạo geometry/material; kiểm tra widget còn mounted trước setState sau await.” Giữ nhãn chưa compile; không biến mã giả thành ví dụ Dart đã chạy. |
| P1 — 2.2 dòng 39–41 và 2.10 bước 3: GPU/Impeller trên Android | R4/R5; R8 Flutter 3.47 | Điều kiện phiên bản và cờ GPU đúng tài liệu Scene. Tuy nhiên nguồn Flutter nêu Impeller mặc định Android API 29+, thiết bị thấp hơn/không Vulkan có fallback legacy OpenGL. Không suy ra mọi Android đủ điều kiện Scene. | Bổ sung sau dòng 41: “Bật Flutter GPU khác với bật Impeller. Cần ghi Android API, GPU và backend thực tế; fallback đồ họa Flutter không tự chứng minh Flutter GPU/Scene hoạt động trên máy đó.” Nếu viết XML, dùng đúng metadata `io.flutter.embedding.android.EnableFlutterGPU` với `android:value="true"` trong `<application>`. |
| P2 — 2.6.2: parsedAnimations/createAnimationClip, engine tiến clip | R3 hiện hành | Đúng tài liệu. Cần phân biệt Animation dữ liệu với AnimationClip trạng thái và xử lý tên clip không tồn tại trước khi chép ví dụ dùng dấu `!`. | Giữ nội dung; bổ sung: “Tra `findAnimationByName`, kiểm tra null rồi gọi `createAnimationClip`; clip không lặp tự pause ở keyframe cuối. Khi dùng vòng lặp do SceneView quản lý, không tự tiến cùng clip lần nữa.” |
| P2 — 2.7.1: SceneView quản lý loop; 2.8.1 PhysicsWorld | R1; R6 0.5.2 | Nội dung đúng nhưng ví dụ Rapier dùng scene.update rồi scene.render thuộc vòng lặp thủ công; ghép vào SceneView có nguy cơ cập nhật kép. | Giữ cảnh báo hiện có. Hướng dẫn bổ sung nên chọn một trong hai: SceneView quản lý hoặc vòng lặp thủ công gọi update/render. Với Rapier, nêu `RapierWorld.ensureInitialized()`, PhysicsWorld ở scene.root, body trước collider; chưa tuyên bố fixed timestep chứng minh tất định. |
| P2 — 2.7.2: scene.raycast chọn đối tượng | R7 hiện hành | Đúng tên API nhưng chưa nói đủ phạm vi render picking so với collider. | Thêm sau câu đầu về kết quả: “`Scene.raycast` kiểm tra hình học render; query thế giới vật lý kiểm tra collision shapes. Chọn đối tượng hiển thị và xử lý đạn/va chạm có thể cần hai truy vấn khác nhau.” Giữ kích thước SceneView làm hệ tham chiếu. |
| P2 — 2.1: Godot/Flame/Scene và Basketball Stars | R9; HT01–HT04 kế thừa | Bản hiện tại đã tách công cụ phát triển và game cùng thể loại, không đánh đồng đối tượng so sánh. R9 chỉ chứng minh multiplayer mobile và thao tác quảng bá. | Giữ 2.1.1/2.1.2. Không suy từ R9 thành 1v1 nửa sân, kiến trúc server hay thuật toán ném; chỉ bổ sung quan sát UI sau khi có ảnh/phiên bản/nguồn hợp lệ. Không xếp hạng hiệu năng engine. |

## Kết quả rà soát và việc còn mở

Các vấn đề chính là thiếu độ cụ thể ở hướng dẫn API, chưa có bằng chứng lỗi compile hay lỗi engine. Ưu tiên chỉnh getter, lifecycle, khởi tạo tài nguyên và điều kiện Android. Luật tính điểm, quyền giữ bóng và mạng vẫn thuộc logic game; animation/physics/rendering không tự thực thi luật bóng rổ.

Tự rà soát: các sửa đề xuất có vị trí và nguồn; không thêm kết quả thử; nguồn kế thừa tách riêng; ngôn ngữ và định danh nhất quán. Đóng góp của lượt này là đối chiếu tài liệu, không phải thực nghiệm. Còn cần kiểm tra API theo lockfile, đối chiếu lifecycle bằng source phiên bản được chọn và compile ví dụ tối giản khi được giao. Lead/thesis tích hợp các sửa cần thiết, giữ Chương 1–3 trước giữa kỳ; Chương 4–5 chờ bằng chứng.
