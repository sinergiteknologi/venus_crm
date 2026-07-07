import 'base_envelope.dart';

class PostContactEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmContactID;
  final String prmAccountCode;
  final String prmContactName;
  final String prmPositionCode;
  final String prmOwner;
  final String prmEmail;
  final String prmPhone;
  final String prmMobile;
  final String prmDivision;
  final String prmEmailAlt;
  final String prmBirthDay;
  final String prmReligion;
  final String prmLeadSourceCode;
  final String prmDescription;
  final String prmIsSuspend;
  final String prmUser;

  PostContactEnvelope({
    required this.prmBusCode,
    required this.prmContactID,
    required this.prmAccountCode,
    required this.prmContactName,
    required this.prmPositionCode,
    required this.prmOwner,
    required this.prmEmail,
    required this.prmPhone,
    required this.prmMobile,
    required this.prmDivision,
    required this.prmEmailAlt,
    required this.prmBirthDay,
    required this.prmReligion,
    required this.prmLeadSourceCode,
    required this.prmDescription,
    required this.prmIsSuspend,
    required this.prmUser,
  });

  @override
  String toXml() {
    final body = '''<PostDataContact xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>$prmBusCode</prmBusCode>
      <prmContactID>$prmContactID</prmContactID>
      <prmAccountCode>$prmAccountCode</prmAccountCode>
      <prmContactName>$prmContactName</prmContactName>
      <prmPositionCode>$prmPositionCode</prmPositionCode>
      <prmOwner>$prmOwner</prmOwner>
      <prmEmail>$prmEmail</prmEmail>
      <prmPhone>$prmPhone</prmPhone>
      <prmMobile>$prmMobile</prmMobile>
      <prmDivision>$prmDivision</prmDivision>
      <prmEmailAlt>$prmEmailAlt</prmEmailAlt>
      <prmBirthDay>$prmBirthDay</prmBirthDay>
      <prmReligion>$prmReligion</prmReligion>
      <prmLeadSourceCode>$prmLeadSourceCode</prmLeadSourceCode>
      <prmDescription>$prmDescription</prmDescription>
      <prmIsSuspend>$prmIsSuspend</prmIsSuspend>
      <prmUser>$prmUser</prmUser>
    </PostDataContact>''';
    return wrapInEnvelope(body);
  }
}
