// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

// تعريف ثابت للخط المستخدم لضمان التوحيد
const String customFont = 'Cairo';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum AiAssistanceMode {
  both('كلاهما', Icons.flash_on_outlined, Colors.amber),
  field('توجيه ميداني', Icons.explore_outlined, Colors.blue),
  medical('طبية فقط', Icons.medical_services_outlined, Colors.purple);

  const AiAssistanceMode(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class _SettingsPageState extends State<SettingsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLocationSharingEnabled = true;
  double _searchRadius = 5.0;
  bool _nearbyCaseAlert = true;
  bool _alertSound = true;
  bool _vibration = false;
  bool _silentModeOverride = false;
  // ignore: unused_field
  String? _selectedFilePath;
  String? _fileName;
  bool _isAiAssistantEnabled = true;
  AiAssistanceMode _aiAssistanceMode = AiAssistanceMode.both;

  Future<void> _pickFile() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _fileName = result.files.single.name;
          _selectedFilePath = result.files.single.path;
        });
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _showPermissionDialog() async {
    final bool? didAgree = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'تفعيل صوت الطوارئ',
                        style: TextStyle(
                          fontFamily: customFont,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'هل توافق على السماح لهذا التطبيق بتشغيل أصوات الطوارئ حتى عندما يكون هاتفك على وضع الصامت أو عدم الإزعاج؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: customFont,
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'تُستخدم هذه الميزة فقط لإنذارات الطوارئ التي قد تنقذ حياة. لن يتم تشغيل أي أصوات أخرى.',
                            style: TextStyle(
                              fontFamily: customFont,
                              color: Colors.black87,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'أوافق',
                      style: TextStyle(
                        fontFamily: customFont,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontFamily: customFont,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (didAgree != null) {
      setState(() => _silentModeOverride = didAgree);
    }
  }

  Future<void> _showAiModePicker() async {
    final AiAssistanceMode?
    selectedMode = await showModalBottomSheet<AiAssistanceMode>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, bottom: 16),
                  child: Text(
                    'اختر نمط المساعدة الذكية',
                    style: TextStyle(
                      fontFamily: customFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...AiAssistanceMode.values.map((mode) {
                  final bool isSelected = _aiAssistanceMode == mode;
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(mode),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor:
                        isSelected
                            ? Colors.red.withOpacity(0.1)
                            : Colors.transparent,
                    leading: Icon(
                      mode.icon,
                      color: isSelected ? mode.color : Colors.black54,
                    ),
                    title: Text(
                      mode.label,
                      style: TextStyle(
                        fontFamily: customFont,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.red : Colors.black87,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? const Icon(Icons.check_circle, color: Colors.red)
                            : null,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selectedMode != null) {
      setState(() => _aiAssistanceMode = selectedMode);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 16, color: Colors.black54),
              label: const Text(
                'إغلاق',
                style: TextStyle(fontFamily: customFont, color: Colors.black87),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ),
        leadingWidth: 120,
        title: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Settings / إعدادات',
              style: TextStyle(
                fontFamily: customFont,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'إعدادات المسعف',
                style: TextStyle(
                  fontFamily: customFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildLocationSettingsCard(),
              const SizedBox(height: 20),
              _buildNotificationsCard(),
              const SizedBox(height: 20),
              _buildSilentModeCard(),
              const SizedBox(height: 20),
              _buildAiSettingsCard(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save_alt_outlined, size: 20),
                label: const Text(
                  'حفظ التغييرات',
                  style: TextStyle(fontFamily: customFont, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'AI Settings',
                    style: TextStyle(
                      fontFamily: customFont,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'إعدادات الذكاء الاصطناعي',
                    style: TextStyle(
                      fontFamily: customFont,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
              Icon(Icons.smart_toy_outlined, color: Colors.red, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitchRow(
            'تفعيل المساعد الذكي',
            'الحصول على مساعدة ذكية أثناء الطوارئ',
            _isAiAssistantEnabled,
            (value) => setState(() => _isAiAssistantEnabled = value),
          ),
          if (_isAiAssistantEnabled) ...[
            const Divider(indent: 20, endIndent: 20, height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'نمط المساعدة',
                  style: TextStyle(
                    fontFamily: customFont,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _showAiModePicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _aiAssistanceMode.icon,
                                color: _aiAssistanceMode.color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _aiAssistanceMode.label,
                                style: const TextStyle(
                                  fontFamily: customFont,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Professional Profile',
                    style: TextStyle(
                      fontFamily: customFont,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'الملف المهني',
                    style: TextStyle(
                      fontFamily: customFont,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
              Icon(Icons.person_outline, color: Colors.red, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),
          _buildEditableField('الاسم الكامل', 'ادخل الاسم الكامل'),
          _buildEditableField('رقم المسعف / ترخيص العمل', 'ادخل رقم الترخيص'),
          _buildEditableField('الجهة التابع لها', 'ادخل اسم الجهة'),
          _buildEditableField('رقم الهاتف المهني', 'ادخل رقم الهاتف'),
          const SizedBox(height: 24),
          const Text(
            'صورة الهوية أو الشهادة',
            style: TextStyle(
              fontFamily: customFont,
              color: Colors.black54,
              fontSize: 13,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.upload_file_outlined,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _fileName ?? 'رفع ملف',
                      style: TextStyle(
                        fontFamily: customFont,
                        color: _fileName != null ? Colors.black : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Location Settings',
                    style: TextStyle(
                      fontFamily: customFont,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'إعدادات الموقع',
                    style: TextStyle(
                      fontFamily: customFont,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
              Icon(Icons.location_on_outlined, color: Colors.red, size: 28),
            ],
          ),
          const SizedBox(height: 24),
          _buildSwitchRow(
            'مشاركة موقعي الحالي',
            'مشاركة موقعك مباشرة مع المرضى',
            _isLocationSharingEnabled,
            (value) => setState(() => _isLocationSharingEnabled = value),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'نطاق البحث عن الحالات',
                style: TextStyle(
                  fontFamily: customFont,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6.0,
                  thumbColor: Colors.black,
                  activeTrackColor: Colors.red,
                  inactiveTrackColor: Colors.grey.shade300,
                  valueIndicatorTextStyle: const TextStyle(
                    fontFamily: customFont,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Slider(
                  value: _searchRadius,
                  min: 1,
                  max: 25,
                  label: 'km ${_searchRadius.round()}',
                  onChanged:
                      (double value) => setState(() => _searchRadius = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'km 1',
                      style: TextStyle(
                        fontFamily: customFont,
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'km ${_searchRadius.round()}',
                      style: const TextStyle(
                        fontFamily: customFont,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'km 25',
                      style: TextStyle(
                        fontFamily: customFont,
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Emergency Notifications',
                    style: TextStyle(
                      fontFamily: customFont,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'إشعارات الطوارئ',
                    style: TextStyle(
                      fontFamily: customFont,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
              Icon(
                Icons.notifications_active_outlined,
                color: Colors.red,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitchRow(
            'تنبيه عند وجود حالة قريبة',
            'تلقي تنبيهات عند وجود حالات طوارئ قريبة',
            _nearbyCaseAlert,
            (value) => setState(() => _nearbyCaseAlert = value),
          ),
          const Divider(indent: 20, endIndent: 20),
          _buildSwitchRow(
            'صوت التنبيه',
            'تشغيل صوت عند وجود حالة طوارئ',
            _alertSound,
            (value) => setState(() => _alertSound = value),
          ),
          const Divider(indent: 20, endIndent: 20),
          _buildSwitchRow(
            'تفعيل الاهتزاز',
            'اهتزاز الهاتف عند التنبيهات',
            _vibration,
            (value) => setState(() => _vibration = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSilentModeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'تشغيل صوت الطوارئ حتى في الصامت',
                style: TextStyle(
                  fontFamily: customFont,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.smartphone,
                color: Colors.red.withOpacity(0.8),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'هذا التطبيق سيطلب إذنًا لتشغيل إشعارات صوتية مهمة حتى لو هاتفك على صامت أو الوضع "عدم الإزعاج". تُستخدم هذه الميزة فقط لإنذارات الطوارئ التي قد تنقذ حياة.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: customFont,
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Switch(
                value: _silentModeOverride,
                onChanged:
                    (bool value) =>
                        value
                            ? _showPermissionDialog()
                            : setState(() => _silentModeOverride = false),
                activeTrackColor: Colors.black54,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: customFont,
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: customFont,
              color: Colors.black,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: customFont,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: customFont,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: customFont,
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.red),
        ],
      ),
    );
  }
}
