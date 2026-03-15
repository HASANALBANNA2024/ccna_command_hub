//
// import 'package:ccna_command_hub/screens/login_screen.dart';
// import 'package:ccna_command_hub/screens/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:ccna_command_hub/services/auth_service.dart';
//
// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final AuthService _auth = AuthService();
//
//
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//   // পাসওয়ার্ড শো/হাইড স্টেট
//   bool _isObscure = true;
//   bool _isConfirmObscure = true;
//
//   @override
//   Widget build(BuildContext context) {
//     bool isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 25.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 50),
//
//               // --- ১. অ্যাপ আইকন এবং নাম (Login Screen এর মতো) ---
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
//                       child: const Icon(Icons.router_rounded, size: 60, color: Colors.blueAccent),
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
//                       "Create an account to get started",
//                       style: TextStyle(color: Colors.grey, fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // --- ২. ইনপুট ফিল্ডস (Name, Email, Password, Confirm) ---
//               _buildTextField(
//                 controller: _nameController,
//                 label: "Full Name",
//                 icon: Icons.person_outline_rounded,
//                 isDark: isDark,
//                 keyboardType: TextInputType.name,
//               ),
//
//               const SizedBox(height: 15),
//
//               _buildTextField(
//                 controller: _emailController,
//                 label: "Email Address",
//                 icon: Icons.email_outlined,
//                 isDark: isDark,
//                 keyboardType: TextInputType.emailAddress,
//                 autofill: [AutofillHints.email],
//               ),
//
//               const SizedBox(height: 15),
//
//               _buildTextField(
//                 controller: _passwordController,
//                 label: "Password",
//                 icon: Icons.lock_outline_rounded,
//                 isDark: isDark,
//                 isPassword: true,
//                 isObscure: _isObscure,
//                 autofill: [AutofillHints.newPassword],
//                 toggleObscure: () => setState(() => _isObscure = !_isObscure),
//               ),
//
//               const SizedBox(height: 15),
//
//               _buildTextField(
//                 controller: _confirmPasswordController,
//                 label: "Confirm Password",
//                 icon: Icons.lock_reset_rounded,
//                 isDark: isDark,
//                 isPassword: true,
//                 isObscure: _isConfirmObscure,
//                 toggleObscure: () => setState(() => _isConfirmObscure = !_isConfirmObscure),
//               ),
//
//               const SizedBox(height: 30),
//
//               // --- ৩. রেজিস্টার বাটন (Long & Gradient) ---
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
//                     // পাসওয়ার্ড চেক লজিক
//                     if (_passwordController.text != _confirmPasswordController.text) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Passwords do not match!")),
//                       );
//                       return;
//                     }
//
//                     // ডাটাবেসে ইউজার রেজিস্টার করা
//                     var user = await _auth.registerWithEmail(
//                       _emailController.text,
//                       _nameController.text,
//                       _passwordController.text,
//                     );
//
//                     if (user != null) {
//                       print("Register Successful");
//                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Registration Failed! Please try again.")),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   ),
//                   child: const Text(
//                     "REGISTER",
//                     style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // --- ৪. লগইন লিঙ্ক ---
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Already have an account? ",
//                     style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
//                     },
//                     child: const Text(
//                       "Login Now",
//                       style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // কাস্টম টেক্সট ফিল্ড মেথড (ডিজাইন ইউনিফর্ম রাখার জন্য)
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required bool isDark,
//     bool isPassword = false,
//     bool isObscure = false,
//     TextInputType keyboardType = TextInputType.text,
//     List<String>? autofill,
//     VoidCallback? toggleObscure,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword ? isObscure : false,
//       keyboardType: keyboardType,
//       autofillHints: autofill,
//       style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//         prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
//         suffixIcon: isPassword
//             ? IconButton(
//           icon: Icon(isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20),
//           onPressed: toggleObscure,
//         )
//             : null,
//         filled: true,
//         fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.blueAccent.withOpacity(0.05),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
//         ),
//       ),
//     );
//   }
// }