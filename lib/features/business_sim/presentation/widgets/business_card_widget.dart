import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../../domain/entities/business_entity.dart';

class BusinessCardWidget extends StatelessWidget {
  final BusinessEntity business;
  final VoidCallback onClaim;
  final VoidCallback onUpgrade;

  const BusinessCardWidget({
    super.key,
    required this.business,
    required this.onClaim,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  business.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Level ${business.level}', style: const TextStyle(fontSize: 12, color: AppColors.warning)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Doanh thu: +${currencyFormatter.format(business.currentRevenuePerSec * 3600)}/h',
                  style: const TextStyle(color: AppColors.primary, fontSize: 13),
                ),
                Text(
                  'Phí bảo trì: -${currencyFormatter.format(business.baseCostPerSec * 3600)}/h',
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: onUpgrade,
                    child: Text('Nâng cấp (${currencyFormatter.format(business.upgradeCost)})'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: business.unclaimedCash > 0 ? onClaim : null,
                    child: Text('Nhận ${currencyFormatter.format(business.unclaimedCash)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
