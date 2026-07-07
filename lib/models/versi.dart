class Versi {
  final String? versi;

  Versi({this.versi});

  factory Versi.fromXml(Map<String, dynamic> xml) {
    return Versi(
      versi: xml['Versi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Versi': versi,
    };
  }
}
