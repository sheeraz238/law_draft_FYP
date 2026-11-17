import 'package:flutter_test/flutter_test.dart';
import 'package:law_draft_app/models/legal_guide.dart';
import 'package:law_draft_app/services/inheritance_calculator.dart';
import 'package:law_draft_app/services/local_search.dart';
import 'package:law_draft_app/services/property_tax_calculator.dart';
import 'package:law_draft_app/services/template_renderer.dart';

String share(InheritanceResult r, String heir) =>
    r.shares.firstWhere((s) => s.heir == heir).share.toString();

LegalGuide guide(String id, String title, List<String> keywords) => LegalGuide(
  id: id,
  topic: 'Test',
  title: title,
  summary: '',
  steps: const [],
  documents: const [],
  draftIds: const [],
  keywords: keywords,
  reviewedBy: null,
  reviewedOn: null,
);

void main() {
  group('Inheritance calculator', () {
    test('wife, son and daughter', () {
      final r = InheritanceCalculator.calculate(
        const InheritanceInput(wives: 1, sons: 1, daughters: 1),
      );
      expect(share(r, 'Wife'), '1/8');
      expect(share(r, 'Son'), '7/12');
      expect(share(r, 'Daughter'), '7/24');
    });

    test(
      'husband, father and mother: mother gets a third of the remainder',
      () {
        final r = InheritanceCalculator.calculate(
          const InheritanceInput(husband: 1, father: 1, mother: 1),
        );
        expect(share(r, 'Husband'), '1/2');
        expect(share(r, 'Mother'), '1/6');
        expect(share(r, 'Father'), '1/3');
      },
    );

    test('wife and one daughter: remainder returns to the daughter (radd)', () {
      final r = InheritanceCalculator.calculate(
        const InheritanceInput(wives: 1, daughters: 1),
      );
      expect(share(r, 'Wife'), '1/8');
      expect(share(r, 'Daughter'), '7/8');
    });

    test('shares above the estate are reduced proportionally (awl)', () {
      final r = InheritanceCalculator.calculate(
        const InheritanceInput(husband: 1, daughters: 2, father: 1, mother: 1),
      );
      expect(share(r, 'Husband'), '1/5');
      expect(share(r, 'Daughter'), '8/15');
      expect(share(r, 'Father'), '2/15');
      expect(share(r, 'Mother'), '2/15');
    });
  });

  group('Property tax calculator', () {
    test('both filers: the higher of the two values is taxed', () {
      final r = PropertyTaxCalculator.calculate(
        fbrValue: 8000000,
        registryValue: 10000000,
        buyerFiler: true,
        sellerFiler: true,
      );
      expect(r.value, 10000000);
      expect(r.buyerTax, closeTo(125000, 0.01));
      expect(r.sellerTax, closeTo(275000, 0.01));
      expect(r.total, closeTo(400000, 0.01));
    });

    test('non-filer buyer on 60 million pays the middle slab', () {
      final r = PropertyTaxCalculator.calculate(
        fbrValue: 60000000,
        registryValue: 0,
        buyerFiler: false,
        sellerFiler: true,
      );
      expect(r.buyerTax, closeTo(8700000, 0.01));
      expect(r.sellerTax, closeTo(1650000, 0.01));
    });

    test('both non-filers on 120 million', () {
      final r = PropertyTaxCalculator.calculate(
        fbrValue: 120000000,
        registryValue: 0,
        buyerFiler: false,
        sellerFiler: false,
      );
      expect(r.buyerTax, closeTo(22200000, 0.01));
      expect(r.sellerTax, closeTo(13800000, 0.01));
    });
  });

  group('Draft template renderer', () {
    test('numbering, optional lines and one-per-line points', () {
      final spec = <dynamic>[
        {'t': 'Hello {name|upper}', 'b': true},
        {'n': true, 't': 'First {x}'},
        {'n': true, 'if': 'opt', 't': 'Optional {opt}'},
        {'each': 'items', 'n': true, 't': '{item}'},
      ];
      final out = TemplateRenderer.render(spec, {
        'name': 'ali',
        'x': '1',
        'opt': '',
        'items': 'a\nb',
      });
      expect(out.map((l) => l.text).toList(), [
        'Hello ALI',
        '1. First 1',
        '2. a',
        '3. b',
      ]);
    });

    test('dates and party placeholders', () {
      final spec = <dynamic>[
        {'t': '{d} / {p.type} / {p.name}'},
      ];
      final out = TemplateRenderer.render(spec, {
        'd': DateTime(2026, 3, 5),
        'p': {
          'type': 'Petitioner',
          'parties': [
            {'name': 'Ali'},
          ],
        },
      });
      expect(out.first.text, '05/03/2026 / Petitioner / Ali');
    });
  });

  group('Local guide search', () {
    final guides = [
      guide('1', 'How to file a Khula suit', ['khula', 'shauhar']),
      guide('2', 'How to file an FIR', ['fir', 'thana', 'police']),
      guide('3', 'How bail works', ['bail', 'zamanat', 'zamant']),
    ];

    test('finds the right guide from Roman Urdu words', () {
      expect(
        LocalSearch.rank('shauhar se khula chahiye', guides).first.guide.id,
        '1',
      );
      expect(LocalSearch.rank('thana report', guides).first.guide.id, '2');
      expect(LocalSearch.rank('zamant', guides).first.guide.id, '3');
    });

    test('returns nothing for unrelated words', () {
      expect(LocalSearch.rank('qabza', guides), isEmpty);
    });
  });
}
