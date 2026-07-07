class Business {
  final String? code;
  final String? name;

  Business({
    this.code,
    this.name,
  });

  factory Business.fromXml(Map<String, dynamic> xml) {
    
    return Business(
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
