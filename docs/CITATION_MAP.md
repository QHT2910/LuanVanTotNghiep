# Ánh xạ trích dẫn R1

Ngày biên tập: 04/11/2026. Cấp số theo lần xuất hiện đầu tiên; URL trùng dùng chung số. Không coi biên tập là truy cập web mới.

| Mã cũ | Mã số | URL | Ngày đọc kế thừa |
|---|---|---|---|
| SCENE-01 | [1] | https://fscene.dev/getting-started/ | 03/11/2026 |
| SCENE-02 | [2] | https://fscene.dev/getting-started/installation/ | 03/11/2026 |
| LT01 | [2] | https://fscene.dev/getting-started/installation/ | 03/11/2026 (khảo sát đầu); 04/11/2026 (lượt đọc Chương 2) |
| LT02 | [7] | https://pub.dev/packages/flutter_scene | 04/11/2026 |
| LT03 | [10] | https://fscene.dev/getting-started/core-concepts/ | 04/11/2026 |
| LT04 | [11] | https://fscene.dev/guides/scene-graph/ | 04/11/2026 |
| LT05 | [12] | https://fscene.dev/guides/materials/ | 04/11/2026 |
| LT06 | [13] | https://fscene.dev/guides/cameras/ | 04/11/2026 |
| LT07 | [14] | https://fscene.dev/guides/lighting-and-environment/ | 04/11/2026 |
| LT08 | [15] | https://fscene.dev/guides/assets-and-loading/ | 04/11/2026 |
| LT09 | [16] | https://fscene.dev/guides/animation/ | 04/11/2026 |
| LT10 | [18] | https://fscene.dev/guides/picking-and-input/ | 04/11/2026 |
| LT11 | [17] | https://pub.dev/packages/flutter_scene_rapier | 04/11/2026 |
| LT12 | [19] | https://pub.dev/packages/flutter_scene_net | 04/11/2026 |
| HT01 | [3] | https://docs.godotengine.org/en/stable/about/introduction.html | 04/11/2026 |
| HT02 | [4] | https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html | 04/11/2026 |
| HT03 | [5] | https://flame-engine.org/ | 04/11/2026 |
| HT04 | [6] | https://github.com/flame-engine/flame/blob/main/packages/flame_3d/README.md | 04/11/2026 |
| HT05 | [8] | https://www.miniclip.com/games/basketball-stars/ | 04/11/2026 |
| IMP01 | [9] | https://docs.flutter.dev/perf/impeller | 04/11/2026 |

## Metadata và giới hạn nguồn kế thừa

- SCENE-01 → [1]: Flutter Scene, *Welcome to Scene*, https://fscene.dev/getting-started/ . Nguồn đã được nhóm đọc ngày 03/11/2026; hỗ trợ nhận diện engine và các thành phần, không chứng minh kết quả demo.
- SCENE-02 → [2]: Flutter Scene, *Installation*, https://fscene.dev/getting-started/installation/ . Nguồn đã được nhóm đọc ngày 03/11/2026; hỗ trợ mô tả nền tảng và điều kiện cấu hình. Cần đối chiếu lại khi chọn phiên bản triển khai.
- LT01 → [2]: Flutter Scene, *Installation*: https://fscene.dev/getting-started/installation/ (đã đọc ngày 03/11/2026 trong khảo sát ban đầu; yêu cầu phiên bản cần kiểm tra khi triển khai).
- LT02 → [7]: Flutter Scene, gói `flutter_scene`, 0.24.3: https://pub.dev/packages/flutter_scene.
- LT03 → [10]: Flutter Scene, *Core concepts*: https://fscene.dev/getting-started/core-concepts/.
- LT04 → [11]: Flutter Scene, *Scene graph*: https://fscene.dev/guides/scene-graph/.
- LT05 → [12]: Flutter Scene, *Materials*: https://fscene.dev/guides/materials/.
- LT06 → [13]: Flutter Scene, *Cameras*: https://fscene.dev/guides/cameras/.
- LT07 → [14]: Flutter Scene, *Lighting and environment*: https://fscene.dev/guides/lighting-and-environment/.
- LT08 → [15]: Flutter Scene, *Assets and loading*: https://fscene.dev/guides/assets-and-loading/.
- LT09 → [16]: Flutter Scene, *Animation*: https://fscene.dev/guides/animation/.
- LT10 → [18]: Flutter Scene, *Picking and input*: https://fscene.dev/guides/picking-and-input/.
- LT11 → [17]: Gói `flutter_scene_rapier`, 0.5.2: https://pub.dev/packages/flutter_scene_rapier.
- LT12 → [19]: Gói `flutter_scene_net`, 0.2.2: https://pub.dev/packages/flutter_scene_net.
- HT01 → [3]: Godot Engine, Introduction. https://docs.godotengine.org/en/stable/about/introduction.html. Truy cập ngày 04/11/2026.
- HT02 → [4]: Godot Engine, Exporting for Android. https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html. Truy cập ngày 04/11/2026.
- HT03 → [5]: Flame, trang chính thức. https://flame-engine.org/. Truy cập ngày 04/11/2026.
- HT04 → [6]: Flame, tài liệu flame_3d. https://github.com/flame-engine/flame/blob/main/packages/flame_3d/README.md. Truy cập ngày 04/11/2026.
- HT05 → [8]: Miniclip, Basketball Stars. https://www.miniclip.com/games/basketball-stars/. Truy cập ngày 04/11/2026.
- IMP01 → [9]: Flutter, Impeller rendering engine. https://docs.flutter.dev/perf/impeller. Truy cập ngày 04/11/2026.

## Ánh xạ khẳng định theo research/verification-r1.md

| Vị trí / khẳng định sửa | Nguồn | Trạng thái |
|---|---|---|
| 2.3.2: getter trả bản sao, gán transform theo 0.24.3 | [7], [11] | Tài liệu; chưa chạy |
| 2.3.3: đầy đủ lifecycle, update chờ onLoad | [10] | Tài liệu; chưa thử tái gắn |
| 2.10 bước 4: initializeStaticResources, mounted sau await | [7], [10] | Tài liệu; chưa compile |
| 2.2 / 2.10 bước 3: GPU khác Impeller, backend Android | [2], [9] | Chưa xác minh thiết bị |
| 2.6.2: Animation/AnimationClip, null, pause, một loop | [16] | Tài liệu; chưa chạy |
| 2.7.1 / 2.8.1: một loop, RapierWorld, body trước collider | [10], [17] | Tài liệu; chưa chạy |
| 2.7.2: render raycast khác collision query | [18] | Tài liệu; chưa chạy |

R8 trong báo cáo research ánh xạ IMP01 ở bảng trên. Không đưa mã R1–R9 vào manuscript. LT05–LT08, LT12 và HT01–HT04 chưa đọc lại trong R1; giữ trạng thái kế thừa. LT01 giữ cả ngày đọc 03/11 và 04/11.

## Tự rà soát

- Bố cục: 1.1.2 đúng tên; 2.1–2.10 và 3.1/3.2/3.3 giữ nguyên; không thêm mục chương.
- Truy vết: thay mã cũ, mở đủ dải LT10–LT12; giữ nguồn và khẳng định. Danh mục chung ở REFERENCES.md để Lead gắn cuối bản tổng hợp.
- Đóng góp còn ở mục tiêu nghiên cứu và thiết kế dự kiến. Văn phong trung tính; không thêm nhấn đậm hoặc viết hoa toàn bộ.
- Thực nghiệm: chưa compile, chạy, đo hay chứng minh hai Android; chưa thể kết luận đánh giá đầy đủ.
- Thiết kế còn cần kiểm chứng; UC08 được Lead duyệt thuộc F01. Bảng Player/Ball chỉ tổng hợp luật đã có, không tự đặt ngưỡng, chính sách rời trận và guard còn mở.
- Tất cả khối Mermaid giữ nguyên; không sửa source hình 3-2 hoặc UI. Lead sẽ tích hợp sơ đồ mới.
- Không chạy git, Word render, commit/push.
