import 'package:flutter/material.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'madhhab_preference_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key, this.editing = false});
  final bool editing;
  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  static const options = [
    ('English', 'English'),
    ('اردو', 'Urdu'),
    ('العربية', 'Arabic')
  ];
  int _selected = 0;
  bool _edited = false, _loading = true, _saving = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final language = await NoorStore.getLanguage();
    final index = options.indexWhere((item) => item.$2 == language);
    if (mounted) {
      setState(() {
        if (!_edited && index >= 0) _selected = index;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    await NoorStore.setLanguage(options[_selected].$2);
    if (!mounted) return;
    if (widget.editing) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MadhhabPreferenceScreen()));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Reading language')),
        body: SafeArea(
            child: ListView(padding: const EdgeInsets.all(24), children: [
          const Text('Read in your language', style: NoorType.screenTitle),
          const SizedBox(height: 10),
          const Text(
              'Sets the Quran Reader’s default language. App menus stay in English.',
              style: NoorType.secondary),
          const SizedBox(height: 24),
          for (int i = 0; i < options.length; i++) ...[
            NoorOptionTile(
                label: options[i].$1,
                sublabel: options[i].$2,
                labelStyle: i == 1
                    ? NoorType.urdu(size: 18)
                    : i == 2
                        ? NoorType.arabic(size: 22)
                        : null,
                selected: i == _selected,
                trailing: NoorRadioDot(selected: i == _selected),
                onTap: () {
                  if (!_saving) {
                    setState(() {
                      _edited = true;
                      _selected = i;
                    });
                  }
                }),
            const SizedBox(height: 12),
          ],
        ])),
        bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: FilledButton(
                    onPressed: _saving || _loading ? null : _save,
                    child: Text(_saving
                        ? 'Saving…'
                        : widget.editing
                            ? 'Save language'
                            : 'Continue')))),
      );
}
