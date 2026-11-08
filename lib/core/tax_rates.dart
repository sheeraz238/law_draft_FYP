class TaxRates {
  static const lastVerified = 'Nov 2026 (Finance Act 2026, tax year 2026-27)';

  /// Section 236K, buyer
  static double buyerRate(bool filer, double value) {
    if (filer) return 0.0125;
    if (value <= 50000000) return 0.105;
    if (value <= 100000000) return 0.145;
    return 0.185;
  }

  /// Section 236C, seller
  static double sellerRate(bool filer) => filer ? 0.0275 : 0.115;
}
