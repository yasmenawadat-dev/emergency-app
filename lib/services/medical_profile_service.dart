import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalProfileService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  DocumentReference get _doc =>
      _firestore.collection('users').doc(_uid)
      .collection('medical_profile').doc('main');

  // حفظ البيانات
  Future<void> saveProfile(Map<String, dynamic> data) async {
    await _doc.set(data, SetOptions(merge: true));
  }

  // جلب البيانات
  Future<Map<String, dynamic>?> loadProfile() async {
    final snap = await _doc.get();
    if (snap.exists) {
      return snap.data() as Map<String, dynamic>;
    }
    return null;
  }
}
