import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../envelopes/post_activity_envelope.dart';
import '../../../../shared/models/dropdown_option.dart';
import '../../../../shared/utils/crm_session.dart';
import '../../../../shared/utils/pipe_data_parser.dart';
import '../../../../shared/widgets/crm_form_widgets.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final _crmService = VenusCRMService();
  final _session = CrmSession();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _taskId = "0";

  // State Variables
  String? _busCode;
  String? _actSource = 'Lead';
  String? _actTypeCode;
  String? _status = 'Planned';
  String? _priority = 'Medium';
  String? _linkedId;

  // Master Data & Flags
  List<DropdownOption> _businesses = [];
  List<DropdownOption> _activityTypes = [];
  List<DropdownOption> _linkedEntities = [];
  Map<String, bool> _locationRequiredMap = {}; // Maps ActTypeCode to IsLocationRequired

  // Controllers
  final _actDateCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _coordinateCtrl = TextEditingController();

  static const _actSources = ['Lead', 'Account', 'Contact', 'Potential'];
  static const _statuses = ['Planned', 'Held', 'Not Held'];
  static const _priorities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _loadMasterData();
    _initDateTime();
  }

  void _initDateTime() {
    final now = DateTime.now();
    _actDateCtrl.text = "${now.month}/${now.day}/${now.year} ${now.hour}:${now.minute}:00";
  }

  Future<void> _loadMasterData() async {
    setState(() => _isLoading = true);
    try {
      await _session.load();
      _busCode = _session.busCode;
      
      final bus = _busCode ?? '';
      final businessResult = await _crmService.getBusiness(bus);
      final actTypesRes = await _crmService.getActivityType(bus);
      
      if (mounted) {
        setState(() {
          _businesses = PipeDataParser.parseCodeName(businessResult?.code, businessResult?.name);
          _activityTypes = PipeDataParser.parseActivityType(actTypesRes?.pref1, actTypesRes?.pref2, actTypesRes?.pref3);
          
          // Store location requirement flags (Java: arRequiredLocation)
          final codes = PipeDataParser.split(actTypesRes?.pref1);
          final requiredFlags = PipeDataParser.split(actTypesRes?.pref3);
          for (int i = 0; i < codes.length; i++) {
            _locationRequiredMap[codes[i]] = requiredFlags[i].toLowerCase() == "true";
          }

          if (_busCode == null && _businesses.isNotEmpty) _busCode = _businesses.first.code;
        });
        _loadLinkedEntities('');
      }
    } catch (e) {
      if (mounted) showCrmSnackBar(context, 'Failed to load data: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        _coordinateCtrl.text = "${position.latitude}, ${position.longitude}";

        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark p = placemarks[0];
          _locationCtrl.text = "${p.street}, ${p.subLocality}, ${p.locality}, ${p.country}";
        }
      } else {
        showCrmSnackBar(context, "Location permission denied", isError: true);
      }
    } catch (e) {
      showCrmSnackBar(context, "Error getting location: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<DropdownOption>> _searchLinkedEntities(String query) async {
    if (_busCode == null || _actSource == null) return [];
    final bus = _busCode!;
    final auth = _session.userAuth;

    try {
      switch (_actSource) {
        case 'Lead':
          final res = await _crmService.getLead(bus, auth, query);
          return PipeDataParser.parseCodeName(res?.pref1, res?.pref2);
        case 'Account':
          final res = await _crmService.getAccount(bus, auth, query, '0');
          return PipeDataParser.parseCodeName(res?.code, res?.name);
        case 'Contact':
          final res = await _crmService.getContact(bus, auth, query);
          return PipeDataParser.parseCodeName(res?.pref3, res?.pref4);
        case 'Potential':
          final res = await _crmService.getPotential(bus, auth, query);
          return PipeDataParser.parseCodeName(res?.pref3, res?.pref4);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _loadLinkedEntities(String query) async {
    final results = await _searchLinkedEntities(query);
    if (mounted) setState(() => _linkedEntities = results);
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null && mounted) {
      setState(() {
        _actDateCtrl.text = "${date.month}/${date.day}/${date.year} ${time.hour}:${time.minute}:00";
      });
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Java Logic: Validation for Required Location
    bool isLocReq = _locationRequiredMap[_actTypeCode] ?? false;
    if (isLocReq && _coordinateCtrl.text.isEmpty) {
      showCrmSnackBar(context, "Invalid current location. GPS is required for this activity type.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final envelope = PostActivityEnvelope(
        prmLeadID: _actSource == 'Lead' ? (_linkedId ?? '') : '',
        prmActID: '0',
        prmContactID: _actSource == 'Contact' ? (_linkedId ?? '') : '',
        prmPotentialID: _actSource == 'Potential' ? (_linkedId ?? '') : '',
        prmType: _actSource ?? '',
        prmSubject: _subjectCtrl.text.trim(),
        prmDate: _actDateCtrl.text.trim(),
        prmStatus: _status ?? '',
        prmPriority: _priority ?? '',
        prmDesc: _descCtrl.text.trim(),
        prmBusCode: _busCode!,
        prmActTypeCode: _actTypeCode ?? '',
        prmCoordinate: _coordinateCtrl.text.trim(),
        prmLocation: _locationCtrl.text.trim(),
        prmUser: _session.username,
        prmTaskID: _actSource == 'Account' ? (_linkedId ?? '') : '',
      );

      final result = await _crmService.postActivity(envelope);
      if (mounted) {
        if (result?.status == true) {
          showCrmSnackBar(context, 'Activity successfully added');
          _clearForm();
        } else {
          showCrmSnackBar(context, 'Failed to save activity', isError: true);
        }
      }
    } catch (e) {
      if (mounted) showCrmSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _subjectCtrl.clear();
    _descCtrl.clear();
    _locationCtrl.clear();
    _coordinateCtrl.clear();
    _initDateTime();
    setState(() {
      _actSource = 'Lead';
      _linkedId = null;
      _actTypeCode = null;
      _status = 'Planned';
      _priority = 'Medium';
    });
    _loadLinkedEntities('');
  }

  @override
  Widget build(BuildContext context) {
    bool isLocationRequired = _locationRequiredMap[_actTypeCode] ?? false;

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: "Activity Information",
                  icon: Icons.event_note_outlined,
                  children: [
                    CrmDropdownField(label: "Business", items: _businesses, value: _busCode, onChanged: (v) => setState(() => _busCode = v)),
                    
                    // Type (Link To) - Java: cboType
                    CrmDropdownField(
                      label: "Type (Link To)", 
                      items: _actSources.map((e) => DropdownOption(code: e, name: e)).toList(), 
                      value: _actSource, 
                      onChanged: (v) {
                        setState(() { _actSource = v; _linkedId = null; _linkedEntities = []; });
                        _loadLinkedEntities('');
                      }
                    ),

                    // Linked Entity - Dynamic Visibility/Search
                    CrmDropdownField(
                      label: "Linked $_actSource",
                      items: _linkedEntities,
                      value: _linkedId,
                      onChanged: (v) => setState(() => _linkedId = v),
                      onSearch: _searchLinkedEntities,
                      hint: "Search $_actSource...",
                    ),

                    // Activity Type - Java: cboActType
                    CrmDropdownField(
                      label: "Activity Type", 
                      items: _activityTypes, 
                      value: _actTypeCode, 
                      onChanged: (v) {
                        setState(() => _actTypeCode = v);
                        if (_locationRequiredMap[v] == true) {
                          _getCurrentLocation();
                        }
                      }
                    ),

                    CrmTextField(label: "Subject", icon: Icons.subject_rounded, controller: _subjectCtrl, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    CrmTextField(label: "Date & Time", icon: Icons.calendar_month_outlined, controller: _actDateCtrl, readOnly: true, onTap: _selectDateTime),
                    
                    CrmDropdownField(label: "Status", items: _statuses.map((e) => DropdownOption(code: e, name: e)).toList(), value: _status, onChanged: (v) => setState(() => _status = v)),
                    CrmDropdownField(label: "Priority", items: _priorities.map((e) => DropdownOption(code: e, name: e)).toList(), value: _priority, onChanged: (v) => setState(() => _priority = v)),
                    
                    CrmTextField(
                      label: "Coordinate", 
                      icon: Icons.location_searching, 
                      controller: _coordinateCtrl, 
                      readOnly: true,
                      suffix: isLocationRequired ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey) : IconButton(icon: const Icon(Icons.my_location), onPressed: _getCurrentLocation),
                    ),
                    CrmTextField(
                      label: "Location Address", 
                      icon: Icons.location_on_outlined, 
                      controller: _locationCtrl, 
                      readOnly: isLocationRequired, 
                      maxLines: 2
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "Description",
                  icon: Icons.description_outlined,
                  children: [
                    CrmTextField(label: "Description", icon: Icons.notes_rounded, controller: _descCtrl, maxLines: 4),
                  ],
                ),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.local_activity_rounded, color: Colors.deepPurple)),
        const SizedBox(width: 16),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Log Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("Track your sales interactions", style: TextStyle(color: Colors.grey))]),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))]),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 20, color: const Color(0xFF1E4CCB)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
          const Divider(height: 30, thickness: 0.5),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: OutlinedButton(onPressed: _clearForm, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Clear", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: ElevatedButton(onPressed: _saveActivity, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E4CCB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Save Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
      ],
    );
  }
}
