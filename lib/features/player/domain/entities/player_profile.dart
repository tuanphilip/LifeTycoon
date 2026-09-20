import 'package:equatable/equatable.dart';

enum SyncStatus { synced, pendingCreate, pendingUpdate, pendingDelete }

class PlayerProfile extends Equatable {
  final String id;
  final String name;
  final int level;
  final double cashBalance;
  final int prestigePoints;
  final int intellectStat;
  final int staminaStat;
  final int disciplineStat;
  final int energyCurrent;
  final int energyMax;
  final int lastActiveTimestampMs;
  final SyncStatus syncStatus;

  const PlayerProfile({
    required this.id,
    required this.name,
    this.level = 1,
    this.cashBalance = 500.0,
    this.prestigePoints = 0,
    this.intellectStat = 10,
    this.staminaStat = 10,
    this.disciplineStat = 10,
    this.energyCurrent = 100,
    this.energyMax = 100,
    required this.lastActiveTimestampMs,
    this.syncStatus = SyncStatus.synced,
  });

  PlayerProfile copyWith({
    String? name,
    int? level,
    double? cashBalance,
    int? prestigePoints,
    int? intellectStat,
    int? staminaStat,
    int? disciplineStat,
    int? energyCurrent,
    int? energyMax,
    int? lastActiveTimestampMs,
    SyncStatus? syncStatus,
  }) {
    return PlayerProfile(
      id: id,
      name: name ?? this.name,
      level: level ?? this.level,
      cashBalance: cashBalance ?? this.cashBalance,
      prestigePoints: prestigePoints ?? this.prestigePoints,
      intellectStat: intellectStat ?? this.intellectStat,
      staminaStat: staminaStat ?? this.staminaStat,
      disciplineStat: disciplineStat ?? this.disciplineStat,
      energyCurrent: energyCurrent ?? this.energyCurrent,
      energyMax: energyMax ?? this.energyMax,
      lastActiveTimestampMs: lastActiveTimestampMs ?? this.lastActiveTimestampMs,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        level,
        cashBalance,
        prestigePoints,
        intellectStat,
        staminaStat,
        disciplineStat,
        energyCurrent,
        energyMax,
        lastActiveTimestampMs,
        syncStatus,
      ];
}
