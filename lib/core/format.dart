String formatMoney(double v) => v.round().toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (m) => ',',
);
