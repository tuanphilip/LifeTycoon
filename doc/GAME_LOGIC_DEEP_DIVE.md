# ĐẶC TẢ CHI TIẾT LOGIC TOÁN HỌC & GAME DESIGN (LifeTycoon Deep Dive)

Tài liệu này định nghĩa toàn bộ công thức cân bằng kinh tế (Game Economy Balance), hệ số mở rộng (Scaling Formulas), cơ chế Prestige/Rebirth và ma trận tài sản trong game.

---

## 1. Hệ thống Chỉ số Người chơi & Tác động Gameplay (Stat Influence Matrix)

Các chỉ số thu được từ nỗ lực đời thực (Action Hub) không chỉ là điểm số vô nghĩa mà tác động trực tiếp vào cơ chế kinh doanh và đầu tư:

| Chỉ số | Nguồn thu thập | Công thức tác động Gameplay |
| :--- | :--- | :--- |
| **🧠 INT (Trí Tuệ)** | Đọc sách (.epub/.pdf) | 1. Điều kiện mở khóa doanh nghiệp công nghệ.<br>2. Giảm phí giao dịch sàn chứng khoán: $\text{Fee} = \max(0.1\%, 1.5\% - 0.05\% \times \text{INT})$.<br>3. Mở rộng hạn mức gửi ngân hàng. |
| **⚡ STA (Thể Lực)** | Đi bộ / Chạy bộ (Steps) | 1. Mở khóa doanh nghiệp vận tải/thi công.<br>2. Tăng tốc độ chu kỳ sinh tiền: $\text{CycleSpeedMultiplier} = 1 + 0.01 \times \text{STA}$. |
| **🛡️ DIS (Kỷ Luật)** | Pomodoro Deep Work | 1. Tăng thời gian lưu trữ tiền Offline tối đa: $\text{MaxOfflineHours} = \min(24, 12 + 0.5 \times \text{DIS})$.<br>2. Tăng tỷ lệ hoàn thành nhiệm vụ và giảm tỷ lệ phạt bảo trì. |
| **👑 PRE (Danh Tiếng)**| Mua sắm tài sản xa xỉ | 1. Tăng tổng doanh thu toàn bộ đế chế: $\text{TotalRev} = \text{BaseRev} \times (1 + 0.05 \times \text{PRE})$.<br>2. Mở khóa thẻ đen ngân hàng và vòng Rebirth/Prestige. |

---

## 2. Công thức Cân bằng Doanh nghiệp (Business Economy Formulas)

### 2.1. Chi phí Mua & Nâng cấp (Upgrade Cost Scaling)
$$\text{Cost}(L) = \text{BaseCost} \times (1.15)^{L - 1}$$

### 2.2. Doanh thu Doanh nghiệp (Revenue Scaling)
Doanh thu tăng theo cấp độ nhưng có các mốc đột phá (Milestone Multipliers) tại cấp 25, 50, 100, 200:
$$\text{Rev}(L) = \text{BaseRev} \times L \times \prod \text{MilestoneMultiplier}$$
* **Cấp 25:** x2 Doanh thu
* **Cấp 50:** x3 Doanh thu
* **Cấp 100:** x5 Doanh thu
* **Cấp 200:** x10 Doanh thu

### 2.3. Chi phí Bảo trì & Rủi ro Phá sản (Maintenance & Breakdown Risk)
* Chi phí bảo trì mỗi giờ: $\text{MaintCost} = 0.20 \times \text{BaseRev} \times L^{0.95}$ (tăng chậm hơn doanh thu để đảm bảo có lãi biên).
* Nếu ví tiền mặt $< 0$, doanh nghiệp đình công (`is_paused = true`), người chơi phải làm nhiệm vụ ngoài đời hoặc bán cổ phiếu để cứu doanh nghiệp.

---

## 3. Hệ thống Cổ phiếu & Tin tức Thị trường (News Event Shocks)

Ngoài quá trình ngẫu nhiên GBM:
$$S_{t + \Delta t} = S_t \exp\left( \left(\mu - \frac{1}{2}\sigma^2\right)\Delta t + \sigma \sqrt{\Delta t} Z \right)$$

Hệ thống tích hợp **Event Shocks** (Sự kiện kinh tế giả lập xuất hiện mỗi 30-60 phút):
* **Sự kiện Tích cực (Bull Event):** Ví dụ *"Đột phá công nghệ AI thế hệ mới"* $\rightarrow$ Mã `TECH` được bơm thêm cú sốc giá $+15\% \text{ đến } +35\%$.
* **Sự kiện Tiêu cực (Bear Event):** Ví dụ *"Khủng hoảng chuỗi cung ứng nông sản"* $\rightarrow$ Mã `FOOD` giảm $-10\% \text{ đến } -25\%$.
* **Người chơi có INT cao** sẽ nhận thông báo tin tức trước 60 giây để kịp thời mua/bán kiếm lời.

---

## 4. Cơ chế Tái sinh / Niêm yết IPO (Prestige & IPO Loop)

Khi đạt tổng giá trị tài sản ròng $\ge \$10,000,000$ (Net Worth), người chơi có thể bấm **Niêm Yết Tập Đoàn (IPO / Rebirth)**:
* **Reset:** Bán toàn bộ doanh nghiệp về cấp 1, số dư tiền mặt về $0.
* **Giữ lại:** Toàn bộ chỉ số cá nhân (INT, STA, DIS), tài sản xa xỉ (Xe, Nhà) và Ebook đã đọc.
* **Phần thưởng:** Nhận **Cổ phần Vàng (Gold Shares)** vĩnh viễn:
  $$\text{Gold Shares} = 150 \times \sqrt{\frac{\text{Net Worth}}{\$1,000,000}}$$
* Mỗi Gold Share tăng vĩnh viễn $+2\%$ lợi nhuận cho tất cả doanh nghiệp ở kiếp sau.
