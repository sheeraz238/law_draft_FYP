class GuideRef {
  final String id;
  final String title;
  const GuideRef(this.id, this.title);
}

class ChatAnswer {
  final String answer;
  final bool grounded;
  final List<GuideRef> guides;
  final List<String> draftIds;

  const ChatAnswer({
    required this.answer,
    required this.grounded,
    required this.guides,
    required this.draftIds,
  });
}
