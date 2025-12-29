import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'responsive/settings_screen.dart';
import 'responsive/role_selection_screen.dart';
import 'user_login_screen.dart';
import 'splash_screen.dart';
import 'providers/settings_provider.dart';
import 'firebase_options.dart';
import 'app_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EmergencyAppWrapper());
}

class EmergencyAppWrapper extends StatelessWidget {
  const EmergencyAppWrapper({super.key});

  Future<FirebaseApp> _initializeFirebase() async {
    if (Firebase.apps.isEmpty) {
      return await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      return Firebase.app();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final settingsProvider = SettingsProvider();
        settingsProvider.startStatsSimulation();

        return ChangeNotifierProvider.value(
          value: settingsProvider,
          child: const EmergencyApp(),
        );
      },
    );
  }
}

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق نجدة',
      theme: settingsProv.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const SplashScreen(),
      routes: {
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/user_login': (context) => const UserLoginScreen(),
        '/settings': (context) => SettingsScreen(),
        // تمرير قيم افتراضية هنا لتجنب الأخطاء
        '/home_tabs': (context) => const AppScaffold(uid: '', isGuest: true),
      },
      builder: (context, widget) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return const Material(
            child: Center(child: Text("جاري تحميل البيانات...")),
          );
        };
        return widget!;
      },
    );
  }
}
