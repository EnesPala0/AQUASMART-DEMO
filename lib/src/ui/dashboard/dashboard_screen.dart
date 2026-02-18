import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/water_control_provider.dart';
import '../../constants/app_theme.dart';
import '../stats/stats_screen.dart';
import 'widgets/profile_selector.dart';
import 'widgets/temperature_control.dart';
import 'widgets/summary_cards.dart';
import 'widgets/efficiency_alert.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('AquaSmart', style: AppTextStyles.title.copyWith(color: AppColors.primaryBlue)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: AppColors.primaryBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const ProfileSelector(),
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TemperatureControl(),
                    SizedBox(height: 30),
                    _ShowerButton(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const EfficiencyAlert(),
              const SizedBox(height: 20),
              const SummaryCards(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShowerButton extends ConsumerWidget {
  const _ShowerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShowering = ref.watch(waterControlProvider.select((s) => s.isShowering));
    final notifier = ref.read(waterControlProvider.notifier);

    return GestureDetector(
      onTap: notifier.toggleShower,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: isShowering ? Colors.redAccent : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (isShowering ? Colors.redAccent : AppColors.primaryBlue).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isShowering ? Icons.stop_circle_outlined : Icons.play_circle_fill,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              isShowering ? 'STOP SHOWER' : 'START SHOWER',
              style: AppTextStyles.title.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
