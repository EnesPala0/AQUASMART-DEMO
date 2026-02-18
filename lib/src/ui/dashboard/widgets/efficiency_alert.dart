import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/water_control_provider.dart';
import '../../../constants/app_theme.dart';

class EfficiencyAlert extends ConsumerWidget {
  const EfficiencyAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEfficient = ref.watch(waterControlProvider.select((s) => s.isEfficient));

    if (!isEfficient) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.efficiencyGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.efficiencyGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌿', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            'Great job! You are saving water.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.efficiencyGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
