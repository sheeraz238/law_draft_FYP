import '../models/draft_template.dart';

class DraftService {
  static const tags = [
    'All',
    'Family',
    'Civil',
    'Criminal',
    'Bail',
    'Rent',
    'Constitutional',
  ];

  // Abhi sample data. Baad mein Supabase se aayega.
  static List<DraftCategory> getCategories() {
    return const [
      DraftCategory(
        id: 'important',
        name: 'Important Drafts',
        drafts: [
          DraftTemplate(
            id: 'written_statement',
            title: 'Written Statement / Objection',
            tag: 'Civil',
          ),
          DraftTemplate(
            id: 'khula_suit',
            title: 'Suit for Dissolution of Marriage (Khula)',
            tag: 'Family',
          ),
        ],
      ),
      DraftCategory(
        id: 'misc',
        name: 'Miscellaneous Applications',
        drafts: [
          DraftTemplate(id: 'notice', title: 'Notice', tag: 'Civil'),
          DraftTemplate(
            id: 'urgency_app',
            title: 'Application for Urgency',
            tag: 'Civil',
          ),
          DraftTemplate(
            id: 'return_surety',
            title: 'Application for Return of Surety',
            tag: 'Bail',
          ),
          DraftTemplate(
            id: 'change_surety',
            title: 'Application for Change of Surety',
            tag: 'Bail',
          ),
        ],
      ),
      DraftCategory(
        id: 'bail',
        name: 'Bail Applications',
        drafts: [
          DraftTemplate(
            id: 'pre_arrest_bail',
            title: 'Pre-Arrest Bail Application',
            tag: 'Bail',
          ),
          DraftTemplate(
            id: 'post_arrest_bail',
            title: 'Post-Arrest Bail Application',
            tag: 'Bail',
          ),
        ],
      ),
      DraftCategory(
        id: 'rent',
        name: 'Rent Matters',
        drafts: [
          DraftTemplate(
            id: 'eviction',
            title: 'Eviction Petition',
            tag: 'Rent',
          ),
        ],
      ),
      DraftCategory(
        id: 'constitutional',
        name: 'Constitutional',
        drafts: [
          DraftTemplate(
            id: 'const_petition',
            title: 'Constitutional Petition',
            tag: 'Constitutional',
          ),
        ],
      ),
    ];
  }
}
