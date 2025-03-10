import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gas_detector_app/auth.dart';
import 'package:gas_detector_app/pages/home_page.dart'; // Import HomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      print('Attempting to sign in with email: ${_controllerEmail.text}'); // Debug print
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      print('Sign in successful'); // Debug print
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
      print('Sign in failed: $e'); // Debug print
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
      print('Unexpected error during sign in: $e'); // Debug print
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      print('Attempting to register with email: ${_controllerEmail.text}'); // Debug print
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      print('Registration successful'); // Debug print
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
      print('Registration failed: $e'); // Debug print
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
      print('Unexpected error during registration: $e'); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade800, Colors.blue.shade300],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isLogin ? 'LOGIN' : 'REGISTER',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        _buildInputField('Email', _controllerEmail),
                        const SizedBox(height: 10),
                        _buildInputField('Password', _controllerPassword, isPassword: true),
                        const SizedBox(height: 20),
                        if (errorMessage != null && errorMessage!.isNotEmpty)
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 80),
                        ElevatedButton(
                          onPressed: isLogin
                              ? signInWithEmailAndPassword
                              : createUserWithEmailAndPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            isLogin ? 'Login' : 'Register',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        errorMessage = ''; // Clear error when switching
                      });
                    },
                    child: Text.rich(
                      TextSpan(
                        text: isLogin ? 'Don\'t have an account? ' : 'Already have an account? ',
                        style: GoogleFonts.poppins(color: Colors.white),
                        children: [
                          TextSpan(
                            text: isLogin ? 'Sign up' : 'Login',
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 255, 166, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}