class DataLead {
  final Map<String, String?> prefs;

  DataLead({required this.prefs});

  factory DataLead.fromXml(Map<String, dynamic> xml) {
    Map<String, String?> prefs = {};
    for (int i = 1; i <= 21; i++) {
      prefs['Pref$i'] = xml['Pref$i'];
    }
    return DataLead(prefs: prefs);
  }

  Map<String, dynamic> toJson() {
    return prefs;
  }

  // Helper getters for convenience
  String? get pref1 => prefs['Pref1'];
  String? get pref2 => prefs['Pref2'];
  // ... and so on if needed
}
