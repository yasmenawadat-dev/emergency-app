import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsive/paramedic_dashboard_page.dart';

class ParamedicRegisterPage extends StatefulWidget {
  const ParamedicRegisterPage({super.key});

  @override
  State<ParamedicRegisterPage> createState() => _ParamedicRegisterPageState();
}

class _ParamedicRegisterPageState extends State<ParamedicRegisterPage> {
  // متغير للتحكم برؤية كلمة المرور
  bool _isPasswordVisible = false;

  // تعريف اللون الأساسي (استخدام final بدلاً من const لتجنب أخطاء الترجمة)
  final Color red = const Color(0xFFFF2B2B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // زر الرجوع العلوي
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- الأيقونة العلوية ---
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(color: red, shape: BoxShape.circle),
                  child: const Center(
                    child: Icon(
                      Icons.person_add_alt_1,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // --- العناوين ---
                Text(
                  'Paramedic New Account',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'حساب مسعف جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 35),

                // --- حقول الإدخال ---
                _buildRegisterInput(
                  hint: 'الاسم الكامل / Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                _buildRegisterInput(
                  hint: 'البريد الإلكتروني / Email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 15),
                _buildRegisterInput(
                  hint: 'كلمة المرور / Password',
                  icon: Icons.lock_outline,
                  isPass: true,
                ),

                const SizedBox(height: 30),

                // --- زر إنشاء الحساب ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // افتراضياً يذهب للوحة التحكم بعد التسجيل
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParamedicDashboard(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'إنشاء حساب / Sign Up',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- زر العودة (تسجيل الدخول) ---
                TextButton(
                  onPressed: () {
                    // العودة للصفحة السابقة (صفحة تسجيل الدخول أو اختيار الدور)
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Sign In / لديك حساب؟ تسجيل دخول',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ويدجيت موحدة للحقول (الرموز يميناً والعين يساراً)
  Widget _buildRegisterInput({
    required String hint,
    required IconData icon,
    bool isPass = false,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        obscureText: isPass && !_isPasswordVisible,
        textAlign: TextAlign.right, // الكتابة تبدأ من اليمين
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(
            color: Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),

          // رمز العين على اليسار (prefixIcon)
          prefixIcon:
              isPass
                  ? IconButton(
                    onPressed:
                        () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 18,
                      color: Colors.black54,
                    ),
                  )
                  : null,

          // الرموز الأساسية (الاسم، الإيميل، القفل) على اليمين (suffixIcon)
          suffixIcon: Icon(icon, color: Colors.black, size: 20),

          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
