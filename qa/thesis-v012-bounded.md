QA bounded v0.12 hiện hành — REVISE, p1038 OPEN theo yêu cầu Cindy; chưa final closure. Không phát hiện P1/P2 mới ở bốn trang được giao.

Quota: host get_subscription_usage trả account openai/default connected, primary0%, weekly16%, updated1795000600757, dưới95%; không đổi account/provider. Query providerId codex đầu trả accounts[] nên đã đọc đúng toàn localaccounts, không hiểu empty là0quota.

Own RAM checks:
Input actual useredited v0.11_corrected:5218894bytes/e606d15654145595d228f70003f8e8b8ff80b48326c95a46fa85032fa504fea3.
v0.12DOCX:6360372bytes/80e4d5cb7b743584702a8dc22fd8353b2f77e4a4d26d65bde559eb8f1b41a256.
PDF:3487837bytes/e7b9ed9c0f000d7d78cd6c7fac3dc5e44256011edd6265c50ecc92f1e06b1f32.
ZIP chỉdocument.xml+image1–27.png đổi;11Figmaimage28–38 giữ byte.24OMML serializedexact/44reftextexact.38caption XML label BIU, colon/title plain, không lỗi ở phép dò runs.
Đọc Ch4.3.6 actualXML: tutorial analyze/bundle/headless/asset inspection được tách khỏi13/22/34/47; không nhận renderSceneView/Fox/hotreload runtime từ bundle; AVD ứng dụng tham chiếu4.3.2–5 riêng. Không thấy nâng thành phone/Internet/fullgame.

Ảnh own: chỉdeliverypage76/80/81/83. Page76 có hai loại diamond phân biệt rõ: RoomState rỗngaggregation, WorldState đencomposition; bội số/attributes đọc được. Page80/81 guard/nestedalt không chồng tabalt; page81 guard đầu một dòng nguyên; page83 snapshot arrows vềđúngA/B và caption/diagram không clipping. Không QA toàn108trang;104PNGbyteexact và native108/font/render là Lead kế thừa từ hồ sơ.

P2 instructional defect OPEN — baselinep1038, example declarative:
Actual XML có một paragraph “// Cập nhật tham số trên material cũ, không tạo material mới.          _material.baseColorFactor = _tint();”, w:br=0. Statement vẫn bị chú thích // khi sao chép; authornote không giải quyết lỗi hướng dẫn.
Sửa bounded: thêm w:br thật sau câu comment, trước _material.baseColorFactor = _tint(); hoặc tách statement thành paragraph mã kế tiếp. Giữ mọi token code/comment, không chỉ thêm khoảng trắng. REVIEW_v0.12 đoạn coi việc tách dòng là trách nhiệm tác giả cũng phải cập nhật sau fix. Không dùng build lịch sử làm bằng chứng listing mới compile. Chờ Lead bàn giao newhash để closure riêng, không tự reread/export.

Actual gates:
get_subscription_usage(alllocal) | PASS available0%/16% updated1795000600757 | logpath=none
node stdin crypto3artifact | PASS hash/bytes như trên | logpath=none
node stdin JSZip/DOM preservation+38captionruns | PASS24OMML/44refs/11Figma/changedparts/BIUscope | logpath=none
node stdin XMLmergedlisting | FAIL instructionalp1038 comment+statement sameparagraph/br0 | logpath=none
node stdin XML4.3.6 +Get-Content reviews/metadata/logs | PASS scopeclaims; Word/fontgates inherited notrerun | logpath=none
view_image delivery76/80/81/83 | PASS boundeddiagramreadability | logpath=none

Sản phẩm bàn giao: supplementQA hiện hành choLead lưu; verdictREVISE đến p1038 sửa thực.
Bằng chứng: actualhash/XML/RAM+4ảnh mới; Word/full108review kế thừaLead.
Điểm chưa rõ: chưa thẩm định học thuật toàn bộ/in/crossWord; chưa có artifactfix.
Bước tiếp: Lead sửa ngắt dòng rồi giao closure cần thiết; worker không mởtaskkhác, game/Stage3PAUSED.
