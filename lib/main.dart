import 'package:assignment/controllers/ble_controllers.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/views/screen/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BleController(),
      child: const BleApp(),
    ),
  );
}

class BleApp extends StatelessWidget {
  const BleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scanner',
      theme: AppTheme.light,
      home: const ScanScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}