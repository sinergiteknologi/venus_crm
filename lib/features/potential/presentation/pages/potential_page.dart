import 'package:flutter/material.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../envelopes/post_potential_envelope.dart';
import '../../../../models/data_contact2.dart';
import '../../../../shared/models/dropdown_option.dart';
import '../../../../shared/utils/crm_session.dart';
import '../../../../shared/utils/pipe_data_parser.dart';
import '../../../../shared/widgets/crm_form_widgets.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class PotentialEditData {
  final String potentialId;
  final String businessName;
  final String accountName;
  final String name;
  final String closingDate;
  final String stageDisplay;
  final String finishDisplay;
  final String ownerName;
  final String amount;
  final String methodName;
  final String location;
  final String leadSource;
  final String description;
  final bool isSuspend;
  final String accountCode;
  final String contactRecords;
  final String stageRecords;

  const PotentialEditData({
    required this.potentialId,
    required this.businessName,
    required this.accountName,
    required this.name,
    required this.closingDate,
    required this.stageDisplay,
    required this.finishDisplay,
    required this.ownerName,
    required this.amount,
    required this.methodName,
    required this.location,
    required this.leadSource,
    required this.description,
    required this.isSuspend,
    required this.accountCode,
    required this.contactRecords,
    required this.stageRecords,
  });
}

class PotentialPage extends StatefulWidget {
  final PotentialEditData? editData;
  final VoidCallback? onBack;
  final VoidCallback? onCompleted;

  const PotentialPage({
    super.key,
    this.editData,
    this.onBack,
    this.onCompleted,
  });

  @override
  State<PotentialPage> createState() => _PotentialPageState();
}

class _PotentialPageState extends State<PotentialPage> {
  final _crmService = VenusCRMService();
  final _session = CrmSession();

  bool _isLoading = false;
  int _contactRequestId = 0;
  bool _isSuspend = false;
  String _potentialId = '';

  String? _busCode;
  String? _ownerUser;
  String? _accountCode;
  String? _methodCode;
  String? _stageCode;
  String? _leadSourceCode;
  String? _selectedContactId;

  List<DropdownOption> _businesses = [];
  List<DropdownOption> _allSales = [];
  List<DropdownOption> _sales = [];
  List<DropdownOption> _accounts = [];
  List<DropdownOption> _methods = [];
  List<DropdownOption> _stages = [];
  List<DropdownOption> _leadSources = [];
  List<DropdownOption> _contacts = [];
  final Map<String, String> _contactPositions = {};
  final Map<String, String> _contactDivisions = {};
  final Map<String, String> _contactPhones = {};
  List<Map<String, String>> _savedContacts = [];
  List<Map<String, String>> _savedStages = [];
  int? _selectedContactRow;
  int? _selectedStageRow;

  final _closingDateCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _finishDateCtrl = TextEditingController();
  final _stageDescCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Contact section fields
  final _contactPositionCtrl = TextEditingController();
  final _contactDivisionCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactDescCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _potentialId = widget.editData?.potentialId ?? 'New01';
    _isSuspend = widget.editData?.isSuspend ?? false;
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    setState(() => _isLoading = true);
    try {
      await _session.load();
      _busCode = _session.busCode.isEmpty ? null : _session.busCode;
      final businessResult = await _crmService.getBusiness(_busCode ?? '');

      if (mounted) {
        setState(() {
          _businesses = PipeDataParser.parseCodeName(
            businessResult?.code,
            businessResult?.name,
          );
          if (widget.editData != null) {
            _busCode =
                _codeByName(_businesses, widget.editData!.businessName) ??
                _busCode;
          }
          if ((_busCode == null || _busCode!.isEmpty) &&
              _businesses.isNotEmpty) {
            _busCode = _businesses.first.code;
          }
        });
      }
      await _loadBusinessData(setDefaultOwner: widget.editData == null);
      if (mounted && widget.editData != null) {
        await _applyEditData(widget.editData!);
      }
    } catch (e) {
      if (mounted) {
        showCrmSnackBar(context, 'Failed to load data: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBusinessData({required bool setDefaultOwner}) async {
    final bus = _busCode;
    if (bus == null || bus.isEmpty) return;

    final results = await Future.wait([
      _crmService.getSales(bus, _session.userAuth),
      _crmService.getAccount(bus, _session.userAuth, '', 'POTENTIAL'),
      _crmService.getMethodPotential(bus),
      _crmService.getStage(bus),
      _crmService.getLeadSource(bus),
    ]);
    if (!mounted) return;

    final salesResult = results[0] as dynamic;
    final accountResult = results[1] as dynamic;
    final methodResult = results[2] as dynamic;
    final stageResult = results[3] as dynamic;
    final leadSourceResult = results[4] as dynamic;
    final owners = PipeDataParser.parseSalesOwners(
      salesResult?.pref1,
      salesResult?.pref2,
      salesResult?.pref3,
    );

    setState(() {
      _allSales = owners;
      _sales = owners;
      _accounts = PipeDataParser.parseCodeName(
        accountResult?.code,
        accountResult?.name,
      );
      _methods = PipeDataParser.parseCodeName(
        methodResult?.code,
        methodResult?.name,
      );
      _stages = PipeDataParser.parseCodeName(
        stageResult?.code,
        stageResult?.name,
      );
      _leadSources = PipeDataParser.parseCodeName(
        leadSourceResult?.code,
        leadSourceResult?.name,
      );
      if (setDefaultOwner) _setDefaultOwner();
    });
  }

  void _setDefaultOwner() {
    _ownerUser = _codeByName(_allSales, _session.salesName);
    if (_ownerUser == null &&
        _allSales.any((owner) => owner.code == _session.username)) {
      _ownerUser = _session.username;
    }
    if (_ownerUser == null && _allSales.isNotEmpty) {
      _ownerUser = _allSales.first.code;
    }
  }

  Future<List<DropdownOption>> _searchAccounts(String query) async {
    final bus = _busCode;
    if (bus == null || bus.isEmpty) return [];
    final result = await _crmService.getAccount(
      bus,
      _session.userAuth,
      query,
      'POTENTIAL',
    );
    final accounts = PipeDataParser.parseCodeName(result?.code, result?.name);
    if (mounted) setState(() => _accounts = accounts);
    return accounts;
  }

  String? _codeByName(List<DropdownOption> options, String name) {
    for (final option in options) {
      if (option.name == name || option.code == name) return option.code;
    }
    return null;
  }

  Future<void> _applyEditData(PotentialEditData data) async {
    setState(() {
      _potentialId = data.potentialId;
      _accountCode = _accounts.any((item) => item.code == data.accountCode)
          ? data.accountCode
          : _codeByName(_accounts, data.accountName);
      _ownerUser = _codeByName(_allSales, data.ownerName);
      _methodCode = _codeByName(_methods, data.methodName);
      _leadSourceCode = _codeByName(_leadSources, data.leadSource);
      _nameCtrl.text = data.name;
      _closingDateCtrl.text = data.closingDate;
      _amountCtrl.text = data.amount;
      _locationCtrl.text = data.location;
      _descCtrl.text = data.description;
      _isSuspend = data.isSuspend;
      _savedContacts = _parseContactRecords(data.contactRecords);
      _savedStages = _parseStageRecords(data.stageRecords);
    });
    if (_accountCode != null) await _loadContactsForAccount();
  }

  List<Map<String, String>> _parseContactRecords(String value) {
    return PipeDataParser.split(value)
        .where((record) {
          final fields = record.split(';');
          return fields.isNotEmpty && fields.first == _potentialId;
        })
        .map((record) {
          final fields = record.split(';');
          return {
            'id': fields.length > 1 ? fields[1] : '',
            'name': fields.length > 2 ? fields[2] : '',
            'position': fields.length > 3 ? fields[3] : '',
            'division': fields.length > 4 ? fields[4] : '',
            'phone': fields.length > 5 ? fields[5] : '',
            'desc': fields.length > 6 ? fields[6] : '',
          };
        })
        .where((row) => row['id']!.isNotEmpty)
        .toList();
  }

  List<Map<String, String>> _parseStageRecords(String value) {
    return PipeDataParser.split(value)
        .where((record) {
          final fields = record.split(';');
          return fields.isNotEmpty && fields.first == _potentialId;
        })
        .map((record) {
          final fields = record.split(';');
          return {
            'code': fields.length > 1 ? fields[1] : '',
            'name': fields.length > 2 ? fields[2] : '',
            'startDate': fields.length > 3 ? fields[3] : '',
            'finishDate': fields.length > 4 ? fields[4] : '',
            'desc': fields.length > 5 ? fields[5] : '',
          };
        })
        .where((row) => row['code']!.isNotEmpty)
        .toList();
  }

  Future<void> _onBusinessChanged(String? value) async {
    setState(() {
      _busCode = value;
      _ownerUser = null;
      _accountCode = null;
      _methodCode = null;
      _stageCode = null;
      _leadSourceCode = null;
      _selectedStageRow = null;
      _sales = [];
      _allSales = [];
      _accounts = [];
      _methods = [];
      _stages = [];
      _leadSources = [];
      _clearAccountContacts();
      _savedStages = [];
    });
    setState(() => _isLoading = true);
    try {
      await _loadBusinessData(setDefaultOwner: true);
    } catch (e) {
      if (mounted) {
        showCrmSnackBar(context, 'Failed to load data: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadContactsForAccount() async {
    if (_busCode == null || _accountCode == null) return;

    final requestId = ++_contactRequestId;
    final business = _busCode!;
    final account = _accountCode!;
    setState(() => _isLoading = true);
    try {
      final result = await _crmService.getContactForAccount(
        business,
        _session.username,
        account,
        '',
      );
      if (!mounted ||
          requestId != _contactRequestId ||
          business != _busCode ||
          account != _accountCode) {
        return;
      }

      final contacts = result != null
          ? _buildContactsForAccount(result)
          : <DropdownOption>[];

      setState(() {
        _contacts = contacts;
        _selectedContactId = null;
        _contactPositionCtrl.clear();
        _contactDivisionCtrl.clear();
        _contactPhoneCtrl.clear();
      });

      if (contacts.isEmpty) {
        showCrmSnackBar(
          context,
          'No contacts found for selected account',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted && requestId == _contactRequestId) {
        showCrmSnackBar(context, 'Failed to load contacts: $e', isError: true);
      }
    } finally {
      if (mounted && requestId == _contactRequestId) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearAccountContacts() {
    ++_contactRequestId;
    _selectedContactId = null;
    _selectedContactRow = null;
    _contacts = [];
    _savedContacts = [];
    _contactPositions.clear();
    _contactDivisions.clear();
    _contactPhones.clear();
    _contactPositionCtrl.clear();
    _contactDivisionCtrl.clear();
    _contactPhoneCtrl.clear();
    _contactDescCtrl.clear();
  }

  Future<List<DropdownOption>> _searchContactsForAccount(String query) async {
    if (_busCode == null || _accountCode == null) return [];
    final requestId = ++_contactRequestId;
    final business = _busCode!;
    final account = _accountCode!;
    final result = await _crmService.getContactForAccount(
      business,
      _session.username,
      account,
      query,
    );
    if (!mounted ||
        requestId != _contactRequestId ||
        business != _busCode ||
        account != _accountCode ||
        result == null) {
      return [];
    }
    final contacts = _buildContactsForAccount(result);
    setState(() => _contacts = contacts);
    return contacts;
  }

  List<DropdownOption> _buildContactsForAccount(DataContact2 result) {
    final contactIds = PipeDataParser.split(result.pref1);
    final contactNames = PipeDataParser.split(result.pref2);
    final positions = PipeDataParser.split(result.pref3);
    final divisions = PipeDataParser.split(result.pref4);
    final phones = PipeDataParser.split(result.pref5);
    final contacts = <DropdownOption>[];
    final seen = <String>{};
    _contactPositions.clear();
    _contactDivisions.clear();
    _contactPhones.clear();

    for (var i = 0; i < contactIds.length; i++) {
      final contactId = contactIds[i].trim();
      final contactName = i < contactNames.length
          ? contactNames[i].trim()
          : contactId;

      if (contactId.isEmpty || !seen.add(contactId)) continue;
      _contactPositions[contactId] = i < positions.length ? positions[i] : '';
      _contactDivisions[contactId] = i < divisions.length ? divisions[i] : '';
      _contactPhones[contactId] = i < phones.length ? phones[i] : '';

      contacts.add(DropdownOption(code: contactId, name: contactName));
    }

    return contacts;
  }

  Future<void> _onContactChanged(String? contactId) async {
    if (contactId == null) return;
    setState(() {
      _selectedContactId = contactId;
      _contactPositionCtrl.text = _contactPositions[contactId] ?? '';
      _contactDivisionCtrl.text = _contactDivisions[contactId] ?? '';
      _contactPhoneCtrl.text = _contactPhones[contactId] ?? '';
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(
        () => controller.text = "${picked.month}/${picked.day}/${picked.year}",
      );
    }
  }

  String _optionName(List<DropdownOption> options, String? code) {
    if (code == null) return '';
    for (final item in options) {
      if (item.code == code) return item.name;
    }
    return code;
  }

  void _saveContact() {
    if (_selectedContactId == null) {
      showCrmSnackBar(context, 'Please select a contact', isError: true);
      return;
    }

    final row = {
      'id': _selectedContactId!,
      'name': _optionName(_contacts, _selectedContactId),
      'position': _contactPositionCtrl.text.trim(),
      'division': _contactDivisionCtrl.text.trim(),
      'phone': _contactPhoneCtrl.text.trim(),
      'desc': _descriptionValue(_contactDescCtrl.text),
    };

    setState(() {
      if (_selectedContactRow != null &&
          _selectedContactRow! < _savedContacts.length) {
        _savedContacts[_selectedContactRow!] = row;
      } else {
        final existingIndex = _savedContacts.indexWhere(
          (contact) => contact['id'] == row['id'],
        );
        if (existingIndex >= 0) {
          _savedContacts[existingIndex] = row;
        } else {
          _savedContacts.add(row);
        }
      }
      _selectedContactId = null;
      _selectedContactRow = null;
      _contactPositionCtrl.clear();
      _contactDivisionCtrl.clear();
      _contactPhoneCtrl.clear();
      _contactDescCtrl.clear();
    });
    showCrmSnackBar(context, 'Contact saved');
  }

  void _deleteContact() {
    if (_selectedContactRow == null || _savedContacts.isEmpty) {
      showCrmSnackBar(context, 'Select a contact row to delete', isError: true);
      return;
    }
    setState(() {
      _savedContacts.removeAt(_selectedContactRow!);
      _selectedContactRow = null;
    });
  }

  void _saveStage() {
    if (_stageCode == null || _stageCode!.isEmpty) {
      showCrmSnackBar(context, 'Please select a stage', isError: true);
      return;
    }
    if (_startDateCtrl.text.trim().isEmpty) {
      showCrmSnackBar(context, 'Please select start date', isError: true);
      return;
    }

    final row = {
      'code': _stageCode!,
      'name': _optionName(_stages, _stageCode),
      'startDate': _startDateCtrl.text.trim(),
      'finishDate': _finishDateCtrl.text.trim(),
      'desc': _descriptionValue(_stageDescCtrl.text),
    };

    setState(() {
      if (_selectedStageRow != null &&
          _selectedStageRow! < _savedStages.length) {
        _savedStages[_selectedStageRow!] = row;
      } else {
        final existingIndex = _savedStages.indexWhere(
          (stage) => stage['code'] == row['code'],
        );
        if (existingIndex >= 0) {
          _savedStages[existingIndex] = row;
        } else {
          _savedStages.add(row);
        }
      }
      _stageCode = null;
      _selectedStageRow = null;
      _startDateCtrl.clear();
      _finishDateCtrl.clear();
      _stageDescCtrl.clear();
    });
    showCrmSnackBar(context, 'Stage saved');
  }

  void _deleteStage() {
    if (_selectedStageRow == null || _savedStages.isEmpty) {
      showCrmSnackBar(context, 'Select a stage row to delete', isError: true);
      return;
    }
    setState(() {
      _savedStages.removeAt(_selectedStageRow!);
      _selectedStageRow = null;
    });
  }

  void _deleteSavedRow({required bool isContact, required int index}) {
    setState(() {
      if (isContact) {
        _savedContacts.removeAt(index);
        _selectedContactRow = null;
        _selectedContactId = null;
        _contactPositionCtrl.clear();
        _contactDivisionCtrl.clear();
        _contactPhoneCtrl.clear();
        _contactDescCtrl.clear();
      } else {
        _savedStages.removeAt(index);
        _selectedStageRow = null;
        _stageCode = null;
        _startDateCtrl.clear();
        _finishDateCtrl.clear();
        _stageDescCtrl.clear();
      }
    });
  }

  String _descriptionValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '-' : trimmed;
  }

  bool _validate() {
    final validAccount =
        _accountCode != null &&
        _accounts.any((account) => account.code == _accountCode);
    if (!validAccount) {
      showCrmSnackBar(context, 'Please select a valid account', isError: true);
      return false;
    }
    final validOwner =
        _ownerUser != null &&
        _allSales.any((owner) => owner.code == _ownerUser);
    if (!validOwner) {
      showCrmSnackBar(context, 'Please select a valid owner', isError: true);
      return false;
    }
    if (_nameCtrl.text.trim().isEmpty) {
      showCrmSnackBar(context, 'Please enter a potential name', isError: true);
      return false;
    }
    if (_locationCtrl.text.trim().isEmpty) {
      showCrmSnackBar(context, 'Please enter a location', isError: true);
      return false;
    }
    if (_savedStages.isEmpty) {
      showCrmSnackBar(context, 'Please add at least one stage', isError: true);
      return false;
    }
    if (_savedContacts.isEmpty) {
      showCrmSnackBar(
        context,
        'Please add at least one contact',
        isError: true,
      );
      return false;
    }
    return true;
  }

  String _joinRows(String key, List<Map<String, String>> rows) {
    return rows
        .map(
          (row) => key == 'desc'
              ? _descriptionValue(row[key] ?? '')
              : row[key] ?? '',
        )
        .join('|');
  }

  Future<void> _savePotential() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      final stages = [
        ..._savedStages,
      ]..sort((a, b) => (a['startDate'] ?? '').compareTo(b['startDate'] ?? ''));
      final contacts = [..._savedContacts]
        ..sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      final envelope = PostPotentialEnvelope(
        prmPotentialID: _potentialId.isEmpty ? 'New01' : _potentialId,
        prmBusCode: _busCode!,
        prmActID: _accountCode!,
        prmPotentialName: _nameCtrl.text.trim(),
        prmClosingDate: _closingDateCtrl.text.trim(),
        prmLeadSourceCode: _leadSourceCode ?? '',
        prmPotentialOwner: _ownerUser!,
        prmAmount: _amountCtrl.text.trim(),
        prmDescription: _descCtrl.text.trim(),
        prmIsSuspend: _isSuspend ? '1' : '0',
        prmStageCode: _joinRows('code', stages),
        prmStageName: _joinRows('name', stages),
        prmStartDate: _joinRows('startDate', stages),
        prmFinishedDate: _joinRows('finishDate', stages),
        prmStageDesc: _joinRows('desc', stages),
        prmContactCode: _joinRows('id', contacts),
        prmContactDescription: _joinRows('desc', contacts),
        prmUser: _session.username,
        prmMethodCode: _methodCode ?? '',
        prmLocation: _locationCtrl.text.trim(),
      );
      final result = await _crmService.postPotential(envelope);
      if (!mounted) return;
      if (result?.status == true) {
        showCrmSnackBar(context, 'Data Successfully Added');
        widget.onCompleted?.call();
      } else {
        showCrmSnackBar(context, 'Failed to save the data', isError: true);
      }
    } catch (e) {
      if (mounted) showCrmSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clear() {
    setState(() {
      _potentialId = 'New01';
      _accountCode = null;
      _methodCode = null;
      _stageCode = null;
      _leadSourceCode = null;
      _selectedStageRow = null;
      _clearAccountContacts();
      _savedStages = [];
      _isSuspend = false;
      _closingDateCtrl.clear();
      _startDateCtrl.clear();
      _finishDateCtrl.clear();
      _stageDescCtrl.clear();
      _nameCtrl.clear();
      _amountCtrl.clear();
      _locationCtrl.clear();
      _descCtrl.clear();
      _contactPositionCtrl.clear();
      _contactDivisionCtrl.clear();
      _contactPhoneCtrl.clear();
      _contactDescCtrl.clear();
      _setDefaultOwner();
    });
  }

  @override
  void dispose() {
    _closingDateCtrl.dispose();
    _startDateCtrl.dispose();
    _finishDateCtrl.dispose();
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _contactPositionCtrl.dispose();
    _contactDivisionCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactDescCtrl.dispose();
    _stageDescCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: "Potential Information",
                icon: Icons.trending_up_rounded,
                children: [
                  CrmDropdownField(
                    label: "Business",
                    items: _businesses,
                    value: _busCode,
                    onChanged: _onBusinessChanged,
                  ),
                  CrmDropdownField(
                    label: "Account",
                    items: _accounts,
                    value: _accountCode,
                    onSearch: _searchAccounts,
                    onChanged: (v) {
                      setState(() {
                        _accountCode = v;
                        _clearAccountContacts();
                      });
                      if (v != null && v.isNotEmpty) {
                        _loadContactsForAccount();
                      }
                    },
                  ),
                  CrmDropdownField(
                    label: "Owner",
                    items: _sales,
                    value: _ownerUser,
                    onChanged: (v) => setState(() => _ownerUser = v),
                  ),
                  CrmTextField(
                    label: "Name",
                    icon: Icons.assignment_outlined,
                    controller: _nameCtrl,
                  ),
                  CrmTextField(
                    label: "Amount",
                    icon: Icons.monetization_on_outlined,
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  CrmTextField(
                    label: "Closing Date",
                    icon: Icons.calendar_today_outlined,
                    controller: _closingDateCtrl,
                    readOnly: true,
                    onTap: () => _selectDate(context, _closingDateCtrl),
                  ),
                  CrmDropdownField(
                    label: "Method",
                    items: _methods,
                    value: _methodCode,
                    onChanged: (v) => setState(() => _methodCode = v),
                  ),
                  CrmTextField(
                    label: "Location",
                    icon: Icons.location_on_outlined,
                    controller: _locationCtrl,
                  ),
                  CrmTextField(
                    label: "Description",
                    icon: Icons.description,
                    controller: _descCtrl,
                    maxLines: 3,
                  ),
                  CrmSwitchTile(
                    title: "Is Suspend?",
                    value: _isSuspend,
                    onChanged: (val) => setState(() => _isSuspend = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "Related Contacts",
                icon: Icons.people_alt_outlined,
                children: [
                  CrmDropdownField(
                    label: "Contact Name",
                    items: _contacts,
                    value: _selectedContactId,
                    onChanged: _onContactChanged,
                    onSearch: _searchContactsForAccount,
                    enabled: _accountCode != null,
                    hint: _accountCode == null
                        ? "Select account first"
                        : "Select contact",
                  ),
                  CrmTextField(
                    label: "Position",
                    icon: Icons.work_outline,
                    controller: _contactPositionCtrl,
                    readOnly: true,
                  ),
                  CrmTextField(
                    label: "Division",
                    icon: Icons.business_outlined,
                    controller: _contactDivisionCtrl,
                    readOnly: true,
                  ),
                  CrmTextField(
                    label: "Phone",
                    icon: Icons.phone_android_outlined,
                    controller: _contactPhoneCtrl,
                    readOnly: true,
                  ),
                  CrmTextField(
                    label: "Description",
                    icon: Icons.notes_rounded,
                    controller: _contactDescCtrl,
                  ),
                  const SizedBox(height: 8),
                  _buildSubActionButtons("Contact"),
                  const SizedBox(height: 16),
                  _buildMiniTable("Contact"),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "Stage History",
                icon: Icons.history_rounded,
                children: [
                  CrmDropdownField(
                    label: "Stage",
                    items: _stages,
                    value: _stageCode,
                    onChanged: (v) => setState(() => _stageCode = v),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CrmTextField(
                          label: "Start Date",
                          icon: Icons.calendar_today_outlined,
                          controller: _startDateCtrl,
                          readOnly: true,
                          onTap: () => _selectDate(context, _startDateCtrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CrmTextField(
                          label: "Finish Date",
                          icon: Icons.calendar_today_outlined,
                          controller: _finishDateCtrl,
                          readOnly: true,
                          onTap: () => _selectDate(context, _finishDateCtrl),
                        ),
                      ),
                    ],
                  ),
                  CrmTextField(
                    label: "Description",
                    icon: Icons.notes_rounded,
                    controller: _stageDescCtrl,
                  ),
                  const SizedBox(height: 8),
                  _buildSubActionButtons("Stage"),
                  const SizedBox(height: 16),
                  _buildMiniTable("Stage"),
                ],
              ),
              const SizedBox(height: 32),
              _buildMainActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.stars_rounded, color: Colors.green),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Potential Lead",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Analyze your business growth",
              style: TextStyle(color: Colors.grey),
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

  Widget _buildSubActionButtons(String type) {
    final isContact = type == 'Contact';
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isContact ? _saveContact : _saveStage,
            icon: const Icon(Icons.add, size: 18),
            label: Text("Save $type"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E4CCB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isContact ? _deleteContact : _deleteStage,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text("Delete"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniTable(String type) {
    final isContact = type == 'Contact';
    final rows = isContact ? _savedContacts : _savedStages;
    final selectedRow = isContact ? _selectedContactRow : _selectedStageRow;

    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          'No $type added yet',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    final columns = isContact
        ? ['Name', 'Position', 'Division', 'Phone', 'Desc', 'Action']
        : ['Stage Name', 'Start Date', 'Finish Date', 'Desc', 'Action'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 44,
          columnSpacing: 16,
          columns: columns
              .map(
                (c) => DataColumn(
                  label: Text(
                    c,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
          rows: List.generate(rows.length, (index) {
            final row = rows[index];
            final isSelected = selectedRow == index;
            final cells = isContact
                ? [
                    row['name'] ?? '',
                    row['position'] ?? '',
                    row['division'] ?? '',
                    row['phone'] ?? '',
                    row['desc'] ?? '',
                  ]
                : [
                    row['name'] ?? '',
                    row['startDate'] ?? '',
                    row['finishDate'] ?? '',
                    row['desc'] ?? '',
                  ];

            return DataRow(
              selected: isSelected,
              onSelectChanged: (_) {
                setState(() {
                  if (isContact) {
                    _selectedContactRow = index;
                    _selectedContactId = row['id'];
                    _contactPositionCtrl.text = row['position'] ?? '';
                    _contactDivisionCtrl.text = row['division'] ?? '';
                    _contactPhoneCtrl.text = row['phone'] ?? '';
                    _contactDescCtrl.text = row['desc'] == '-'
                        ? ''
                        : row['desc'] ?? '';
                  } else {
                    _selectedStageRow = index;
                    _stageCode = row['code'];
                    _startDateCtrl.text = row['startDate'] ?? '';
                    _finishDateCtrl.text = row['finishDate'] ?? '';
                    _stageDescCtrl.text = row['desc'] == '-'
                        ? ''
                        : row['desc'] ?? '';
                  }
                });
              },
              cells: cells
                  .map(
                    (text) => DataCell(
                      Text(text, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .followedBy([
                    DataCell(
                      IconButton(
                        tooltip: 'Delete $type',
                        onPressed: () =>
                            _deleteSavedRow(isContact: isContact, index: index),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ])
                  .toList(),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMainActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.redAccent),
            ),
            child: const Text(
              "Back",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _clear,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              "Clear",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _savePotential,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E4CCB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              "Save Potential",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
