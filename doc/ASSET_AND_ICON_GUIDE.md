# HƯỚNG DẪN THIẾT KẾ TÀI NGUYÊN, ICON & HÌNH ẢNH (Asset Pipeline Guide)

Tài liệu này hướng dẫn chi tiết quy chuẩn kích thước, phong cách đồ họa và các công cụ AI miễn phí/tối ưu để tạo trọn bộ tài nguyên cho **LifeTycoon** chuẩn Store.

---

## 1. Phong cách Đồ họa (Visual Style Direction)

* **Phong cách chủ đạo:** **Dark Modern Minimalist + 3D Isometric Glossy Clay / Glassmorphism** (Phong cách giống *Business Empire: RichMan* hoặc fintech hiện đại như Revolut/CashApp).
* **Bảng màu giao diện (Color Palette):**
  * Nền chính: `#0D0F12` (OLED Pure Black/Dark Slate).
  * Card Surface: `#161A20` & `#1E242C`.
  * Tiền tệ / Lợi nhuận: `#00E676` (Neon Green).
  * Công nghệ / Trí tuệ: `#2979FF` (Tech Blue).
  * Thể lực / Vàng bạc: `#FFB300` (Electric Gold / Amber).
  * Cảnh báo / Chi phí: `#FF5252` (Crimson Red).

---

## 2. Danh mục & Kích thước Tài nguyên Cần chuẩn bị

### 2.1. App Icon & Store Graphics
| Loại tài nguyên | Kích thước (px) | Định dạng | Mục đích |
| :--- | :--- | :--- | :--- |
| **App Store Icon** | $1024 \times 1024$ | PNG (không bo góc, không alpha/transparency) | iOS App Store |
| **Google Play Icon** | $512 \times 512$ | PNG (32-bit color, bo góc 20% khi submit) | Google Play Store |
| **Feature Graphic** | $1024 \times 500$ | PNG / JPG (dưới 15MB) | Banner quảng bá Google Play |
| **Store Screenshots** | $1290 \times 2796$ (iOS) & $1080 \times 2400$ (Android) | PNG | 5-8 ảnh chụp màn hình hiển thị 4 Tab game |

### 2.2. In-Game Icons & Badges
* **Hệ thống Icon UI:** Dùng vector SVG từ bộ **Lucide Icons** hoặc **Phosphor Icons** (miễn phí thương mại, cực nét trên mọi độ phân giải màn hình).
* **Chỉ số cá nhân:**
  * 🧠 Trí tuệ (INT): `brain.svg` / `book-open.svg`
  * ⚡ Thể lực (STA): `zap.svg` / `footprints.svg`
  * 🛡️ Kỷ luật (DIS): `shield.svg` / `hourglass.svg`
  * 👑 Danh tiếng (PRE): `crown.svg` / `gem.svg`

### 2.3. Danh mục Thẻ 2D / 3D Asset Cards (WebP / Transparent PNG)
Kích thước chuẩn: $600 \times 600\text{ px}$ (Nền trong suốt, cắt sát viền, nén dạng `.webp` dung lượng $< 60\text{ KB}$/ảnh).

#### A. Doanh nghiệp (Business Cards):
1. `biz_coffee_cart.webp`: Quầy cà phê takeaway hiện đại.
2. `biz_taxi_fleet.webp`: Đội xe taxi công nghệ màu vàng/xanh neon.
3. `biz_it_studio.webp`: Văn phòng thiết kế/lập trình máy móc hiện đại.
4. `biz_real_estate.webp`: Tòa nhà văn phòng cao ốc kính.

#### B. Tài sản Xa xỉ (Luxury Assets):
1. `asset_vespa.webp`: Xe máy tay ga phong cách cổ điển Ý.
2. `asset_sedan.webp`: Xe hơi hạng sang màu đen bóng.
3. `asset_supercar.webp`: Siêu xe thể thao màu cam/đỏ.
4. `asset_penthouse.webp`: Căn hộ áp mái view thành phố đêm.
5. `asset_luxury_watch.webp`: Đồng hồ cơ mặt kính sapphire viền vàng.

---

## 3. Công thức Tạo Prompt Prompt AI (Midjourney / Stable Diffusion / DALL-E 3)

Bạn có thể dùng các prompt mẫu dưới đây để tự sinh ảnh chất lượng cao 100% đồng bộ phong cách:

### Prompt mẫu cho Doanh nghiệp (Business):
> `3D isometric icon of a modern coffee takeaway kiosk, high glossy clay texture, minimalist fintech dark theme background, glowing green neon accent, clean edge, octane render, 8k --v 6.0 --q 2`

### Prompt mẫu cho Siêu xe / Xe hơi (Vehicles):
> `3D render of a futuristic luxury sports car, sleek glossy dark metallic finish with neon gold lighting trims, isometric floating angle, transparent background, studio lighting, hyper-realistic, minimal game asset --v 6.0`

### Prompt mẫu cho Bất động sản (Real Estate):
> `3D isometric modern glass skyscraper building, penthouse on top with warm interior lights, dark luxury background, minimalist clean architecture, octane render --v 6.0`

### Prompt mẫu cho Đồng hồ Xa xỉ (Watches):
> `3D render of a luxury Swiss mechanical chronograph watch, titanium case, sapphire glass, glowing hands, isometric view, transparent background, high-end commercial style --v 6.0`

---

## 4. Công cụ Xử lý & Tối ưu Asset Tự động

1. **Tách nền trong suốt:** Sử dụng [remove.bg](https://www.remove.bg) hoặc [clipdrop.co/remove-background](https://clipdrop.co/remove-background) để làm sạch nền ảnh.
2. **Chuyển đổi sang WebP (Nén dung lượng):**
   * Dùng CLI `cwebp`:
     ```bash
     cwebp -q 85 asset_supercar.png -o asset_supercar.webp
     ```
   * Hoặc công cụ online: [Squoosh.app](https://squoosh.app) (chọn WebP, chỉnh chất lượng 80-85%).
3. **Cấu trúc lưu trong project Flutter:**
   ```text
   assets/
   ├── icons/           # Các file svg UI (zap, briefcase, chart, gem)
   └── images/
       ├── businesses/  # biz_coffee.webp, biz_taxi.webp, ...
       └── luxury/      # car_sedan.webp, watch_swiss.webp, ...
   ```
