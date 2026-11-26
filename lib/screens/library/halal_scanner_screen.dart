import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/halal_database.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Module 14 P2/P3 — Halal Food Checker & Scanner:
/// Instant offline ingredient & E-number analysis, EAN/UPC barcode lookup via
/// OpenFoodFacts (with offline samples), and a searchable E-number reference.
class HalalScannerScreen extends StatefulWidget {
  const HalalScannerScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<HalalScannerScreen> createState() => _HalalScannerScreenState();
}

class _HalalScannerScreenState extends State<HalalScannerScreen> {
  late int _tab;
  final _ingredientCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _eSearchCtrl = TextEditingController();

  HalalAnalysisResult? _analysis;
  BarcodeLookupResult? _barcodeResult;
  bool _lookingUpBarcode = false;
  HalalVerdict? _eFilter;
  List<Map<String, dynamic>> _history = const [];

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);
    _loadHistory();
  }

  @override
  void dispose() {
    _ingredientCtrl.dispose();
    _barcodeCtrl.dispose();
    _eSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final h = await NoorStore.getHalalScanHistory();
    if (!mounted) return;
    setState(() => _history = h);
  }

  Future<void> _runIngredientCheck({String? presetTitle}) async {
    final text = _ingredientCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    final res = HalalDatabase.analyzeIngredients(text);
    setState(() => _analysis = res);
    await NoorStore.addHalalScanRecord({
      'title': presetTitle ?? 'Ingredient Check',
      'verdict': res.overallVerdict.name,
      'summary': res.summary,
      'date': DateTime.now().toIso8601String().split('T').first,
    });
    await _loadHistory();
  }

  Future<void> _lookupBarcode([String? preset]) async {
    if (preset != null) {
      _barcodeCtrl.text = preset;
    }
    final code = _barcodeCtrl.text.trim();
    if (code.isEmpty || _lookingUpBarcode) return;
    setState(() => _lookingUpBarcode = true);
    final res = await HalalDatabase.lookupBarcode(code);
    if (!mounted) return;
    setState(() {
      _lookingUpBarcode = false;
      _barcodeResult = res;
    });
    if (res.found) {
      await NoorStore.addHalalScanRecord({
        'title': res.productName,
        'verdict': res.analysis.overallVerdict.name,
        'summary': 'Barcode ${res.barcode}: ${res.analysis.summary}',
        'date': DateTime.now().toIso8601String().split('T').first,
      });
      await _loadHistory();
    }
  }

  Color _verdictColor(BuildContext context, HalalVerdict v) {
    switch (v) {
      case HalalVerdict.halal:
        return NoorTheme.accent(context);
      case HalalVerdict.doubtful:
        return Theme.of(context).brightness == Brightness.dark
            ? NoorColors.darkGold
            : NoorColors.goldDeep;
      case HalalVerdict.haram:
        return Theme.of(context).brightness == Brightness.dark
            ? NoorColors.errorOnDark
            : NoorColors.error;
    }
  }

  String _verdictLabel(HalalVerdict v) {
    switch (v) {
      case HalalVerdict.halal:
        return 'HALAL SCREEN PASSED';
      case HalalVerdict.doubtful:
        return 'MUSHBOOH (VERIFY SOURCE)';
      case HalalVerdict.haram:
        return 'HARAM / FLAGGED INGREDIENT';
    }
  }

  IconData _verdictIcon(HalalVerdict v) {
    switch (v) {
      case HalalVerdict.halal:
        return Icons.verified_outlined;
      case HalalVerdict.doubtful:
        return Icons.help_outline;
      case HalalVerdict.haram:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            NoorDarkHeader(
              title: 'Halal Food Checker',
              subtitle: 'Ingredients, barcode & E-number verification',
              child: NoorPillTabs(
                tabs: const ['Ingredients', 'Barcode', 'E-Numbers'],
                selected: _tab,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _buildIngredientsTab(),
                  _buildBarcodeTab(),
                  _buildENumbersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        NoorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NoorSectionLabel('Paste Ingredients or E-Numbers'),
              const SizedBox(height: 8),
              Text(
                'Check any product label offline against Halal, Mushbooh (doubtful), and Haram additive rules.',
                style: NoorType.meta.copyWith(color: NoorTheme.muted(context)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ingredientCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Sugar, Gelatin, Mono- and diglycerides (E471), Citric acid (E330)...',
                  filled: true,
                  fillColor: NoorTheme.softSurface(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: NoorTheme.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: NoorTheme.border(context)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: () => _runIngredientCheck(),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Analyze Ingredients'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'QUICK TEST LABELS',
                style: NoorType.eyebrow.copyWith(color: NoorTheme.muted(context)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sample in HalalDatabase.sampleLabels)
                    ActionChip(
                      label: Text(sample.name),
                      onPressed: () {
                        _ingredientCtrl.text = sample.text;
                        _runIngredientCheck(presetTitle: sample.name);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        if (_analysis != null) ...[
          const SizedBox(height: 16),
          _analysisCard(_analysis!),
        ],
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 16),
          NoorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NoorSectionLabel('Recent Checks'),
                const SizedBox(height: 8),
                for (final item in _history.take(5))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${item['date']} • ${item['title']} (${item['verdict']})',
                      style: NoorType.meta.copyWith(color: NoorTheme.muted(context)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _analysisCard(HalalAnalysisResult res) {
    final c = _verdictColor(context, res.overallVerdict);
    return NoorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c),
            ),
            child: Row(
              children: [
                Icon(_verdictIcon(res.overallVerdict), color: c, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _verdictLabel(res.overallVerdict),
                        style: NoorType.eyebrow.copyWith(color: c),
                      ),
                      const SizedBox(height: 4),
                      Text(res.summary, style: NoorType.secondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < res.findings.length; i++) ...[
            if (i > 0) Divider(height: 16, color: NoorTheme.border(context)),
            Builder(builder: (context) {
              final f = res.findings[i];
              final fc = _verdictColor(context, f.verdict);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_verdictIcon(f.verdict), color: fc, size: 19),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.token, style: NoorType.cardTitle),
                        const SizedBox(height: 2),
                        Text(f.reason,
                            style: NoorType.meta
                                .copyWith(color: NoorTheme.muted(context))),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBarcodeTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        NoorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NoorSectionLabel('Product Barcode Lookup (EAN / UPC)'),
              const SizedBox(height: 8),
              Text(
                'Enter the printed product digits to fetch product ingredients from OpenFoodFacts (online) or test offline sample barcodes.',
                style: NoorType.meta.copyWith(color: NoorTheme.muted(context)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _barcodeCtrl,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _lookupBarcode(),
                decoration: InputDecoration(
                  hintText: 'Enter barcode digits (e.g. 3017620422003)',
                  prefixIcon: const Icon(Icons.qr_code_2_outlined),
                  filled: true,
                  fillColor: NoorTheme.softSurface(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: NoorTheme.border(context)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: _lookingUpBarcode ? null : () => _lookupBarcode(),
                  icon: _lookingUpBarcode
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_lookingUpBarcode ? 'Looking up...' : 'Check Barcode'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'SAMPLE TEST BARCODES',
                style: NoorType.eyebrow.copyWith(color: NoorTheme.muted(context)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in HalalDatabase.sampleBarcodes)
                    ActionChip(
                      label: Text('${s.name.split('(').first.trim()} (${s.barcode})'),
                      onPressed: () => _lookupBarcode(s.barcode),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (_barcodeResult != null) ...[
          const SizedBox(height: 16),
          if (!_barcodeResult!.found)
            NoorCard(
              color: NoorTheme.warmSurface(context),
              child: Text(
                _barcodeResult!.errorMessage ?? 'Product not found.',
                style: NoorType.body,
              ),
            )
          else ...[
            NoorCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(_barcodeResult!.productName,
                            style: NoorType.cardTitle),
                      ),
                      Chip(
                        label: Text(
                            _barcodeResult!.isLive ? 'OpenFoodFacts' : 'Sample'),
                      ),
                    ],
                  ),
                  if (_barcodeResult!.brand.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(_barcodeResult!.brand,
                        style: NoorType.meta
                            .copyWith(color: NoorTheme.muted(context))),
                  ],
                  if (_barcodeResult!.ingredientsText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Ingredients:',
                        style: NoorType.eyebrow
                            .copyWith(color: NoorTheme.accent(context))),
                    const SizedBox(height: 4),
                    Text(_barcodeResult!.ingredientsText,
                        style: NoorType.secondary),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _analysisCard(_barcodeResult!.analysis),
          ],
        ],
      ],
    );
  }

  Widget _buildENumbersTab() {
    final q = _eSearchCtrl.text.trim().toLowerCase();
    final filtered = HalalDatabase.eNumbers.where((e) {
      if (_eFilter != null && e.verdict != _eFilter) return false;
      if (q.isEmpty) return true;
      return e.code.toLowerCase().contains(q) ||
          e.name.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          e.explanation.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        TextField(
          controller: _eSearchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search E-number or name (e.g. E471, Carmine, Gelatin)...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: NoorTheme.surface(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: NoorTheme.border(context)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text('All (${HalalDatabase.eNumbers.length})'),
              selected: _eFilter == null,
              onSelected: (_) => setState(() => _eFilter = null),
            ),
            ChoiceChip(
              label: const Text('Halal'),
              selected: _eFilter == HalalVerdict.halal,
              onSelected: (_) => setState(() => _eFilter = HalalVerdict.halal),
            ),
            ChoiceChip(
              label: const Text('Doubtful'),
              selected: _eFilter == HalalVerdict.doubtful,
              onSelected: (_) => setState(() => _eFilter = HalalVerdict.doubtful),
            ),
            ChoiceChip(
              label: const Text('Haram / Avoid'),
              selected: _eFilter == HalalVerdict.haram,
              onSelected: (_) => setState(() => _eFilter = HalalVerdict.haram),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final entry in filtered) ...[
          NoorCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _verdictColor(context, entry.verdict)
                        .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: _verdictColor(context, entry.verdict)),
                  ),
                  child: Text(
                    entry.code,
                    style: NoorType.tabular(NoorType.meta.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _verdictColor(context, entry.verdict),
                    )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.name} · ${entry.category}',
                          style: NoorType.cardTitle),
                      const SizedBox(height: 4),
                      Text(entry.explanation,
                          style: NoorType.meta
                              .copyWith(color: NoorTheme.muted(context))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        NoorCard(
          color: NoorTheme.warmSurface(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NoorSectionLabel('Halal Shopping & Certification Guide'),
              const SizedBox(height: 8),
              for (final tip in HalalDatabase.shoppingGuideTips) ...[
                Text(tip.title, style: NoorType.cardTitle),
                const SizedBox(height: 2),
                Text(tip.detail,
                    style:
                        NoorType.meta.copyWith(color: NoorTheme.muted(context))),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

