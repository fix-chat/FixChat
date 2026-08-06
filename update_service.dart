import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String version;
  final String changelog;
  final String apkUrl;
  UpdateInfo(
      {required this.version, required this.changelog, required this.apkUrl});
}

class UpdateService {
  // ⚠️ এখানে নিজের GitHub username আর repo-র নাম বসাও
  static const String owner = 'YOUR_GITHUB_USERNAME';
  static const String repo = 'fixchat';

  /// GitHub-এর সর্বশেষ Release চেক করে, বর্তমান app version-এর
  /// সাথে তুলনা করে। নতুন ভার্সন থাকলে UpdateInfo রিটার্ন করে, না থাকলে null।
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.github.com/repos/$owner/$repo/releases/latest'),
        headers: {'Accept': 'application/vnd.github+json'},
      );
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final latestTag =
          (data['tag_name'] as String).replaceFirst(RegExp('^v'), '');
      final changelog = (data['body'] as String?)?.trim() ?? '';
      final assets = data['assets'] as List<dynamic>? ?? [];

      final apkAsset = assets.cast<Map<String, dynamic>?>().firstWhere(
            (a) => (a?['name'] as String?)?.endsWith('.apk') ?? false,
            orElse: () => null,
          );
      if (apkAsset == null) return null;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewer(latestTag, currentVersion)) {
        return UpdateInfo(
          version: latestTag,
          changelog: changelog,
          apkUrl: apkAsset['browser_download_url'] as String,
        );
      }
      return null;
    } catch (_) {
      // ইন্টারনেট না থাকলে বা GitHub API-তে সমস্যা হলে চুপচাপ স্কিপ করবে,
      // অ্যাপ ব্লক হবে না।
      return null;
    }
  }

  /// Semantic version তুলনা: "1.2.0" > "1.1.5" ইত্যাদি
  static bool _isNewer(String latest, String current) {
    final l = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final lv = i < l.length ? l[i] : 0;
      final cv = i < c.length ? c[i] : 0;
      if (lv != cv) return lv > cv;
    }
    return false;
  }
}
