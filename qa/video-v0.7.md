# QA bổ sung v0.7 — 07/11/2026

Orca Worker tester bkm37d3uiwhgp757im7y9hov, gpt-6.1-sol, chỉ đọc. Không P1; P2 duy nhất là câu trạng thái build trong hồ sơ nguồn, Lead đã đồng bộ sau báo cáo.

Đạt phạm vi nội dung/source và Word XML: declarative/imperative, retained graph/reconciliation/ownership; các giai đoạn loading/warm-up; debug asset reload và editor chưa dùng; bài tùy chọn State giữ tài nguyên, controller chỉ đọc, không đổi A–F. Source cache 0.24.3 hỗ trợ đường reveal và guard kDebugMode. Không diễn giải compile thành runtime.

Video [38] kế thừa Cindy xem chọn đoạn, không transcript đầy đủ; [39]/[40] web hiện hành, [41] source phiên bản. [15] có lượt đọc bổ sung, giữ lịch sử cũ. Code Markdown khớp source; Word có nhãn tiếp nối xuất bản. Word 41 refs,27 ảnh,3 OMML; không marker/comment hoặc API vào math trong phạm vi quét. Không phát hiện mất dấu; ?v= trong URL không phải lỗi encoding.

Evidence kế thừa: analyze target PASS No issues found; build bundle đúng target exit0 theo checks.json, build stdout rỗng và kernel hash. QA không chạy lại chương trình. Chưa nghiệm thu PDF hoặc Android/warm-up/reload/editor runtime.

```text
Get-Content/Select-String + cache 0.24.3 | PASS ownership/reveal/debug reload | logpath=none
Regex/source comparison | PASS Markdown/source; Word có nhãn tiếp nối | logpath=none
ZipFile.OpenRead + XML | PASS 41refs/27ảnh/3OMML, marker/API-math trong mẫu quét | logpath=none
```

Lead phải tái xuất PDF sau sửa metadata và rà phân trang; báo cáo QA này không thay gate đó.
