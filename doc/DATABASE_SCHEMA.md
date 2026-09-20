# THIẾT KẾ CƠ SỞ DỮ LIỆU CỤC BỘ (DRIFT / SQLITE SCHEMA)

Tất cả bảng đều tuân thủ chuẩn **Offline-First & Cloud-Sync Ready**:
* Khóa chính là `UUID v4` (dạng chuỗi).
* Trường thời gian là Unix Timestamp (`INTEGER` tính bằng milli-seconds hoặc seconds).
* Có `sync_status` (`synced`, `pending_create`, `pending_update`, `pending_delete`) sẵn sàng cho Cloud Push ở Phase 2.

---

## 1. Bảng `players` (Hồ sơ người chơi)

| Cột | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `id` | `TEXT PRIMARY KEY` | UUID v4 của người chơi |
| `name` | `TEXT` | Tên người chơi |
| `level` | `INTEGER` | Cấp độ hiện tại (1, 2, 3...) |
| `cash_balance` | `REAL` | Số dư tiền mặt ($) |
| `prestige_points` | `INTEGER` | Điểm danh tiếng |
| `intellect_stat` | `INTEGER` | Điểm Trí Tuệ (tích lũy từ đọc sách) |
| `stamina_stat` | `INTEGER` | Điểm Thể Lực (tích lũy từ bước chân) |
| `discipline_stat` | `INTEGER` | Điểm Kỷ Luật (tích lũy từ Pomodoro) |
| `energy_current` | `INTEGER` | Năng lượng hiện tại (0 - 100) |
| `energy_max` | `INTEGER` | Năng lượng tối đa |
| `last_active_timestamp`| `INTEGER` | Timestamp lần active cuối (chống cheat) |
| `last_uptime_ms` | `INTEGER` | Uptime phần cứng lần cuối ghi nhận |
| `created_at` | `INTEGER` | Timestamp tạo |
| `updated_at` | `INTEGER` | Timestamp cập nhật |
| `sync_status` | `TEXT` | Trạng thái đồng bộ |

---

## 2. Bảng `businesses` (Doanh nghiệp sở hữu)

| Cột | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `id` | `TEXT PRIMARY KEY` | UUID v4 |
| `business_code` | `TEXT` | Mã loại hình (`coffee_cart`, `taxi_fleet`, `it_studio`...) |
| `name` | `TEXT` | Tên hiển thị do user đặt hoặc mặc định |
| `level` | `INTEGER` | Cấp độ doanh nghiệp (1, 2, 3...) |
| `base_revenue_per_sec` | `REAL` | Doanh thu cơ bản mỗi giây |
| `base_cost_per_sec` | `REAL` | Chi phí bảo trì mỗi giây |
| `unclaimed_cash` | `REAL` | Số tiền chưa bấm claim |
| `last_calculated_at`| `INTEGER` | Timestamp lần tính tiền gần nhất |
| `is_paused` | `BOOLEAN` | Tạm dừng do thiếu tiền bảo trì hay không |
| `created_at` | `INTEGER` | Timestamp tạo |
| `updated_at` | `INTEGER` | Timestamp cập nhật |
| `sync_status` | `TEXT` | Trạng thái đồng bộ |

---

## 3. Bảng `bank_deposits` (Sổ tiết kiệm ngân hàng)

| Cột | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `id` | `TEXT PRIMARY KEY` | UUID v4 |
| `deposit_type` | `TEXT` | `flexible` (linh hoạt) hoặc `term_30d` (kỳ hạn 30 ngày) |
| `principal_amount` | `REAL` | Tiền gốc gửi vào |
| `interest_rate` | `REAL` | Lãi suất (0.001 / ngày với flexible, 0.07 với term) |
| `started_at` | `INTEGER` | Ngày bắt đầu gửi |
| `matures_at` | `INTEGER` | Ngày đáo hạn (null nếu flexible) |
| `last_interest_claim` | `INTEGER` | Lần nhận lãi cuối |
| `is_closed` | `BOOLEAN` | Đã tất toán hay chưa |
| `created_at` | `INTEGER` | Timestamp tạo |
| `updated_at` | `INTEGER` | Timestamp cập nhật |
| `sync_status` | `TEXT` | Trạng thái đồng bộ |

---

## 4. Bảng `market_stocks` & `stock_ticks` (Sàn giao dịch)

### `market_stocks` (Danh mục cổ phiếu)
| Cột | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `symbol` | `TEXT PRIMARY KEY` | `TECH`, `FOOD`, `PROP`, `GOLD` |
| `company_name` | `TEXT` | Tên đầy đủ của công ty ảo |
| `current_price` | `REAL` | Giá hiện tại |
| `initial_price` | `REAL` | Giá khởi tạo |
| `volatility` | `REAL` | Hệ số biến động $\sigma$ |
| `drift_rate` | `REAL` | Hệ số xu hướng tăng trưởng $\mu$ |
| `user_owned_shares` | `REAL` | Số lượng cổ phiếu người chơi nắm giữ |
| `average_buy_price` | `REAL` | Giá mua trung bình của người chơi |

### `stock_ticks` (Lịch sử nến để vẽ biểu đồ)
| Cột | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Auto increment tick |
| `symbol` | `TEXT` | FK đến `market_stocks.symbol` |
| `open_price` | `REAL` | Giá mở |
| `high_price` | `REAL` | Giá cao nhất |
| `low_price` | `REAL` | Giá thấp nhất |
| `close_price` | `REAL` | Giá đóng |
| `timestamp` | `INTEGER` | Timestamp tạo nến |

---

## 5. Bảng `action_logs` (Lịch sử hành động thực tế)

| Cột | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `id` | `TEXT PRIMARY KEY` | UUID v4 |
| `action_type` | `TEXT` | `pomodoro`, `reading_epub`, `reading_pdf`, `pedometer`, `task` |
| `duration_seconds` | `INTEGER` | Thời lượng thực tế (giây) |
| `metric_value` | `REAL` | Số bước chân, số trang đọc, v.v. |
| `cash_reward` | `REAL` | Tiền thưởng nhận được ($) |
| `stat_reward_type` | `TEXT` | `INT`, `STA`, `DISCIPLINE` |
| `stat_reward_value`| `INTEGER` | Điểm chỉ số được cộng |
| `is_verified` | `BOOLEAN` | Đạt kiểm tra chống cheat hay không |
| `created_at` | `INTEGER` | Timestamp hoàn thành |
| `sync_status` | `TEXT` | Trạng thái đồng bộ |
