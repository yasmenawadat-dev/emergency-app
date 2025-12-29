// lib/widgets/stats_tab.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<SettingsProvider>(
        builder: (context, prov, _) {
          final stats = prov.stats;
          final totalRequests = stats['totalRequests']?.toString() ?? '0';
          final avgResponseSeconds = stats['avgResponseSeconds']?.toString() ?? '0';
          final lastRequestAt = stats['lastRequestAt']?.toString() ?? 'غير محدد';

          double progressValue = totalRequests != '0'
              ? (double.tryParse(totalRequests)! % 100) / 100
              : 0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إحصائيات الاستخدام',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange),
                  ),
                  const SizedBox(height: 20),

                  // --- كروت المعلومات مع حركة ---
                  // --- كروت المعلومات متراصة عمودياً ---
Column(
  children: [
    _animatedCard(
      'إجمالي الطلبات',
      totalRequests,
      Icons.sos,
      Colors.red,
      Colors.redAccent,
    ),
    const SizedBox(height: 12),
    _animatedCard(
      'متوسط وقت الاستجابة',
      '$avgResponseSeconds ثانية',
      Icons.timer,
      Colors.orange,
      Colors.deepOrange,
    ),
    const SizedBox(height: 12),
    _animatedCard(
      'آخر طلب',
      lastRequestAt,
      Icons.schedule,
      Colors.blue,
      Colors.lightBlueAccent,
    ),
  ],
),

                  const SizedBox(height: 30),

                  // --- مؤشر التقدم الدائري ---
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progressValue),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, _) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 12,
                                color: Colors.red,
                                backgroundColor: Colors.red.withOpacity(0.2),
                              );
                            },
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progressValue * 100).toInt()}%',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                            const Text(
                              'نسبة الاستجابة',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Animation wrapper ---
  Widget _animatedCard(
      String title, String value, IconData icon, Color start, Color end) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: _buildGradientCard(title, value, icon, start, end),
        );
      },
    );
  }

  // --- Gradient card design ---
  Widget _buildGradientCard(
      String title, String value, IconData icon, Color start, Color end) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start, end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: end.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
