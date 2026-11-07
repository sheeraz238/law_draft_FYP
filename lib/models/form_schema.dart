enum FieldType { text, multiline, dropdown, date, parties }

class FormFieldDef {
  final String key;
  final String label;
  final FieldType type;
  final bool required;
  final String? hint;
  final List<String> options;
  final String? typeLabel; // parties ke liye: "First party type" jaisa label

  const FormFieldDef({
    required this.key,
    required this.label,
    required this.type,
    this.required = true,
    this.hint,
    this.options = const [],
    this.typeLabel,
  });
}

class FormSectionDef {
  final String title;
  final List<FormFieldDef> fields;
  const FormSectionDef({required this.title, required this.fields});
}

class DraftSchema {
  final String id;
  final String title;
  final String description;
  final List<FormSectionDef> sections;
  const DraftSchema({
    required this.id,
    required this.title,
    required this.description,
    required this.sections,
  });
}
