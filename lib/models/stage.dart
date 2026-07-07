class Stage {
  final String? code;
  final String? name;

  Stage({this.code, this.name});

  factory Stage.fromXml(Map<String, dynamic> xml) {
    return Stage(
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
