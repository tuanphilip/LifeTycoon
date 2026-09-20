// LifeTycoon Game Core Engine & State Management (Updated: Flexible Reading Tracking)

let player = {
  name: "Philip Tuan",
  level: 1,
  cash: 2500,
  int: 15,
  sta: 20,
  dis: 18,
  pre: 12,
  readingMinutes: 0,
  readingActive: false,
  readingInterval: null,
  steps: 3450,
  pomoActive: false,
  pomoSeconds: 25 * 60,
  pomoInterval: null
};

let businesses = [
  {
    id: "biz-1",
    name: "Xe Cà Phê Takeaway",
    level: 2,
    baseRevPerSec: 0.25, // $900/h
    baseCostPerSec: 0.05, // $180/h
    basePrice: 1000,
    unclaimed: 450,
    reqInt: 0,
    reqSta: 0
  },
  {
    id: "biz-2",
    name: "Đội Xe Taxi Đô Thị",
    level: 1,
    baseRevPerSec: 0.80, // $2880/h
    baseCostPerSec: 0.20, // $720/h
    basePrice: 5000,
    unclaimed: 120,
    reqInt: 0,
    reqSta: 15
  },
  {
    id: "biz-3",
    name: "Studio Gia Công Phần Mềm",
    level: 0, // Not unlocked
    baseRevPerSec: 2.50, // $9000/h
    baseCostPerSec: 0.60,
    basePrice: 20000,
    unclaimed: 0,
    reqInt: 25,
    reqSta: 0
  }
];

let assets = [
  { id: "car-1", name: "Xe Máy Vespa", price: 1500, pre: 5, icon: "🛵", owned: true },
  { id: "car-2", name: "Sedan Hạng Sang", price: 25000, pre: 25, icon: "🚗", owned: false },
  { id: "prop-1", name: "Căn Hộ Studio", price: 50000, pre: 60, icon: "🏢", owned: false },
  { id: "watch-1", name: "Đồng Hồ Cơ Thụy Sĩ", price: 10000, pre: 15, icon: "⌚", owned: false }
];

let stocks = {
  TECH: { name: "Tập Đoàn Công Nghệ", price: 152.40, initial: 150, drift: 0.15, vol: 0.40, history: [148, 149, 150, 151, 152.4], owned: 0, avgPrice: 0 },
  FOOD: { name: "Chuỗi F&B Toàn Cầu", price: 45.20, initial: 45, drift: 0.06, vol: 0.12, history: [44.8, 45.0, 45.1, 45.2], owned: 0, avgPrice: 0 },
  PROP: { name: "Bất Động Sản Đô Thị", price: 88.00, initial: 85, drift: 0.08, vol: 0.20, history: [86, 87, 86.5, 88.0], owned: 0, avgPrice: 0 },
  GOLD: { name: "Quỹ Vàng Dự Trữ", price: 215.00, initial: 210, drift: 0.04, vol: 0.10, history: [212, 213, 214, 215.0], owned: 0, avgPrice: 0 }
};

let currentStock = "TECH";
let stockChart = null;

// Initialize App
document.addEventListener("DOMContentLoaded", () => {
  lucide.createIcons();
  initStockChart();
  renderTopStatus();
  renderBusinesses();
  renderAssets();
  
  // Game Loop tick (every 1 second)
  setInterval(gameLoopTick, 1000);
  
  // Stock Market GBM tick (every 3 seconds for fast demo)
  setInterval(stockMarketTick, 3000);
});

function formatMoney(amount) {
  return "$" + Math.floor(amount).toLocaleString();
}

function renderTopStatus() {
  document.getElementById("player-cash").innerText = formatMoney(player.cash);
  document.getElementById("stat-int").innerText = `${player.int} INT`;
  document.getElementById("stat-sta").innerText = `${player.sta} STA`;
  document.getElementById("stat-dis").innerText = `${player.dis} DIS`;
  document.getElementById("stat-pre").innerText = `${player.pre} PRE`;
  document.getElementById("player-level-badge").innerText = `LV.${player.level}`;
}

// Business Management
function renderBusinesses() {
  const container = document.getElementById("business-list");
  container.innerHTML = "";
  
  let totalRevPerHour = 0;

  businesses.forEach((biz, idx) => {
    if (biz.level > 0) {
      const speedMultiplier = 1.0 + (0.01 * player.sta);
      const netSec = (biz.baseRevPerSec * biz.level * speedMultiplier) - biz.baseCostPerSec;
      totalRevPerHour += (netSec * 3600);
    }

    const upgradeCost = Math.floor(biz.basePrice * Math.pow(1.15, biz.level));
    const isUnlocked = biz.level > 0;
    const canUnlock = player.int >= biz.reqInt && player.sta >= biz.reqSta;

    const card = document.createElement("div");
    card.className = "bg-surfaceDark border border-borderDark rounded-xl p-4";
    card.innerHTML = `
      <div class="flex justify-between items-center mb-2">
        <div class="font-bold text-sm text-white">${biz.name}</div>
        <span class="text-xs ${isUnlocked ? 'bg-zinc-800 text-goldYellow' : 'bg-red-950 text-red-400'} px-2 py-0.5 rounded font-bold">
          ${isUnlocked ? `Cấp ${biz.level}` : 'Chưa Mở Khóa'}
        </span>
      </div>

      ${isUnlocked ? `
        <div class="flex justify-between items-center text-xs mb-3 text-gray-400">
          <span class="text-moneyGreen font-medium">Doanh thu: +$${Math.floor(biz.baseRevPerSec * biz.level * (1 + 0.01 * player.sta) * 3600).toLocaleString()}/h</span>
          <span class="text-dangerRed font-medium">Bảo trì: -$${Math.floor(biz.baseCostPerSec * 3600).toLocaleString()}/h</span>
        </div>
        <div class="grid grid-cols-2 gap-2">
          <button onclick="upgradeBiz(${idx})" class="bg-surfaceCard border border-borderDark hover:border-goldYellow text-white text-xs font-semibold py-2 rounded-lg transition active:scale-95">
            Nâng cấp (${formatMoney(upgradeCost)})
          </button>
          <button onclick="claimBiz(${idx})" ${biz.unclaimed > 0 ? '' : 'disabled'} class="bg-moneyGreen disabled:opacity-40 text-black text-xs font-bold py-2 rounded-lg transition active:scale-95">
            Nhận ${formatMoney(biz.unclaimed)}
          </button>
        </div>
      ` : `
        <div class="text-xs text-gray-400 mb-3">
          Yêu cầu: ${biz.reqInt > 0 ? `<span class="${player.int >= biz.reqInt ? 'text-techBlue' : 'text-dangerRed'}">${biz.reqInt} INT</span> ` : ''}
          ${biz.reqSta > 0 ? `<span class="${player.sta >= biz.reqSta ? 'text-goldYellow' : 'text-dangerRed'}">${biz.reqSta} STA</span>` : ''}
        </div>
        <button onclick="unlockBiz(${idx})" ${canUnlock && player.cash >= biz.basePrice ? '' : 'disabled'} class="w-full bg-surfaceCard border border-borderDark text-white text-xs font-bold py-2 rounded-lg disabled:opacity-40">
          Mở Doanh Nghiệp (${formatMoney(biz.basePrice)})
        </button>
      `}
    `;
    container.appendChild(card);
  });

  document.getElementById("total-revenue-rate").innerText = `+$${Math.floor(totalRevPerHour).toLocaleString()}/h`;
}

function gameLoopTick() {
  businesses.forEach(biz => {
    if (biz.level > 0) {
      const speedMultiplier = 1.0 + (0.01 * player.sta);
      const netIncome = (biz.baseRevPerSec * biz.level * speedMultiplier) - biz.baseCostPerSec;
      biz.unclaimed += Math.max(0, netIncome);
    }
  });
  renderBusinesses();
}

function claimBiz(idx) {
  const amount = businesses[idx].unclaimed;
  if (amount > 0) {
    player.cash += amount;
    businesses[idx].unclaimed = 0;
    renderTopStatus();
    renderBusinesses();
  }
}

function upgradeBiz(idx) {
  const cost = Math.floor(businesses[idx].basePrice * Math.pow(1.15, businesses[idx].level));
  if (player.cash >= cost) {
    player.cash -= cost;
    businesses[idx].level += 1;
    renderTopStatus();
    renderBusinesses();
  }
}

function unlockBiz(idx) {
  const biz = businesses[idx];
  if (player.cash >= biz.basePrice && player.int >= biz.reqInt && player.sta >= biz.reqSta) {
    player.cash -= biz.basePrice;
    biz.level = 1;
    renderTopStatus();
    renderBusinesses();
  }
}

// Action Hub - E-Reader (Đo thời gian đọc đơn giản & quy đổi Xu)
function toggleReadingSession() {
  const btn = document.querySelector("#tab-action button[onclick='simulateReading()']");
  if (!player.readingActive) {
    player.readingActive = true;
    player.readingSeconds = 0;
    btn.innerText = "Dừng Đọc & Quy Đổi Thưởng (Đang Đọc...)";
    btn.className = "w-full mt-2 bg-dangerRed text-white font-bold py-2 rounded-lg text-sm transition active:scale-95";
    
    player.readingInterval = setInterval(() => {
      player.readingSeconds += 1;
      const mins = Math.floor(player.readingSeconds / 60);
      const secs = player.readingSeconds % 60;
      document.getElementById("reading-time-display").innerText = `${mins}m ${secs}s`;
    }, 1000);
  } else {
    clearInterval(player.readingInterval);
    player.readingActive = false;
    const earnedMins = Math.max(1, Math.floor(player.readingSeconds / 60));
    const rewardCash = earnedMins * 100; // $100 per minute
    const rewardInt = Math.max(1, Math.floor(earnedMins / 5)); // +1 INT per 5 mins
    
    player.cash += rewardCash;
    player.int += rewardInt;
    player.readingMinutes += earnedMins;
    
    alert(`🎉 Bạn đã đọc sách ${earnedMins} phút! Quy đổi thành công +$${rewardCash.toLocaleString()} Xu & +${rewardInt} Trí Tuệ (INT)!`);
    
    document.getElementById("reading-time-display").innerText = `${player.readingMinutes} phút`;
    btn.innerText = "Mở Sách Đọc (EPUB / PDF)";
    btn.className = "w-full mt-2 bg-surfaceCard border border-borderDark hover:border-techBlue text-white font-medium py-2 rounded-lg text-sm transition active:scale-95";
    
    renderTopStatus();
    renderBusinesses();
  }
}

// Map simulateReading to toggleReadingSession
window.simulateReading = toggleReadingSession;

function togglePomodoro() {
  const btn = document.getElementById("btn-start-pomo");
  if (!player.pomoActive) {
    player.pomoActive = true;
    btn.innerText = "Dừng Phiên Tập Trung";
    btn.className = "w-full mt-2 bg-dangerRed text-white font-bold py-2.5 rounded-lg text-sm transition active:scale-95";
    player.pomoInterval = setInterval(() => {
      if (player.pomoSeconds > 0) {
        player.pomoSeconds -= 1;
        const mins = String(Math.floor(player.pomoSeconds / 60)).padStart(2, '0');
        const secs = String(player.pomoSeconds % 60).padStart(2, '0');
        document.getElementById("pomo-timer-display").innerText = `${mins}:${secs}`;
      } else {
        clearInterval(player.pomoInterval);
        player.pomoActive = false;
        player.cash += 1000;
        player.dis += 5;
        player.pomoSeconds = 25 * 60;
        alert("🎉 Xuất sắc! Bạn hoàn thành phiên Deep Work: +$1,000 Xu và +5 Kỷ Luật!");
        renderTopStatus();
        btn.innerText = "Bắt đầu Phiên Tập Trung (25 Phút)";
        btn.className = "w-full mt-2 bg-gradient-to-r from-emerald-500 to-teal-600 text-black font-bold py-2.5 rounded-lg text-sm transition active:scale-95";
      }
    }, 1000);
  } else {
    clearInterval(player.pomoInterval);
    player.pomoActive = false;
    player.pomoSeconds = 25 * 60;
    document.getElementById("pomo-timer-display").innerText = "25:00";
    btn.innerText = "Bắt đầu Phiên Tập Trung (25 Phút)";
    btn.className = "w-full mt-2 bg-gradient-to-r from-emerald-500 to-teal-600 text-black font-bold py-2.5 rounded-lg text-sm transition active:scale-95";
  }
}

function addSimulatedSteps() {
  player.steps += 500;
  if (player.steps >= 5000) {
    player.cash += 1500;
    player.sta += 5;
    player.steps = 0;
  }
  document.getElementById("step-count-display").innerText = `${player.steps.toLocaleString()} / 5,000`;
  document.getElementById("step-progress-bar").style.width = `${Math.min(100, (player.steps / 5000) * 100)}%`;
  renderTopStatus();
  renderBusinesses();
}

// Assets & Prestige
function renderAssets() {
  const container = document.getElementById("asset-catalog");
  container.innerHTML = "";
  
  assets.forEach(asset => {
    const card = document.createElement("div");
    card.className = "bg-surfaceDark border border-borderDark rounded-xl p-3 flex flex-col items-center text-center";
    card.innerHTML = `
      <div class="text-3xl mb-1">${asset.icon}</div>
      <div class="font-bold text-xs text-white">${asset.name}</div>
      <div class="text-[11px] text-purple-400 font-semibold mb-2">+${asset.pre} Danh Tiếng</div>
      ${asset.owned ? `
        <span class="text-[10px] bg-emerald-950 text-emerald-400 font-bold px-2 py-1 rounded w-full">ĐÃ SỞ HỮU</span>
      ` : `
        <button onclick="buyAsset('${asset.id}')" ${player.cash >= asset.price ? '' : 'disabled'} class="w-full bg-surfaceCard border border-borderDark hover:border-purple-400 text-white text-[11px] font-bold py-1.5 rounded disabled:opacity-40">
          ${formatMoney(asset.price)}
        </button>
      `}
    `;
    container.appendChild(card);
  });
}

function buyAsset(id) {
  const asset = assets.find(a => a.id === id);
  if (asset && !asset.owned && player.cash >= asset.price) {
    player.cash -= asset.price;
    asset.owned = true;
    player.pre += asset.pre;
    renderTopStatus();
    renderAssets();
  }
}

// Stock & GBM Math Engine
function initStockChart() {
  const ctx = document.getElementById('stockChart').getContext('2d');
  stockChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: stocks[currentStock].history.map((_, i) => `${i + 1}`),
      datasets: [{
        label: currentStock,
        data: [...stocks[currentStock].history],
        borderColor: '#00E676',
        backgroundColor: 'rgba(0, 230, 118, 0.08)',
        borderWidth: 2,
        fill: true,
        tension: 0.3,
        pointRadius: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        x: { display: false },
        y: {
          grid: { color: 'rgba(255, 255, 255, 0.05)' },
          ticks: { color: '#90A4AE', font: { size: 10 } }
        }
      }
    }
  });
}

function selectStock(sym) {
  currentStock = sym;
  ['TECH', 'FOOD', 'PROP', 'GOLD'].forEach(s => {
    const btn = document.getElementById(`btn-stock-${s}`);
    if (s === sym) {
      btn.className = "py-1.5 text-xs font-bold rounded-lg border border-techBlue bg-techBlue/20 text-techBlue";
    } else {
      btn.className = "py-1.5 text-xs font-bold rounded-lg border border-borderDark bg-surfaceCard text-gray-400";
    }
  });

  const st = stocks[sym];
  document.getElementById("stock-symbol-title").innerText = `${sym} (${st.name})`;
  updateStockUI();
}

function stockMarketTick() {
  Object.keys(stocks).forEach(sym => {
    const st = stocks[sym];
    // Box-Muller Gaussian
    let u1 = Math.random(), u2 = Math.random();
    while (u1 === 0) u1 = Math.random();
    const z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2);

    const dt = 1.0 / 252.0;
    const driftTerm = (st.drift - 0.5 * Math.pow(st.vol, 2)) * dt;
    const shockTerm = st.vol * Math.sqrt(dt) * z;
    
    st.price = Math.max(1.0, +(st.price * Math.exp(driftTerm + shockTerm)).toFixed(2));
    st.history.push(st.price);
    if (st.history.length > 20) st.history.shift();
  });

  updateStockUI();
}

function updateStockUI() {
  const st = stocks[currentStock];
  const change = (((st.price - st.initial) / st.initial) * 100).toFixed(2);
  const isUp = change >= 0;

  document.getElementById("stock-price-display").innerText = `$${st.price.toFixed(2)}`;
  document.getElementById("stock-price-display").className = `text-lg font-extrabold ${isUp ? 'text-moneyGreen' : 'text-dangerRed'} font-mono`;
  document.getElementById("stock-change-display").innerText = `${isUp ? '+' : ''}${change}%`;
  document.getElementById("stock-change-display").className = `text-[11px] ${isUp ? 'text-moneyGreen' : 'text-dangerRed'} font-semibold`;
  document.getElementById("stock-holding-info").innerText = `Đang nắm giữ: ${st.owned} cổ | Giá vốn: $${st.avgPrice.toFixed(2)}`;

  if (stockChart) {
    stockChart.data.labels = st.history.map((_, i) => `${i + 1}`);
    stockChart.data.datasets[0].data = [...st.history];
    stockChart.data.datasets[0].borderColor = isUp ? '#00E676' : '#FF5252';
    stockChart.data.datasets[0].backgroundColor = isUp ? 'rgba(0, 230, 118, 0.08)' : 'rgba(255, 82, 82, 0.08)';
    stockChart.update('none');
  }
}

function buyStock() {
  const st = stocks[currentStock];
  if (player.cash >= st.price) {
    player.cash -= st.price;
    st.avgPrice = ((st.avgPrice * st.owned) + st.price) / (st.owned + 1);
    st.owned += 1;
    renderTopStatus();
    updateStockUI();
  }
}

function sellStock() {
  const st = stocks[currentStock];
  if (st.owned > 0) {
    player.cash += st.price;
    st.owned -= 1;
    if (st.owned === 0) st.avgPrice = 0;
    renderTopStatus();
    updateStockUI();
  }
}

function depositBank(amount) {
  if (player.cash >= amount) {
    player.cash -= amount;
    alert(`Đã gửi thành công ${formatMoney(amount)} vào gói Tiết kiệm linh hoạt! Lãi suất 0.1%/ngày.`);
    renderTopStatus();
  }
}

function depositBankTerm(amount) {
  if (player.cash >= amount) {
    player.cash -= amount;
    alert(`Đã gửi thành công ${formatMoney(amount)} vào sổ Tiết kiệm 30 ngày! Lãi suất 7.0%/kỳ hạn.`);
    renderTopStatus();
  }
}

// Navigation Tabs
function switchTab(tabId) {
  document.querySelectorAll(".tab-content").forEach(el => el.classList.remove("active"));
  document.getElementById(`tab-${tabId}`).classList.add("active");

  ['action', 'business', 'finance', 'assets'].forEach(t => {
    const navBtn = document.getElementById(`nav-${t}`);
    if (t === tabId) {
      navBtn.className = "flex flex-col items-center justify-center text-moneyGreen";
      navBtn.querySelector("span").className = "text-[10px] font-bold";
    } else {
      navBtn.className = "flex flex-col items-center justify-center text-gray-400 hover:text-white";
      navBtn.querySelector("span").className = "text-[10px] font-semibold";
    }
  });

  if (tabId === 'finance' && stockChart) {
    setTimeout(() => stockChart.resize(), 50);
  }
}
