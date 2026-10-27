import 'package:flutter/material.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../shared/models/dropdown_option.dart';
import '../../../../shared/utils/crm_session.dart';
import '../../../../shared/utils/pipe_data_parser.dart';
import '../../../../shared/widgets/crm_form_widgets.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../activity/presentation/pages/activity_page.dart';
import '../../../contact/presentation/pages/contact_page.dart';
import '../../../lead/presentation/pages/lead_page.dart';
import '../../../potential/presentation/pages/potential_page.dart';

class FindViewPage extends StatefulWidget {
  final ValueChanged<LeadEditData> onLeadSelected;
  final ValueChanged<ContactEditData> onContactSelected;
  final ValueChanged<PotentialEditData> onPotentialSelected;
  final ValueChanged<ActivityEditData> onActivitySelected;

  const FindViewPage({
    super.key,
    required this.onLeadSelected,
    required this.onContactSelected,
    required this.onPotentialSelected,
    required this.onActivitySelected,
  });

  @override
  State<FindViewPage> createState() => _FindViewPageState();
}

class _FindViewPageState extends State<FindViewPage> {
  final _crmService = VenusCRMService();
  final _session = CrmSession();

  final _valueCtrl = TextEditingController();
  final _date1Ctrl = TextEditingController();
  final _date2Ctrl = TextEditingController();

  bool _isLoading = false;
  String _viewType = 'Lead';
  String _searchBy = 'All';
  List<Map<String, String>> _results = [];
  List<String> _columns = [];

  static const _viewTypes = ['Lead', 'Contact', 'Potential', 'Activity'];

  Map<String, List<String>> get _searchOptions => {
    'Lead': ['All', 'Name', 'Company', 'Source', 'LOB'],
    'Contact': ['All', 'Name', 'Account', 'LOB'],
    'Potential': ['All', 'Name', 'Account'],
    'Activity': ['All', 'Lead', 'Account', 'Contact', 'Potential', 'Sales'],
  };

  @override
  void initState() {
    super.initState();
    _initDates();
  }

  void _initDates() {
    final now = DateTime.now();
    _date1Ctrl.text = "${now.month}/${now.day}/${now.year}";
    _date2Ctrl.text = "${now.month}/${now.day}/${now.year}";
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    _date1Ctrl.dispose();
    _date2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(
        () => ctrl.text = "${picked.month}/${picked.day}/${picked.year}",
      );
    }
  }

  Future<void> _findData() async {
    setState(() {
      _isLoading = true;
      _results = [];
      _columns = [];
    });
    try {
      await _session.load();
      final bus = _session.busCode;
      final auth = _session.userAuth;
      final val = _valueCtrl.text.trim();

      String d1 = _viewType == 'Activity' ? _date1Ctrl.text : "-";
      String d2 = _viewType == 'Activity' && _searchBy != 'All'
          ? _date2Ctrl.text
          : "-";

      dynamic data;
      int colCount = 0;

      switch (_viewType) {
        case 'Lead':
          data = await _crmService.getDataLead(
            bus,
            auth,
            _searchBy,
            val,
            d1,
            d2,
          );
          colCount = 21;
          break;
        case 'Contact':
          data = await _crmService.getDataContact(
            bus,
            auth,
            _searchBy,
            val,
            d1,
            d2,
          );
          colCount = 16;
          break;
        case 'Potential':
          data = await _crmService.getDataPotential(
            bus,
            auth,
            _searchBy,
            val,
            d1,
            d2,
          );
          colCount = 17;
          break;
        case 'Activity':
          data = await _crmService.getDataActivity(
            bus,
            auth,
            _searchBy,
            val,
            d1,
            d2,
          );
          colCount = 13;
          break;
      }

      if (mounted && data != null) {
        final Map<String, String?> prefs = {};
        final json = data.toJson();
        for (int i = 1; i <= colCount; i++) {
          prefs['Pref$i'] = json['Pref$i']?.toString();
        }

        setState(() {
          _results = PipeDataParser.parseRows(prefs, colCount);
          _updateColumns();
        });

        if (_results.isEmpty) {
          showCrmSnackBar(context, "Data not found", isError: true);
        }
      } else if (mounted) {
        setState(() {
          _results = [];
          _columns = [];
        });
        showCrmSnackBar(context, "Data not found", isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _columns = [];
        });
        showCrmSnackBar(context, "Error: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateColumns() {
    switch (_viewType) {
      case 'Lead':
        _columns = ['ID', 'Customer', 'Company', 'LOB', 'Status'];
        break;
      case 'Contact':
        _columns = ['ID', 'Name', 'Account', 'Phone', 'Email'];
        break;
      case 'Potential':
        _columns = ['ID', 'Name', 'Account', 'Stage', 'Amount'];
        break;
      case 'Activity':
        _columns = ['ID', 'Type', 'Subject', 'Date', 'Status'];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isActivity = _viewType == 'Activity';
    bool showDate1 = isActivity;
    bool showDate2 = isActivity && _searchBy != 'All';

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
                title: "Filtering",
                icon: Icons.filter_alt_outlined,
                children: [
                  CrmDropdownField(
                    label: "View",
                    items: _viewTypes
                        .map((e) => DropdownOption(code: e, name: e))
                        .toList(),
                    value: _viewType,
                    onChanged: (v) => setState(() {
                      _viewType = v!;
                      _searchBy = 'All';
                      _results = [];
                    }),
                  ),
                  CrmDropdownField(
                    label: "Search By",
                    items: (_searchOptions[_viewType] ?? ['All'])
                        .map((e) => DropdownOption(code: e, name: e))
                        .toList(),
                    value: _searchBy,
                    onChanged: (v) => setState(() => _searchBy = v!),
                  ),
                  CrmTextField(
                    label: "Value",
                    icon: Icons.search,
                    controller: _valueCtrl,
                  ),

                  if (showDate1)
                    CrmTextField(
                      label: "Date 1",
                      icon: Icons.calendar_today,
                      controller: _date1Ctrl,
                      readOnly: true,
                      onTap: () => _selectDate(_date1Ctrl),
                    ),

                  if (showDate2)
                    CrmTextField(
                      label: "Date 2",
                      icon: Icons.calendar_today,
                      controller: _date2Ctrl,
                      readOnly: true,
                      onTap: () => _selectDate(_date2Ctrl),
                    ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _findData,
                      icon: const Icon(Icons.manage_search),
                      label: const Text(
                        "Find Data",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E4CCB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Results (${_results.length})",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _results.isEmpty ? _buildEmptyResult() : _buildResultsTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    final Map<String, List<int>> displayMap = {
      'Lead': [1, 3, 4, 5, 13],
      'Contact': [1, 3, 4, 8, 11],
      'Potential': [1, 4, 3, 6, 9],
      'Activity': [1, 2, 5, 6, 7],
    };
    final indices = displayMap[_viewType] ?? [1];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _columns
              .map(
                (c) => DataColumn(
                  label: Text(
                    c,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
          rows: _results
              .map(
                (row) => DataRow(
                  onSelectChanged: (selected) {
                    if (selected ?? false) {
                      _selectResult(row);
                    }
                  },
                  cells: indices
                      .map((i) => DataCell(Text(row['Pref$i'] ?? '-')))
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _pref(Map<String, String> row, int index) => row['Pref$index'] ?? '';

  bool _boolPref(Map<String, String> row, int index) {
    final value = _pref(row, index).trim().toLowerCase();
    return value == '1' || value == 'true' || value == 'yes';
  }

  void _selectResult(Map<String, String> row) {
    switch (_viewType) {
      case 'Lead':
        widget.onLeadSelected(
          LeadEditData(
            leadId: _pref(row, 1),
            busName: _pref(row, 2),
            sales: _pref(row, 7),
            company: _pref(row, 4),
            lob: _pref(row, 5),
            leadSource: _pref(row, 6),
            customer: _pref(row, 3),
            phone: _pref(row, 8),
            mobile: _pref(row, 9),
            fax: _pref(row, 10),
            email: _pref(row, 11),
            website: _pref(row, 12),
            leadStatus: _pref(row, 13),
            noOfEmployees: _pref(row, 14),
            address: _pref(row, 15),
            city: _pref(row, 16),
            state: _pref(row, 17),
            zipCode: _pref(row, 18),
            region: _pref(row, 19),
            description: _pref(row, 20),
            isSuspend: _boolPref(row, 21),
          ),
        );
        break;
      case 'Contact':
        widget.onContactSelected(
          ContactEditData(
            contactId: _pref(row, 1),
            busName: _pref(row, 2),
            account: _pref(row, 4),
            sales: _pref(row, 7),
            name: _pref(row, 3),
            phone: _pref(row, 8),
            mobile: _pref(row, 9),
            fax: _pref(row, 10),
            email: _pref(row, 11),
            homePhone: _pref(row, 12),
            website: _pref(row, 13),
            birthDay: _pref(row, 14),
            assistant: _pref(row, 15),
            assistantPhone: _pref(row, 16),
            leadSource: _pref(row, 6),
            position: _pref(row, 5),
            description: '',
            isSuspend: false,
          ),
        );
        break;
      case 'Potential':
        widget.onPotentialSelected(
          PotentialEditData(
            potentialId: _pref(row, 1),
            businessName: _pref(row, 2),
            accountName: _pref(row, 3),
            name: _pref(row, 4),
            closingDate: _pref(row, 5),
            stageDisplay: _pref(row, 6),
            finishDisplay: _pref(row, 7),
            ownerName: _pref(row, 8),
            amount: _pref(row, 9),
            methodName: _pref(row, 10),
            location: _pref(row, 11),
            leadSource: _pref(row, 12),
            description: _pref(row, 13),
            isSuspend: _boolPref(row, 14),
            accountCode: _pref(row, 15),
            contactRecords: _pref(row, 16),
            stageRecords: _pref(row, 17),
          ),
        );
        break;
      case 'Activity':
        widget.onActivitySelected(
          ActivityEditData(
            taskId: _pref(row, 1),
            type: _pref(row, 2),
            linkedName: _pref(row, 3),
            linkedSubName: _pref(row, 4),
            subject: _pref(row, 5),
            date: _pref(row, 6),
            status: _pref(row, 7),
            priority: _pref(row, 8),
            description: _pref(row, 9),
            businessName: _pref(row, 10),
            sales: _pref(row, 11),
            activityTypeName: _pref(row, 12),
            coordinate: _pref(row, 13),
          ),
        );
        break;
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.manage_search_rounded,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Find & View",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Advanced Filtering System",
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

  Widget _buildEmptyResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No data found",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
