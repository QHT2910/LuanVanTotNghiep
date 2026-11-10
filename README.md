# Luận văn Flutter Scene — bản làm việc

Nghiên cứu Flutter Scene và ứng dụng xây dựng demo game bóng rổ đối kháng 3D trên Android, ưu tiên hai người qua Internet.

Ưu tiên hiện tại: demo từng phần trên giả lập; luận văn sửa song song sau. [Tập offline mốc1](game/offline-practice/README.md) đã có APK debug và bằng chứng trên một Pixel_9a; [báo cáo kiểm chứng](docs/MILESTONE_1_REVIEW.md). Đây chưa phải multiplayer hoặc kết quả máy thật. Figma đã được chọn cho UI01–UI06, chưa có file/session; giao diện demo chỉ là UI tạm.

- [Bố cục sơ bộ](thesis/OUTLINE.md)
- [Chương 1 — Giới thiệu](thesis/01-gioi-thieu.md)
- [Chương 2 — Cơ sở lý thuyết](thesis/02-co-so-ly-thuyet.md)
- [Chương 3 — Xây dựng game](thesis/03-xay-dung-game.md)
- [Quy cách mẫu và kế hoạch](docs/QUY_CACH_VA_KE_HOACH.md)
- [Bản Word hiện hành v0.7 — bổ sung khai báo, loading và hot reload](thesis/Ban_thao_Chuong_1-3_v0.7.docx)
- [PDF v0.7](thesis/Ban_thao_Chuong_1-3_v0.7.pdf)
- [Báo cáo bổ sung từ video](docs/VIDEO_v0.7_REVIEW.md)
- [Bản lưu Word v0.6](thesis/Ban_thao_Chuong_1-3_v0.6.docx)
- [PDF v0.6 — bản dàn bằng Cindy để rà in](thesis/Ban_thao_Chuong_1-3_v0.6.pdf)
- [Báo cáo bản xuất v0.6 và giới hạn công cụ](docs/PUBLICATION_v0.6_REVIEW.md)
- [Bản lưu Word v0.5](thesis/Ban_thao_Chuong_1-3_v0.5.docx)
- [Bản lưu Word v0.4](thesis/Ban_thao_Chuong_1-3_v0.4.docx)
- [Báo cáo sửa theo review R3](docs/R3_REVIEW.md)
- [Bản lưu Word v0.3](thesis/Ban_thao_Chuong_1-3_v0.3.docx)
- [Báo cáo mở rộng Chương 2 R2](docs/R2_REVIEW.md)
- [Trạng thái hiện hành và bằng chứng](docs/CURRENT_STATUS.md)
- [Checkpoint tiếp tục dự án](docs/CONTEXT_HANDOFF.md)
- [Quy trình bảo toàn context](docs/CONTEXT_PROTOCOL.md)
- [Báo cáo lượt cải thiện R1](docs/R1_REVIEW.md)
- [Danh mục tài liệu tham khảo](thesis/REFERENCES.md)
- [Rà soát v0.2 và phần giao diện còn thiếu](docs/REVIEW_v0.2.md)
- [Trạng thái và phần cần hoàn thiện](docs/TRANG_THAI_BAN_THAO.md)
- [Lưu GitHub cuối phiên](docs/GITHUB_WORKFLOW.md)

Trạng thái: bản thảo sơ bộ theo bố cục sinh viên chỉ định, có thể thay đổi. Có probe và tập offline đã chạy trên một AVD; chưa có full game, kết quả Redmi hoặc bằng chứng hai Android/Internet. Chương 4–5 chờ sản phẩm. Bản này chưa sẵn sàng nộp.

Nguồn Mermaid và SVG UML trong `diagrams/` có thể chỉnh sửa. Tài liệu gốc trường, bản nháp tham khảo, cache và cấu hình cá nhân không đưa lên repo công khai.

Game dùng tên tạm Bóng rổ đối kháng 3D. Các tệp v0.1/v0.2 và wireframe 3-9 lưu lại để theo dõi lịch sử. Mục 3.3 cần bộ thiết kế bằng phần mềm bên thứ ba; Figma đã được sinh viên chọn; chưa có file/session hoặc bộ thiết kế chính thức. Xem [đặc tả UI](design/ui-spec-r1.md) và [kiểm chứng khả thi](game/feasibility-r1.md).
# Workspace phát triển

Mở `LuanVanTotNghiep.code-workspace` trong VS Code. Các root hiển thị: Game và demos (`game`, gồm probe/tutorial/offline/evidence), Thesis (`thesis`), UI (`design`), Research (`research`), QA (`qa`), Docs (`docs`), Tools (`tools`), Demo manifest (`demos`). Chỉ workspace settings ẩn build/.dart_tool/.scratch/.git; không đổi global settings.

`demos/README.md` ghi commit và APK từng mốc; APK M3a bảo toàn local dưới demos/releases (không Git). `docs/ROADMAP.md` ghi thứ tự công việc. Các nguồn lịch sử và evidence giữ nguyên; UI tạm không phải thiết kế Figma chính thức. Quy định trình bày mới ở `docs/THESIS_FORMAT_2026-11-09.md`, chưa xuất lại Word/PDF trong lượt tổ chức này.
