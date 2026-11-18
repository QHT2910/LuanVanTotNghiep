# Đối chiếu lifecycle Scene 0.24.3

Cindy yêu cầu kiểm lại Hình2.5 sau khi xem bản111trang. Lead đọc trực tiếp package cache **flutter_scene0.24.3**, component.dart và node.dart, ngày18/11/2026. Không dùng thứ tự trên web hiện hành để thay mã đã pin.

| Nguồn | Hành vi thực |
|---|---|
| Component.attachTo, dòng94–97 | Gán node rồi gọi onAttach. |
| Node.addComponent, dòng786–807 | attachTo trước; nếu node đã trong cảnh thì mount ngay. |
| Component.mount,106–116 | Guard mounted; đặt mounted=true; gọi onMount; nếu chưa loaded mới gọi onLoad. Future hoàn tất chỉ đặt loaded nếu lúc đó mounted. |
| Component.tick/fixedTick,126–138 | Chỉ gọi update/fixedUpdate khi enabled, mounted và loaded. |
| Node._unmount,847–851 | Unmount component khi rời cảnh, không tự detach component khỏi node. |
| Node.removeComponent,809–821 | Nếu node trong cảnh thì unmount, sau đó detachFrom. |
| Component.detachFrom,100–103 | onDetach chạy trước khi xóa tham chiếu node. |

**Kết luận:** thứ tự onAttach→onMount→onLoad của hình cũ đúng đường đi này; câu “onMount trước onLoad…, sau onAttach” dễ gây đọc nhầm. Không đảo hook để sửa một lỗi diễn giải. Vấn đề thực cần sửa là câu văn rõ từng bước, guard loaded/mounted/enabled, phạm vi unmount/detach và caption claim ownership dù hình không vẽ ownership.

Sửa bounded trên bản **v0.11_corrected**, giữ v0.11_final làm candidate lịch sử:

- p211 baseline viết thành từng bước; bỏ so sánh thứ tự web không cần thiết.
- p213 nói rõ một đường gắn/mount/nạp/update/gỡ trên node đang trong cảnh.
- Caption2.5 thành “Một đường đi thành công của Component trong Scene0.24.3[35]”.
- p216 phân biệt rời cảnh với gỡ component, cảnh báo remount khi load chưa hoàn tất, giữ ownership/dispose ở văn xuôi.
- Hình2.5 giữ ba hook đầu đúng mã; ghi onLoad hoàn tất khi còn mounted, guard tick đủ3điều kiện, đặt tên nhóm cuối theo đường gỡ khi đang trong cảnh.
- Không sửa bốn sơ đồ khác hoặc code/game/network; không mở lại toàn luận văn.

Rà source cache không thay cho chạy mọi lỗi/remount. Hình chỉ minh họa một đường thành công; không khẳng định mọi lần mount chỉ gọi onLoad một lần hoặc mọi unmount đều detach. Không nhận shared GPU resources giải phóng đồng bộ.

Gate Lead: Get-Content component.dart/full và node.dart786–851 | PASS đọc nguồn pinned | logpath=none. Verify/check-normal corrected | PASS | .scratch/thesis-v011/verify-corrected.txt và normal-corrected.txt. Native PDF/QA corrected được ghi ở bản handoff sau export; không lấy QA cũ của111trang làm QA mới cho ngữ nghĩa lifecycle.

## Kiểm riêng tiêu đề trang16

Cindy thấy PNG review cũ chỉ hiện '3.'. XML thực chứa nguyên '2.4.3. Quyền cập nhật và tài nguyên dùng chung', không numPr; PDF text item cũng nguyên2.4.3 tại x85.3/y772.15. Render riêng trang16 từ cùng PDF trong tiến trình PDF.js mới, scale2, cho ảnh corrected-page-16-fresh.png hiện đầy đủ2.4.3 và2.4.4. Đây là sai khác ảnh review ở pipeline trước; không có cơ sở đổi numbering trong Word hoặc xuất lại lần nữa. PDF/DOCXhash không đổi. Ảnh corrected-page-16.png đã cập nhật từ bản render riêng có thể đọc rõ; bản render cũ giữ tại .scratch để không xóa lịch sử. Cần phân biệt quan sát ảnh với textlayer: đã kiểm cảhai, không chỉ suy từ XML.

Gate: XML/PDFtext coordinates read | PASS | logpath=none. Isolated PDF page16 scale2 | PASS thấy đủ2.4.3/2.4.4 | .scratch/thesis-v011/page16-fresh.txt.
