import 'package:flutter/material.dart';
import '../../data/noor_controller.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';

class PrayerSettingsScreen extends StatefulWidget {
  const PrayerSettingsScreen({super.key});
  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  static const methods = {
    1: 'University of Islamic Sciences, Karachi',
    2: 'ISNA (North America)',
    3: 'Muslim World League',
    4: 'Umm al-Qura, Makkah',
    5: 'Egyptian General Authority',
    7: 'Tehran',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Singapore',
    12: 'France',
    13: 'Turkey'
  };
  int _method = 1;
  String _madhhab = 'Hanafi';
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final method = await NoorStore.getCalculationMethod();
    final madhhab = await NoorStore.getMadhhab();
    if (mounted) {
      setState(() {
        _method = methods.containsKey(method) ? method : 1;
        _madhhab = madhhab == 'Hanafi' ? 'Hanafi' : 'Standard';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    await NoorStore.setCalculationMethod(_method);
    await NoorStore.setMadhhab(_madhhab == 'Hanafi' ? 'Hanafi' : 'Shafi');
    if (!mounted) return;
    await NoorScope.read(context)?.loadLocation();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prayer times and reminders updated.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Prayer Settings')),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const Text('Match your local timetable', style: NoorType.screenTitle),
          const SizedBox(height: 12),
          const Text(
              'Choose the calculation method used in your area. Times are calculated for the city selected in Settings → Location. Follow your local mosque when its timetable differs.'),
          const SizedBox(height: 28),
          DropdownButtonFormField<int>(
            initialValue: _method,
            isExpanded: true,
            key: ValueKey('method-$_method-$_loading'),
            decoration: const InputDecoration(
                labelText: 'Calculation method', border: OutlineInputBorder()),
            items: methods.entries
                .map((entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value,
                        maxLines: 2, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged:
                _loading ? null : (value) => setState(() => _method = value!),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _madhhab,
            isExpanded: true,
            key: ValueKey('asr-$_madhhab-$_loading'),
            decoration: const InputDecoration(
                labelText: 'Asr convention', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(
                  value: 'Hanafi', child: Text('Hanafi (later Asr)')),
              DropdownMenuItem(
                  value: 'Standard', child: Text('Shafi / Maliki / Hanbali'))
            ],
            onChanged:
                _loading ? null : (value) => setState(() => _madhhab = value!),
          ),
          const SizedBox(height: 24),
          const Text(
              'Prayer times refresh online when possible and use astronomical calculations offline. Android reminders are scheduled seven days ahead; reopen the app weekly to refresh them.'),
          const SizedBox(height: 28),
          FilledButton(
              onPressed: _loading ? null : _save,
              child: Text(_loading ? 'Updating…' : 'Save prayer settings')),
        ]),
      );
}
