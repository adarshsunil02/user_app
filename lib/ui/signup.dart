
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_map/ui/login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController=TextEditingController();
  final TextEditingController passwordController = TextEditingController();
 
  final formkey = GlobalKey<FormState>();
  bool isVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Sign Up",
                  style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 35),
                  ),
                
                const Gap(20),
               
                const Gap(30),
                const Text("name"),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.abc_outlined),
                    hintText: "your name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const Gap(20),
                const Text("email"),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_rounded),
                      hintText: "yourmail@gmail.com",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                const Gap(20),
                const Text("phone number"),
                TextFormField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone),
                      hintText: "0000000000",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                const Gap(20),
                const Text("password"),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isVisible,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.fingerprint_rounded),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: !isVisible
                              ? const Icon(Icons.visibility_off_outlined)
                              : const Icon(Icons.visibility_outlined)),
                      hintText: "************",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                const Gap(20),
                
                const Gap(40),
                ElevatedButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      signup(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('sign up failed...')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(400, 55),
                      backgroundColor: Colors.black),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                
                const Gap(30),
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                      text: TextSpan(
                          text: "Already  have an account? ",
                          style: const TextStyle(color: Colors.black),
                          children: [
                        TextSpan(
                            text: "Sign In",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>  Login(),
                                    ));
                              },
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))
                      ])),
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Future signup(context) async {
   
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          );

      addUserDetails(nameController.text.trim(), emailController.text.trim(),phoneNumberController.text.trim());
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>  Login(),
        ),
      );
    }
  }

  Future addUserDetails(String name, String email,String phoneNumber) async {
    await FirebaseFirestore.instance.collection("userscollection").add({
      'name': name,
      'email': email,
      'phone number':phoneNumber,
    });
  }

 

