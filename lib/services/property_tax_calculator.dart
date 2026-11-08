import 'dart:math';
import '../core/tax_rates.dart';

class PropertyTaxResult {
  final double value;
  final double buyerRate;
  final double sellerRate;
  final double buyerTax;
  final double sellerTax;

  const PropertyTaxResult({
    required this.value,
    required this.buyerRate,
    required this.sellerRate,
    required this.buyerTax,
    required this.sellerTax,
  });

  double get total => buyerTax + sellerTax;
}

class PropertyTaxCalculator {
  static PropertyTaxResult calculate({
    required double fbrValue,
    required double registryValue,
    required bool buyerFiler,
    required bool sellerFiler,
  }) {
    // Tax us value par lagta hai jo zyada ho (FBR/DC ya registry)
    final value = max(fbrValue, registryValue);
    final buyerRate = TaxRates.buyerRate(buyerFiler, value);
    final sellerRate = TaxRates.sellerRate(sellerFiler);
    return PropertyTaxResult(
      value: value,
      buyerRate: buyerRate,
      sellerRate: sellerRate,
      buyerTax: value * buyerRate,
      sellerTax: value * sellerRate,
    );
  }
}
