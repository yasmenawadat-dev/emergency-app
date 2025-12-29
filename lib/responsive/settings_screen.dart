//lib\responsive\settings_screen.dart
import 'package:flutter/material.dart';
import '../widgets/profile_tab.dart';
import '../widgets/emergency_tab.dart';
import '../widgets/stats_tab.dart';


  @override
  class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0, // الآن أول تاب هو الملف الشخصي
      child: Scaffold(
        appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 1,
  automaticallyImplyLeading: false, // ✅ هذا يشيل زر العودة
  title: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const Icon(Icons.settings, color: Colors.red),
      const SizedBox(width: 8),
      Text(
        'الإعدادات',
        style: TextStyle(
          color: Colors.red[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  centerTitle: true,
  bottom: TabBar(
    labelColor: Colors.red[600],
    unselectedLabelColor: Colors.grey,
    indicatorColor: Colors.red[600],
    tabs: const [
      Tab(icon: Icon(Icons.person), text: 'الملف الشخصي'),
      Tab(icon: Icon(Icons.emergency), text: 'الطوارئ'),
      Tab(icon: Icon(Icons.bar_chart), text: 'الإحصائيات'),
    ],
  ),
),

        body: const TabBarView(
          children: [
            ProfileTab(),     // أول تاب → الملف الشخصي
            EmergencyTab(),   // ثاني تاب → الطوارئ
            StatsTab(),       // ثالث تاب → الإحصائيات
          ],
        ),
      ),
    );
  }
}


class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;

  const CustomScaffold({
    super.key,
    required this.body,
    this.title,
    this.bottomNavigationBar,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(title: Text(title!), centerTitle: true, actions: actions)
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
