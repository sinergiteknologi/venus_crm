class DefaultFault {
  final String? errorMessage;
  final String? faultCode;
  final String? faultString;

  DefaultFault({this.errorMessage, this.faultCode, this.faultString});

  factory DefaultFault.fromXml(Map<String, dynamic> xml) {
    return DefaultFault(
      errorMessage: xml['ErrorMessage'],
      faultCode: xml['faultcode'],
      faultString: xml['faultstring'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ErrorMessage': errorMessage,
      'faultcode': faultCode,
      'faultstring': faultString,
    };
  }
}
