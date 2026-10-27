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
    required this.prmLeadID,
    required this.prmActID,
    required this.prmContactID,
    required this.prmPotentialID,
    required this.prmType,
    required this.prmSubject,
    required this.prmDate,
    required this.prmStatus,
    required this.prmPriority,
    required this.prmDesc,
    required this.prmBusCode,
    required this.prmActTypeCode,
    required this.prmCoordinate,
    required this.prmLocation,
    required this.prmUser,
    required this.prmTaskID,
  });

  @override
  String toXml() {
    String body =
        '''<PostDataActivity xmlns="${BaseVenusCRMEnvelope.namespace}">
      <prmLeadID>${BaseVenusCRMEnvelope.escape(prmLeadID)}</prmLeadID>
      <prmActID>${BaseVenusCRMEnvelope.escape(prmActID)}</prmActID>
      <prmContactID>${BaseVenusCRMEnvelope.escape(prmContactID)}</prmContactID>
      <prmPotentialID>${BaseVenusCRMEnvelope.escape(prmPotentialID)}</prmPotentialID>
      <prmType>${BaseVenusCRMEnvelope.escape(prmType)}</prmType>
      <prmSubject>${BaseVenusCRMEnvelope.escape(prmSubject)}</prmSubject>
      <prmDate>${BaseVenusCRMEnvelope.escape(prmDate)}</prmDate>
      <prmStatus>${BaseVenusCRMEnvelope.escape(prmStatus)}</prmStatus>
      <prmPriority>${BaseVenusCRMEnvelope.escape(prmPriority)}</prmPriority>
      <prmDesc>${BaseVenusCRMEnvelope.escape(prmDesc)}</prmDesc>
      <prmBusCode>${BaseVenusCRMEnvelope.escape(prmBusCode)}</prmBusCode>
      <prmActTypeCode>${BaseVenusCRMEnvelope.escape(prmActTypeCode)}</prmActTypeCode>
      <prmCoordinate>${BaseVenusCRMEnvelope.escape(prmCoordinate)}</prmCoordinate>
      <prmLocation>${BaseVenusCRMEnvelope.escape(prmLocation)}</prmLocation>
      <prmUser>${BaseVenusCRMEnvelope.escape(prmUser)}</prmUser>
      <prmTaskID>${BaseVenusCRMEnvelope.escape(prmTaskID)}</prmTaskID>
    </PostDataActivity>''';
    return wrapInEnvelope(body);
  }
}
