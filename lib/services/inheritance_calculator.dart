import '../core/fraction.dart';

class InheritanceInput {
  final int husband,
      wives,
      sons,
      daughters,
      grandsons,
      granddaughters,
      father,
      mother,
      brothers,
      sisters;

  const InheritanceInput({
    this.husband = 0,
    this.wives = 0,
    this.sons = 0,
    this.daughters = 0,
    this.grandsons = 0,
    this.granddaughters = 0,
    this.father = 0,
    this.mother = 0,
    this.brothers = 0,
    this.sisters = 0,
  });
}

class ShareResult {
  final String heir;
  final int count;
  final Fraction share; // poore group ka hissa
  const ShareResult(this.heir, this.count, this.share);
}

class InheritanceResult {
  final List<ShareResult> shares;
  final List<String> notes;
  const InheritanceResult(this.shares, this.notes);
}

class InheritanceCalculator {
  static const _order = [
    'Husband',
    'Wife',
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Grandson',
    'Granddaughter',
    'Brother',
    'Sister',
  ];

  static Fraction _f(int n, [int d = 1]) => Fraction(n, d);

  static InheritanceResult calculate(InheritanceInput h) {
    final notes = <String>[];
    final counts = {
      'Husband': h.husband,
      'Wife': h.wives,
      'Father': h.father,
      'Mother': h.mother,
      'Son': h.sons,
      'Daughter': h.daughters,
      'Grandson': h.grandsons,
      'Granddaughter': h.granddaughters,
      'Brother': h.brothers,
      'Sister': h.sisters,
    };

    final fixed = <String, Fraction>{}; // group -> fixed hissa
    final asaba = <String, int>{}; // group -> units (mard 2, aurat 1)

    final hasDesc = h.sons + h.daughters + h.grandsons + h.granddaughters > 0;
    final siblings = h.brothers + h.sisters;
    final spouse = h.husband + h.wives > 0;
    final sibBlocked = h.sons > 0 || h.grandsons > 0 || h.father > 0;

    // 1. Fixed hissay
    if (h.husband > 0) fixed['Husband'] = hasDesc ? _f(1, 4) : _f(1, 2);
    if (h.wives > 0) fixed['Wife'] = hasDesc ? _f(1, 8) : _f(1, 4);
    if (h.mother > 0) {
      fixed['Mother'] = (hasDesc || siblings >= 2) ? _f(1, 6) : _f(1, 3);
    }
    if (!hasDesc && siblings < 2 && spouse && h.father > 0 && h.mother > 0) {
      final spouseShare =
          (fixed['Husband'] ?? _f(0)) + (fixed['Wife'] ?? _f(0));
      fixed['Mother'] = (_f(1) - spouseShare) / _f(3);
      notes.add(
        'Umariyyatayn: mother gets 1/3 of what remains after the spouse share.',
      );
    }
    if (h.father > 0 && hasDesc) fixed['Father'] = _f(1, 6);

    if (h.sons == 0 && h.daughters > 0) {
      fixed['Daughter'] = h.daughters == 1 ? _f(1, 2) : _f(2, 3);
    }
    if (h.sons == 0 && h.grandsons == 0 && h.granddaughters > 0) {
      if (h.daughters == 0) {
        fixed['Granddaughter'] = h.granddaughters == 1 ? _f(1, 2) : _f(2, 3);
      } else if (h.daughters == 1) {
        fixed['Granddaughter'] = _f(1, 6);
      } else {
        notes.add(
          'Son\'s daughters get nothing: two or more daughters take 2/3.',
        );
      }
    }
    if (!sibBlocked &&
        h.brothers == 0 &&
        h.sisters > 0 &&
        h.daughters == 0 &&
        h.granddaughters == 0) {
      fixed['Sister'] = h.sisters == 1 ? _f(1, 2) : _f(2, 3);
    }

    // 2. Asaba (bachat lene wale)
    if (h.sons > 0) {
      asaba['Son'] = h.sons * 2;
      if (h.daughters > 0) asaba['Daughter'] = h.daughters;
      if (h.grandsons + h.granddaughters > 0) {
        notes.add('Son\'s children are blocked by the son(s).');
      }
    } else if (h.grandsons > 0) {
      asaba['Grandson'] = h.grandsons * 2;
      if (h.granddaughters > 0) asaba['Granddaughter'] = h.granddaughters;
    } else if (h.father > 0) {
      asaba['Father'] = 1;
    } else if (h.brothers > 0) {
      asaba['Brother'] = h.brothers * 2;
      if (h.sisters > 0) asaba['Sister'] = h.sisters;
    } else if (h.sisters > 0 && (h.daughters > 0 || h.granddaughters > 0)) {
      asaba['Sister'] = h.sisters;
    }
    if (sibBlocked && siblings > 0) {
      notes.add(
        'Brothers and sisters are blocked (by son, son\'s son or father).',
      );
    }

    // 3. Awl / asaba / radd
    var fixedTotal = _f(0);
    for (final v in fixed.values) {
      fixedTotal = fixedTotal + v;
    }
    final result = <String, Fraction>{};

    if (fixedTotal > _f(1)) {
      for (final e in fixed.entries) {
        result[e.key] = e.value / fixedTotal;
      }
      notes.add(
        'Awl: fixed shares exceeded the estate, so all were reduced proportionally.',
      );
    } else {
      result.addAll(fixed);
      final residue = _f(1) - fixedTotal;
      if (asaba.isNotEmpty) {
        var units = 0;
        for (final u in asaba.values) {
          units += u;
        }
        for (final e in asaba.entries) {
          result[e.key] =
              (result[e.key] ?? _f(0)) + residue * _f(e.value, units);
        }
      } else if (residue.isPositive && fixed.isNotEmpty) {
        final nonSpouse = fixed.keys
            .where((k) => k != 'Husband' && k != 'Wife')
            .toList();
        final pool = nonSpouse.isNotEmpty ? nonSpouse : fixed.keys.toList();
        var poolTotal = _f(0);
        for (final k in pool) {
          poolTotal = poolTotal + fixed[k]!;
        }
        for (final k in pool) {
          result[k] = fixed[k]! + residue * (fixed[k]! / poolTotal);
        }
        notes.add(
          nonSpouse.isNotEmpty
              ? 'Radd: the remainder was returned to the sharers (not the spouse).'
              : 'Radd: no other heirs, so the remainder returned to the spouse.',
        );
      }
    }
    for (final k in asaba.keys) {
      result.putIfAbsent(k, () => _f(0));
    }
    if (result.isEmpty) notes.add('No eligible heir found.');

    final shares = <ShareResult>[
      for (final k in _order)
        if (result.containsKey(k)) ShareResult(k, counts[k]!, result[k]!),
    ];
    return InheritanceResult(shares, notes);
  }
}
