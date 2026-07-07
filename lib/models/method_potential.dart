class MethodPotential {
  final String? code;
  final String? name;

  MethodPotential({this.code, this.name});

  factory MethodPotential.fromXml(Map<String, dynamic> xml) {
    return MethodPotential(
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
