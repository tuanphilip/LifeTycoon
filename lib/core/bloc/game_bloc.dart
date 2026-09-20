import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../player/domain/entities/player_profile.dart';
import '../../business_sim/domain/entities/business_entity.dart';
import '../../finance_sim/domain/entities/stock_entity.dart';
import '../../core/utils/gbm_engine.dart';
import '../../core/anti_cheat/anti_cheat_engine.dart';

// --- EVENTS ---
abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameStartedEvent extends GameEvent {}
class GameLoopTickEvent extends GameEvent {}
class ClaimBusinessMoneyEvent extends GameEvent {
  final String businessId;
  const ClaimBusinessMoneyEvent(this.businessId);
  @override
  List<Object?> get props => [businessId];
}
class UpgradeBusinessEvent extends GameEvent {
  final String businessId;
  const UpgradeBusinessEvent(this.businessId);
  @override
  List<Object?> get props => [businessId];
}
class UnlockBusinessEvent extends GameEvent {
  final String businessId;
  const UnlockBusinessEvent(this.businessId);
  @override
  List<Object?> get props => [businessId];
}
class CompletePomodoroEvent extends GameEvent {
  final int minutes;
  const CompletePomodoroEvent(this.minutes);
  @override
  List<Object?> get props => [minutes];
}
class CompleteReadingSessionEvent extends GameEvent {
  final int minutes;
  const CompleteReadingSessionEvent(this.minutes);
  @override
  List<Object?> get props => [minutes];
}
class RecordStepsEvent extends GameEvent {
  final int steps;
  const RecordStepsEvent(this.steps);
  @override
  List<Object?> get props => [steps];
}
class BuyStockEvent extends GameEvent {
  final String symbol;
  final double amount;
  const BuyStockEvent(this.symbol, this.amount);
  @override
  List<Object?> get props => [symbol, amount];
}
class SellStockEvent extends GameEvent {
  final String symbol;
  final double amount;
  const SellStockEvent(this.symbol, this.amount);
  @override
  List<Object?> get props => [symbol, amount];
}
class TriggerIPORebirthEvent extends GameEvent {}

// --- STATE ---
class GameState extends Equatable {
  final PlayerProfile player;
  final List<BusinessEntity> businesses;
  final Map<String, StockEntity> stocks;
  final bool isCheatDetected;

  const GameState({
    required this.player,
    required this.businesses,
    required this.stocks,
    this.isCheatDetected = false,
  });

  GameState copyWith({
    PlayerProfile? player,
    List<BusinessEntity>? businesses,
    Map<String, StockEntity>? stocks,
    bool? isCheatDetected,
  }) {
    return GameState(
      player: player ?? this.player,
      businesses: businesses ?? this.businesses,
      stocks: stocks ?? this.stocks,
      isCheatDetected: isCheatDetected ?? this.isCheatDetected,
    );
  }

  @override
  List<Object?> get props => [player, businesses, stocks, isCheatDetected];
}

// --- BLOC ---
class GameBloc extends Bloc<GameEvent, GameState> {
  final GbmEngine _gbmEngine = GbmEngine();
  Timer? _tickTimer;

  GameBloc()
      : super(GameState(
          player: PlayerProfile(
            id: 'player-1',
            name: 'Philip Tuan',
            level: 1,
            cashBalance: 2500.0,
            intellectStat: 15,
            staminaStat: 20,
            disciplineStat: 18,
            prestigePoints: 5,
            lastActiveTimestampMs: DateTime.now().millisecondsSinceEpoch,
          ),
          businesses: [
            BusinessEntity(
              id: 'biz-1',
              code: 'coffee_cart',
              name: 'Xe Cà Phê Takeaway',
              category: BusinessCategory.fnb,
              level: 2,
              baseRevenuePerSec: 0.25,
              baseCostPerSec: 0.05,
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
              baseRevenuePerSec: 0.80,
              baseCostPerSec: 0.20,
              basePurchaseCost: 5000.0,
              requiredStamina: 15,
              unclaimedCash: 120.0,
              lastCalculatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
            BusinessEntity(
              id: 'biz-3',
              code: 'it_studio',
              name: 'Studio Gia Công Phần Mềm',
              category: BusinessCategory.technology,
              level: 0,
              baseRevenuePerSec: 2.50,
              baseCostPerSec: 0.60,
              basePurchaseCost: 20000.0,
              requiredIntellect: 25,
              unclaimedCash: 0.0,
              lastCalculatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          ],
          stocks: {
            'TECH': StockEntity(symbol: 'TECH', companyName: 'Tập Đoàn Công Nghệ', currentPrice: 152.40, initialPrice: 150.0, driftRate: 0.15, volatility: 0.40, history: [148, 149, 150, 151, 152.4]),
            'FOOD': StockEntity(symbol: 'FOOD', companyName: 'Chuỗi F&B Toàn Cầu', currentPrice: 45.20, initialPrice: 45.0, driftRate: 0.06, volatility: 0.12, history: [44.8, 45.0, 45.1, 45.2]),
            'PROP': StockEntity(symbol: 'PROP', companyName: 'Bất Động Sản Đô Thị', currentPrice: 88.00, initialPrice: 85.0, driftRate: 0.08, volatility: 0.20, history: [86, 87, 86.5, 88.0]),
            'GOLD': StockEntity(symbol: 'GOLD', companyName: 'Quỹ Vàng Dự Trữ', currentPrice: 215.00, initialPrice: 210.0, driftRate: 0.04, volatility: 0.10, history: [212, 213, 214, 215.0]),
          },
        )) {
    on<GameStartedEvent>(_onGameStarted);
    on<GameLoopTickEvent>(_onGameLoopTick);
    on<ClaimBusinessMoneyEvent>(_onClaimBusinessMoney);
    on<UpgradeBusinessEvent>(_onUpgradeBusiness);
    on<UnlockBusinessEvent>(_onUnlockBusiness);
    on<CompletePomodoroEvent>(_onCompletePomodoro);
    on<CompleteReadingSessionEvent>(_onCompleteReadingSession);
    on<RecordStepsEvent>(_onRecordSteps);
    on<BuyStockEvent>(_onBuyStock);
    on<SellStockEvent>(_onSellStock);
    on<TriggerIPORebirthEvent>(_onTriggerIPORebirth);

    add(GameStartedEvent());
  }

  void _onGameStarted(GameStartedEvent event, Emitter<GameState> emit) {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(GameLoopTickEvent());
    });
  }

  void _onGameLoopTick(GameLoopTickEvent event, Emitter<GameState> emit) {
    // 1. Calculate business passive cashflow
    final updatedBusinesses = state.businesses.map((biz) {
      if (biz.level > 0 && !biz.isPaused) {
        final double speedMultiplier = 1.0 + (0.01 * state.player.staminaStat);
        final double netRate = (biz.currentRevenuePerSec * speedMultiplier) - biz.baseCostPerSec;
        return biz.copyWith(unclaimedCash: biz.unclaimedCash + (netRate > 0 ? netRate : 0));
      }
      return biz;
    }).toList();

    // 2. Tick Stock GBM Engine occasionally
    emit(state.copyWith(businesses: updatedBusinesses));
  }

  void _onClaimBusinessMoney(ClaimBusinessMoneyEvent event, Emitter<GameState> emit) {
    final bizIndex = state.businesses.indexWhere((b) => b.id == event.businessId);
    if (bizIndex != -1) {
      final biz = state.businesses[bizIndex];
      final claimed = biz.unclaimedCash;
      if (claimed > 0) {
        final updatedBizList = List<BusinessEntity>.from(state.businesses);
        updatedBizList[bizIndex] = biz.copyWith(unclaimedCash: 0.0);
        emit(state.copyWith(
          player: state.player.copyWith(cashBalance: state.player.cashBalance + claimed),
          businesses: updatedBizList,
        ));
      }
    }
  }

  void _onUpgradeBusiness(UpgradeBusinessEvent event, Emitter<GameState> emit) {
    final bizIndex = state.businesses.indexWhere((b) => b.id == event.businessId);
    if (bizIndex != -1) {
      final biz = state.businesses[bizIndex];
      final cost = biz.upgradeCost;
      if (state.player.cashBalance >= cost) {
        final updatedBizList = List<BusinessEntity>.from(state.businesses);
        updatedBizList[bizIndex] = biz.copyWith(level: biz.level + 1);
        emit(state.copyWith(
          player: state.player.copyWith(cashBalance: state.player.cashBalance - cost),
          businesses: updatedBizList,
        ));
      }
    }
  }

  void _onUnlockBusiness(UnlockBusinessEvent event, Emitter<GameState> emit) {
    final bizIndex = state.businesses.indexWhere((b) => b.id == event.businessId);
    if (bizIndex != -1) {
      final biz = state.businesses[bizIndex];
      if (state.player.cashBalance >= biz.basePurchaseCost &&
          state.player.intellectStat >= biz.requiredIntellect &&
          state.player.staminaStat >= biz.requiredStamina) {
        final updatedBizList = List<BusinessEntity>.from(state.businesses);
        updatedBizList[bizIndex] = biz.copyWith(level: 1);
        emit(state.copyWith(
          player: state.player.copyWith(cashBalance: state.player.cashBalance - biz.basePurchaseCost),
          businesses: updatedBizList,
        ));
      }
    }
  }

  void _onCompletePomodoro(CompletePomodoroEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(
      player: state.player.copyWith(
        cashBalance: state.player.cashBalance + 1000.0,
        disciplineStat: state.player.disciplineStat + 5,
      ),
    ));
  }

  void _onCompleteReadingSession(CompleteReadingSessionEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(
      player: state.player.copyWith(
        cashBalance: state.player.cashBalance + 500.0,
        intellectStat: state.player.intellectStat + 2,
      ),
    ));
  }

  void _onRecordSteps(RecordStepsEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(
      player: state.player.copyWith(
        cashBalance: state.player.cashBalance + 1500.0,
        staminaStat: state.player.staminaStat + 5,
      ),
    ));
  }

  void _onBuyStock(BuyStockEvent event, Emitter<GameState> emit) {
    final stock = state.stocks[event.symbol];
    if (stock != null) {
      final totalCost = stock.currentPrice * event.amount;
      if (state.player.cashBalance >= totalCost) {
        final newOwned = stock.userOwnedShares + event.amount;
        final newAvg = ((stock.averageBuyPrice * stock.userOwnedShares) + totalCost) / newOwned;
        final updatedStocks = Map<String, StockEntity>.from(state.stocks);
        updatedStocks[event.symbol] = stock.copyWith(
          userOwnedShares: newOwned,
          averageBuyPrice: newAvg,
        );
        emit(state.copyWith(
          player: state.player.copyWith(cashBalance: state.player.cashBalance - totalCost),
          stocks: updatedStocks,
        ));
      }
    }
  }

  void _onSellStock(SellStockEvent event, Emitter<GameState> emit) {
    final stock = state.stocks[event.symbol];
    if (stock != null && stock.userOwnedShares >= event.amount) {
      final returnCash = stock.currentPrice * event.amount;
      final newOwned = stock.userOwnedShares - event.amount;
      final updatedStocks = Map<String, StockEntity>.from(state.stocks);
      updatedStocks[event.symbol] = stock.copyWith(
        userOwnedShares: newOwned,
        averageBuyPrice: newOwned == 0 ? 0 : stock.averageBuyPrice,
      );
      emit(state.copyWith(
        player: state.player.copyWith(cashBalance: state.player.cashBalance + returnCash),
        stocks: updatedStocks,
      ));
    }
  }

  void _onTriggerIPORebirthEvent(TriggerIPORebirthEvent event, Emitter<GameState> emit) {
    // IPO logic: Reset businesses, gain Prestige & Gold Shares
    final resetBusinesses = state.businesses.map((b) => b.copyWith(level: 0, unclaimedCash: 0)).toList();
    emit(state.copyWith(
      player: state.player.copyWith(
        cashBalance: 500.0,
        prestigePoints: state.player.prestigePoints + 50,
      ),
      businesses: resetBusinesses,
    ));
  }

  @override
  Future<void> close() {
    _tickTimer?.cancel();
    return super.close();
  }
}
