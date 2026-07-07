class DataPotential {
  final String? pref1;
  final String? pref2;
  final String? pref3;
  final String? pref4;
  final String? pref5;
  final String? pref6;
  final String? pref7;
  final String? pref8;
  final String? pref9;
  final String? pref10;
  final String? pref11;
  final String? pref12;
  final String? pref13;
  final String? pref14;
  final String? pref15;
  final String? pref16;
  final String? pref17;

  DataPotential({
    this.pref1, this.pref2, this.pref3, this.pref4,
    this.pref5, this.pref6, this.pref7, this.pref8,
    this.pref9, this.pref10, this.pref11, this.pref12,
    this.pref13, this.pref14, this.pref15, this.pref16,
    this.pref17,
  });

  factory DataPotential.fromXml(Map<String, dynamic> xml) {
    return DataPotential(
      pref1: xml['Pref1'],
      pref2: xml['Pref2'],
      pref3: xml['Pref3'],
      pref4: xml['Pref4'],
      pref5: xml['Pref5'],
      pref6: xml['Pref6'],
      pref7: xml['Pref7'],
      pref8: xml['Pref8'],
      pref9: xml['Pref9'],
      pref10: xml['Pref10'],
      pref11: xml['Pref11'],
      pref12: xml['Pref12'],
      pref13: xml['Pref13'],
      pref14: xml['Pref14'],
      pref15: xml['Pref15'],
      pref16: xml['Pref16'],
      pref17: xml['Pref17'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Pref1': pref1, 'Pref2': pref2, 'Pref3': pref3, 'Pref4': pref4,
      'Pref5': pref5, 'Pref6': pref6, 'Pref7': pref7, 'Pref8': pref8,
      'Pref9': pref9, 'Pref10': pref10, 'Pref11': pref11, 'Pref12': pref12,
      'Pref13': pref13, 'Pref14': pref14, 'Pref15': pref15, 'Pref16': pref16,
      'Pref17': pref17,
    };
  }
}
