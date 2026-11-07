import '../models/form_schema.dart';

class SchemaService {
  // Abhi code mein. Baad mein Supabase (form_schema JSON) se aayega.
  static DraftSchema? getSchema(String id) {
    switch (id) {
      case 'notice':
        return _notice;
      default:
        return null;
    }
  }

  static const _notice = DraftSchema(
    id: 'notice',
    title: 'Notice',
    description: 'Notice application filed in court',
    sections: [
      FormSectionDef(
        title: 'Court Title',
        fields: [
          FormFieldDef(
            key: 'court_title',
            label: 'Court Title',
            type: FieldType.text,
            hint: 'e.g. IN THE COURT OF SENIOR CIVIL JUDGE',
          ),
        ],
      ),
      FormSectionDef(
        title: 'Case Type',
        fields: [
          FormFieldDef(
            key: 'case_type',
            label: 'Case Type',
            type: FieldType.dropdown,
            options: [
              'Constitutional Petition',
              'Civil Suit',
              'Family Case',
              'Criminal Case',
            ],
          ),
        ],
      ),
      FormSectionDef(
        title: 'First Party / Plaintiff',
        fields: [
          FormFieldDef(
            key: 'first_party',
            label: 'First Party',
            type: FieldType.parties,
            typeLabel: 'First Party Type',
            options: ['Petitioner', 'Plaintiff', 'Appellant', 'Applicant'],
          ),
        ],
      ),
      FormSectionDef(
        title: 'Second Party / Defendant',
        fields: [
          FormFieldDef(
            key: 'second_party',
            label: 'Second Party',
            type: FieldType.parties,
            typeLabel: 'Second Party Type',
            options: ['Respondent', 'Defendant'],
          ),
        ],
      ),
      FormSectionDef(
        title: 'Suit Details',
        fields: [
          FormFieldDef(
            key: 'suit_type',
            label: 'Suit Type',
            type: FieldType.dropdown,
            options: [
              'Suit for Dissolution of Marriage (Khula)',
              'Suit for Recovery',
              'Suit for Declaration',
              'Suit for Permanent Injunction',
            ],
          ),
        ],
      ),
      FormSectionDef(
        title: 'Via of Notice',
        fields: [
          FormFieldDef(
            key: 'statement_type',
            label: 'Statement Type',
            type: FieldType.dropdown,
            options: ['Written Statement', 'Objection Statement'],
          ),
        ],
      ),
      FormSectionDef(
        title: 'Hearing and Order Details',
        fields: [
          FormFieldDef(
            key: 'appearance_date',
            label: 'Appearance Date',
            type: FieldType.date,
          ),
          FormFieldDef(
            key: 'order_for',
            label: 'Order For',
            type: FieldType.dropdown,
            options: ['Reader', 'Court'],
          ),
        ],
      ),
      FormSectionDef(
        title: 'Court Name',
        fields: [
          FormFieldDef(
            key: 'court_name',
            label: 'Court Name',
            type: FieldType.text,
            hint: 'e.g. Family Court Hyderabad',
          ),
        ],
      ),
    ],
  );
}
