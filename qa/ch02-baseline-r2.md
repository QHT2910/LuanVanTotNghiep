# Rà soát baseline Chương 2 — 05/11/2026

Nguồn: báo cáo Orca Worker tester bkm37d3uiwhgp757im7y9hov trong lượt R2. Đây là rà tài liệu hiện hành, chưa nghiệm thu bản R2. Không chạy game/build hoặc kiểm chứng lại môi trường.

| Nhóm | Thiếu ở bản trước | Yêu cầu bản mới |
|---|---|---|
| Pipeline, 2.2 | Chỉ phân vai Flutter/Scene/GPU/Impeller | Luồng vertex–clip–raster–fragment–depth/blend–framebuffer, đầu vào/ra và hình |
| Toán, 2.3 | Chưa công bố quy ước | Vector thuần nhất, local/world/view/clip/NDC, PVM, chia w, viewport; đơn vị và thứ tự nhân |
| Scene graph, 2.3 | Chuyển nhanh sang API | Transform cha–con, ownership, một nơi ghi transform, giữ local/world pose khi đổi cha |
| Mesh/PBR, 2.4 | Thiếu cấu trúc và phản xạ | Vertex/index/normal/UV/tangent/winding; diffuse/specular, roughness, texture màu/dữ liệu |
| Camera/light, 2.5 | Thiếu cơ sở phép chiếu | View/frustum/FOV/aspect/near/far/depth; direct light/IBL/shadow/tone mapping |
| Asset/animation, 2.6 | Chủ yếu tên API | glTF/GLB, accessor/buffer, keyframe/channel/sampler, skin/inverse bind, blending vs retargeting |
| Loop/input, 2.7 | Thiếu mô hình thời gian | Accumulator, fixed timestep, backlog/interpolation; widget/NDC/ray; held vs edge input |
| Physics, 2.8 | Chủ yếu quy trình Rapier | Động học/tích phân/sai số, broad/narrow phase, contact/trigger, discrete/sweep/CCD |
| Netcode, 2.9 | Thiếu mô hình thông điệp | Authority/input/seq/ack/tick/snapshot, prediction/reconciliation/interpolation, RTT/jitter |
| Mobile perf | Nội dung rải rác | CPU/GPU bottleneck, budget=1000/FPS, draw calls/overdraw/memory/GC, profile/release/thermal |

Các sửa thuật ngữ: công bố vector cột trước W_child=W_parent L_child; không biểu diễn lifecycle như chuỗi chỉ đi một lần; roughness là phân bố vi bề mặt; directional light không tự đồng nghĩa shadow; GLB là container glTF; giới hạn blending theo loại kênh/rig; delta time không loại bỏ sai số; ray cần quy ước tọa độ; mô phỏng số cập nhật rời rạc.

Chuyển thao tác/API ở 2.2–2.9 xuống hướng dẫn cuối chương. Giữ ví dụ tính toán và công thức trong lý thuyết. Không đưa chính sách game riêng vào Ch2.

Nghiệm thu R2: công thức có ký hiệu/đơn vị/giả định; một project xuyên suốt với tiền đề và file sửa; đúng lockfile Scene 0.24.3; nguồn hỗ trợ đúng claim; video ghi mức truy cập thật; analyze/bundle không chứng minh Android và localhost không chứng minh Internet; không tự đặt FPS/RTT đạt. Giữ Word v0.3, xuất bản mới và đối chiếu citation/hình/số mục.

Giới hạn: chưa có công thức sai cụ thể được chứng minh vì bản cũ hầu như chưa có công thức. QA chỉ kế thừa evidence R1, không chạy lại. Get-Content/rg đọc thành công; không tạo log do nhiệm vụ chỉ đọc, bằng chứng gốc ở transcript worker. Toàn văn báo cáo gốc được giữ trong cuộc trao đổi, không sao chép tool output vào checkpoint.
