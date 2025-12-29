import 'package:flutter/material.dart';

class FirstAidDetailsPage extends StatelessWidget {
  final String caseKey;

  const FirstAidDetailsPage({
    super.key,
    required this.caseKey,
  });

  Map<String, dynamic> get _data {
    switch (caseKey) {
      case 'headache':
        return {
          'title': 'إسعافات الصداع',
          'image': 'assets/images/headache.png',
          'steps': [
            'الجلوس في مكان هادئ',
            'شرب كمية كافية من الماء',
            'تدليك الرأس والرقبة',
            'الراحة والنوم',
            'مراجعة الطبيب إذا استمر الألم',
          ],
        };

      case 'burn':
        return {
          'title': 'إسعافات الحروق الخفيفة',
          'image': 'assets/images/burn.png',
          'steps': [
            'تبريد مكان الحرق بالماء الفاتر',
            'عدم وضع الثلج مباشرة',
            'تغطية الحرق بضماد نظيف',
            'عدم فقع الفقاعات',
          ],
        };

      case 'wound':
        return {
          'title': 'إسعافات الجروح',
          'image': 'assets/images/cut.png',
          'steps': [
            'غسل اليدين جيدًا',
            'تنظيف الجرح بالماء',
            'تعقيم الجرح',
            'تغطيته بضماد نظيف',
          ],
        };

      default:
        return {
          'title': 'نزلة برد أو احتقان',
          'image': 'assets/images/cold.png',
          'steps': [
            'الراحة',
            'شرب السوائل الدافئة',
            'استخدام بخار الماء',
            'مراجعة الطبيب إذا ساءت الأعراض',
          ],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Directionality(
      textDirection: TextDirection.rtl, // من اليمين لليسار
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: Text(data['title'], style: const TextStyle(color: Colors.white),),
          backgroundColor: Colors.red[600],
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- صورة الحالة ---
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  data['image'],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // --- عنوان الإسعافات باللون الأحمر ونص أبيض ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'الإسعافات الأولية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 12),

              // --- خطوات الإسعافات ---
              ...List.generate(
                data['steps'].length,
                (i) => Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      // ignore: deprecated_member_use
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      data['steps'][i],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right, // من اليمين لليسار
                    ),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
