import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

// State class for the Water Control System
class WaterControlState {
  final UserProfile currentUser;
  final double targetTemperature;
  final double dailyConsumptionLiters;
  final double monthlyConsumptionM3;
  final double estimatedCost;
  final bool isEfficient;
  final List<DailyUsage> weeklyUsage;
  
  // Demo Simulation State
  final bool isShowering;
  final double currentSessionLiters;
  final double currentSessionCost;

  WaterControlState({
    required this.currentUser,
    required this.targetTemperature,
    required this.dailyConsumptionLiters,
    required this.monthlyConsumptionM3,
    required this.estimatedCost,
    required this.isEfficient,
    required this.weeklyUsage,
    this.isShowering = false,
    this.currentSessionLiters = 0.0,
    this.currentSessionCost = 0.0,
  });

  WaterControlState copyWith({
    UserProfile? currentUser,
    double? targetTemperature,
    double? dailyConsumptionLiters,
    double? monthlyConsumptionM3,
    double? estimatedCost,
    bool? isEfficient,
    List<DailyUsage>? weeklyUsage,
    bool? isShowering,
    double? currentSessionLiters,
    double? currentSessionCost,
  }) {
    return WaterControlState(
      currentUser: currentUser ?? this.currentUser,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      dailyConsumptionLiters: dailyConsumptionLiters ?? this.dailyConsumptionLiters,
      monthlyConsumptionM3: monthlyConsumptionM3 ?? this.monthlyConsumptionM3,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      isEfficient: isEfficient ?? this.isEfficient,
      weeklyUsage: weeklyUsage ?? this.weeklyUsage,
      isShowering: isShowering ?? this.isShowering,
      currentSessionLiters: currentSessionLiters ?? this.currentSessionLiters,
      currentSessionCost: currentSessionCost ?? this.currentSessionCost,
    );
  }
}

// Dummy Users
final List<UserProfile> _users = [
  UserProfile(id: '1', name: 'Father', color: Colors.blue, icon: Icons.face),
  UserProfile(id: '2', name: 'Mother', color: Colors.pink, icon: Icons.face_3),
  UserProfile(id: '3', name: 'Child', color: Colors.orange, icon: Icons.child_care),
];

// State Notifier
class WaterControlNotifier extends StateNotifier<WaterControlState> {
  Timer? _showerTimer;
  final double _costPerLiter = 0.025; // Example cost
  final double _litersPerSecond = 0.15; // Approx 9L/min

  WaterControlNotifier()
      : super(WaterControlState(
          currentUser: _users[0],
          targetTemperature: 38.0,
          dailyConsumptionLiters: 45.5,
          monthlyConsumptionM3: 3.2,
          estimatedCost: 15.0,
          isEfficient: true,
          weeklyUsage: _generateMockWeeklyData(1.0),
        ));

  void selectUser(UserProfile user) {
    if (user.id == state.currentUser.id) return;
    
    // Stop any active shower when switching users
    stopShower();

    // Randomize data based on user ID to make it deterministic but distinct
    final random = Random(user.id.hashCode);
    final multiplier = 0.5 + random.nextDouble(); // 0.5x to 1.5x usage

    state = state.copyWith(
      currentUser: user,
      dailyConsumptionLiters: (30 + random.nextDouble() * 50) * multiplier,
      monthlyConsumptionM3: (2 + random.nextDouble() * 3) * multiplier,
      estimatedCost: (50 + random.nextDouble() * 200) * multiplier,
      weeklyUsage: _generateMockWeeklyData(multiplier),
      targetTemperature: 35 + random.nextDouble() * 10, // Different preferred temp
    );
    _checkEfficiency();
  }

  void updateTemperature(double temp) {
    state = state.copyWith(targetTemperature: temp);
    _checkEfficiency();
  }

  void toggleShower() {
    if (state.isShowering) {
      stopShower();
    } else {
      startShower();
    }
  }

  void startShower() {
    if (_showerTimer != null && _showerTimer!.isActive) return;

    state = state.copyWith(
      isShowering: true,
      currentSessionLiters: 0,
      currentSessionCost: 0,
    );

    _showerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newLiters = state.currentSessionLiters + _litersPerSecond;
      final newSessionCost = newLiters * _costPerLiter;

      // Update totals in real-time
      state = state.copyWith(
        currentSessionLiters: newLiters,
        currentSessionCost: newSessionCost,
        dailyConsumptionLiters: state.dailyConsumptionLiters + _litersPerSecond,
        estimatedCost: state.estimatedCost + (_litersPerSecond * _costPerLiter),
      );
    });
  }

  void stopShower() {
    _showerTimer?.cancel();
    _showerTimer = null;
    state = state.copyWith(isShowering: false);
  }

  void _checkEfficiency() {
    // Simple logic: if temp is below 40
    bool efficient = state.targetTemperature < 40;
    state = state.copyWith(isEfficient: efficient);
  }
  
  static List<DailyUsage> _generateMockWeeklyData(double multiplier) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final random = Random();
    return days.map((day) => DailyUsage(day, (20 + random.nextDouble() * 60) * multiplier)).toList();
  }

  @override
  void dispose() {
    _showerTimer?.cancel();
    super.dispose();
  }
}

// Providers
final usersProvider = Provider<List<UserProfile>>((ref) => _users);

final waterControlProvider = StateNotifierProvider<WaterControlNotifier, WaterControlState>((ref) {
  return WaterControlNotifier();
});
