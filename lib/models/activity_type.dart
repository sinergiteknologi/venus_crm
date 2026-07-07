class ActivityType {
  final String? pref1;
  final String? pref2;
  final String? pref3;

  ActivityType({
    this.pref1,
    this.pref2,
    this.pref3,
  });

  factory ActivityType.fromXml(Map<String, dynamic> xml) {
    return ActivityType(
      pref1: xml['Pref1'],
      pref2: xml['Pref2'],
      pref3: xml['Pref3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Pref1': pref1,
      'Pref2': pref2,
      'Pref3': pref3,
    };
  }
}
