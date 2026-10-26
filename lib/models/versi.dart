class Versi {
  final String? versi;

  Versi({this.versi});

  List<String> get _parts => (versi ?? '').split('/');

  int? get versionCode =>
      _parts.isNotEmpty ? int.tryParse(_parts.first.trim()) : null;

  String get versionName =>
      _parts.length > 1 ? _parts[1].trim() : (versi ?? '').trim();

  bool get isMandatory =>
      _parts.length > 2 && _parts[2].trim().toLowerCase() == 'true';

  bool get isValid => versionCode != null && _parts.length >= 2;

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
