import 'package:flutter/material.dart';
import '../../../../models/contact.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../shared/models/dropdown_option.dart';
import '../../../../shared/utils/crm_session.dart';
import '../../../../shared/utils/pipe_data_parser.dart';
import '../../../../shared/widgets/crm_form_widgets.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class PotentialPage extends StatefulWidget {
  const PotentialPage({super.key});

  @override
  State<PotentialPage> createState() => _PotentialPageState();
}

class _PotentialPageState extends State<PotentialPage> {
  final _crmService = VenusCRMService();
  final _session = CrmSession();

  bool _isLoading = false;
  bool _isSuspend = false;

  String? _busCode;
  String? _salesCode;
  String? _accountCode;
  String? _methodCode;
  String? _stageCode;
  String? _selectedContactId;

  List<DropdownOption> _businesses = [];
  List<DropdownOption> _sales = [];
  List<DropdownOption> _accounts = [];
  List<DropdownOption> _methods = [];
  List<DropdownOption> _stages = [];
  List<DropdownOption> _contacts = [];
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
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    setState(() => _isLoading = true);
    try {
      await _session.load();
      _busCode = _session.busCode;
      
      final bus = _busCode ?? '';
      final auth = _session.userAuth;

      final businessResult = await _crmService.getBusiness(bus);
      final salesResult = await _crmService.getSales(bus, auth);
      final accountResult = await _crmService.getAccount(bus, auth, '', '1');
      final methodResult = await _crmService.getMethodPotential(bus);
      final stageResult = await _crmService.getStage(bus);

      if (mounted) {
        setState(() {
          _businesses = PipeDataParser.parseCodeName(businessResult?.code, businessResult?.name);
          _sales = PipeDataParser.parseSales(salesResult?.pref1, salesResult?.pref2, salesResult?.pref3);
          _accounts = PipeDataParser.parseCodeName(accountResult?.code, accountResult?.name);
          _methods = PipeDataParser.parseCodeName(methodResult?.code, methodResult?.name);
          _stages = PipeDataParser.parseCodeName(stageResult?.code, stageResult?.name);
          
          if (_busCode == null && _businesses.isNotEmpty) _busCode = _businesses.first.code;
          _salesCode = _session.salesCode;
        });
      }
    } catch (e) {
      if (mounted) showCrmSnackBar(context, 'Failed to load data: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadContactsForAccount() async {
    if (_busCode == null || _accountCode == null) return;

    setState(() => _isLoading = true);
    try {
      final accountName = _optionName(_accounts, _accountCode);
      final result = await _crmService.getContact(
        _busCode!,
        _session.userAuth,
        '',
      );
      if (!mounted) return;

      final contacts = result != null
          ? _buildContactsForAccount(result, _accountCode!, accountName)
          : <DropdownOption>[];

      setState(() {
        _contacts = contacts;
        _selectedContactId = null;
        _contactPositionCtrl.clear();
        _contactDivisionCtrl.clear();
        _contactPhoneCtrl.clear();
      });

      if (contacts.isEmpty) {
        showCrmSnackBar(context, 'No contacts found for selected account', isError: true);
      }
    } catch (e) {
      if (mounted) showCrmSnackBar(context, 'Failed to load contacts: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<DropdownOption>> _searchContactsForAccount(String query) async {
    if (_busCode == null || _accountCode == null) return [];
    final result = await _crmService.getContact(_busCode!, _session.userAuth, query);
    if (result == null) return [];
    final accountName = _optionName(_accounts, _accountCode);
    final contacts = _buildContactsForAccount(result, _accountCode!, accountName);
    if (mounted) setState(() => _contacts = contacts);
    return contacts;
  }

  List<DropdownOption> _buildContactsForAccount(
    Contact result,
    String accountCode,
    String accountName,
  ) {
    final accountIds = PipeDataParser.split(result.pref1);
    final accountNames = PipeDataParser.split(result.pref2);
    final contactIds = PipeDataParser.split(result.pref3);
    final contactNames = PipeDataParser.split(result.pref4);

    final normalizedAccountCode = accountCode.trim().toLowerCase();
    final normalizedAccountName = accountName.trim().toLowerCase();

    final contacts = <DropdownOption>[];
    final seen = <String>{};
    final rowCount = contactIds.length;

    for (var i = 0; i < rowCount; i++) {
      final rowAccountId = i < accountIds.length ? accountIds[i].trim() : '';
      final rowAccountName = i < accountNames.length ? accountNames[i].trim() : '';
      final contactId = contactIds[i].trim();
      final contactName = i < contactNames.length ? contactNames[i].trim() : contactId;

      if (contactId.isEmpty) continue;

      final matchesAccount = rowAccountId.toLowerCase() == normalizedAccountCode ||
          rowAccountName.toLowerCase() == normalizedAccountName ||
          rowAccountName.toLowerCase() == normalizedAccountCode ||
          rowAccountId.toLowerCase() == normalizedAccountName ||
          (normalizedAccountCode.isNotEmpty &&
              rowAccountId.toLowerCase().contains(normalizedAccountCode)) ||
          (normalizedAccountName.isNotEmpty &&
              rowAccountName.toLowerCase().contains(normalizedAccountName));

      if (!matchesAccount) continue;
      if (seen.contains(contactId)) continue;
      seen.add(contactId);

      contacts.add(DropdownOption(code: contactId, name: contactName));
    }

    return contacts;
  }

  Future<void> _onContactChanged(String? contactId) async {
    if (contactId == null) return;
    setState(() {
      _selectedContactId = contactId;
      _isLoading = true;
    });
    
    try {
      final res = await _crmService.getDataContact(_busCode!, _session.userAuth, 'ID', contactId, '', '');
      if (res != null && mounted) {
        // Pref5: Position, Pref10: Division, Pref8: Phone (from API documentation)
        setState(() {
          _contactPositionCtrl.text = res.pref5 ?? '';
          _contactDivisionCtrl.text = res.pref10 ?? '';
          _contactPhoneCtrl.text = res.pref8 ?? '';
        });
      }
    } catch (e) {
      if (mounted) showCrmSnackBar(context, 'Failed to load contact details: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => controller.text = "${picked.month}/${picked.day}/${picked.year}");
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
      'desc': _contactDescCtrl.text.trim(),
    };

    setState(() {
      _savedContacts.add(row);
      _selectedContactRow = _savedContacts.length - 1;
      _selectedContactId = null;
      _contactPositionCtrl.clear();
      _contactDivisionCtrl.clear();
      _contactPhoneCtrl.clear();
      _contactDescCtrl.clear();
    });
    showCrmSnackBar(context, 'Contact added to list');
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
      'desc': _stageDescCtrl.text.trim(),
    };

    setState(() {
      _savedStages.add(row);
      _selectedStageRow = _savedStages.length - 1;
      _stageCode = null;
      _startDateCtrl.clear();
      _finishDateCtrl.clear();
      _stageDescCtrl.clear();
    });
    showCrmSnackBar(context, 'Stage added to list');
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
                  CrmDropdownField(label: "Business", items: _businesses, value: _busCode, onChanged: (v) => setState(() => _busCode = v)),
                  CrmDropdownField(label: "Account", items: _accounts, value: _accountCode, onChanged: (v) {
                    setState(() => _accountCode = v);
                    _loadContactsForAccount();
                  }),
                  CrmDropdownField(label: "Owner", items: _sales, value: _salesCode, onChanged: (v) => setState(() => _salesCode = v)),
                  CrmTextField(label: "Name", icon: Icons.assignment_outlined, controller: _nameCtrl),
                  CrmTextField(label: "Amount", icon: Icons.monetization_on_outlined, controller: _amountCtrl, keyboardType: TextInputType.number),
                  CrmTextField(label: "Closing Date", icon: Icons.calendar_today_outlined, controller: _closingDateCtrl, readOnly: true, onTap: () => _selectDate(context, _closingDateCtrl)),
                  CrmDropdownField(label: "Method", items: _methods, value: _methodCode, onChanged: (v) => setState(() => _methodCode = v)),
                  CrmTextField(label: "Location", icon: Icons.location_on_outlined, controller: _locationCtrl),
                  CrmTextField(label: "Description", icon: Icons.description, controller: _descCtrl, maxLines: 3),
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
                    hint: _accountCode == null ? "Select account first" : "Select contact",
                  ),
                  CrmTextField(label: "Position", icon: Icons.work_outline, controller: _contactPositionCtrl, readOnly: true),
                  CrmTextField(label: "Division", icon: Icons.business_outlined, controller: _contactDivisionCtrl, readOnly: true),
                  CrmTextField(label: "Phone", icon: Icons.phone_android_outlined, controller: _contactPhoneCtrl, readOnly: true),
                  CrmTextField(label: "Description", icon: Icons.notes_rounded, controller: _contactDescCtrl),
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
                  CrmDropdownField(label: "Stage", items: _stages, value: _stageCode, onChanged: (v) => setState(() => _stageCode = v)),
                  Row(
                    children: [
                      Expanded(child: CrmTextField(label: "Start Date", icon: Icons.calendar_today_outlined, controller: _startDateCtrl, readOnly: true, onTap: () => _selectDate(context, _startDateCtrl))),
                      const SizedBox(width: 12),
                      Expanded(child: CrmTextField(label: "Finish Date", icon: Icons.calendar_today_outlined, controller: _finishDateCtrl, readOnly: true, onTap: () => _selectDate(context, _finishDateCtrl))),
                    ],
                  ),
                  CrmTextField(label: "Description", icon: Icons.notes_rounded, controller: _stageDescCtrl),
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
          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.stars_rounded, color: Colors.green),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Potential Lead", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Analyze your business growth", style: TextStyle(color: Colors.grey)),
          ],
        )
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20, color: const Color(0xFF1E4CCB)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        ? ['Name', 'Position', 'Division', 'Phone', 'Desc']
        : ['Stage Name', 'Start Date', 'Finish Date', 'Desc'];

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
              .map((c) => DataColumn(
                    label: Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ))
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
                  } else {
                    _selectedStageRow = index;
                  }
                });
              },
              cells: cells
                  .map((text) => DataCell(Text(text, style: const TextStyle(fontSize: 12))))
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
            onPressed: () {},
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.redAccent)),
            child: const Text("Clear All", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => showCrmSnackBar(context, 'Post Potential API not available in documentation'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E4CCB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text("Save Potential", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
