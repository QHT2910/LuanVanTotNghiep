--- KẾT THÚC VĂN BẢN 2.1–2.11; PHẦN DƯỚI CHỈ LÀ BÀN GIAO NỘI BỘ ---

Bố cục R2 đề xuất theo giao việc (chưa sửa OUTLINE trên đĩa):
2.1 Các hệ thống tương tự
2.2 Nền tảng Flutter Scene và pipeline kết xuất
2.3 Cơ sở toán học của không gian 3D
2.4 Đồ thị cảnh, thành phần và vòng đời
2.5 Hình học, vật liệu và shader
2.6 Camera, ánh sáng và môi trường
2.7 Tài nguyên, mô hình và hoạt ảnh
2.8 Vòng lặp, nhập liệu và giao diện hiển thị
2.9 Chuyển động và mô phỏng vật lý
2.10 Kết nối và đồng bộ trạng thái thời gian thực
2.11 Hiệu năng và giới hạn đánh giá
2.12 Hướng dẫn riêng cuối chương: developer chuẩn bị; chưa đưa walkthrough mới vào sản phẩm thesis này.

Nguồn bổ sung đã mở thành công ngày 05/11/2026, dùng nhãn chờ Lead append sau [19], không đánh số lại Ch1/3:
- [M-PIPELINE] Khronos, Vulkan Specification, “Pipelines”, bản latest: https://docs.vulkan.org/spec/latest/chapters/pipelines.html . Hỗ trợ nguyên lý primitive/vertex processing, rasterization, fragment và framebuffer; không chứng minh Scene 0.24.3 cung cấp mọi stage hay API Vulkan. Đã mở bằng web.
- [M-GLTF] Khronos 3D Formats Working Group, glTF 2.0 Specification, trang hiển thị version 2.0.1 (2021-10-11): https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html . Hỗ trợ cấu trúc nội dung và phân biệt glTF/GLB; không suy ra mọi extension được Scene hỗ trợ. Đã mở bằng web.
- [M-TIME] Glenn Fiedler, “Fix Your Timestep!”, 10/06/2004: https://gafferongames.com/post/fix_your_timestep/ . Nguồn tác giả gốc cho fixed/variable timestep, accumulator và nguy cơ spiral of death; không phải bằng chứng tất định Scene. Đã mở bằng web.
- [M-RAPIER] Rapier, “Rigid-bodies”, User Guide JavaScript 0.21: https://rapier.rs/docs/user_guides/javascript/rigid_bodies/ . Hỗ trợ khác biệt body/collider và dynamic/fixed/kinematic; chỉ lấy nguyên lý, không sao chép API JS sang Dart binding 0.5.2. Đã mở bằng web.
- [M-NET-A] Gabriel Gambetta, “Fast-Paced Multiplayer (Part I): Client-Server Game Architecture”: https://www.gabrielgambetta.com/client-server-game-architecture.html . Hỗ trợ mô hình authoritative, lệnh và kết quả; không chứng minh chống gian lận hoàn chỉnh. Đã mở bằng web; không tự đặt năm công bố khi trang không nêu trong phần đọc.
- [M-NET-B] Gabriel Gambetta, “Fast-Paced Multiplayer (Part II): Client-Side Prediction and Server Reconciliation”: https://www.gabrielgambetta.com/client-side-prediction-server-reconciliation.html . Hỗ trợ prediction, acknowledgement/replay/reconciliation; không khẳng định game đã triển khai. Đã mở bằng web.
- [M-NET-C] Gabriel Gambetta, “Fast-Paced Multiplayer (Part III): Entity Interpolation”: https://www.gabrielgambetta.com/entity-interpolation.html . Hỗ trợ interpolation, thời điểm hiển thị trễ và giới hạn ngoại suy; không tự chọn buffer 100 ms hoặc tick cụ thể. Đã mở bằng web.
- [M-PERF] Flutter, “Flutter performance profiling”: https://docs.flutter.dev/perf/ui-performance . Hỗ trợ thiết bị thật/profile/DevTools và phân biệt debug; không coi UI graph là toàn bộ phép đo tải Scene. Đã mở bằng web.

Ngày đọc [1]–[19] vẫn theo REFERENCES hiện hành. Không nâng nguồn kế thừa thành lượt đọc ngày 05/11. Không dùng các URL mở lỗi làm nguồn trong manuscript.

Reverse-outline và vai trò đoạn, ngoài manuscript:
- 2.1: định nghĩa tiêu chí công cụ → đối chiếu Godot/Flame/Scene theo nguồn → tách sản phẩm Basketball Stars → giới hạn khảo sát. Vai trò: bối cảnh và lý do chọn đối tượng nghiên cứu; không xếp hạng.
- 2.2: phân lớp Flutter/Scene/GPU → quá trình từ dữ liệu tới ảnh → phân công CPU/GPU → backend và điều kiện Android. Vai trò: giải thích vị trí công nghệ trước API.
- 2.3: đại lượng và hệ quy chiếu → phép toán vector → tọa độ thuần nhất/TRS → phân cấp transform → biểu diễn xoay → MVP/clip/viewport. Vai trò: cơ sở toán cho các mục cảnh/camera/picking, mỗi công thức ghi điều kiện.
- 2.4: cấu trúc cảnh → quan hệ không gian so với logic → lifecycle → quyền cập nhật → vòng đời tài nguyên. Vai trò: giải thích mô hình đối tượng và phụ thuộc.
- 2.5: dữ liệu đỉnh/index/mesh → pháp tuyến → shader/material → PBR → texture → chi phí. Vai trò: giải thích bản chất biểu diễn bề mặt.
- 2.6: camera/hệ nhìn → phối cảnh/trực giao → thể tích cắt → chiếu sáng → môi trường/bóng/exposure. Vai trò: quan hệ hình học với ảnh quan sát.
- 2.7: cấu trúc tài nguyên → pipeline runtime/build → nạp và bộ nhớ → keyframe/nội suy → dữ liệu/clip → hòa trộn và logic. Vai trò: biểu diễn theo thời gian và quản lý tài nguyên.
- 2.8: nhịp mô phỏng/nhịp vẽ → timestep/accumulator/quá tải → input thành lệnh → trạng thái giữ/cạnh → picking → HUD và một vòng lặp. Vai trò: tổ chức thời gian và tương tác.
- 2.9: phương trình chuyển động → tích phân số → body/collider → tìm tiếp xúc/giải phản lực → giới hạn rời rạc → biến sự kiện vật lý thành luật. Vai trò: nền tảng mô phỏng, không chốt backend.
- 2.10: authority → lệnh/snapshot/ack → tần suất/băng thông → prediction/reconciliation → interpolation → RTT/jitter/session/Internet. Vai trò: giải thích cơ chế mạng và điều kiện áp dụng.
- 2.11: ngân sách frame → nút thắt CPU/GPU → tải geometry/fragment/memory → thiết kế phép đo → giới hạn suy luận từ analyze/build/run. Vai trò: cơ sở đánh giá; không điền kết quả dự án.

Claim review:
| Nhóm khẳng định | Nguồn / bằng chứng | Trạng thái và điều cần làm tiếp |
|---|---|---|
| Godot/Android, Flame/flame_3d, Scene | [1], [3]–[7], [10] | Nguồn R1 kế thừa, không có benchmark so sánh |
| Basketball Stars multiplayer và thao tác quảng bá | [8] | Không suy kiến trúc, half-court hay thuật toán ném |
| Scene native/GPU, Android, Impeller | [2], [7], [9], [10] | Cần đối chiếu backend trên Redmi thực; build không chứng minh render |
| Pipeline đồ họa tổng quát | M-PIPELINE | Có nguồn chính thức; không gán mọi stage thành Scene feature |
| Vector, TRS, normal matrix, Euler/quaternion, MVP | [11] hỗ trợ local/world; các phương trình là diễn giải toán tiêu chuẩn trong bản soạn | Công thức tự kiểm tra về điều kiện/đơn vị; cần research bổ sung giáo trình đồ họa/toán 3D có trang/mục cho quyển nộp. Không gán [11] là nguồn bao trùm toàn bộ công thức |
| Lifecycle, ownership, getter copy | [7], [10], [11] và verification-r1 | Chưa thử đầy đủ lifecycle; không chép ví dụ tài liệu thành đã chạy |
| Mesh/material/PBR/texture | [10], [12] | [12] kế thừa; chưa benchmark shader, không khẳng định mọi tùy biến shader có API |
| Camera/light/environment | [13], [14] | Nguồn kế thừa; công thức x'=fx/z và cosine là mô hình giản lược, chưa phải shader Scene cụ thể |
| Tài nguyên/glTF/GLB/animation | [7], [15], [16], M-GLTF | Hỗ trợ nguyên lý; chưa thử model/extension, không coi mọi ví dụ đã compile |
| Timestep/accumulator | M-TIME, [10] | Chưa chứng minh tất định; cần source/binding theo lockfile cho tutorial |
| Picking | [18] | Tách render query và collision query; chưa chạy thao tác thực |
| Vật lý/body/collider | [17], M-RAPIER | Nguồn JS chỉ nguyên lý; Euler bán ẩn là diễn giải phương pháp, cần giáo trình/source chuyên môn bổ sung cho quyển nộp |
| Netcode | [19], M-NET-A/B/C | Cơ chế lý thuyết; không chốt giao thức, tham số, hosting hoặc NAT traversal |
| Frame budget và đo | M-PERF; T=1000/f là đổi đơn vị | Không có dữ liệu benchmark mới; các phân tích overdraw/thermal/CPU-GPU cần đối chiếu profiler khi có sản phẩm |

Tự phản biện theo năm chiều:
1. Đóng góp: chương cung cấp nền tảng giải thích thành phần; không tuyên bố thuật toán mới hoặc lợi thế thực nghiệm.
2. Mạch văn: sắp toán trước graph, vật liệu trước camera/light, thời gian trước vật lý/netcode; hướng dẫn không trộn vào các mục lý thuyết.
3. Thực nghiệm: không tạo kết quả mới. Chỉ hồ sơ hiện có xác nhận probe Scene 0.24.3 analyze/build bundle và loopback; không đưa thành game đã chạy.
4. Đánh giá: mục hiệu năng mô tả phương pháp; chưa có phép so sánh engine hoặc số liệu điện thoại.
5. Thiết kế: quyền cập nhật, frame loop, authority và phân biệt render/physics được làm rõ; kiến trúc và ngưỡng thuộc Ch3 hoặc quyết định sau.

Kiểm chứng thực chạy, một dòng command/pass-fail/logpath:
- Get-Content -LiteralPath D:/totnghiep/LuanVanTotNghiep/{AGENTS.md,PROJECT_BRIEF.md,docs/CONTEXT_HANDOFF.md,thesis/OUTLINE.md,research/ch02-sources.md,research/verification-r1.md,thesis/REFERENCES.md} -Encoding UTF8 | PASS (đọc từng path trong cùng tool call) | logpath: không ghi log vì nhiệm vụ chỉ đọc.
- Get-Content -LiteralPath D:/totnghiep/LuanVanTotNghiep/CURRENT_STATUS.md -Encoding UTF8 | FAIL: file not found; corrected to docs/CURRENT_STATUS.md | logpath: none; read-only task.
- Get-Content -LiteralPath D:/totnghiep/LuanVanTotNghiep/docs/CURRENT_STATUS.md -Encoding UTF8 | PASS | logpath: không ghi log.
- web.open: M-PIPELINE/M-GLTF/M-TIME/M-RAPIER/M-NET-A/B/C/M-PERF | PASS (có nội dung) | logpath: không ghi; chỉ tool transcript.
- web.open: Valve Source Multiplayer Networking / Unity clients-and-servers / Vulkan tutorial path | FAIL: 403 or inaccessible; excluded as sources | logpath: none; no files written.
- JS in-memory content checks: section sequence 2.1–2.11; no bold/internal paths/code walkthrough; numeric references within [1]–[19]; formulas present | PASS | logpath: không ghi; kết quả trong tool transcript.
- Build/analyze/render/game test/git/commit/push | NOT RUN trong R2 thesis | logpath: không có log mới.

Sản phẩm bàn giao: toàn văn 2.1–2.11 ở trên, bố cục đề xuất, danh sách tám nguồn bổ sung có nhãn, reverse-outline và claim review; tất cả gửi qua báo cáo, không ghi tệp ở root nào.
Bằng chứng: hồ sơ dự án và nguồn R1, tám trang nguồn mở thành công, kiểm tra nội dung trong bộ nhớ; không nhận là kiểm thử game.
Điểm chưa rõ: 2.12 do developer cung cấp; còn cần nguồn giáo trình cho phần toán/tích phân và đối chiếu backend thực/lockfile; dữ liệu R1 chưa chứng minh render Android.
Bước tiếp theo: Lead lưu bản R2 mới, ghép 2.12, append các nhãn nguồn sau [19], cập nhật OUTLINE theo quyết định R2 và giữ nguyên Word v0.3. Lead có thể chuyển research rà phần toán và nguồn mới trước khi dựng Word mới.

