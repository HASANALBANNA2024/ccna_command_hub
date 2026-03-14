import 'package:flutter/material.dart';
import 'package:ccna_command_hub/services/auth_service.dart';

class RegisterScreen extends StatefulWidget
{
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
{
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Create Account"),
     ),
     // body of content
     body: Padding(
       padding: EdgeInsets.all(20),
       child: Column(
         children: [
           TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
           TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),

           SizedBox(height: 30,),

           ElevatedButton(onPressed: ()async{
             var user = await _auth.registerWithEmail(_emailController.text, _passwordController.text);
             if(user!=null)
               {
                 Navigator.pop(context);
                 print("Register Done");
               }
           }, child: Text("Register")),

         ],
       ),
     ),
   );
  }
}