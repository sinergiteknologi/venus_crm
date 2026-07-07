class LeadStatus {
  final String? code;
  final String? name;

  LeadStatus({this.code, this.name});

  factory LeadStatus.fromXml(Map<String, dynamic> xml) {
    return LeadStatus(
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
