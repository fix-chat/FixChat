import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanItem {
  final String label;
  final IconData icon;
  _ScanStatus status;
  _ScanItem(this.label, this.icon, [this.status = _ScanStatus.pending]);
}

enum _ScanStatus { pending, scanning, ok, warning }

class _ScanScreenState extends State<ScanScreen> {
  bool _scanning = false;
  bool _done = false;

  final List<_ScanItem> _items = [
    _ScanItem('Battery', Icons.battery_full_rounded),
    _ScanItem('Storage', Icons.storage_rounded),
    _ScanItem('RAM', Icons.memory_rounded),
    _ScanItem('Internet', Icons.public_rounded),
    _ScanItem('Wi-Fi', Icons.wifi_rounded),
    _ScanItem('Bluetooth', Icons.bluetooth_rounded),
    _ScanItem('Notifications', Icons.notifications_rounded),
    _ScanItem('Installed Apps', Icons.apps_rounded),
    _ScanItem('Permissions', Icons.privacy_tip_rounded),
    _ScanItem('Android Version', Icons.android_rounded),
    _ScanItem('Security', Icons.security_rounded),
    _ScanItem('Updates', Icons.system_update_rounded),
  ];

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _done = false;
      for (final item in _items) {
        item.status = _ScanStatus.pending;
      }
    });

    // TODO: এখানে real device-info / permission_handler প্যাকেজ দিয়ে
    // actual scan বসবে। এখন simulated।
    for (var i = 0; i < _items.length; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() {
        _items[i].status =
            (i == 1 || i == 7) ? _ScanStatus.warning : _ScanStatus.ok;
      });
    }

    setState(() {
      _scanning = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final warnings =
        _items.where((e) => e.status == _ScanStatus.warning).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Device')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (_done)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: warnings > 0
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        warnings > 0
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        color: warnings > 0
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          warnings > 0
                              ? '$warnings টি সমস্যা পাওয়া গেছে'
                              : 'সব ঠিক আছে ✅',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _row(_items[index]),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _scanning ? null : _startScan,
                  icon: Icon(_scanning
                      ? Icons.hourglass_top_rounded
                      : Icons.radar_rounded),
                  label: Text(_scanning
                      ? 'স্ক্যান হচ্ছে...'
                      : (_done ? 'আবার স্ক্যান করো' : 'স্ক্যান শুরু করো')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(_ScanItem item) {
    Widget trailing;
    switch (item.status) {
      case _ScanStatus.pending:
        trailing = Icon(Icons.circle_outlined,
            color: Colors.grey.shade300, size: 20);
        break;
      case _ScanStatus.scanning:
        trailing = const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        break;
      case _ScanStatus.ok:
        trailing =
            const Icon(Icons.check_circle_rounded, color: AppColors.success);
        break;
      case _ScanStatus.warning:
        trailing = const Icon(Icons.warning_amber_rounded,
            color: AppColors.warning);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          trailing,
        ],
      ),
    );
  }
}
