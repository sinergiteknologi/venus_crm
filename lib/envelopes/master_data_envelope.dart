import 'base_envelope.dart';

class MasterDataEnvelope extends BaseVenusCRMEnvelope {
  final String methodName;
  final Map<String, String> parameters;

  MasterDataEnvelope(this.methodName, {this.parameters = const {}});

  @override
  String toXml() {
    final params = parameters.entries
        .map((e) => '<${e.key}>${e.value}</${e.key}>')
        .join('\n      ');
    final body = params.isEmpty
        ? '<$methodName xmlns="${BaseVenusCRMEnvelope.namespace}" />'
        : '''<$methodName xmlns="${BaseVenusCRMEnvelope.namespace}">
      $params
    </$methodName>''';
     
    return wrapInEnvelope(body);
  }
}
