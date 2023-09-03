import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whatever/auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
              onPressed: () async {
                UserCredential? user = await Auth.instance.signInWithGoogle();
                if (user != null) {
                  context.go("/");
                }
              },
              child: const Text("Login with Google")),
        ),
      ),
    );
  }
}
