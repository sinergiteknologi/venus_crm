import 'base_envelope.dart';

class LoginDataEnvelope extends BaseVenusCRMEnvelope {
  final String sUser;
  final String sPwd;

  LoginDataEnvelope(this.sUser, this.sPwd);

  @override
  String toXml() {
    String body =
        '''<GetLogin xmlns="${BaseVenusCRMEnvelope.namespace}">
      <sUser>${BaseVenusCRMEnvelope.escape(sUser)}</sUser>
      <sPwd>${BaseVenusCRMEnvelope.escape(sPwd)}</sPwd>
    </GetLogin>''';
    return wrapInEnvelope(body);
  }
}
