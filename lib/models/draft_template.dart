class DraftTemplate {
  final String id;
  final String title;
  final String tag;
  const DraftTemplate({
    required this.id,
    required this.title,
    required this.tag,
  });
}

class DraftCategory {
  final String id;
  final String name;
  final List<DraftTemplate> drafts;
  const DraftCategory({
    required this.id,
    required this.name,
    required this.drafts,
  });
}
