import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // ফাংশন ১: ইমেজ আপলোড
  Future<String> uploadImage(File image) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('profile_pics').child('$uid.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error: $e");
      return "";
    }
  }

  // ফাংশন ২: ডাটা আপডেট
  Future updateUserData(String name, String phone, String imageURL, String birthday, String religion) async {
    return await userCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'phone': phone,
      'image': imageURL,
      'birthday': birthday,
      'religion': religion,
      'email': FirebaseAuth.instance.currentUser!.email,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // ফাংশন ৩: ড্রয়ারের জন্য ডাটা (এই লাইনেই আপনার সমস্যা হচ্ছিল)
  Stream<DocumentSnapshot> get getPersonalData {
    return userCollection.doc(uid).snapshots();
  }
}