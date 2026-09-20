import 'package:equatable/equatable.dart';

class StockEntity extends Equatable {
  final String symbol;
  final String companyName;
  final double currentPrice;
  final double initialPrice;
  final double driftRate;
  final double volatility;
  final double userOwnedShares;
  final double averageBuyPrice;
  final List<double> history;

  const StockEntity({
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.initialPrice,
    required this.driftRate,
    required this.volatility,
    this.userOwnedShares = 0.0,
    this.averageBuyPrice = 0.0,
    this.history = const [],
  });

  StockEntity copyWith({
    double? currentPrice,
    double? userOwnedShares,
    double? averageBuyPrice,
    List<double>? history,
  }) {
    return StockEntity(
      symbol: symbol,
      companyName: companyName,
      currentPrice: currentPrice ?? this.currentPrice,
      initialPrice: initialPrice,
      driftRate: driftRate,
      volatility: volatility,
      userOwnedShares: userOwnedShares ?? this.userOwnedShares,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        companyName,
        currentPrice,
        initialPrice,
        driftRate,
        volatility,
        userOwnedShares,
        averageBuyPrice,
        history,
      ];
}
