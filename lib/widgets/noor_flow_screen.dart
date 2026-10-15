import 'package:flutter/material.dart';
import '../theme/noor_theme.dart';

/// Simple flow screen for onboarding/auth (Pages 37–42):
/// title, one-line purpose, and a primary button to the next step.
class NoorFlowScreen extends StatelessWidget {
  const NoorFlowScreen({
    super.key,
    required this.page,
    required this.title,
    required this.purpose,
    required this.buttonLabel,
    required this.onNext,
  });

  final int page;
  final String title;
  final String purpose;
  final String buttonLabel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: NoorColors.emeraldDark,
          foregroundColor: Colors.white,
          title: Text('Page ${page.toString().padLeft(2, '0')}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(purpose),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onNext, child: Text(buttonLabel)),
            ),
          ],
        ),
      ),
    );
  }
}
