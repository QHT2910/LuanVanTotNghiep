# Chương 2. Cơ sở lý thuyết

## 2.1. Các hệ thống tương tự

### 2.1.1. Engine và framework phát triển game

Các công cụ phát triển game được khảo sát theo cách tổ chức cảnh, khả năng làm game 3D trên Android và quan hệ với Flutter. Việc đối chiếu dựa trên tài liệu chính thức; chưa thực hiện phép đo để xếp hạng hiệu năng giữa các engine.

Godot là engine mã nguồn mở hỗ trợ game 2D và 3D, tổ chức dự án trong một giao diện biên tập thống nhất. Tài liệu có quy trình xuất ứng dụng sang Android, bao gồm thiết lập SDK và môi trường Java. Cách làm này phù hợp với dự án cần công cụ biên tập cảnh và quy trình xuất game riêng. Với đề tài đang nghiên cứu nội dung 3D trong Flutter, Godot là một hướng tiếp cận để đối chiếu cách xây dựng và quản lý cảnh, nhưng không thay thế đối tượng nghiên cứu Flutter Scene. [3], [4]

Flame được xây dựng trên Flutter và thường được dùng cho game 2D. Hệ sinh thái của dự án có `flame_3d`, một gói hỗ trợ kết xuất 3D đang ở giai đoạn thử nghiệm. Vì vậy, không thể kết luận Flame chỉ có khả năng giả lập 2.5D. Khi so sánh với Flutter Scene, cần phân biệt Flame cốt lõi với gói 3D đi kèm và đối chiếu đúng phiên bản. Hai hướng đều cho phép nghiên cứu nội dung game trong hệ sinh thái Flutter, nhưng API tổ chức cảnh và mức hỗ trợ của từng gói cần được khảo sát riêng. [5], [6]

Flutter Scene cung cấp các khái niệm cảnh, node, mesh, vật liệu, camera và hoạt ảnh trong ứng dụng Flutter. Đề tài chọn công cụ này để tìm hiểu cách phối hợp đồ họa 3D với giao diện và mã Dart. Lựa chọn đó xuất phát từ mục tiêu nghiên cứu; mức phù hợp với game bóng rổ sẽ được đánh giá thông qua demo và các phép thử sau khi triển khai. [2], [7]

| Công cụ | Đặc điểm liên quan đến đề tài | Nội dung cần đối chiếu |
|---|---|---|
| Godot | Có engine 2D/3D, giao diện biên tập và quy trình xuất Android | Cách tổ chức cảnh và quy trình phát triển game độc lập |
| Flame và flame_3d | Cùng hệ sinh thái Flutter; hỗ trợ 3D nằm trong gói thử nghiệm | Phạm vi API của gói cốt lõi và gói 3D, điều kiện phiên bản |
| Flutter Scene | Tích hợp cảnh 3D vào ứng dụng Flutter | Khởi tạo cảnh, tài nguyên, tương tác, hiệu năng trên thiết bị đích |

Những đặc điểm trên chưa đủ để kết luận công cụ nào nhanh hơn hoặc dễ học hơn. Một phép so sánh hiệu năng cần cùng cảnh, tài nguyên, thiết bị, chế độ build và cách đo; phạm vi hiện tại tập trung vào tìm hiểu Flutter Scene.

### 2.1.2. Game bóng rổ trên thiết bị di động

Basketball Stars của Miniclip là ví dụ về game bóng rổ nhiều người chơi trên thiết bị di động. Trang giới thiệu của nhà phát hành mô tả các hoạt động dẫn bóng, ném và ghi điểm. Đây là cơ sở tham khảo về chủ đề và hình thức đối kháng; trang giới thiệu không cung cấp đủ thông tin để xác định kiến trúc máy chủ, thuật toán đồng bộ hoặc công thức tính kết quả cú ném. [8]

Đối với demo Bóng rổ đối kháng 3D, các nội dung cần khảo sát từ sản phẩm cùng thể loại gồm bố trí nút điều khiển, cách báo người đang giữ bóng, phản hồi khi ném hoặc cản phá, bảng điểm và luồng vào trận. Khi thiết kế giao diện, cần ghi lại nguồn và giới hạn quan sát của từng nội dung thay vì suy đoán cơ chế bên trong từ hình ảnh quảng bá. Bản khảo sát hiện chưa bao gồm trải nghiệm chơi có ghi nhận thao tác hoặc phép đo trên Basketball Stars.

### 2.1.3. Nhận xét và định hướng của đề tài

Khảo sát cho thấy cần tách hai nhóm đối chiếu: công cụ phát triển giúp giải thích cách xây dựng hệ thống, còn game cùng thể loại giúp xác định những tương tác cần có trong vòng chơi. Đề tài không sao chép toàn bộ chức năng của một sản phẩm thương mại. Phạm vi demo gồm nửa sân, hai người, một bóng và các thao tác đã thống nhất; tài khoản, cửa hàng và giải đấu không nằm trong phần bắt buộc.

Nội dung nghiên cứu tiếp theo đi từ vai trò của Flutter Scene đến cách sử dụng từng thành phần. Những lựa chọn riêng về luật, kết nối và giao diện của demo được trình bày ở Chương 3.

## 2.2. Tổng quan Flutter Scene và nền tảng Flutter GPU/Impeller

Flutter Scene là bộ công cụ xây dựng nội dung ba chiều trong ứng dụng Flutter. Thay vì chỉ mô tả các thành phần giao diện hai chiều, lập trình viên tổ chức đối tượng trong một không gian có vị trí, hướng, kích thước và góc quan sát. Cảnh ba chiều sau khi kết xuất vẫn tham gia bố cục ứng dụng thông qua widget, nên màn hình có thể kết hợp vùng hiển thị thế giới 3D với nút bấm, thông báo và bảng thông tin Flutter.

Trong kiến trúc này, cần phân biệt ba lớp trách nhiệm. Flutter quản lý ứng dụng và giao diện. Flutter GPU cung cấp khả năng sử dụng tài nguyên và lệnh đồ họa ở mức thấp. Scene tổ chức những khái niệm thuận tiện hơn như cảnh, đối tượng, lưới, vật liệu và camera. Trên nền tảng native, tài liệu Scene xác định Flutter GPU và Impeller là nền tảng kết xuất; trên web sử dụng backend riêng. Vì vậy, mã điều khiển game không cần tự xây dựng toàn bộ đường ống đồ họa, nhưng vẫn phải quan tâm giới hạn tài nguyên và tương thích thiết bị. [2], [7]

Quy trình tìm hiểu gồm: xác định phiên bản Flutter yêu cầu; chọn phiên bản Scene; đọc API tương ứng; dựng ví dụ nhỏ; sau đó mới bổ sung tài nguyên phức tạp. Hướng dẫn hiện yêu cầu Flutter 3.47 stable trở lên và bật Flutter GPU cho Android. Phiên bản Flutter cục bộ đã ghi nhận là 3.47.8, nhưng con số này chỉ chứng minh điều kiện phiên bản ban đầu, không chứng minh ứng dụng đã chạy trên Redmi Note 11. Scene còn trước phiên bản 1.0, nên phải lưu phiên bản dependency, lockfile và thay đổi API liên quan. [2]

Bật Flutter GPU khác với bật Impeller. Theo tài liệu Flutter, Impeller mặc định trên Android API 29 trở lên; thiết bị ở API thấp hơn hoặc không hỗ trợ Vulkan có thể dùng bộ kết xuất OpenGL cũ. Cần ghi Android API, GPU và backend thực tế; fallback đồ họa Flutter không tự chứng minh Flutter GPU hoặc Scene hoạt động trên thiết bị đó. [9]

## 2.3. Đồ thị cảnh, node, hệ tọa độ và phép biến đổi

### 2.3.1. Scene và Node

`Scene` là đối tượng quản lý cảnh. Bên dưới cảnh là cây các `Node`; một node có thể chứa phần hiển thị, node con và hành vi. Cách tổ chức phân cấp giúp biểu diễn những quan hệ như vật thể được gắn vào tay nhân vật hoặc camera đi theo một điểm điều khiển. Di chuyển node cha làm thay đổi vị trí thế giới của các node con mà không cần cập nhật từng đối tượng riêng. [10], [11]

Vị trí cục bộ được hiểu theo hệ tọa độ của cha, còn vị trí thế giới được hiểu theo toàn cảnh. Với một node con, ma trận biến đổi thế giới được tính từ ma trận thế giới của cha nhân với ma trận cục bộ. Do phép nhân ma trận không giao hoán, thay đổi thứ tự tịnh tiến, xoay và co giãn có thể tạo kết quả khác nhau. Khi nhập tài nguyên từ phần mềm dựng hình, cần thống nhất chiều cao, hướng nhìn và tỷ lệ thay vì sửa bằng nhiều phép xoay rời rạc không có quy ước.

### 2.3.2. Cách sử dụng từng bước

1. Tạo một `Scene` và node đại diện cho đối tượng.
2. Gắn hình học, vật liệu hoặc hành vi cần thiết vào node.
3. Gắn node vào cảnh bằng `scene.add`, hoặc vào node cha bằng `node.add`.
4. Gán vị trí, góc xoay và tỷ lệ theo hệ tọa độ đã chọn.
5. Quan sát riêng từng phép biến đổi trước khi ghép thành một phân cấp phức tạp.

Tài liệu cung cấp thuộc tính `position`, `rotation`, `scale` và `localTransform`. Theo README 0.24.3, các getter thành phần biến đổi trả về bản sao. Ví dụ sử dụng `node.position = vm.Vector3(0, 1, 0)` để gán lại; khi đổi ma trận, ưu tiên gán một `localTransform` mới và đối chiếu API của phiên bản đã khóa. Với hành vi liên tục, nên gom cập nhật vào một nơi, tránh widget và logic mô phỏng đồng thời ghi cùng thuộc tính. [7], [11]

### 2.3.3. Component và quyền sở hữu

`Component` đóng gói hành vi gắn với node. Tài liệu mô tả thứ tự vòng đời `onAttach → onLoad → onMount → update/fixedUpdate → onUnmount → onDetach`. `onLoad` thiết lập bất đồng bộ một lần; cập nhật chờ bước này hoàn tất. `update` chạy theo frame, còn `fixedUpdate` theo bước vật lý. Đây là mô tả tài liệu, chưa phải kết quả thử tái gắn node. Việc gom chuyển động hoặc tương tác vào component giúp giảm mã cập nhật phân tán. Scene hỗ trợ cả khai báo cấu trúc bằng widget và thao tác cây cảnh trực tiếp. Hai cách cùng sử dụng đối tượng bên dưới, nhưng phải rõ bên nào sở hữu cấu trúc và thuộc tính: một giá trị do widget khai báo có thể được áp dụng lại khi widget rebuild. [10]

## 2.4. Hình học, mesh và vật liệu

### 2.4.1. Vai trò từng thành phần

Hình học mô tả hình dạng thông qua đỉnh, chỉ số nối đỉnh và các thuộc tính phục vụ tô bóng. Vật liệu mô tả phản ứng của bề mặt với ánh sáng. `Mesh` ghép hình học với vật liệu để tạo phần có thể được kết xuất. Một khối cầu giống nhau có thể được biểu diễn như nhựa, kim loại hoặc bề mặt màu phẳng khi thay vật liệu; ngược lại, cùng một vật liệu có thể dùng cho nhiều hình dạng. [10], [12]

Scene cung cấp hình học cơ bản, phù hợp để học API và tạo nguyên mẫu. Ưu điểm của nguyên mẫu từ các khối là không phụ thuộc quy trình nhập mô hình và dễ nhận biết lỗi tỷ lệ. Tuy nhiên, số node và lưới vẫn cần kiểm soát; chia một vật thể đơn giản thành quá nhiều đối tượng độc lập có thể làm tăng chi phí quản lý và vẽ.

### 2.4.2. Vật liệu PBR và vật liệu không chiếu sáng

`PhysicallyBasedMaterial` sử dụng những tham số như màu cơ sở, độ kim loại và độ nhám. Độ kim loại ảnh hưởng cách phản xạ, còn độ nhám điều chỉnh độ sắc của phản chiếu. Không nên xem tăng độ sáng màu cơ sở là cách thay thế ánh sáng, vì hai thao tác giải quyết hai vấn đề khác nhau. `UnlitMaterial` hiển thị bề mặt không phụ thuộc hệ chiếu sáng, thuận tiện cho đánh dấu, kiểm tra hình học hoặc phong cách giản lược. [12]

Để sử dụng, trước hết chọn hình học; tiếp theo tạo vật liệu, điều chỉnh một nhóm tham số và ghép thành mesh; cuối cùng gắn mesh vào node. Nên thay một tham số mỗi lần để nhận biết tác động. Khi dùng texture, phải kiểm tra đường dẫn, tọa độ UV, độ phân giải và thông tin màu của tài nguyên. Tài liệu phân biệt texture màu cơ sở, normal, metallic–roughness và các kênh khác; chúng không thể thay thế tùy ý cho nhau. Vật liệu và hình học gắn với tài nguyên GPU nên cần tái sử dụng, tránh tạo lại liên tục trong mỗi khung hình. [10], [12]

## 2.5. Camera và ánh sáng

### 2.5.1. Camera

Camera quyết định vùng thế giới được chiếu lên màn hình. Phép chiếu phối cảnh làm vật ở xa có kích thước biểu kiến nhỏ hơn vật ở gần, hỗ trợ nhận biết chiều sâu. Các tham số quan trọng gồm vị trí, điểm nhìn, hướng lên, góc nhìn và mặt phẳng cắt. Mặt phẳng gần hoặc xa đặt không hợp lý có thể cắt mất vật thể hoặc làm việc phân biệt độ sâu kém hiệu quả. [13]

Quy trình thiết lập bắt đầu bằng một camera cố định nhìn vào gốc tọa độ. Sau khi xác nhận đối tượng hiển thị đúng, mới thay đổi độ cao, khoảng cách và góc nhìn. Trong Scene, có thể truyền `PerspectiveCamera` trực tiếp vào `SceneView`, hoặc dùng `cameraBuilder` để tạo góc quan sát thay đổi theo thời gian. Với camera thuộc phân cấp cảnh, tài liệu giới thiệu `CameraComponent` và camera chính của scene. Chọn cách nào phụ thuộc việc camera chỉ quan sát cố định hay cần gắn vào cấu trúc chuyển động. [13]

### 2.5.2. Ánh sáng và môi trường

Ánh sáng giúp người quan sát nhận biết hình khối, vật liệu và độ cao. Chiếu sáng dựa trên ảnh môi trường mô phỏng ánh sáng tới từ nhiều hướng; nguồn sáng có hướng bổ sung đặc tính như mặt trời và bóng đổ. Skybox là phần nền nhìn thấy, không đồng nhất với nguồn chiếu sáng. Chỉ đổi nền chưa chắc làm đối tượng sáng lên, và đổi môi trường chiếu sáng cũng không tự bảo đảm nền tương ứng được vẽ. [14]

Tài liệu Scene mô tả môi trường mặc định cho cảnh mới, giúp bắt đầu với vật liệu PBR mà chưa phải dựng hệ đèn riêng. Quy trình học nên giữ môi trường mặc định, xác nhận vật liệu, rồi mới thử panorama hoặc đèn có hướng. Nếu thêm bóng đổ, cần so sánh cả hình ảnh lẫn thời gian khung hình. Hậu xử lý, phơi sáng và tone mapping là những bước điều chỉnh đầu ra; không nên bật hàng loạt hiệu ứng trước khi có một cấu hình cơ sở để đối chiếu. [14]

## 2.6. Tài nguyên, mô hình và hoạt ảnh

### 2.6.1. Nạp mô hình

Một mô hình có thể chứa phân cấp node, lưới, vật liệu, texture và hoạt ảnh. Định dạng glTF/GLB giúp trao đổi những dữ liệu này, nhưng việc một engine hỗ trợ định dạng không đồng nghĩa hỗ trợ mọi extension hoặc mọi cấu hình xuất. Cần kiểm tra bằng mô hình nhỏ trước, ghi công cụ xuất, tỷ lệ, giấy phép và những tính năng đã dùng. [15]

Scene có hai đường nạp chính. `Node.fromGlbAsset` nạp GLB trong asset bundle tại runtime; sau khi hoàn tất, node được thêm vào cảnh. Đường còn lại chuyển tài nguyên khi build rồi dùng `loadScene` theo đường dẫn nguồn. Tiền xử lý giúp chuyển công việc khỏi thời điểm mở cảnh, nhưng đầu ra phụ thuộc quy trình build và phải được quản lý cùng nguồn tài nguyên. [15]

Các bước sử dụng gồm: chuẩn bị mô hình có quyền sử dụng; khai báo hoặc đưa vào pipeline phù hợp; nạp bất đồng bộ; hiển thị trạng thái chờ hoặc lỗi; đặt tỷ lệ và vị trí; cuối cùng kiểm tra hình ảnh trên thiết bị. Không nên bỏ qua trạng thái lỗi rồi xem mô hình không hiển thị như một lỗi camera. Khi tài nguyên lớn, thời gian nạp, bộ nhớ và khung hình đầu đều là các khía cạnh cần ghi nhận riêng. [15]

### 2.6.2. Hoạt ảnh

Hoạt ảnh mô tả sự thay đổi theo thời gian của tư thế hoặc thuộc tính mô hình. Clip phát lại là đối tượng có trạng thái riêng: thời gian phát, lặp, dừng, tốc độ và trọng số hòa trộn. Tài liệu Scene cho phép duyệt `parsedAnimations`, tìm animation theo tên và tạo clip bằng `createAnimationClip`. `Animation` chứa dữ liệu hoạt ảnh, còn `AnimationClip` giữ trạng thái phát. Khi tra bằng `findAnimationByName`, cần kiểm tra kết quả khác null trước khi gọi `createAnimationClip`. Clip không lặp tự tạm dừng ở keyframe cuối. Khi dùng vòng lặp do `SceneView` quản lý, không tự tiến cùng clip lần nữa. [16]

Quy trình hợp lý là liệt kê tên clip, thử một clip, kiểm tra lặp và sau đó thử chuyển trạng thái. Hòa trộn giúp giảm thay đổi tư thế đột ngột, nhưng phải bảo đảm các clip được tác giả tạo cho cùng cấu trúc xương. Một hoạt ảnh ném bóng chỉ mô tả hình ảnh; thời điểm bóng rời tay, quyền giữ bóng và kết quả cú ném vẫn thuộc logic game. Không dùng việc một clip đã chạy xong làm bằng chứng bóng hợp lệ vào rổ.

## 2.7. Vòng lặp, nhập liệu và tích hợp giao diện Flutter

### 2.7.1. Cập nhật và hiển thị

Game cần nhận thao tác, cập nhật trạng thái và vẽ trạng thái đó. Thời gian khung hình không cố định, nên chuyển động dựa trên cộng một lượng vị trí mỗi frame sẽ phụ thuộc tốc độ máy. Cần sử dụng thời gian đã trôi qua hoặc một bước mô phỏng cố định phù hợp. Tài liệu Scene mô tả `update` theo frame và `fixedUpdate` theo bước vật lý. Việc chọn đồng hồ nào phải gắn với loại hành vi: hiệu ứng thị giác có thể theo frame, còn mô phỏng cần quy tắc tiến thời gian rõ ràng. [10]

`SceneView` quản lý vòng kết xuất khi dùng widget. Nếu lập trình viên tự quản lý render loop, trách nhiệm tiến cảnh phải được xác định riêng: chọn `SceneView` quản lý hoặc vòng lặp thủ công gọi `update` và `render`. Không gọi thêm cập nhật thủ công chỉ vì một ví dụ sử dụng `CustomPainter` có làm như vậy; trộn hai cách có thể tiến mô phỏng hai lần. Đây là điểm cần kiểm tra khi chuyển ví dụ tài liệu thành cấu trúc ứng dụng. [10], [17]

### 2.7.2. Nhập liệu và giao diện

Thao tác cảm ứng ban đầu là tọa độ trên widget. Muốn chọn đối tượng trong cảnh, phải chuyển điểm chạm thành tia trong không gian rồi kiểm tra giao cắt. Tài liệu hướng dẫn dùng `screenPointToRay` của camera và `scene.raycast`; kết quả chứa node và thông tin điểm chạm. `Scene.raycast` kiểm tra hình học render; truy vấn thế giới vật lý kiểm tra collision shapes. Việc chọn đối tượng hiển thị và xử lý va chạm có thể cần hai truy vấn khác nhau. Kích thước dùng chuyển đổi phải là kích thước vùng SceneView, không mặc định là toàn bộ màn hình. [18]

Đối với điều khiển nhân vật, lớp nhập liệu nên biến cử chỉ thành lệnh có ý nghĩa, thay vì sửa trực tiếp điểm số hay vị trí từ mọi callback. Có thể bố trí HUD Flutter trên vùng kết xuất bằng cơ chế bố cục thông thường. Cần tách tần suất cập nhật HUD với chuyển động 3D để hạn chế rebuild không cần thiết. Khi mất chạm, ứng dụng vào nền hoặc người chơi mở màn hình khác, trạng thái nút giữ cần được xóa theo quy tắc, tránh hành động tiếp tục ngoài ý muốn. Những quy tắc này thuộc thiết kế ứng dụng, không phải tính năng tự động được bảo đảm bởi engine.

## 2.8. Chuyển động, va chạm và tính điểm

### 2.8.1. Vật thể và thế giới vật lý

Vật thể đồ họa và vật thể va chạm có vai trò khác nhau. Mesh phục vụ hiển thị, collider phục vụ phát hiện hoặc giải quyết tiếp xúc. Rigid body lưu cách vật thể tham gia mô phỏng, chẳng hạn đứng yên hoặc chuyển động dưới tác động vật lý. Collider đơn giản có thể gần đúng hình dạng phức tạp để giảm chi phí, nhưng độ gần đúng phải đủ cho tương tác cần mô phỏng.

`flutter_scene_rapier` triển khai hợp đồng vật lý của hệ sinh thái Scene thông qua Rapier; tài liệu mô tả rigid body, collider, joint, truy vấn và sự kiện. Theo ví dụ của `flutter_scene_rapier` 0.5.2, quy trình bắt đầu bằng `RapierWorld.ensureInitialized()`, gắn `PhysicsWorld` vào `scene.root`, tạo body trước collider cho node, thiết lập trọng lực và theo dõi sự kiện. Không nên đồng thời gán transform đồ họa theo một logic độc lập và yêu cầu rigid body động điều khiển cùng đối tượng. [17]

### 2.8.2. Trình tự nghiên cứu chuyển động

Để kiểm chứng một quả bóng, trước hết dùng mặt sàn và hình cầu đơn giản; kiểm tra rơi, chạm sàn và độ nảy; tiếp theo thêm bảng hoặc vật cản; cuối cùng mới xét vùng rổ. Bóng chuyển động nhanh có thể đi qua vùng hẹp giữa hai bước mô phỏng, nên cần kiểm tra kích thước collider, bước thời gian và giải pháp liên tục mà backend thực sự hỗ trợ. Không khẳng định API chống xuyên vật thể sẵn có khi chưa đối chiếu phiên bản.

Phát hiện va chạm chưa đủ để tính điểm. Logic cần phân biệt bóng chạm vành với bóng đi qua vùng hợp lệ, hướng đi, trạng thái cú ném và việc đã cộng điểm. Đây là ví dụ của sự phân chia giữa dịch vụ engine và quy tắc nghiệp vụ game. Với game arcade, quỹ đạo có thể được điều khiển theo công thức; với mô phỏng động lực học, vận tốc và tiếp xúc tác động liên tục. Hai cách cần được so sánh theo mục tiêu nghiên cứu, không tự coi là tương đương hoặc bảo đảm tất định giữa các máy.

## 2.9. Kết nối và đồng bộ game thời gian thực

Mạng truyền thông điệp giữa các tiến trình; engine kết xuất không tự giải quyết toàn bộ luật phiên chơi. Cần xác định nơi quyết định trạng thái, nơi gửi thao tác và cách xử lý khi thông điệp đến muộn. Mô hình máy chủ quyết định trạng thái giúp tập trung việc kiểm tra luật; máy khách có thể làm mượt hiển thị, nhưng kết quả cuối vẫn phải theo nguồn được giao quyền. Đây là nguyên tắc thiết kế của một giải pháp, chưa phải kiến trúc đã triển khai của đề tài.

Tài liệu `flutter_scene_net` mô tả việc gắn replica với node, tạo hoặc xóa node theo trạng thái máy chủ và nội suy transform. Nội suy hiển thị vị trí ở một thời điểm trước hiện tại để giảm giật do nhịp nhận không đều; đổi lại có độ trễ hình ảnh. Nó không tự quyết định quyền sở hữu bóng, điểm hay điều kiện thắng. `SceneHost` hỗ trợ listener WebSocket trong ứng dụng native, nhưng việc host chạy trên điện thoại không đồng nghĩa điện thoại ở mạng khác sẽ kết nối được. [19]

Đối với Internet, cần một điểm kết nối có thể tiếp cận, hoặc cơ chế chuyển tiếp phù hợp. NAT, firewall, chứng chỉ, địa chỉ máy chủ, vòng đời ứng dụng và bảo vệ dữ liệu đầu vào là những phần cần đánh giá riêng. Hiện chỉ có một điện thoại, nên một client trên máy tính hỗ trợ thử trao đổi thông điệp; kết quả đó không thay thế kiểm chứng hai Android từ hai mạng khác nhau.

Quy trình nghiên cứu gồm: thử kết nối và ngắt kết nối; truyền một trạng thái nhỏ; gắn mã phiên và số thứ tự; đồng bộ một đối tượng; sau đó mới thêm nội suy, lệnh game và xử lý ngoại lệ. Độ trễ khứ hồi khác độ trễ từ thao tác tới hiển thị, nên báo cáo phải nêu cách đo. Không lấy timestamp của hai máy trừ trực tiếp khi chưa giải quyết sai lệch đồng hồ. Các thông số tick, snapshot và bộ đệm là tham số cần thử, không có một giá trị tối ưu mặc định cho mọi thiết bị.

## 2.10. Hướng dẫn từng bước dựng cảnh mẫu và tích hợp các thành phần

Quy trình bắt đầu bằng một project thử riêng, sau đó bổ sung từng thành phần. Ví dụ dựng khối cơ bản đã được kiểm tra phân tích tĩnh và compile bundle với bộ phiên bản của probe; khả năng khởi tạo GPU và hiển thị trên Android vẫn cần được kiểm tra trên thiết bị.

Bước 1: ghi môi trường. Thu thập `flutter --version`, `flutter doctor -v` và `flutter devices`. Ghi model, Android và chế độ build của điện thoại khi có kết nối. Không đưa số định danh hoặc dữ liệu cá nhân vào báo cáo công khai.

Bước 2: tạo ứng dụng mẫu. Tạo Flutter project với Android, thêm dependency `flutter_scene` theo phiên bản được chọn và lưu lockfile. Lệnh tài liệu là `flutter pub add flutter_scene`; với nghiên cứu cần ghi lại phiên bản resolve thay vì chỉ nói dùng bản mới nhất. Không nâng SDK giữa quá trình đo nếu chưa ghi nhận thay đổi. [2]

Bước 3: bật GPU. Theo hướng dẫn hiện hành, Android có thể bật Flutter GPU qua metadata `io.flutter.embedding.android.EnableFlutterGPU` bên trong `application` của manifest; khi phát triển có cờ `--enable-flutter-gpu`. Metadata này cần có `android:value="true"` trong `<application>`. Bật cờ GPU không thay cho kiểm tra backend Android và khả năng hỗ trợ của thiết bị. Kiểm tra đúng cú pháp tài liệu và phiên bản trước khi chạy. [2], [9]

Bước 4: dựng hình học. Ví dụ dưới đây sử dụng API `flutter_scene` 0.24.3 để tạo một khối cơ bản. `Scene.initializeStaticResources()` hoàn tất trước khi tạo geometry và material. `FutureBuilder` hiển thị trạng thái đang chờ hoặc lỗi trong lúc khởi tạo, rồi chuyển sang `SceneView` khi tài nguyên sẵn sàng. Nếu dùng `setState` sau `await` thay cho cách này, cần kiểm tra widget còn mounted. [7], [10]

```dart
import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() => runApp(const MaterialApp(home: SceneProbe()));

class SceneProbe extends StatefulWidget {
  const SceneProbe({super.key});
  @override
  State<SceneProbe> createState() => _SceneProbeState();
}

class _SceneProbeState extends State<SceneProbe> {
  final Scene scene = Scene();
  late final Future<void> ready;

  @override
  void initState() {
    super.initState();
    ready = initialize();
  }

  Future<void> initialize() async {
    await Scene.initializeStaticResources();
    scene.add(Node(mesh: Mesh(
      CuboidGeometry(vm.Vector3(1, 1, 1)),
      PhysicallyBasedMaterial(),
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<void>(
      future: ready,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Scene initialization failed: ${snapshot.error}'));
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return SceneView(scene,
          camera: PerspectiveCamera(position: vm.Vector3(2, 2, -4)));
      },
    ),
  );
}
```

Compile bundle chỉ kiểm tra đường biên dịch và tài nguyên đầu ra, chưa xác nhận cảnh đã render thành công trên thiết bị. Việc kiểm tra hiển thị cần bật Flutter GPU, chọn đúng thiết bị và ghi lại backend đang sử dụng.

Bước 5: thử biến đổi và quan sát. Thay đổi vị trí theo từng trục; thêm một node con và di chuyển node cha; điều chỉnh camera. Kiểm tra vật thể bị cắt, nằm sau camera hoặc bị che trước khi kết luận không render. Sau đó thêm component chuyển động sử dụng thời gian trôi qua. [11], [13]

Bước 6: thử vật liệu và ánh sáng. So sánh một vật liệu màu phẳng với PBR; giữ hình học và camera không đổi. Điều chỉnh độ nhám, sau đó mới thêm texture hoặc nguồn sáng. Lưu ảnh minh họa thật khi đã chạy; không dùng ảnh thiết kế thay cho bằng chứng hiệu năng. [12], [14]

Bước 7: thay mô hình và hoạt ảnh. Nạp một GLB có giấy phép rõ ràng, kiểm tra tên node và animation; thử clip lặp trước rồi chuyển clip. Sau khi đường runtime hoạt động, đánh giá tiền xử lý asset và trạng thái loading. Tách lỗi đường dẫn, định dạng và thiếu clip thành các tình huống khác nhau. [15], [16]

Bước 8: bổ sung tương tác. Gắn cử chỉ với chọn đối tượng hoặc lệnh chuyển động, kiểm tra kích thước vùng chạm và việc thả tay. Sau đó mới thêm vật lý hoặc mạng, mỗi lần một cơ chế. Với Rapier, xác nhận body/collider bằng một vật rơi đơn giản; với mạng, xác nhận trạng thái một đối tượng trước khi ghép luật trận. [18], [17], [19]

Bước 9: ghi lại kết quả. Lưu phiên bản, cấu hình, lệnh, log, ảnh và giới hạn của từng lần chạy. Chỉ sau khi có sản phẩm mới đưa số đo và kết luận đạt vào Chương 4. Chương này cung cấp nền tảng và cách thao tác để xây dựng; những lựa chọn riêng cho game sẽ được trình bày ở Chương 3.
