class Helpline {
  final String name;
  final String number;
  final String category;
  final String note;
  final String source;
  final String sourceUrl;
  const Helpline(
    this.name,
    this.number,
    this.category,
    this.note,
    this.source,
    this.sourceUrl,
  );
}

const helplinesCheckedOn = '22 Nov 2026';

const helplineCategories = [
  'Emergency',
  'Free legal help',
  'Women and children',
];

const _unWomen =
    'https://asiapacific.unwomen.org/en/countries/pakistan/evaw-pakistan/emergency-contacts';

const helplines = [
  Helpline(
    'Police emergency',
    '15',
    'Emergency',
    'For immediate danger. In Sindh it is also published as Madadgar 15.',
    'UN Women, emergency contacts',
    _unWomen,
  ),
  Helpline(
    'Rescue 1122',
    '1122',
    'Emergency',
    'Emergency medical, rescue and fire service. It is a provincial service, so check that it works in your district.',
    'UN Women, emergency contacts',
    _unWomen,
  ),
  Helpline(
    'Edhi ambulance',
    '115',
    'Emergency',
    'Ambulance service of the Edhi Foundation.',
    'UN Women, emergency contacts',
    _unWomen,
  ),
  Helpline(
    'Sindh Legal Advisory Call Centre',
    '0800-70806',
    'Free legal help',
    'Free legal advice by phone, run by the Legal Aid Society. Call timings can change, so confirm on their website.',
    'Legal Aid Society',
    'https://las.org.pk/accesstojustice',
  ),
  Helpline(
    'Ministry of Human Rights helpline',
    '1099',
    'Free legal help',
    'Toll-free helpline for free legal advice and complaints about human rights violations. Timings can change.',
    'Ministry of Human Rights',
    'https://mohr.gov.pk/Detail/YWRiYjU0NzktMGE2Zi00NDYyLTljNzktMTA2N2M2MjBlZWZl',
  ),
  Helpline(
    'Madadgar helpline',
    '1098',
    'Women and children',
    'Helpline for women and children who face violence or abuse.',
    'UN Women, emergency contacts',
    _unWomen,
  ),
];
