import 'package:flutter/material.dart';
import '../services/inheritance_calculator.dart';

class InheritanceScreen extends StatefulWidget {
  const InheritanceScreen({super.key});

  @override
  State<InheritanceScreen> createState() => _InheritanceScreenState();
}

class _InheritanceScreenState extends State<InheritanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _estate = TextEditingController();

  final Map<String, int> _c = {
    'Husband': 0,
    'Wife': 0,
    'Son': 0,
    'Daughter': 0,
    'Grandson': 0,
    'Granddaughter': 0,
    'Father': 0,
    'Mother': 0,
    'Brother': 0,
    'Sister': 0,
  };
  static const _max = {'Husband': 1, 'Wife': 4, 'Father': 1, 'Mother': 1};

  InheritanceResult? _result;
  double _estateValue = 0;

  @override
  void dispose() {
    _estate.dispose();
    super.dispose();
  }

  String _money(double v) => v.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    if (_c.values.every((v) => v == 0)) {
      _msg('Kam az kam ek waris chunein');
      return;
    }
    if (_c['Husband']! > 0 && _c['Wife']! > 0) {
      _msg('Husband aur wife dono ek sath nahi ho sakte');
      return;
    }
    final estate = double.parse(_estate.text.replaceAll(',', '').trim());
    final input = InheritanceInput(
      husband: _c['Husband']!,
      wives: _c['Wife']!,
      sons: _c['Son']!,
      daughters: _c['Daughter']!,
      grandsons: _c['Grandson']!,
      granddaughters: _c['Granddaughter']!,
      father: _c['Father']!,
      mother: _c['Mother']!,
      brothers: _c['Brother']!,
      sisters: _c['Sister']!,
    );
    setState(() {
      _estateValue = estate;
      _result = InheritanceCalculator.calculate(input);
    });
  }

  Widget _counter(String key, String label, [String? hint]) {
    final v = _c[key]!;
    final max = _max[key] ?? 20;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: hint == null ? null : Text(hint),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: v > 0 ? () => setState(() => _c[key] = v - 1) : null,
          ),
          SizedBox(width: 28, child: Text('$v', textAlign: TextAlign.center)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: v < max ? () => setState(() => _c[key] = v + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _resultView() {
    final r = _result!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Result', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Heir')),
                  DataColumn(label: Text('No.')),
                  DataColumn(label: Text('Share')),
                  DataColumn(label: Text('%')),
                  DataColumn(label: Text('Total (PKR)')),
                  DataColumn(label: Text('Each (PKR)')),
                ],
                rows: [
                  for (final s in r.shares)
                    DataRow(
                      cells: [
                        DataCell(Text(s.heir)),
                        DataCell(Text('${s.count}')),
                        DataCell(Text(s.share.toString())),
                        DataCell(
                          Text((s.share.value * 100).toStringAsFixed(2)),
                        ),
                        DataCell(Text(_money(_estateValue * s.share.value))),
                        DataCell(
                          Text(_money(_estateValue * s.share.value / s.count)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            for (final n in r.notes)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('• $n'),
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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Islamic Inheritance Calculator',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'For reference only (Hanafi rules, simplified). Verify your '
                    'case with a qualified Mufti or lawyer. This is not a fatwa.',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _estate,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total estate value (PKR) *',
                  hintText: 'e.g. 5000000',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final x = double.tryParse(
                    (v ?? '').replaceAll(',', '').trim(),
                  );
                  return (x == null || x <= 0) ? 'Enter a valid amount' : null;
                },
              ),
              const SizedBox(height: 12),
              _group('Spouse', [
                _counter('Husband', 'Husband', 'Must be legally married'),
                _counter('Wife', 'Wives', 'Multiple wives share equally'),
              ]),
              _group('Children and Grandchildren', [
                _counter('Son', 'Sons'),
                _counter('Daughter', 'Daughters'),
                _counter('Grandson', 'Grandsons (son\'s sons)'),
                _counter('Granddaughter', 'Granddaughters (son\'s daughters)'),
              ]),
              _group('Parents', [
                _counter('Father', 'Father'),
                _counter('Mother', 'Mother'),
              ]),
              _group('Siblings', [
                _counter('Brother', 'Full brothers'),
                _counter('Sister', 'Full sisters'),
              ]),
              FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calculate Inheritance'),
              ),
              const SizedBox(height: 16),
              if (_result != null) _resultView(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
