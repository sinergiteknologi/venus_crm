import 'base_envelope.dart';

class PostPotentialEnvelope extends BaseVenusCRMEnvelope {
  final String prmPotentialID;
  final String prmBusCode;
  final String prmActID;
  final String prmPotentialName;
  final String prmClosingDate;
  final String prmLeadSourceCode;
  final String prmPotentialOwner;
  final String prmAmount;
  final String prmDescription;
  final String prmIsSuspend;
  final String prmStageCode;
  final String prmStageName;
  final String prmStartDate;
  final String prmFinishedDate;
  final String prmStageDesc;
  final String prmContactCode;
  final String prmContactDescription;
  final String prmUser;
  final String prmMethodCode;
  final String prmLocation;

  PostPotentialEnvelope({
    required this.prmPotentialID,
    required this.prmBusCode,
    required this.prmActID,
    required this.prmPotentialName,
    required this.prmClosingDate,
    required this.prmLeadSourceCode,
    required this.prmPotentialOwner,
    required this.prmAmount,
    required this.prmDescription,
    required this.prmIsSuspend,
    required this.prmStageCode,
    required this.prmStageName,
    required this.prmStartDate,
    required this.prmFinishedDate,
    required this.prmStageDesc,
    required this.prmContactCode,
    required this.prmContactDescription,
    required this.prmUser,
    required this.prmMethodCode,
    required this.prmLocation,
  });

  String _value(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  @override
  String toXml() {
    final body =
        '''<PostDataPotential xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmPotentialID>${_value(prmPotentialID)}</prmPotentialID>
      <prmBusCode>${_value(prmBusCode)}</prmBusCode>
      <prmActID>${_value(prmActID)}</prmActID>
      <prmPotentialName>${_value(prmPotentialName)}</prmPotentialName>
      <prmClosingDate>${_value(prmClosingDate)}</prmClosingDate>
      <prmLeadSourceCode>${_value(prmLeadSourceCode)}</prmLeadSourceCode>
      <prmPotentialOwner>${_value(prmPotentialOwner)}</prmPotentialOwner>
      <prmAmount>${_value(prmAmount)}</prmAmount>
      <prmDescription>${_value(prmDescription)}</prmDescription>
      <prmIsSuspend>${_value(prmIsSuspend)}</prmIsSuspend>
      <prmStageCode>${_value(prmStageCode)}</prmStageCode>
      <prmStageName>${_value(prmStageName)}</prmStageName>
      <prmStartDate>${_value(prmStartDate)}</prmStartDate>
      <prmFinishedDate>${_value(prmFinishedDate)}</prmFinishedDate>
      <prmStageDesc>${_value(prmStageDesc)}</prmStageDesc>
      <prmContactCode>${_value(prmContactCode)}</prmContactCode>
      <prmContactDescription>${_value(prmContactDescription)}</prmContactDescription>
      <prmUser>${_value(prmUser)}</prmUser>
      <prmMethodCode>${_value(prmMethodCode)}</prmMethodCode>
      <prmLocation>${_value(prmLocation)}</prmLocation>
    </PostDataPotential>''';
    return wrapInEnvelope(body);
  }
}
