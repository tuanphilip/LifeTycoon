import 'dart:math';
import 'package:equatable/equatable.dart';
import '../../player/domain/entities/player_profile.dart';

enum BusinessCategory { fnb, transport, technology, realEstate }

class BusinessEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final BusinessCategory category;
  final int level;
  final double baseRevenuePerSec;
  final double baseCostPerSec;
  final double basePurchaseCost;
  final int requiredIntellect;
  final int requiredStamina;
  final double unclaimedCash;
  final int lastCalculatedAt;
  final bool isPaused;
  final SyncStatus syncStatus;

  const BusinessEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    this.level = 1,
    required this.baseRevenuePerSec,
    required this.baseCostPerSec,
    required this.basePurchaseCost,
    this.requiredIntellect = 0,
    this.requiredStamina = 0,
    this.unclaimedCash = 0.0,
    required this.lastCalculatedAt,
    this.isPaused = false,
    this.syncStatus = SyncStatus.synced,
  });

  /// Upgrade cost calculation: BaseCost * 1.15^(level - 1)
  double get upgradeCost => basePurchaseCost * pow(1.15, level);

  /// Current revenue per sec based on level
  double get currentRevenuePerSec => baseRevenuePerSec * level;

  /// Current net rate
  double get netProfitPerSec => currentRevenuePerSec - baseCostPerSec;

  BusinessEntity copyWith({
    int? level,
    double? unclaimedCash,
    int? lastCalculatedAt,
    bool? isPaused,
    SyncStatus? syncStatus,
  }) {
    return BusinessEntity(
      id: id,
      code: code,
      name: name,
      category: category,
      level: level ?? this.level,
      baseRevenuePerSec: baseRevenuePerSec,
      baseCostPerSec: baseCostPerSec,
      basePurchaseCost: basePurchaseCost,
      requiredIntellect: requiredIntellect,
      requiredStamina: requiredStamina,
      unclaimedCash: unclaimedCash ?? this.unclaimedCash,
      lastCalculatedAt: lastCalculatedAt ?? this.lastCalculatedAt,
      isPaused: isPaused ?? this.isPaused,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        category,
        level,
        baseRevenuePerSec,
        baseCostPerSec,
        basePurchaseCost,
        requiredIntellect,
        requiredStamina,
        unclaimedCash,
        lastCalculatedAt,
        isPaused,
        syncStatus,
      ];
}
