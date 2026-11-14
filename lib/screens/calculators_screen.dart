import 'package:flutter/material.dart';
import 'inheritance_screen.dart';
import 'property_tax_screen.dart';

/// Dono calculators ek jagah, tabs ke saath
class CalculatorsScreen extends StatefulWidget {
  final int tab; // 0 = property tax, 1 = inheritance
  final ValueChanged<int>? onChanged;
  const CalculatorsScreen({super.key, this.tab = 0, this.onChanged});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> {
  late int _tab = widget.tab;

  @override
  void didUpdateWidget(covariant CalculatorsScreen old) {
    super.didUpdateWidget(old);
    if (old.tab != widget.tab) _tab = widget.tab;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(Icons.apartment_outlined),
                  label: Text('Property tax'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(Icons.account_balance_outlined),
                  label: Text('Inheritance share'),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (s) {
                setState(() => _tab = s.first);
                widget.onChanged?.call(s.first);
              },
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: const [PropertyTaxScreen(), InheritanceScreen()],
          ),
        ),
      ],
    );
  }
}
