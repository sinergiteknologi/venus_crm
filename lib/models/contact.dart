class Contact {
  final String? pref1;
  final String? pref2;
  final String? pref3;
  final String? pref4;

  Contact({
    this.pref1,
    this.pref2,
    this.pref3,
    this.pref4,
  });

  factory Contact.fromXml(Map<String, dynamic> xml) {
    return Contact(
      pref1: xml['Pref1'],
      pref2: xml['Pref2'],
      pref3: xml['Pref3'],
      pref4: xml['Pref4'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Pref1': pref1,
      'Pref2': pref2,
      'Pref3': pref3,
      'Pref4': pref4,
    };
  }
}
