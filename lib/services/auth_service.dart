// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   // Register Logic
//
//   Future<User?> registerWithEmail(String email, String name, String password) async {
//     try {
//       // ১. ইমেইল এবং পাসওয়ার্ড দিয়ে ইউজার তৈরি করা
//       UserCredential result = await _auth.createUserWithEmailAndPassword(
//           email: email,
//           password: password
//       );
//
//       User? user = result.user;
//
//       if (user != null) {
//         // ২. ইউজারের ডিসপ্লে নেম আপডেট করা (Firebase Auth-এ)
//         await user.updateDisplayName(name);
//
//         // ৩. Firestore ডেটাবেসে ইউজারের তথ্য সেভ করা (যাতে পরে প্রোফাইলে দেখানো যায়)
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'uid': user.uid,
//           'name': name,
//           'email': email,
//           'createdAt': DateTime.now(),
//         });
//       }
//
//       return user;
//     } catch (e) {
//       print("Registration Error: ${e.toString()}");
//       return null;
//     }
//   }
// // login Logic
// Future<User?> loginWithEmail(String email, String password)async{
//   try {
//     UserCredential result = await _auth.signInWithEmailAndPassword(
//         email: email, password: password);
//     return result.user;
//   } catch (e) {
//     print(e.toString());
//     return null;
//   }
//
// }
// // forgot password
//   Future<void> resetPassword(String email)async
//   {
//     await _auth.sendPasswordResetEmail(email: email);
//   }
//
// // logout
// Future<void> signOut() async
// {
//   await _auth.signOut();
// }
// }