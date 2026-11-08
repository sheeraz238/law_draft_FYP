int _gcd(int a, int b) {
  while (b != 0) {
    final t = a % b;
    a = b;
    b = t;
  }
  return a.abs();
}

class Fraction {
  final int n;
  final int d;
  const Fraction._(this.n, this.d);

  factory Fraction(int n, [int d = 1]) {
    if (d == 0) throw ArgumentError('Denominator cannot be zero');
    if (d < 0) {
      n = -n;
      d = -d;
    }
    final g = _gcd(n, d);
    return g <= 1 ? Fraction._(n, d) : Fraction._(n ~/ g, d ~/ g);
  }

  Fraction operator +(Fraction o) => Fraction(n * o.d + o.n * d, d * o.d);
  Fraction operator -(Fraction o) => Fraction(n * o.d - o.n * d, d * o.d);
  Fraction operator *(Fraction o) => Fraction(n * o.n, d * o.d);
  Fraction operator /(Fraction o) => Fraction(n * o.d, d * o.n);
  bool operator >(Fraction o) => n * o.d > o.n * d;

  bool get isZero => n == 0;
  bool get isPositive => n > 0;
  double get value => n / d;

  @override
  String toString() => d == 1 ? '$n' : '$n/$d';
}
