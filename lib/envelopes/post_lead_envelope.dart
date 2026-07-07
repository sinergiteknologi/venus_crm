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
    required this.prmBusCode, required this.prmLeadName, required this.prmCompany,
    required this.prmEmail, required this.prmPhone, required this.prmFax,
    required this.prmMobilePhone, required this.prmWebsite, required this.prmLeadSourceCode,
    required this.prmLeadStatusCode, required this.prmLOBCode, required this.prmNoofEmp,
    required this.prmAddress, required this.prmCity, required this.prmState,
    required this.prmZIPCode, required this.prmCountry, required this.prmLeadOwner,
    required this.prmDescription, required this.prmIsSuspend, required this.prmUser,
    required this.prmLeadID,
  });

  @override
  String toXml() {
    String body = '''<PostDataLead xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmBusCode>$prmBusCode</prmBusCode>
      <prmLeadName>$prmLeadName</prmLeadName>
      <prmCompany>$prmCompany</prmCompany>
      <prmEmail>$prmEmail</prmEmail>
      <prmPhone>$prmPhone</prmPhone>
      <prmFax>$prmFax</prmFax>
      <prmMobilePhone>$prmMobilePhone</prmMobilePhone>
      <prmWebsite>$prmWebsite</prmWebsite>
      <prmLeadSourceCode>$prmLeadSourceCode</prmLeadSourceCode>
      <prmLeadStatusCode>$prmLeadStatusCode</prmLeadStatusCode>
      <prmLOBCode>$prmLOBCode</prmLOBCode>
      <prmNoofEmp>$prmNoofEmp</prmNoofEmp>
      <prmAddress>$prmAddress</prmAddress>
      <prmCity>$prmCity</prmCity>
      <prmState>$prmState</prmState>
      <prmZIPCode>$prmZIPCode</prmZIPCode>
      <prmCountry>$prmCountry</prmCountry>
      <prmLeadOwner>$prmLeadOwner</prmLeadOwner>
      <prmDescription>$prmDescription</prmDescription>
      <prmIsSuspend>$prmIsSuspend</prmIsSuspend>
      <prmUser>$prmUser</prmUser>
      <prmLeadID>$prmLeadID</prmLeadID>
    </PostDataLead>''';
    return wrapInEnvelope(body);
  }
}
