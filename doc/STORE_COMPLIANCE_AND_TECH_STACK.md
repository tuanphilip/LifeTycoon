# QUY CHUẨN KỸ THUẬT CHO GOOGLE PLAY & APP STORE COMPLIANCE (LifeTycoon)

Tài liệu này quy định toàn bộ Tech Stack, quyền hạn thiết bị (Permissions), và các tiêu chuẩn kiểm duyệt nghiêm ngặt của **Apple App Store Review Guidelines** và **Google Play Developer Policies** để đảm bảo app được duyệt 100% không bị reject.

---

## 1. Tech Stack Khuyến nghị (Production-Ready)

| Thành phần | Công nghệ / Package | Lý do lựa chọn & Đạt chuẩn Store |
| :--- | :--- | :--- |
| **Core Framework** | **Flutter 3.x (Dart 3.x)** | Biên dịch AOT ra native ARM64/x86_64, hỗ trợ ProGuard/R8 (Android) & Bitcode/dSYM (iOS). |
| **State Management** | **Flutter BLoC (`flutter_bloc: ^8.1.x`)** | Tách biệt State/UI triệt để, dễ viết Unit Test, không gây rò rỉ bộ nhớ (memory leaks). |
| **Local Database** | **Drift (`drift: ^2.18.x` + `sqlite3_flutter_libs`)** | SQLite type-safe chuẩn native C, ổn định hơn Isar/Hive trên iOS 17/18 và Android 14/15. |
| **Secure Key/Vault** | **`flutter_secure_storage: ^9.0.x`** | Lưu biến bảo mật vào iOS Keychain & Android EncryptedSharedPreferences (Hardware-backed Keystore). |
| **Sensors & Hardware** | **`sensors_plus: ^5.0.x`**, **`pedometer: ^4.0.x`** | Plugin chính chủ Flutter Community, tương thích API mới nhất. |
| **Background & Notifications** | **`flutter_local_notifications: ^17.x.x`** | Đẩy thông báo cục bộ khi hết giờ Pomodoro / nhận doanh thu mà không cần Firebase. |
| **Data Visualization** | **`fl_chart: ^0.68.x`** | Vẽ biểu đồ Canvas thuần Dart cực nhẹ, không dùng Webview gây tốn RAM. |
| **E-Reader Engine** | **`epubx: ^3.1.x`** (EPUB) & **`pdfx: ^2.6.x`** (PDF) | Render offline thuần, không cần quyền truy cập mạng. |

---

## 2. Chiến lược Vượt qua Kiểm duyệt Store (App Store & Google Play)

### 2.1. Quy định về Quyền hạn Cảm biến & Sức khỏe (Permissions & Privacy)
Cả Apple và Google đều phạt rất nặng các app xin quyền thừa thãi (Over-permissioned apps).

#### Android (`AndroidManifest.xml`):
* `android.permission.ACTIVITY_RECOGNITION`: Bắt buộc để đếm bước chân trên Android 10+. **Chỉ xin runtime permission khi người dùng bấm vào Tab Vận Động**, kèm màn hình giải thích rõ lý do (In-App Disclosure).
* `android.permission.FOREGROUND_SERVICE` & `android.permission.FOREGROUND_SERVICE_HEALTH`: Dành cho phiên Pomodoro hoặc chạy bộ.
* **KHÔNG** xin quyền `READ_EXTERNAL_STORAGE` / `MANAGE_EXTERNAL_STORAGE` bừa bãi. Sử dụng **Android Storage Access Framework (SAF)** qua `file_picker` để người dùng tự chọn file `.epub`/`.pdf` mà không cần cấp quyền truy cập toàn bộ bộ nhớ máy.

#### iOS (`Info.plist`):
Cần viết mô tả **Usage Description** minh bạch, rõ ràng bằng tiếng Anh và tiếng Việt:
* `NSMotionUsageDescription`: *"LifeTycoon requires motion sensor access to count your steps and convert walking progress into in-game stamina and rewards."*
* **Lưu file Ebook:** Lưu hoàn toàn vào thư mục `NSDocumentDirectory` nội bộ của App (App Sandbox) để iOS không coi là app chia sẻ file lậu.

### 2.2. Tránh hiểu nhầm cờ bạc / tiền ảo thật (Virtual Currency vs Real Money)
* **Google Play Financial Services Policy & Apple Guideline 3.1.5 (Cryptocurrencies):**
  * Trong game có sàn giao dịch ảo (`TECH`, `FOOD`, `PROP`, `GOLD`) và Ngân hàng mô phỏng.
  * **Quy tắc bắt buộc:** Ghi rõ trên màn hình Splash Screen, Onboarding và Tab Finance: *"Tất cả tiền tệ, cổ phiếu và tài sản trong ứng dụng là hoàn toàn giả lập nhằm mục đích giải trí và nâng cao năng suất. Ứng dụng không có tính năng đổi thưởng ra tiền thật, không cung cấp dịch vụ đầu tư tài chính thực tế."*
  * Không dùng icon của Bitcoin/Ethereum thật để tránh bị bot quét nhầm là app Crypto Unlicensed.

### 2.3. Tối ưu Dung lượng & Hiệu năng (App Size & Performance)
* **Android:** Bật R8 Shrinking, đóng gói dạng `.aab` (Android App Bundle). Tách asset âm thanh/ảnh theo chuẩn WebP/SVG để dung lượng download dưới $30\text{ MB}$.
* **iOS:** Tối ưu Asset Catalog, bật LLVM optimization.

---

## 3. Cấu trúc Source Code Chuẩn Store-Ready

```text
LifeTycoon/
├── android/                  # Native Android configs, ProGuard rules, SAF handlers
├── ios/                      # iOS Runner, Info.plist privacy descriptions
├── lib/
│   ├── app/
│   │   ├── config/           # Theme (Dark OLED), App Constants, Store Disclaimer
│   │   └── routes/           # GoRouter
│   ├── core/
│   │   ├── anti_cheat/       # Anti-Time-Travel, Uptime Bridge, Sensor Moving Avg
│   │   ├── database/         # Drift SQLite DB & DAOs
│   │   ├── hardware/         # Sensor wrappers, Pedometer stream, Proximity handler
│   │   └── security/         # Secure Storage, Hardware Keystore wrapper
│   └── features/
│       ├── action_hub/       # Pomodoro (Face-down), E-Reader (SAF), Pedometer, Tasks
│       ├── business_sim/     # Idle Cashflow Engine, Level Scaling
│       ├── finance_sim/      # Bank Savings, GBM Stock Market (fl_chart)
│       ├── assets_prestige/  # Luxury Items Catalog, Inventory
│       └── player/           # Stats, Wallet, Energy System
└── test/                     # Unit Tests cho Math Engine & Anti-Cheat Rules
```
