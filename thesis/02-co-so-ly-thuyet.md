# CHƯƠNG 2. CƠ SỞ LÝ THUYẾT

> Bản thảo nghiên cứu sơ bộ, cập nhật ngày 04/11/2026. API được đối chiếu với tài liệu chính thức đang công bố; các lệnh, đoạn mã và quy trình dưới đây chưa được thực thi trong dự án. Những khác biệt giữa tài liệu, phiên bản gói và thiết bị sẽ được kiểm chứng khi xây dựng sản phẩm. Danh mục nguồn ở cuối chương và `research/ch02-sources.md`.

## 2.1. Tổng quan Flutter Scene và nền tảng Flutter GPU/Impeller

Flutter Scene là bộ công cụ xây dựng nội dung ba chiều trong ứng dụng Flutter. Thay vì chỉ mô tả các thành phần giao diện hai chiều, lập trình viên tổ chức đối tượng trong một không gian có vị trí, hướng, kích thước và góc quan sát. Cảnh ba chiều sau khi kết xuất vẫn tham gia bố cục ứng dụng thông qua widget, nên màn hình có thể kết hợp vùng hiển thị thế giới 3D với nút bấm, thông báo và bảng thông tin Flutter.

Trong kiến trúc này, cần phân biệt ba lớp trách nhiệm. Flutter quản lý ứng dụng và giao diện. Flutter GPU cung cấp khả năng sử dụng tài nguyên và lệnh đồ họa ở mức thấp. Scene tổ chức những khái niệm thuận tiện hơn như cảnh, đối tượng, lưới, vật liệu và camera. Trên nền tảng native, tài liệu Scene xác định Flutter GPU và Impeller là nền tảng kết xuất; trên web sử dụng backend riêng. Vì vậy, mã điều khiển game không cần tự xây dựng toàn bộ đường ống đồ họa, nhưng vẫn phải quan tâm giới hạn tài nguyên và tương thích thiết bị. [LT01, LT02]

Quy trình tìm hiểu gồm: xác định phiên bản Flutter yêu cầu; chọn phiên bản Scene; đọc API tương ứng; dựng ví dụ nhỏ; sau đó mới bổ sung tài nguyên phức tạp. Hướng dẫn hiện yêu cầu Flutter 3.47 stable trở lên và bật Flutter GPU cho Android. Phiên bản Flutter cục bộ đã ghi nhận là 3.47.8, nhưng con số này chỉ chứng minh điều kiện phiên bản ban đầu, không chứng minh ứng dụng đã chạy trên Redmi Note 11. Scene còn trước phiên bản 1.0, nên phải lưu phiên bản dependency, lockfile và thay đổi API liên quan. [LT01]

## 2.2. Đồ thị cảnh, node, hệ tọa độ và phép biến đổi

### 2.2.1. Scene và Node

`Scene` là đối tượng quản lý cảnh. Bên dưới cảnh là cây các `Node`; một node có thể chứa phần hiển thị, node con và hành vi. Cách tổ chức phân cấp giúp biểu diễn những quan hệ như vật thể được gắn vào tay nhân vật hoặc camera đi theo một điểm điều khiển. Di chuyển node cha làm thay đổi vị trí thế giới của các node con mà không cần cập nhật từng đối tượng riêng. [LT03, LT04]

Vị trí cục bộ được hiểu theo hệ tọa độ của cha, còn vị trí thế giới được hiểu theo toàn cảnh. Với một node con, ma trận biến đổi thế giới được tính từ ma trận thế giới của cha nhân với ma trận cục bộ. Do phép nhân ma trận không giao hoán, thay đổi thứ tự tịnh tiến, xoay và co giãn có thể tạo kết quả khác nhau. Khi nhập tài nguyên từ phần mềm dựng hình, cần thống nhất chiều cao, hướng nhìn và tỷ lệ thay vì sửa bằng nhiều phép xoay rời rạc không có quy ước.

### 2.2.2. Cách sử dụng từng bước

1. Tạo một `Scene` và node đại diện cho đối tượng.
2. Gắn hình học, vật liệu hoặc hành vi cần thiết vào node.
3. Gắn node vào cảnh bằng `scene.add`, hoặc vào node cha bằng `node.add`.
4. Gán vị trí, góc xoay và tỷ lệ theo hệ tọa độ đã chọn.
5. Quan sát riêng từng phép biến đổi trước khi ghép thành một phân cấp phức tạp.

Tài liệu cung cấp thuộc tính `position`, `rotation`, `scale` và `localTransform`. Các getter biến đổi có thể trả về bản sao; sửa trực tiếp một thành phần trên giá trị trả về không nhất thiết sửa node. Cách an toàn theo ví dụ tài liệu là tạo giá trị mới rồi gán trở lại, chẳng hạn `node.position = vm.Vector3(0, 1, 0)`. Với hành vi liên tục, nên gom cập nhật vào một nơi, tránh widget và logic mô phỏng đồng thời ghi cùng thuộc tính. [LT02, LT04]

### 2.2.3. Component và quyền sở hữu

`Component` đóng gói hành vi gắn với node. Vòng đời được tài liệu mô tả gồm gắn thành phần, nạp bất đồng bộ, tham gia cảnh, cập nhật và rời cảnh. Việc gom chuyển động hoặc tương tác vào component giúp giảm mã cập nhật phân tán. Scene hỗ trợ cả khai báo cấu trúc bằng widget và thao tác cây cảnh trực tiếp. Hai cách cùng sử dụng đối tượng bên dưới, nhưng phải rõ bên nào sở hữu cấu trúc và thuộc tính: một giá trị do widget khai báo có thể được áp dụng lại khi widget rebuild. [LT03]

## 2.3. Hình học, mesh và vật liệu

### 2.3.1. Vai trò từng thành phần

Hình học mô tả hình dạng thông qua đỉnh, chỉ số nối đỉnh và các thuộc tính phục vụ tô bóng. Vật liệu mô tả phản ứng của bề mặt với ánh sáng. `Mesh` ghép hình học với vật liệu để tạo phần có thể được kết xuất. Một khối cầu giống nhau có thể được biểu diễn như nhựa, kim loại hoặc bề mặt màu phẳng khi thay vật liệu; ngược lại, cùng một vật liệu có thể dùng cho nhiều hình dạng. [LT03, LT05]

Scene cung cấp hình học cơ bản, phù hợp để học API và tạo nguyên mẫu. Ưu điểm của nguyên mẫu từ các khối là không phụ thuộc quy trình nhập mô hình và dễ nhận biết lỗi tỷ lệ. Tuy nhiên, số node và lưới vẫn cần kiểm soát; chia một vật thể đơn giản thành quá nhiều đối tượng độc lập có thể làm tăng chi phí quản lý và vẽ.

### 2.3.2. Vật liệu PBR và vật liệu không chiếu sáng

`PhysicallyBasedMaterial` sử dụng những tham số như màu cơ sở, độ kim loại và độ nhám. Độ kim loại ảnh hưởng cách phản xạ, còn độ nhám điều chỉnh độ sắc của phản chiếu. Không nên xem tăng độ sáng màu cơ sở là cách thay thế ánh sáng, vì hai thao tác giải quyết hai vấn đề khác nhau. `UnlitMaterial` hiển thị bề mặt không phụ thuộc hệ chiếu sáng, thuận tiện cho đánh dấu, kiểm tra hình học hoặc phong cách giản lược. [LT05]

Để sử dụng, trước hết chọn hình học; tiếp theo tạo vật liệu, điều chỉnh một nhóm tham số và ghép thành mesh; cuối cùng gắn mesh vào node. Nên thay một tham số mỗi lần để nhận biết tác động. Khi dùng texture, phải kiểm tra đường dẫn, tọa độ UV, độ phân giải và thông tin màu của tài nguyên. Tài liệu phân biệt texture màu cơ sở, normal, metallic–roughness và các kênh khác; chúng không thể thay thế tùy ý cho nhau. Vật liệu và hình học gắn với tài nguyên GPU nên cần tái sử dụng, tránh tạo lại liên tục trong mỗi khung hình. [LT03, LT05]

## 2.4. Camera và ánh sáng

### 2.4.1. Camera

Camera quyết định vùng thế giới được chiếu lên màn hình. Phép chiếu phối cảnh làm vật ở xa có kích thước biểu kiến nhỏ hơn vật ở gần, hỗ trợ nhận biết chiều sâu. Các tham số quan trọng gồm vị trí, điểm nhìn, hướng lên, góc nhìn và mặt phẳng cắt. Mặt phẳng gần hoặc xa đặt không hợp lý có thể cắt mất vật thể hoặc làm việc phân biệt độ sâu kém hiệu quả. [LT06]

Quy trình thiết lập bắt đầu bằng một camera cố định nhìn vào gốc tọa độ. Sau khi xác nhận đối tượng hiển thị đúng, mới thay đổi độ cao, khoảng cách và góc nhìn. Trong Scene, có thể truyền `PerspectiveCamera` trực tiếp vào `SceneView`, hoặc dùng `cameraBuilder` để tạo góc quan sát thay đổi theo thời gian. Với camera thuộc phân cấp cảnh, tài liệu giới thiệu `CameraComponent` và camera chính của scene. Chọn cách nào phụ thuộc việc camera chỉ quan sát cố định hay cần gắn vào cấu trúc chuyển động. [LT06]

### 2.4.2. Ánh sáng và môi trường

Ánh sáng giúp người quan sát nhận biết hình khối, vật liệu và độ cao. Chiếu sáng dựa trên ảnh môi trường mô phỏng ánh sáng tới từ nhiều hướng; nguồn sáng có hướng bổ sung đặc tính như mặt trời và bóng đổ. Skybox là phần nền nhìn thấy, không đồng nhất với nguồn chiếu sáng. Chỉ đổi nền chưa chắc làm đối tượng sáng lên, và đổi môi trường chiếu sáng cũng không tự bảo đảm nền tương ứng được vẽ. [LT07]

Tài liệu Scene mô tả môi trường mặc định cho cảnh mới, giúp bắt đầu với vật liệu PBR mà chưa phải dựng hệ đèn riêng. Quy trình học nên giữ môi trường mặc định, xác nhận vật liệu, rồi mới thử panorama hoặc đèn có hướng. Nếu thêm bóng đổ, cần so sánh cả hình ảnh lẫn thời gian khung hình. Hậu xử lý, phơi sáng và tone mapping là những bước điều chỉnh đầu ra; không nên bật hàng loạt hiệu ứng trước khi có một cấu hình cơ sở để đối chiếu. [LT07]

## 2.5. Tài nguyên, mô hình và hoạt ảnh

### 2.5.1. Nạp mô hình

Một mô hình có thể chứa phân cấp node, lưới, vật liệu, texture và hoạt ảnh. Định dạng glTF/GLB giúp trao đổi những dữ liệu này, nhưng việc một engine hỗ trợ định dạng không đồng nghĩa hỗ trợ mọi extension hoặc mọi cấu hình xuất. Cần kiểm tra bằng mô hình nhỏ trước, ghi công cụ xuất, tỷ lệ, giấy phép và những tính năng đã dùng. [LT08]

Scene có hai đường nạp chính. `Node.fromGlbAsset` nạp GLB trong asset bundle tại runtime; sau khi hoàn tất, node được thêm vào cảnh. Đường còn lại chuyển tài nguyên khi build rồi dùng `loadScene` theo đường dẫn nguồn. Tiền xử lý giúp chuyển công việc khỏi thời điểm mở cảnh, nhưng đầu ra phụ thuộc quy trình build và phải được quản lý cùng nguồn tài nguyên. [LT08]

Các bước sử dụng gồm: chuẩn bị mô hình có quyền sử dụng; khai báo hoặc đưa vào pipeline phù hợp; nạp bất đồng bộ; hiển thị trạng thái chờ hoặc lỗi; đặt tỷ lệ và vị trí; cuối cùng kiểm tra hình ảnh trên thiết bị. Không nên bỏ qua trạng thái lỗi rồi xem mô hình không hiển thị như một lỗi camera. Khi tài nguyên lớn, thời gian nạp, bộ nhớ và khung hình đầu đều là các khía cạnh cần ghi nhận riêng. [LT08]

### 2.5.2. Hoạt ảnh

Hoạt ảnh mô tả sự thay đổi theo thời gian của tư thế hoặc thuộc tính mô hình. Clip phát lại là đối tượng có trạng thái riêng: thời gian phát, lặp, dừng, tốc độ và trọng số hòa trộn. Tài liệu Scene cho phép duyệt `parsedAnimations`, tìm animation theo tên và tạo clip bằng `createAnimationClip`. Engine cập nhật clip đang phát, nên không được vừa để engine điều khiển vừa tự tăng thời gian của cùng clip mà không có chủ đích. [LT09]

Quy trình hợp lý là liệt kê tên clip, thử một clip, kiểm tra lặp và sau đó thử chuyển trạng thái. Hòa trộn giúp giảm thay đổi tư thế đột ngột, nhưng phải bảo đảm các clip được tác giả tạo cho cùng cấu trúc xương. Một hoạt ảnh ném bóng chỉ mô tả hình ảnh; thời điểm bóng rời tay, quyền giữ bóng và kết quả cú ném vẫn thuộc logic game. Không dùng việc một clip đã chạy xong làm bằng chứng bóng hợp lệ vào rổ.

## 2.6. Vòng lặp, nhập liệu và tích hợp giao diện Flutter

### 2.6.1. Cập nhật và hiển thị

Game cần nhận thao tác, cập nhật trạng thái và vẽ trạng thái đó. Thời gian khung hình không cố định, nên chuyển động dựa trên cộng một lượng vị trí mỗi frame sẽ phụ thuộc tốc độ máy. Cần sử dụng thời gian đã trôi qua hoặc một bước mô phỏng cố định phù hợp. Tài liệu Scene mô tả `update` theo frame và `fixedUpdate` theo bước vật lý. Việc chọn đồng hồ nào phải gắn với loại hành vi: hiệu ứng thị giác có thể theo frame, còn mô phỏng cần quy tắc tiến thời gian rõ ràng. [LT03]

`SceneView` quản lý vòng kết xuất khi dùng widget. Nếu lập trình viên tự quản lý render loop, trách nhiệm tiến cảnh phải được xác định riêng. Không gọi thêm cập nhật thủ công chỉ vì một ví dụ sử dụng `CustomPainter` có làm như vậy; trộn hai cách có thể tiến mô phỏng hai lần. Đây là điểm cần kiểm tra khi chuyển ví dụ tài liệu thành cấu trúc ứng dụng. [LT03, LT11]

### 2.6.2. Nhập liệu và giao diện

Thao tác cảm ứng ban đầu là tọa độ trên widget. Muốn chọn đối tượng trong cảnh, phải chuyển điểm chạm thành tia trong không gian rồi kiểm tra giao cắt. Tài liệu hướng dẫn dùng `screenPointToRay` của camera và `scene.raycast`; kết quả chứa node và thông tin điểm chạm. Kích thước dùng chuyển đổi phải là kích thước vùng SceneView, không mặc định là toàn bộ màn hình. [LT10]

Đối với điều khiển nhân vật, lớp nhập liệu nên biến cử chỉ thành lệnh có ý nghĩa, thay vì sửa trực tiếp điểm số hay vị trí từ mọi callback. Có thể bố trí HUD Flutter trên vùng kết xuất bằng cơ chế bố cục thông thường. Cần tách tần suất cập nhật HUD với chuyển động 3D để hạn chế rebuild không cần thiết. Khi mất chạm, ứng dụng vào nền hoặc người chơi mở màn hình khác, trạng thái nút giữ cần được xóa theo quy tắc, tránh hành động tiếp tục ngoài ý muốn. Những quy tắc này thuộc thiết kế ứng dụng, không phải tính năng tự động được bảo đảm bởi engine.

## 2.7. Chuyển động, va chạm và tính điểm

### 2.7.1. Vật thể và thế giới vật lý

Vật thể đồ họa và vật thể va chạm có vai trò khác nhau. Mesh phục vụ hiển thị, collider phục vụ phát hiện hoặc giải quyết tiếp xúc. Rigid body lưu cách vật thể tham gia mô phỏng, chẳng hạn đứng yên hoặc chuyển động dưới tác động vật lý. Collider đơn giản có thể gần đúng hình dạng phức tạp để giảm chi phí, nhưng độ gần đúng phải đủ cho tương tác cần mô phỏng.

`flutter_scene_rapier` triển khai hợp đồng vật lý của hệ sinh thái Scene thông qua Rapier; tài liệu mô tả rigid body, collider, joint, truy vấn và sự kiện. Quy trình bắt đầu bằng khởi tạo backend, gắn `PhysicsWorld` vào gốc cảnh, tạo body rồi collider cho node, thiết lập trọng lực và theo dõi sự kiện. Không nên đồng thời gán transform đồ họa theo một logic độc lập và yêu cầu rigid body động điều khiển cùng đối tượng. [LT11]

### 2.7.2. Trình tự nghiên cứu chuyển động

Để kiểm chứng một quả bóng, trước hết dùng mặt sàn và hình cầu đơn giản; kiểm tra rơi, chạm sàn và độ nảy; tiếp theo thêm bảng hoặc vật cản; cuối cùng mới xét vùng rổ. Bóng chuyển động nhanh có thể đi qua vùng hẹp giữa hai bước mô phỏng, nên cần kiểm tra kích thước collider, bước thời gian và giải pháp liên tục mà backend thực sự hỗ trợ. Không khẳng định API chống xuyên vật thể sẵn có khi chưa đối chiếu phiên bản.

Phát hiện va chạm chưa đủ để tính điểm. Logic cần phân biệt bóng chạm vành với bóng đi qua vùng hợp lệ, hướng đi, trạng thái cú ném và việc đã cộng điểm. Đây là ví dụ của sự phân chia giữa dịch vụ engine và quy tắc nghiệp vụ game. Với game arcade, quỹ đạo có thể được điều khiển theo công thức; với mô phỏng động lực học, vận tốc và tiếp xúc tác động liên tục. Hai cách cần được so sánh theo mục tiêu nghiên cứu, không tự coi là tương đương hoặc bảo đảm tất định giữa các máy.

## 2.8. Kết nối và đồng bộ game thời gian thực

Mạng truyền thông điệp giữa các tiến trình; engine kết xuất không tự giải quyết toàn bộ luật phiên chơi. Cần xác định nơi quyết định trạng thái, nơi gửi thao tác và cách xử lý khi thông điệp đến muộn. Mô hình máy chủ quyết định trạng thái giúp tập trung việc kiểm tra luật; máy khách có thể làm mượt hiển thị, nhưng kết quả cuối vẫn phải theo nguồn được giao quyền. Đây là nguyên tắc thiết kế của một giải pháp, chưa phải kiến trúc đã triển khai của đề tài.

Tài liệu `flutter_scene_net` mô tả việc gắn replica với node, tạo hoặc xóa node theo trạng thái máy chủ và nội suy transform. Nội suy hiển thị vị trí ở một thời điểm trước hiện tại để giảm giật do nhịp nhận không đều; đổi lại có độ trễ hình ảnh. Nó không tự quyết định quyền sở hữu bóng, điểm hay điều kiện thắng. `SceneHost` hỗ trợ listener WebSocket trong ứng dụng native, nhưng việc host chạy trên điện thoại không đồng nghĩa điện thoại ở mạng khác sẽ kết nối được. [LT12]

Đối với Internet, cần một điểm kết nối có thể tiếp cận, hoặc cơ chế chuyển tiếp phù hợp. NAT, firewall, chứng chỉ, địa chỉ máy chủ, vòng đời ứng dụng và bảo vệ dữ liệu đầu vào là những phần cần đánh giá riêng. Hiện chỉ có một điện thoại, nên một client trên máy tính hỗ trợ thử trao đổi thông điệp; kết quả đó không thay thế kiểm chứng hai Android từ hai mạng khác nhau.

Quy trình nghiên cứu gồm: thử kết nối và ngắt kết nối; truyền một trạng thái nhỏ; gắn mã phiên và số thứ tự; đồng bộ một đối tượng; sau đó mới thêm nội suy, lệnh game và xử lý ngoại lệ. Độ trễ khứ hồi khác độ trễ từ thao tác tới hiển thị, nên báo cáo phải nêu cách đo. Không lấy timestamp của hai máy trừ trực tiếp khi chưa giải quyết sai lệch đồng hồ. Các thông số tick, snapshot và bộ đệm là tham số cần thử, không có một giá trị tối ưu mặc định cho mọi thiết bị.

## 2.9. Hướng dẫn từng bước dựng cảnh mẫu và tích hợp các thành phần

Quy trình dưới đây là hướng dẫn để thực hiện sau, chưa phải biên bản chạy thành công. Nên dùng một project thử riêng để lỗi API không ảnh hưởng nội dung luận văn hoặc mã demo chính.

**Bước 1 — ghi môi trường.** Thu thập `flutter --version`, `flutter doctor -v` và `flutter devices`. Ghi model, Android và chế độ build của điện thoại khi có kết nối. Không đưa số định danh hoặc dữ liệu cá nhân vào báo cáo công khai.

**Bước 2 — tạo ứng dụng mẫu.** Tạo Flutter project với Android, thêm dependency `flutter_scene` theo phiên bản được chọn và lưu lockfile. Lệnh tài liệu là `flutter pub add flutter_scene`; với nghiên cứu cần ghi lại phiên bản resolve thay vì chỉ nói dùng bản mới nhất. Không nâng SDK giữa quá trình đo nếu chưa ghi nhận thay đổi. [LT01]

**Bước 3 — bật GPU.** Theo hướng dẫn hiện hành, Android có thể bật Flutter GPU qua metadata `io.flutter.embedding.android.EnableFlutterGPU` bên trong `application` của manifest; khi phát triển có cờ `--enable-flutter-gpu`. Kiểm tra đúng cú pháp tài liệu và phiên bản trước khi chạy. [LT01]

**Bước 4 — dựng hình học.** Tạo `Scene`, chờ tài nguyên engine cần thiết sẵn sàng, tạo một mesh từ hình học đơn giản và vật liệu, thêm node rồi hiển thị bằng `SceneView`. Khởi đầu chỉ với một đối tượng giúp phân biệt lỗi khởi tạo, camera và vật liệu. Dưới đây là mã giả tổ chức công việc, không phải API Dart có thể chạy trực tiếp:

```text
khởi tạo scene và tài nguyên dùng chung
tạo geometry → material → mesh → node
đặt node gần gốc tọa độ và thêm vào scene
tạo camera nhìn vào node
hiển thị SceneView cùng vùng thông báo trạng thái
```

**Bước 5 — thử biến đổi và quan sát.** Thay đổi vị trí theo từng trục; thêm một node con và di chuyển node cha; điều chỉnh camera. Kiểm tra vật thể bị cắt, nằm sau camera hoặc bị che trước khi kết luận không render. Sau đó thêm component chuyển động sử dụng thời gian trôi qua. [LT04, LT06]

**Bước 6 — thử vật liệu và ánh sáng.** So sánh một vật liệu màu phẳng với PBR; giữ hình học và camera không đổi. Điều chỉnh độ nhám, sau đó mới thêm texture hoặc nguồn sáng. Lưu ảnh minh họa thật khi đã chạy; không dùng ảnh thiết kế thay cho bằng chứng hiệu năng. [LT05, LT07]

**Bước 7 — thay mô hình và hoạt ảnh.** Nạp một GLB có giấy phép rõ ràng, kiểm tra tên node và animation; thử clip lặp trước rồi chuyển clip. Sau khi đường runtime hoạt động, đánh giá tiền xử lý asset và trạng thái loading. Tách lỗi đường dẫn, định dạng và thiếu clip thành các tình huống khác nhau. [LT08, LT09]

**Bước 8 — bổ sung tương tác.** Gắn cử chỉ với chọn đối tượng hoặc lệnh chuyển động, kiểm tra kích thước vùng chạm và việc thả tay. Sau đó mới thêm vật lý hoặc mạng, mỗi lần một cơ chế. Với Rapier, xác nhận body/collider bằng một vật rơi đơn giản; với mạng, xác nhận trạng thái một đối tượng trước khi ghép luật trận. [LT10–LT12]

**Bước 9 — ghi lại kết quả.** Lưu phiên bản, cấu hình, lệnh, log, ảnh và giới hạn của từng lần chạy. Chỉ sau khi có sản phẩm mới đưa số đo và kết luận đạt vào Chương 4. Chương này cung cấp nền tảng và cách thao tác để xây dựng; những lựa chọn riêng cho game sẽ được trình bày ở Chương 3.

## Tài liệu tham khảo của Chương 2

Các nguồn được đọc ngày 04/11/2026; đánh số LT là mã làm việc, sẽ thống nhất với danh mục toàn luận văn. Những trang hướng dẫn trực tuyến không có phiên bản cố định phải được đối chiếu lại với dependency đã chọn.

- [LT01] Flutter Scene, *Installation*: https://fscene.dev/getting-started/installation/ (đã đọc ngày 03/11/2026 trong khảo sát ban đầu; yêu cầu phiên bản cần kiểm tra khi triển khai).
- [LT02] Flutter Scene, gói `flutter_scene`, 0.24.3: https://pub.dev/packages/flutter_scene.
- [LT03] Flutter Scene, *Core concepts*: https://fscene.dev/getting-started/core-concepts/.
- [LT04] Flutter Scene, *Scene graph*: https://fscene.dev/guides/scene-graph/.
- [LT05] Flutter Scene, *Materials*: https://fscene.dev/guides/materials/.
- [LT06] Flutter Scene, *Cameras*: https://fscene.dev/guides/cameras/.
- [LT07] Flutter Scene, *Lighting and environment*: https://fscene.dev/guides/lighting-and-environment/.
- [LT08] Flutter Scene, *Assets and loading*: https://fscene.dev/guides/assets-and-loading/.
- [LT09] Flutter Scene, *Animation*: https://fscene.dev/guides/animation/.
- [LT10] Flutter Scene, *Picking and input*: https://fscene.dev/guides/picking-and-input/.
- [LT11] Gói `flutter_scene_rapier`, 0.5.2: https://pub.dev/packages/flutter_scene_rapier.
- [LT12] Gói `flutter_scene_net`, 0.2.2: https://pub.dev/packages/flutter_scene_net.
