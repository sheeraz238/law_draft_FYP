import '../models/legal_guide.dart';

class LocalMatch {
  final LegalGuide guide;
  final double score;
  const LocalMatch(this.guide, this.score);
}

/// Internet aur AI ke baghair lafzon ki milaan se sab se qareeb guides dhoondta hai.
class LocalSearch {
  static final Set<String> _stop = {
    'i',
    'me',
    'my',
    'we',
    'is',
    'am',
    'are',
    'the',
    'a',
    'an',
    'to',
    'of',
    'for',
    'how',
    'what',
    'can',
    'do',
    'does',
    'want',
    'need',
    'please',
    'kya',
    'kaise',
    'kese',
    'kia',
    'ka',
    'ki',
    'ke',
    'ko',
    'se',
    'mein',
    'main',
    'hai',
    'hain',
    'ho',
    'hoga',
    'chahiye',
    'chahye',
    'mujhe',
    'meri',
    'mera',
    'mere',
    'hum',
    'aap',
    'par',
    'pe',
    'or',
    'aur',
    'ya',
    'tou',
    'nahi',
    'nhi',
    'karna',
    'karni',
    'karein',
    'karun',
    'kare',
    'bata',
    'batao',
  };

  static List<String> tokens(String s) {
    final cleaned = s.toLowerCase().replaceAll(
      RegExp(r'[^\p{L}\p{M}\p{N}\s]', unicode: true),
      ' ',
    );
    return cleaned
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 1 && !_stop.contains(t))
        .toList();
  }

  // do lafz mein sirf ek harf ka farq (typo)
  static bool _near(String a, String b) {
    if ((a.length - b.length).abs() > 1) return false;
    var i = 0, j = 0, edits = 0;
    while (i < a.length && j < b.length) {
      if (a[i] == b[j]) {
        i++;
        j++;
        continue;
      }
      if (++edits > 1) return false;
      if (a.length > b.length) {
        i++;
      } else if (a.length < b.length) {
        j++;
      } else {
        i++;
        j++;
      }
    }
    edits += (a.length - i) + (b.length - j);
    return edits <= 1;
  }

  static double _tokenScore(String t, Set<String> words) {
    if (words.contains(t)) return 1;
    if (t.length < 4) return 0;
    for (final w in words) {
      if (w.length >= 4 && (w.startsWith(t) || t.startsWith(w))) return 0.7;
      if (t.length >= 5 && w.length >= 5 && _near(t, w)) return 0.6;
    }
    return 0;
  }

  static double scoreGuide(List<String> q, LegalGuide g) {
    final kw = <String>{for (final k in g.keywords) ...tokens(k)};
    final title = tokens(g.title).toSet();
    final other = <String>{...tokens(g.summary), ...tokens(g.topic)};
    var total = 0.0;
    for (final t in q) {
      final s = [
        3 * _tokenScore(t, kw),
        2 * _tokenScore(t, title),
        _tokenScore(t, other),
      ];
      total += s.reduce((a, b) => a > b ? a : b);
    }
    return total;
  }

  static List<LocalMatch> rank(
    String query,
    List<LegalGuide> guides, {
    double minScore = 2,
    int limit = 5,
  }) {
    final q = tokens(query);
    if (q.isEmpty) return [];
    final out = <LocalMatch>[];
    for (final g in guides) {
      final s = scoreGuide(q, g);
      if (s >= minScore) out.add(LocalMatch(g, s));
    }
    out.sort((a, b) => b.score.compareTo(a.score));
    return out.take(limit).toList();
  }
}
