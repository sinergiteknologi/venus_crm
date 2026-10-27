import 'base_envelope.dart';

class PasswordEnvelope extends BaseVenusCRMEnvelope {
  final String prmUser;
  final String prmNewPassword;

  PasswordEnvelope(this.prmUser, this.prmNewPassword);

  @override
  String toXml() {
    final body =
        '''<UploadNewPassword xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmUser>${BaseVenusCRMEnvelope.escape(prmUser)}</prmUser>
      <prmNewPassword>${BaseVenusCRMEnvelope.escape(prmNewPassword)}</prmNewPassword>
    </UploadNewPassword>''';
    return wrapInEnvelope(body);
  }
}
