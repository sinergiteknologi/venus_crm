import 'base_envelope.dart';

class PostActivityEnvelope extends BaseVenusCRMEnvelope {
  final String prmLeadID;
  final String prmActID;
  final String prmContactID;
  final String prmPotentialID;
  final String prmType;
  final String prmSubject;
  final String prmDate;
  final String prmStatus;
  final String prmPriority;
  final String prmDesc;
  final String prmBusCode;
  final String prmActTypeCode;
  final String prmCoordinate;
  final String prmLocation;
  final String prmUser;
  final String prmTaskID;

  PostActivityEnvelope({
    required this.prmLeadID, required this.prmActID, required this.prmContactID,
    required this.prmPotentialID, required this.prmType, required this.prmSubject,
    required this.prmDate, required this.prmStatus, required this.prmPriority,
    required this.prmDesc, required this.prmBusCode, required this.prmActTypeCode,
    required this.prmCoordinate, required this.prmLocation, required this.prmUser,
    required this.prmTaskID,
  });

  @override
  String toXml() {
    String body = '''<PostDataActivity xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmLeadID>$prmLeadID</prmLeadID>
      <prmActID>$prmActID</prmActID>
      <prmContactID>$prmContactID</prmContactID>
      <prmPotentialID>$prmPotentialID</prmPotentialID>
      <prmType>$prmType</prmType>
      <prmSubject>$prmSubject</prmSubject>
      <prmDate>$prmDate</prmDate>
      <prmStatus>$prmStatus</prmStatus>
      <prmPriority>$prmPriority</prmPriority>
      <prmDesc>$prmDesc</prmDesc>
      <prmBusCode>$prmBusCode</prmBusCode>
      <prmActTypeCode>$prmActTypeCode</prmActTypeCode>
      <prmCoordinate>$prmCoordinate</prmCoordinate>
      <prmLocation>$prmLocation</prmLocation>
      <prmUser>$prmUser</prmUser>
      <prmTaskID>$prmTaskID</prmTaskID>
    </PostDataActivity>''';
    return wrapInEnvelope(body);
  }
}
