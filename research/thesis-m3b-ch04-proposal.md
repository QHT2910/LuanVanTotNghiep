# Chương 4. Kiểm thử

## 4.1. Môi trường và phạm vi kiểm thử

Các mốc M1, M2, M3a và M3b kiểm tra từng phần của ứng dụng tập bóng rổ offline. M1 tập trung vào dựng cảnh và vòng ném; M2 bổ sung joystick và phối hợp thao tác; M3a thêm nhảy; M3b thêm Dash. Chương này trình bày kết quả theo từng bản và mức kiểm tra, không xem các mốc đó là nghiệm thu toàn bộ game đối kháng 1v1.

| Thành phần | Môi trường được ghi nhận |
|---|---|
| Flutter và Dart | Flutter 3.47.8 stable, Dart 3.13.7 |
| Engine | flutter_scene 0.24.3 |
| Thiết bị chạy | Một AVD có tên Pixel_9a |
| Hệ điều hành và kiến trúc | Android API 37, x86_64 |
| Backend đồ họa | Impeller OpenGLES theo hồ sơ chạy |
| Bản ứng dụng | APK debug cho Android x64 |

Pixel_9a ở đây là tên giả lập, không phải điện thoại Pixel vật lý. Chưa có kết quả chạy ứng dụng trên Redmi Note 11 hoặc thử hai điện thoại qua Internet. Cấu hình trên phục vụ kiểm tra chức năng; nó không đại diện cho hiệu năng của thiết bị di động thật.

Probe Scene/Fox và ứng dụng tập offline được phân biệt trong đánh giá. Probe hỗ trợ kiểm tra cảnh và đường nạp asset ở phạm vi của chính nó. Ứng dụng tập sử dụng nhân vật hình khối; kết quả probe không xác nhận mô hình Fox đã được tích hợp vào gameplay.

## 4.2. Kịch bản và phương pháp kiểm tra

### 4.2.1. Các mức kiểm tra

Phân tích tĩnh được dùng để tìm lỗi mã trong phạm vi công cụ kiểm tra. Các bài kiểm tra logic và widget đối chiếu cấu hình, điều kiện trạng thái và phản hồi đầu vào. Build và cài đặt xác nhận sản phẩm có thể được tạo và chuyển tới môi trường chạy tương ứng; chúng không thay thế việc kiểm tra hành vi.

Ở mức runtime, các chuỗi thao tác trên AVD được đối chiếu với sự kiện ứng dụng và điều kiện mong đợi. Mã sự kiện, thời gian mô phỏng, định danh cú ném hoặc hành động giúp xác định trình tự và phát hiện tác dụng lặp. Ảnh chụp hỗ trợ kiểm tra một số trạng thái hiển thị, nhưng không tự chứng minh hành vi liên tục giữa mọi khung hình.

Kiểm tra source và APK bổ sung mối liên hệ giữa mã và bản được kiểm. Việc source có mặt trong kernel, hash APK cục bộ và hash APK đã cài là các phép đối chiếu riêng. Kết quả phù hợp chỉ có giá trị trong phạm vi bản và dữ liệu đã kiểm, không chứng minh toàn bộ đường thực thi hoặc hiệu năng.

### 4.2.2. Nhóm kịch bản

| Nhóm | Nội dung đối chiếu |
|---|---|
| Ném và ghi điểm | Cú 2/3 điểm, ném trượt, ghi điểm một lần, reset giữa bay và chơi tiếp |
| Điều khiển | Deadzone, giới hạn vector joystick, quyền sở hữu pointer, release và cancel |
| Nhảy | Không nhảy lần hai trên không, tiếp đất, độ cao thả bóng và chân chiếu xuống sân |
| Dash | Điều kiện nhận, hướng đã chốt, thời lượng, giới hạn sân, hồi chiêu và hành động xung đột |
| Vòng đời | Hủy đầu vào, pause/resume, không tự phát sinh hành động và tiếp tục chơi |
| Tính nhất quán bản kiểm | Mã nguồn được đối chiếu với APK và metadata bản cài |

Các điều kiện chỉ được kiểm bằng logic hoặc widget được ghi riêng, không nâng thành kết quả runtime Scene. Trong M3b, chuỗi thử có input ngoài bộ thao tác kiểm soát được giữ làm dữ liệu thăm dò và không dùng làm oracle của phiên cuối.

## 4.3. Kết quả theo từng mốc

### 4.3.1. Tổng hợp

| Mốc | Tổng bài kiểm tra của bản | Kết quả công cụ và sản phẩm | Phạm vi chức năng chính |
|---|---:|---|---|
| M1 | 13 | Phân tích tĩnh, kiểm tra, build và cài đặt đạt theo hồ sơ cuối | Cảnh và vòng tập ném offline |
| M2 | 22 | Phân tích tĩnh, kiểm tra, build và cài đặt đạt | Joystick và phối hợp hai pointer |
| M3a | 34 | Phân tích tĩnh, kiểm tra, build và cài đặt đạt | Nhảy và ném trên không |
| M3b | 47 | Phân tích tĩnh, kiểm tra, build và cài đặt đạt | Dash và các điều kiện liên quan |

13, 22, 34 và 47 là tổng của từng phiên bản, không cộng thành số bài kiểm tra độc lập của bản cuối. Bộ 47 bài của M3b gồm 34 bài trước và 13 bài mới. Việc đạt các bài kiểm tra chỉ xác nhận những điều kiện được chúng bao phủ.

Ở M3b, một điều chỉnh xuống dòng HUD được thực hiện sau lượt test; source cuối tiếp tục được phân tích, build, cài và đối chiếu audit. Do đó, không diễn giải hồ sơ thành một lượt chạy test mới sau mọi thay đổi trình bày.

### 4.3.2. M1: vòng tập ném

Chuỗi runtime cuối ghi sáu lần thả bóng. Các cú 1, 2 và 6 lần lượt cộng 3, 2 và 2 điểm, tổng cuối là 7. Hai cú ném với mức giữ thấp và đầy không làm tăng điểm. Cú thứ 5 bị reset giữa bay, không được cộng điểm; sau reset vẫn có thể ném và chơi tiếp.

Hai chu kỳ xuống nền rồi trở lại có các sự kiện hủy canh ném, pause và resume, sau đó mô phỏng tiếp tục. Hồ sơ cuối dùng cách giữ ticker và pause logic; lỗi đứng sau resume ở bản trung gian không được coi là trạng thái cuối. Biện pháp tắt anti-aliasing đã được dùng để xử lý vệt hình trong phạm vi quan sát, chưa chứng minh nguyên nhân hoặc giải pháp tổng quát cho mọi backend.

### 4.3.3. M2: joystick và phối hợp ném

Hai pointer được dùng để giữ joystick và giữ–thả nút ném. Sau khi ngón ném được thả, ngón điều khiển vẫn tiếp tục di chuyển trong chuỗi kiểm tra. Hai cú ném được ghi nhận đều cộng 3 điểm, tổng 6, không lặp định danh ghi điểm.

Hủy toàn bộ pointer đưa joystick về tâm và hủy canh ném mà không tạo cú thả mới. Sau background/resume, ứng dụng tiếp tục nhận thao tác và ném. Hủy riêng từng pointer, xử lý giá trị không hữu hạn, đường chéo và một số tình huống callback cũ được kiểm ở mức logic hoặc widget; chưa có oracle AVD cho toàn bộ các trường hợp đó.

### 4.3.4. M3a: nhảy và độ cao thả

Oracle ghi sáu lần bắt đầu nhảy, năm lần tiếp đất và một lần reset hủy nhảy. Yêu cầu nhảy lặp khi đang trên không bị từ chối. Pause/resume giữ cùng độ cao và thời gian mô phỏng tại mốc đối chiếu; sau resume nhân vật tiếp đất mà không tự tạo cú nhảy hoặc cú ném mới.

Hai cú thả trên không có độ cao nhân vật khoảng 0,906904 và 0,884193 đơn vị cảnh; điểm xuất phát bóng tương ứng khoảng 2,706904 và 2,684193. Tọa độ đứng của chân dùng cho tính điểm vẫn bằng 0. Hai cú lần lượt ghi 3 và 2 điểm, tổng 5. Các số này xác nhận dữ liệu được ghi trong hai ca, không phải số đo quỹ đạo từ thiết bị vật lý.

Joystick+jump và jump+shoot là hai ca hai pointer riêng. Chúng chưa chứng minh thao tác đồng thời bằng ba ngón hoặc mọi tổ hợp trên không.

### 4.3.5. M3b: Dash

Phiên runtime cuối ghi bảy lần bắt đầu và bảy lần kết thúc Dash. Bốn lần kết thúc theo thời lượng 0,2 giây đạt quãng đường 1,6 đơn vị cảnh. Hai lần kết thúc do biên bắt đầu ngay tại vị trí biên x = −3,78 nên quãng đường bằng 0; chúng không chứng minh trường hợp Dash chéo từ bên trong bị cắt tại biên. Trường hợp cắt quãng đường theo hướng và một số biên khác được kiểm bằng source và unit test.

Một Dash bị kết thúc khi xuống nền sau 0,1 giây và đi được 0,8 đơn vị. Tại các mốc pause/resume được đối chiếu, thời gian mô phỏng và thời gian hồi còn lại không thay đổi. Không có Dash tự phát khi trở lại; thao tác mới sau resume vẫn được nhận.

Các yêu cầu khi đang Dash hoặc đang hồi bị từ chối theo oracle. Dash hủy canh ném mà không làm phát sinh cú ném cũ; chuỗi tiếp theo ghi một cú 3 điểm đúng một lần và trở về lượt tập mới. Hủy pointer toàn bộ không đảo ngược Dash đã được nhận, phù hợp chính sách hành động theo lần nhấn.

Những ca chặn jump/shoot trong Dash, reset giữa Dash, race, hướng chéo và hủy riêng từng pointer còn dựa vào kiểm tra logic hoặc widget, không phải tất cả đã được thực hiện trong chuỗi runtime này.

Audit cuối ghi nhận bảy source được nhúng trong kernel APK và không còn các source phẳng cũ trong danh sách kiểm. Hồ sơ hash bản cài khớp hash APK cuối. Trường đối chiếu kernel cục bộ với kernel APK có giá trị chưa xác định không được tính là một phép kiểm đạt. Các kiểm tra này liên hệ đúng bản kiểm, không xác nhận hiệu năng hoặc bao phủ mọi hành vi.

## 4.4. Giới hạn đánh giá

Kết quả hiện có giới hạn ở một giả lập và bản tập offline. Chưa có benchmark FPS, frame time hoặc RTT; không thể từ các lần thao tác thành công suy ra hiệu năng trên điện thoại thật. Cũng chưa có thử hai Android hoặc hai mạng Internet.

Hệ chuyển động và cú ném dùng mô hình giải tích, chưa có solver bảng–vành, bật nảy hoặc Block. Dash đã có trong bản tập nhưng tương tác với đối thủ, phân xử từ máy chủ, phòng đấu và vòng trận 11 điểm/3 phút chưa được triển khai. Thành công của các mốc không đồng nghĩa hoàn thành yêu cầu 1v1.

Mức bằng chứng giữa các ca khác nhau: unit kiểm logic, widget kiểm phối hợp thành phần trong fixture, runtime kiểm một số chuỗi trên AVD. Chuỗi hai pointer không bao phủ ba ngón, mọi race hoặc mọi độ phân giải. Ảnh chụp và báo cáo QA chỉ hỗ trợ phạm vi đã quan sát.

UI runtime là giao diện thử nghiệm. Concept UI04 V3 đã được duyệt nhưng chưa có bộ ảnh Figma xuất được xác minh để đưa vào bản thảo; các màn còn lại vẫn cần hoàn thiện theo thiết kế. Vì vậy, kết quả thao tác trên demo chưa phải nghiệm thu bộ giao diện chính thức.
