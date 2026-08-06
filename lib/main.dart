import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/root_shell.dart';

void main() {
  runApp(const FixChatApp());
}

class FixChatApp extends StatelessWidget {
  const FixChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixChat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      home: const RootShell(),
    );
  }
}
