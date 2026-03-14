import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Enter your email to receive a password reset link"),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _auth.resetPassword(_emailController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Check your email for reset link")));
                Navigator.pop(context);
              },
              child: Text("Send Link"),
            ),
          ],
        ),
      ),
    );
  }
}