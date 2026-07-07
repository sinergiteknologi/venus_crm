class LOB {
  final String? code;
  final String? name;

  LOB({this.code, this.name});

  factory LOB.fromXml(Map<String, dynamic> xml) {
    return LOB(
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
