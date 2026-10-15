import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'language_selection_screen.dart';

/// Page 38 — Goal Selection. "What would you like to improve?" with
/// a two-column grid of goal tiles (initial badge + label); selected
/// tiles fill emerald, the rest stay white. Multi-select, then the
/// Continue pill at the bottom.
class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  // Pre-selected in the design: Quran reading, Salah consistency,
  // Memorization.
  final _selected = <int>{0, 1, 3};

  @override
  Widget build(BuildContext context) {
    return NoorScaffold(
      bottom: NoorPrimaryButton(
        label: _selected.isEmpty
            ? 'Choose at least one goal'
            : 'Continue · ${_selected.length} selected',
        onPressed: _selected.isEmpty
            ? null
            : () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LanguageSelectionScreen())),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
        children: [
          const Text('What would you like to improve?',
              style: NoorType.screenTitle),
          const SizedBox(height: 10),
          const Text('Choose one or more goals. You can change them anytime.',
              style: NoorType.secondary),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: SampleData.goals.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              // Cells grow taller as the OS text size grows, so
              // labels never overflow at 200% text scale.
              childAspectRatio: 1.85 /
                  MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
            ),
            itemBuilder: (context, i) {
              final goal = SampleData.goals[i];
              final on = _selected.contains(i);
              return NoorOptionTile(
                label: goal.$2,
                leading: NoorInitialBadge(goal.$1, selected: on),
                selected: on,
                onTap: () =>
                    setState(() => on ? _selected.remove(i) : _selected.add(i)),
              );
            },
          ),
        ],
      ),
    );
  }
}
