class CaseLaw {
  final String id;
  final String title;
  final String citation;
  final String court;
  final int? year;
  final String summary;
    final String? sourceUrl;
  final String? topic;

  const CaseLaw({
    required this.id,
    required this.title,
    required this.citation,
    required this.court,
    required this.year,
    required this.summary,
        this.sourceUrl,
    this.topic,
  });

  factory CaseLaw.fromMap(Map<String, dynamic> m) => CaseLaw(
        id: m['id'] as String,
        title: (m['title'] ?? '') as String,
        citation: (m['citation'] ?? '') as String,
        court: (m['court'] ?? '') as String,
        year: m['year'] as int?,
        summary: (m['summary'] ?? '') as String,
                sourceUrl: m['source_url'] as String?,
    topic: m['topic'] as String?,
      );
}