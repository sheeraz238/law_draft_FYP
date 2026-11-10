class GuideStep {
  final String title;
  final String detail;
  const GuideStep(this.title, this.detail);
}

class LegalGuide {
  final String id;
  final String topic;
  final String title;
  final String summary;
  final List<GuideStep> steps;
  final List<String> documents;
  final List<String> draftIds;
  final List<String> keywords;
  final String? reviewedBy;
  final DateTime? reviewedOn;

  const LegalGuide({
    required this.id,
    required this.topic,
    required this.title,
    required this.summary,
    required this.steps,
    required this.documents,
    required this.draftIds,
    required this.keywords,
    required this.reviewedBy,
    required this.reviewedOn,
  });

  factory LegalGuide.fromMap(Map<String, dynamic> m) {
    List asList(dynamic v) => (v is List) ? v : const [];
    return LegalGuide(
      id: m['id'] as String,
      topic: (m['topic'] ?? '') as String,
      title: (m['title'] ?? '') as String,
      summary: (m['summary'] ?? '') as String,
      steps: asList(m['steps'])
          .map<GuideStep>(
            (s) => GuideStep('${s['title'] ?? ''}', '${s['detail'] ?? ''}'),
          )
          .toList(),
      documents: asList(m['documents']).map<String>((e) => '$e').toList(),
      draftIds: asList(m['draft_ids']).map<String>((e) => '$e').toList(),
      keywords: asList(m['keywords']).map<String>((e) => '$e').toList(),
      reviewedBy: m['reviewed_by'] as String?,
      reviewedOn: m['reviewed_on'] == null
          ? null
          : DateTime.tryParse('${m['reviewed_on']}'),
    );
  }
}
