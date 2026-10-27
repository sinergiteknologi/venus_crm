import 'base_envelope.dart';

class AccountEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmUserAuth;
  final String prmLike;
  final String prmFromMenu;

  AccountEnvelope(
    this.prmBusCode,
    this.prmUserAuth,
    this.prmLike,
    this.prmFromMenu,
  );

  @override
  String toXml() {
    String body =
        '''<GetDataAccount xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>${BaseVenusCRMEnvelope.escape(prmBusCode)}</prmBusCode>
      <prmUserAuth>${BaseVenusCRMEnvelope.escape(prmUserAuth)}</prmUserAuth>
      <prmLike>${BaseVenusCRMEnvelope.escape(prmLike)}</prmLike>
      <prmFromMenu>${BaseVenusCRMEnvelope.escape(prmFromMenu)}</prmFromMenu>
    </GetDataAccount>''';
    return wrapInEnvelope(body);
  }
}
