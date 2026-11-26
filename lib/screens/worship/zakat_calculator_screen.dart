import 'package:flutter/material.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Module 12 P1/P2 — Interactive Zakat & Sadaqah Tools:
/// Cash/Savings, Gold, Silver, Investments/Business, Debts deductible,
/// Gold/Silver Nisab threshold calculator, and saved Zakat/Sadaqah log.
class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _cashCtrl = TextEditingController();
  final _goldGramsCtrl = TextEditingController();
  final _silverGramsCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _debtsCtrl = TextEditingController();
  final _goldPriceCtrl = TextEditingController(text: '85');
  final _silverPriceCtrl = TextEditingController(text: '1.05');
  final _sadaqahCtrl = TextEditingController();

  String _currency = 'USD';
  bool _useSilverNisab = true;
  List<Map<String, dynamic>> _zakatHistory = const [];
  List<Map<String, dynamic>> _sadaqahHistory = const [];

  static const double goldNisabGrams = 87.48;
  static const double silverNisabGrams = 612.36;
  static const List<String> currencies = [
    'USD',
    'PKR',
    'GBP',
    'EUR',
    'SAR',
    'AED',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    _goldGramsCtrl.dispose();
    _silverGramsCtrl.dispose();
    _businessCtrl.dispose();
    _debtsCtrl.dispose();
    _goldPriceCtrl.dispose();
    _silverPriceCtrl.dispose();
    _sadaqahCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final z = await NoorStore.getZakatHistory();
    final s = await NoorStore.getSadaqahHistory();
    if (mounted) {
      setState(() {
        _zakatHistory = z;
        _sadaqahHistory = s;
      });
    }
  }

  double _val(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', ''))?.clamp(0, 1e12) ?? 0;

  double get _goldPrice => _val(_goldPriceCtrl);
  double get _silverPrice => _val(_silverPriceCtrl);
  double get _goldValue => _val(_goldGramsCtrl) * _goldPrice;
  double get _silverValue => _val(_silverGramsCtrl) * _silverPrice;

  double get _netZakatable {
    final gross = _val(_cashCtrl) +
        _goldValue +
        _silverValue +
        _val(_businessCtrl);
    return (gross - _val(_debtsCtrl)).clamp(0, 1e12);
  }

  double get _nisabThreshold => _useSilverNisab
      ? silverNisabGrams * _silverPrice
      : goldNisabGrams * _goldPrice;

  bool get _aboveNisab => _nisabThreshold > 0 && _netZakatable >= _nisabThreshold;
  double get _zakatDue => _aboveNisab ? _netZakatable * 0.025 : 0;

  Future<void> _saveZakatCalculation() async {
    await NoorStore.addZakatRecord({
      'currency': _currency,
      'net': _netZakatable,
      'zakat': _zakatDue,
      'nisabBasis': _useSilverNisab ? 'Silver (612.36g)' : 'Gold (87.48g)',
      'date': DateTime.now().toIso8601String().split('T').first,
    });
    await _loadHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zakat calculation saved to history.')),
      );
    }
  }

  Future<void> _logSadaqah() async {
    final amount = _val(_sadaqahCtrl);
    if (amount <= 0) return;
    await NoorStore.addSadaqahRecord({
      'currency': _currency,
      'amount': amount,
      'date': DateTime.now().toIso8601String().split('T').first,
    });
    _sadaqahCtrl.clear();
    await _loadHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sadaqah entry saved privately.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            const NoorDarkHeader(
              title: 'Zakat & Sadaqah',
              subtitle: '2.5% annual calculation & Nisab check',
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
                        Text('ESTIMATED ZAKAT DUE (2.5%)',
                            style: NoorType.eyebrow
                                .copyWith(color: NoorColors.onEmeraldMuted)),
                        const SizedBox(height: 8),
                        Text(
                          '$_currency ${_zakatDue.toStringAsFixed(2)}',
                          style: NoorType.tabular(NoorType.hero(
                              size: 32, color: NoorColors.gold)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Net zakatable wealth: $_currency ${_netZakatable.toStringAsFixed(2)}',
                          style: NoorType.tabular(NoorType.secondary
                              .copyWith(color: Colors.white)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _nisabThreshold <= 0
                              ? 'Enter current gold or silver rate below to evaluate Nisab.'
                              : _aboveNisab
                                  ? 'Above Nisab ($_currency ${_nisabThreshold.toStringAsFixed(2)}) — Zakat applies if held for 1 lunar year (Hawl).'
                                  : 'Below Nisab ($_currency ${_nisabThreshold.toStringAsFixed(2)}) — obligatory Zakat is not due.',
                          style: NoorType.meta
                              .copyWith(color: NoorColors.onEmeraldMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NoorSectionLabel('Currency & Nisab Standard'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in currencies)
                              ChoiceChip(
                                label: Text(c),
                                selected: _currency == c,
                                onSelected: (_) =>
                                    setState(() => _currency = c),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Silver Nisab (612.36g)'),
                              selected: _useSilverNisab,
                              onSelected: (_) =>
                                  setState(() => _useSilverNisab = true),
                            ),
                            ChoiceChip(
                              label: const Text('Gold Nisab (87.48g)'),
                              selected: !_useSilverNisab,
                              onSelected: (_) =>
                                  setState(() => _useSilverNisab = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                context,
                                controller: _goldPriceCtrl,
                                label: 'Gold / g ($_currency)',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
                                context,
                                controller: _silverPriceCtrl,
                                label: 'Silver / g ($_currency)',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NoorSectionLabel('Zakatable Assets & Liabilities'),
                        const SizedBox(height: 12),
                        _numField(
                          context,
                          controller: _cashCtrl,
                          label: 'Cash & Bank Savings ($_currency)',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                context,
                                controller: _goldGramsCtrl,
                                label: 'Gold owned (grams)',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
                                context,
                                controller: _silverGramsCtrl,
                                label: 'Silver owned (grams)',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _numField(
                          context,
                          controller: _businessCtrl,
                          label: 'Business Inventory & Investments ($_currency)',
                        ),
                        const SizedBox(height: 12),
                        _numField(
                          context,
                          controller: _debtsCtrl,
                          label: 'Immediate Debts Due ($_currency)',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saveZakatCalculation,
                            icon: const Icon(Icons.bookmark_add_outlined),
                            label: const Text('Save Calculation'),
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
                        const NoorSectionLabel('Private Sadaqah Tracker'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                context,
                                controller: _sadaqahCtrl,
                                label: 'Sadaqah amount ($_currency)',
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              onPressed: _logSadaqah,
                              child: const Text('Log'),
                            ),
                          ],
                        ),
                        if (_sadaqahHistory.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          for (final item in _sadaqahHistory.take(5))
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${item['date']} • ${item['currency']} ${(item['amount'] as num).toStringAsFixed(2)}',
                                style: NoorType.tabular(NoorType.meta),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  if (_zakatHistory.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    NoorCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const NoorSectionLabel('Saved Zakat History'),
                          const SizedBox(height: 8),
                          for (final rec in _zakatHistory.take(5)) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${rec['date']} • ${rec['currency']} ${(rec['zakat'] as num).toStringAsFixed(2)} (${rec['nisabBasis']})',
                              style: NoorType.tabular(NoorType.secondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  NoorCard(
                    color: NoorTheme.warmSurface(context),
                    child: Text(
                      'Update the gold and silver prices per gram to your local market rate. Complex business, agricultural, or inheritance rulings should be verified with a qualified scholar.',
                      style: NoorType.meta
                          .copyWith(color: NoorTheme.muted(context)),
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

  Widget _numField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
  }) =>
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: NoorTheme.surface(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: NoorTheme.border(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: NoorTheme.border(context)),
          ),
        ),
      );
}

