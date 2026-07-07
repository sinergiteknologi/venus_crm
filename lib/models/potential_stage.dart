class PotentialStage {
  final String? pref1;
  final String? pref2;
  final String? pref3;
  final String? pref4;
  final String? pref5;

  PotentialStage({
    this.pref1, this.pref2, this.pref3, this.pref4, this.pref5,
  });

  factory PotentialStage.fromXml(Map<String, dynamic> xml) {
    return PotentialStage(
      pref1: xml['Pref1'],
      pref2: xml['Pref2'],
      pref3: xml['Pref3'],
      pref4: xml['Pref4'],
      pref5: xml['Pref5'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Pref1': pref1, 'Pref2': pref2, 'Pref3': pref3, 'Pref4': pref4, 'Pref5': pref5,
    };
  }
}
