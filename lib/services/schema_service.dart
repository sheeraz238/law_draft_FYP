import '../models/form_schema.dart';
import 'template_store.dart';

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
              case 'return_surety':
        return _returnSurety;
      case 'eviction':
        return _eviction;
      case 'written_statement':
        return _writtenStatement;
        
            default:
        return TemplateStore.schemaFor(id);
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
    // --- Return of Surety ---
  static final _returnSurety = DraftSchema(
    id: 'return_surety',
    title: 'Application for Return of Surety',
    description:
        'Application by a surety asking the court to discharge the surety and return the documents',
    sections: [
      _courtName('e.g. Court of Sessions Judge Hyderabad'),
      _party('Applicant (Surety)', 'first_party', ['Applicant']),
      FormSectionDef(
        title: 'Case Details',
        fields: [
          FormFieldDef(
            key: 'accused_name',
            label: 'Name of the Accused',
            type: FieldType.text,
          ),
          FormFieldDef(
            key: 'fir_no',
            label: 'FIR No.',
            type: FieldType.text,
            hint: 'e.g. 123/2026',
          ),
          FormFieldDef(
            key: 'police_station',
            label: 'Police Station',
            type: FieldType.text,
          ),
          FormFieldDef(
            key: 'bail_order_date',
            label: 'Date of Bail Order',
            type: FieldType.date,
          ),
        ],
      ),
      FormSectionDef(
        title: 'Surety Details',
        fields: [
          FormFieldDef(
            key: 'surety_amount',
            label: 'Surety Amount (PKR)',
            type: FieldType.text,
            hint: 'e.g. 100,000',
          ),
          FormFieldDef(
            key: 'surety_documents',
            label: 'Documents furnished as surety',
            type: FieldType.text,
            hint: 'e.g. property papers and CNIC copy',
          ),
          FormFieldDef(
            key: 'return_reason',
            label: 'Reason for return of surety',
            type: FieldType.multiline,
            hint: 'e.g. the case has been decided and the trial has concluded',
          ),
        ],
      ),
    ],
  );

  // --- Eviction Petition ---
  static final _eviction = DraftSchema(
    id: 'eviction',
    title: 'Eviction Petition',
    description:
        'Petition by a landlord asking for eviction of a tenant from rented premises',
    sections: [
      _courtName('e.g. Rent Controller Hyderabad'),
      _party('Landlord (Petitioner)', 'first_party', [
        'Petitioner',
        'Applicant',
      ]),
      _party('Tenant (Respondent)', 'second_party', ['Respondent']),
      FormSectionDef(
        title: 'Rented Premises',
        fields: [
          FormFieldDef(
            key: 'premises_address',
            label: 'Address of the rented premises',
            type: FieldType.multiline,
          ),
          FormFieldDef(
            key: 'premises_type',
            label: 'Type of premises',
            type: FieldType.dropdown,
            options: ['Residential house', 'Flat', 'Shop', 'Office', 'Other'],
          ),
          FormFieldDef(
            key: 'monthly_rent',
            label: 'Monthly rent (PKR)',
            type: FieldType.text,
            hint: 'e.g. 25,000',
          ),
          FormFieldDef(
            key: 'tenancy_start',
            label: 'Tenancy started on',
            type: FieldType.date,
          ),
        ],
      ),
      FormSectionDef(
        title: 'Ground for Eviction',
        fields: [
          FormFieldDef(
            key: 'ground',
            label: 'Main ground',
            type: FieldType.dropdown,
            options: [
              'Default in payment of rent',
              'Personal need of the landlord',
              'Sub-letting without permission',
              'Other',
            ],
          ),
          FormFieldDef(
            key: 'ground_details',
            label: 'Details of the ground',
            type: FieldType.multiline,
            hint: 'e.g. rent has not been paid since January 2026',
          ),
          FormFieldDef(
            key: 'notice_date',
            label: 'Date of notice sent to the tenant (if any)',
            type: FieldType.text,
            required: false,
            hint: 'e.g. 05/03/2026',
          ),
        ],
      ),
    ],
  );

  // --- Written Statement ---
  static final _writtenStatement = DraftSchema(
    id: 'written_statement',
    title: 'Written Statement / Objection',
    description:
        'Reply by the defendant to a civil suit, with objections and a para-wise reply',
    sections: [
      _courtName('e.g. Senior Civil Judge Hyderabad'),
      FormSectionDef(
        title: 'Suit Details',
        fields: [
          FormFieldDef(
            key: 'suit_no',
            label: 'Suit No.',
            type: FieldType.text,
            hint: 'e.g. 123/2026',
          ),
          FormFieldDef(
            key: 'suit_nature',
            label: 'Nature of the suit',
            type: FieldType.text,
            hint: 'e.g. Suit for Recovery',
          ),
        ],
      ),
      _party('Plaintiff', 'first_party', ['Plaintiff', 'Petitioner']),
      _party('Defendant', 'second_party', ['Defendant', 'Respondent']),
      FormSectionDef(
        title: 'Preliminary Objections',
        fields: [
          FormFieldDef(
            key: 'objections',
            label: 'Objections (one point per line)',
            type: FieldType.multiline,
          ),
        ],
      ),
      FormSectionDef(
        title: 'Reply on Facts',
        fields: [
          FormFieldDef(
            key: 'reply',
            label: 'Para-wise reply (one point per line)',
            type: FieldType.multiline,
            hint: 'Keep the same order as the plaint',
          ),
          FormFieldDef(
            key: 'additional_facts',
            label: 'Additional facts (one point per line, if any)',
            type: FieldType.multiline,
            required: false,
          ),
        ],
      ),
    ],
  );
}
