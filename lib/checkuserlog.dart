import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_map/ui/destination.dart';
import 'package:google_map/ui/login.dart';

class Checkuserlog extends StatelessWidget {
  const Checkuserlog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const Destination();
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}
