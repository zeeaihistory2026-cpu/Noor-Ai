import 'package:flutter/material.dart';
import '../theme/noor_theme.dart';

/// Placeholder screen for a design page not yet implemented.
/// [page] is the NOOR design page number (01–42); [purpose] is a
/// one-line description taken from that page's "Screen Purpose".
class NoorStubScreen extends StatelessWidget {
  const NoorStubScreen({
    super.key,
    required this.page,
    required this.title,
    required this.purpose,
  });

  final int page;
  final String title;
  final String purpose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: NoorColors.emeraldDark,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text('Design Page ${page.toString().padLeft(2, '0')}'),
              backgroundColor: NoorColors.emeraldSoft,
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(purpose, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Stub screen — implement from the matching design PNG in '
                  'workspace/noor-design/NOOR_AI_Companion_Complete_UI_Pages_01-42/. '
                  'Use real exported background artwork from those files, '
                  'not generated approximations.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
