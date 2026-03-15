// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class DatabaseService {
//   // Get current user UID
//   // final String uid = FirebaseAuth.instance.currentUser!.uid;
//   final String uid = FirebaseAuth.instance.currentUser?.uid ?? "CCNA Command Hub";
//   // Firestore collection reference
//   final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
//
//   // Function 1: Convert Image to Base64 string (Alternative to Cloud Storage)
//   Future<String> uploadImage(File image) async {
//     try {
//       // Convert image file to bytes
//       List<int> imageBytes = await image.readAsBytes();
//
//       // Encode bytes to Base64 string
//       String base64Image = base64Encode(imageBytes);
//
//       print("Image encoded successfully!");
//       // Return with proper Data URI header
//       return "data:image/png;base64,$base64Image";
//
//     } catch (e) {
//       print("Error encoding image: $e");
//       return "";
//     }
//   }
//
//   // Function 2: Update or Save user profile data
//   Future updateUserData(String name, String phone, String imageURL, String birthday, String religion) async {
//     try {
//       return await userCollection.doc(uid).set({
//         'uid': uid,
//         'name': name,
//         'phone': phone,
//         'image': imageURL, // Saves the Base64 string here
//         'birthday': birthday,
//         'religion': religion,
//         'email': FirebaseAuth.instance.currentUser!.email,
//         'updatedAt': FieldValue.serverTimestamp(), // Server timestamp for sync
//       }, SetOptions(merge: true));
//     } catch (e) {
//       print("Error updating data: $e");
//       return null;
//     }
//   }
//
//   // Function 3: Get real-time user data for Profile/Drawer
//   Stream<DocumentSnapshot> get getPersonalData {
//     return userCollection.doc(uid).snapshots();
//   }
//
//   // Function 4: Fetch user data once (if needed)
//   Future<DocumentSnapshot> getUserDataOnce() async {
//     return await userCollection.doc(uid).get();
//   }
// }