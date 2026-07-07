class Sales {
  final String? pref1;
  final String? pref2;
  final String? pref3;

  Sales({this.pref1, this.pref2, this.pref3});

  factory Sales.fromXml(Map<String, dynamic> xml) {
    return Sales(
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
