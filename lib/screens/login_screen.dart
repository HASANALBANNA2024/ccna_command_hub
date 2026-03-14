import 'package:ccna_command_hub/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/services/auth_service.dart';
import 'package:ccna_command_hub/screens/forgot_password.dart';
import 'package:ccna_command_hub/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true; // পাসওয়ার্ড দেখানো বা লুকানোর জন্য

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // --- ১. অ্যাপ আইকন এবং নাম ---
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.router_rounded, size: 60, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "CCNA Command Hub",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Login to continue your journey",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // --- ২. ইমেইল ফিল্ড ---
              _buildTextField(
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email_outlined,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
                autofill: [AutofillHints.email],
              ),

              const SizedBox(height: 20),

              // --- ৩. পাসওয়ার্ড ফিল্ড ---
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock_outline_rounded,
                isDark: isDark,
                isPassword: true,
                isObscure: _isObscure,
                autofill: [AutofillHints.password],
                toggleObscure: () => setState(() => _isObscure = !_isObscure),
              ),

              // --- ৪. ফরগট পাসওয়ার্ড ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- ৫. লগইন বাটন (Full Width & Gradient) ---
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.indigoAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    var user = await _auth.loginWithEmail(_emailController.text, _passwordController.text);
                    if (user != null) {
                      print("Login Successful");
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to login. Please check your email or password."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- ৬. রেজিস্ট্রেশন লিঙ্ক ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                    },
                    child: const Text(
                      "Register Here",
                      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // কাস্টম টেক্সট ফিল্ড মেথড
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    List<String>? autofill,
    VoidCallback? toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      autofillHints: autofill,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey),
          onPressed: toggleObscure,
        )
            : null,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.blueAccent.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}