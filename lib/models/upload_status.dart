class UploadStatus {
  final bool status;

  UploadStatus({this.status = false});

  factory UploadStatus.fromXml(Map<String, dynamic> xml) {
    return UploadStatus(
      status: xml['Status']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
    };
  }
}
