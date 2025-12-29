import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('emergencyContacts') ?? [];
    setState(() {
      _contacts = saved.map((e) {
        final parts = e.split('|');
        return {'name': parts[0], 'phone': parts[1]};
      }).toList();
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _contacts.map((e) => "${e['name']}|${e['phone']}").toList();
    await prefs.setStringList('emergencyContacts', data);
  }

  void _addContact() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;
    setState(() {
      _contacts.add({'name': _nameController.text, 'phone': _phoneController.text});
    });
    _saveContacts();
    _nameController.clear();
    _phoneController.clear();
  }

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
    _saveContacts();
  }

  void _callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addContact,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Add Contact'),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    title: Text(contact['name']!),
                    subtitle: Text(contact['phone']!),
                    leading: const Icon(Icons.phone, color: Colors.green),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteContact(index),
                    ),
                    onTap: () => _callNumber(contact['phone']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
