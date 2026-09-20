import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// Tables definitions
class PlayersTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  RealColumn get cashBalance => real().withDefault(const Constant(500.0))();
  IntColumn get prestigePoints => integer().withDefault(const Constant(0))();
  IntColumn get intellectStat => integer().withDefault(const Constant(10))();
  IntColumn get staminaStat => integer().withDefault(const Constant(10))();
  IntColumn get disciplineStat => integer().withDefault(const Constant(10))();
  IntColumn get energyCurrent => integer().withDefault(const Constant(100))();
  IntColumn get energyMax => integer().withDefault(const Constant(100))();
  IntColumn get goldShares => integer().withDefault(const Constant(0))();
  IntColumn get lastActiveTimestampMs => integer()();
  IntColumn get lastUptimeMs => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

class BusinessesTable extends Table {
  TextColumn get id => text()();
  TextColumn get businessCode => text()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // fnb, transport, technology, realEstate
  IntColumn get level => integer().withDefault(const Constant(1))();
  RealColumn get baseRevenuePerSec => real()();
  RealColumn get baseCostPerSec => real()();
  RealColumn get basePurchaseCost => real()();
  IntColumn get requiredIntellect => integer().withDefault(const Constant(0))();
  IntColumn get requiredStamina => integer().withDefault(const Constant(0))();
  RealColumn get unclaimedCash => real().withDefault(const Constant(0.0))();
  IntColumn get lastCalculatedAt => integer()();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

class BankDepositsTable extends Table {
  TextColumn get id => text()();
  TextColumn get depositType => text()(); // flexible, term_30d
  RealColumn get principalAmount => real()();
  RealColumn get interestRate => real()();
  IntColumn get startedAt => integer()();
  IntColumn get maturesAt => integer().nullable()();
  IntColumn get lastInterestClaim => integer()();
  BoolColumn get isClosed => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MarketStocksTable extends Table {
  TextColumn get symbol => text()();
  TextColumn get companyName => text()();
  RealColumn get currentPrice => real()();
  RealColumn get initialPrice => real()();
  RealColumn get volatility => real()();
  RealColumn get driftRate => real()();
  RealColumn get userOwnedShares => real().withDefault(const Constant(0.0))();
  RealColumn get averageBuyPrice => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {symbol};
}

class ActionLogsTable extends Table {
  TextColumn get id => text()();
  TextColumn get actionType => text()(); // pomodoro, reading, pedometer, task
  IntColumn get durationSeconds => integer()();
  RealColumn get metricValue => real()();
  RealColumn get cashReward => real()();
  TextColumn get statRewardType => text()();
  IntColumn get statRewardValue => integer()();
  BoolColumn get isVerified => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  PlayersTable,
  BusinessesTable,
  BankDepositsTable,
  MarketStocksTable,
  ActionLogsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'lifetycoon_db.sqlite'));
    return NativeDatabase(file);
  });
}
