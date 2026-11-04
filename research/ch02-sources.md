# Hồ sơ nguồn cho bản sơ bộ Chương 2

Ngày khảo sát: 2026-11-04. Không cài dependency, không chạy ví dụ, không benchmark. Chỉ đọc tài liệu. Nguồn LT01 đã đọc trong phiên Lead ngày 2026-11-03; không giả định lần truy cập hôm nay thành công. LT02 đọc bằng web; LT03–LT12 (trừ LT01/02) đọc nội dung HTML công khai qua PowerShell Invoke-WebRequest, bỏ thẻ để đọc; trang có một số ký tự UTF-8 bị hiển thị sai ở dấu câu tiếng Anh, các tên API được đọc trực tiếp.

| Mã | Nguồn | Phiên bản/phạm vi | Luận điểm được hỗ trợ và giới hạn |
|---|---|---|---|
| LT01 | https://fscene.dev/getting-started/installation/ | Tài liệu đã đọc 03/11/2026 | Flutter ≥3.47, cấu hình GPU Android; cần đối chiếu khi resolve dependency |
| LT02 | https://pub.dev/packages/flutter_scene | 0.24.3 | Tên engine, nền tảng, API khởi đầu, pre-1.0; không chứng minh khả năng thiết bị |
| LT03 | https://fscene.dev/getting-started/core-concepts/ | Trang hiện hành | Scene/Node/Component/Mesh/Camera, vòng đời và SceneView; chưa compile ví dụ |
| LT04 | https://fscene.dev/guides/scene-graph/ | Trang hiện hành | Phân cấp, local/world transforms, component; không xác nhận thiết kế game |
| LT05 | https://fscene.dev/guides/materials/ | Trang hiện hành | PBR, unlit, texture slots, tái sử dụng; chưa đo chi phí GPU |
| LT06 | https://fscene.dev/guides/cameras/ | Camera primary/default ghi mốc ≥0.19 | PerspectiveCamera, cameraBuilder, CameraComponent; chưa thử góc nhìn |
| LT07 | https://fscene.dev/guides/lighting-and-environment/ | Trang hiện hành | Môi trường, skybox, directional light, exposure; không benchmark |
| LT08 | https://fscene.dev/guides/assets-and-loading/ | Trang hiện hành | GLB runtime/build, loadScene, loading; không xác minh mọi extension glTF |
| LT09 | https://fscene.dev/guides/animation/ | Trang hiện hành | parsedAnimations, clip, playback và blending; chưa thử mô hình |
| LT10 | https://fscene.dev/guides/picking-and-input/ | Trang hiện hành | screenPointToRay, scene.raycast và khác biệt render/physics queries |
| LT11 | https://pub.dev/packages/flutter_scene_rapier | 0.5.2 | PhysicsWorld, body trước collider, fixed timestep, binary hỗ trợ; API experimental |
| LT12 | https://pub.dev/packages/flutter_scene_net | 0.2.2 | Replica/node, transform interpolation, in-app native host; chưa chứng minh NAT/relay/Internet |

## Giới hạn cần giữ khi biên tập

Nguồn bổ sung cho mục 2.1, đọc ngày 04/11/2026:

| Mã | Nguồn | Luận điểm và giới hạn |
|---|---|---|
| HT01 | https://docs.godotengine.org/en/stable/about/introduction.html | Engine 2D/3D và môi trường biên tập; không benchmark |
| HT02 | https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html | Có quy trình export Android; không xác nhận máy cụ thể |
| HT03 | https://flame-engine.org/ | Flame trong hệ sinh thái Flutter; không suy ra toàn bộ tính năng 3D |
| HT04 | https://github.com/flame-engine/flame/blob/main/packages/flame_3d/README.md | flame_3d thử nghiệm; không kết luận Flame chỉ hỗ trợ 2.5D |
| HT05 | https://www.miniclip.com/games/basketball-stars/ | Nhà phát hành giới thiệu game bóng rổ multiplayer mobile; không có cơ sở suy đoán thuật toán/kiến trúc bên trong |

- Không ghi các bước hướng dẫn là “đã thực hiện”. Toàn bộ walkthrough là quy trình đề xuất để chạy sau.
- Những nhận xét về ma trận, thời gian, quyền quyết định trạng thái, kiểm tra lỗi và lưu bằng chứng là phần giải thích/phương pháp của bản thảo; không quy chúng thành tính năng tự động của Scene.
- Không xem fixed timestep là bằng chứng tất định đa nền tảng.
- Không xem SceneHost là giải pháp NAT traversal.
- Chưa chọn Rapier hoặc `flutter_scene_net` làm dependency cuối.
- Có thể mở rộng chương bằng hình thực nghiệm và đoạn mã đã compile sau khi có sản phẩm; hiện chưa dùng hình dựng giả làm ảnh chạy.
