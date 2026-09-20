# LifeTycoon (Đô Thị Khởi Nghiệp Thực Tế)

> **LifeTycoon** là game mô phỏng kinh doanh dạng Tab (Business Tycoon Simulator) kết hợp công cụ phát triển năng lực bản thân (Productivity Tool), lấy cảm hứng từ lối chơi của *Business Empire: RichMan* nhưng biến nỗ lực đời thực (Tập trung, Đọc sách, Vận động) thành vốn mồi khởi nghiệp.

---

## 🚀 Điểm nổi bật & Triết lý Thiết kế

1. **Vòng lặp cốt lõi (Core Gameplay Loop):** Nỗ lực thực tế (Đọc Ebook, Pomodoro không chạm máy, Đi bộ/Chạy) ➔ Nhận Vốn & Chỉ số (Trí Tuệ, Thể Lực, Kỷ Luật) ➔ Mở Doanh nghiệp / Đầu tư Tài chính ➔ Sinh Dòng tiền Thụ động ➔ Sở hữu Tài sản Xa xỉ & Gia tăng Danh tiếng.
2. **Kiến trúc Offline-First 100%:** Chạy hoàn toàn trên máy cục bộ (Local DB Drift/SQLite), không phụ thuộc Server ở Phase 1. Mọi bản ghi sẵn sàng schema sync để cắm Cloud/Multiplayer ở Phase 2.
3. **UI/UX Dark Theme tối giản:** Giao diện Card/Tab mượt mà (60-120 FPS), trực quan, không dùng Game Engine 2D/3D cồng kềnh để tối ưu dung lượng và pin.
4. **Hệ thống Anti-Cheat cục bộ chặt chẽ:** Chống tua ngược/tiến thời gian (Anti-Time-Travel), chống rung lắc giả lập bước chân, tracking úp màn hình Pomodoro.

---

## 📱 Cấu trúc 4 Tab Gameplay

* **Tab 1: Action Hub (Hành Động Thực Tế):**
  * *Deep Work / Pomodoro Lock:* Lật úp điện thoại (Proximity + Gyroscope) để tính giờ tập trung. Rời app quá 10s phạt năng lượng.
  * *In-App E-Reader:* Đọc .epub/.pdf với cơ chế kiểm tra lật trang tối thiểu 15s/trang và random keep-alive.
  * *Pedometer & Step Tracker:* Đếm bước chân với bộ lọc rung lắc và giới hạn tốc độ di chuyển (3-15 km/h).
  * *Task Manager:* Quản lý công việc hàng ngày, thưởng streak & buff năng suất x1.5.
* **Tab 2: Business Simulator (Doanh Nghiệp Mô Phỏng):**
  * Xây dựng và nâng cấp chuỗi kinh doanh (F&B, Dịch vụ, Vận tải, Công nghệ).
  * Yêu cầu vốn tiền mặt + Chỉ số thực tế (Trí tuệ INT, Thể lực STA).
  * Cashflow Engine tính toán offline tối đa 12 giờ treo máy.
* **Tab 3: Finance Simulator (Thị Trường Tài Chính & Ngân Hàng):**
  * *Ngân hàng:* Gửi tiết kiệm linh hoạt và kỳ hạn (khóa lãi kép chống lạm phát).
  * *Sàn Giao dịch:* 4 mã cổ phiếu đại diện các ngành, biến động theo thuật toán Geometric Brownian Motion (GBM) cục bộ, vẽ nến bằng `fl_chart`.
* **Tab 4: Assets & Prestige (Kho Tài Sản & Phong Cách Sống):**
  * Mua xe cộ, siêu xe, bất động sản, đồng hồ hạng sang.
  * Mở rộng slot kinh doanh, tăng điểm Danh tiếng (Prestige) và Sức hút.

---

## 📚 Tài liệu Dự án (`/doc`)

Chi tiết toàn bộ kiến trúc và đặc tả kỹ thuật được lưu trong thư mục [`/doc`](./doc):

* [`doc/PRD.md`](./doc/PRD.md): Toàn văn Tài liệu Yêu cầu Sản phẩm (Product Requirements Document) - Phase 1 MVP.
* [`doc/ARCHITECTURE.md`](./doc/ARCHITECTURE.md): Kiến trúc Clean Architecture, Thiết kế Domain & Data Layer, Anti-Cheat Engine.
* [`doc/DATABASE_SCHEMA.md`](./doc/DATABASE_SCHEMA.md): Chi tiết Schema Cơ sở dữ liệu Drift (SQLite) chuẩn hóa Sync.
* [`doc/FINANCE_ENGINE_MATH.md`](./doc/FINANCE_ENGINE_MATH.md): Đặc tả toán học cho Mô hình Dòng tiền Idle & Thuật toán biến động giá cổ phiếu (GBM).

---

## 🛠️ Công nghệ Sử dụng

* **Framework:** Flutter (Dart >= 3.3)
* **Architecture:** Clean Architecture + BLoC / Riverpod
* **Local Database:** Drift (SQLite) + Flutter Secure Storage
* **Data Visualization:** fl_chart / candlesticks
* **Hardware & Sensors:** `pedometer`, `sensors_plus`, `proximity_sensor`
* **File Parser:** `epubx`, `syncfusion_flutter_pdfviewer` / `pdfx`
