# KIẾN TRÚC HỆ THỐNG & ĐẶC TẢ KỸ THUẬT (LifeTycoon)

## 1. Triết lý Thiết kế (Clean Architecture & Offline-First)

Hệ thống được thiết kế theo mô hình 3 tầng (Presentation - Domain - Data), phân chia độc lập hoàn toàn theo tính năng (**Feature-first**). Game không phụ thuộc vào Game Engine (Flame/Unity) ở Phase 1, toàn bộ tương tác là Widget Native Flutter đạt chuẩn 60-120 FPS.

```text
lib/
├── app/
│   ├── config/             # Theme, Constants, Strings, Assets
│   ├── routes/             # GoRouter or AutoRoute
│   └── observer/           # AppLifecycleObserver
├── core/
│   ├── anti_cheat/         # Anti-Time-Travel, Hardware Uptime, Step Filter
│   ├── database/           # Drift Database instance, migrations, DAOs
│   ├── error/              # Failure, Exceptions
│   ├── services/           # Background tick service, Notification service
│   └── utils/              # Math utilities (GBM, Idle calculus, DateTime ext)
└── features/
    ├── player/             # Player profile, stats (INT, STA, Discipline), Wallet
    ├── action_hub/         # Deep work, Reader, Pedometer, Tasks
    ├── business_sim/       # Business entities, idle cashflow engine
    ├── finance_sim/        # Bank deposit, Virtual stock market (fl_chart)
    └── assets_prestige/    # Luxury catalog, inventory, prestige points
```

---

## 2. Chi tiết các Tầng (Layers)

### 2.1. Presentation Layer (UI & State Management)
* **State Management:** BLoC (Business Logic Component) hoặc Riverpod 2.x.
* **UI Components:**
  * `TopStatusBar`: Hiển thị Level, Tiền mặt, Danh tiếng, INT/STA/Kỷ luật.
  * `ActionTabView`: Gồm Pomodoro Face-down View, E-Reader View, Step Progress, To-Do List.
  * `BusinessTabView`: Card List hiển thị doanh nghiệp, level, thanh loading chu kỳ dòng tiền, nút Claim & Nâng cấp.
  * `FinanceTabView`: Bảng lãi suất ngân hàng, Biểu đồ nến (`fl_chart`), danh mục cổ phiếu sở hữu.
  * `AssetTabView`: Grid/Card View tài sản xa xỉ (Xe cộ, Bất động sản, Đồng hồ).

### 2.2. Domain Layer (Pure Dart Business Logic)
* **Entities:** Không phụ thuộc bất kỳ package bên thứ 3 nào.
* **Use Cases:**
  * `CalculateOfflineIncomeUseCase`: Tính doanh thu tích lũy khi user quay lại app.
  * `GenerateMarketTickUseCase`: Tạo bước nhảy giá cổ phiếu theo thuật toán GBM.
  * `VerifyActionRewardUseCase`: Kiểm tra tính hợp lệ trước khi trả Xu & EXP chỉ số.
  * `ExecuteBankInterestUseCase`: Xử lý trả lãi tiết kiệm hàng ngày.

### 2.3. Data Layer (Persistence & Repositories)
* **Local Database:** Drift (SQLite type-safe ORM).
* **Secure Storage:** `flutter_secure_storage` (lưu salt mã hóa, timestamp check, secret keys).
* **Repositories Implementations:** Chuyển đổi DTO từ Database sang Domain Entities.

---

## 3. Cơ chế Chống Gian lận (Anti-Cheat Engine)

### 3.1. Anti-Time-Travel (Chống đổi giờ máy)
Vì app chạy 100% offline, nguy cơ người chơi chỉnh giờ máy lên 1 năm để rút lãi ngân hàng/nhận tiền doanh nghiệp là rất lớn.

**Quy trình xác thực thời gian:**
1. **Lưu trữ kép (Dual Check):**
   * Lưu `last_active_wall_time` (Unix timestamp từ `DateTime.now().millisecondsSinceEpoch`).
   * Lưu `last_active_uptime` (Hardware Uptime từ native OS qua MethodChannel).
2. **Khi app Resume / Khởi động lại:**
   * Tính `delta_wall = current_wall - last_active_wall_time`.
   * Tính `delta_uptime = current_uptime - last_active_uptime`.
   * **Quy tắc 1 (Lùi giờ):** Nếu `delta_wall < 0` $\rightarrow$ Phát hiện hack lùi giờ $\rightarrow$ Freeze tính năng kinh tế trong 24 giờ.
   * **Quy tắc 2 (Tiến giờ):** Nếu `delta_wall > delta_uptime + 300` (sai số quá 5 phút mà không reboot) $\rightarrow$ Dùng `delta_uptime` thay thế hoặc chặn tính offline reward.
   * **Quy tắc 3 (Reboot):** Nếu máy reboot (`current_uptime < last_active_uptime`), hệ thống giới hạn tối đa `delta_wall` cho phép là $12\text{ giờ}$ (Hard Cap).

### 3.2. Chống Gian lận Vận động (Pedometer & Accelerometer)
* Thu thập mẫu gia tốc (Accelerometer) theo cửa sổ trượt 3 giây.
* Tính Fast Fourier Transform (FFT) hoặc đếm peak để xác định tần số bước chân:
  * Người đi bộ/chạy: Tần số dao động $1.5\text{ Hz} – 3.5\text{ Hz}$.
  * Rung lắc giả lập / Đung đưa tay máy: Tần số $> 5\text{ Hz}$ hoặc biên độ quá đều bất thường $\rightarrow$ Bỏ qua bước chân.

### 3.3. Chống Gian lận Deep Work (Pomodoro Face-down)
* Kết hợp `proximity_sensor` (khoảng cách mặt kính = 0 khi úp xuống bàn) + `sensors_plus` (trục Z của accelerometer $\approx -9.8\text{ m/s}^2$).
* Lắng nghe `AppLifecycleState.paused` / `inactive`. Nếu rời app quá $10\text{ giây}$, trigger `CancelSession` và phạt 50% năng lượng.
