# TÀI LIỆU YÊU CẦU SẢN PHẨM (PRD) — PHASE 1 (MVP)

* **Tên dự án (Dự kiến):** LifeTycoon (Đô Thị Khởi Nghiệp Thực Tế)
* **Nền tảng:** Mobile App (iOS & Android)
* **Kiến trúc:** 100% Offline-First (Không phụ thuộc Server)
* **Mục tiêu Phase 1:** Kiểm chứng Vòng lặp cốt lõi (Core Gameplay Loop): Biến nỗ lực đời thực (Tập trung, Đọc sách, Đi bộ/Chạy) thành vốn phát triển đế chế kinh doanh mô phỏng dạng Tab.

---

## 1. Tổng quan Sản phẩm & Mục tiêu

### 1.1. Tầm nhìn Sản phẩm
Xây dựng một ứng dụng kết hợp giữa **Công cụ Năng suất (Productivity Tool)** và **Game Mô phỏng Kinh doanh dạng Thẻ/Tab (Business Tycoon Simulator)**. Ứng dụng giúp người dùng nâng cấp năng lực bản thân ngoài đời (sức khỏe, tri thức, sự tập trung) thông qua cơ chế tưởng thưởng hấp dẫn của thế giới kinh doanh ảo.

### 1.2. Mục tiêu Phase 1
1. Triển khai hoàn chỉnh ứng dụng chạy cục bộ (Local Storage), không cần hệ thống backend phức tạp.
2. Đo lường chính xác và chống gian lận tự động đối với 3 hành vi đời thực: Đọc Ebook, Tập trung không chạm máy (Pomodoro), và Vận động (Bước chân).
3. Xây dựng hệ thống kinh tế mô phỏng: Hộ kinh doanh tạo dòng tiền thụ động, thị trường đầu tư tài chính giả lập, và danh mục tài sản xa xỉ.
4. Thiết lập cấu trúc mã nguồn theo chuẩn Clean Architecture để sẵn sàng cắm kết nối Server/Multiplayer ở Phase 2 và tích hợp Game Engine 2D ở Phase 3.

---

## 2. Kiến trúc Kỹ thuật & Mô hình Dữ liệu

```text
┌────────────────────────────────────────────────────────┐
│               PRESENTATION LAYER (FLUTTER)             │
│  [Tab Hành Động]  [Tab Doanh Nghiệp]  [Tab Thị Trường] │
└───────────────────────────┬────────────────────────────┘
                            │ (Events / Bloc / Provider)
┌───────────────────────────▼────────────────────────────┐
│                  DOMAIN & SERVICE LAYER                │
│  • Anti-Cheat Engine      • Idle Business Engine       │
│  • Pedometer / Health     • Market Simulation (Math)   │
│  • EPUB / PDF Parser      • Financial & Prestige Logic │
└───────────────────────────┬────────────────────────────┘
                            │ (Repositories)
┌───────────────────────────▼────────────────────────────┐
│               DATA ACCESS LAYER (OFFLINE-FIRST)        │
│  • Local DB: Isar / Drift (SQLite)                     │
│  • File System: Local App Storage (Ebooks, Cache)      │
│  • Ready for Cloud Sync: UUID, updated_at, sync_status │
└────────────────────────────────────────────────────────┘
```

* **Framework phát triển:** Flutter (Dart) — Tối ưu hiệu năng 60–120 FPS, hỗ trợ giao diện card/tab mượt mà.
* **Cơ sở dữ liệu cục bộ:** Drift (SQLite) hoặc Isar. Mọi bản ghi (Record) đều có cấu trúc:
  * `id`: Chuỗi UUID v4.
  * `created_at` / `updated_at`: Unix Timestamp.
  * `sync_status`: Enum (`synced`, `pending_create`, `pending_update`) — phục vụ việc đẩy lên đám mây ở Phase 2.
* **Quy chuẩn lưu trữ file:** File Ebook (.epub, .pdf) được copy trực tiếp vào thư mục an toàn của ứng dụng (`ApplicationDocumentsDirectory`).

---

## 3. Cấu trúc Giao diện & Tính năng Chi tiết

Giao diện ứng dụng được chia thành 4 Tab chính và 1 Thanh trạng thái cố định phía trên:

```text
┌─────────────────────────────────────────────────────────────────┐
│ [Cấp độ] Tên Người Chơi  │  Tài sản: $1,250,000  │  Danh tiếng: 85 │
│ Chỉ số: Trí Tuệ (INT): 14  │  Thể Lực (STA): 22  │  Kỷ Luật: 18   │
├───────────────┬─────────────────┬────────────────┬──────────────┤
│ TAB 1: ACTION │ TAB 2: BUSINESS │ TAB 3: FINANCE │ TAB 4: ASSET │
└───────────────┴─────────────────┴────────────────┴──────────────┘
```

### Module 1: Hành Động Thực Tế (Action Hub - Tab 1)
Nguồn sinh vốn mồi duy nhất của người chơi. Tích hợp cơ chế tracking tự động và kiểm tra gian lận cục bộ:

#### 1.1. Chế độ Tập trung Sâu (Deep Work / Pomodoro Lock)
* **Quy cách hoạt động:** Người dùng chọn thời lượng (25, 45, hoặc 60 phút) và bấm bắt đầu.
* **Cơ chế Tracking & Chống Cheat:**
  * **Cảm biến lật úp:** Sử dụng con quay hồi chuyển (`sensors_plus`) và cảm biến tiệm cận (`proximity_sensor`). Bắt buộc người dùng úp mặt điện thoại xuống bàn để tính giờ.
  * **App Lifecycle Tracking:** Lắng nghe sự kiện `AppLifecycleState`. Nếu người dùng chuyển app hoặc về Home quá 10 giây (Grace Period), phiên làm việc lập tức thất bại.
* **Phần thưởng:** Hoàn thành 25 phút nhận $1,000 Xu + 5 Điểm Kỷ Luật. Thất bại: Mất 50% số năng lượng trong ngày.

#### 1.2. Trình đọc Ebook & Kho Tri Thức (In-App E-Reader)
* **Quy cách hoạt động:** Cho phép người dùng import file `.epub` hoặc `.pdf` từ bộ nhớ máy. Giao diện đọc sách hỗ trợ chỉnh cỡ chữ, nền vàng/đen, lật trang mượt mà.
* **Cơ chế Tracking & Chống Cheat:**
  * **Đo thời gian đọc thực tế:** Mỗi trang phải dừng tối thiểu 15 giây mới được tính thời gian đọc hợp lệ.
  * **Tương tác ngẫu nhiên (Keep-alive):** Mỗi 10–15 phút xuất hiện một hộp thoại chạm xác nhận để tránh trường hợp bật sáng màn hình rồi bỏ đi làm việc khác.
* **Phần thưởng:** Mỗi 10 phút đọc tích lũy nhận $500 Xu + 2 Điểm Trí Tuệ.

#### 1.3. Vận động Thể chất (Pedometer & Step Tracking)
* **Quy cách hoạt động:** Đọc dữ liệu từ cảm biến đếm bước chân phần cứng (`pedometer`) hoặc đồng bộ qua Google Health Connect / Apple HealthKit.
* **Cơ chế Tracking & Chống Cheat:**
  * **Bộ lọc tần số bước chân:** Lọc bỏ các bước có tần số gia tốc bất thường (rung lắc cơ học do máy rung).
  * **Giới hạn tốc độ di chuyển (khi bật GPS đi bộ):** Từ 3 km/h đến 15 km/h. Vượt quá tốc độ này không ghi nhận quãng đường.
* **Phần thưởng:** 5.000 bước chân = $1,500 Xu + 5 Điểm Thể Lực.

#### 1.4. Quản lý Danh sách Công việc (Task / To-Do Manager)
* Tạo task công việc hằng ngày kèm Deadline và Mức độ ưu tiên (Thấp, Trung bình, Cao).
* Hoàn thành 1 task quan trọng = Thưởng $200 – $500 Xu.
* Hoàn thành 100% task trong ngày: Kích hoạt Buff "Năng Suất Vượt Trội" (x1.5 doanh thu kinh doanh trong 4 giờ).

---

### Module 2: Mô phỏng Doanh nghiệp (Business Simulator - Tab 2)
Hệ thống kinh doanh mô phỏng 100% (Single-player Idle) tạo dòng tiền thụ động cho người chơi.

```text
┌───────────────────────────────────────────────────────────┐
│ Tên Doanh nghiệp: Quán Cà Phê Takeaway (Cấp 3)            │
│ Doanh thu: +$450 Xu / giờ      Chi phí duy trì: -$100/giờ │
│ Yêu cầu mở rộng: 25 Điểm Trí Tuệ (Hiện có: 18/25)         │
│ [ NÂNG CẤP - $5,000 ]       [ THU TIỀN VỀ VÍ (Claim) ]    │
└───────────────────────────────────────────────────────────┘
```

#### Phân cấp Mô hình Kinh doanh:
1. **Bán lẻ & Dịch vụ F&B (Vốn nhỏ):** Xe cà phê take-away, Cửa hàng tiện lợi, Tiệm giặt là.
   * *Yêu cầu:* Vốn Xu cơ bản. Dòng tiền nhỏ, hồi vốn nhanh.
2. **Vận tải & Thi công (Vốn vừa):** Đội xe taxi cá nhân, Đội thầu sơn sửa nhà.
   * *Yêu cầu:* Cần chỉ số Thể Lực (STA) từ chạy bộ để mở khóa.
3. **Công nghệ & Trí tuệ (Vốn lớn):** Công ty gia công phần mềm, Studio thiết kế.
   * *Yêu cầu:* Vốn Xu lớn + Cột mốc Trí Tuệ (INT) từ việc đọc xong một số cuốn sách nhất định.

#### Logic Dòng tiền (Cash Flow Engine):
* **Tính toán Offline (Offline Earnings Calculation):**
  $$\text{Doanh thu} = \Delta t \times (\text{Doanh thu mỗi giây} - \text{Chi phí bảo trì mỗi giây})$$
  Trong đó $\Delta t = \min(\text{Thời gian offline thực tế}, 12\text{ giờ})$ (Giới hạn tối đa 12 giờ treo máy để buộc người dùng phải vào nhận tiền).
* **Bảo trì:** Nếu số dư tiền mặt không đủ trả chi phí bảo trì định kỳ, doanh nghiệp chuyển sang trạng thái "Đình công/Tạm dừng" cho đến khi người dùng làm task ngoài đời nạp thêm vốn.

---

### Module 3: Thị trường Tài chính & Ngân hàng (Finance Simulator - Tab 3)
Nơi người chơi học cách phân bổ vốn và gia tăng tài sản thông qua các thuật toán mô phỏng toán học:

#### 3.1. Ngân hàng Trung ương (Central Bank)
* **Tiết kiệm linh hoạt:** Lãi suất 0.1%/ngày (khoảng 3%/tháng), rút vốn bất kỳ lúc nào.
* **Tiết kiệm có kỳ hạn (30 ngày):** Lãi suất 7%/kỳ hạn. Rút trước hạn mất toàn bộ lãi.
* **Hạn mức gửi:** Bị chặn theo cấp độ người dùng để tránh hiệu ứng lãi kép làm lạm phát tiền game.

#### 3.2. Sàn Chứng khoán & Tiền mã hóa Ảo (Virtual Market)
* 4 mã cổ phiếu ảo đại diện cho các ngành: `TECH` (Công nghệ), `FOOD` (Bán lẻ), `PROP` (Bất động sản), `GOLD` (Vàng).
* **Thuật toán biến động giá:** Sử dụng mô hình toán học Geometric Brownian Motion (GBM) chạy cục bộ:
  $$S_{t + \Delta t} = S_t \exp\left( \left(\mu - \frac{1}{2}\sigma^2\right)\Delta t + \sigma \sqrt{\Delta t} Z \right)$$
* Mỗi 15 phút, giá cổ phiếu cập nhật một nến mới. Biểu đồ nến được vẽ trực tiếp bằng thư viện `fl_chart`.

---

### Module 4: Kho Tài Sản & Phong Cách Sống (Assets & Prestige - Tab 4)
Hố tiêu thụ tiền tệ chính trong game, kích thích người chơi tích lũy tài sản:

| Danh mục | Vật phẩm tiêu biểu | Giá bán (Xu) | Lợi ích In-Game |
| :--- | :--- | :--- | :--- |
| **Phương tiện** | Xe máy tay ga, Sedan hạng sang, Siêu xe thể thao | $15.000 – $500.000 | Tăng tốc độ nhận tiền của doanh nghiệp vận tải; Tăng điểm Danh tiếng. |
| **Bất động sản** | Căn hộ studio, Căn hộ 2PN, Penthouse trung tâm | $50.000 – $2.000.000 | Mở rộng số slot đặt doanh nghiệp; Giảm phí bảo trì tài sản. |
| **Thời trang / Đồng hồ** | Đồng hồ thép, Đồng hồ cơ Thụy Sĩ cao cấp | $5.000 – $100.000 | Hiển thị trên thẻ Profile; Tăng điểm Sức Hút cá nhân. |

* **Quy cách hiển thị:** Toàn bộ vật phẩm ở Phase 1 là Thẻ ảnh 2D tĩnh chất lượng cao kèm mô tả chi tiết và huy hiệu sở hữu.

---

## 4. Thiết kế Kinh tế & Cơ chế Chống Gian lận

### 4.1. Trần Cung tiền Hàng ngày (Daily Supply Cap)
Ngăn chặn người dùng gian lận bằng cách tua đồng hồ máy hoặc treo máy giả lập:
* **Chạy bộ:** Tối đa 12.000 bước/ngày nhận thưởng. Các bước sau mốc này chỉ ghi nhận chỉ số sức khỏe, không cộng Xu.
* **Đọc sách:** Tối đa 90 phút/ngày nhận thưởng.
* **Pomodoro:** Tối đa 6 phiên (150 phút)/ngày nhận thưởng.

### 4.2. Chống Gian lận Thời gian (Anti-Time-Travel)
Vì ứng dụng chạy offline, người dùng có thể chỉnh giờ điện thoại để "hack" lãi ngân hàng hoặc doanh nghiệp idle:
* **Thuật toán kiểm tra:**
  1. Ứng dụng lưu `last_active_timestamp` vào bộ nhớ an toàn (Encrypted Shared Preferences).
  2. Mỗi khi app mở lại: So sánh `current_time` với `last_active_timestamp`.
  3. Nếu `current_time < last_active_timestamp` (người dùng lùi giờ): Khóa toàn bộ tính năng sinh tiền trong 24 giờ.
  4. Tích hợp **uptime phần cứng** (thời gian thiết bị hoạt động kể từ lần khởi động lại gần nhất) để đo độ trôi thời gian thực thay vì chỉ đọc giờ hệ thống.

---

## 5. Kế hoạch Triển khai (Roadmap 8 Tuần)

```text
Tuần 1 - 2: Core Data & Task Engine
├── Setup Clean Architecture trên Flutter
├── Khởi tạo Database (Drift/SQLite) với Schema chuẩn Sync
└── Module Task & To-do List cơ bản

Tuần 3 - 4: Action Tracking & Anti-Cheat Hub
├── Tích hợp Module Đọc Ebook (.epub, .pdf) + Tracking lật trang
├── Tích hợp Pedometer & HealthKit (Bộ lọc tốc độ)
└── Tích hợp Pomodoro Timer (Lifecycle & Proximity Sensor)

Tuần 5 - 6: Business & Finance Simulator
├── Engine tính toán doanh thu thụ động (Idle Formula)
├── Mô phỏng biến động giá Chứng khoán/Crypto (fl_chart)
└── Tính năng Tiết kiệm Ngân hàng & Quản lý Chi phí

Tuần 7: Assets, Prestige & UI Polish
├── Danh mục mua sắm Tài sản (Xe cộ, Bất động sản dạng Card)
├── Kết nối bộ chỉ số: Thể Lực - Trí Tuệ - Kỷ Luật vào Gameplay
└── Rà soát chống hack thời gian (Time-travel check)

Tuần 8: Testing, QA & Hoàn thiện bản MVP
├── Thử nghiệm thực tế các phiên tập trung, chạy bộ, đọc sách
├── Cân bằng thông số kinh tế (Lãi suất, Giá bán, Lợi nhuận)
└── Đóng gói nội bộ bản Alpha Test (APK & TestFlight)
```

---

## 6. Tiêu chí Đánh giá Thành công (Success Metrics)
* **Tỷ lệ Duy trì Chuỗi (Streak Retention):** $\ge 35\%$ người dùng duy trì chuỗi hoạt động thực tế (đọc sách, tập trung hoặc chạy bộ) liên tục trong 7 ngày.
* **Chỉ số Kỷ luật:** Thời lượng tập trung trung bình đạt $\ge 40\text{ phút/người dùng/ngày}$.
* **Độ ổn định Hệ thống:** Tỷ lệ crash $\le 0.5\%$; không xuất hiện lỗi tràn số dư tài khoản do bug thời gian.
