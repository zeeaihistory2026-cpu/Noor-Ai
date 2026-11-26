import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../data/noor_store.dart';
import '../../data/noor_controller.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../auth/create_account_screen.dart';

/// Page 40 — Madhhab Preference. "Fiqh preference" rows with a radio
/// dot on the right; Hanafi is the emerald selected row in the design.
/// The preference only changes how differences are presented ("Show
/// all" / "I'm not sure" are first-class options, chosen responsibly).
class MadhhabPreferenceScreen extends StatefulWidget {
  const MadhhabPreferenceScreen({super.key, this.editing = false});
  final bool editing;

  @override
  State<MadhhabPreferenceScreen> createState() =>
      _MadhhabPreferenceScreenState();
}

class _MadhhabPreferenceScreenState extends State<MadhhabPreferenceScreen> {
  int _selected = 0; // Hanafi, per the design
  bool _edited = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final madhhab = await NoorStore.getMadhhab();
    final index = SampleData.madhhabOptions.indexOf(madhhab);
    if (mounted && !_edited && index >= 0) setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    return NoorScaffold(
      bottom: NoorPrimaryButton(
        label: widget.editing ? 'Save preference' : 'Continue',
        onPressed: () async {
          await NoorStore.setMadhhab(SampleData.madhhabOptions[_selected]);
          if (!context.mounted) return;
          await NoorScope.read(context)?.loadLocation();
          if (context.mounted) {
            if (widget.editing) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateAccountScreen()));
          }
        },
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
        children: [
          const Text('Fiqh preference', style: NoorType.screenTitle),
          const SizedBox(height: 10),
          Text(
              'This helps AI present recognized scholarly differences '
              'responsibly. Choose "Show all" if unsure.',
              style: NoorType.body
                  .copyWith(color: NoorTheme.muted(context), height: 1.45)),
          const SizedBox(height: 28),
          for (var i = 0; i < SampleData.madhhabOptions.length; i++) ...[
            NoorOptionTile(
              label: SampleData.madhhabOptions[i],
              trailing: NoorRadioDot(selected: i == _selected),
              selected: i == _selected,
              onTap: () => setState(() {
                _edited = true;
                _selected = i;
              }),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
