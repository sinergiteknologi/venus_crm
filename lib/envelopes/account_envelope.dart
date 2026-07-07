import 'base_envelope.dart';

class AccountEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmUserAuth;
  final String prmLike;
  final String prmFromMenu;

  AccountEnvelope(this.prmBusCode, this.prmUserAuth, this.prmLike, this.prmFromMenu);

  @override
  String toXml() {
    String body = '''<GetDataAccount xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>$prmBusCode</prmBusCode>
      <prmUserAuth>$prmUserAuth</prmUserAuth>
      <prmLike>$prmLike</prmLike>
      <prmFromMenu>$prmFromMenu</prmFromMenu>
    </GetDataAccount>''';
    return wrapInEnvelope(body);
  }
}
