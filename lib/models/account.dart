class Account {
  final String? code;
  final String? name;

  Account({
    this.code,
    this.name,
  });

  factory Account.fromXml(Map<String, dynamic> xml) {
    return Account(
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
