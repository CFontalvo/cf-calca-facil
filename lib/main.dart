import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CfCalcaFacilApp());
}

class CfCalcaFacilApp extends StatelessWidget {
  const CfCalcaFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CF Calca Fácil',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
