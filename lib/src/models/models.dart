import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  UserProfile({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
}

class DailyUsage {
  final String dayName;
  final double liters;

  DailyUsage(this.dayName, this.liters);
}
