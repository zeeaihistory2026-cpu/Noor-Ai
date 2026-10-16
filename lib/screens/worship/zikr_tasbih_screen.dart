import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../data/firebase_rest_service.dart';
import '../../data/noor_store.dart';
import '../../data/user_data_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../library/dua_library_screen.dart';

/// Represents a Dhikr / Remembrance entry.
class DhikrModel {
  final String id;
  final String arabic;
  final String transliteration;
  final String meaning;
  final int defaultTarget;
  final String? reference;
  final String category; // 'tasbih', 'morning', 'evening', 'salah', 'custom'

  const DhikrModel({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.defaultTarget = 33,
    this.reference,
    this.category = 'tasbih',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'arabic': arabic,
    'transliteration': transliteration,
    'meaning': meaning,
    'defaultTarget': defaultTarget,
    'reference': reference,
    'category': category,
  };

  factory DhikrModel.fromMap(Map<String, dynamic> map) => DhikrModel(
    id: map['id']?.toString() ?? '',
    arabic: map['arabic']?.toString() ?? '',
    transliteration: map['transliteration']?.toString() ?? '',
    meaning: map['meaning']?.toString() ?? '',
    defaultTarget: (map['defaultTarget'] as num?)?.toInt() ?? 33,
    reference: map['reference']?.toString(),
    category: map['category']?.toString() ?? 'custom',
  );
}

/// Page 07 — Zikr & Tasbih Screen.
/// Provides an authentic, beautifully styled digital Tasbih counter with:
/// - Exact geometric bead painter (no distortion or spiral collapse)
/// - 3 fully functional tabs: Tasbih, Daily Adhkar, My Zikr
/// - Proper Material & Scaffold ancestor (eliminating yellow underlines & black background)
/// - Responsive target chips (33, 66, 99, 100, and functional Custom target dialog)
/// - Interactive Dhikr cards with Arabic calligraphy, transliteration, and translation
/// - Balanced Today's Progress card and styled Daily Tip
class ZikrTasbihScreen extends StatefulWidget {
  final int initialTab;
  final String? initialDhikrId;
  final DhikrModel? initialCustomDhikr;

  const ZikrTasbihScreen({
    super.key,
    this.initialTab = 0,
    this.initialDhikrId,
    this.initialCustomDhikr,
  });

  @override
  State<ZikrTasbihScreen> createState() => _ZikrTasbihScreenState();
}

class _ZikrTasbihScreenState extends State<ZikrTasbihScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0; // 0: Tasbih, 1: Daily Adhkar, 2: My Zikr
  int _count = 27;
  int _target = 33;
  int _totalToday = 164;
  final int _sessionsToday = 3;
  bool _hapticEnabled = true;
  String _firstName = '';

  // Current active dhikr in Tasbih counter
  late DhikrModel _activeDhikr;

  // Animation controller for counter tap bounce
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  // Preset Dhikr collection
  static const List<DhikrModel> _tasbihDhikrs = [
    DhikrModel(
      id: 'subhanallah',
      arabic: 'سُبْحَانَ ٱللَّٰهِ',
      transliteration: 'SubhanAllah',
      meaning: 'Glory be to Allah',
      defaultTarget: 33,
      reference: 'Sahih Muslim 597',
    ),
    DhikrModel(
      id: 'alhamdulillah',
      arabic: 'ٱلْحَمْدُ لِلَّٰهِ',
      transliteration: 'Alhamdulillah',
      meaning: 'All praise is for Allah',
      defaultTarget: 33,
      reference: 'Sahih Muslim 597',
    ),
    DhikrModel(
      id: 'allahuakbar',
      arabic: 'ٱللَّٰهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      meaning: 'Allah is the Greatest',
      defaultTarget: 33,
      reference: 'Sahih Muslim 597',
    ),
    DhikrModel(
      id: 'lailahaillallah',
      arabic: 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      transliteration: 'La ilaha illa Allah',
      meaning: 'There is no deity worthy of worship except Allah',
      defaultTarget: 100,
      reference: 'Sahih al-Bukhari 6403',
    ),
    DhikrModel(
      id: 'astaghfirullah',
      arabic: 'أَسْتَغْفِرُ ٱللَّٰهَ',
      transliteration: 'Astaghfirullah',
      meaning: 'I seek forgiveness from Allah',
      defaultTarget: 100,
      reference: 'Sunan Ibn Majah 3817',
    ),
    DhikrModel(
      id: 'subhanallahi_bihamdihi',
      arabic: 'سُبْحَانَ ٱللَّٰهِ وَبِحَمْدِهِ',
      transliteration: 'SubhanAllahi wa bihamdihi',
      meaning: 'Glory be to Allah and His is the praise',
      defaultTarget: 100,
      reference: 'Sahih al-Bukhari 6405',
    ),
    DhikrModel(
      id: 'salawat',
      arabic: 'ٱللَّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
      transliteration: "Allahumma Salli 'ala Muhammad",
      meaning: 'O Allah, send peace and blessings upon Muhammad',
      defaultTarget: 100,
      reference: 'Sunan an-Nasa\'i 1297',
    ),
    DhikrModel(
      id: 'hawqala',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّٰهِ',
      transliteration: 'La hawla wa la quwwata illa billah',
      meaning: 'There is no power nor strength except with Allah',
      defaultTarget: 33,
      reference: 'Sahih al-Bukhari 4205',
    ),
  ];

  // Daily Adhkar items
  static const List<DhikrModel> _dailyAdhkarList = [
    DhikrModel(
      id: 'ayatul_kursi',
      arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
      transliteration: 'Ayat al-Kursi (2:255)',
      meaning: 'Allah! There is no deity except Him, the Ever-Living, the Sustainer of all.',
      defaultTarget: 1,
      reference: 'Morning & Evening Protection',
      category: 'morning',
    ),
    DhikrModel(
      id: 'ikhlas_falaq_nas',
      arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ • الفلق • الناس',
      transliteration: 'Al-Ikhlas, Al-Falaq, An-Nas (3x)',
      meaning: 'Recite each Surah 3 times in morning and evening for sufficient protection.',
      defaultTarget: 3,
      reference: 'Sunan Abu Dawud 5082',
      category: 'morning',
    ),
    DhikrModel(
      id: 'asbahna',
      arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ',
      transliteration: 'Asbahna wa asbahal mulku lillah',
      meaning: 'We have entered a new day and with it all dominion belongs to Allah.',
      defaultTarget: 1,
      reference: 'Sahih Muslim 2723',
      category: 'morning',
    ),
    DhikrModel(
      id: 'sayyid_istighfar',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ...',
      transliteration: 'Sayyid al-Istighfar',
      meaning: 'Master Supplication for Forgiveness — guaranteed Jannah if recited with faith.',
      defaultTarget: 1,
      reference: 'Sahih al-Bukhari 6306',
      category: 'morning',
    ),
    DhikrModel(
      id: 'bismillahillazi',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ',
      transliteration: 'Bismillahil-lazi la yadurru...',
      meaning: 'In the Name of Allah, with Whose Name nothing can cause harm in earth or heaven.',
      defaultTarget: 3,
      reference: 'Sunan Abu Dawud 5088',
      category: 'morning',
    ),
    DhikrModel(
      id: 'raditu_billah',
      arabic: 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا',
      transliteration: 'Raditu billahi Rabba...',
      meaning: 'I am pleased with Allah as my Lord, Islam as my religion, and Muhammad as my Prophet.',
      defaultTarget: 3,
      reference: 'Sunan Abu Dawud 5072',
      category: 'morning',
    ),
  ];

  // User's custom dhikr items
  final List<DhikrModel> _customDhikrs = [
    const DhikrModel(
      id: 'custom_hasbunallah',
      arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      transliteration: "Hasbunallahu wa ni'mal wakeel",
      meaning: 'Allah is sufficient for us, and He is the best disposer of affairs.',
      defaultTarget: 100,
      reference: 'Surah Ali \'Imran 3:173',
      category: 'custom',
    ),
    const DhikrModel(
      id: 'custom_yunus',
      arabic: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      transliteration: 'Dua of Prophet Yunus (A.S)',
      meaning: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
      defaultTarget: 40,
      reference: 'Surah Al-Anbiya 21:87',
      category: 'custom',
    ),
  ];

  // Track progress for other dhikrs
  final Map<String, int> _countsMap = {
    'subhanallah': 27,
    'alhamdulillah': 33,
    'allahuakbar': 21,
    'lailahaillallah': 0,
    'astaghfirullah': 45,
    'ayatul_kursi': 1,
    'ikhlas_falaq_nas': 2,
    'asbahna': 1,
    'sayyid_istighfar': 0,
    'bismillahillazi': 3,
    'raditu_billah': 3,
    'custom_hasbunallah': 50,
    'custom_yunus': 15,
  };

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);

    if (widget.initialCustomDhikr != null) {
      _activeDhikr = widget.initialCustomDhikr!;
      if (!_customDhikrs.any((d) => d.id == _activeDhikr.id)) {
        _customDhikrs.insert(0, _activeDhikr);
      }
      _target = _activeDhikr.defaultTarget;
      _count = 0;
    } else if (widget.initialDhikrId != null) {
      final match = _tasbihDhikrs.firstWhere(
        (d) => d.id == widget.initialDhikrId,
        orElse: () => _tasbihDhikrs[0],
      );
      _activeDhikr = match;
      _target = _activeDhikr.defaultTarget;
      _count = _countsMap[_activeDhikr.id] ?? 27;
    } else {
      _activeDhikr = _tasbihDhikrs[0];
      _target = _activeDhikr.defaultTarget;
      _count = _countsMap[_activeDhikr.id] ?? 27;
    }

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _loadName();
    _loadPersistedState();
  }

  String get _today => DateTime.now().toIso8601String().split('T').first;

  Future<void> _loadPersistedState() async {
    final savedCounts = await NoorStore.getTasbihCounts();
    final customList = await NoorStore.getCustomDhikrs();
    final total = await NoorStore.getTasbihTotalToday(_today);

    if (mounted) {
      setState(() {
        if (savedCounts.isNotEmpty) {
          _countsMap.addAll(savedCounts);
        }
        for (final map in customList) {
          final customDhikr = DhikrModel.fromMap(map);
          if (!_customDhikrs.any((d) => d.id == customDhikr.id)) {
            _customDhikrs.add(customDhikr);
          }
        }
        if (total > 0) {
          _totalToday = total;
        }
        if (_countsMap.containsKey(_activeDhikr.id)) {
          _count = _countsMap[_activeDhikr.id]!;
        }
      });
    }

    // Background sync with cloud if authenticated
    try {
      final cloudTotal = await UserDataService.instance.loadTasbihTotal(_today);
      if (cloudTotal != null && cloudTotal > total && mounted) {
        setState(() => _totalToday = cloudTotal);
        await NoorStore.setTasbihTotalToday(_today, cloudTotal);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _loadName() async {
    try {
      final profile = await FirebaseRestService().currentProfile();
      if (profile != null && mounted && profile.name.trim().isNotEmpty) {
        setState(() {
          _firstName = profile.name.trim().split(RegExp(r'\s+')).first;
        });
      }
    } catch (_) {}
  }

  void _tap() {
    _bounceController.forward().then((_) => _bounceController.reverse());

    if (_hapticEnabled) {
      if (_count + 1 >= _target) {
        HapticFeedback.heavyImpact();
      } else if ((_count + 1) % 33 == 0) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    setState(() {
      if (_count < _target) {
        _count++;
      } else {
        // Lap completion: either cap or loop based on preference
        _count = _target;
      }
      _totalToday++;
      _countsMap[_activeDhikr.id] = _count;
    });

    NoorStore.setTasbihCount(_activeDhikr.id, _count);
    NoorStore.setTasbihTotalToday(_today, _totalToday);
    UserDataService.instance.saveTasbihTotal(_today, _totalToday);

    if (mounted) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        '$_count',
        Directionality.of(context),
      );
    }

    if (_count == _target) {
      if (mounted) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Target of $_target completed for ${_activeDhikr.transliteration}. MashaAllah.',
          Directionality.of(context),
        );
      }
      _showCompletionNotice();
    }
  }

  void _undo() {
    if (_count > 0) {
      if (_hapticEnabled) HapticFeedback.selectionClick();
      setState(() {
        _count--;
        if (_totalToday > 0) _totalToday--;
        _countsMap[_activeDhikr.id] = _count;
      });
      NoorStore.setTasbihCount(_activeDhikr.id, _count);
      NoorStore.setTasbihTotalToday(_today, _totalToday);
      UserDataService.instance.saveTasbihTotal(_today, _totalToday);
      if (mounted) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Undone to $_count',
          Directionality.of(context),
        );
      }
    }
  }

  void _confirmReset() {
    if (_count == 0) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? NoorColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.refresh, color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark),
            const SizedBox(width: 8),
            Text('Reset Counter?', style: NoorType.section.copyWith(color: isDark ? NoorColors.darkTextPrimary : NoorColors.emeraldDark)),
          ],
        ),
        content: Text(
          'Are you sure you want to reset your count of $_count for "${_activeDhikr.transliteration}" back to 0?',
          style: NoorType.body.copyWith(color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NoorColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _reset();
            },
            child: const Text('Reset to 0'),
          ),
        ],
      ),
    );
  }

  void _reset() {
    if (_hapticEnabled) HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
      _countsMap[_activeDhikr.id] = 0;
    });
    NoorStore.setTasbihCount(_activeDhikr.id, 0);
    if (mounted) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Counter reset to 0',
        Directionality.of(context),
      );
    }
  }

  void _selectDhikr(DhikrModel dhikr) {
    setState(() {
      _activeDhikr = dhikr;
      _target = dhikr.defaultTarget;
      _count = _countsMap[dhikr.id] ?? 0;
    });
  }

  void _setTarget(int t) {
    if (_hapticEnabled) HapticFeedback.selectionClick();
    setState(() {
      _target = t;
      if (_count > _target) _count = _target;
    });
  }

  void _showCompletionNotice() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NoorColors.emeraldDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: NoorColors.gold, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Target of $_target reached! MashaAllah.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _reset();
              },
              child: const Text('Reset', style: TextStyle(color: NoorColors.gold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openCustomTargetDialog() {
    final controller = TextEditingController(text: '$_target');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.tune, color: NoorColors.emeraldDark),
            const SizedBox(width: 10),
            Text('Custom Target', style: NoorType.section.copyWith(color: NoorColors.emeraldDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set your preferred remembrance count:', style: NoorType.body.copyWith(color: NoorColors.mutedDark)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: NoorType.display.copyWith(fontSize: 26, color: NoorColors.emeraldDark),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: NoorColors.emeraldMid),
                ),
                suffixText: 'times',
              ),
            ),
            const SizedBox(height: 16),
            Text('Quick Presets', style: NoorType.meta.copyWith(color: NoorColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [50, 70, 500, 1000].map((preset) {
                return ActionChip(
                  label: Text('$preset'),
                  backgroundColor: NoorColors.emeraldSoft,
                  labelStyle: const TextStyle(color: NoorColors.emeraldDark, fontWeight: FontWeight.w700),
                  onPressed: () {
                    controller.text = '$preset';
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: NoorColors.mutedDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NoorColors.emeraldDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              if (parsed != null && parsed > 0 && parsed <= 10000) {
                _setTarget(parsed);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Set Target'),
          ),
        ],
      ),
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NoorColors.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Tasbih Preferences', style: NoorType.section.copyWith(color: NoorColors.emeraldDark)),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: NoorColors.emeraldDark,
                title: const Text('Haptic Vibration Feedback', style: NoorType.body),
                subtitle: Text('Subtle buzz on each bead tap and completion', style: NoorType.meta.copyWith(color: NoorColors.muted)),
                value: _hapticEnabled,
                onChanged: (val) {
                  setSheetState(() => _hapticEnabled = val);
                  setState(() => _hapticEnabled = val);
                },
              ),
              const Divider(color: NoorColors.hairlineSoft),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.refresh, color: NoorColors.emeraldDark),
                title: const Text('Reset Counter to Zero', style: NoorType.body),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _confirmReset();
                  },
                  child: const Text('Reset Now', style: TextStyle(color: NoorColors.error, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _openHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: NoorColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.history, color: NoorColors.emeraldDark),
                const SizedBox(width: 8),
                Text('Today\'s Remembrance Log', style: NoorType.section.copyWith(color: NoorColors.emeraldDark)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: NoorColors.emeraldSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statCol('$_totalToday', 'Total Zikr'),
                  _statCol('$_sessionsToday', 'Sessions'),
                  _statCol('8 Days', 'Current Streak'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Active Adhkar', style: NoorType.meta.copyWith(color: NoorColors.muted)),
            const SizedBox(height: 8),
            ..._tasbihDhikrs.take(4).map((d) {
              final cnt = _countsMap[d.id] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(d.arabic, style: NoorType.arabic(size: 18, color: NoorColors.emeraldDark)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(d.transliteration, style: NoorType.secondary),
                    ),
                    Text('$cnt / ${d.defaultTarget}', style: NoorType.meta.copyWith(color: NoorColors.emeraldDark)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String value, String label) {
    return Column(
      children: [
        Text(value, style: NoorType.section.copyWith(color: NoorColors.emeraldDark, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(label, style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
      ],
    );
  }

  void _openAddCustomDhikrDialog() {
    final arabicCtrl = TextEditingController();
    final transCtrl = TextEditingController();
    final meaningCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Custom Zikr', style: NoorType.section.copyWith(color: NoorColors.emeraldDark)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: arabicCtrl,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'Arabic Text (Optional)',
                  hintText: 'سُبْحَانَ اللَّهِ',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: transCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name / Transliteration *',
                  hintText: 'SubhanAllah',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: meaningCtrl,
                decoration: const InputDecoration(
                  labelText: 'Meaning / Notes',
                  hintText: 'Glory be to Allah',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Count *',
                  hintText: '33',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: NoorColors.mutedDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NoorColors.emeraldDark,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (transCtrl.text.trim().isNotEmpty) {
                final targetVal = int.tryParse(targetCtrl.text.trim()) ?? 33;
                final newDhikr = DhikrModel(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  arabic: arabicCtrl.text.trim().isNotEmpty ? arabicCtrl.text.trim() : 'ذِكْر',
                  transliteration: transCtrl.text.trim(),
                  meaning: meaningCtrl.text.trim(),
                  defaultTarget: targetVal,
                  category: 'custom',
                );
                setState(() {
                  _customDhikrs.add(newDhikr);
                  _countsMap[newDhikr.id] = 0;
                });
                NoorStore.saveCustomDhikr(newDhikr.toMap());
                NoorStore.setTasbihCount(newDhikr.id, 0);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save Zikr'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Crucial: Must be wrapped in Scaffold to avoid un-themed black canvas & yellow underlines
    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Emerald Curved App Bar
            _buildHeader(context),

            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _buildTasbihTab(),
                  _buildDailyAdhkarTab(),
                  _buildMyZikrTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [NoorColors.emeraldDark, NoorColors.emeraldMid],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Back',
              ),
              Expanded(
                child: Text(
                  'Zikr & Tasbih',
                  textAlign: TextAlign.center,
                  style: NoorType.section.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: _openHistorySheet,
                tooltip: 'History',
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Colors.white),
                onPressed: _openHistorySheet,
                tooltip: 'Statistics',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Three Navigation Tabs
          NoorPillTabs(
            tabs: const ['Tasbih', 'Daily Adhkar', 'My Zikr'],
            selected: _tab,
            onSelect: (i) => setState(() => _tab = i),
          ),

          const SizedBox(height: 12),

          // Zikr Streak Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(NoorRadius.card),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: NoorColors.amber,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zikr Streak',
                        style: NoorType.meta.copyWith(color: Colors.white70, fontSize: 11),
                      ),
                      Text(
                        '8 Days',
                        style: NoorType.section.copyWith(color: NoorColors.gold, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _firstName.isNotEmpty ? 'Keep going, $_firstName!' : 'Keep going, consistency brings light!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NoorType.meta.copyWith(color: Colors.white70, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                          .asMap()
                          .entries
                          .map((e) => Padding(
                                padding: const EdgeInsetsDirectional.only(start: 3),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      e.value,
                                      textAlign: TextAlign.center,
                                      style: NoorType.meta.copyWith(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Icon(
                                      e.key < 6 ? Icons.check_circle : Icons.radio_button_unchecked,
                                      size: 14,
                                      color: e.key < 6 ? NoorColors.success : Colors.white38,
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 0: MAIN TASBIH COUNTER =================
  Widget _buildTasbihTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Dhikr Title & Arabic Calligraphy
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _smallIconButton(Icons.tune, onTap: _openSettingsSheet, tooltip: 'Settings'),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Text(
                    _activeDhikr.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: NoorType.arabic(size: 26, color: NoorColors.emeraldDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _activeDhikr.transliteration,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NoorType.section.copyWith(color: NoorColors.ink, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _activeDhikr.meaning,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: NoorType.secondary.copyWith(color: NoorColors.mutedDark, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _smallIconButton(Icons.refresh, onTap: _confirmReset, tooltip: 'Reset'),
          ],
        ),

        const SizedBox(height: 18),

        // Tasbih Counter with Outer Beads Ring and Undo / Add Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Undo Button
            Semantics(
              button: true,
              label: 'Undo previous count. Current count is $_count.',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roundBtn(Icons.remove, _undo, tooltip: 'Undo (-1)'),
                  const SizedBox(height: 6),
                  Text('Undo', style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Central Bead Counter
            _buildTasbihCounterRing(),

            const SizedBox(width: 14),

            // Add Button
            Semantics(
              button: true,
              label: 'Add to count. Current count is $_count of $_target.',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roundBtn(Icons.add, _tap, tooltip: 'Add (+1)'),
                  const SizedBox(height: 6),
                  Text('Add', style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Center(
          child: Text(
            'Tap the circle to count',
            style: NoorType.meta.copyWith(color: NoorColors.mutedDark),
          ),
        ),

        const SizedBox(height: 18),

        // Target Chips (33, 66, 99, 100, Custom)
        Row(
          children: [
            for (final t in [33, 66, 99, 100]) ...[
              Expanded(child: _buildTargetChip(t)),
              const SizedBox(width: 6),
            ],
            Expanded(flex: 2, child: _buildCustomChip()),
          ],
        ),

        const SizedBox(height: 24),

        // Other Dhikr Carousel
        Row(
          children: [
            const Expanded(child: NoorSectionLabel('Other Dhikr')),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DuaLibraryScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'View All',
                  style: NoorType.secondary.copyWith(
                    color: NoorColors.emerald,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildOtherDhikrList(),

        const SizedBox(height: 20),

        // Today's Progress Card
        _buildTodayProgressCard(),

        const SizedBox(height: 16),

        // Daily Tip Card
        _buildDailyTipCard(),
      ],
    );
  }

  // Central Tasbih Counter Ring with exact geometry beads
  Widget _buildTasbihCounterRing() {
    const double outerSize = 220.0;
    const double innerSize = 176.0;

    return Semantics(
      button: true,
      liveRegion: true,
      label: 'Tasbih counter, $_count of $_target. Tap to count.',
      value: '$_count of $_target',
      child: GestureDetector(
        onTap: _tap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            width: outerSize,
            height: outerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom Bead Painter with true math.sin & math.cos
                CustomPaint(
                  size: const Size(outerSize, outerSize),
                  painter: _TasbihBeadsPainter(
                    count: _count,
                    target: _target,
                    goldColor: NoorColors.gold,
                    baseColor: NoorColors.emeraldMid.withValues(alpha: 0.4),
                  ),
                ),

                // Center Emerald Disc with Gold Border
                Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [NoorColors.emeraldMid, NoorColors.emeraldDark],
                      stops: [0.3, 1.0],
                    ),
                    border: Border.all(color: NoorColors.gold, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: NoorColors.emeraldDark.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_count',
                            style: NoorType.tabular(
                              NoorType.display.copyWith(
                                fontSize: 52,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '/ $_target',
                              style: NoorType.meta.copyWith(
                                color: NoorColors.goldPale,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (_count >= _target) ...[
                            const SizedBox(height: 4),
                            const Icon(Icons.check_circle, color: NoorColors.gold, size: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetChip(int t) {
    final bool isSelected = _target == t;
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Target $t',
      child: Material(
        color: isSelected ? NoorColors.emeraldDark : Colors.white,
        borderRadius: BorderRadius.circular(NoorRadius.chip),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: () => _setTarget(t),
          borderRadius: BorderRadius.circular(NoorRadius.chip),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NoorRadius.chip),
              border: isSelected ? null : Border.all(color: NoorColors.hairline),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$t',
                style: TextStyle(
                  color: isSelected ? Colors.white : NoorColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip() {
    final bool isCustom = ![33, 66, 99, 100].contains(_target);
    return Material(
      color: isCustom ? NoorColors.emeraldDark : Colors.white,
      borderRadius: BorderRadius.circular(NoorRadius.chip),
      elevation: isCustom ? 2 : 0,
      child: InkWell(
        onTap: _openCustomTargetDialog,
        borderRadius: BorderRadius.circular(NoorRadius.chip),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NoorRadius.chip),
            border: isCustom ? null : Border.all(color: NoorColors.hairline),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isCustom ? 'Custom ($_target)' : 'Custom',
                  maxLines: 1,
                  style: TextStyle(
                    color: isCustom ? Colors.white : NoorColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.edit,
                  size: 13,
                  color: isCustom ? NoorColors.goldPale : NoorColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherDhikrList() {
    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _tasbihDhikrs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final d = _tasbihDhikrs[i];
          final currentCount = _countsMap[d.id] ?? 0;
          final pct = (currentCount / d.defaultTarget).clamp(0.0, 1.0);
          final bool isCurrent = _activeDhikr.id == d.id;

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NoorRadius.card),
            elevation: isCurrent ? 3 : 1,
            child: InkWell(
              onTap: () => _selectDhikr(d),
              borderRadius: BorderRadius.circular(NoorRadius.card),
              child: Container(
                width: 154,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NoorRadius.card),
                  border: Border.all(
                    color: isCurrent ? NoorColors.emerald : NoorColors.hairlineSoft,
                    width: isCurrent ? 1.8 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            d.arabic,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NoorType.arabic(size: 16, color: NoorColors.emeraldDark),
                          ),
                        ),
                        if (pct >= 1.0)
                          const Icon(Icons.check_circle, color: NoorColors.emerald, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d.transliteration,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NoorType.secondary.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      d.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NoorType.meta.copyWith(color: NoorColors.muted, fontSize: 11),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$currentCount / ${d.defaultTarget}', style: NoorType.meta.copyWith(fontSize: 11)),
                        Text('${(pct * 100).toInt()}%', style: NoorType.meta.copyWith(color: NoorColors.emeraldDark, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        color: NoorColors.emerald,
                        backgroundColor: NoorColors.sand,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayProgressCard() {
    return NoorCard(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: NoorSectionLabel("Today's Progress")),
              Text(
                'Total: $_totalToday Zikr',
                style: NoorType.meta.copyWith(color: NoorColors.emeraldDark, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _ProgItem(Icons.sync, '3', 'Sessions')),
              Expanded(child: _ProgItem(Icons.calendar_month, '12 min', 'Duration')),
              Expanded(child: _ProgItem(Icons.bar_chart, '85%', 'Completion')),
              Expanded(child: _ProgItem(Icons.auto_awesome, 'Great', 'MashaAllah!')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard() {
    return Container(
      decoration: BoxDecoration(
        color: NoorColors.emeraldSoft,
        borderRadius: BorderRadius.circular(NoorRadius.heroCard),
        border: Border.all(color: NoorColors.emerald.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: NoorColors.emeraldDark, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Daily Tip',
                      style: NoorType.cardTitle.copyWith(color: NoorColors.emeraldDark, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'The best of people are those who remember Allah the most.',
                  style: NoorType.secondary.copyWith(height: 1.45, color: NoorColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  "Sunan An-Nasa'i 8",
                  style: NoorType.meta.copyWith(color: NoorColors.emeraldDark, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              NoorAssets.salahLantern,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.wb_sunny_outlined, color: NoorColors.emeraldDark, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 1: DAILY ADHKAR =================
  Widget _buildDailyAdhkarTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Adhkar Routine', style: NoorType.section.copyWith(color: NoorColors.emeraldDark)),
                const SizedBox(height: 2),
                Text('Authentic Morning & Evening Remembrances', style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.library_books, color: NoorColors.emeraldDark),
              tooltip: 'Browse Library',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DuaLibraryScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ..._dailyAdhkarList.map((d) {
          final count = _countsMap[d.id] ?? 0;
          final bool isComplete = count >= d.defaultTarget;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(NoorRadius.card),
              border: Border.all(
                color: isComplete ? NoorColors.success.withValues(alpha: 0.5) : NoorColors.hairlineSoft,
              ),
              boxShadow: NoorShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        d.arabic,
                        textDirection: TextDirection.rtl,
                        style: NoorType.arabic(size: 20, color: NoorColors.emeraldDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        if (_hapticEnabled) HapticFeedback.lightImpact();
                        final current = _countsMap[d.id] ?? 0;
                        final next = current + 1 > d.defaultTarget ? d.defaultTarget : current + 1;
                        setState(() {
                          _countsMap[d.id] = next;
                          _totalToday++;
                        });
                        NoorStore.setTasbihCount(d.id, next);
                        NoorStore.setTasbihTotalToday(_today, _totalToday);
                        UserDataService.instance.saveTasbihTotal(_today, _totalToday);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isComplete ? NoorColors.emeraldDark : NoorColors.emeraldSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isComplete ? Icons.check : Icons.touch_app,
                              color: isComplete ? Colors.white : NoorColors.emeraldDark,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$count / ${d.defaultTarget}',
                              style: TextStyle(
                                color: isComplete ? Colors.white : NoorColors.emeraldDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(d.transliteration, style: NoorType.secondary.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(d.meaning, style: NoorType.meta.copyWith(color: NoorColors.mutedDark, height: 1.3)),
                if (d.reference != null) ...[
                  const SizedBox(height: 6),
                  Text(d.reference!, style: NoorType.meta.copyWith(color: NoorColors.emerald, fontSize: 11)),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // ================= TAB 2: MY ZIKR (CUSTOM) =================
  Widget _buildMyZikrTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Custom Zikr', style: NoorType.section.copyWith(color: NoorColors.emeraldDark)),
                  const SizedBox(height: 2),
                  Text('Personal goals & custom remembrances', style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: NoorColors.emeraldDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Zikr'),
              onPressed: _openAddCustomDhikrDialog,
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_customDhikrs.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite_border, color: NoorColors.emerald, size: 40),
                const SizedBox(height: 10),
                const Text('No custom dhikr yet', style: NoorType.cardTitle),
                const SizedBox(height: 4),
                Text('Add your personal wirid or favorite tasbih!', style: NoorType.meta.copyWith(color: NoorColors.muted)),
              ],
            ),
          ),
        ] else ...[
          ..._customDhikrs.map((d) {
            final count = _countsMap[d.id] ?? 0;
            final isComplete = count >= d.defaultTarget;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NoorRadius.card),
                border: Border.all(
                  color: isComplete ? NoorColors.success.withValues(alpha: 0.5) : NoorColors.hairlineSoft,
                ),
                boxShadow: NoorShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          d.arabic,
                          textDirection: TextDirection.rtl,
                          style: NoorType.arabic(size: 20, color: NoorColors.emeraldDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          if (_hapticEnabled) HapticFeedback.lightImpact();
                          final current = _countsMap[d.id] ?? 0;
                          final next = current + 1 > d.defaultTarget ? d.defaultTarget : current + 1;
                          setState(() {
                            _countsMap[d.id] = next;
                            _totalToday++;
                          });
                          NoorStore.setTasbihCount(d.id, next);
                          NoorStore.setTasbihTotalToday(_today, _totalToday);
                          UserDataService.instance.saveTasbihTotal(_today, _totalToday);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isComplete ? NoorColors.emeraldDark : NoorColors.emeraldSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$count / ${d.defaultTarget}',
                            style: TextStyle(
                              color: isComplete ? Colors.white : NoorColors.emeraldDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(d.transliteration, style: NoorType.secondary.copyWith(fontWeight: FontWeight.w700)),
                  if (d.meaning.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(d.meaning, style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: NoorColors.mutedDark),
                        tooltip: 'Delete custom zikr',
                        onPressed: () async {
                          setState(() {
                            _customDhikrs.removeWhere((item) => item.id == d.id);
                            _countsMap.remove(d.id);
                          });
                          await NoorStore.deleteCustomDhikr(d.id);
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text('Count in Tasbih'),
                        onPressed: () {
                          _selectDhikr(d);
                          setState(() => _tab = 0);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // Round Action Button (Undo / Add)
  Widget _roundBtn(IconData icon, VoidCallback onTap, {required String tooltip}) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: NoorColors.ink, size: 22),
          ),
        ),
      ),
    );
  }

  // Small Square Icon Button (Tune / Refresh)
  Widget _smallIconButton(IconData icon, {required VoidCallback onTap, required String tooltip}) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NoorColors.hairline),
            ),
            child: Icon(icon, color: NoorColors.emeraldDark, size: 20),
          ),
        ),
      ),
    );
  }
}

/// Custom Painter for Tasbih beads using exact trigonometry (`math.sin` & `math.cos`).
/// - Targets <= 33: Renders 33 distinct beads with golden glow for counted beads.
/// - Targets <= 66: Renders 66 refined, properly spaced beads.
/// - Targets > 66: Renders an elegant continuous gold progress sweep with milestone bead indicators.
class _TasbihBeadsPainter extends CustomPainter {
  final int count;
  final int target;
  final Color goldColor;
  final Color baseColor;

  _TasbihBeadsPainter({
    required this.count,
    required this.target,
    required this.goldColor,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    if (target <= 66) {
      // Discrete Bead Rendering
      final int totalBeads = target;
      final double beadRadius = totalBeads <= 33 ? 5.5 : 3.8;

      for (int i = 0; i < totalBeads; i++) {
        // Start from 12 o'clock (-pi/2) and rotate clockwise
        final double angle = (i / totalBeads) * 2 * math.pi - (math.pi / 2);
        final double bx = center.dx + radius * math.cos(angle);
        final double by = center.dy + radius * math.sin(angle);
        final beadCenter = Offset(bx, by);

        final bool isCounted = i < count;
        final bool isCurrentHead = i == count - 1;

        if (isCounted) {
          // Counted Bead: Filled Gold with slight shadow
          final paint = Paint()
            ..color = goldColor
            ..style = PaintingStyle.fill;
          canvas.drawCircle(beadCenter, isCurrentHead ? beadRadius + 1.5 : beadRadius, paint);

          // Subtle inner gleam
          final gleamPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.5)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(beadCenter.dx - 1.2, beadCenter.dy - 1.2),
            beadRadius * 0.35,
            gleamPaint,
          );
        } else {
          // Uncounted Bead: Emerald border with translucent center
          final fillPaint = Paint()
            ..color = baseColor
            ..style = PaintingStyle.fill;
          canvas.drawCircle(beadCenter, beadRadius, fillPaint);

          final borderPaint = Paint()
            ..color = goldColor.withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawCircle(beadCenter, beadRadius, borderPaint);
        }
      }
    } else {
      // High-Count Targets (> 66): Circular arc track + Gold progress sweep + Milestone beads
      final trackPaint = Paint()
        ..color = baseColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0;
      canvas.drawCircle(center, radius, trackPaint);

      final double progress = (count / target).clamp(0.0, 1.0);
      if (progress > 0) {
        final progressPaint = Paint()
          ..color = goldColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 6.0;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          progress * 2 * math.pi,
          false,
          progressPaint,
        );

        // Active bead head at the tip
        final double headAngle = progress * 2 * math.pi - (math.pi / 2);
        final headX = center.dx + radius * math.cos(headAngle);
        final headY = center.dy + radius * math.sin(headAngle);
        final headCenter = Offset(headX, headY);

        final headPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(headCenter, 6.0, headPaint);

        final headBorder = Paint()
          ..color = goldColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(headCenter, 6.0, headBorder);
      }

      // 4 Quarter milestone tick marks
      for (int m = 0; m < 4; m++) {
        final double mAngle = (m / 4.0) * 2 * math.pi - (math.pi / 2);
        final mx = center.dx + radius * math.cos(mAngle);
        final my = center.dy + radius * math.sin(mAngle);
        final tickPaint = Paint()
          ..color = goldColor.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(mx, my), 3.0, tickPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TasbihBeadsPainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.target != target ||
        oldDelegate.goldColor != goldColor;
  }
}

/// Helper component for Today's Progress row items with soft wrap and auto-scaling
class _ProgItem extends StatelessWidget {
  const _ProgItem(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: NoorColors.emeraldDark, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: NoorType.section.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: NoorType.meta.copyWith(color: NoorColors.mutedDark, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
