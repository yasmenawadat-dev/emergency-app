// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../tabs/aidfirst.dart';
import '../widgets/emergency_tab.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String uid;
  final bool isGuest;

  const HomePage({
    required this.uid,
    required this.isGuest,
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // -------------------- المتغيرات --------------------
  bool _sosActive = false;
  int _counter = 5;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  
  // تعريف الـ Detector الخاص بـ shake_plus

  LatLng _currentLatLng = const LatLng(31.9539, 35.9106); // موقع افتراضي (عمان)
  String _currentAddress = "جاري تحديد الموقع الحالي...";
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    
    _pulseController.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (s == AnimationStatus.dismissed && _sosActive) {
        _pulseController.forward();
      }
    });

    _initLocation();
  

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<SettingsProvider>(context, listen: false);
      prov.addListener(() {
        if (prov.voiceActivation && prov.wasHelpSpoken) {
          if (!_sosActive) startSos(immediateSelection: true);
          prov.resetHelpSpoken();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // -------------------- الوظائف --------------------

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _currentAddress = "شارع الجامعة، عمان، الأردن";
      });
      _mapController.move(_currentLatLng, 15.0);
    } catch (e) { debugPrint(e.toString()); }
  }

  

  void startSos({bool immediateSelection = false}) {
    if (_sosActive) return;
    setState(() { _sosActive = true; _counter = 5; });
    _pulseController.forward();
    
    if (!kIsWeb) {
      FlutterRingtonePlayer().play(
        android: AndroidSounds.alarm, 
        ios: IosSounds.alarm, 
        looping: true, 
        asAlarm: true
      );
    }
    
    if (immediateSelection) _showEmergencyOptions();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_counter > 0) {
        setState(() => _counter--);
      } else {
        t.cancel();
        _handleEmergency(level: 'حرجة'); 
      }
    });
  }

  void stopSos() {
    _timer?.cancel();
    if (!kIsWeb) FlutterRingtonePlayer().stop();
    _pulseController.reset();
    setState(() { _sosActive = false; _counter = 5; });
  }

  Future<void> _handleEmergency({required String level}) async {
    stopSos();
    try {
      await FirebaseFirestore.instance.collection('cases').add({
        'uid': widget.uid,
        'level': level,
        'latitude': _currentLatLng.latitude,
        'longitude': _currentLatLng.longitude,
        'description': level == 'حرجة' ? 'SOS Alert - Critical' : 'Normal Alert - Need Guidance',
        'time': DateTime.now().toIso8601String(),
        'status': 'قيد الانتظار',
      });

      if (level == 'حرجة') {
        final Uri telLaunchUri = Uri(scheme: 'tel', path: '911');
        if (await canLaunchUrl(telLaunchUri)) {
          await launchUrl(telLaunchUri);
        }
      }
    } catch (e) {
      debugPrint("خطأ أثناء ارسال البلاغ: $e");
    }
  }

  void _shareLocation() async {
    final String mapUrl = "https://www.google.com/maps/search/?api=1&query=${_currentLatLng.latitude},${_currentLatLng.longitude}";
    await Share.share("🚨 نجدة: هذا موقعي الحالي للطوارئ:\n$mapUrl");
  }

  // -------------------- بناء الواجهة --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('نَجدة', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Center(
              child: GestureDetector(
                onTap: () => _sosActive ? stopSos() : startSos(immediateSelection: true),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (c, child) => Transform.scale(scale: _sosActive ? _pulseAnim.value : 1.0, child: child),
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)],
                      gradient: const RadialGradient(colors: [Color(0xFFFF6B6B), Color(0xFFCF2330)]),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('SOS', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                          Text('اضغط للاستغاثة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

       Column(
  children: [
    _buildCircularBtn(
      Icons.local_police,
      "الشرطة",
      Colors.blue,
      () => launchUrl(Uri.parse('tel:911')),
    ),
    const SizedBox(height: 16),

    _buildCircularBtn(
      Icons.people,
      "العائلة",
      Colors.green,
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text("جهات اتصال الطوارئ"),
                backgroundColor: Colors.red,
                centerTitle: true,
              ),
              body: const EmergencyTab(),
            ),
          ),
        );
      },
    ),
    const SizedBox(height: 16),

    _buildCircularBtn(
      Icons.local_fire_department,
      "الدفاع المدني",
      Colors.orange,
      () => launchUrl(Uri.parse('tel:998')),
    ),
  ],
),


            const SizedBox(height: 30),
            _buildMapSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65, height: 65,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLatLng,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLatLng,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_currentAddress, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _shareLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text("مشاركة موقعي الحالي", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  const Text("حالة طوارئ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                  const Text("اختر نوع الطوارئ", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.red[100]!)),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: Colors.red, radius: 25, child: Text('$_counter', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("التفعيل التلقائي خلال:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text("اختر النوع لإيقاف العداد", style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ]),
                        ),
                        const Icon(Icons.timer_outlined, color: Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildModernOption(icon: Icons.flash_on, title: "حالة حرجة 🚨", subtitle: "اتصال فوري بجهات الطوارئ", color: Colors.red,
                    onTap: () { 
                      Navigator.pop(context); 
                      _handleEmergency(level: 'حرجة'); 
                    }),
                  const SizedBox(height: 12),

                  _buildModernOption(icon: Icons.info_outline, title: "حالة عادية ⚠️", subtitle: "إرسال تنبيه وفتح دليل الإسعافات", color: Colors.orange,
                    onTap: () { 
                      Navigator.pop(context); 
                      _handleEmergency(level: 'عادية'); 
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AidFirstTab())); 
                    }),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildModernOption({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}