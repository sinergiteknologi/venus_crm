class DataContact2 {
  final String? pref1;
  final String? pref2;
  final String? pref3;
  final String? pref4;
  final String? pref5;

  const DataContact2({
    this.pref1,
    this.pref2,
    this.pref3,
    this.pref4,
    this.pref5,
  });

  factory DataContact2.fromXml(Map<String, dynamic> xml) {
    return DataContact2(
      pref1: xml['Pref1'],
      pref2: xml['Pref2'],
      pref3: xml['Pref3'],
      pref4: xml['Pref4'],
      pref5: xml['Pref5'],
    );
  }
}
