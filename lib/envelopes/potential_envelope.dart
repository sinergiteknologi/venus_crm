import 'base_envelope.dart';

class PotentialEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmUserAuth;
  final String prmLike;

  PotentialEnvelope(this.prmBusCode, this.prmUserAuth, this.prmLike);

  @override
  String toXml() {
    String body =
        '''<GetDataPotential xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>${BaseVenusCRMEnvelope.escape(prmBusCode)}</prmBusCode>
      <prmUserAuth>${BaseVenusCRMEnvelope.escape(prmUserAuth)}</prmUserAuth>
      <prmLike>${BaseVenusCRMEnvelope.escape(prmLike)}</prmLike>
    </GetDataPotential>''';
    return wrapInEnvelope(body);
  }
}
