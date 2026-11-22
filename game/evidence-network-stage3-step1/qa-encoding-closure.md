# Orca Worker QA — encoding closure PASS

Đóng P2 hồ sơ, tái sử dụng numerical/source PASS trước. Không chạy lại code/CLI/build/AVD. QA tự kiểm report UTF8: 0 dấu hỏi thay chữ, 0 U+FFFD, 0 NUL; bảng32dòng khớp comparison từng ID/tick/alpha/Scene/CPU/distance, chỉ cho sai số in9decimal 5.1e-10 (không đổi threshold1e-4m). 42 manifest filehash khớp. Golden SHA1944fc379b5d3d2cdae8c08a236bedd12d7cacdbd08878b290510f8918fabf2d; comparison SHA79c00548dcda4e84009f0c14a9b345946cb765e107a962ce2a6f5a48edfd47c3 không đổi.

Original log byteexact với log hỏng; readable không NUL/U+FFFD/localVM URL, giữ GOLDEN_DONE32. Manifest cảnh báo readable là lossy recovery, không raw nguyên vẹn hoặc chạy collector mới. Các giới hạn32fixtures/Jog/ready/clear/genericparser/GPU/productionrelease/networkSTEP2 được ghi đúng. Không nâng delta0 thành physical accuracy.

Actual readonly gates: Get-Content/Select-String review+manifest PASS; nodeUTF8scan PASS; node32tablecompare PASS; nodemanifest42hash+oracle PASS; nodeoriginal/readablechecks PASS. logpath=none(RAM). Không mở STEP2, không ghi/Git.
