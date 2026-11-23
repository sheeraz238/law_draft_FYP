class RightsCard {
  final String title;
  final String article;
  final List<String> points;
  final String note;
  const RightsCard(this.title, this.article, this.points, this.note);
}

const rightsSourceUrl =
    'https://pakistani.org/pakistan/constitution/part2.ch1.html';

const rightsCards = [
  RightsCard(
    'If you are arrested',
    'Article 10',
    [
      'You must be told the reasons for your arrest as soon as possible.',
      'You have the right to consult a lawyer of your choice and to be defended by him.',
      'You must be brought before a magistrate within 24 hours of your arrest, not counting the time needed to travel.',
      'You cannot be kept in custody for longer than that without the magistrate allowing it.',
    ],
    'Laws on preventive detention follow different rules. Speak to a lawyer as early as you can.',
  ),
  RightsCard(
    'Fair trial',
    'Article 10A',
    [
      'When you are charged with a crime, or when your civil rights and duties are being decided, you are entitled to a fair trial and due process.',
    ],
    'What a fair trial means in your own case is a question for your lawyer.',
  ),
  RightsCard(
    'Life, liberty, dignity and privacy',
    'Articles 9 and 14',
    [
      'Nobody can be deprived of life or liberty except in accordance with law.',
      'The dignity of a person and, subject to law, the privacy of the home are protected.',
      'Nobody may be tortured to extract evidence.',
    ],
    'If your rights are violated, write down the date, place and names, and speak to a lawyer or a legal aid helpline.',
  ),
  RightsCard(
    'Self-incrimination and double punishment',
    'Article 13',
    [
      'A person cannot be punished or prosecuted twice for the same offence.',
      'A person accused of an offence cannot be forced to be a witness against himself.',
    ],
    'Ask a lawyer how this applies before you answer questions.',
  ),
  RightsCard(
    'Treated according to law',
    'Article 4',
    [
      'Every citizen has the right to the protection of law and to be treated in accordance with law.',
      'No action that harms the life, liberty, body, reputation or property of a person can be taken except in accordance with law.',
    ],
    'This is the base of many other rights. A lawyer can tell you how it applies to your situation.',
  ),
];
