# Hình lý thuyết Chương 2 R2

Nguồn thiết kế: Orca Worker diagrams ub7cjeu5ajbo6e9kxn475jsn, 05/11/2026; Lead lưu và rút gọn nhãn từ bàn giao. Sáu nguồn 2-*-r2.mmd có PNG cùng tên. Chưa tích hợp Word hoặc kiểm tra nhãn ở kích thước trang cuối.

| Hình | Nội dung và căn cứ | Giới hạn |
|---|---|---|
| rendering-layers | Lớp native Scene–Flutter GPU–Impeller–GPU; https://docs.flutter.dev/perf/impeller | Không phải timeline/thread, không gồm WebGL2 |
| mvp-spaces | Local/world/view/clip; https://learnopengl.com/Getting-started/Coordinate-Systems | Vector cột PVM; chưa gồm chia w/viewport, không áp quy ước OpenGL lên Scene |
| scenegraph-transform | World con = world cha × local con; https://fscene.dev/guides/scene-graph/ | Root không mặc định identity; không biểu diễn cache |
| lifecycle-ownership | Mã package flutter_scene 0.24.3, component.dart/scene_view.dart/scene.dart | Đường mount/load thành công, không phải state machine đầy đủ |
| fixed-render-interpolation | https://gafferongames.com/post/fix_your_timestep/ | Hiển thị nội suy không ghi ngược mô phỏng; không chứng minh tất định |
| network-snapshot-timeline | https://www.gabrielgambetta.com/entity-interpolation.html và https://gafferongames.com/post/snapshot_interpolation/ | Các timestamp cùng miền giờ server; không giả định một input–một snapshot |

Lead đối chiếu cache 0.24.3: mount() gọi onMount() trước onLoad(); evidence cục bộ .scratch/r2-lifecycle-source.log. onLoad hoàn tất khi còn mounted mới đặt loaded. Không coi đồ thị lifecycle là tất cả nhánh remount/lỗi. Scene.dispose bỏ tham chiếu render target Scene giữ; không suy mọi tài nguyên GPU chia sẻ bị hủy đồng bộ.

Render: lần mặc định thiếu Chromium phù hợp; dùng cấu hình Puppeteer có sẵn trong .scratch/puppeteer.json, không cài browser mới. PASS mmdc cả sáu nguồn, log .scratch/r2-diagram-render-retry.log. Không chạy game hoặc build. Cần rà trực quan và caption trong Word trước nghiệm thu.
