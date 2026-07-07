import '../../models/login.dart';
import '../models/dropdown_option.dart';
import 'pipe_data_parser.dart';
import 'pref_manager.dart';

class CrmSession {
  Login? _login;

  Future<Login?> load() async {
    _login ??= await PrefManager.getLoginData();
    return _login;
  }

  Login? get login => _login;

  String get busCode => _login?.pref1 ?? '';
  String get busName => _login?.pref2 ?? '';
  String get username => _login?.pref3 ?? '';
  String get salesCode => _login?.pref4 ?? '';
  String get salesName => _login?.pref5 ?? '';
  String get userAuth => _login?.pref8 ?? '';

  List<DropdownOption> get businesses =>
      PipeDataParser.parseCodeName(_login?.pref6, _login?.pref7);
}
