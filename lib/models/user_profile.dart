class UserProfile {
  final String fullName;
  final String city;
  final String lawFirm;
  final String enrollmentNo;
  final String whatsapp;
  final int draftCredits;
  final int caselawCredits;

  const UserProfile({
    required this.fullName,
    required this.city,
    required this.lawFirm,
    required this.enrollmentNo,
    required this.whatsapp,
    required this.draftCredits,
    required this.caselawCredits,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    fullName: (m['full_name'] ?? '') as String,
    city: (m['city'] ?? '') as String,
    lawFirm: (m['law_firm'] ?? 'Individual') as String,
    enrollmentNo: (m['enrollment_no'] ?? '') as String,
    whatsapp: (m['whatsapp'] ?? '') as String,
    draftCredits: (m['draft_credits'] ?? 0) as int,
    caselawCredits: (m['caselaw_credits'] ?? 0) as int,
  );
}
