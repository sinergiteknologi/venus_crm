class Position {
  final String? code;
  final String? name;

  Position({this.code, this.name});

  factory Position.fromXml(Map<String, dynamic> xml) {
    return Position(
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
