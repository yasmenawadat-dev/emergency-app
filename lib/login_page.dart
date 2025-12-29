// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:my_app/app_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // جلب FCM Token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print("Device FCM Token: $fcmToken");

      // حفظ البريد إذا تم تفعيل Remember Me
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('saved_email', _emailController.text.trim());
      }

      if (mounted && credential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AppScaffold(uid: credential.user!.uid, isGuest: false),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "حدث خطأ غير متوقع 😅";
      switch (e.code) {
        case 'user-not-found':
          message = "المستخدم غير موجود. يرجى التسجيل أولاً.";
          break;
        case 'wrong-password':
          message = "كلمة المرور غير صحيحة.";
          break;
        case 'invalid-email':
          message = "البريد الإلكتروني غير صالح.";
          break;
        case 'too-many-requests':
          message = "تم حظر الحساب مؤقتاً بسبب محاولات متكررة فاشلة. حاول لاحقاً.";
          break;
        default:
          message = "خطأ المصادقة: ${e.code}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, textAlign: TextAlign.right)),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('guest_contacts')) {
      prefs.setString('guest_contacts', jsonEncode([]));
    }

    Navigator.pushReplacement(
      // ignore: duplicate_ignore
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => AppScaffold(uid: 'guest', isGuest: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Welcome Back",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sign in to access your emergency profile",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                labelText: "Email Address",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    ),
                    const Text("Remember me"),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_outline, color: Colors.black54),
                label: const Text("Continue as Guest"),
                onPressed: _continueAsGuest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
