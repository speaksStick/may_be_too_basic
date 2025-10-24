import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:may_be_too_basic/Common/GlobalObjectProvider.dart';
import 'package:may_be_too_basic/Enums/UserProfession.dart';
import 'package:may_be_too_basic/ViewModel/RegisterUserViewModel.dart';
import 'package:provider/provider.dart';


class RegisterUserView extends StatelessWidget {
  const RegisterUserView({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController cityController = TextEditingController();
    int? selectedProfession;

    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text("Register User"),
            ],
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 30, 30, 30),
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
                        backgroundColor: const Color.fromARGB(255, 59, 59, 59),
                        child: Icon(Icons.add, size: 22, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(GetInformationScreenWidget(context)),
                      SizedBox(height: 24),
                      Text(
                        "Create Your Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 45, 45, 46),
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 24),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: const Color.fromARGB(255, 48, 48, 48)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          filled: true,
                          fillColor: Colors.deepPurple.shade50,
                        ),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: const Color.fromARGB(255, 38, 38, 38)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: const Color.fromARGB(255, 208, 202, 202),
                        ),
                        controller: passwordController,
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_city_rounded, color: const Color.fromARGB(255, 38, 38, 38)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          labelText: 'City',
                          hintText: 'Optional',
                          filled: true,
                          fillColor: const Color.fromARGB(255, 20, 20, 20),
                        ),
                        controller: cityController,
                        obscureText: true,
                      ),
                      DropdownButton(items: 
                     [ 
                        DropdownMenuItem(child: Text("One"), value: 1,),
                        DropdownMenuItem(child: Text("Two"), value: 2,),
                        DropdownMenuItem(child: Text("Three"), value: 3,),
                    ], 
                    onChanged: (value) { selectedProfession = value; },),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.check_circle, color: Colors.white),
                          label: Text(
                            "Register",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 44, 44, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            elevation: 8,
                          ),
                          onPressed: () async{
                            String email = emailController.text;
                            String password = passwordController.text;
                            String city = cityController.text;
                            String profession = Userprofession.values[selectedProfession ?? 0].name;
      
                            print("Email: $email, Password: $password, City: $city, Profession: $profession");
                            //FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                            bool userRegisterationStatus = await Provider.of<RegisterUserViewModel>(context, listen: false).RegisterUserAsync(UserData(email, password));
                            
                            if(userRegisterationStatus)
                            {
                              GlobalObjectProvider.LoggerServiceSingleTonObject.LogMessage("User registered successfully with status: ${userRegisterationStatus.toString()}"); 
                              Navigator.pushNamed(context, '/loginUserView');
                            }
                            else
                            {
                              GlobalObjectProvider.LoggerServiceSingleTonObject.LogError("User registration failed.");
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/loginUserView');
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 39, 39, 39),
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
  
  String GetInformationScreenWidget(BuildContext context) 
  {
    var errorStatus = context.watch<RegisterUserViewModel>().GetUserRegsitrationErrorStatus().toString();
    var messgae = errorStatus == "UserRegisterationErrorStatus.none" ? "" : "Error: $errorStatus";
    return messgae;
    // return Text(
    //   messgae,  
    //   style: TextStyle(
    //     fontSize: 20,
    //     fontWeight: FontWeight.w600,
    //     color: Colors.white,
    //   ),
    // );
  }
}