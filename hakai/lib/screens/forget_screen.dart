import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _errorMessage = "";
  bool _isEmailSent = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendPasswordResetEmail() async {
    try {
      final String email = _emailController.text.trim();
      if (email.isEmpty) {
        setState(() {
          _errorMessage = "Please enter a valid email.";
        });
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      
      setState(() {
        _errorMessage = "Password reset link sent to your email!";
        _isEmailSent = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "FORGOT PASSWORD",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Enter your email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendPasswordResetEmail,
                child: Text("Send Reset Link"),
              ),
              if (_isEmailSent)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Please check your email for the reset link.",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
