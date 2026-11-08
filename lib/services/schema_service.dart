import '../models/form_schema.dart';

class SchemaService {
  // Abhi code mein. Baad mein Supabase (form_schema JSON) se aayega.
  static DraftSchema? getSchema(String id) {
        switch (id) {
      case 'notice':
        return _notice;
      case 'khula_suit':
        return _khula;
      case 'pre_arrest_bail':
        return _preArrestBail;
      case 'post_arrest_bail':
        return _postArrestBail;
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
    // --- Common blocks ---
  static FormSectionDef _courtName(String hint) => FormSectionDef(
    title: 'Court Name',
    fields: [
      FormFieldDef(
        key: 'court_name',
        label: 'Court Name',
        type: FieldType.text,
        hint: hint,
      ),
    ],
  );

  static FormSectionDef _party(
    String title,
    String key,
    List<String> options,
  ) => FormSectionDef(
    title: title,
    fields: [
      FormFieldDef(
        key: key,
        label: title,
        type: FieldType.parties,
        typeLabel: 'Party Type',
        options: options,
      ),
    ],
  );

  // --- Khula ---
  static final _khula = DraftSchema(
    id: 'khula_suit',
    title: 'Suit for Dissolution of Marriage (Khula)',
    description: 'Plaint for dissolution of marriage on the basis of khula',
    sections: [
      _courtName('e.g. Family Court Hyderabad'),
      _party('Plaintiff (Wife)', 'first_party', ['Plaintiff']),
      _party('Defendant (Husband)', 'second_party', ['Defendant']),
      FormSectionDef(
        title: 'Marriage Details',
        fields: [
          FormFieldDef(
            key: 'marriage_date',
            label: 'Date of Marriage',
            type: FieldType.date,
          ),
          FormFieldDef(
            key: 'marriage_place',
            label: 'Place of Marriage',
            type: FieldType.text,
            hint: 'e.g. Hyderabad',
          ),
          FormFieldDef(
            key: 'dower',
            label: 'Dower (Haq Mehr)',
            type: FieldType.text,
            hint: 'e.g. Rs. 100,000',
          ),
          FormFieldDef(
            key: 'dower_status',
            label: 'Dower Status',
            type: FieldType.dropdown,
            options: ['Paid', 'Partly paid', 'Unpaid'],
          ),
          FormFieldDef(
            key: 'children',
            label: 'Children from the marriage (if any)',
            type: FieldType.text,
            required: false,
            hint: 'e.g. One son aged 5 years',
          ),
        ],
      ),
      FormSectionDef(
        title: 'Separation and Grounds',
        fields: [
          FormFieldDef(
            key: 'separation_date',
            label: 'Living separately since',
            type: FieldType.date,
          ),
          FormFieldDef(
            key: 'grounds',
            label: 'Grounds for Khula',
            type: FieldType.multiline,
            hint: 'Briefly describe why the marriage cannot continue',
          ),
        ],
      ),
    ],
  );

  // --- Bail ---
  static final List<FormSectionDef> _bailBase = [
    _courtName('e.g. Court of Sessions Judge Hyderabad'),
    _party('Applicant (Accused)', 'first_party', ['Applicant', 'Petitioner']),
    FormSectionDef(
      title: 'FIR Details',
      fields: [
        FormFieldDef(
          key: 'fir_no',
          label: 'FIR No.',
          type: FieldType.text,
          hint: 'e.g. 123/2026',
        ),
        FormFieldDef(key: 'fir_date', label: 'FIR Date', type: FieldType.date),
        FormFieldDef(
          key: 'police_station',
          label: 'Police Station',
          type: FieldType.text,
        ),
        FormFieldDef(
          key: 'offences',
          label: 'Offence Sections',
          type: FieldType.text,
          hint: 'e.g. 302, 34 PPC',
        ),
      ],
    ),
    FormSectionDef(
      title: 'Complainant',
      fields: [
        FormFieldDef(
          key: 'complainant',
          label: 'Complainant Name',
          type: FieldType.text,
          required: false,
        ),
      ],
    ),
    FormSectionDef(
      title: 'Grounds for Bail',
      fields: [
        FormFieldDef(
          key: 'bail_grounds',
          label: 'Grounds',
          type: FieldType.multiline,
          hint: 'e.g. no direct role, delay in FIR, false implication',
        ),
      ],
    ),
  ];

  static final _preArrestBail = DraftSchema(
    id: 'pre_arrest_bail',
    title: 'Pre-Arrest Bail Application',
    description: 'Application for pre-arrest bail',
    sections: [..._bailBase],
  );

  static final _postArrestBail = DraftSchema(
    id: 'post_arrest_bail',
    title: 'Post-Arrest Bail Application',
    description: 'Application for post-arrest bail',
    sections: [
      ..._bailBase,
      FormSectionDef(
        title: 'Arrest Details',
        fields: [
          FormFieldDef(
            key: 'arrest_date',
            label: 'Date of Arrest',
            type: FieldType.date,
          ),
          FormFieldDef(
            key: 'custody_place',
            label: 'Place of Custody',
            type: FieldType.text,
            hint: 'e.g. District Jail Hyderabad',
          ),
        ],
      ),
    ],
  );
}
