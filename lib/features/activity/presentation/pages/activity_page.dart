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

class _LinkedEntityOption {
  final String entityId;
  final String accountId;
  final String name;
  final String accountName;

  const _LinkedEntityOption({
    required this.entityId,
    required this.accountId,
    required this.name,
    this.accountName = '',
  });

  String get selectionKey =>
      accountId == entityId ? entityId : '$accountId\u001f$entityId';

  DropdownOption get dropdownOption =>
      DropdownOption(code: selectionKey, name: name);
}

class ActivityEditData {
  final String taskId;
  final String type;
  final String linkedName;
  final String linkedSubName;
  final String subject;
  final String date;
  final String status;
  final String priority;
  final String description;
  final String businessName;
  final String sales;
  final String activityTypeName;
  final String coordinate;
  final String location;

  const ActivityEditData({
    required this.taskId,
    required this.type,
    required this.linkedName,
    required this.linkedSubName,
    required this.subject,
    required this.date,
    required this.status,
    required this.priority,
    required this.description,
    required this.businessName,
    required this.sales,
    required this.activityTypeName,
    required this.coordinate,
    required this.location,
  });
}

class ActivityPage extends StatefulWidget {
  final ActivityEditData? editData;
  final VoidCallback? onBack;
  final VoidCallback? onCompleted;

  const ActivityPage({super.key, this.editData, this.onBack, this.onCompleted});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final _crmService = VenusCRMService();
  final _session = CrmSession();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  int _linkedRequestId = 0;
  String _taskId = '';

  String? _busCode;
  String? _actSource = 'Lead';
  String? _actTypeCode;
  String? _status = 'Progress';
  String? _priority = 'Medium';
  String? _linkedId;

  List<DropdownOption> _businesses = [];
  List<DropdownOption> _activityTypes = [];
  List<_LinkedEntityOption> _linkedEntities = [];
  final Map<String, _LinkedEntityOption> _linkedEntitiesByKey = {};
  Map<String, bool> _locationRequiredMap = {};

  final _actDateCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _coordinateCtrl = TextEditingController();

  static const _actSources = ['Lead', 'Account', 'Contact', 'Potential'];
  static const _statuses = ['Progress', 'Finished'];
  static const _priorities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _initDateTime();
    _loadMasterData();
  }

  void _initDateTime() {
    final now = DateTime.now();
    _actDateCtrl.text =
        '${now.month}/${now.day}/${now.year} ${now.hour}:${now.minute}:00';
  }

  Future<void> _loadMasterData() async {
    setState(() => _isLoading = true);
    try {
      await _session.load();
      final businessResult = await _crmService.getBusiness(_session.busCode);
      final businesses = PipeDataParser.parseCodeName(
        businessResult?.code,
        businessResult?.name,
      );
      final editData = widget.editData;
      final editBusiness = editData == null
          ? null
          : _codeForValue(businesses, editData.businessName);
      final sessionBusiness =
          businesses.any((business) => business.code == _session.busCode)
          ? _session.busCode
          : null;

      if (!mounted) return;
      setState(() {
        _businesses = businesses;
        _busCode =
            editBusiness ??
            sessionBusiness ??
            (businesses.isNotEmpty ? businesses.first.code : null);
        if (editData != null) {
          _taskId = editData.taskId.trim().isEmpty
              ? ''
              : editData.taskId.trim();
          _actSource = _sourceForValue(editData.type);
          _status = _statusForValue(editData.status);
          _priority = _priorities.contains(editData.priority)
              ? editData.priority
              : 'Medium';
          _subjectCtrl.text = editData.subject;
          _actDateCtrl.text = editData.date;
          _descCtrl.text = editData.description;
          _coordinateCtrl.text = editData.coordinate;
          _locationCtrl.text = editData.location;
        }
      });

      await _loadActivityTypes();
      if (editData != null) {
        await _loadEditLinkedEntities(editData);
        if (!mounted) return;
        setState(() {
          _actTypeCode = _codeForValue(
            _activityTypes,
            editData.activityTypeName,
          );
          _linkedId = _linkedCodeForEdit(editData);
        });
      }
    } catch (e) {
      if (mounted) {
        showCrmSnackBar(context, 'Failed to load data: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _codeForValue(List<DropdownOption> items, String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final item in items) {
      if (item.code.trim().toLowerCase() == normalized ||
          item.name.trim().toLowerCase() == normalized) {
        return item.code;
      }
    }
    return null;
  }

  String _sourceForValue(String value) {
    final normalized = value.trim().toLowerCase();
    for (final source in _actSources) {
      if (source.toLowerCase() == normalized) return source;
    }
    return 'Lead';
  }

  String _statusForValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'finished':
      case 'held':
      case 'completed':
      case 'complete':
      case 'done':
        return 'Finished';
      case 'progress':
      case 'planned':
      case 'not held':
      case 'pending':
      case 'open':
      default:
        return 'Progress';
    }
  }

  bool _parseLocationRequired(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'y';
  }

  Future<void> _loadActivityTypes() async {
    final business = _busCode;
    if (business == null || business.isEmpty) {
      if (mounted) {
        setState(() {
          _activityTypes = [];
          _locationRequiredMap = {};
        });
      }
      return;
    }

    final result = await _crmService.getActivityType(business);
    if (!mounted || _busCode != business) return;

    final codes = PipeDataParser.split(result?.pref1);
    final flags = PipeDataParser.split(result?.pref3);
    final locationRequired = <String, bool>{};
    for (var i = 0; i < codes.length; i++) {
      locationRequired[codes[i]] =
          i < flags.length && _parseLocationRequired(flags[i]);
    }

    setState(() {
      _activityTypes = PipeDataParser.parseActivityType(
        result?.pref1,
        result?.pref2,
        result?.pref3,
      );
      _locationRequiredMap = locationRequired;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        final coordinate = '${position.latitude}, ${position.longitude}';
        _coordinateCtrl.text = coordinate;

        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (!mounted) return;
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            _locationCtrl.text =
                [place.street, place.subLocality, place.locality, place.country]
                    .where((part) => part != null && part.trim().isNotEmpty)
                    .join(', ');
          }
        } catch (_) {
          if (!mounted) return;
          _locationCtrl.text = coordinate;
        }
      } else {
        if (mounted) {
          showCrmSnackBar(context, 'Location permission denied', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showCrmSnackBar(context, 'Error getting location: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<_LinkedEntityOption>> _searchLinkedEntities(String query) async {
    final bus = _busCode;
    final source = _actSource;
    if (bus == null || bus.isEmpty || source == null || source.isEmpty) {
      return [];
    }
    final auth = _session.userAuth;

    switch (source) {
      case 'Lead':
        final result = await _crmService.getLead(bus, auth, query);
        return _linkedOptions(entityIds: result?.pref1, names: result?.pref2);
      case 'Account':
        final result = await _crmService.getAccount(bus, auth, query, '0');
        return _linkedOptions(
          entityIds: result?.code,
          accountIds: result?.code,
          names: result?.name,
        );
      case 'Contact':
        final result = await _crmService.getContact(bus, auth, query);
        return _linkedOptions(
          entityIds: result?.pref3,
          accountIds: result?.pref1,
          names: result?.pref4,
          accountNames: result?.pref2,
        );
      case 'Potential':
        final result = await _crmService.getPotential(bus, auth, query);
        return _linkedOptions(
          entityIds: result?.pref3,
          accountIds: result?.pref1,
          names: result?.pref4,
          accountNames: result?.pref2,
        );
      default:
        return [];
    }
  }

  List<_LinkedEntityOption> _linkedOptions({
    required String? entityIds,
    required String? names,
    String? accountIds,
    String? accountNames,
  }) {
    final ids = PipeDataParser.split(entityIds);
    final labels = PipeDataParser.split(names);
    final accounts = PipeDataParser.split(accountIds);
    final accountLabels = PipeDataParser.split(accountNames);

    return List.generate(ids.length, (index) {
      final entityId = ids[index];
      return _LinkedEntityOption(
        entityId: entityId,
        accountId: index < accounts.length ? accounts[index] : entityId,
        name: index < labels.length ? labels[index] : entityId,
        accountName: index < accountLabels.length ? accountLabels[index] : '',
      );
    });
  }

  Future<List<DropdownOption>> _searchLinkedDropdownOptions(
    String query,
  ) async {
    final results = await _searchLinkedEntities(query);
    for (final item in results) {
      _linkedEntitiesByKey[item.selectionKey] = item;
    }
    return results.map((item) => item.dropdownOption).toList();
  }

  Future<void> _loadLinkedEntities(String query) async {
    final requestId = ++_linkedRequestId;
    final business = _busCode;
    final source = _actSource;
    final results = await _searchLinkedEntities(query);
    if (!mounted ||
        requestId != _linkedRequestId ||
        business != _busCode ||
        source != _actSource) {
      return;
    }
    setState(() {
      _linkedEntities = results;
      for (final item in results) {
        _linkedEntitiesByKey[item.selectionKey] = item;
      }
    });
  }

  Future<void> _loadEditLinkedEntities(ActivityEditData data) async {
    await _loadLinkedEntities(data.linkedName);
    if (_linkedCodeForEdit(data) != null || data.linkedSubName.trim().isEmpty) {
      return;
    }

    final existing = List<_LinkedEntityOption>.of(_linkedEntities);
    final requestId = ++_linkedRequestId;
    final business = _busCode;
    final source = _actSource;
    final additional = await _searchLinkedEntities(data.linkedSubName.trim());
    if (!mounted ||
        requestId != _linkedRequestId ||
        business != _busCode ||
        source != _actSource) {
      return;
    }

    final merged = <String, _LinkedEntityOption>{
      for (final item in existing) item.selectionKey: item,
      for (final item in additional) item.selectionKey: item,
    };
    setState(() {
      _linkedEntities = merged.values.toList();
      _linkedEntitiesByKey.addAll(merged);
    });
  }

  String? _linkedCodeForEdit(ActivityEditData data) {
    final linkedName = data.linkedName.trim().toLowerCase();
    final accountName = data.linkedSubName.trim().toLowerCase();

    for (final item in _linkedEntities) {
      if (linkedName == item.entityId.trim().toLowerCase() ||
          linkedName == item.name.trim().toLowerCase()) {
        return item.selectionKey;
      }
    }
    for (final item in _linkedEntities) {
      final code = item.entityId.trim().toLowerCase();
      final name = item.name.trim().toLowerCase();
      if (linkedName.isNotEmpty &&
          (name.contains(linkedName) ||
              linkedName.contains(name) ||
              code.contains(linkedName) ||
              linkedName.contains(code))) {
        return item.selectionKey;
      }
    }
    for (final item in _linkedEntities) {
      if (accountName.isNotEmpty &&
          accountName == item.accountName.trim().toLowerCase()) {
        return item.selectionKey;
      }
    }
    return null;
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null && mounted) {
      setState(() {
        _actDateCtrl.text =
            '${date.month}/${date.day}/${date.year} ${time.hour}:${time.minute}:00';
      });
    }
  }

  bool _validateActivity() {
    if (_busCode == null || _busCode!.isEmpty) {
      showCrmSnackBar(context, 'Business is required', isError: true);
      return false;
    }
    if (_actSource == null || _actSource!.isEmpty) {
      showCrmSnackBar(context, 'Type is required', isError: true);
      return false;
    }
    if (_linkedId == null || _linkedId!.isEmpty) {
      showCrmSnackBar(
        context,
        'Linked ${_actSource ?? 'entity'} is required',
        isError: true,
      );
      return false;
    }
    if (_actTypeCode == null || _actTypeCode!.isEmpty) {
      showCrmSnackBar(context, 'Activity Type is required', isError: true);
      return false;
    }
    if (_actDateCtrl.text.trim().isEmpty) {
      showCrmSnackBar(context, 'Date & Time is required', isError: true);
      return false;
    }
    if (_subjectCtrl.text.trim().isEmpty) {
      showCrmSnackBar(context, 'Subject is required', isError: true);
      return false;
    }
    if (_descCtrl.text.trim().isEmpty) {
      showCrmSnackBar(context, 'Description is required', isError: true);
      return false;
    }
    if ((_locationRequiredMap[_actTypeCode] ?? false) &&
        _coordinateCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'Invalid current location. GPS is required for this activity type.',
        isError: true,
      );
      return false;
    }
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _saveActivity() async {
    FocusScope.of(context).unfocus();
    if (!_validateActivity()) return;

    setState(() => _isLoading = true);
    try {
      final linkedEntity = _linkedEntitiesByKey[_linkedId!];
      if (linkedEntity == null) {
        showCrmSnackBar(context, 'Linked entity is invalid', isError: true);
        return;
      }
      final source = _actSource!;
      final envelope = PostActivityEnvelope(
        prmLeadID: source == 'Lead' ? linkedEntity.entityId : '',
        prmActID:
            source == 'Account' || source == 'Contact' || source == 'Potential'
            ? linkedEntity.accountId
            : '',
        prmContactID: source == 'Contact' ? linkedEntity.entityId : '',
        prmPotentialID: source == 'Potential' ? linkedEntity.entityId : '',
        prmType: source,
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
        prmTaskID: _taskId.trim(),
      );

      final result = await _crmService.postActivity(envelope);
      if (mounted) {
        if (result?.status == true) {
          showCrmSnackBar(context, 'Activity successfully saved');
          widget.onCompleted?.call();
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

  Future<void> _changeBusiness(String? value) async {
    setState(() {
      _isLoading = true;
      _busCode = value;
      _linkedId = null;
      _actTypeCode = null;
      _activityTypes = [];
      _linkedEntities = [];
      _linkedEntitiesByKey.clear();
      _locationRequiredMap = {};
      _locationCtrl.clear();
      _coordinateCtrl.clear();
    });

    try {
      await _loadActivityTypes();
      await _loadLinkedEntities('');
    } catch (e) {
      if (mounted) {
        showCrmSnackBar(context, 'Failed to load data: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeSource(String? value) async {
    setState(() {
      _actSource = value;
      _linkedId = null;
      _linkedEntities = [];
      _linkedEntitiesByKey.clear();
    });
    try {
      await _loadLinkedEntities('');
    } catch (e) {
      if (mounted) {
        showCrmSnackBar(
          context,
          'Failed to load linked entities: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _clearForm() async {
    FocusScope.of(context).unfocus();
    final sessionBusiness =
        _businesses.any((business) => business.code == _session.busCode)
        ? _session.busCode
        : null;

    setState(() {
      _isLoading = true;
      _taskId = '';
      _busCode =
          sessionBusiness ??
          (_businesses.isNotEmpty ? _businesses.first.code : null);
      _actSource = 'Lead';
      _linkedId = null;
      _actTypeCode = null;
      _status = 'Progress';
      _priority = 'Medium';
      _activityTypes = [];
      _linkedEntities = [];
      _linkedEntitiesByKey.clear();
      _locationRequiredMap = {};
      _subjectCtrl.clear();
      _descCtrl.clear();
      _locationCtrl.clear();
      _coordinateCtrl.clear();
      _formKey.currentState?.reset();
      _initDateTime();
    });

    try {
      await _loadActivityTypes();
      await _loadLinkedEntities('');
    } catch (e) {
      if (mounted) {
        showCrmSnackBar(context, 'Failed to load data: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _actDateCtrl.dispose();
    _locationCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    _coordinateCtrl.dispose();
    super.dispose();
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
                    CrmDropdownField(
                      label: "Business",
                      items: _businesses,
                      value: _busCode,
                      onChanged: _changeBusiness,
                    ),
                    CrmDropdownField(
                      label: "Type (Link To)",
                      items: _actSources
                          .map((e) => DropdownOption(code: e, name: e))
                          .toList(),
                      value: _actSource,
                      onChanged: _changeSource,
                    ),
                    CrmDropdownField(
                      label: "Linked $_actSource",
                      items: _linkedEntities
                          .map((item) => item.dropdownOption)
                          .toList(),
                      value: _linkedId,
                      onChanged: (value) {
                        setState(() {
                          _linkedId = value;
                          final selected = _linkedEntitiesByKey[value];
                          if (selected != null &&
                              !_linkedEntities.any(
                                (item) =>
                                    item.selectionKey == selected.selectionKey,
                              )) {
                            _linkedEntities = [..._linkedEntities, selected];
                          }
                        });
                      },
                      onSearch: _searchLinkedDropdownOptions,
                      hint: "Search $_actSource...",
                    ),
                    CrmDropdownField(
                      label: "Activity Type",
                      items: _activityTypes,
                      value: _actTypeCode,
                      onChanged: (v) {
                        setState(() => _actTypeCode = v);
                        if (_locationRequiredMap[v] == true) {
                          _getCurrentLocation();
                        }
                      },
                    ),
                    CrmTextField(
                      label: "Subject",
                      icon: Icons.subject_rounded,
                      controller: _subjectCtrl,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    CrmTextField(
                      label: "Date & Time",
                      icon: Icons.calendar_month_outlined,
                      controller: _actDateCtrl,
                      readOnly: true,
                      onTap: _selectDateTime,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    CrmDropdownField(
                      label: "Status",
                      items: _statuses
                          .map((e) => DropdownOption(code: e, name: e))
                          .toList(),
                      value: _status,
                      onChanged: (v) => setState(() => _status = v),
                    ),
                    CrmDropdownField(
                      label: "Priority",
                      items: _priorities
                          .map((e) => DropdownOption(code: e, name: e))
                          .toList(),
                      value: _priority,
                      onChanged: (v) => setState(() => _priority = v),
                    ),
                    CrmTextField(
                      label: "Coordinate",
                      icon: Icons.location_searching,
                      controller: _coordinateCtrl,
                      readOnly: true,
                      suffix: isLocationRequired
                          ? const Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: Colors.grey,
                            )
                          : IconButton(
                              icon: const Icon(Icons.my_location),
                              onPressed: _getCurrentLocation,
                            ),
                    ),
                    CrmTextField(
                      label: "Location Address",
                      icon: Icons.location_on_outlined,
                      controller: _locationCtrl,
                      readOnly: isLocationRequired,
                      maxLines: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "Description",
                  icon: Icons.description_outlined,
                  children: [
                    CrmTextField(
                      label: "Description",
                      icon: Icons.notes_rounded,
                      controller: _descCtrl,
                      maxLines: 4,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
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
    final isEdit = widget.editData != null;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.local_activity_rounded,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Edit Activity" : "Log Activity",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              isEdit
                  ? "Update activity details"
                  : "Track your sales interactions",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1E4CCB)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 0.5),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isEdit = widget.editData != null;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isEdit ? widget.onBack : _clearForm,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEdit ? "Back" : "Clear",
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _saveActivity,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E4CCB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Save Activity",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
