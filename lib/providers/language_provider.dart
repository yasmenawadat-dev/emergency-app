// lib/providers/language_provider.dart

import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // استخدمه لحفظ الإعدادات

class LanguageProvider with ChangeNotifier {
  Locale? _locale; 

  Locale? get locale => _locale;

  LanguageProvider() {
    // 💡 يمكن هنا تحميل اللغة المحفوظة من SharedPreferences عند بدء التشغيل
    // حالياً يتم تعيينها على العربية كافتراضي
    _locale = const Locale('ar'); 
  }

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  // ✅ إضافة toggleLanguage
  void toggleLanguage() {
    if (_locale?.languageCode == 'ar') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('ar'));
    }
  }
}