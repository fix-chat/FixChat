import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class ApkInstaller {
  /// APK ডাউনলোড করে সিস্টেম ইনস্টলার খুলে দেয়।
  /// শেষ কনফার্মেশন ট্যাপ (Install) ইউজারকেই দিতে হবে — এটা Android-এর
  /// সিকিউরিটি রেস্ট্রিকশন, কোনো অ্যাপ নিজে-নিজে সাইলেন্টলি ইনস্টল করতে পারে না।
  static Future<void> downloadAndInstall(
    String url, {
    required void Function(double progress) onProgress,
  }) async {
    // Android 8+ এ APK ইনস্টল করার জন্য এই পারমিশন লাগবে
    final status = await Permission.requestInstallPackages.request();
    if (!status.isGranted) {
      throw Exception('Install permission দেওয়া হয়নি');
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/fixchat_update.apk';
    final file = File(filePath);

    final request = http.Request('GET', Uri.parse(url));
    final response = await http.Client().send(request);
    final total = response.contentLength ?? 0;
    var received = 0;

    final sink = file.openWrite();
    await response.stream.map((chunk) {
      received += chunk.length;
      if (total > 0) onProgress(received / total);
      sink.add(chunk);
      return chunk;
    }).drain();
    await sink.close();

    await OpenFile.open(filePath);
  }
}
