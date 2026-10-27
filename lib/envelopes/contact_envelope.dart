import 'base_envelope.dart';

class ContactEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmUserAuth;
  final String prmLike;

  ContactEnvelope(this.prmBusCode, this.prmUserAuth, this.prmLike);

  @override
  String toXml() {
    String body =
        '''<GetDataContact xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>${BaseVenusCRMEnvelope.escape(prmBusCode)}</prmBusCode>
      <prmUserAuth>${BaseVenusCRMEnvelope.escape(prmUserAuth)}</prmUserAuth>
      <prmLike>${BaseVenusCRMEnvelope.escape(prmLike)}</prmLike>
    </GetDataContact>''';
    return wrapInEnvelope(body);
  }
}
