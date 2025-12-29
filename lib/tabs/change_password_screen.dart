// lib/change_password_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    setState(() => _isLoading = true);

    try {
      // 1. احصل على المستخدم الحالي وإيميله
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception("المستخدم غير مسجل دخوله");
      }

      // 2. 🟢 [هذه هي الخطوة الأهم]
      // قم بإنشاء "بيانات اعتماد" باستخدام كلمة المرور القديمة
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text.trim(),
      );

      // 3. 🟢 قم بـ "إعادة المصادقة"
      await user.reauthenticateWithCredential(credential);

      // 4. إذا نجحت (كلمة المرور القديمة صحيحة)، قم بالتحديث
      await user.updatePassword(_newPasswordController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // أغلق الصفحة
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'كلمة المرور القديمة غير صحيحة.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'كلمة المرور الجديدة ضعيفة جداً (يجب أن تكون 6 أحرف على الأقل).';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // (للأخطاء العامة)
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التحديث: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تغيير كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور القديمة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('تحديث كلمة المرور'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}