import 'base_envelope.dart';

class PasswordEnvelope extends BaseVenusCRMEnvelope {
  final String prmUser;
  final String prmNewPassword;

  PasswordEnvelope(this.prmUser, this.prmNewPassword);

  @override
  String toXml() {
    final body = '''<UploadNewPassword xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmUser>$prmUser</prmUser>
      <prmNewPassword>$prmNewPassword</prmNewPassword>
    </UploadNewPassword>''';
    return wrapInEnvelope(body);
  }
}
