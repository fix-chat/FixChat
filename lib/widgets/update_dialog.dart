import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/update_service.dart';
import '../services/apk_installer.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo info;
  const UpdateDialog({super.key, required this.info});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  Future<void> _startUpdate() async {
    setState(() {
      _downloading = true;
      _error = null;
    });
    try {
      await ApkInstaller.downloadAndInstall(
        widget.info.apkUrl,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'আপডেট ডাউনলোড করা যায়নি। আবার চেষ্টা করো।');
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_downloading,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.system_update_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text('নতুন আপডেট: v${widget.info.version}')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.info.changelog.isNotEmpty)
                Text(widget.info.changelog, style: const TextStyle(height: 1.4))
              else
                Text('নতুন ফিচার ও ফিক্স এসেছে।',
                    style: TextStyle(color: Colors.grey.shade600)),
              if (_downloading) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                      value: _progress > 0 ? _progress : null, minHeight: 6),
                ),
                const SizedBox(height: 6),
                Text('${(_progress * 100).toInt()}% ডাউনলোড হয়েছে',
                    style: const TextStyle(fontSize: 12)),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
            ],
          ),
        ),
        actions: [
          if (!_downloading)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('পরে'),
            ),
          ElevatedButton(
            onPressed: _downloading ? null : _startUpdate,
            child: Text(_downloading ? 'ডাউনলোড হচ্ছে...' : 'এখনই আপডেট করো'),
          ),
        ],
      ),
    );
  }
}
