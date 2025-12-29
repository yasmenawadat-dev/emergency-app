// home_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shake/shake.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ----------------------------------------------------------------
// ## 🚨 الصفحة الرئيسية (Home Page)
// ----------------------------------------------------------------

/// Main Home Page - takes uid and isGuest flag
class HomePage extends StatefulWidget {
  final String uid;
  final bool isGuest;
  const HomePage({required this.uid, required this.isGuest, super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // SOS state
  bool _sosActive = false;
  int _counter = 5;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  Position? _currentPos;
  ShakeDetector? _shakeDetector;
  
  FlutterRingtonePlayer? _player;

  // Contacts
  List<Map<String, String>> _contacts = [];

  // حالة المسعف (Mock Ambulance Tracking)
  bool _isAmbulanceDispatched = false;
  LatLng? _ambulancePos;
  String _eta = "جاري الحساب...";
  Timer? _ambulanceTimer;
  
  // مفتاح خاص بالخريطة لإجبارها على إعادة البناء عند تحديث الموقع
  final Key mapKey = UniqueKey();


  // بيانات المستخدم الوهمية أو الحقيقية
  String get userName {
    if (widget.isGuest) return 'مستخدم زائر';
    return FirebaseAuth.instance.currentUser?.displayName ?? FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'مستخدم';
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
    _pulseController.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (s == AnimationStatus.dismissed && _sosActive) _pulseController.forward();
    });
    _initLocation();
    _initShake();
    _loadContacts();
  }

  // ------------------------- Location Logic -------------------------
  
  Future<void> _initLocation() async {
    final perm = await Permission.location.request();
    if (!perm.isGranted) {
      print('Location permission denied.');
      return;
    }
    
    try {
      // جلب الموقع الأولي مرة واحدة
      _currentPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      // 🛑 إعادة بناء الواجهة لظهور الخريطة فوراً
      setState(() {}); 
    } catch (e) {
      print('Failed to get initial location: $e');
    }

    // الاستماع للتحديثات المستمرة
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5)
    ).listen((p) {
      setState(() => _currentPos = p);
    });
  }

  void _initShake() {
    _shakeDetector = ShakeDetector.autoStart(onPhoneShake: () {
      if (!_sosActive) startSos(immediateSelection: true); 
    });
  }

  // ------------------------- Contacts Logic -------------------------

  Future<void> _loadContacts() async {
    if (widget.isGuest) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('guest_contacts') ?? '[]';
      final list = jsonDecode(raw) as List;
      setState(() => _contacts = list.map((e) => Map<String, String>.from(e)).toList());
    } else {
      final col = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('emergency_contacts');
      final snap = await col.get();
      setState(() => _contacts = snap.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id, 
          'name': (data['name'] as String?) ?? '',
          'phone': (data['phone'] as String?) ?? ''
        };
      }).toList());
      
      col.snapshots().listen((s) {
        setState(() => _contacts = s.docs.map((d) {
          final data = d.data();
          return {
            'id': d.id, 
            'name': (data['name'] as String?) ?? '', 
            'phone': (data['phone'] as String?) ?? ''
          };
        }).toList());
      });
    }
  }

  Future<void> addContact(Map<String, String> contact) async {
    if (widget.isGuest) {
      _contacts.add(contact);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('guest_contacts', jsonEncode(_contacts));
      setState(() {});
    } else {
      final col = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('emergency_contacts');
      await col.add({'name': contact['name'], 'phone': contact['phone']});
    }
  }

  Future<void> removeContact(String idOrPhone) async {
    if (widget.isGuest) {
      _contacts.removeWhere((c) => c['phone'] == idOrPhone);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('guest_contacts', jsonEncode(_contacts));
      setState(() {});
    } else {
      final col = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('emergency_contacts');
      final snap = await col.where('phone', isEqualTo: idOrPhone).get();
      for (var d in snap.docs) {
        await d.reference.delete();
      }
    }
  }
  
  // ------------------------- SOS Activation Logic -------------------------

  void startSos({bool immediateSelection = false}) {
    if (_sosActive) return;
    setState(() {
      _sosActive = true;
      _counter = 5;
    });
    _pulseController.forward();
    
    _player = FlutterRingtonePlayer();
    _player!.play(android: AndroidSounds.alarm, ios: IosSounds.alarm, looping: true, asAlarm: true);

    if (immediateSelection) {
      _showEmergencySelection(canCancel: true);
    }
    
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          _timer?.cancel();
          // نغلق النافذة المنبثقة قبل محاولة فتح واحدة جديدة أو التوجيه
          if (mounted) Navigator.of(context).pop(); 
          _handleEmergencyResponse(critical: true, autoTriggered: true);
        }
      });
    });
  }

  void stopSos() {
    _timer?.cancel();
    _player?.stop();
    _player = null; 
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _sosActive = false;
      _counter = 5;
    });
  }
  
  // ------------------------- Core Response Handler -------------------------

  void _handleEmergencyResponse({required bool critical, bool autoTriggered = false}) {
    stopSos();

    if (critical) {
      // رن دغري وابعت اللوكيشن - حالة حرجة
      launchUrl(Uri.parse('tel:911')); 
      _sendSosToContacts(critical: true);
      _startAmbulanceTracking(critical: true);
    } else {
      // حالة عادية: إرشادات إسعافات أولية ثم تتبع مسعف
      _showFirstAidInstructions();
      _sendSosToContacts(critical: false); 
      // تتبع المسعف يبدأ بعد إغلاق نافذة الإرشادات الآن
    }
  }

  // ------------------------- Ambulance Tracking Mock -------------------------

  void _startAmbulanceTracking({required bool critical}) {
    if (_currentPos == null) return;
    if (_isAmbulanceDispatched) return; 

    _ambulancePos = LatLng(_currentPos!.latitude + 0.005, _currentPos!.longitude - 0.005);
    _isAmbulanceDispatched = true;
    _eta = critical ? "3 دقائق" : "6 دقائق"; 
    setState(() {});

    int secondsRemaining = critical ? 180 : 360; 
    _ambulanceTimer?.cancel();
    _ambulanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      secondsRemaining -= 5;

      if (secondsRemaining <= 0) {
        timer.cancel();
        _eta = "وصل المسعف!";
        _ambulancePos = LatLng(_currentPos!.latitude, _currentPos!.longitude);
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('وصل المسعف إلى موقعك.', textAlign: TextAlign.right),
          backgroundColor: Colors.green,
        ));
        // نوقف التتبع بعد الوصول
        setState(() => _isAmbulanceDispatched = false);

      } else {
        double progress = 1 - (secondsRemaining / (critical ? 180 : 360));
        // محاكاة حركة المسعف نحو موقع المستخدم
        _ambulancePos = LatLng(
          _currentPos!.latitude + 0.005 * (1 - progress), 
          _currentPos!.longitude - 0.005 * (1 - progress), 
        );
        _eta = "${(secondsRemaining / 60).ceil()} دقائق";
      }
      if (mounted) setState(() {});
    });
  }

  // ------------------------- Quick Action Buttons -------------------------

  Future<void> policeAction() async {
    HapticFeedback.mediumImpact(); 
    FlutterRingtonePlayer().play(android: AndroidSounds.notification, ios: IosSounds.glass, looping: false); 
    await launchUrl(Uri.parse('tel:911')); 
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling Police: 911...')));
  }

  Future<void> fireAction() async {
    HapticFeedback.mediumImpact();
    FlutterRingtonePlayer().play(android: AndroidSounds.notification, ios: IosSounds.glass, looping: false); 
    await launchUrl(Uri.parse('tel:911')); 
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling Fire Department: 911...')));
  }

  // ------------------------- SOS Sender -------------------------

  Future<void> _sendSosToContacts({required bool critical}) async {
    final locText = _currentPos != null ? 'https://www.google.com/maps/search/?api=1&query=${_currentPos!.latitude},${_currentPos!.longitude}' : 'Location unknown';
    final typeText = critical ? '🚨 حالة حرجة جداً! خطر على الحياة' : '⚠️ بحاجة مساعدة غير حرجة (إسعافات أولية)';
    final msg = Uri.encodeComponent('$typeText\nموقعي: $locText');

    if (_contacts.isEmpty) {
      final genericSms = Uri.parse('sms:?body=$msg');
      if (await canLaunchUrl(genericSms)) await launchUrl(genericSms, mode: LaunchMode.externalApplication);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No contacts. Opening generic SMS.')));
      return;
    }

    for (var c in _contacts) {
      final phone = c['phone']!.replaceAll('+', ''); // إزالة + من رقم الواتساب
      final wa = Uri.parse('https://wa.me/$phone?text=$msg');
      if (await canLaunchUrl(wa)) {
        await launchUrl(wa, mode: LaunchMode.externalApplication);
      } else {
        final sms = Uri.parse('sms:${c['phone']}?body=$msg');
        await launchUrl(sms, mode: LaunchMode.externalApplication);
      }
    }

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency messages started (WhatsApp/SMS opened).')));
    _showCallingScreen(emergency: critical);
  }

  // ------------------------- UI Modals -------------------------

  void _showEmergencySelection({required bool canCancel}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // نستخدم Timer هنا لتحديث العداد داخل النافذة المنبثقة
            if (_sosActive && canCancel) {
              Timer(const Duration(milliseconds: 100), () {
                if (mounted) setStateDialog(() {});
              });
            }
            
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              contentPadding: const EdgeInsets.all(0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('حالة طوارئ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                        if (canCancel && _counter > 0)
                          TextButton.icon(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            label: Text('إلغاء ($_counter)', style: const TextStyle(color: Colors.red)),
                            onPressed: () {
                              stopSos();
                              Navigator.of(context).pop();
                            },
                          )
                        else if (!canCancel) 
                            const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    child: Column(
                      children: [
                        // زر حالة حرجة (خطر على الحياة)
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            _handleEmergencyResponse(critical: true); 
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.flash_on, color: Colors.white),
                                SizedBox(width: 10),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('حالة حرجة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text('خطر على الحياة - اتصال فوري بجهات الطوارئ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                )),
                                Icon(Icons.warning_amber_rounded, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // زر حالة متوسطة (غير مهددة)
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            _handleEmergencyResponse(critical: false); 
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade700, 
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.phone, color: Colors.white),
                                SizedBox(width: 10),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('حالة متوسطة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text('غير مهددة للحياة - إرسال تنبيهات للعائلة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                )),
                                Icon(Icons.access_time, color: Colors.white),
                              ],
                            ),
                          )),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _showCallingScreen({required bool emergency}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('جاري الاتصال بجهات الطوارئ', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.phone_in_talk, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text('تم إرسال تنبيه عاجل!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red)),
              Text(
                emergency ? 'طوارئ جداً - أولوية عالية' : 'طوارئ - أولوية متوسطة',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))
          ]
        );
      },
    );
  }

  // 🛑 تم التعديل: إظهار إرشادات الإسعافات الأولية المبسّطة
  void _showFirstAidInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('خطوات هامة', textAlign: TextAlign.right),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '⚠️ ابق هادئاً، المسعف قادم في الطريق إليك.', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  'لقد قمنا بإرسال تنبيه بحالة "عادية" إلى جهات الاتصال والمسعف الأقرب. يرجى الانتظار في مكان آمن.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 10),
                Text(
                  'يمكنك التوجه لصفحة "الملف الطبي" في الأسفل للاطلاع على تعليمات إسعاف أولية مفصلة حسب الحالة.',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // البدء بتتبع المسعف فوراً بعد إغلاق النافذة
                _startAmbulanceTracking(critical: false); 
              },
              child: const Text('حسناً، ابدأ تتبع المسعف الآن'),
            ),
          ],
        );
      },
    );
  }

  void openContactsModal() {
      showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) {
      final nameCtl = TextEditingController();
      final phoneCtl = TextEditingController();
      return StatefulBuilder(builder: (context, setStateModal) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SizedBox(
            height: 420,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text('Emergency Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: _contacts.isEmpty
                    ? const Center(child: Text('No contacts yet.'))
                    : ListView.builder(itemCount: _contacts.length, itemBuilder: (c,i){
                        final ct = _contacts[i];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(ct['name'] ?? ''),
                          subtitle: Text(ct['phone'] ?? ''),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(icon: const Icon(Icons.message), onPressed: () async {
                              final locUrl = _currentPos != null ? 'https://www.google.com/maps/search/?api=1&query=${_currentPos!.latitude},${_currentPos!.longitude}' : 'unknown location';
                              final encoded = Uri.encodeComponent('Emergency! Please help. My location: $locUrl');
                              final smsUri = Uri.parse('sms:${ct['phone']}?body=$encoded');
                              if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
                            }),
                            IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                              await removeContact(ct['phone'] ?? ct['id'] ?? '');
                              setStateModal(() {});
                              setState(() {});
                            }),
                          ]),
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(children: [
                    Expanded(child: TextField(controller: nameCtl, decoration: const InputDecoration(hintText: 'Name'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: phoneCtl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone (+962...)'))),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ElevatedButton.icon(onPressed: () async {
                    final nm = nameCtl.text.trim();
                    final ph = phoneCtl.text.trim();
                    if (nm.isEmpty || ph.isEmpty) return;
                    await addContact({'name': nm, 'phone': ph});
                    nameCtl.clear();
                    phoneCtl.clear();
                    setStateModal(() {});
                    setState(() {}); 
                  }, icon: const Icon(Icons.add), label: const Text('Add Contact')),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ambulanceTimer?.cancel(); 
    _pulseController.dispose();
    _shakeDetector?.stopListening();
    _player?.stop(); 
    super.dispose();
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'أهلاً بك، $userName!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              if (!widget.isGuest)
                IconButton(
                  onPressed: () async { 
                    await FirebaseAuth.instance.signOut(); 
                  }, 
                  icon: const Icon(Icons.logout, color: Colors.red),
                  tooltip: 'تسجيل الخروج',
                ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'شعارنا: سلامتكم أولويتنا.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🛑 دالة الزر الدائري (Circular Service Button)
  Widget _circularServiceBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column( // نستخدم Column لوضع الأيقونة والنص تحتها
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70, // حجم الدائرة
            height: 70, // حجم الدائرة
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 35), // الأيقونة
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)), // النص تحت الأيقونة
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sosSize = 170.0; 
    
    // تجهيز Markers للخريطة
    List<Marker> mapMarkers = [
      if (_currentPos != null)
        Marker(
            point: LatLng(_currentPos!.latitude, _currentPos!.longitude), 
            width: 80, 
            height: 80, 
            child: const Icon(Icons.location_on, size: 36, color: Colors.red)
        ),
      // إضافة علامة المسعف إذا تم تفعيل التتبع
      if (_ambulancePos != null)
        Marker(
            point: _ambulancePos!, 
            width: 80, 
            height: 80, 
            child: Icon(Icons.airport_shuttle, size: 36, color: _eta == "وصل المسعف!" ? Colors.green : Colors.blue),
        ),
    ];
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تطبيق الطوارئ - NAJDAH'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        automaticallyImplyLeading: false,
        actions: [ ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'الطوارئ'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'ملف طبي'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'استفسارات'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
        currentIndex: 0,
        onTap: (index) {
          // يمكن إضافة منطق الانتقال بين الصفحات هنا
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // 🛑 العمود الرئيسي
          return Column(
            children: [
              // الجزء العلوي الذي لا يحتاج للتمرير
              _buildHeader(),
              
              const SizedBox(height: 10),
              const Text('Emergency', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 20),

              // زر SOS
              GestureDetector(
                onTap: () { if (!_sosActive) {
                  startSos(immediateSelection: true);
                } else {
                  stopSos();
                } },
                child: AnimatedBuilder(
                  animation: _pulseController,
                  child: Container(
                    width: sosSize,
                    height: sosSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(colors: [Color(0xFFFF6B6B), Color(0xFFCF2330)], focal: Alignment.center),
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.35), blurRadius: _sosActive ? 40 : 20, spreadRadius: _sosActive ? 12 : 6)],
                    ),
                    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('SOS', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(_sosActive ? '$_counter' : 'Tap to activate', style: const TextStyle(color: Colors.white70)),
                    ])),
                  ),
                  builder: (ctx, child) {
                    final scale = _sosActive ? _pulseAnim.value : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                ),
              ),

              const SizedBox(height: 40),

              // 🛑 الأزرار الدائرية تحت بعضها (تم التعديل هنا)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column( // 🛠️ تم التعديل إلى Column
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circularServiceBtn(Icons.local_police, 'Police', Colors.blue.shade400, (){ policeAction(); }),
                    const SizedBox(height: 20),
                    _circularServiceBtn(Icons.family_restroom, 'Family', Colors.green.shade400, (){ openContactsModal(); }),
                    const SizedBox(height: 20),
                    _circularServiceBtn(Icons.local_fire_department, 'Fire', Colors.orange.shade400, (){ fireAction(); }),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // عرض حالة المسعف
              if (_isAmbulanceDispatched)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.alarm_on, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text('المسعف قادم! وقت الوصول المتوقع: $_eta', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ),
                ),

              // 🛑 الخريطة تأخذ باقي المساحة (Expanded)
              Expanded(child: Container(
                width: constraints.maxWidth * 0.9, 
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _currentPos == null 
                    ? const Center(child: Text('جاري تحديد الموقع...'))
                    : FlutterMap(
                      options: MapOptions(
                          initialCenter: LatLng(_currentPos!.latitude, _currentPos!.longitude), 
                          initialZoom: 15.0,
                          interactionOptions: InteractionOptions(
                              flags: _isAmbulanceDispatched ? InteractiveFlag.none : InteractiveFlag.all
                          ),
                      ),
                      children: [
                        TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a','b','c']),
                        MarkerLayer(markers: mapMarkers),
                        if (_isAmbulanceDispatched && _ambulancePos != null && _currentPos != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [LatLng(_currentPos!.latitude, _currentPos!.longitude), _ambulancePos!],
                                color: Colors.blue,
                                strokeWidth: 4.0,
                              ),
                            ],
                          ),
                      ],
                    ),
                ),
              )),
              
              // عرض الموقع الحالي كنص في الأسفل
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _currentPos != null 
                    ? 'موقعي: Lat: ${_currentPos!.latitude.toStringAsFixed(4)}, Lng: ${_currentPos!.longitude.toStringAsFixed(4)}'
                    : 'جاري تحديد الموقع...',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}