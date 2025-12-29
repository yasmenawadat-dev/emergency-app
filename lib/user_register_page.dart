// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final Color blue = const Color(0xFF1E63FF);

  Future<void> _performRegistration() async {
    setState(() => _isLoading = true);

    try {
      // 🔐 إنشاء حساب
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // 🔥 تخزين البيانات في Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': _emailController.text.trim(),
        'createdAt': Timestamp.now(),
        'role': 'user',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = 'فشل إنشاء الحساب';

      if (e.code == 'weak-password') {
        msg = 'كلمة المرور ضعيفة';
      } else if (e.code == 'email-already-in-use') {
        msg = 'الإيميل مستخدم مسبقًا';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // 🔵 أيقونة
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_add, color: blue, size: 45),
                ),

                const SizedBox(height: 25),

                // 📝 العناوين
                Text(
                  'Create Account',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'إنشاء حساب جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 35),

                // 📧 Email
                _buildTextField(
                  _emailController,
                  Icons.email_outlined,
                  'البريد الإلكتروني / Email',
                ),

                const SizedBox(height: 15),

                // 🔒 Password
                _buildTextField(
                  _passwordController,
                  Icons.lock_outline,
                  'كلمة المرور / Password',
                  isPass: true,
                  isVisible: _isPasswordVisible,
                  toggle: () => setState(
                    () => _isPasswordVisible = !_isPasswordVisible,
                  ),
                ),

                const SizedBox(height: 30),

                // 🔘 زر التسجيل
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _performRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'تسجيل حساب / Sign Up',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hintText, {
    bool isPass = false,
    bool isVisible = false,
    VoidCallback? toggle,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: isPass && !isVisible,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(fontSize: 13),
          prefixIcon: isPass
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    size: 18,
                  ),
                  onPressed: toggle,
                )
              : null,
          suffixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
