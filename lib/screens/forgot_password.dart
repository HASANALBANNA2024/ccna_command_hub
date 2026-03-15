// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
//
// class ForgotPasswordScreen extends StatelessWidget {
//   final _emailController = TextEditingController();
//   final AuthService _auth = AuthService();
//
//   @override
//   Widget build(BuildContext context) {
//     // ডার্ক মোড চেক
//     bool isDark = Theme.of(context).brightness == Brightness.dark;
//     //
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
//       // ব্যাক বাটন কাস্টমাইজেশন
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.blueGrey.shade900),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 25.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 30),
//
//               // --- ১. অ্যাপ আইকন এবং নাম ---
//               Center(
//                 child: Column(
//                   children: [
//                     Container(
//                       height: 100,
//                       width: 100,
//                       decoration: BoxDecoration(
//                         color: Colors.blueAccent.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: const Icon(Icons.lock_reset_rounded, size: 60, color: Colors.blueAccent),
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       "CCNA Command Hub",
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : Colors.blueGrey.shade900,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       "Forgot your password?",
//                       style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               // --- ২. নির্দেশনামূলক টেক্সট ---
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Text(
//                   "Enter your email below. We will send you a secure link to reset your password.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: isDark ? Colors.white70 : Colors.black54,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // --- ৩. ইমেইল ইনপুট ফিল্ড (লগইন পেজের স্টাইলে) ---
//               TextField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//                 decoration: InputDecoration(
//                   labelText: "Email Address",
//                   labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//                   prefixIcon: const Icon(Icons.email_outlined, color: Colors.blueAccent, size: 22),
//                   filled: true,
//                   fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.blueAccent.withOpacity(0.05),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // --- ৪. সেন্ড বাটন (Long & Gradient) ---
//               Container(
//                 width: double.infinity,
//                 height: 55,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   gradient: const LinearGradient(
//                     colors: [Colors.blueAccent, Colors.indigoAccent],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blueAccent.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     )
//                   ],
//                 ),
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (_emailController.text.isNotEmpty) {
//                       await _auth.resetPassword(_emailController.text);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Check your email for the reset link!"),
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                       Navigator.pop(context);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Please enter your email first"),
//                           backgroundColor: Colors.redAccent,
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   ),
//                   child: const Text(
//                     "SEND RESET LINK",
//                     style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }