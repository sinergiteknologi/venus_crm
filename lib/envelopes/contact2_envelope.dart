import 'base_envelope.dart';

class Contact2Envelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmUserAuth;
  final String prmAccount;
  final String prmLike;

  Contact2Envelope(
    this.prmBusCode,
    this.prmUserAuth,
    this.prmAccount,
    this.prmLike,
  );

  @override
  String toXml() {
    final body =
        '''<GetDataContact2 xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>${BaseVenusCRMEnvelope.escape(prmBusCode)}</prmBusCode>
      <prmUserAuth>${BaseVenusCRMEnvelope.escape(prmUserAuth)}</prmUserAuth>
      <prmAccount>${BaseVenusCRMEnvelope.escape(prmAccount)}</prmAccount>
      <prmLike>${BaseVenusCRMEnvelope.escape(prmLike)}</prmLike>
    </GetDataContact2>''';
    return wrapInEnvelope(body);
  }
}
