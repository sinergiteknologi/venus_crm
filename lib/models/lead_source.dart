class LeadSource {
  final String? code;
  final String? name;

  LeadSource({this.code, this.name});

  factory LeadSource.fromXml(Map<String, dynamic> xml) {
    return LeadSource(
      code: xml['Code'],
      name: xml['Name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Code': code,
      'Name': name,
    };
  }
}
