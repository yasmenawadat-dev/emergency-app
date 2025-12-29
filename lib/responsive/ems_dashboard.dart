// lib/ems_dashboard.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmsDashboard extends StatelessWidget {
  const EmsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMS Dashboard (المسعفون)'),
        backgroundColor: Colors.red.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // 🟢 العودة لشاشة اختيار الدور
              Navigator.of(context).pushReplacementNamed('/role_selection');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 100, color: Colors.red.shade700),
            const Text('Welcome, Paramedic', style: TextStyle(fontSize: 24)),
            const Text('هنا ستظهر بلاغات الإسعاف'),
          ],
        ),
      ),
    );
  }
}