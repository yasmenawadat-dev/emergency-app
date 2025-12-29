// lib/widgets/profile_tab.dart

// ignore_for_file: deprecated_member_use, unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/settings_provider.dart';

const List<String> _bloodTypes = [
  'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'غير محدد'
];

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<SettingsProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl, // واجهة RTL
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('معلومات الملف الشخصي', prov),
            ProfileInformationSection(prov: prov),
            const SizedBox(height: 25),
            _buildSectionTitle('الخصوصية والأمان', prov),
            PrivacySecuritySection(prov: prov),
            const SizedBox(height: 25),
            _buildSectionTitle('الإعدادات العامة', prov),
            GeneralSettingsSection(prov: prov),
            const SizedBox(height: 30),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  prov.signOut();
                  Navigator.pushReplacementNamed(context, '/user_login');
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, SettingsProvider prov) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, right: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }
}

// ------------------- قسم معلومات الملف الشخصي -------------------
class ProfileInformationSection extends StatelessWidget {
  final SettingsProvider prov;
  const ProfileInformationSection({super.key, required this.prov});

  @override
  Widget build(BuildContext context) {
    final isDark = prov.isDarkMode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            _buildInfoTile(Icons.person_outline, "الاسم الكامل", prov.name, isDark),
            _buildInfoTile(Icons.email_outlined, "البريد الإلكتروني",
                prov.currentUser?['email'] ?? 'لا يوجد بريد', isDark),
            _buildInfoTile(Icons.phone_android_outlined, "رقم الهاتف",
                prov.phone ?? "غير محدد", isDark),
            _buildInfoTile(Icons.bloodtype_outlined, "فصيلة الدم",
                prov.bloodType.isEmpty ? "غير محدد" : prov.bloodType, isDark),
            _buildInfoTile(Icons.cake_outlined, "تاريخ الميلاد",
                prov.birthDate ?? "غير محدد", isDark),
            const Divider(),
            TextButton.icon(
              onPressed: () => _showEditProfileDialog(context),
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              label: const Text("تعديل البيانات الشخصية",
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, bool isDark) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red.withOpacity(0.1),
        child: Icon(icon, color: Colors.red[600], size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 12, color: isDark ? Colors.white70 : Colors.grey)),
      subtitle: Text(value,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black)),
      dense: true,
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: prov.name);
    final phoneController = TextEditingController(text: prov.phone ?? '');
    final birthDateController =
        TextEditingController(text: prov.birthDate ?? '');
    final emailController =
        TextEditingController(text: prov.currentUser?['email'] ?? '');
    String selectedBloodType = prov.bloodType.isNotEmpty ? prov.bloodType : 'غير محدد';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل البيانات', textAlign: TextAlign.center),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 10),
                TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email))),
                const SizedBox(height: 10),
                TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                        labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('فصيلة الدم'),
                  subtitle: Text(selectedBloodType,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () async {
                    final newType = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('اختر فصيلة الدم'),
                        children: _bloodTypes
                            .map((type) => SimpleDialogOption(
                                  onPressed: () => Navigator.pop(context, type),
                                  child: Text(type),
                                ))
                            .toList(),
                      ),
                    );
                    if (newType != null) setState(() => selectedBloodType = newType);
                  },
                ),
                TextField(
                  controller: birthDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'تاريخ الميلاد',
                      prefixIcon: Icon(Icons.calendar_today)),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() => birthDateController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2,'0')}-${pickedDate.day.toString().padLeft(2,'0')}");
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              onPressed: () {
                prov.updateProfile(
                  newName: nameController.text,
                  newPhone: phoneController.text,
                  newBloodType: selectedBloodType,
                  newBirthDate: birthDateController.text,
                  newEmail: emailController.text,
                );
                Navigator.pop(ctx);
              },
              child: const Text('حفظ التغييرات', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- قسم الخصوصية والأمان -------------------
class PrivacySecuritySection extends StatelessWidget {
  final SettingsProvider prov;
  const PrivacySecuritySection({super.key, required this.prov});

  @override
  Widget build(BuildContext context) {
    final isDark = prov.isDarkMode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(Icons.health_and_safety_outlined,
                color: Colors.green[700]),
            title: const Text('مشاركة البيانات الطبية'),
            subtitle: const Text('السماح للمسعفين بالوصول لبياناتك عند الطوارئ'),
            value: prov.enableMedicalSharing,
            onChanged: (val) => prov.setMedicalSharing(val),
            activeColor: Colors.red[600],
          ),
          const Divider(height: 0),

          // --- زر تغيير كلمة المرور ---
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.orange),
            title: const Text('تغيير كلمة المرور', style: TextStyle(color: Colors.orange)),
            onTap: () => _showChangePasswordDialog(context, prov),
          ),

          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text('حذف الحساب', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text('سيتم مسح كافة بياناتك بشكل نهائي'),
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('هل أنت متأكد؟'),
        content: const Text(
            'حذف الحساب سيؤدي إلى فقدان جميع بياناتك الطبية وجهات اتصال الطوارئ. لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              prov.deleteAccount(); 
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/user_login');
            },
            child: const Text('حذف نهائي', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, SettingsProvider prov) {
    final passwordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير كلمة المرور', textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            onPressed: () async {
              final currentPassword = passwordController.text.trim();
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('كلمة المرور الجديدة لا تتطابق')),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && user.email != null) {
                  final cred = EmailAuthProvider.credential(
                      email: user.email!, password: currentPassword);
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPassword);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح!')),
                  );
                  Navigator.pop(ctx);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فشل تغيير كلمة المرور: $e')),
                );
              }
            },
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ------------------- قسم الإعدادات العامة -------------------
class GeneralSettingsSection extends StatelessWidget {
  final SettingsProvider prov;
  const GeneralSettingsSection({super.key, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          // سياسة الخصوصية
          ListTile(
  leading: Icon(Icons.description_outlined, color: Colors.blueGrey),
  title: Text('سياسة الخصوصية'),
  onTap: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => Padding(
          padding: EdgeInsets.all(16),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Text(
                    'سياسة الخصوصية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. جمع المعلومات:\n'
                    'نقوم بجمع المعلومات الشخصية مثل الاسم، البريد الإلكتروني، رقم الهاتف، والبيانات الطبية الحيوية لتوفير خدمة أفضل.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '2. استخدام المعلومات:\n'
                    'تستخدم البيانات لتحسين تجربة المستخدم، وتقديم الدعم الطبي عند الطوارئ، وضمان استمرارية الخدمات.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '3. مشاركة المعلومات:\n'
                    'قد نشارك بعض البيانات مع الجهات الطبية المصرح بها فقط عند الضرورة ووفقًا لقوانين حماية البيانات.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '4. حماية المعلومات:\n'
                    'نستخدم بروتوكولات أمان عالية لتخزين البيانات وحمايتها من الوصول غير المصرح به.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '5. حقوق المستخدمين:\n'
                    'يمكنك الاطلاع على بياناتك وتعديلها أو طلب حذفها في أي وقت.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '6. التواصل مع الدعم:\n'
                    'لأي استفسارات أو ملاحظات بخصوص الخصوصية، يمكنك التواصل معنا عبر البريد الإلكتروني أو التطبيق مباشرة.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
),


          const Divider(height: 0),

          // حول التطبيق
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueGrey),
            title: const Text('حول التطبيق'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "تطبيق الطوارئ",
                applicationVersion: "1.0.0",
                applicationIcon: Icon(Icons.health_and_safety,
                    color: Colors.red[600], size: 40),
                children: const [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      "هذا التطبيق مصمم لمساعدتك في حالات الطوارئ الطبية، "
                      "وتسهيل الوصول لبياناتك الحيوية بسرعة وسهولة. "
                      "يتيح لك التطبيق تخزين بياناتك الطبية الأساسية، "
                      "مشاركة المعلومات مع الجهات الطبية المصرح لها عند الضرورة، "
                      "والوصول إلى جهات الاتصال الطارئة.",
                      style: TextStyle(height: 1.6),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

