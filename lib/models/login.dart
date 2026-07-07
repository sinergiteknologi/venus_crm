class Login {
  final String? pref1;
  final String? pref2;
  final String? pref3;
  final String? pref4;
  final String? pref5;
  final String? pref6;
  final String? pref7;
  final String? pref8;
  final String? pref9;

  Login({
    this.pref1,
    this.pref2,
    this.pref3,
    this.pref4,
    this.pref5,
    this.pref6,
    this.pref7,
    this.pref8,
    this.pref9,
  });

  factory Login.fromXml(Map<String, dynamic> xml) {
    return Login(
      pref1: xml['Pref1'],
      pref2: xml['Pref2'],
      pref3: xml['Pref3'],
      pref4: xml['Pref4'],
      pref5: xml['Pref5'],
      pref6: xml['Pref6'],
      pref7: xml['Pref7'],
      pref8: xml['Pref8'],
      pref9: xml['Pref9'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Pref1': pref1,
      'Pref2': pref2,
      'Pref3': pref3,
      'Pref4': pref4,
      'Pref5': pref5,
      'Pref6': pref6,
      'Pref7': pref7,
      'Pref8': pref8,
      'Pref9': pref9,
    };
  }
}
