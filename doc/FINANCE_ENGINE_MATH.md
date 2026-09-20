# ĐẶC TẢ TOÁN HỌC & ENGINE MÔ PHỎNG KINH TẾ (LifeTycoon)

## 1. Mô hình Biến động Giá Chứng khoán (Geometric Brownian Motion - GBM)

Để mô phỏng thị trường chứng khoán ảo chạy hoàn toàn offline mà vẫn có tính chân thực cao, biểu đồ giá tuân theo quá trình ngẫu nhiên GBM chuẩn tài chính:

$$S_{t + \Delta t} = S_t \cdot \exp\left( \left(\mu - \frac{1}{2}\sigma^2\right)\Delta t + \sigma \sqrt{\Delta t} \cdot Z \right)$$

### 1.1. Giải thích tham số:
* $S_t$: Giá cổ phiếu tại thời điểm hiện tại $t$.
* $S_{t + \Delta t}$: Giá cổ phiếu sau khoảng thời gian $\Delta t$ (mỗi nến cách nhau 15 phút hoặc 1 tick trong game).
* $\mu$ (Drift Rate): Tỷ suất sinh lời kỳ vọng hàng năm (xu hướng tăng trưởng dài hạn của ngành).
* $\sigma$ (Volatility): Độ biến động giá của ngành.
* $Z \sim \mathcal{N}(0, 1)$: Biến ngẫu nhiên có phân phối chuẩn tắc (sinh qua thuật toán Box-Muller transform trong Dart).

### 1.2. Bảng tham số mặc định cho 4 mã cổ phiếu:
| Mã | Ngành | $\mu$ (Kỳ vọng) | $\sigma$ (Biến động) | Đặc tính |
| :--- | :--- | :--- | :--- | :--- |
| `TECH` | Công nghệ cao | $+0.15$ | $0.40$ | Tăng trưởng nhanh, rủi ro cao, nến dài |
| `FOOD` | Bán lẻ tiêu dùng | $+0.06$ | $0.12$ | Ổn định, ít sóng, thích hợp ăn cổ tức |
| `PROP` | Bất động sản | $+0.08$ | $0.20$ | Chu kỳ vừa, thanh khoản trung bình |
| `GOLD` | Kim loại quý | $+0.04$ | $0.10$ | Trú ẩn an toàn khi thị trường giảm |

### 1.3. Code mẫu Pure Dart (Box-Muller & GBM Tick):
```dart
import 'dart:math';

class GbmEngine {
  final Random _rnd = Random();

  double _nextGaussian() {
    double u1 = _rnd.nextDouble();
    double u2 = _rnd.nextDouble();
    while (u1 <= 1e-15) {
      u1 = _rnd.nextDouble();
    }
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }

  double calculateNextPrice({
    required double currentPrice,
    required double drift, // mu
    required double volatility, // sigma
    double dt = 1.0 / 252.0, // delta t
  }) {
    double z = _nextGaussian();
    double driftTerm = (drift - 0.5 * pow(volatility, 2)) * dt;
    double shockTerm = volatility * sqrt(dt) * z;
    return currentPrice * exp(driftTerm + shockTerm);
  }
}
```

---

## 2. Công thức Dòng tiền Offline (Idle Cash Flow Engine)

Mỗi doanh nghiệp sở hữu tạo ra doanh thu thụ động theo thời gian:

$$\text{Net Revenue Rate} = \text{RevenuePerSec} - \text{CostPerSec}$$

### 2.1. Doanh thu sau thời gian Offline:
$$\text{Total Profit} = \min(\Delta t_{\text{offline}}, 12 \times 3600) \times \max(0, \text{Net Revenue Rate})$$

* Giới hạn tối đa **12 giờ** tích lũy. Sau 12 giờ người chơi phải mở app bấm **Claim** để kho tiền không bị tràn.
* Nếu $\text{Net Revenue Rate} < 0$ (chi phí bảo trì lớn hơn doanh thu) và người chơi không đủ tiền mặt bù đắp, trạng thái doanh nghiệp tự động chuyển sang `is_paused = true`.

---

## 3. Công thức Nâng cấp Doanh nghiệp (Cost Scaling)

Chi phí nâng cấp cấp độ tiếp theo của doanh nghiệp tuân theo hàm mũ:

$$\text{Upgrade Cost}(L) = \text{BaseCost} \times (1.15)^{L - 1}$$

Trong đó:
* $L$: Cấp độ mục tiêu cần nâng cấp lên.
* $\text{BaseCost}$: Chi phí mua doanh nghiệp ở Cấp 1.
* Hệ số nhân $1.15$ đảm bảo độ khó tăng dần theo phong cách Idle Tycoon truyền thống.
