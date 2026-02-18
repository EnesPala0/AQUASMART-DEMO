import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import 'widgets/weekly_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Statistics', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Consumption', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text('Last 7 Days', style: AppTextStyles.body),
            const SizedBox(height: 40),
            const WeeklyChart(),
            const SizedBox(height: 40),
            // Placeholder for more stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your water usage is 10% lower than last week. Keep it up!',
                      style: AppTextStyles.body.copyWith(color: AppColors.darkBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
