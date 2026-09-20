import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app/config/theme.dart';
import 'core/bloc/game_bloc.dart';
import 'features/player/domain/entities/player_profile.dart';
import 'features/player/presentation/widgets/top_status_bar.dart';
import 'features/business_sim/domain/entities/business_entity.dart';
import 'features/business_sim/presentation/widgets/business_card_widget.dart';
import 'features/finance_sim/domain/entities/stock_entity.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeTycoonApp());
}

class LifeTycoonApp extends StatelessWidget {
  const LifeTycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(),
      child: MaterialApp(
        title: 'LifeTycoon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Default to Business Tab
  String _selectedStock = 'TECH';

  // E-Reader state
  int _readingSessionSeconds = 0;
  bool _isReadingActive = false;

  // Assets list
  final List<Map<String, dynamic>> _luxuryAssets = [
    {'id': 'vespa', 'name': 'Xe Máy Vespa', 'price': 1500.0, 'prestige': 5, 'icon': '🛵', 'owned': true},
    {'id': 'sedan', 'name': 'Sedan Hạng Sang', 'price': 25000.0, 'prestige': 25, 'icon': '🚗', 'owned': false},
    {'id': 'supercar', 'name': 'Siêu Xe Thể Thao', 'price': 120000.0, 'prestige': 80, 'icon': '🏎️', 'owned': false},
    {'id': 'penthouse', 'name': 'Penthouse Trung Tâm', 'price': 500000.0, 'prestige': 250, 'icon': '🏢', 'owned': false},
    {'id': 'watch', 'name': 'Đồng Hồ Thụy Sĩ', 'price': 10000.0, 'prestige': 15, 'icon': '⌚', 'owned': false},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                TopStatusBar(player: state.player),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      _buildActionHubView(context, state),
                      _buildBusinessSimView(context, state),
                      _buildFinanceSimView(context, state),
                      _buildAssetPrestigeView(context, state),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Hành Động'),
              BottomNavigationBarItem(icon: Icon(Icons.business_center), label: 'Doanh Nghiệp'),
              BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Thị Trường'),
              BottomNavigationBarItem(icon: Icon(Icons.diamond), label: 'Tài Sản'),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 1: ACTION HUB ---
  Widget _buildActionHubView(BuildContext context, GameState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Trung Tâm Năng Lực & Hành Động',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        const Text(
          'Đo lường thời gian đọc sách & tập trung để nhận vốn mồi và nâng cấp bản thân.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // 1. E-Reader Card (Đo thời gian đọc sách đơn giản)
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('📖', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Text('Trình Đọc Sách (E-Reader)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        '${_readingSessionSeconds ~/ 60}m ${_readingSessionSeconds % 60}s',
                        style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Mỗi 10 phút đọc sách tích lũy = +$500 Xu & +2 Trí Tuệ (INT)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isReadingActive ? AppColors.danger : AppColors.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  icon: Icon(_isReadingActive ? Icons.stop : Icons.menu_book),
                  label: Text(_isReadingActive ? 'Dừng Đọc & Quy Đổi Thưởng' : 'Mở Sách Đọc (EPUB / PDF)'),
                  onPressed: () {
                    setState(() {
                      if (_isReadingActive) {
                        _isReadingActive = false;
                        context.read<GameBloc>().add(CompleteReadingSessionEvent((_readingSessionSeconds ~/ 60) + 1));
                        _readingSessionSeconds = 0;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 Đã quy đổi thời gian đọc thành +$500 Xu & +2 INT!')),
                        );
                      } else {
                        _isReadingActive = true;
                        _readingSessionSeconds += 600; // Simulate 10 mins reading for quick test
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 2. Pomodoro Deep Work Card
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('⏳', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text('Tập Trung Sâu (Pomodoro)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Hoàn thành phiên 25 phút = +$1,000 Xu & +5 Kỷ Luật (DIS)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  onPressed: () {
                    context.read<GameBloc>().add(const CompletePomodoroEvent(25));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎉 Hoàn thành phiên Pomodoro: +$1,000 Xu & +5 Kỷ Luật!')),
                    );
                  },
                  child: const Text('Bắt Đầu Phiên 25 Phút', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 3. Pedometer Step Tracker Card
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🏃', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text('Vận Động Thể Chất (Bước Chân)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Mỗi 5.000 bước đi bộ = +$1,500 Xu & +5 Thể Lực (STA)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  onPressed: () {
                    context.read<GameBloc>().add(const RecordStepsEvent(5000));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎉 Đã ghi nhận 5.000 bước chân: +$1,500 Xu & +5 Thể Lực!')),
                    );
                  },
                  child: const Text('Ghi Nhận 5.000 Bước Chân', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: BUSINESS SIMULATOR ---
  Widget _buildBusinessSimView(BuildContext context, GameState state) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Danh Mục Doanh Nghiệp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.rocket_launch, size: 16),
                label: const Text('Niêm Yết IPO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () {
                  context.read<GameBloc>().add(TriggerIPORebirthEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('👑 Đã thực hiện IPO: Nhận +50 Điểm Danh Tiếng & Cổ Phần Vàng!')),
                  );
                },
              ),
            ],
          ),
        ),
        ...state.businesses.map((business) {
          if (business.level == 0) {
            // Unlocked Card
            final bool canUnlock = state.player.cashBalance >= business.basePurchaseCost &&
                state.player.intellectStat >= business.requiredIntellect &&
                state.player.staminaStat >= business.requiredStamina;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(business.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Chưa Mở Khóa', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Yêu cầu: ${business.requiredIntellect > 0 ? "${business.requiredIntellect} INT  " : ""}${business.requiredStamina > 0 ? "${business.requiredStamina} STA" : ""}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canUnlock ? AppColors.primary : AppColors.surfaceVariant,
                        foregroundColor: canUnlock ? Colors.black : AppColors.textSecondary,
                        minimumSize: const Size(double.infinity, 38),
                      ),
                      onPressed: canUnlock ? () => context.read<GameBloc>().add(UnlockBusinessEvent(business.id)) : null,
                      child: Text('Mở Khóa (${currencyFormatter.format(business.basePurchaseCost)})'),
                    ),
                  ],
                ),
              ),
            );
          }

          return BusinessCardWidget(
            business: business,
            onClaim: () => context.read<GameBloc>().add(ClaimBusinessMoneyEvent(business.id)),
            onUpgrade: () => context.read<GameBloc>().add(UpgradeBusinessEvent(business.id)),
          );
        }).toList(),
      ],
    );
  }

  // --- TAB 3: FINANCE & STOCK MARKET ---
  Widget _buildFinanceSimView(BuildContext context, GameState state) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final stock = state.stocks[_selectedStock] ?? state.stocks.values.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Sàn Chứng Khoán & Tiền Mã Hóa (GBM Simulation)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // Stock Selector Buttons
        Row(
          children: state.stocks.keys.map((sym) {
            final isSelected = sym == _selectedStock;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? AppColors.secondary : AppColors.surfaceCard,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => setState(() => _selectedStock = sym),
                  child: Text(sym, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Stock Info & Chart
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(stock.companyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      currencyFormatter.format(stock.currentPrice),
                      style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineBarData(
                          spots: stock.history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Đang nắm giữ: ${stock.userOwnedShares.toInt()} Cổ | Giá vốn TB: ${currencyFormatter.format(stock.averageBuyPrice)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                        onPressed: () => context.read<GameBloc>().add(BuyStockEvent(_selectedStock, 1)),
                        child: const Text('MUA (1 Cổ)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
                        onPressed: stock.userOwnedShares >= 1 ? () => context.read<GameBloc>().add(SellStockEvent(_selectedStock, 1)) : null,
                        child: const Text('BÁN (1 Cổ)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 4: ASSETS & PRESTIGE ---
  Widget _buildAssetPrestigeView(BuildContext context, GameState state) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const dynamicDelegate(),
      itemCount: _luxuryAssets.length,
      itemBuilder: (context, index) {
        final asset = _luxuryAssets[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(asset['icon'], style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 6),
                Text(asset['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                Text('+${asset['prestige']} Danh Tiếng', style: const TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (asset['owned'] == true)
                  const Text('ĐÃ SỞ HỮU', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11))
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onPressed: state.player.cashBalance >= asset['price']
                      ? () {
                          setState(() => asset['owned'] = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('🎉 Bạn đã mua ${asset['name']} thành công!')),
                          );
                        }
                      : null,
                    child: Text(currencyFormatter.format(asset['price']), style: const TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class dynamicDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  const dynamicDelegate()
      : super(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        );
}
