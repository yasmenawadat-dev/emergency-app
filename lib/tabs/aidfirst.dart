// lib/tabs/aidfarst.dart

import 'package:flutter/material.dart';
import 'package:my_app/ai_assistant_page.dart';
import 'package:my_app/first_aid_details_page.dart';

class AidFirstTab extends StatelessWidget {
  const AidFirstTab({super.key});

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                const SizedBox(height: 10),
                _firstAidSection(context),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _caseCard(context, 'صداع', 'صداع عادي أو نصفي',
                      Icons.ac_unit, 'headache'),
                  _caseCard(context, 'حرق خفيف',
                      'حروق بسيطة من الطبخ أو الشمس',
                      Icons.local_fire_department, 'burn'),
                  _caseCard(context, 'خدوش وجروح بسيطة',
                      'جروح وخدوش صغيرة', Icons.cut, 'wound'),
                  _caseCard(context, 'نزلة برد أو احتقان',
                      'نزلات برد واحتقان أنف', Icons.air, 'cold'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FIRST AID HEADER =================
Widget _firstAidHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.rtl, // لضبط الاتجاه للعربية
          children: const [
            Icon(
              Icons.medical_services, // أيقونة مناسبة للإسعافات
              color: Colors.red,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              'الإسعافات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'اختر حالة شائعة أو استخدم المساعد الذكي للحصول على نصائح فورية',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}


// ================= FIRST AID SECTION =================
Widget _firstAidSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        _firstAidHeader(context), // الهيدر الجديد بالمنتصف
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AiAssistantPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.smart_toy, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'المساعد الذكي (AI)',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Spacer(),
                Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}



  // ================= CASE CARD =================
  Widget _caseCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String caseKey,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FirstAidDetailsPage(caseKey: caseKey),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 227, 83, 72),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('اضغط للمساعدة',style: TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),),
          ),
        ],
      ),
    );
  }
}
