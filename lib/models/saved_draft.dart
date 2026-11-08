class SavedDraft {
  final String id;
  final String templateId;
  final String title;
  final Map<String, dynamic> formData;
  final DateTime createdAt;

  const SavedDraft({
    required this.id,
    required this.templateId,
    required this.title,
    required this.formData,
    required this.createdAt,
  });

  factory SavedDraft.fromMap(Map<String, dynamic> m) => SavedDraft(
    id: m['id'] as String,
    templateId: m['template_id'] as String,
    title: m['title'] as String,
    formData: Map<String, dynamic>.from(m['form_data'] as Map),
    createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
  );
}
