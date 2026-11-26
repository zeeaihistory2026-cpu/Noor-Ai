import 'dart:convert';
import 'package:http/http.dart' as http;

/// Curated offline Halal food & E-number analyzer (Module 14: P2/P3)
/// paired with optional live OpenFoodFacts barcode lookup.
enum HalalVerdict {
  halal,
  doubtful,
  haram,
}

class ENumberEntry {
  const ENumberEntry({
    required this.code,
    required this.name,
    required this.category,
    required this.verdict,
    required this.explanation,
  });

  final String code;
  final String name;
  final String category;
  final HalalVerdict verdict;
  final String explanation;
}

class IngredientFinding {
  const IngredientFinding({
    required this.token,
    required this.verdict,
    required this.reason,
    this.matchedCode,
  });

  final String token;
  final HalalVerdict verdict;
  final String reason;
  final String? matchedCode;
}

class HalalAnalysisResult {
  const HalalAnalysisResult({
    required this.overallVerdict,
    required this.findings,
    required this.summary,
  });

  final HalalVerdict overallVerdict;
  final List<IngredientFinding> findings;
  final String summary;
}

class BarcodeLookupResult {
  const BarcodeLookupResult({
    required this.barcode,
    required this.found,
    required this.productName,
    required this.brand,
    required this.ingredientsText,
    required this.labels,
    required this.analysis,
    required this.isLive,
    this.errorMessage,
  });

  final String barcode;
  final bool found;
  final String productName;
  final String brand;
  final String ingredientsText;
  final List<String> labels;
  final HalalAnalysisResult analysis;
  final bool isLive;
  final String? errorMessage;
}

abstract final class HalalDatabase {
  static const List<ENumberEntry> eNumbers = [
    ENumberEntry(
      code: 'E100',
      name: 'Curcumin',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Extracted from turmeric root; plant-derived.',
    ),
    ENumberEntry(
      code: 'E101',
      name: 'Riboflavin (Vitamin B2)',
      category: 'Color / Vitamin',
      verdict: HalalVerdict.doubtful,
      explanation: 'Usually yeast/plant or synthetic, occasionally dairy/organ source — check vegetarian/Halal label.',
    ),
    ENumberEntry(
      code: 'E102',
      name: 'Tartrazine',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Synthetic azo food coloring.',
    ),
    ENumberEntry(
      code: 'E104',
      name: 'Quinoline Yellow',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Synthetically produced colorant.',
    ),
    ENumberEntry(
      code: 'E110',
      name: 'Sunset Yellow FCF',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Synthetic food coloring.',
    ),
    ENumberEntry(
      code: 'E120',
      name: 'Carmine / Cochineal',
      category: 'Color',
      verdict: HalalVerdict.haram,
      explanation: 'Derived from crushed cochineal insects; considered Haram/impermissible by mainstream Halal certifiers.',
    ),
    ENumberEntry(
      code: 'E129',
      name: 'Allura Red AC',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Synthetically produced red dye.',
    ),
    ENumberEntry(
      code: 'E140',
      name: 'Chlorophylls',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Green pigment extracted from edible plants and algae.',
    ),
    ENumberEntry(
      code: 'E150a',
      name: 'Plain Caramel',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Produced by controlled heating of plant sugars.',
    ),
    ENumberEntry(
      code: 'E150d',
      name: 'Sulfite Ammonia Caramel',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Caramel coloring produced from sugars; verify no alcohol flavor carrier in beverages.',
    ),
    ENumberEntry(
      code: 'E160a',
      name: 'Beta-Carotene',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Plant/algal pigment unless emulsified with gelatin carrier — verify carrier in supplements.',
    ),
    ENumberEntry(
      code: 'E160b',
      name: 'Annatto',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Extracted from achiote seeds.',
    ),
    ENumberEntry(
      code: 'E160c',
      name: 'Paprika Extract',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Extracted from sweet red peppers.',
    ),
    ENumberEntry(
      code: 'E162',
      name: 'Beetroot Red (Betanin)',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Extracted from red beets.',
    ),
    ENumberEntry(
      code: 'E163',
      name: 'Anthocyanins',
      category: 'Color',
      verdict: HalalVerdict.halal,
      explanation: 'Natural fruit and berry pigments (check grape skin extracts if fermented with wine must).',
    ),
    ENumberEntry(
      code: 'E170',
      name: 'Calcium Carbonate',
      category: 'Mineral / Color',
      verdict: HalalVerdict.halal,
      explanation: 'Mineral chalk origin.',
    ),
    ENumberEntry(
      code: 'E200',
      name: 'Sorbic Acid',
      category: 'Preservative',
      verdict: HalalVerdict.halal,
      explanation: 'Synthetic preservative; plant-compatible.',
    ),
    ENumberEntry(
      code: 'E202',
      name: 'Potassium Sorbate',
      category: 'Preservative',
      verdict: HalalVerdict.halal,
      explanation: 'Synthetic mineral salt of sorbic acid.',
    ),
    ENumberEntry(
      code: 'E211',
      name: 'Sodium Benzoate',
      category: 'Preservative',
      verdict: HalalVerdict.halal,
      explanation: 'Synthetic preservative.',
    ),
    ENumberEntry(
      code: 'E260',
      name: 'Acetic Acid (Vinegar)',
      category: 'Acid',
      verdict: HalalVerdict.halal,
      explanation: 'Food acid; Halal when fully converted to vinegar without residual intoxicant.',
    ),
    ENumberEntry(
      code: 'E270',
      name: 'Lactic Acid',
      category: 'Acid',
      verdict: HalalVerdict.halal,
      explanation: 'Normally fermented from beet/corn sugars; occasionally whey-derived.',
    ),
    ENumberEntry(
      code: 'E296',
      name: 'Malic Acid',
      category: 'Acid',
      verdict: HalalVerdict.halal,
      explanation: 'Fruit acid or synthetically produced.',
    ),
    ENumberEntry(
      code: 'E300',
      name: 'Ascorbic Acid (Vitamin C)',
      category: 'Antioxidant',
      verdict: HalalVerdict.halal,
      explanation: 'Glucose-derived or synthetic.',
    ),
    ENumberEntry(
      code: 'E304',
      name: 'Ascorbyl Palmitate',
      category: 'Antioxidant',
      verdict: HalalVerdict.doubtful,
      explanation: 'Palmitic acid portion may derive from plant (palm) or animal fat — confirm vegetarian/Halal label.',
    ),
    ENumberEntry(
      code: 'E306',
      name: 'Tocopherols (Vitamin E)',
      category: 'Antioxidant',
      verdict: HalalVerdict.halal,
      explanation: 'Typically extracted from vegetable oils (soy/sunflower).',
    ),
    ENumberEntry(
      code: 'E322',
      name: 'Lecithin',
      category: 'Emulsifier',
      verdict: HalalVerdict.doubtful,
      explanation: 'Halal when soy, sunflower, or egg-derived; verify source when origin is unlisted.',
    ),
    ENumberEntry(
      code: 'E330',
      name: 'Citric Acid',
      category: 'Acid',
      verdict: HalalVerdict.halal,
      explanation: 'Produced via carbohydrate fermentation or citrus.',
    ),
    ENumberEntry(
      code: 'E331',
      name: 'Sodium Citrates',
      category: 'Acid / Buffer',
      verdict: HalalVerdict.halal,
      explanation: 'Mineral salt of citric acid.',
    ),
    ENumberEntry(
      code: 'E406',
      name: 'Agar',
      category: 'Gelling Agent',
      verdict: HalalVerdict.halal,
      explanation: 'Seaweed-derived Halal alternative to animal gelatin.',
    ),
    ENumberEntry(
      code: 'E407',
      name: 'Carrageenan',
      category: 'Thickener',
      verdict: HalalVerdict.halal,
      explanation: 'Extracted from red edible seaweeds.',
    ),
    ENumberEntry(
      code: 'E410',
      name: 'Locust Bean Gum',
      category: 'Thickener',
      verdict: HalalVerdict.halal,
      explanation: 'Derived from carob tree seeds.',
    ),
    ENumberEntry(
      code: 'E412',
      name: 'Guar Gum',
      category: 'Thickener',
      verdict: HalalVerdict.halal,
      explanation: 'Derived from guar beans.',
    ),
    ENumberEntry(
      code: 'E414',
      name: 'Gum Arabic (Acacia)',
      category: 'Thickener',
      verdict: HalalVerdict.halal,
      explanation: 'Natural tree sap from Acacia.',
    ),
    ENumberEntry(
      code: 'E415',
      name: 'Xanthan Gum',
      category: 'Thickener',
      verdict: HalalVerdict.halal,
      explanation: 'Fermented from corn/sugar carbohydrates.',
    ),
    ENumberEntry(
      code: 'E422',
      name: 'Glycerol / Glycerin',
      category: 'Humectant',
      verdict: HalalVerdict.doubtful,
      explanation: 'Can come from vegetable oils OR animal fats (including lard/tallow); require Halal/vegan marking.',
    ),
    ENumberEntry(
      code: 'E432',
      name: 'Polysorbate 20',
      category: 'Emulsifier',
      verdict: HalalVerdict.doubtful,
      explanation: 'Fatty acid ester may be plant- or animal-sourced.',
    ),
    ENumberEntry(
      code: 'E433',
      name: 'Polysorbate 80',
      category: 'Emulsifier',
      verdict: HalalVerdict.doubtful,
      explanation: 'Oleic acid component can be vegetable or animal fat origin.',
    ),
    ENumberEntry(
      code: 'E440',
      name: 'Pectin',
      category: 'Gelling Agent',
      verdict: HalalVerdict.halal,
      explanation: 'Extracted from apples and citrus fruit peels.',
    ),
    ENumberEntry(
      code: 'E441',
      name: 'Gelatin / Gelatine',
      category: 'Gelling Agent',
      verdict: HalalVerdict.haram,
      explanation: 'Commonly porcine or non-zabiha bovine unless explicitly certified Halal bovine or fish gelatin.',
    ),
    ENumberEntry(
      code: 'E450',
      name: 'Diphosphates',
      category: 'Raising Agent',
      verdict: HalalVerdict.halal,
      explanation: 'Inorganic mineral phosphate salts.',
    ),
    ENumberEntry(
      code: 'E470a',
      name: 'Sodium/Potassium/Calcium Fatty Acid Salts',
      category: 'Emulsifier',
      verdict: HalalVerdict.doubtful,
      explanation: 'Fatty acids may be derived from vegetable or animal fat.',
    ),
    ENumberEntry(
      code: 'E470b',
      name: 'Magnesium Stearate',
      category: 'Anti-caking',
      verdict: HalalVerdict.doubtful,
      explanation: 'Widely used in supplements & tablets; verify vegetable/Halal origin.',
    ),
    ENumberEntry(
      code: 'E471',
      name: 'Mono- and Diglycerides of Fatty Acids',
      category: 'Emulsifier',
      verdict: HalalVerdict.doubtful,
      explanation: 'Very common in bread, chocolate & ice cream; may originate from palm/soy OR animal/pork fat unless labeled Halal/vegan.',
    ),
    ENumberEntry(
      code: 'E472e',
      name: 'DATEM (Mono/diacetyl tartaric acid esters)',
      category: 'Bakery Emulsifier',
      verdict: HalalVerdict.doubtful,
      explanation: 'Uses E471 base fats; confirm plant-only or Halal bakery certification.',
    ),
    ENumberEntry(
      code: 'E476',
      name: 'Polyglycerol Polyricinoleate (PGPR)',
      category: 'Chocolate Emulsifier',
      verdict: HalalVerdict.doubtful,
      explanation: 'Uses glycerol + castor bean oil; check plant glycerol source.',
    ),
    ENumberEntry(
      code: 'E481',
      name: 'Sodium Stearoyl Lactylate',
      category: 'Emulsifier',
      verdict: HalalVerdict.doubtful,
      explanation: 'Stearic acid may be plant or animal derived.',
    ),
    ENumberEntry(
      code: 'E491',
      name: 'Sorbitan Monostearate',
      category: 'Emulsifier',
      verdict: HalalVerdict.doubtful,
      explanation: 'Contains stearic acid (check plant vs animal fat).',
    ),
    ENumberEntry(
      code: 'E500',
      name: 'Sodium Carbonates (Baking Soda)',
      category: 'Raising Agent',
      verdict: HalalVerdict.halal,
      explanation: 'Mineral salt.',
    ),
    ENumberEntry(
      code: 'E542',
      name: 'Bone Phosphate',
      category: 'Anti-caking',
      verdict: HalalVerdict.haram,
      explanation: 'Produced from animal bones (often porcine/non-zabiha cattle).',
    ),
    ENumberEntry(
      code: 'E570',
      name: 'Stearic Acid',
      category: 'Glazing / Anti-caking',
      verdict: HalalVerdict.doubtful,
      explanation: 'Either plant oil or animal tallow origin.',
    ),
    ENumberEntry(
      code: 'E621',
      name: 'Monosodium Glutamate (MSG)',
      category: 'Flavor Enhancer',
      verdict: HalalVerdict.halal,
      explanation: 'Produced via bacterial fermentation of molasses/starch; Halal unless blended in meat-extract seasoning.',
    ),
    ENumberEntry(
      code: 'E627',
      name: 'Disodium Guanylate',
      category: 'Flavor Enhancer',
      verdict: HalalVerdict.doubtful,
      explanation: 'Often produced via yeast fermentation or fish/meat extract — verify vegetarian/Halal.',
    ),
    ENumberEntry(
      code: 'E631',
      name: 'Disodium Inosinate',
      category: 'Flavor Enhancer',
      verdict: HalalVerdict.doubtful,
      explanation: 'May be derived from meat/pork extract, fish, or microbial fermentation; confirm source.',
    ),
    ENumberEntry(
      code: 'E635',
      name: 'Disodium 5\'-Ribonucleotides',
      category: 'Flavor Enhancer',
      verdict: HalalVerdict.doubtful,
      explanation: 'Blend of E627 + E631; check microbial/vegetarian origin.',
    ),
    ENumberEntry(
      code: 'E901',
      name: 'Beeswax',
      category: 'Glazing Agent',
      verdict: HalalVerdict.halal,
      explanation: 'Produced by honeybees.',
    ),
    ENumberEntry(
      code: 'E903',
      name: 'Carnauba Wax',
      category: 'Glazing Agent',
      verdict: HalalVerdict.halal,
      explanation: 'Plant wax from Brazilian carnauba palm leaves.',
    ),
    ENumberEntry(
      code: 'E904',
      name: 'Shellac',
      category: 'Confectionery Glaze',
      verdict: HalalVerdict.doubtful,
      explanation: 'Secreted by lac insects and often dissolved in ethanol carriers; opinions vary across Halal certifiers.',
    ),
    ENumberEntry(
      code: 'E920',
      name: 'L-Cysteine',
      category: 'Flour Treatment',
      verdict: HalalVerdict.haram,
      explanation: 'Historically extracted from human hair or duck feathers; Halal only if explicitly synthetic/fermented.',
    ),
    ENumberEntry(
      code: 'E951',
      name: 'Aspartame',
      category: 'Sweetener',
      verdict: HalalVerdict.halal,
      explanation: 'Synthetic amino-acid dipeptide sweetener.',
    ),
    ENumberEntry(
      code: 'E955',
      name: 'Sucralose',
      category: 'Sweetener',
      verdict: HalalVerdict.halal,
      explanation: 'Derived from sucrose.',
    ),
    ENumberEntry(
      code: 'E965',
      name: 'Maltitol',
      category: 'Sweetener',
      verdict: HalalVerdict.halal,
      explanation: 'Sugar alcohol hydrogenated from starch/maltose.',
    ),
    ENumberEntry(
      code: 'E1105',
      name: 'Lysozyme',
      category: 'Enzyme / Preservative',
      verdict: HalalVerdict.halal,
      explanation: 'Typically extracted from chicken egg whites.',
    ),
    ENumberEntry(
      code: 'E1510',
      name: 'Ethanol (Ethyl Alcohol)',
      category: 'Solvent / Carrier',
      verdict: HalalVerdict.haram,
      explanation: 'Intoxicant alcohol; impermissible as an added drink/intoxicating component.',
    ),
  ];

  static final Map<String, ENumberEntry> _byCode = {
    for (final e in eNumbers) e.code.toLowerCase(): e,
  };

  static ENumberEntry? findByCode(String code) =>
      _byCode[code.toLowerCase().trim()];

  static const List<({String name, String label, String text})> sampleLabels = [
    (
      name: 'Gummy Candy Label',
      label: 'Halal check: Gelatin & Carmine',
      text: 'Glucose syrup, Sugar, Gelatin, Citric acid (E330), Carmine (E120), Beeswax (E901)',
    ),
    (
      name: 'Baked Biscuit Label',
      label: 'Doubtful emulsifiers check',
      text: 'Wheat flour, Sugar, Palm oil, Mono- and diglycerides (E471), Whey powder, Soy lecithin (E322), Sodium bicarbonate (E500)',
    ),
    (
      name: 'Clean Plant Beverage',
      label: 'Plant-based label',
      text: 'Water, Sugar, Citric acid (E330), Gum arabic (E414), Curcumin (E100), Ascorbic acid (E300)',
    ),
  ];

  static const List<({String barcode, String name, String brand, String ingredients, List<String> labels})>
      sampleBarcodes = [
    (
      barcode: '3017620422003',
      name: 'Hazelnut Cocoa Spread (Sample)',
      brand: 'Ferrero (Reference Sample)',
      ingredients: 'Sugar, Palm oil, Hazelnuts, Skimmed milk powder, Fat-reduced cocoa, Lecithin (E322), Vanillin',
      labels: ['Vegetarian (verify soy lecithin origin)'],
    ),
    (
      barcode: '5000159461122',
      name: 'Fruity Chewy Sweets (Sample)',
      brand: 'Confectionery Sample',
      ingredients: 'Sugar, Glucose syrup, Gelatin, Citric acid (E330), Carmine (E120), Carnauba wax (E903)',
      labels: ['Contains Gelatin & E120'],
    ),
    (
      barcode: '8901058851229',
      name: 'Roasted Corn Chips (Sample)',
      brand: 'Snack Sample',
      ingredients: 'Corn meal, Vegetable oil, Salt, Paprika extract (E160c), Citric acid (E330)',
      labels: ['Plant ingredients'],
    ),
  ];

  static const List<({String title, String detail})> shoppingGuideTips = [
    (
      title: 'Verify Recognized Halal Certification',
      detail: 'Look for accredited seals (e.g., JAKIM, MUI, IFANCA, HFA, SANHA, HMC) especially on meat, gelatin, cheeses, and baked goods.',
    ),
    (
      title: 'Watch E471, E472, E422 & Rennet',
      detail: 'When a product shows "suitable for vegetarians" or "vegan", plant/synthetic sources replace animal fats and non-zabiha rennet.',
    ),
    (
      title: 'Check Hidden Alcohol Carriers',
      detail: 'Pure vanilla extract, glazing agents, and imported sauces (mirin, wine vinegar blends) may contain added ethanol or cooking wine.',
    ),
  ];

  static HalalAnalysisResult analyzeIngredients(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) {
      return const HalalAnalysisResult(
        overallVerdict: HalalVerdict.doubtful,
        findings: [],
        summary: 'Paste ingredients or enter an E-number to check Halal status.',
      );
    }

    final rawTokens = cleaned
        .split(RegExp(r'[,;\n•]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final findings = <IngredientFinding>[];
    var worst = HalalVerdict.halal;

    void considerVerdict(HalalVerdict v) {
      if (v == HalalVerdict.haram) {
        worst = HalalVerdict.haram;
      } else if (v == HalalVerdict.doubtful && worst != HalalVerdict.haram) {
        worst = HalalVerdict.doubtful;
      }
    }

    final eCodeRegex = RegExp(r'\b[eE]-?\s*(\d{3,4}[a-zA-Z]?)\b');

    for (final token in rawTokens) {
      final lower = token.toLowerCase();
      var matched = false;

      // 1. Check any explicit E-codes in the token.
      for (final m in eCodeRegex.allMatches(token)) {
        final normalizedCode = 'E${m.group(1)!.toLowerCase()}';
        final entry = findByCode(normalizedCode) ??
            findByCode(normalizedCode.replaceAll(RegExp(r'[a-z]+$'), ''));
        if (entry != null) {
          matched = true;
          considerVerdict(entry.verdict);
          findings.add(IngredientFinding(
            token: token,
            verdict: entry.verdict,
            reason: '${entry.code} (${entry.name}): ${entry.explanation}',
            matchedCode: entry.code,
          ));
          break;
        }
      }
      if (matched) continue;

      // 2. Check soy/sunflower explicitly before generic lecithin.
      if (lower.contains('soy lecithin') ||
          lower.contains('soya lecithin') ||
          lower.contains('sunflower lecithin') ||
          lower.contains('vegetable glycerin') ||
          lower.contains('halal gelatin') ||
          lower.contains('fish gelatin')) {
        findings.add(IngredientFinding(
          token: token,
          verdict: HalalVerdict.halal,
          reason: 'Explicitly plant, fish, or Halal-certified source.',
        ));
        continue;
      }

      // 3. Check haram/doubtful ingredient keywords.
      final haramPattern = RegExp(
          r'\b(pork|lard|bacon|ham|prosciutto|porcine|gelatine?|carmine|cochineal|wine|beer|rum|brandy|whisky|vodka|liqueur|ethanol|alcohol|mirin)\b');
      final doubtfulPattern = RegExp(
          r'\b(mono-?\s*(?:and|&)\s*diglycerides?|diglycerides?|glycerin|glycerol|shortening|tallow|pepsin|lipase|l-?cysteine|whey|rennet|cheese|natural flavou?r(?:ing)?s?|emulsifier|lecithin|vanilla extract|magnesium stearate)\b');

      if (haramPattern.hasMatch(lower)) {
        considerVerdict(HalalVerdict.haram);
        findings.add(IngredientFinding(
          token: token,
          verdict: HalalVerdict.haram,
          reason:
              'Flagged ingredient (porcine, alcohol, insect-derived E120, or uncertified gelatin). Avoid unless proven Halal-certified.',
        ));
      } else if (doubtfulPattern.hasMatch(lower)) {
        considerVerdict(HalalVerdict.doubtful);
        findings.add(IngredientFinding(
          token: token,
          verdict: HalalVerdict.doubtful,
          reason:
              'Mushbooh (Doubtful): Source can be plant or animal/alcohol-based. Confirm Halal or vegan/vegetarian certification.',
        ));
      } else {
        findings.add(IngredientFinding(
          token: token,
          verdict: HalalVerdict.halal,
          reason: 'No flagged Haram or doubtful additive detected.',
        ));
      }
    }

    final haramCount =
        findings.where((f) => f.verdict == HalalVerdict.haram).length;
    final doubtfulCount =
        findings.where((f) => f.verdict == HalalVerdict.doubtful).length;

    final String summary;
    if (haramCount > 0) {
      summary =
          '$haramCount flagged Haram/avoid ingredient(s) detected. Verify certification or avoid this item.';
    } else if (doubtfulCount > 0) {
      summary =
          '$doubtfulCount doubtful (Mushbooh) item(s) require source verification (plant/Halal vs. animal fat/enzymes).';
    } else {
      summary =
          'All ${findings.length} parsed ingredient(s) passed offline Halal screen.';
    }

    return HalalAnalysisResult(
      overallVerdict: worst,
      findings: findings,
      summary: summary,
    );
  }

  static Future<BarcodeLookupResult> lookupBarcode(
    String rawBarcode, {
    http.Client? client,
  }) async {
    final code = rawBarcode.replaceAll(RegExp(r'[^0-9]'), '');
    if (code.length < 8) {
      return BarcodeLookupResult(
        barcode: rawBarcode,
        found: false,
        productName: '',
        brand: '',
        ingredientsText: '',
        labels: const [],
        analysis: analyzeIngredients(''),
        isLive: false,
        errorMessage: 'Enter a valid 8–14 digit EAN/UPC barcode.',
      );
    }

    // 1. Live OpenFoodFacts lookup.
    final c = client ?? http.Client();
    final ownsClient = client == null;
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$code.json'
        '?fields=product_name,brands,ingredients_text,additives_tags,labels_tags',
      );
      final res = await c.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final status = (decoded['status'] as num?)?.toInt() ?? 0;
        final product = decoded['product'] as Map<String, dynamic>?;
        if (status == 1 && product != null) {
          final name = product['product_name']?.toString().trim() ?? 'Product $code';
          final brand = product['brands']?.toString().trim() ?? '';
          final ing = product['ingredients_text']?.toString().trim() ?? '';
          final additives = ((product['additives_tags'] as List?) ?? const [])
              .map((e) => e.toString().replaceFirst('en:', '').toUpperCase())
              .toList();
          final labels = ((product['labels_tags'] as List?) ?? const [])
              .map((e) => e.toString().replaceFirst('en:', '').replaceAll('-', ' '))
              .toList();
          final combined = [if (ing.isNotEmpty) ing, ...additives].join(', ');
          return BarcodeLookupResult(
            barcode: code,
            found: true,
            productName: name.isEmpty ? 'Product $code' : name,
            brand: brand,
            ingredientsText: combined,
            labels: labels.take(5).toList(),
            analysis: analyzeIngredients(combined),
            isLive: true,
          );
        }
      }
    } catch (_) {
      // Fall back to sample reference barcodes below.
    } finally {
      if (ownsClient) c.close();
    }

    for (final s in sampleBarcodes) {
      if (s.barcode == code) {
        return BarcodeLookupResult(
          barcode: code,
          found: true,
          productName: s.name,
          brand: s.brand,
          ingredientsText: s.ingredients,
          labels: s.labels,
          analysis: analyzeIngredients(s.ingredients),
          isLive: false,
        );
      }
    }

    return BarcodeLookupResult(
      barcode: code,
      found: false,
      productName: '',
      brand: '',
      ingredientsText: '',
      labels: const [],
      analysis: analyzeIngredients(''),
      isLive: false,
      errorMessage:
          'No offline match found and OpenFoodFacts could not be reached. Paste the package ingredients in the Ingredients tab for instant verification.',
    );
  }
}
