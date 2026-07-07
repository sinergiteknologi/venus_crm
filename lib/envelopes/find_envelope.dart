import 'base_envelope.dart';

class FindEnvelope extends BaseVenusCRMEnvelope {
  final String methodName;
  final String prmBusCode;
  final String prmUserAuth;
  final String prmType;
  final String prmValue;
  final String prmDate1;
  final String prmDate2;

  FindEnvelope({
    required this.methodName,
    required this.prmBusCode,
    required this.prmUserAuth,
    required this.prmType,
    required this.prmValue,
    required this.prmDate1,
    required this.prmDate2,
  });

  @override
  String toXml() {
    String body = '''<$methodName xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>$prmBusCode</prmBusCode>
      <prmUserAuth>$prmUserAuth</prmUserAuth>
      <prmType>$prmType</prmType>
      <prmValue>$prmValue</prmValue>
      <prmDate1>$prmDate1</prmDate1>
      <prmDate2>$prmDate2</prmDate2>
    </$methodName>''';
    return wrapInEnvelope(body);
  }
}
