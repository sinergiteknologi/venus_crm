import 'base_envelope.dart';

class PostLeadEnvelope extends BaseVenusCRMEnvelope {
  final String prmBusCode;
  final String prmLeadName;
  final String prmCompany;
  final String prmEmail;
  final String prmPhone;
  final String prmFax;
  final String prmMobilePhone;
  final String prmWebsite;
  final String prmLeadSourceCode;
  final String prmLeadStatusCode;
  final String prmLOBCode;
  final String prmNoofEmp;
  final String prmAddress;
  final String prmCity;
  final String prmState;
  final String prmZIPCode;
  final String prmCountry;
  final String prmLeadOwner;
  final String prmDescription;
  final String prmIsSuspend;
  final String prmUser;
  final String prmLeadID;

  PostLeadEnvelope({
    required this.prmBusCode,
    required this.prmLeadName,
    required this.prmCompany,
    required this.prmEmail,
    required this.prmPhone,
    required this.prmFax,
    required this.prmMobilePhone,
    required this.prmWebsite,
    required this.prmLeadSourceCode,
    required this.prmLeadStatusCode,
    required this.prmLOBCode,
    required this.prmNoofEmp,
    required this.prmAddress,
    required this.prmCity,
    required this.prmState,
    required this.prmZIPCode,
    required this.prmCountry,
    required this.prmLeadOwner,
    required this.prmDescription,
    required this.prmIsSuspend,
    required this.prmUser,
    required this.prmLeadID,
  });

  @override
  String toXml() {
    String body =
        '''<PostDataLead xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>${BaseVenusCRMEnvelope.escape(prmBusCode)}</prmBusCode>
      <prmLeadName>${BaseVenusCRMEnvelope.escape(prmLeadName)}</prmLeadName>
      <prmCompany>${BaseVenusCRMEnvelope.escape(prmCompany)}</prmCompany>
      <prmEmail>${BaseVenusCRMEnvelope.escape(prmEmail)}</prmEmail>
      <prmPhone>${BaseVenusCRMEnvelope.escape(prmPhone)}</prmPhone>
      <prmFax>${BaseVenusCRMEnvelope.escape(prmFax)}</prmFax>
      <prmMobilePhone>${BaseVenusCRMEnvelope.escape(prmMobilePhone)}</prmMobilePhone>
      <prmWebsite>${BaseVenusCRMEnvelope.escape(prmWebsite)}</prmWebsite>
      <prmLeadSourceCode>${BaseVenusCRMEnvelope.escape(prmLeadSourceCode)}</prmLeadSourceCode>
      <prmLeadStatusCode>${BaseVenusCRMEnvelope.escape(prmLeadStatusCode)}</prmLeadStatusCode>
      <prmLOBCode>${BaseVenusCRMEnvelope.escape(prmLOBCode)}</prmLOBCode>
      <prmNoofEmp>${BaseVenusCRMEnvelope.escape(prmNoofEmp)}</prmNoofEmp>
      <prmAddress>${BaseVenusCRMEnvelope.escape(prmAddress)}</prmAddress>
      <prmCity>${BaseVenusCRMEnvelope.escape(prmCity)}</prmCity>
      <prmState>${BaseVenusCRMEnvelope.escape(prmState)}</prmState>
      <prmZIPCode>${BaseVenusCRMEnvelope.escape(prmZIPCode)}</prmZIPCode>
      <prmCountry>${BaseVenusCRMEnvelope.escape(prmCountry)}</prmCountry>
      <prmLeadOwner>${BaseVenusCRMEnvelope.escape(prmLeadOwner)}</prmLeadOwner>
      <prmDescription>${BaseVenusCRMEnvelope.escape(prmDescription)}</prmDescription>
      <prmIsSuspend>${BaseVenusCRMEnvelope.escape(prmIsSuspend)}</prmIsSuspend>
      <prmUser>${BaseVenusCRMEnvelope.escape(prmUser)}</prmUser>
      <prmLeadID>${BaseVenusCRMEnvelope.escape(prmLeadID)}</prmLeadID>
    </PostDataLead>''';
    return wrapInEnvelope(body);
  }
}
