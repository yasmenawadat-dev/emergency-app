// lib/widgets/emergency_tab.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';

class EmergencyTab extends StatelessWidget {
  const EmergencyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<SettingsProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم ميزات الطوارئ الذكية
            _buildHeader('ميزات الطوارئ المتقدمة', Icons.security_update_good, Colors.red),
            _buildFeaturesCard(prov),

            const SizedBox(height: 25),

            // قسم تذكير الأدوية (المنبه)
            _buildHeader('تذكير الأدوية (المنبه)', Icons.alarm, Colors.deepOrange),
            _buildMedicineAlarmCard(context, prov),

            const SizedBox(height: 25),

            // قسم جهات الاتصال الطارئة
            _buildHeader('جهات الاتصال الطارئة', Icons.contact_phone, Colors.blueGrey),
            _buildContactsCard(context, prov),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // مكوّن عنوان القسم
  Widget _buildHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // 1. بطاقة ميزات الطوارئ (Voice, Recording, Tracking)
  Widget _buildFeaturesCard(SettingsProvider prov) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.mic, color: Colors.purple),
            title: const Text('التفعيل الصوتي (Help)'),
            subtitle: const Text('تفعيل الطوارئ تلقائياً عند سماع كلمة "Help"'),
            value: prov.voiceActivation,
            onChanged: (val) => prov.setVoiceActivation(val),
            activeColor: Colors.red,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.record_voice_over, color: Colors.red),
            title: const Text('التسجيل التلقائي (Auto Recording)'),
            subtitle: const Text('بدء تسجيل الصوت فور حدوث حالة طوارئ'),
            value: prov.autoRecording,
            onChanged: (val) => prov.setAutoRecording(val),
            activeColor: Colors.red,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.location_on, color: Colors.green),
            title: const Text('تتبع العائلة (Family Tracking)'),
            subtitle: const Text('مشاركة موقعك الجغرافي مع أفراد العائلة'),
            value: prov.familyTracking,
            onChanged: (val) => prov.setFamilyTracking(val),
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }

  // 2. بطاقة منبه الأدوية
  Widget _buildMedicineAlarmCard(BuildContext context, SettingsProvider prov) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          if (prov.medicineAlarms.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('لا توجد منبهات أدوية مضافة', style: TextStyle(color: Colors.grey)),
            ),
          ...prov.medicineAlarms.asMap().entries.map((entry) {
            final index = entry.key;
            final alarm = entry.value;
            return Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.medication_liquid, color: Colors.deepOrange),
                  title: Text(alarm['name'] ?? ''),
                  subtitle: Text('موعد الدواء: ${alarm['time']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.grey),
                    onPressed: () => prov.removeMedicineAlarm(index),
                  ),
                ),
                if (index < prov.medicineAlarms.length - 1) const Divider(height: 1),
              ],
            );
          }),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add_alarm, color: Colors.blue),
            title: const Text('إضافة منبه دواء جديد', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            onTap: () => _showAddAlarmDialog(context, prov),
          ),
        ],
      ),
    );
  }

  // 3. بطاقة جهات الاتصال
  Widget _buildContactsCard(BuildContext context, SettingsProvider prov) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ...prov.emergencyContacts.asMap().entries.map((entry) {
            // ignore: unused_local_variable
            final index = entry.key;
            final contact = entry.value;
            return ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.person, color: Colors.white)),
              title: Text(contact['name'] ?? ''),
              subtitle: Text(contact['phone'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () => launchUrl(Uri.parse('tel:${contact['phone']}')),
              ),
            );
          }),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1, color: Colors.blue),
            title: const Text('إضافة جهة اتصال جديدة'),
            onTap: () => _showAddContactDialog(context, prov),
          ),
        ],
      ),
    );
  }

  // --- حوار إضافة منبه دواء ---
  void _showAddAlarmDialog(BuildContext context, SettingsProvider prov) {
    final nameController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('ضبط منبه دواء'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الدواء', prefixIcon: Icon(Icons.medication)),
              ),
              const SizedBox(height: 15),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('اختر الوقت'),
                trailing: Text(selectedTime.format(context), style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: selectedTime);
                  if (time != null) setState(() => selectedTime = time);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  prov.addMedicineAlarm(nameController.text, selectedTime.format(context));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ المنبه'),
            ),
          ],
        ),
      ),
    );
  }

  // --- حوار إضافة جهة اتصال ---
  void _showAddContactDialog(BuildContext context, SettingsProvider prov) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة جهة اتصال'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                prov.addEmergencyContact(name: nameController.text, phone: phoneController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}