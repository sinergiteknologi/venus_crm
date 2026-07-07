import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/login.dart';
import '../models/lead.dart';
import '../models/account.dart';
import '../models/contact.dart';
import '../models/potential.dart';
import '../models/data_lead.dart';
import '../models/data_contact.dart';
import '../models/data_potential.dart';
import '../models/data_activity.dart';
import '../models/business.dart';
import '../models/sales.dart';
import '../models/lead_source.dart';
import '../models/lead_status.dart';
import '../models/activity_type.dart';
import '../models/lob.dart';
import '../models/stage.dart';
import '../models/position.dart';
import '../models/method_potential.dart';
import '../models/post_response.dart';
import '../models/upload_status.dart';
import '../models/versi.dart';
import '../envelopes/login_envelope.dart';
import '../envelopes/lead_envelope.dart';
import '../envelopes/account_envelope.dart';
import '../envelopes/contact_envelope.dart';
import '../envelopes/potential_envelope.dart';
import '../envelopes/find_envelope.dart';
import '../envelopes/post_lead_envelope.dart';
import '../envelopes/post_contact_envelope.dart';
import '../envelopes/post_activity_envelope.dart';
import '../envelopes/password_envelope.dart';
import '../envelopes/master_data_envelope.dart';

class VenusCRMService {
  static const String _apiUrl =
      'https://implement.sinergiteknologi.co.id/VenusCRMServices/mobileservices.asmx';

  String get _requestUrl {
    if (kIsWeb) {
      return Uri.base.resolve('api/proxy').toString();
    }
    return _apiUrl;
  }

  // ── Authentication ──────────────────────────────────────────────────────────

  Future<Login?> getLogin(String sUser, String sPwd) async {
    final envelope = LoginDataEnvelope(sUser, sPwd);
    final response =
        await _postRequest(envelope.toXml(), "http://VenusCRM.org/GetLogin");
    if (response.statusCode == 200) {
      return _parseResponse<Login>(
          response.body, 'Login', (xml) => Login.fromXml(xml));
    }
    return null;
  }

  Future<UploadStatus?> uploadNewPassword(
      String prmUser, String prmNewPassword) async {
    final envelope = PasswordEnvelope(prmUser, prmNewPassword);
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/UploadNewPassword");
    if (response.statusCode == 200) {
      return _parseResponse<UploadStatus>(response.body, 'UploadStatus',
          (xml) => UploadStatus.fromXml(xml));
    }
    return null;
  }

  // ── Lead ────────────────────────────────────────────────────────────────────

  Future<Lead?> getLead(
      String prmBusCode, String prmUserAuth, String prmLike) async {
    final envelope = LeadEnvelope(prmBusCode, prmUserAuth, prmLike);
    final response =
        await _postRequest(envelope.toXml(), "http://VenusCRM.org/GetLead");
    if (response.statusCode == 200) {
      return _parseResponse<Lead>(
          response.body, 'DataLead', (xml) => Lead.fromXml(xml));
    }
    return null;
  }

  Future<DataLead?> getDataLead(String prmBusCode, String prmUserAuth,
      String prmType, String prmValue, String prmDate1, String prmDate2) async {
    final envelope = FindEnvelope(
      methodName: 'GetFindDataLead',
      prmBusCode: prmBusCode,
      prmUserAuth: prmUserAuth,
      prmType: prmType,
      prmValue: prmValue,
      prmDate1: prmDate1,
      prmDate2: prmDate2,
    );
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/GetFindDataLead");
    if (response.statusCode == 200) {
      return _parseResponse<DataLead>(
          response.body, 'DataLead', (xml) => DataLead.fromXml(xml));
    }
    return null;
  }

  Future<PostResponse?> postLead(PostLeadEnvelope envelope) async {
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/PostDataLead");
    if (response.statusCode == 200) {
      return _parseResponse<PostResponse>(
          response.body, 'Post', (xml) => PostResponse.fromXml(xml));
    }
    return null;
  }

  // ── Account & Contact ───────────────────────────────────────────────────────

  Future<Account?> getAccount(String prmBusCode, String prmUserAuth,
      String prmLike, String prmFromMenu) async {
    final envelope =
        AccountEnvelope(prmBusCode, prmUserAuth, prmLike, prmFromMenu);
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/GetDataAccount");
    if (response.statusCode == 200) {
      return _parseResponse<Account>(
          response.body, 'DataAccount', (xml) => Account.fromXml(xml));
    }
    return null;
  }

  Future<Contact?> getContact(
      String prmBusCode, String prmUserAuth, String prmLike) async {
    final envelope = ContactEnvelope(prmBusCode, prmUserAuth, prmLike);
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/GetDataContact");
    if (response.statusCode == 200) {
      return _parseResponse<Contact>(
          response.body, 'DataContact', (xml) => Contact.fromXml(xml));
    }
    return null;
  }

  Future<DataContact?> getDataContact(String prmBusCode, String prmUserAuth,
      String prmType, String prmValue, String prmDate1, String prmDate2) async {
    final envelope = FindEnvelope(
      methodName: 'GetFindDataContact',
      prmBusCode: prmBusCode,
      prmUserAuth: prmUserAuth,
      prmType: prmType,
      prmValue: prmValue,
      prmDate1: prmDate1,
      prmDate2: prmDate2,
    );
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/GetFindDataContact");
    if (response.statusCode == 200) {
      return _parseResponse<DataContact>(
          response.body, 'DataContact', (xml) => DataContact.fromXml(xml));
    }
    return null;
  }

  Future<PostResponse?> postContact(PostContactEnvelope envelope) async {
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/PostDataContact");
    if (response.statusCode == 200) {
      return _parseResponse<PostResponse>(
          response.body, 'Post', (xml) => PostResponse.fromXml(xml));
    }
    return null;
  }

  // ── Potential ───────────────────────────────────────────────────────────────

  Future<Potential?> getPotential(
      String prmBusCode, String prmUserAuth, String prmLike) async {
    final envelope = PotentialEnvelope(prmBusCode, prmUserAuth, prmLike);
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/GetDataPotential");
    if (response.statusCode == 200) {
      return _parseResponse<Potential>(
          response.body, 'DataPotential', (xml) => Potential.fromXml(xml));
    }
    return null;
  }

  Future<DataPotential?> getDataPotential(String prmBusCode,
      String prmUserAuth, String prmType, String prmValue,
      String prmDate1, String prmDate2) async {
    final envelope = FindEnvelope(
      methodName: 'GetFindDataPotential',
      prmBusCode: prmBusCode,
      prmUserAuth: prmUserAuth,
      prmType: prmType,
      prmValue: prmValue,
      prmDate1: prmDate1,
      prmDate2: prmDate2,
    );
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/GetFindDataPotential");
    if (response.statusCode == 200) {
      return _parseResponse<DataPotential>(response.body, 'DataPotential',
          (xml) => DataPotential.fromXml(xml));
    }
    return null;
  }

  // ── Activity ────────────────────────────────────────────────────────────────

  Future<PostResponse?> postActivity(PostActivityEnvelope envelope) async {
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/PostDataActivity");
    if (response.statusCode == 200) {
      return _parseResponse<PostResponse>(
          response.body, 'Post', (xml) => PostResponse.fromXml(xml));
    }
    return null;
  }

  Future<DataActivity?> getDataActivity(String prmBusCode, String prmUserAuth,
      String prmType, String prmValue, String prmDate1, String prmDate2) async {
    final envelope = FindEnvelope(
      methodName: 'GetFindDataActivity',
      prmBusCode: prmBusCode,
      prmUserAuth: prmUserAuth,
      prmType: prmType,
      prmValue: prmValue,
      prmDate1: prmDate1,
      prmDate2: prmDate2,
    );
    final response = await _postRequest(
        envelope.toXml(), "http://VenusCRM.org/GetFindDataActivity");
    if (response.statusCode == 200) {
      return _parseResponse<DataActivity>(
          response.body, 'DataActivity', (xml) => DataActivity.fromXml(xml));
    }
    return null;
  }

  // ── Master Data ─────────────────────────────────────────────────────────────

  Future<Business?> getBusiness(String prmBusCode) async {
    return _fetchMaster<Business>(
        'GetDataBusiness', 'DataBusiness', (xml) => Business.fromXml(xml),
        params: {'prmBusCode': prmBusCode});
  }

  Future<Sales?> getSales(String prmBusCode, String prmUserAuth) async {
    return _fetchMaster<Sales>(
        'GetDataSales', 'DataSales', (xml) => Sales.fromXml(xml),
        params: {'prmBusCode': prmBusCode, 'prmUserAuth': prmUserAuth});
  }

  Future<LeadSource?> getLeadSource(String prmBusCode) async {
    return _fetchMaster<LeadSource>(
        'GetDataLeadSource', 'DataLeadSource', (xml) => LeadSource.fromXml(xml),
        params: {'prmBusCode': prmBusCode});
  }

  Future<LeadStatus?> getLeadStatus(String prmBusCode) async {
    return _fetchMaster<LeadStatus>(
        'GetDataLeadStatus', 'DataLeadStatus', (xml) => LeadStatus.fromXml(xml),
        params: {'prmBusCode': prmBusCode});
  }

  Future<ActivityType?> getActivityType(String prmBusCode) async {
    return _fetchMaster<ActivityType>(
        'GetDataActivityType', 'DataActivityType', (xml) => ActivityType.fromXml(xml),
        params: {'prmBusCode': prmBusCode});
  }

  Future<LOB?> getLOB(String prmBusCode) async {
    return _fetchMaster<LOB>(
        'GetDataLOB', 'DataLOB', (xml) => LOB.fromXml(xml),
        params: {'prmBusCode': prmBusCode});
  }

  Future<Stage?> getStage(String prmBusCode) async {
    return _fetchMaster<Stage>(
        'GetDataStage', 'DataStage', (xml) => Stage.fromXml(xml),
        params: {'prmBusCode': prmBusCode});
  }

  Future<Position?> getPosition(String prmBusCode) async {
    return _fetchMaster<Position>(
        'GetDataPosition', 'DataPosition', (xml) => Position.fromXml(xml),
        params: {'prmBusCode': prmBusCode});
  }

  Future<MethodPotential?> getMethodPotential(String prmBusCode) async {
    return _fetchMaster<MethodPotential>('GetDataMethodPotential',
        'DataMethodPotential', (xml) => MethodPotential.fromXml(xml),
        params: {'prmBusCode': prmBusCode});
  }

  // ── System ──────────────────────────────────────────────────────────────────

  Future<Versi?> getVersi() async {
    final envelope = MasterDataEnvelope('GetVersi');
    final response =
        await _postRequest(envelope.toXml(), "http://VenusCRM.org/GetVersi");
    if (response.statusCode == 200) {
      return _parseResponse<Versi>(
          response.body, 'Versi', (xml) => Versi.fromXml(xml));
    }
    return null;
  }

  // ── Internal ────────────────────────────────────────────────────────────────

  Future<T?> _fetchMaster<T>(
    String method,
    String element,
    T Function(Map<String, dynamic>) creator, {
    Map<String, String> params = const {},
  }) async {
    final envelope = MasterDataEnvelope(method, parameters: params);
    final response =
        await _postRequest(envelope.toXml(), "http://VenusCRM.org/$method");
    if (response.statusCode == 200) {
      return _parseResponse<T>(response.body, element, creator);
    }
    return null;
  }

  Future<http.Response> _postRequest(String xmlBody, String soapAction) async {
    return await http.post(
      Uri.parse(_requestUrl),
      headers: {
        "Content-Type": "text/xml; charset=utf-8",
        "SOAPAction": soapAction,
      },
      body: xmlBody,
    );
  }

  T? _parseResponse<T>(String xmlString, String elementName,
      T Function(Map<String, dynamic>) creator) {
    final document = XmlDocument.parse(xmlString);
    final element = document.findAllElements(elementName).firstOrNull;
    if (element != null) {
      final data = <String, dynamic>{};
      for (var child in element.children.whereType<XmlElement>()) {
        data[child.name.local] = child.innerText;
      }
      return creator(data);
    }
    return null;
  }
}
