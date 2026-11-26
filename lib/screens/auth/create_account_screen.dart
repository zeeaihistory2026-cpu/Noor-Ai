import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import 'auth_screen.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key, this.authService});
  final AuthService? authService;
  @override
  Widget build(BuildContext context) =>
      AuthScreen(createAccount: true, authService: authService);
}
