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
    final body =
        '''<PostDataContact xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>${BaseVenusCRMEnvelope.escape(prmBusCode)}</prmBusCode>
      <prmAccountID>${BaseVenusCRMEnvelope.escape(prmAccountID)}</prmAccountID>
      <prmLeadSourceCode>${BaseVenusCRMEnvelope.escape(prmLeadSourceCode)}</prmLeadSourceCode>
      <prmContactName>${BaseVenusCRMEnvelope.escape(prmContactName)}</prmContactName>
      <prmEmail>${BaseVenusCRMEnvelope.escape(prmEmail)}</prmEmail>
      <prmPhone>${BaseVenusCRMEnvelope.escape(prmPhone)}</prmPhone>
      <prmHomePhone>${BaseVenusCRMEnvelope.escape(prmHomePhone)}</prmHomePhone>
      <prmMobilePhone>${BaseVenusCRMEnvelope.escape(prmMobilePhone)}</prmMobilePhone>
      <prmFax>${BaseVenusCRMEnvelope.escape(prmFax)}</prmFax>
      <prmWebsite>${BaseVenusCRMEnvelope.escape(prmWebsite)}</prmWebsite>
      <prmAssistant>${BaseVenusCRMEnvelope.escape(prmAssistant)}</prmAssistant>
      <prmAssistantPhone>${BaseVenusCRMEnvelope.escape(prmAssistantPhone)}</prmAssistantPhone>
      <prmDateOfBirth>${BaseVenusCRMEnvelope.escape(prmDateOfBirth)}</prmDateOfBirth>
      <prmContactOwner>${BaseVenusCRMEnvelope.escape(prmContactOwner)}</prmContactOwner>
      <prmPCode>${BaseVenusCRMEnvelope.escape(prmPCode)}</prmPCode>
      <prmDescription>${BaseVenusCRMEnvelope.escape(prmDescription)}</prmDescription>
      <prmIsSuspend>${BaseVenusCRMEnvelope.escape(prmIsSuspend)}</prmIsSuspend>
      <prmUser>${BaseVenusCRMEnvelope.escape(prmUser)}</prmUser>
      <prmContactID>${BaseVenusCRMEnvelope.escape(prmContactID)}</prmContactID>
    </PostDataContact>''';
    return wrapInEnvelope(body);
  }
}
