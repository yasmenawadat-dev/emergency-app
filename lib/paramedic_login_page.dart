import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'paramedic_register_page.dart';
import 'responsive/paramedic_dashboard_page.dart';

class ParamedicLoginPage extends StatefulWidget {
  const ParamedicLoginPage({super.key});

  @override
  State<ParamedicLoginPage> createState() => _ParamedicLoginPageState();
}

class _ParamedicLoginPageState extends State<ParamedicLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final Color red = const Color(0xFFFF2B2B);

  // =================== LOGIN FUNCTION ===================
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.isEmpty) {
        throw FirebaseAuthException(
          code: 'empty-fields',
          message: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور',
        );
      }

      

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ParamedicDashboard(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'لا يوجد حساب بهذا البريد الإلكتروني';
            break;
          case 'wrong-password':
            _errorMessage = 'كلمة المرور غير صحيحة';
            break;
          case 'invalid-email':
            _errorMessage = 'البريد الإلكتروني غير صالح';
            break;
          case 'empty-fields':
            _errorMessage = e.message;
            break;
          default:
            _errorMessage = 'حدث خطأ، حاول مرة أخرى';
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =================== UI ===================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // =================== LOGO ===================
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: red,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/paramedic.png',
                      width: 50,
                      height: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // =================== TITLE ===================
                Text(
                  'تسجيل دخول المسعف',
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paramedic Login',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 35),

                // =================== EMAIL ===================
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    icon: Icons.email_outlined,
                    hint: 'البريد الإلكتروني / Email',
                  ),
                ),

                const SizedBox(height: 18),

                // =================== PASSWORD ===================
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration(
                    icon: Icons.lock_outline,
                    hint: 'كلمة المرور / Password',
                  ),
                ),

                const SizedBox(height: 18),

                // =================== ERROR MESSAGE ===================
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),

                const SizedBox(height: 24),

                // =================== LOGIN BUTTON ===================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'تسجيل الدخول / Sign in',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================== REGISTER ===================
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParamedicRegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    'إنشاء حساب جديد / Create account',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  // =================== INPUT DECORATION ===================
  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      hintStyle: GoogleFonts.tajawal(
        color: Colors.grey.shade500,
        fontSize: 15,
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}