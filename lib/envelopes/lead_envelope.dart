import 'base_envelope.dart';

class LeadEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmUserAuth;
  final String prmLike;

  LeadEnvelope(this.prmBusCode, this.prmUserAuth, this.prmLike);

  @override
  String toXml() {
    String body =
        '''<GetLead xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>${BaseVenusCRMEnvelope.escape(prmBusCode)}</prmBusCode>
      <prmUserAuth>${BaseVenusCRMEnvelope.escape(prmUserAuth)}</prmUserAuth>
      <prmLike>${BaseVenusCRMEnvelope.escape(prmLike)}</prmLike>
    </GetLead>''';
    return wrapInEnvelope(body);
  }
}
