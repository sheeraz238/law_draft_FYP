import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/tax_rates.dart';
import '../services/property_tax_calculator.dart';
import '../core/app_theme.dart';
import '../widgets/ui_kit.dart';

class PropertyTaxScreen extends StatefulWidget {
  const PropertyTaxScreen({super.key});

  @override
  State<PropertyTaxScreen> createState() => _PropertyTaxScreenState();
}

class _PropertyTaxScreenState extends State<PropertyTaxScreen> {
  final _fbr = TextEditingController();
  final _registry = TextEditingController();
  bool _buyerFiler = true;
  bool _sellerFiler = true;
  double _fbrValue = 0;
  double _registryValue = 0;
  PropertyTaxResult? _result;
  bool _showCompare = false;

  @override
  void dispose() {
    _fbr.dispose();
    _registry.dispose();
    super.dispose();
  }

  double _parse(String s) => double.tryParse(s.replaceAll(',', '').trim()) ?? 0;

  bool _readValues() {
    final f = _parse(_fbr.text);
    final r = _parse(_registry.text);
    if (f <= 0 && r <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FBR/DC value ya registry value likhein')),
      );
      return false;
    }
    _fbrValue = f;
    _registryValue = r;
    return true;
  }

  void _calculate() {
    if (!_readValues()) return;
    setState(() {
      _showCompare = false;
      _result = PropertyTaxCalculator.calculate(
        fbrValue: _fbrValue,
        registryValue: _registryValue,
        buyerFiler: _buyerFiler,
        sellerFiler: _sellerFiler,
      );
    });
  }

  void _compare() {
    if (!_readValues()) return;
    setState(() => _showCompare = true);
  }

  Widget _status(String label, bool filer, ValueChanged<bool> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Filer')),
            ButtonSegment(value: false, label: Text('Non-Filer')),
          ],
          selected: {filer},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }

  String _pct(double r) => '${(r * 100).toStringAsFixed(2)}%';

    Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppTheme.mono(
              size: 13,
              weight: bold ? FontWeight.w600 : FontWeight.w500,
              color: bold ? AppColors.amber : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _partyCard(
    IconData icon,
    String title,
    String section,
    String rate,
    double amount,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBox(icon, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Pill(section, color: const Color(0xFF60A5FA)),
              ],
            ),
            const SizedBox(height: 14),
            _row('Rate', rate),
            _row('Advance tax', 'PKR ${formatMoney(amount)}', bold: true),
          ],
        ),
      ),
    );
  }

  Widget _resultCard() {
    final r = _result!;
    final buyer = _partyCard(
      Icons.shopping_bag_outlined,
      'Buyer liability',
      'S.236K',
      _pct(r.buyerRate),
      r.buyerTax,
    );
    final seller = _partyCard(
      Icons.sell_outlined,
      'Seller deductions',
      'S.236C',
      _pct(r.sellerRate),
      r.sellerTax,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL ADVANCE TAX',
                  style: AppTheme.mono(
                    size: 11,
                    weight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'PKR ${formatMoney(r.total)}',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: AppColors.amber),
                ),
                const SizedBox(height: 4),
                Text(
                  'On a taxable value of PKR ${formatMoney(r.value)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth >= 560) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: buyer),
                  const SizedBox(width: 8),
                  Expanded(child: seller),
                ],
              );
            }
            return Column(children: [buyer, seller]);
          },
        ),
      ],
    );
  }

  Widget _compareCard() {
    final rows = <DataRow>[];
    for (final b in [true, false]) {
      for (final s in [true, false]) {
        final r = PropertyTaxCalculator.calculate(
          fbrValue: _fbrValue,
          registryValue: _registryValue,
          buyerFiler: b,
          sellerFiler: s,
        );
        rows.add(
          DataRow(
            cells: [
              DataCell(Text(b ? 'Filer' : 'Non-Filer')),
              DataCell(Text(s ? 'Filer' : 'Non-Filer')),
              DataCell(Text(formatMoney(r.buyerTax))),
              DataCell(Text(formatMoney(r.sellerTax))),
              DataCell(Text(formatMoney(r.total))),
            ],
          ),
        );
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compare all statuses (PKR)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Buyer')),
                  DataColumn(label: Text('Seller')),
                  DataColumn(label: Text('Buyer tax')),
                  DataColumn(label: Text('Seller tax')),
                  DataColumn(label: Text('Total')),
                ],
                rows: rows,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Property Tax Calculator',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'For guidance only. Covers advance tax (236K buyer, 236C seller) '
                  'only, not stamp duty, registration fee or capital gains tax. '
                  'Rates last checked: ${TaxRates.lastVerified}. '
                  'Consult a qualified tax lawyer or CA.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fbr,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'FBR / DC valuation (PKR)',
                      prefixText: 'PKR ',
                      hintText: 'e.g. 2400000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _registry,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Registry value (PKR)',
                      prefixText: 'PKR ',
                      hintText: 'e.g. 2551500',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _status(
                  'Buyer status',
                  _buyerFiler,
                  (v) => setState(() => _buyerFiler = v),
                ),
                _status(
                  'Seller status',
                  _sellerFiler,
                  (v) => setState(() => _sellerFiler = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Calculate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _compare,
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Compare all statuses'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_showCompare)
              _compareCard()
            else if (_result != null)
              _resultCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
