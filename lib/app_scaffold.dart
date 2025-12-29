import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/tabs/aidfirst.dart';
import 'tabs/home_page.dart';
import 'tabs/medical.dart'; 
import 'responsive/settings_screen.dart';

class AppScaffold extends StatefulWidget {
  final String uid;       // إضافة uid
  final bool isGuest;     // إضافة isGuest

  const AppScaffold({
    super.key,
    required this.uid,
    required this.isGuest,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام المتغيرات المخزنة في widget
    final List<Widget> pages = [
      HomePage(
        uid: widget.uid,
        isGuest: widget.isGuest,
      ),
      const AidFirstTab(),
      const MedicalHomePage(),
      SettingsScreen(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: pages,
        ),
        bottomNavigationBar: Material(
          color: Colors.red[700],
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(icon: Icon(Icons.home), text: 'الرئيسية'),
              Tab(icon: Icon(Icons.medical_services), text: 'إسعافات'),
              Tab(icon: Icon(Icons.folder_shared), text: 'ملف طبي'),
              Tab(icon: Icon(Icons.settings), text: 'الإعدادات'),
            ],
          ),
        ),
      ),
    );
  }
}
