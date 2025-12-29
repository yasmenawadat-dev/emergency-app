import 'package:flutter/material.dart';
import '../services/medical_profile_service.dart';

class MedicalHomePage extends StatefulWidget {
  const MedicalHomePage({super.key});

  @override
  State<MedicalHomePage> createState() => _MedicalHomePageState();
}

class _MedicalHomePageState extends State<MedicalHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ScrollControllers لكل تبويبة
  final ScrollController _scrollControllerTab1 = ScrollController();
  final ScrollController _scrollControllerTab2 = ScrollController();
  final ScrollController _scrollControllerTab3 = ScrollController();
  final ScrollController _scrollControllerTab4 = ScrollController();

  bool showBackToTopTab1 = false;
  bool showBackToTopTab2 = false;
  bool showBackToTopTab3 = false;
  bool showBackToTopTab4 = false;

  // Controllers للبيانات (Tab 1)
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  String selectedBloodType = 'غير محدد';
  final List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'غير محدد'];

  // حقول إضافية Tab 1
  final TextEditingController allergiesCtrl = TextEditingController();
  final TextEditingController weightCtrl = TextEditingController();
  final TextEditingController heightCtrl = TextEditingController();

  // Tab 2 & 3 Lists
  List<String> chronicDiseases = [];
  List<String> surgeries = [];
  List<String> medicalHistory = [];

  // حقول إضافية Tab 2
  List<String> currentMedications = [];
  final TextEditingController lastCheckupCtrl = TextEditingController();

  // حقول إضافية Tab 3
  List<String> previousIncidents = [];
  final TextEditingController notesForParamedicCtrl = TextEditingController();

  // Tab 4 states (مثل الكود الأصلي)
  bool showHospitals = true;
  bool showMedLab = true;
  bool showFamilyDoctor = true;

  final MedicalProfileService _service = MedicalProfileService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupScrollListener(_scrollControllerTab1, (val) => setState(() => showBackToTopTab1 = val));
    _setupScrollListener(_scrollControllerTab2, (val) => setState(() => showBackToTopTab2 = val));
    _setupScrollListener(_scrollControllerTab3, (val) => setState(() => showBackToTopTab3 = val));
    _setupScrollListener(_scrollControllerTab4, (val) => setState(() => showBackToTopTab4 = val));

    _loadProfile();

    // حفظ تلقائي عند أي تعديل
    fullNameCtrl.addListener(_saveProfile);
    dobCtrl.addListener(_saveProfile);
    allergiesCtrl.addListener(_saveProfile);
    weightCtrl.addListener(_saveProfile);
    heightCtrl.addListener(_saveProfile);
    lastCheckupCtrl.addListener(_saveProfile);
    notesForParamedicCtrl.addListener(_saveProfile);
  }

  void _setupScrollListener(ScrollController controller, Function(bool) update) {
    controller.addListener(() {
      if (controller.offset > 200) {
        update(true);
      } else {
        update(false);
      }
    });
  }

  Future<void> _loadProfile() async {
    final data = await _service.loadProfile();
    if (data != null) {
      setState(() {
        fullNameCtrl.text = data['fullName'] ?? '';
        dobCtrl.text = data['dob'] ?? '';
        selectedBloodType = data['bloodType'] ?? 'غير محدد';
        allergiesCtrl.text = data['allergies'] ?? '';
        weightCtrl.text = data['weight'] ?? '';
        heightCtrl.text = data['height'] ?? '';
        chronicDiseases = List<String>.from(data['chronicDiseases'] ?? []);
        surgeries = List<String>.from(data['surgeries'] ?? []);
        medicalHistory = List<String>.from(data['medicalHistory'] ?? []);
        currentMedications = List<String>.from(data['currentMedications'] ?? []);
        lastCheckupCtrl.text = data['lastCheckup'] ?? '';
        previousIncidents = List<String>.from(data['previousIncidents'] ?? []);
        notesForParamedicCtrl.text = data['notesForParamedic'] ?? '';
        showHospitals = data['showHospitals'] ?? true;
        showMedLab = data['showMedLab'] ?? true;
        showFamilyDoctor = data['showFamilyDoctor'] ?? true;
      });
    }
  }

  Future<void> _saveProfile() async {
    final data = {
      'fullName': fullNameCtrl.text,
      'dob': dobCtrl.text,
      'bloodType': selectedBloodType,
      'allergies': allergiesCtrl.text,
      'weight': weightCtrl.text,
      'height': heightCtrl.text,
      'chronicDiseases': chronicDiseases,
      'surgeries': surgeries,
      'medicalHistory': medicalHistory,
      'currentMedications': currentMedications,
      'lastCheckup': lastCheckupCtrl.text,
      'previousIncidents': previousIncidents,
      'notesForParamedic': notesForParamedicCtrl.text,
      'showHospitals': showHospitals,
      'showMedLab': showMedLab,
      'showFamilyDoctor': showFamilyDoctor,
    };
    await _service.saveProfile(data);
  }

  @override
  void dispose() {
    _saveProfile(); // حفظ تلقائي عند الخروج
    _tabController.dispose();
    fullNameCtrl.dispose();
    dobCtrl.dispose();
    allergiesCtrl.dispose();
    weightCtrl.dispose();
    heightCtrl.dispose();
    lastCheckupCtrl.dispose();
    notesForParamedicCtrl.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF7F7F9),
      prefixIcon: Icon(icon, color: Colors.red[300]),
      contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide.none),
    );
  }

  Widget saveButton(VoidCallback onTap, {String text = 'حفظ المعلومات'}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget buildTab(ScrollController controller, bool showBackToTop, Widget content) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: content,
        ),
        if (showBackToTop)
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => controller.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
              backgroundColor: Colors.red[400],
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildCardList(String title, List<String> items, VoidCallback onAdd, Function(int) onDelete) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              return Column(
                children: [
                  ListTile(
                    title: Text(value),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => onDelete(index),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              );
            }),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blue),
              title: const Text('إضافة', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => dobCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}"); 
    }
  }

  Future<void> _addItemDialog(List<String> list, String title) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('أضف $title'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => list.add(controller.text));
                _saveProfile(); // حفظ تلقائي بعد إضافة أي عنصر
              }
              Navigator.pop(ctx);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.medical_information, color: Colors.red[400]),
              const SizedBox(width: 10),
              Text('الملف الطبي الخاص بي', style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold)),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.red[400],
            labelColor: Colors.red[600],
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'الأساسية'),
              Tab(text: 'معلومات مساعدة'),
              Tab(text: 'السجل الطبي'),
              Tab(text: 'مشاركة البيانات'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1
            buildTab(_scrollControllerTab1, showBackToTopTab1, Column(
              children: [
                TextField(controller: fullNameCtrl, decoration: inputDecoration('الاسم الكامل', Icons.person)),
                const SizedBox(height: 12),
                TextField(
                  controller: dobCtrl,
                  readOnly: true,
                  decoration: inputDecoration('تاريخ الميلاد', Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('فصيلة الدم'),
                  subtitle: Text(selectedBloodType, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () async {
                    final type = await showDialog<String>(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                        title: const Text('اختر فصيلة الدم'),
                        children: bloodTypes.map((b) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, b),
                          child: Text(b),
                        )).toList(),
                      ),
                    );
                    if (type != null) setState(() => selectedBloodType = type);
                    _saveProfile();
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: allergiesCtrl, decoration: inputDecoration('حساسية الأدوية', Icons.warning)),
                TextField(controller: weightCtrl, decoration: inputDecoration('الوزن (كغ)', Icons.monitor_weight)),
                TextField(controller: heightCtrl, decoration: inputDecoration('الطول (سم)', Icons.height)),
                const SizedBox(height: 20),
                saveButton(_saveProfile),
              ],
            )),

            // Tab 2
            buildTab(_scrollControllerTab2, showBackToTopTab2, Column(
              children: [
                _buildCardList('الأمراض المزمنة', chronicDiseases,
                  () => _addItemDialog(chronicDiseases, 'مرض مزمن'),
                  (i) => setState(() => chronicDiseases.removeAt(i))
                ),
                const SizedBox(height: 12),
                _buildCardList('العمليات الجراحية', surgeries,
                  () => _addItemDialog(surgeries, 'عملية جراحية'),
                  (i) => setState(() => surgeries.removeAt(i))
                ),
                const SizedBox(height: 12),
                _buildCardList('الأدوية الحالية', currentMedications,
                  () => _addItemDialog(currentMedications, 'دواء'),
                  (i) => setState(() => currentMedications.removeAt(i))
                ),
                const SizedBox(height: 12),
                TextField(controller: lastCheckupCtrl, decoration: inputDecoration('تاريخ آخر فحص/لقاح', Icons.calendar_today)),
                const SizedBox(height: 20),
                saveButton(_saveProfile),
              ],
            )),

            // Tab 3
            buildTab(_scrollControllerTab3, showBackToTopTab3, Column(
              children: [
                _buildCardList('تفاصيل السجل الطبي', medicalHistory,
                  () => _addItemDialog(medicalHistory, 'سجل طبي'),
                  (i) => setState(() => medicalHistory.removeAt(i))
                ),
                const SizedBox(height: 12),
                _buildCardList('الحوادث السابقة', previousIncidents,
                  () => _addItemDialog(previousIncidents, 'حادث'),
                  (i) => setState(() => previousIncidents.removeAt(i))
                ),
                const SizedBox(height: 12),
                TextField(controller: notesForParamedicCtrl, decoration: inputDecoration('ملاحظات للمسعف', Icons.note)),
                const SizedBox(height: 20),
                saveButton(_saveProfile),
              ],
            )),

            // Tab 4 – مشاركة البيانات
            buildTab(_scrollControllerTab4, showBackToTopTab4, Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اختيار الجهات الطبية لعرض بياناتك:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                CheckboxListTile(
                  title: const Text('جميع مستشفيات المملكة'),
                  value: showHospitals,
                  activeColor: Colors.red,
                  onChanged: (v) { setState(() => showHospitals = v!); _saveProfile(); },
                ),
                CheckboxListTile(
                  title: const Text('مختبرات ميد لابس'),
                  value: showMedLab,
                  activeColor: Colors.red,
                  onChanged: (v) { setState(() => showMedLab = v!); _saveProfile(); },
                ),
                CheckboxListTile(
                  title: const Text('طبيب العائلة الخاص'),
                  value: showFamilyDoctor,
                  activeColor: Colors.red,
                  onChanged: (v) { setState(() => showFamilyDoctor = v!); _saveProfile(); },
                ),
                const SizedBox(height: 30),
                saveButton(_saveProfile, text: 'تحديث صلاحيات العرض'),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
