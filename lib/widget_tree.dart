import 'package:flutter/material.dart';
import 'package:gas_detector_app/auth.dart';
import 'package:gas_detector_app/pages/home_page.dart';
import 'package:gas_detector_app/pages/login_register__page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage(); // User is logged in
        } else {
          return const LoginPage(); // User is not logged in
        }
      },
    );
  }
}