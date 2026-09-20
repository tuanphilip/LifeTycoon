import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../../player/domain/entities/player_profile.dart';

class TopStatusBar extends StatelessWidget {
  final PlayerProfile player;

  const TopStatusBar({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Row 1: Name, Cash, Prestige
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'LV.${player.level}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Text(
                currencyFormatter.format(player.cashBalance),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Stats (INT, STA, Discipline)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBadge('🧠 INT', player.intellectStat, AppColors.secondary),
              _buildStatBadge('⚡ STA', player.staminaStat, AppColors.warning),
              _buildStatBadge('🛡️ DIS', player.disciplineStat, AppColors.primaryLight),
              _buildStatBadge('👑 PRE', player.prestigePoints, Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Text('$value', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
