import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../../providers/water_control_provider.dart';
import '../../../constants/app_theme.dart';

class TemperatureControl extends ConsumerWidget {
  const TemperatureControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetTemp = ref.watch(waterControlProvider).targetTemperature;

    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
        size: 280, // Slightly larger
        startAngle: 150,
        angleRange: 240, // Wider arc
        customWidths: CustomSliderWidths(
          progressBarWidth: 25,
          trackWidth: 25,
          handlerSize: 18,
          shadowWidth: 40,
        ),
        customColors: CustomSliderColors(
          trackColor: AppColors.lightBlue.withOpacity(0.5),
          progressBarColors: [
            AppColors.primaryBlue,
            AppColors.accentCyan,
            Colors.blueAccent,
          ],
          gradientStartAngle: 0,
          gradientEndAngle: 180,
          dotColor: Colors.white,
          shadowColor: AppColors.primaryBlue.withOpacity(0.2),
          shadowMaxOpacity: 0.1,
        ),
        infoProperties: InfoProperties(
          modifier: (double value) {
            return '${value.toInt()}°C';
          },
          mainLabelStyle: AppTextStyles.temperature.copyWith(
            fontSize: 60,
            shadows: [
              Shadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          bottomLabelText: 'Temperature',
          bottomLabelStyle: AppTextStyles.body.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      min: 20,
      max: 60,
      initialValue: targetTemp,
      onChange: (double value) {
        ref.read(waterControlProvider.notifier).updateTemperature(value);
      },
    );
  }
}
