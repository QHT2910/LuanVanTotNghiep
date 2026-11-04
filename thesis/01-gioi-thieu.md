# Chương 1. Giới thiệu

## 1.1. Đặt vấn đề, mục tiêu luận văn

### 1.1.1. Đặt vấn đề

Game 3D trên mobile cần phối hợp cảnh, kết xuất, nhập liệu, chuyển động, luật và tài nguyên. Khi chơi qua mạng, các thiết bị phải thống nhất diễn biến dù thông điệp đến không đồng thời. Vì vậy, nghiên cứu engine cần xem xét từng thành phần lẫn cách tích hợp trong ứng dụng.

Flutter Scene, được phân phối qua gói `flutter_scene`, là một engine 3D dành cho Flutter. Tài liệu của dự án giới thiệu việc tổ chức đồ thị cảnh, mô hình, vật liệu, ánh sáng, camera và hoạt ảnh trong môi trường Flutter, dựa trên Flutter GPU và Impeller ở các nền tảng native [SCENE-01], [SCENE-02]. Hướng tiếp cận này cho phép nghiên cứu sự kết hợp giữa giao diện Flutter và nội dung 3D trong cùng một ứng dụng Dart. Tuy nhiên, việc một thành phần được giới thiệu trong tài liệu không đồng nghĩa toàn bộ game dự kiến sẽ hoạt động phù hợp trên thiết bị và cấu hình mạng của đề tài.

Đề tài lựa chọn game bóng rổ đối kháng 3D làm tình huống ứng dụng để nghiên cứu Flutter Scene. Không gian sân, nhân vật, quả bóng và rổ giúp minh họa rõ vai trò của hình học, phép biến đổi, camera và chuyển động. Các hành động di chuyển, giữ bóng, ném và tranh bóng tạo điều kiện khảo sát mối liên hệ giữa trạng thái logic với hình ảnh hiển thị. Khi hai người chơi tham gia từ hai thiết bị, bài toán còn mở rộng sang trao đổi thao tác, đồng bộ bóng, cập nhật điểm và kết thúc trận nhất quán.

Luận văn nghiên cứu công nghệ qua một demo có phạm vi kiểm soát được. Các luật giản lược phải được phân biệt với luật thể thao chính thức. Hai người chơi từ hai mạng khác nhau qua Internet là hướng ưu tiên, cần kiểm chứng cùng phương án máy chủ và điều kiện triển khai.

### 1.1.2. Mục tiêu của đề tài

Mục tiêu tổng quát là nghiên cứu các thành phần và cách sử dụng Flutter Scene, ứng dụng để thiết kế và xây dựng demo game bóng rổ đối kháng 3D trên Android, từ đó đánh giá mức độ phù hợp của công nghệ đối với phạm vi đã chọn.

Các mục tiêu cụ thể gồm:

- Làm rõ vai trò của Flutter Scene trong hệ thống, quan hệ với Flutter GPU/Impeller và cách tổ chức cảnh 3D.
- Trình bày chức năng, cách phối hợp và hướng dẫn sử dụng từng bước đối với các thành phần cần thiết cho demo.
- Đặc tả gameplay, thao tác, trạng thái và tình huống biên; xây dựng các mô hình thiết kế có thể đối chiếu với yêu cầu.
- Lựa chọn cách xử lý chuyển động, ném bóng và ghi điểm phù hợp với quy mô nghiên cứu; tách trạng thái gameplay khỏi phần trình bày.
- Thiết kế kết nối hai người và cơ chế thống nhất trạng thái; ưu tiên khả năng chơi qua Internet nếu đáp ứng điều kiện kỹ thuật.
- Xây dựng demo, thu thập bằng chứng thực nghiệm và phân tích kết quả theo môi trường thực tế, không khái quát vượt quá phạm vi kiểm tra.

## 1.2. Những thách thức cần giải quyết

Việc sử dụng các thành phần cần có quy trình có thể tái hiện: điều kiện chuẩn bị, thứ tự tạo đối tượng, thiết lập tham số và dấu hiệu kiểm tra. Ví dụ phải ghi rõ phiên bản và trạng thái đã hoặc chưa chạy thử.

API cần được xem xét theo phiên bản. Đề tài dự kiến cố định Flutter và dependency sau khi xác minh tương thích. Không coi tính năng trong nhánh phát triển hoặc pull request là đã có trong SDK tại máy.

Cơ chế mô phỏng phải phù hợp với cách ném và luật chơi. Backend vật lý 3D và quỹ đạo điều khiển bằng thuật toán đều cần kết hợp luật ném, quyền giữ bóng, va chạm và ghi điểm. Hai hướng được so sánh theo mục tiêu demo, khả năng kiểm thử và công sức tích hợp.

Hai người chơi cần nhận cùng kết quả khi thi đấu qua mạng. Hệ thống cần kiểm tra thao tác và định danh sự kiện để tránh cộng điểm lặp hoặc tranh chấp quyền giữ bóng. Máy chủ quyết định trạng thái là phương án cần đánh giá cùng điều kiện triển khai Internet.

Phản hồi trên máy khách cần được đối chiếu với trạng thái chung. Nội suy hoặc phản hồi sớm không được tự quyết định điểm. Mất kết nối, xuống nền, rời phòng và hành động đến sau kết thúc trận cần quy tắc và ca thử tương ứng.

Điều kiện thử nghiệm hiện còn giới hạn: hiện có một Redmi Note 11, chưa có Android thứ hai hoặc kết quả chạy game. Client trên máy tính/giả lập hỗ trợ phát triển nhưng không thay bằng chứng thử hai điện thoại. Cần bố trí việc bổ sung thiết bị phù hợp tiến độ.

Bảng 1-1. Thách thức và hướng xử lý dự kiến

| Nhóm | Hướng xử lý | Bằng chứng cần bổ sung |
|---|---|---|
| Thành phần Scene | Giải thích vai trò, trình tự sử dụng và ví dụ nhỏ | Nguồn chính thức, cấu hình, ảnh hoặc log khi chạy |
| Tương thích phiên bản | Ghi nhận môi trường và cố định dependency phù hợp | Phiên bản, lockfile, hướng dẫn tái lập |
| Ném và va chạm | So sánh mô phỏng vật lý với quỹ đạo điều khiển | Đặc tả, tình huống biên, kết quả thử |
| Đồng bộ mạng | Xác định quyền phân xử và dữ liệu trao đổi | Thiết kế thông điệp, log và trạng thái hai phía |
| Thiết bị di động | Giảm độ phức tạp cảnh theo kết quả đo | Thiết bị/OS, chế độ build, dữ liệu hiệu năng |
| Phạm vi và tiến độ | Hoàn thiện bản thảo nghiên cứu, cập nhật theo sản phẩm | Bản thảo có nguồn, quyết định thiết kế, bằng chứng thực tế |

## 1.3. Nội dung, phạm vi thực hiện

### 1.3.1. Nội dung thực hiện

Phần nghiên cứu trình bày đồ thị cảnh, hệ tọa độ, phép biến đổi, hình học, vật liệu, ánh sáng, camera, tài nguyên và hoạt ảnh: tác dụng, cách dùng, giới hạn và thực hành từng bước. Lý thuyết mô phỏng và đồng bộ mạng phục vụ giải thích các quyết định thiết kế.

Phần ứng dụng mô tả game, phân tích yêu cầu và xây dựng mô hình chức năng, use case, dữ liệu, lớp, tuần tự, hoạt động và giao diện. Các sơ đồ hiện là thiết kế dự kiến, cần đối chiếu với code sau triển khai; tránh lặp cùng thông tin ở nhiều hình.

Quá trình xây dựng dự kiến đi từ cảnh nhỏ và thao tác đơn giản đến một vòng chơi hoàn chỉnh. Cơ chế ném, tính điểm và kết thúc trận được kiểm tra trước khi bổ sung kỹ năng hoặc hiệu ứng. Kết nối hai người được đánh giá riêng rồi tích hợp với gameplay. Chương kiểm thử và kết luận chỉ được hoàn thiện khi có sản phẩm, môi trường và bằng chứng tương ứng.

### 1.3.2. Phạm vi thực hiện

Phạm vi đã xác nhận gồm Android, nội dung bóng rổ đối kháng 3D, hai người trên hai thiết bị qua mạng và sử dụng Flutter Scene làm công nghệ nghiên cứu. Hướng ưu tiên là kết nối qua Internet giữa hai mạng khác nhau. Trường hợp phải thu hẹp khả năng kết nối cần được trình bày cùng lý do và thống nhất lại, không tự coi kết nối cùng Wi-Fi là đã đáp ứng mục tiêu Internet.

Demo sử dụng tên tạm Bóng rổ đối kháng 3D, gồm hai người trên nửa sân với một rổ và một quả bóng. Người chơi di chuyển, ném, nhảy, Dash và Block. Luật tính 2 hoặc 3 điểm tùy vị trí ném; trận kết thúc khi một người đạt ít nhất 11 điểm hoặc hết 3 phút. Người chơi tạo hoặc vào phòng bằng mã; ghép trận nhanh được bổ sung sau khi luồng phòng ổn định. Cách ném theo hướng arcade giúp kiểm soát phạm vi của demo.

Đề tài không đặt mục tiêu xây dựng nền tảng phát hành game thương mại, hệ thống kinh tế vật phẩm hoặc giải đấu quy mô lớn. Các chức năng bổ sung như tài khoản, bảng xếp hạng và chống gian lận nâng cao chỉ được xem xét nếu cần cho phạm vi được thống nhất. Không mặc định sử dụng cơ sở dữ liệu quan hệ khi dữ liệu của demo chỉ cần tồn tại trong phiên chơi; quyết định lưu trữ phải xuất phát từ yêu cầu thực tế.

## 1.4. Kết quả cần đạt và tiêu chí đánh giá

Kết quả nghiên cứu được đánh giá bằng mức độ giải thích và khả năng truy vết, còn kết quả sản phẩm được đánh giá bằng hành vi quan sát được và dữ liệu kiểm tra. Việc mô tả một cơ chế trong thiết kế không thay thế bằng chứng cơ chế đó đã được triển khai. Tương tự, thông tin hỗ trợ nền tảng trong tài liệu không chứng minh hiệu năng trên Redmi Note 11.

Bảng 1-2. Kết quả cần đạt và tiêu chí đánh giá dự kiến

| Kết quả | Tiêu chí đối chiếu | Cách đánh giá |
|---|---|---|
| Báo cáo nghiên cứu Flutter Scene | Nêu thành phần, tác dụng, cách dùng và giới hạn; có nguồn đúng ngữ cảnh | Rà soát Chương 2 và tài liệu tham khảo |
| Hướng dẫn thực hành | Các bước có đầu vào, thao tác và dấu hiệu kiểm tra; ghi rõ phiên bản và trạng thái thực nghiệm | Đối chiếu hướng dẫn với môi trường khi chạy thử |
| Mô tả và thiết kế game | Yêu cầu, luật, use case, dữ liệu, xử lý và giao diện nhất quán | Ma trận yêu cầu–thiết kế và rà soát sơ đồ |
| Cảnh 3D và điều khiển | Hiển thị và thao tác đúng phạm vi đã chốt trên thiết bị đích | Build, quan sát và lưu ảnh/log thực tế |
| Vòng chơi hai người | Hai client tham gia cùng trận, thống nhất bóng, điểm và kết quả | Thử luồng hoàn chỉnh, đối chiếu sự kiện hai phía |
| Kết nối Internet | Kiểm chứng từ hai mạng khác nhau khi điều kiện triển khai cho phép | Ghi mô hình mạng, môi trường và cách tái hiện |
| Luật và tình huống biên | Không tính điểm lặp; xử lý hành động sai, hết giờ và mất kết nối theo đặc tả | Ca thử logic và tích hợp |
| Hiệu năng, ổn định | Chỉ kết luận theo thiết bị, chế độ build và ngưỡng đã thống nhất | Thu dữ liệu đo gốc và báo cáo giới hạn |

Các giá trị như FPS mục tiêu, độ trễ chấp nhận, số trận lặp và thời lượng đo sẽ được chốt sau khi xác định môi trường và phạm vi sản phẩm. Những con số trong bản nháp cũ chỉ là đầu vào tham khảo, không được đưa thành kết quả đạt. Nếu chưa có đủ thiết bị hoặc chưa hoàn thành một phép thử, báo cáo phải ghi rõ phần chưa kiểm chứng.

### Tài liệu tham khảo

- [SCENE-01] Flutter Scene, *Welcome to Scene*, https://fscene.dev/getting-started/ . Nguồn đã được nhóm đọc ngày 03/11/2026; hỗ trợ nhận diện engine và các thành phần, không chứng minh kết quả demo.
- [SCENE-02] Flutter Scene, *Installation*, https://fscene.dev/getting-started/installation/ . Nguồn đã được nhóm đọc ngày 03/11/2026; hỗ trợ mô tả nền tảng và điều kiện cấu hình. Cần đối chiếu lại khi chọn phiên bản triển khai.
