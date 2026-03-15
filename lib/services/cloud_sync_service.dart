import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';

class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ১. লোকাল ডাটা ক্লাউডে পাঠানো
  Future<void> syncLocalToCloud() async {
    final user = _auth.currentUser;
    if (user != null) {
      List<String> passedModules = await UnlockService.getPassedModulesList();

      // চেক করার জন্য এই প্রিন্টটি দিন
      print("Sending to Cloud: $passedModules");

      if (passedModules.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).set({
          'passedModules': passedModules,
          'lastSync': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("Cloud Updated Successfully!");
      } else {
        print("No passed modules found in local storage to sync.");
      }
    }
  }


  Future<void> syncCloudToLocal() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // ইউজারের UID দিয়ে ডাটাবেস থেকে প্রগ্রেস খুঁজে আনছি
        var doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && doc.data()!.containsKey('passedModules')) {
          List<dynamic> cloudModules = doc.data()?['passedModules'] ?? [];
          List<String> modulesToString = cloudModules.cast<String>();

          // এখন SharedPreferences-এ এই লিস্টটি আপডেট করে দেব
          await UnlockService.saveToLocalJson(modulesToString);
          print("Success: Cloud data synced to mobile local storage!");
        }
      } catch (e) {
        print("Error syncing from cloud: $e");
      }
    }
  }
}