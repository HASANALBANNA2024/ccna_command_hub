import 'package:ccna_command_hub/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/services/auth_service.dart';
import 'package:ccna_command_hub/screens/forgot_password.dart';
import 'package:ccna_command_hub/screens/register_screen.dart';


class LoginScreen extends StatefulWidget
{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
              }, child: Text("Forgot Password?")
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: ()async{
                  var user = await _auth.loginWithEmail(_emailController.text, _passwordController.text);
                  if(user!=null)
                    {
                      print("Login Successful");
                      Navigator.push(context, MaterialPageRoute(builder: (_)=> DashboardScreen()));
                    }
                  else
                    {
                      print("Failed");
                    }
                },
                child: Text("Login")
            ),
            
            TextButton(onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
            }, child: Text("Don't have an account? Register Here.."))

          ],
        ),
      ),


    );
  }
}