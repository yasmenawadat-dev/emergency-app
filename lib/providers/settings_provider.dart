// lib/providers/settings_provider.dart

// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SettingsProvider extends ChangeNotifier {
  // =========================
  // محرك الصوت (Speech Engine)
  // =========================
  final stt.SpeechToText _speech = stt.SpeechToText();
  // ignore: unused_field
  bool _isListening = false;

  // =========================
  // إعدادات عامة وخصوصية
  // =========================
  bool enableNotifications = true;
  bool isDarkMode = false;
  bool enableMedicalSharing = true; 
  String language = 'ar';

  // =========================
  // ميزات الطوارئ المتقدمة
  // =========================
  bool voiceActivation = false;
  bool autoRecording = false;
  bool familyTracking = false;
  bool _wasHelpSpoken = false; 

  bool get wasHelpSpoken => _wasHelpSpoken;

  void setVoiceActivation(bool val) async { 
    voiceActivation = val; 
    if (voiceActivation) {
      await _initSpeech(); 
    } else {
      _stopListening();
    }
    notifyListeners(); 
  }
  
  void setAutoRecording(bool val) { 
    autoRecording = val; 
    notifyListeners(); 
  }
  
  void setFamilyTracking(bool val) { 
    familyTracking = val; 
    notifyListeners(); 
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' && voiceActivation) _startListening();
        },
        onError: (error) => print('Speech Error: $error'),
      );
      if (available) _startListening();
    } catch (e) {
      print("Speech Initialization Failed: $e");
    }
  }

  void _startListening() {
    if (!voiceActivation) return;
    _isListening = true;
    _speech.listen(
      onResult: (result) {
        String words = result.recognizedWords.toLowerCase();
        if (words.contains('help') || words.contains('نجدة') || words.contains('ساعدوني')) {
          triggerVoiceEmergency();
        }
      },
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _stopListening() {
    _isListening = false;
    _speech.stop();
  }

  void triggerVoiceEmergency() {
    if (voiceActivation) {
      _wasHelpSpoken = true;
      notifyListeners();
    }
  }

  void resetHelpSpoken() {
    _wasHelpSpoken = false;
    notifyListeners();
  }
  
  // =========================
  // بيانات المستخدم الأساسية
  // =========================
  String _photoURL = '';
  String _name = 'اسم المستخدم';
  String? _phone;
  String? _birthDate;
  String _bloodType = 'غير محدد';
  
  Map<String, dynamic> _stats = {
    'lastRequestAt': DateTime.now().toIso8601String(),
  };
  
  Map<String, dynamic>? _currentUser = {
    'email': 'user@example.com',
    'metadata': {'creationTime': '2023-10-01'},
  };

  String get photoURL => _photoURL;
  String get name => _name;
  String? get phone => _phone;
  String? get birthDate => _birthDate;
  String get bloodType => _bloodType;
  Map<String, dynamic> get stats => _stats;
  Map<String, dynamic>? get currentUser => _currentUser;

  // =========================
  // دوال التحكم بالإعدادات
  // =========================
  
  void setMedicalSharing(bool value) {
    enableMedicalSharing = value;
    notifyListeners();
  }

  void setEnableNotifications(bool value) {
    enableNotifications = value;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void toggleLanguage() {
    language = (language == 'ar') ? 'en' : 'ar';
    notifyListeners();
  }

  // =========================
  // إدارة الملف الشخصي والصورة
  // =========================
  
  void updatePhoto(File file) {
    _photoURL = file.path;
    notifyListeners();
  }

  void updateProfile({
    required String newName,
    required String newPhone,
    required String newBirthDate,
    String? newBloodType,
    String? newEmail,
  }) {
    _name = newName;
    _phone = newPhone;
    _birthDate = newBirthDate;
    _bloodType = newBloodType ?? 'غير محدد';
    if (newEmail != null && _currentUser != null) {
      _currentUser!['email'] = newEmail;
    }
    notifyListeners();
  }

  /// دالة لتحديث الاسم والبريد مباشرة (RegisterScreen)
  void setUserInfo({required String name, required String email}) {
    _name = name;
    // ignore: prefer_conditional_assignment
    if (_currentUser == null) _currentUser = {};
    _currentUser!['email'] = email;
    notifyListeners();
  }

  // =========================
  // إدارة جهات الاتصال والمنبهات
  // =========================
  final List<Map<String, String>> _emergencyContacts = [];
  final List<Map<String, String>> _medicalContacts = [];
  List<Map<String, String>> medicineAlarms = [];

  List<Map<String, String>> get emergencyContacts => _emergencyContacts;
  List<Map<String, String>> get medicalContacts => _medicalContacts;

  void addEmergencyContact({required String name, required String phone}) {
    _emergencyContacts.add({'name': name, 'phone': phone});
    notifyListeners();
  }

  void removeEmergencyContact(int index) {
    if (index >= 0 && index < _emergencyContacts.length) {
      _emergencyContacts.removeAt(index);
      notifyListeners();
    }
  }

  void addMedicineAlarm(String name, String time) {
    medicineAlarms.add({'name': name, 'time': time});
    notifyListeners();
  }

  void removeMedicineAlarm(int index) {
    if (index >= 0 && index < medicineAlarms.length) {
      medicineAlarms.removeAt(index);
      notifyListeners();
    }
  }

  // =========================
  // الحساب (خروج وحذف)
  // =========================

  void deleteAccount() {
    signOut(); 
    print("Account Deleted Successfully");
  }

  void signOut() {
    enableNotifications = true;
    enableMedicalSharing = true;
    isDarkMode = false;
    language = 'ar';
    voiceActivation = false;
    _stopListening();
    autoRecording = false;
    familyTracking = false;
    _photoURL = '';
    _name = 'اسم المستخدم';
    _phone = null;
    _birthDate = null;
    _bloodType = 'غير محدد';
    _emergencyContacts.clear();
    _medicalContacts.clear();
    medicineAlarms.clear();
    _stats = {'lastRequestAt': DateTime.now().toIso8601String()};
    _currentUser = null;
    
    notifyListeners();
    print("User signed out");
  }

  // =========================
  // تحديث الإحصائيات تلقائيًا
  // =========================
  void startStatsSimulation() {
    Future.delayed(const Duration(seconds: 5), () {
      _stats['totalRequests'] = (_stats['totalRequests'] ?? 0) + 1;
      _stats['avgResponseSeconds'] = (_stats['avgResponseSeconds'] ?? 0) + 2;
      _stats['lastRequestAt'] = DateTime.now().toIso8601String();
      notifyListeners();
      startStatsSimulation();
    });
  }
}
