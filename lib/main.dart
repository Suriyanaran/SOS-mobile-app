import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/user_model.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark navigation bar and status bar for immersive tactical feel
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await ApiService.instance.init();
  UserModel? user;
  if (ApiService.instance.token != null) {
    try {
      user = await ApiService.instance.getMe();
    } catch (_) {
      await ApiService.instance.clearToken();
    }
  }

  runApp(AeroSosApp(initialUser: user));
}

class AeroSosApp extends StatelessWidget {
  final UserModel? initialUser;

  const AeroSosApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    Widget homeScreen;
    if (initialUser != null) {
      if (initialUser!.profileCompleted) {
        homeScreen = HomeScreen(user: initialUser!);
      } else {
        homeScreen = ProfileScreen(user: initialUser!);
      }
    } else {
      homeScreen = const AuthScreen();
    }

    return MaterialApp(
      title: 'AERO-SOS Emergency Dispatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: homeScreen,
    );
  }
}
