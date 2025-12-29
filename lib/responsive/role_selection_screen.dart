// lib/role_selection_screen.dart
// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/user_login_screen.dart';
import 'responder_login_screen.dart'; // شاشة دخول المسعف فقط

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  // --- دالة النافذة المنبثقة لجهة الاستجابة (مسعف فقط) ---
  void _showResponseUnitPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر جهة الاستجابة',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Choose Response Unit',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // --- زر المسعف فقط ---
              _buildUnitOption(
                context,
                iconPath: 'assets/images/paramedic.png',
                title: 'Paramedic',
                subtitle: 'مسعف',
                color: Colors.red,
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ResponderLoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widget لزر الخيار مع صورة من assets ---
  Widget _buildUnitOption(
    BuildContext context, {
    String? iconPath,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            iconPath != null
                ? Image.asset(iconPath, height: 32, width: 32)
                : const SizedBox(width: 32, height: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget موحد للبطاقات ---
  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? imagePath,
    IconData? icon,
    required Color buttonColor,
    required VoidCallback onButtonTap,
  }) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  imagePath != null
                      ? Image.asset(imagePath, height: 35, color: Colors.black)
                      : (icon != null
                          ? Icon(icon, size: 35, color: Colors.black87)
                          : const SizedBox.shrink()),
            ),
          ),
          const SizedBox(height: 12),
          if (subtitle != null) ...[
            Text(
              title, // الإنجليزي فوق
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle, // العربي تحت
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
          const SizedBox(height: 15),
          GestureDetector(
            onTap: onButtonTap,
            child: Container(
              width: 240,
              height: 45,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "تسجيل الدخول",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color userColor = Color(0xFF1E63FF);
    const Color responderColor = Color(0xFFD90000);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Najdah | نجدة
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100.withOpacity(0.3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset('assets/images/shield.png', height: 40),
                  ),
                ),
                const SizedBox(height: 15),
                // Title Najdah | نجدة
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Najdah",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w900,
                          color: Colors.red.shade700,
                          fontSize: 22,
                        ),
                      ),
                      TextSpan(
                        text: " / ", // الشرطة
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400, // نحيف
                          color: Colors.black, // أسود
                          fontSize: 20, // أصغر شوي
                        ),
                      ),
                      TextSpan(
                        text: "نجدة",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),
                const Text(
                  "Choose Account Type / اختر نوع الحساب",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 680;
                    if (isWide) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: _buildUserCard(context, userColor)),
                          const SizedBox(width: 20),
                          Flexible(
                            child: _buildResponderCard(context, responderColor),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildUserCard(context, userColor),
                          const SizedBox(height: 30),
                          _buildResponderCard(context, responderColor),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- دالة بناء بطاقة المستخدم ---
  Widget _buildUserCard(BuildContext context, Color color) {
    return _buildRoleCard(
      context,
      title: 'User', // الإنجليزي فوق
      subtitle: 'مستخدم', // العربي تحت
      buttonColor: color,
      icon: Icons.person, // نترك الأيقونة كما هي
      onButtonTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserLoginScreen()),
        );
      },
    );
  }

  // --- دالة بناء بطاقة المسعف المعدلة ---
  Widget _buildResponderCard(BuildContext context, Color color) {
    return _buildRoleCard(
      context,
      title: 'Paramedic', // الإنجليزي فوق
      subtitle: 'مسعف', // العربي تحت
      buttonColor: color,
      imagePath: 'assets/images/paramedic.png', // صورة من assets
      onButtonTap: () {
        // ✅ التعديل هنا: الانتقال المباشر بدلاً من إظهار الـ Popup
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResponderLoginScreen()),
        );
      },
    );
  }
} // هذا القوس هو الذي كان مفقوداً في الكود الخاص بك
