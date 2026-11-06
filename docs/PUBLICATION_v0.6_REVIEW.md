# Rà bản xuất v0.6

Ngày 06/11/2026. Phạm vi là sửa cách xuất bản sau nghiệm thu nội dung R3/v0.5; không chạy lại probe, thêm luật game hoặc đổi provider/model.

## Thay đổi

- Bộ build bỏ comment kỹ thuật sau xử lý hình. Validator Word/PDF bắt `<!--`, `diagram-svg:` và placeholder; hình UML 3.2 vẫn được nhúng.
- Chương 3 dùng caption 3.x. Bốn nhóm hình lớn được chia thành 15 panel dọc, giữ nguồn cũ. Các connector Q1–Q4, T/V/G/L/E/F có giải thích trong văn bản; guard, vòng lặp, thuộc tính và bội số được đối chiếu.
- Năm panel tuần tự được dựng SVG từ nguồn Mermaid bằng `tools/render-sequence-panels.cjs`. Nhãn được xuống dòng, mũi tên có đầu rõ; không dùng ảnh tăng độ phân giải để thay việc bố trí lại.
- Các hình lý thuyết có bố cục gọn hơn. Cỡ ảnh dựa trên cả chiều rộng và chiều cao; không phóng đầy trang mọi hình nhỏ.
- PBR và skinning dùng ba công thức OMML riêng cùng chỉ số toán. API có dấu gạch dưới vẫn là mã. FOV giữ dấu nhân × rõ ràng.
- Bảng ngắn được giữ theo nhóm, hàng không bị cắt; code dài chia ở mốc có nghĩa và có nhãn tiếp nối. Không giữ nguyên khối mã dài qua nhiều trang.

## Đầu ra và giới hạn

Nguồn hiện hành: `thesis/02-co-so-ly-thuyet.md`, `thesis/03-xay-dung-game.md` và bản tổng hợp. Bản Markdown v0.5 được lưu riêng; Word/PDF v0.5 không ghi đè. Word v0.3 có sửa ngoài lượt, phải loại khỏi staging.

Word mới: `thesis/Ban_thao_Chuong_1-3_v0.6.docx`; PDF cùng tên. Bìa, header và mục lục bản nộp chưa hoàn thiện; không tự điền thông tin cá nhân. Bộ thiết kế UI bên thứ ba và bằng chứng Android/Internet vẫn còn thiếu như hồ sơ R3.

## Kiểm tra cuối

Validator Word: PASS 37 nguồn, 27 ảnh, ba công thức OMML, XML hợp lệ và nguồn Mermaid khớp. Log: `.scratch/v06-word-validate-final.log`.

Regression comment/placeholder: PASS, log `.scratch/v06-marker-test.log`.

PDF cuối có 71 trang A4, đã inspect 71/71, verdict ok, không trang trắng. Lead đã xem toàn bộ 18 contact sheet, rà riêng trang 15 (PBR), 19 (skinning), 52 (lớp), 56 (sequence) và 63 (luồng) ở kích thước lớn. Nhãn, mũi tên và công thức đọc được; caption đi cùng hình. UC08 và bảng trạng thái được giữ trọn nhóm; code tách ở các checkpoint và có nhãn tiếp nối. Không thu nhỏ cỡ chữ nội dung để ép số trang. Một số panel vẫn dùng trang riêng, có khoảng trắng để giữ chữ đọc được; không tuyên bố mọi trang đều phủ kín hoặc đã thử in giấy.

SHA256 PDF: e5fb32a270deda86d0eb78d26ec948c13e4251b516d7a5b672368b1090dc61f4. Dữ liệu máy kiểm và hash Word tại publication-v0.6-checks.json. Log render .scratch/v06-render-final.log; marker PDF .scratch/v06-pdf-validate-final.log. Các bản trung gian không phải đầu ra hiện hành.

Native Word PDF export did not finish, including attempts with a new output path and a rebuilt DOCX. Only isolated Word processes created by this task were closed. No execution policy was changed. The final PDF uses Cindy's Chromium renderer with a self-contained HTML view read from the reviewed DOCX; OMML is mapped to MathML. Word and PDF pagination can differ. Native Word pagination remains unapproved; this is not a successful native Word PDF export.

Nguồn tái lập: build-manuscript → make_docx của Cindy → format-draft → finalize-publication → publication-html → render_pdf của Cindy → validate-manuscript/validate-publication-pdf → inspect_pdf → render-publication-review. HTML và ảnh rà ở .scratch, không lưu dữ liệu màn hình hoặc log đầy đủ vào repo. Bộ chuyển giữ tên gói/API, phân biệt mã inline với khối code; MathML bỏ các thuộc tính điều khiển OMML khi tạo chỉ số và hiểu ký hiệu n-ary mặc định của Word là tích phân.

## Phân công

Orca Worker diagrams (Sol 6.1) bàn giao chỉ đọc 11 panel đề xuất và bảng truy vết; Lead tích hợp, chia thêm các panel cao thành 15 panel, dựng ảnh và Word. Các nguồn đề xuất chưa dùng được giữ làm lịch sử, không phải tất cả là hình hiện hành.

Orca Worker QA đã xác nhận source/Word/15 PNG, không có P1/P2 trong phạm vi; qa/publication-v0.6.md. Lead dựng lại từ cùng nguồn/ảnh, chạy validator cuối, rà toàn PDF, diff và thực hiện commit/push cuối phiên. Không dùng native subagent.
