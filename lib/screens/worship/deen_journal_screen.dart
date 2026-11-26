import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/lifestyle_guides_data.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Module 9 P2 — My Deen Sunnah Checklist & Private Gratitude Journal:
/// Track daily prophetic habits and write reflections stored locally.
class DeenJournalScreen extends StatefulWidget {
  const DeenJournalScreen({super.key});

  @override
  State<DeenJournalScreen> createState() => _DeenJournalScreenState();
}

class _DeenJournalScreenState extends State<DeenJournalScreen> {
  Set<String> _doneIds = <String>{};
  List<Map<String, dynamic>> _entries = const [];
  final _journalCtrl = TextEditingController();

  String get _todayKey => DateTime.now().toIso8601String().split('T').first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _journalCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final done = await NoorStore.getSunnahDoneIds(_todayKey);
    final j = await NoorStore.getGratitudeJournal();
    if (!mounted) return;
    setState(() {
      _doneIds = done.toSet();
      _entries = j;
    });
  }

  void _toggleSunnah(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_doneIds.contains(id)) {
        _doneIds.remove(id);
      } else {
        _doneIds.add(id);
      }
    });
    NoorStore.setSunnahDoneIds(_todayKey, _doneIds.toList());
  }

  Future<void> _saveJournal() async {
    final text = _journalCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    await NoorStore.addGratitudeEntry(text);
    _journalCtrl.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final total = LifestyleGuidesData.sunnahHabits.length;
    final done = _doneIds.length;

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            const NoorDarkHeader(
              title: 'My Deen & Sunnah',
              subtitle: 'Daily Sunnah habits & gratitude journal',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  NoorCard(
                    color: NoorColors.emeraldDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAY’S SUNNAH HABITS',
                          style: NoorType.eyebrow
                              .copyWith(color: NoorColors.onEmeraldMuted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$done of $total completed',
                          style: NoorType.tabular(
                              NoorType.section.copyWith(color: NoorColors.gold)),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: total == 0 ? 0 : done / total,
                            color: NoorColors.gold,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NoorSectionLabel('Sunnah Checklist'),
                        const SizedBox(height: 8),
                        for (var i = 0; i < total; i++) ...[
                          if (i > 0)
                            Divider(height: 1, color: NoorTheme.border(context)),
                          Builder(builder: (context) {
                            final h = LifestyleGuidesData.sunnahHabits[i];
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: NoorColors.emeraldDark,
                              value: _doneIds.contains(h.id),
                              onChanged: (_) => _toggleSunnah(h.id),
                              title: Text(h.title, style: NoorType.secondary),
                              subtitle: Text(h.subtitle,
                                  style: NoorType.meta
                                      .copyWith(color: NoorTheme.muted(context))),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NoorSectionLabel('Private Gratitude & Reflection'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _journalCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Write an Alhamdulillah moment or spiritual intention...',
                            filled: true,
                            fillColor: NoorTheme.softSurface(context),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: NoorTheme.border(context)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                                minimumSize: const Size(48, 48)),
                            onPressed: _saveJournal,
                            icon: const Icon(Icons.edit_note_outlined),
                            label: const Text('Save Journal Entry'),
                          ),
                        ),
                        if (_entries.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          for (final e in _entries.take(5))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: NoorTheme.softSurface(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${e['date'] ?? ''}',
                                        style: NoorType.eyebrow.copyWith(
                                            color: NoorTheme.accent(context))),
                                    const SizedBox(height: 4),
                                    Text('${e['text'] ?? ''}',
                                        style: NoorType.secondary),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

