import 'dart:math';

/// Geometric Brownian Motion Engine for Stock/Crypto Price Simulation
class GbmEngine {
  final Random _rnd = Random();

  /// Box-Muller transform to generate standard normal distribution N(0, 1)
  double _nextGaussian() {
    double u1 = _rnd.nextDouble();
    double u2 = _rnd.nextDouble();
    while (u1 <= 1e-15) {
      u1 = _rnd.nextDouble();
    }
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }

  /// Calculate next price tick: S_{t+dt} = S_t * exp((mu - 0.5 * sigma^2)*dt + sigma*sqrt(dt)*Z)
  double calculateNextPrice({
    required double currentPrice,
    required double drift, // mu: expected annualized return
    required double volatility, // sigma: annualized volatility
    double dt = 1.0 / 252.0, // dt: time step
  }) {
    final double z = _nextGaussian();
    final double driftTerm = (drift - 0.5 * pow(volatility, 2)) * dt;
    final double shockTerm = volatility * sqrt(dt) * z;
    final double nextPrice = currentPrice * exp(driftTerm + shockTerm);
    return max(0.01, double.parse(nextPrice.toStringAsFixed(2)));
  }
}
