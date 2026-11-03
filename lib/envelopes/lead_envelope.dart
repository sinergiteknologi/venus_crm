import 'base_envelope.dart';

class LeadEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmUserAuth;
  final String prmLike;

  LeadEnvelope(this.prmBusCode, this.prmUserAuth, this.prmLike);

  @override
  String toXml() {
    String body =
        '''<GetDataLead xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>${BaseVenusCRMEnvelope.escape(prmBusCode)}</prmBusCode>
      <prmUserAuth>${BaseVenusCRMEnvelope.escape(prmUserAuth)}</prmUserAuth>
      <prmLike>${BaseVenusCRMEnvelope.escape(prmLike)}</prmLike>
    </GetDataLead>''';
    return wrapInEnvelope(body);
  }
}
