import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../auth/create_account_screen.dart';

/// Page 40 — Madhhab Preference. "Fiqh preference" rows with a radio
/// dot on the right; Hanafi is the emerald selected row in the design.
/// The preference only changes how differences are presented ("Show
/// all" / "I'm not sure" are first-class options, chosen responsibly).
class MadhhabPreferenceScreen extends StatefulWidget {
  const MadhhabPreferenceScreen({super.key});

  @override
  State<MadhhabPreferenceScreen> createState() =>
      _MadhhabPreferenceScreenState();
}

class _MadhhabPreferenceScreenState extends State<MadhhabPreferenceScreen> {
  int _selected = 0; // Hanafi, per the design

  @override
  Widget build(BuildContext context) {
    return NoorScaffold(
      bottom: NoorPrimaryButton(
        label: 'Continue',
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateAccountScreen())),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
        children: [
          const Text('Fiqh preference',
              style: NoorType.screenTitle),
          const SizedBox(height: 10),
          Text(
              'This helps AI present recognized scholarly differences '
              'responsibly. Choose "Show all" if unsure.',
              style: NoorType.body.copyWith(color: NoorColors.iconMuted, height: 1.45)),
          const SizedBox(height: 28),
          for (var i = 0; i < SampleData.madhhabOptions.length; i++) ...[
            NoorOptionTile(
              label: SampleData.madhhabOptions[i],
              trailing: NoorRadioDot(selected: i == _selected),
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
