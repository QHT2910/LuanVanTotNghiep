# Phân công và quyền tích hợp

Lượt R1 tái sử dụng sáu worker đã tồn tại; không tạo bản trùng. Lead giữ GPT-6.1-Sol. Danh mục route có Gemini 4 Argon (`gemini-4-argon`, nguồn `google-gemini-api`), nhưng đổi riêng research bị automatic approval review từ chối vì thiếu xác nhận trực tiếp của người dùng. Research và các worker còn lại tiếp tục GPT-6.1-Sol; không thay mặc định ứng dụng.

| Vai trò | Sở hữu đầu ra | Phạm vi ghi trong lượt R1 |
|---|---|---|
| research | Khẳng định kỹ thuật, nguồn chính thức, phiên bản/API và giới hạn kiểm chứng | research/verification-r1.md |
| thesis | Văn bản, bố cục và hệ trích dẫn | Ba chương Markdown, thesis/REFERENCES.md, docs/CITATION_MAP.md |
| game-design | Luật, thao tác, đặc tả và đầu vào thiết kế UI | design/ui-spec-r1.md |
| diagrams | UML và truy vết từ đặc tả | Use case UML mới, ảnh và diagrams/traceability-r1.md |
| developer | Project kiểm chứng, build và log tái lập | game/feasibility-r1.md, probe/evidence riêng khi đủ môi trường |
| qa | Ca thử và rà soát bằng chứng độc lập | qa/review-r1.md |
| Lead | Tích hợp, trạng thái, bản tổng hợp/Word, kiểm tra và Git | tools/, docs/, README và sản phẩm tổng hợp |

Các worker không commit/push và không sửa chéo đầu ra. Lead chỉ áp dụng sửa kỹ thuật có nguồn hoặc hạ mức khẳng định khi bằng chứng chưa đủ. Một phần mô tả trong tài liệu không tự trở thành kết quả chạy thử.

Runtime của sáu worker vẫn lưu working directory cũ, còn nhiệm vụ hiện hành chỉ định đường dẫn tuyệt đối D:/totnghiep/LuanVanTotNghiep. Nếu worker không được ghi vào dự án hiện hành thì báo blocker; không ghi bản thay thế ở thư mục cũ hoặc sao chép đè cả workspace.

Figma được đề xuất, chưa được sinh viên chọn và chưa có dự án đang mở được kiểm chứng. UI cần nguồn công cụ bên thứ ba và ảnh xuất thật; không hợp thức hóa wireframe tự sinh bằng cách đổi nhãn công cụ.

Thực tế lượt R1: research, thesis và diagrams ghi được đầu ra ở thư mục đã tồn tại. Game-design, developer và QA không tạo được thư mục mới trong quyền worker; Lead thu báo cáo trả trực tiếp và tự lưu đầu ra trong workspace được phép. Probe/analyze/build/loopback do Lead chạy, không gán thành kết quả của developer hoặc QA. QA rà tài liệu độc lập, tám nhóm ca thử game chưa chạy.
