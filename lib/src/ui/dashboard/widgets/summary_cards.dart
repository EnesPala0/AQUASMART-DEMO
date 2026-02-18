import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/water_control_provider.dart';
import '../../../constants/app_theme.dart';

class SummaryCards extends ConsumerWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waterControlProvider);

    // If showering, show session stats!
    if (state.isShowering) {
       return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCard('Session (L)', state.currentSessionLiters.toStringAsFixed(1), Icons.shower, highlight: true),
          _buildCard('Cost (₺)', state.currentSessionCost.toStringAsFixed(2), Icons.monetization_on, highlight: true),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCard('Daily (L)', '${state.dailyConsumptionLiters.toStringAsFixed(1)} L', Icons.water_drop),
        _buildCard('Monthly (m³)', '${state.monthlyConsumptionM3.toStringAsFixed(2)} m³', Icons.calendar_today),
        _buildCard('Cost', '₺${state.estimatedCost.toStringAsFixed(2)}', Icons.monetization_on),
      ],
    );
  }

  Widget _buildCard(String label, String value, IconData icon, {bool highlight = false}) {
    return Card(
      elevation: highlight ? 8 : 4,
      shadowColor: highlight ? AppColors.accentCyan.withOpacity(0.4) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: highlight ? 140 : 100, // Wider for session stats
        decoration: highlight ? BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentCyan, width: 2),
        ) : null,
        child: Column(
          children: [
            Icon(icon, color: highlight ? AppColors.accentCyan : AppColors.primaryBlue, size: highlight ? 32 : 28),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.cardValue.copyWith(
              fontSize: highlight ? 24 : 16,
              color: highlight ? AppColors.accentCyan : AppColors.primaryBlue,
            )),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.cardLabel),
          ],
        ),
      ),
    );
  }
}
