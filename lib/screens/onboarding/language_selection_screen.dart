import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'madhhab_preference_screen.dart';

/// Page 39 — Language Selection. "Choose your language" with full-
/// width language rows (native label left, English name right, muted);
/// English is the emerald selected row. Single-select.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  int _selected = 0; // English, per the design

  @override
  Widget build(BuildContext context) {
    return NoorScaffold(
      bottom: NoorPrimaryButton(
        label: 'Continue',
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MadhhabPreferenceScreen())),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
        children: [
          const Text('Choose your language', style: NoorType.screenTitle),
          const SizedBox(height: 10),
          const Text('You can change this later.', style: NoorType.secondary),
          const SizedBox(height: 28),
          for (var i = 0; i < SampleData.languages.length; i++) ...[
            NoorOptionTile(
              label: SampleData.languages[i].$1,
              labelStyle: i == 1
                  ? NoorType.urdu(size: 16)
                  : i == 2
                      ? NoorType.arabic(size: 18)
                      : null,
              trailing: Text(SampleData.languages[i].$2,
                  style: NoorType.meta.copyWith(color: i == _selected
                          ? Colors.white
                          : NoorColors.mutedDark)),
              selected: i == _selected,
              onTap: () => setState(() => _selected = i),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
