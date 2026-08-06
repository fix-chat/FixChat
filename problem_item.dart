import 'package:flutter/material.dart';

class ProblemItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final DateTime? timestamp;

  const ProblemItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.timestamp,
  });
}

/// Dummy data - পরে real AI/backend দিয়ে replace হবে
class DummyData {
  static final List<ProblemItem> recentProblems = [
    ProblemItem(
      title: 'Wi-Fi কানেক্ট হচ্ছে না',
      subtitle: 'সমাধান হয়েছে · ২ ঘণ্টা আগে',
      icon: Icons.wifi_off_rounded,
      color: const Color(0xFF2563EB),
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ProblemItem(
      title: 'ফোন স্লো হয়ে গেছে',
      subtitle: 'সমাধান হয়েছে · গতকাল',
      icon: Icons.speed_rounded,
      color: const Color(0xFFF59E0B),
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final List<ProblemItem> popularFixes = [
    ProblemItem(
      title: 'Storage খালি করা',
      subtitle: 'Cache clear + junk files',
      icon: Icons.storage_rounded,
      color: const Color(0xFF22C55E),
    ),
    ProblemItem(
      title: 'Battery Drain সমাধান',
      subtitle: 'Background apps চেক',
      icon: Icons.battery_alert_rounded,
      color: const Color(0xFFEF4444),
    ),
    ProblemItem(
      title: 'Notification সমস্যা',
      subtitle: 'Permission ঠিক করা',
      icon: Icons.notifications_off_rounded,
      color: const Color(0xFF7C3AED),
    ),
    ProblemItem(
      title: 'Bluetooth কানেক্ট হচ্ছে না',
      subtitle: 'Pairing রিসেট',
      icon: Icons.bluetooth_disabled_rounded,
      color: const Color(0xFF06B6D4),
    ),
  ];
}
