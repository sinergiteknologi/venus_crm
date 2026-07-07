class PostResponse {
  final bool status;

  PostResponse({this.status = false});

  factory PostResponse.fromXml(Map<String, dynamic> xml) {
    return PostResponse(
      status: xml['Status']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
    };
  }
}
