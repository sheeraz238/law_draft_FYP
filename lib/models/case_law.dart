class CaseLaw {
  final String id;
  final String title;
  final String citation;
  final String court;
  final int? year;
  final String summary;

  const CaseLaw({
    required this.id,
    required this.title,
    required this.citation,
    required this.court,
    required this.year,
    required this.summary,
  });

  factory CaseLaw.fromMap(Map<String, dynamic> m) => CaseLaw(
        id: m['id'] as String,
        title: (m['title'] ?? '') as String,
        citation: (m['citation'] ?? '') as String,
        court: (m['court'] ?? '') as String,
        year: m['year'] as int?,
        summary: (m['summary'] ?? '') as String,
      );
}