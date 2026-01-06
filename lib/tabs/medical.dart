// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalHomePage extends StatefulWidget {
  const MedicalHomePage({super.key});

  @override
  State<MedicalHomePage> createState() => _MedicalHomePageState();
}

class _MedicalHomePageState extends State<MedicalHomePage>
    with SingleTickerProviderStateMixin {
  // Firebase
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String get _uid => _auth.currentUser!.uid;

  late TabController _tabController;

  // Controllers
  final fullNameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final allergiesCtrl = TextEditingController();
  final chronicCtrl = TextEditingController();

  final medsCtrl = TextEditingController();
  final surgeryCtrl = TextEditingController();
  final labCtrl = TextEditingController();
  final notesCtrl = TextEditingController(); // **ملاحظات قصيرة للطبيب/المسعف**

  // Data
  String selectedBloodType = 'غير محدد';
  final bloodTypes = ['A+','A-','B+','B-','AB+','AB-','O+','O-','غير محدد'];

  List<String> chronicDiseases = [];
  List<String> medications = [];
  List<String> surgeries = [];
  List<String> labTests = [];
  List<String> notes = [];

  // Share
  bool shareHospitals = false;
  bool shareFamilyDoctor = false;
  bool shareNoOne = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  // ================= Firebase =================

  Future<void> _loadProfile() async {
    final doc = await _firestore.collection('medical_profiles').doc(_uid).get();
    if (!doc.exists) return;

    final d = doc.data()!;
    setState(() {
      fullNameCtrl.text = d['fullName'] ?? '';
      dobCtrl.text = d['dob'] ?? '';
      selectedBloodType = d['bloodType'] ?? 'غير محدد';
      allergiesCtrl.text = d['allergies'] ?? '';

      chronicDiseases = List<String>.from(d['chronicDiseases'] ?? []);
      medications = List<String>.from(d['medications'] ?? []);
      surgeries = List<String>.from(d['surgeries'] ?? []);
      labTests = List<String>.from(d['labTests'] ?? []);
      notes = List<String>.from(d['notes'] ?? []);

      shareHospitals = d['shareHospitals'] ?? false;
      shareFamilyDoctor = d['shareFamilyDoctor'] ?? false;
      shareNoOne = d['shareNoOne'] ?? false;
    });
  }

  Future<void> _saveProfile() async {
    await _firestore.collection('medical_profiles').doc(_uid).set({
      'fullName': fullNameCtrl.text,
      'dob': dobCtrl.text,
      'bloodType': selectedBloodType,
      'allergies': allergiesCtrl.text,
      'chronicDiseases': chronicDiseases,
      'medications': medications,
      'surgeries': surgeries,
      'labTests': labTests,
      'notes': notes,
      'shareHospitals': shareHospitals,
      'shareFamilyDoctor': shareFamilyDoctor,
      'shareNoOne': shareNoOne,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('✅ تم الحفظ بنجاح')));
  }

  // ================= Helpers =================

  int get _age {
    if (dobCtrl.text.isEmpty) return 0;
    final dob = DateTime.parse(dobCtrl.text);
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      dobCtrl.text =
          '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
    }
  }

  InputDecoration dec(String h, IconData i, {bool critical = false}) =>
      InputDecoration(
        hintText: h,
        filled: true,
        fillColor: critical ? const Color(0xFFFFF3F3) : const Color(0xFFF7F7F9),
        prefixIcon: Icon(i, color: critical ? Colors.red : Colors.red[300]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget note(String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(Icons.info, color: Colors.red),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget chipsSection(
    String title,
    TextEditingController ctrl,
    List<String> list,
    String hint,
    IconData icon,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            decoration: dec(hint, icon),
            onSubmitted: (v) {
              if (v.trim().isEmpty) return;
              setState(() {
                list.add(v.trim());
                ctrl.clear();
              });
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: list
                .map((e) => Chip(
                      label: Text(e),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => setState(() => list.remove(e)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
      );

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          icon: const Icon(Icons.emergency),
          label: const Text('بطاقة الطوارئ'),
          onPressed: _showEmergencyCard,
        ),
        appBar: AppBar(
          title: const Text('ملفي الطبي'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'المعلومات الأساسية'),
              Tab(text: 'السجل الطبي'),
              Tab(text: 'المشاركة'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _tabBasic(),
            _tabHistory(),
            _tabShare(),
          ],
        ),
      ),
    );
  }

  // ================= Tabs =================

  Widget _tabBasic() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      note('هذه المعلومات الطبية الأساسية قد تُنقذ حياتك في حالات الطوارئ'),
      const SizedBox(height: 20),

      const Text('الاسم الكامل'),
      TextField(controller: fullNameCtrl, decoration: dec('اسمك', Icons.person)),

      const SizedBox(height: 16),
      const Text('تاريخ الميلاد'),
      GestureDetector(
        onTap: _pickDate,
        child: AbsorbPointer(
          child: TextField(
            controller: dobCtrl,
            decoration: dec('اختر التاريخ', Icons.cake),
          ),
        ),
      ),

      const SizedBox(height: 16),
      const Text('فصيلة الدم'),
      DropdownButtonFormField(
        value: selectedBloodType,
        decoration: dec('', Icons.bloodtype),
        items: bloodTypes
            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
            .toList(),
        onChanged: (v) => setState(() => selectedBloodType = v!),
      ),

      const SizedBox(height: 16),
      const Text('حساسية من أدوية ⚠️'),
      TextField(
        controller: allergiesCtrl,
        decoration: dec('مثال: بنسلين', Icons.warning, critical: true),
      ),

      const SizedBox(height: 16),
      chipsSection(
        'الأمراض المزمنة',
        chronicCtrl,
        chronicDiseases,
        'مثال: سكري، ضغط',
        Icons.medical_services,
      ),

      ElevatedButton(onPressed: _saveProfile, child: const Text('حفظ')),
    ],
  );

  Widget _tabHistory() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      note('معلوماتك الطبية تساعد الطبيب على اتخاذ القرار الصحيح لإكمال علاجك'),
      const SizedBox(height: 20),

      chipsSection('💊 الأدوية الحالية', medsCtrl, medications,
          'مثال: ميتفورمين', Icons.medication),

      chipsSection('🩺 العمليات الجراحية', surgeryCtrl, surgeries,
          'مثال: زراعة كلى، قلب مفتوح', Icons.healing),

      chipsSection('🧪 الفحوصات المخبرية', labCtrl, labTests,
          'مثال: فحص دم شامل', Icons.science),

      chipsSection(
        '📝 ملاحظة قصيرة للطبيب أو المسعف',
        notesCtrl,
        notes,
        'مثال: أخاف من التخدير / تواصل مع أهلي قبل أي إجراء',
        Icons.note,
      ),

      ElevatedButton(onPressed: _saveProfile, child: const Text('حفظ')),
    ],
  );

  Widget _tabShare() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      note('اختر الجهات المسموح لها بالاطلاع على معلوماتك الطبية عند الحاجة'),
      const SizedBox(height: 20),

      CheckboxListTile(
        title: const Text('جميع المستشفيات'),
        value: shareHospitals,
        onChanged: shareNoOne
            ? null
            : (v) => setState(() => shareHospitals = v!),
      ),

      CheckboxListTile(
        title: const Text('طبيب العائلة'),
        value: shareFamilyDoctor,
        onChanged: shareNoOne
            ? null
            : (v) => setState(() => shareFamilyDoctor = v!),
      ),

      CheckboxListTile(
        title: const Text('لا أحد'),
        value: shareNoOne,
        onChanged: (v) => setState(() {
          shareNoOne = v!;
          if (v) {
            shareHospitals = false;
            shareFamilyDoctor = false;
          }
        }),
      ),

      const SizedBox(height: 20),
      ElevatedButton(onPressed: _saveProfile, child: const Text('حفظ')),

      const SizedBox(height: 12),
      const Text(
        'في تطبيق نجدة لا يهدف فقط لإنقاذ الحياة في لحظة الخطر،\n'
        'بل لمساعدة الفريق الطبي على اتخاذ القرار الصحيح بعد النجاة.',
        style: TextStyle(color: Colors.grey),
      ),
    ],
  );

  // ================= Emergency =================

  void _showEmergencyCard() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚨 بطاقة الطوارئ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Text('👤 الاسم: ${fullNameCtrl.text.isEmpty ? 'غير محدد' : fullNameCtrl.text}'),
            const SizedBox(height: 6),

            Text('🎂 العمر: ${_age > 0 ? '$_age سنة' : 'غير محدد'}'),
            const SizedBox(height: 6),

            Text('🩸 فصيلة الدم: $selectedBloodType'),
            const SizedBox(height: 6),

            Text(
              '⚠️ الحساسية: ${allergiesCtrl.text.isEmpty ? 'لا يوجد' : allergiesCtrl.text}',
            ),
            const SizedBox(height: 6),

            Text(
              '🩺 الأمراض المزمنة: ${chronicDiseases.isEmpty ? 'لا يوجد' : chronicDiseases.join('، ')}',
            ),
          ],
        ),
      ),
    );
  }
}
