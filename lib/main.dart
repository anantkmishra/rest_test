import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      title: 'REST TEST',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFF000000,
          {
            50:Color(0x11000000),
            100:Color(0x22000000),
            200:Color(0x33000000),
            300:Color(0x44000000),
            400:Color(0x55000000),
            500:Color(0x66000000),
            600:Color(0x77000000),
            700:Color(0x88000000),
            800:Color(0x99000000),
            900:Color(0xAA000000),
            1000:Color(0xBB000000),
            1100:Color(0xCC000000),
            1200:Color(0xDD000000),
            1300:Color(0xEE000000),
            1400:Color(0xFF000000),
          }
        ),
        primaryColor: const Color(0x99000000),
        primaryColorDark: const Color(0xFF000000)
      ),
      home: Home(),
    );
  }
}
