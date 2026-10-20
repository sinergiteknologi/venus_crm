import 'base_envelope.dart';

class PostContactEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmAccountID;
  final String prmLeadSourceCode;
  final String prmContactName;
  final String prmEmail;
  final String prmPhone;
  final String prmHomePhone;
  final String prmMobilePhone;
  final String prmFax;
  final String prmWebsite;
  final String prmAssistant;
  final String prmAssistantPhone;
  final String prmDateOfBirth;
  final String prmContactOwner;
  final String prmPCode;
  final String prmDescription;
  final String prmIsSuspend;
  final String prmUser;
  final String prmContactID;

  PostContactEnvelope({
    required this.prmBusCode,
    required this.prmAccountID,
    required this.prmLeadSourceCode,
    required this.prmContactName,
    required this.prmEmail,
    required this.prmPhone,
    required this.prmHomePhone,
    required this.prmMobilePhone,
    required this.prmFax,
    required this.prmWebsite,
    required this.prmAssistant,
    required this.prmAssistantPhone,
    required this.prmDateOfBirth,
    required this.prmContactOwner,
    required this.prmPCode,
    required this.prmDescription,
    required this.prmIsSuspend,
    required this.prmUser,
    required this.prmContactID,
  });

  @override
  String toXml() {
    final body = '''<PostDataContact xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>$prmBusCode</prmBusCode>
      <prmAccountID>$prmAccountID</prmAccountID>
      <prmLeadSourceCode>$prmLeadSourceCode</prmLeadSourceCode>
      <prmContactName>$prmContactName</prmContactName>
      <prmEmail>$prmEmail</prmEmail>
      <prmPhone>$prmPhone</prmPhone>
      <prmHomePhone>$prmHomePhone</prmHomePhone>
      <prmMobilePhone>$prmMobilePhone</prmMobilePhone>
      <prmFax>$prmFax</prmFax>
      <prmWebsite>$prmWebsite</prmWebsite>
      <prmAssistant>$prmAssistant</prmAssistant>
      <prmAssistantPhone>$prmAssistantPhone</prmAssistantPhone>
      <prmDateOfBirth>$prmDateOfBirth</prmDateOfBirth>
      <prmContactOwner>$prmContactOwner</prmContactOwner>
      <prmPCode>$prmPCode</prmPCode>
      <prmDescription>$prmDescription</prmDescription>
      <prmIsSuspend>$prmIsSuspend</prmIsSuspend>
      <prmUser>$prmUser</prmUser>
      <prmContactID>$prmContactID</prmContactID>
    </PostDataContact>''';
    return wrapInEnvelope(body);
  }
}
