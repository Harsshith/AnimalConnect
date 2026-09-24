import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/pawcare_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

class PawCareApp extends StatelessWidget {
  const PawCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PawCareProvider(),
      child: MaterialApp(
        title: 'AnimalConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
