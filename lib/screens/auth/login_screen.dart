import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import 'auth_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.authService});
  final AuthService? authService;
  @override
  Widget build(BuildContext context) => AuthScreen(authService: authService);
}
