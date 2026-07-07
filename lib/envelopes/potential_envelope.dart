import 'base_envelope.dart';

class PotentialEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmUserAuth;
  final String prmLike;

  PotentialEnvelope(this.prmBusCode, this.prmUserAuth, this.prmLike);

  @override
  String toXml() {
    String body = '''<GetDataPotential xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>$prmBusCode</prmBusCode>
      <prmUserAuth>$prmUserAuth</prmUserAuth>
      <prmLike>$prmLike</prmLike>
    </GetDataPotential>''';
    return wrapInEnvelope(body);
  }
}
