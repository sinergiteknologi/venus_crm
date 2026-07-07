abstract class BaseVenusCRMEnvelope {
  static const String namespace = "http://VenusCRM.org/";

  String wrapInEnvelope(String body) {
    return '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    $body
  </soap:Body>
</soap:Envelope>''';
  }

  String toXml();
}
