// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // إضافة مكتبة الفايربيز
import '../settings_page.dart'; 

// نموذج البيانات
class CaseModel {
  final String name;
  final String phone;
  final String location;
  final String description;
  final String time;
  final String level; // حرجة, متوسطة, عادية
  String status; // قيد الانتظار, تم القبول, تم الوصول, مكتمل

  CaseModel({
    required this.name,
    required this.phone,
    required this.location,
    required this.description,
    required this.time,
    required this.level,
    required this.status,
  });
}

class ParamedicDashboard extends StatefulWidget {
  const ParamedicDashboard({super.key});

  @override
  State<ParamedicDashboard> createState() => _ParamedicDashboardState();
}

class _ParamedicDashboardState extends State<ParamedicDashboard>
    with SingleTickerProviderStateMixin {
  bool showMap = true;

  String _selectedLevel = 'جميع المستويات';
  String _selectedStatus = 'جميع الحالات';
  // ignore: unused_field
  String _paramedicName = 'المسعف';

  final List<String> _levelOptions = [
    'جميع المستويات',
    'حرجة',
    'متوسطة',
    'عادية',
  ];
  final List<String> _statusOptions = [
    'جميع الحالات',
    'قيد الانتظار',
    'تم القبول',
    'تم الوصول',
    'مكتمل',
  ];

  final List<CaseModel> _cases = [
    CaseModel(
      name: "أحمد محمد",
      phone: "+962789123456",
      location: "عمان، الأردن",
      description: "ألم شديد في الصدر",
      time: "منذ 37 دقيقة",
      level: "حرجة",
      status: "قيد الانتظار",
    ),
    CaseModel(
      name: "فاطمة علي",
      phone: "+962790765432",
      location: "إربد، الأردن",
      description: "سقوط من مكان مرتفع",
      time: "منذ 42 دقيقة",
      level: "متوسطة",
      status: "قيد الانتظار",
    ),
    CaseModel(
      name: "علي حسن",
      phone: "+962799654321",
      location: "الزرقاء، الأردن",
      description: "حرق خفيف في اليد",
      time: "منذ 10 دقائق",
      level: "عادية",
      status: "تم القبول",
    ),
    CaseModel(
      name: "سارة محمود",
      phone: "+962777123456",
      location: "العقبة، الأردن",
      description: "صعوبة في التنفس",
      time: "منذ ساعة",
      level: "حرجة",
      status: "تم الوصول",
    ),
    CaseModel(
      name: "خالد وليد",
      phone: "+962788765432",
      location: "مأدبا، الأردن",
      description: "حادث سير بسيط",
      time: "اليوم",
      level: "متوسطة",
      status: "مكتمل",
    ),
  ];

  List<CaseModel> _filteredCases = [];

  @override
  void initState() {
    super.initState();
    _filteredCases = List.from(_cases);
    _loadParamedicName();
  }

  Future<void> _loadParamedicName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _paramedicName = prefs.getString('paramedic_name') ?? 'المسعف';
    });
  }

  // الدالة التي طلبت إضافتها (بدون أي تغيير)
  Widget _buildCaseListFromData(List<CaseModel> cases) {
    if (cases.isEmpty) return const Text("لا توجد حالات");

    return Column(
      children: cases.map((caseData) {
        Color cardColor;
        switch (caseData.level) {
          case 'حرجة':
            cardColor = Colors.red;
            break;
          case 'متوسطة':
            cardColor = Colors.orange;
            break;
          default:
            cardColor = Colors.green;
        }
        return _caseCard(
          context: context,
          caseData: caseData,
          color: cardColor,
          onStatusChanged: () {
            setState(() {});
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalCalls = _cases.length;
    final int pendingCalls =
        _cases.where((c) => c.status == 'قيد الانتظار').length;
    final int inProgressCalls =
        _cases
            .where((c) => c.status == 'تم القبول' || c.status == 'تم الوصول')
            .length;
    final int completedToday = _cases.where((c) => c.status == 'مكتمل').length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white, 
        body: SafeArea(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildImprovedHeader(),
                    const SizedBox(height: 20),
                    _buildCard(
                      Icons.call,
                      Colors.blue,
                      "إجمالي الاتصالات",
                      "Total Calls",
                      totalCalls.toString(),
                    ),
                    _buildCard(
                      Icons.access_time,
                      Colors.orange,
                      "قيد الانتظار",
                      "Pending",
                      pendingCalls.toString(),
                    ),
                    _buildCard(
                      Icons.flash_on,
                      Colors.blue,
                      "جاري التعامل",
                      "In Progress",
                      inProgressCalls.toString(),
                    ),
                    _buildCard(
                      Icons.check_circle,
                      Colors.green,
                      "مكتمل اليوم",
                      "Completed Today",
                      completedToday.toString(),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchFilters(),
                    const SizedBox(height: 24),
                    _buildMapListToggleSection(),
                    const SizedBox(height: 16),
                    if (showMap) _buildMapSection(),
                    if (!showMap) 
                      // إضافة الـ StreamBuilder الذي طلبته هنا
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('cases').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                             return const Text("لا توجد حالات حالياً");
                          }

                          final casesFromFirebase = snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return CaseModel(
                              name: data['name'] ?? 'بدون اسم',
                              phone: data['phone'] ?? '',
                              location: "${data['latitude'] ?? 0}, ${data['longitude'] ?? 0}",
                              description: data['description'] ?? '',
                              time: data['time'] ?? '',
                              level: data['level'] ?? 'عادية',
                              status: data['status'] ?? 'قيد الانتظار',
                            );
                          }).toList();

                          return _buildCaseListFromData(casesFromFirebase);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // بقية الـ Widgets من الكود الأصلي بدون تغيير

  // ignore: unused_element
  Widget _buildCaseList() {
    if (_filteredCases.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "لا توجد حالات تطابق معايير البحث.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children:
          _filteredCases.map((caseData) {
            Color cardColor;
            switch (caseData.level) {
              case 'حرجة':
                cardColor = Colors.red;
                break;
              case 'متوسطة':
                cardColor = Colors.orange;
                break;
              default:
                cardColor = Colors.green;
            }
            return _caseCard(
              context: context,
              caseData: caseData,
              color: cardColor,
              onStatusChanged: () {
                setState(() {});
              },
            );
          }).toList(),
    );
  }

  Widget _buildImprovedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.monitor_heart,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Paramedic",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold, 
                fontSize: 18,
                fontFamily: 'Cairo', 
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              "/",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              "مسعف",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo', 
              ),
            ),
          ],
        ),
        Row(
          children: [
            _headerButton('إعدادات', Icons.settings, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              ).then((_) {
                _loadParamedicName();
              });
            }),
            const SizedBox(width: 8),
            _headerButton('خروج', Icons.logout, () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _headerButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: Colors.black),
      label: Text(text, style: const TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildCard(
    IconData icon,
    Color color,
    String arText,
    String enText,
    String number,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                arText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                enText,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "تصفية الحالات",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown("المستوى", _levelOptions, _selectedLevel, (
                String? newValue,
              ) {
                setState(() {
                  _selectedLevel = newValue!;
                });
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown("الحالة", _statusOptions, _selectedStatus, (
                String? newValue,
              ) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              List<CaseModel> results =
                  _cases.where((caseItem) {
                    final bool levelMatch =
                        _selectedLevel == 'جميع المستويات' ||
                        caseItem.level == _selectedLevel;
                    final bool statusMatch =
                        _selectedStatus == 'جميع الحالات' ||
                        caseItem.status == _selectedStatus;
                    return levelMatch && statusMatch;
                  }).toList();
              setState(() {
                _filteredCases = results;
              });
            },
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text(
              "بحث",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> options,
    String selectedValue,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          hint: Text(hint),
          dropdownColor: Colors.white, 
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(color: Colors.black, fontSize: 14),
          onChanged: onChanged,
          items:
              options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, textAlign: TextAlign.right),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildMapListToggleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _buildToggleItem("خريطة", Icons.map, showMap, () {
            setState(() {
              showMap = true;
            });
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildToggleItem("قائمة", Icons.list, !showMap, () {
            setState(() {
              showMap = false;
            });
          }),
        ),
      ],
    );
  }

  Widget _buildToggleItem(
    String text,
    IconData icon,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.black,
        size: 20,
      ),
      label: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red : Colors.grey[200],
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'assets/images/map_background.png',
                fit: BoxFit.cover,
              ),
            ),
            const PulsingDangerIcon(),
            Positioned(
              top: 10,
              left: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "خريطة الحالات الحية",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildLegendRow(
                          "حالات حرجة (${_cases.where((c) => c.level == 'حرجة').length})",
                          Colors.red,
                        ),
                        _buildLegendRow(
                          "حالات متوسطة (${_cases.where((c) => c.level == 'متوسطة').length})",
                          Colors.orange,
                        ),
                        _buildLegendRow(
                          "حالات عادية (${_cases.where((c) => c.level == 'عادية').length})",
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// الـ Widgets المساعدة كما هي

class PulsingDangerIcon extends StatefulWidget {
  const PulsingDangerIcon({super.key});
  @override
  State<PulsingDangerIcon> createState() => _PulsingDangerIconState();
}

class _PulsingDangerIconState extends State<PulsingDangerIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(_opacityAnimation.value),
            ),
            child: const Icon(Icons.warning, color: Colors.red, size: 30),
          ),
        );
      },
    );
  }
}

Widget statusBadges({required String status, required String level}) {
  Color levelColor;
  switch (level) {
    case 'حرجة':
      levelColor = Colors.red;
      break;
    case 'متوسطة':
      levelColor = Colors.orange;
      break;
    default:
      levelColor = Colors.grey;
  }
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          status,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: levelColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          level,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

Widget _caseCard({
  required BuildContext context,
  required CaseModel caseData,
  required Color color,
  required VoidCallback onStatusChanged,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      Widget actionButtons;

      if (caseData.status == "مكتمل") {
        actionButtons = ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size.fromHeight(40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "مكتمل",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ],
          ),
        );
      } else if (caseData.status == "تم الوصول") {
        actionButtons = ElevatedButton.icon(
          onPressed: () {
            setState(() {
              caseData.status = "مكتمل";
            });
            onStatusChanged();
          },
          icon: const Icon(Icons.check, color: Colors.white, size: 16),
          label: const Text(
            "إكمال المهمة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size.fromHeight(40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      } else if (caseData.status == "تم القبول") {
        actionButtons = Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    caseData.status = "تم الوصول";
                  });
                  onStatusChanged();
                },
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 16,
                ),
                label: const Text(
                  "تم الوصول",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final String googleMapsUrl =
                      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(caseData.location)}";
                  final Uri uri = Uri.parse(googleMapsUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.map, color: Colors.black, size: 16),
                label: const Text(
                  "توجيه",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        actionButtons = ElevatedButton.icon(
          onPressed: () {
            setState(() {
              caseData.status = "تم القبول";
            });
            onStatusChanged();
          },
          icon: const Icon(Icons.check, color: Colors.white, size: 16),
          label: const Text(
            "قبول النداء",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size.fromHeight(40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseData.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            caseData.phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                statusBadges(status: caseData.status, level: caseData.level),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.location_on, caseData.location, Colors.red),
            _infoRow(
              Icons.warning_amber_rounded,
              caseData.description,
              Colors.orange,
            ),
            _infoRow(Icons.access_time, caseData.time, Colors.grey),
            const SizedBox(height: 12),
            actionButtons,
          ],
        ),
      );
    },
  );
}

Widget _infoRow(IconData icon, String text, Color iconColor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    ),
  );
}