import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginUserView extends StatelessWidget {
  const LoginUserView({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Login User"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 52, 53, 52),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color.fromARGB(255, 34, 35, 36),
                      child: Icon(Icons.login_rounded, size: 22, color: Colors.white),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Login to your Account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 10, 10, 10),
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: const Color.fromARGB(255, 59, 61, 61)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        filled: true,
                        fillColor: const Color.fromARGB(255, 96, 96, 96),
                      ),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: const Color.fromARGB(255, 56, 57, 57)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        filled: true,
                        fillColor: const Color.fromARGB(255, 42, 42, 42),
                      ),
                      controller: passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        label: Text(
                          "Login!",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 46, 45, 47),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 8,
                        ),
                        onPressed: () {
                          String email = emailController.text;
                          String password = passwordController.text;
                          print("Email: $email, Password: $password");
                          //FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Don't have an account with us?",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/registerUserView');
                      },
                      child: Text(
                        "Register here",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 71, 71, 72),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}