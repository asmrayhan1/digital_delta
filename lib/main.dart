import 'package:digital_delta/core/theme/app_theme.dart';
import 'package:digital_delta/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:digital_delta/core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: 'https://dfxkvmoabzzkxalqgqem.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmeGt2bW9hYnp6a3hhbHFncWVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2MDU4MTksImV4cCI6MjA5MDE4MTgxOX0.jNninBOIiGmciII_NyTFs8WTuIzo3mDQ3BsaEvG3dqU'
  );

  SupabaseService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Delta',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: LoginScreen(),
    );
  }
}
