import 'package:flutter/material.dart';
import 'app/config/theme.dart';
import 'features/player/domain/entities/player_profile.dart';
import 'features/player/presentation/widgets/top_status_bar.dart';
import 'features/business_sim/domain/entities/business_entity.dart';
import 'features/business_sim/presentation/widgets/business_card_widget.dart';

void main() {
  runApp(const LifeTycoonApp());
}

class LifeTycoonApp extends StatelessWidget {
  const LifeTycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeTycoon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
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

  PlayerProfile _player = PlayerProfile(
    id: 'demo-uuid',
    name: 'Tuan Philip',
    cashBalance: 2500.0,
    level: 2,
    intellectStat: 15,
    staminaStat: 20,
    disciplineStat: 18,
    prestigePoints: 5,
    lastActiveTimestampMs: DateTime.now().millisecondsSinceEpoch,
  );

  List<BusinessEntity> _businesses = [
    BusinessEntity(
      id: 'biz-1',
      code: 'coffee_cart',
      name: 'Xe Cà Phê Takeaway',
      category: BusinessCategory.fnb,
      level: 2,
      baseRevenuePerSec: 0.25, // $900/h
      baseCostPerSec: 0.05, // $180/h
      basePurchaseCost: 1000.0,
      unclaimedCash: 450.0,
      lastCalculatedAt: DateTime.now().millisecondsSinceEpoch,
    ),
    BusinessEntity(
      id: 'biz-2',
      code: 'taxi_fleet',
      name: 'Đội Xe Taxi Đô Thị',
      category: BusinessCategory.transport,
      level: 1,
      baseRevenuePerSec: 0.80, // $2880/h
      baseCostPerSec: 0.20,
      basePurchaseCost: 5000.0,
      unclaimedCash: 120.0,
      lastCalculatedAt: DateTime.now().millisecondsSinceEpoch,
    ),
  ];

  void _claimMoney(int index) {
    setState(() {
      final claimed = _businesses[index].unclaimedCash;
      _player = _player.copyWith(cashBalance: _player.cashBalance + claimed);
      _businesses[index] = _businesses[index].copyWith(unclaimedCash: 0.0);
    });
  }

  void _upgradeBusiness(int index) {
    final cost = _businesses[index].upgradeCost;
    if (_player.cashBalance >= cost) {
      setState(() {
        _player = _player.copyWith(cashBalance: _player.cashBalance - cost);
        _businesses[index] = _businesses[index].copyWith(level: _businesses[index].level + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopStatusBar(player: _player),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildActionHubView(),
                  _buildBusinessSimView(),
                  _buildFinanceSimView(),
                  _buildAssetPrestigeView(),
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
  }

  Widget _buildActionHubView() {
    return const Center(child: Text('Action Hub: Pomodoro & E-Reader & Steps'));
  }

  Widget _buildBusinessSimView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _businesses.length,
      itemBuilder: (context, index) {
        return BusinessCardWidget(
          business: _businesses[index],
          onClaim: () => _claimMoney(index),
          onUpgrade: () => _upgradeBusiness(index),
        );
      },
    );
  }

  Widget _buildFinanceSimView() {
    return const Center(child: Text('Finance Sim: Bank & GBM Stock Market'));
  }

  Widget _buildAssetPrestigeView() {
    return const Center(child: Text('Assets & Prestige: Luxury Cars & Real Estate'));
  }
}
