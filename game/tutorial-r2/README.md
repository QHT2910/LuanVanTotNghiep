# Ví dụ thành phần R2

Source được Orca Worker developer đối chiếu API Scene 0.24.3; Lead lưu và kiểm tra ngày 05/11/2026. Hướng dẫn hiện hành ở mục 2.12 Chương 2; research/tutorial-r2-draft.md và API notes là hồ sơ bàn giao trước tích hợp, không phải trạng thái hiện hành. Không phải game bóng rổ hoặc ví dụ Internet.

Chạy trong thư mục này: `flutter pub get --offline`, `flutter analyze`, `flutter build bundle --debug --target-platform android-arm64`, `dart tool/sync_smoke.dart`. Bốn lệnh đạt; log và kernel hash ở ../evidence-r2/. Smoke source giữ nguyên R1 nhưng có log chạy mới R2.

Nhánh cơ sở không cần model ngoài. assets_step.dart chỉ nạp khi có dart-define và asset hợp lệ được khai báo trong pubspec; chưa có asset/model/animation để thử runtime. Chưa có thư mục Android runner: muốn cài/chạy điện thoại cần tạo runner và metadata Flutter GPU theo hướng dẫn; build bundle không chứng minh việc cài APK hoặc GPU hoạt động.

Điều khiển chọn hướng đến khi nhấn Dừng, không phải nhấn giữ. BasicSimulation chỉ minh họa kinematic/trigger, không có contact solver cho bóng bật nảy. Dispose và event cần kiểm tra runtime khi có thiết bị. Không suy ra đã đạt hiệu năng hoặc tính đúng của luật game.
