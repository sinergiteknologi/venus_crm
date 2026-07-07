import 'package:flutter/material.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../envelopes/post_lead_envelope.dart';
import '../../../../shared/models/dropdown_option.dart';
import '../../../../shared/utils/crm_session.dart';
import '../../../../shared/utils/pipe_data_parser.dart';
import '../../../../shared/widgets/crm_form_widgets.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class LeadEditData {
  final String leadId;
  final String busName;
  final String sales;
  final String company;
  final String lob;
  final String leadSource;
  final String customer;
  final String phone;
  final String mobile;
  final String email;
  final String website;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String region;
  final String description;
  final bool isSuspend;

  const LeadEditData({
    required this.leadId,
    required this.busName,
    required this.sales,
    required this.company,
    required this.lob,
    required this.leadSource,
    required this.customer,
    required this.phone,
    required this.mobile,
    required this.email,
    required this.website,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.region,
    required this.description,
    required this.isSuspend,
  });
}

class LeadPage extends StatefulWidget {
  final LeadEditData? editData;
  final VoidCallback? onBack;

  const LeadPage({super.key, this.editData, this.onBack});

  @override
  State<LeadPage> createState() => _LeadPageState();
}

class _LeadPageState extends State<LeadPage> {
  final _crmService = VenusCRMService();
  final _session = CrmSession();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSuspend = false;
  bool _masterDataReady = false;

  String? _busCode;
  String? _ownerUser;
  String? _lobCode;
  String? _leadSourceCode;
  String? _leadStatusCode;
  String _leadId = '';

  List<DropdownOption> _businesses = [];
  List<DropdownOption> _allSales = [];
  List<DropdownOption> _sales = [];
  List<DropdownOption> _lobs = [];
  List<DropdownOption> _leadSources = [];
  List<DropdownOption> _leadStatuses = [];

  final _companyCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _faxCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _noEmpCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _leadId = widget.editData?.leadId ?? '';
    _isSuspend = widget.editData?.isSuspend ?? false;
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    setState(() => _isLoading = true);
    try {
      await _session.load();
      _busCode = _session.busCode;

      final bus = _busCode ?? '';

      final businessResult = await _crmService.getBusiness(bus);
      final lobResult = await _crmService.getLOB(bus);
      final leadSourceResult = await _crmService.getLeadSource(bus);
      final leadStatusResult = await _crmService.getLeadStatus(bus);

      if (mounted) {
        setState(() {
          _businesses = PipeDataParser.parseCodeName(
            businessResult?.code,
            businessResult?.name,
          );
          _lobs = PipeDataParser.withEmptyOption(
            PipeDataParser.parseCodeName(lobResult?.code, lobResult?.name),
          );
          _leadSources = PipeDataParser.withEmptyOption(
            PipeDataParser.parseCodeName(
              leadSourceResult?.code,
              leadSourceResult?.name,
            ),
          );
          _leadStatuses = PipeDataParser.withEmptyOption(
            PipeDataParser.parseCodeName(
              leadStatusResult?.code,
              leadStatusResult?.name,
            ),
          );

          if (_busCode == null && _businesses.isNotEmpty) {
            _busCode = _businesses.first.code;
          }
        });
      }

      await _loadSalesForBusiness(setDefaultOwner: widget.editData == null);

      if (mounted && widget.editData != null) {
        _applyEditData(widget.editData!);
      }
    } catch (e) {
      if (mounted) {
        showCrmSnackBar(context, 'Failed to load data: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _masterDataReady = true;
        });
      }
    }
  }

  Future<void> _loadSalesForBusiness({bool setDefaultOwner = false}) async {
    if (_busCode == null || _busCode!.isEmpty) return;

    final salesResult = await _crmService.getSales(_busCode!, _session.userAuth);
    final owners = PipeDataParser.parseSalesOwners(
      salesResult?.pref1,
      salesResult?.pref2,
      salesResult?.pref3,
    );

    if (!mounted) return;

    setState(() {
      _allSales = owners;
      _sales = owners;
      if (setDefaultOwner) {
        _setDefaultOwner(owners);
      } else if (_ownerUser != null &&
          !owners.any((owner) => owner.code == _ownerUser)) {
        _ownerUser = null;
      }
    });
  }

  void _setDefaultOwner(List<DropdownOption> owners) {
    if (_session.salesName.isNotEmpty) {
      for (final owner in owners) {
        if (owner.name == _session.salesName) {
          _ownerUser = owner.code;
          return;
        }
      }
    }
    if (_session.username.isNotEmpty) {
      for (final owner in owners) {
        if (owner.code == _session.username) {
          _ownerUser = owner.code;
          return;
        }
      }
    }
    if (owners.isNotEmpty) _ownerUser = owners.first.code;
  }

  Future<List<DropdownOption>> _searchOwners(String query) async {
    final lower = query.trim().toLowerCase();
    final filtered = lower.isEmpty
        ? _allSales
        : _allSales
            .where((owner) => owner.name.toLowerCase().contains(lower))
            .take(5)
            .toList();

    if (mounted) setState(() => _sales = filtered);
    return filtered;
  }

  String? _codeByName(List<DropdownOption> items, String name) {
    for (final item in items) {
      if (item.name == name) return item.code;
    }
    return null;
  }

  void _applyEditData(LeadEditData data) {
    setState(() {
      _leadId = data.leadId;
      _busCode = _codeByName(_businesses, data.busName) ?? _busCode;
      _lobCode = _codeByName(_lobs, data.lob);
      _leadSourceCode = _codeByName(_leadSources, data.leadSource);
      _ownerUser = _codeByName(_allSales, data.sales);
      _companyCtrl.text = data.company;
      _customerCtrl.text = data.customer;
      _phoneCtrl.text = data.phone;
      _mobileCtrl.text = data.mobile;
      _emailCtrl.text = data.email;
      _websiteCtrl.text = data.website;
      _addressCtrl.text = data.address;
      _cityCtrl.text = data.city;
      _stateCtrl.text = data.state;
      _zipCtrl.text = data.zipCode;
      _regionCtrl.text = data.region;
      _descCtrl.text = data.description;
      _isSuspend = data.isSuspend;
    });
  }

  bool _validationSave() {
    if (_busCode == null || _busCode!.isEmpty) {
      showCrmSnackBar(
        context,
        'Business field is blank, please fill the Business field',
        isError: true,
      );
      return false;
    }
    if (_ownerUser == null || _ownerUser!.isEmpty) {
      showCrmSnackBar(
        context,
        'Owner field is blank, please fill the Owner field',
        isError: true,
      );
      return false;
    }
    if (_customerCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'Customer field is blank, please fill the Name field',
        isError: true,
      );
      return false;
    }
    if (_companyCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'Company field is blank, please fill the Name field',
        isError: true,
      );
      return false;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'Address field is blank, please fill the Name field',
        isError: true,
      );
      return false;
    }
    if (_cityCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'City field is blank, please fill the Name field',
        isError: true,
      );
      return false;
    }
    if (_zipCtrl.text.trim().length != 5) {
      showCrmSnackBar(context, 'Invalid zipCode.', isError: true);
      return false;
    }
    if (_stateCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'State field is blank, please fill the Name field',
        isError: true,
      );
      return false;
    }
    if (_leadSourceCode == null || _leadSourceCode!.isEmpty) {
      showCrmSnackBar(
        context,
        'Load source is blank, please fill the Owner field',
        isError: true,
      );
      return false;
    }
    final validOwner = _allSales.any((owner) => owner.code == _ownerUser);
    if (!validOwner) {
      showCrmSnackBar(
        context,
        'Invalid Owner, please fill the Owner field with a right data.',
        isError: true,
      );
      return false;
    }
    return true;
  }

  Future<void> _saveLead() async {
    FocusScope.of(context).unfocus();
    if (!_validationSave()) return;

    setState(() => _isLoading = true);
    try {
      final envelope = PostLeadEnvelope(
        prmBusCode: _busCode!,
        prmLeadName: _customerCtrl.text.trim(),
        prmCompany: _companyCtrl.text.trim(),
        prmEmail: _emailCtrl.text.trim(),
        prmPhone: _phoneCtrl.text.trim(),
        prmFax: _faxCtrl.text.trim(),
        prmMobilePhone: _mobileCtrl.text.trim(),
        prmWebsite: _websiteCtrl.text.trim(),
        prmLeadSourceCode: _leadSourceCode ?? '',
        prmLeadStatusCode: _leadStatusCode ?? '',
        prmLOBCode: _lobCode ?? '',
        prmNoofEmp: _noEmpCtrl.text.trim(),
        prmAddress: _addressCtrl.text.trim(),
        prmCity: _cityCtrl.text.trim(),
        prmState: _stateCtrl.text.trim(),
        prmZIPCode: _zipCtrl.text.trim(),
        prmCountry: _regionCtrl.text.trim(),
        prmLeadOwner: _ownerUser!,
        prmDescription: _descCtrl.text.trim(),
        prmIsSuspend: _isSuspend ? '1' : '0',
        prmUser: _session.username,
        prmLeadID: _leadId,
      );

      final result = await _crmService.postLead(envelope);
      if (mounted) {
        if (result?.status == true) {
          showCrmSnackBar(context, 'Data Successfully Added');
          widget.onBack?.call();
        } else {
          showCrmSnackBar(context, 'Failed to save the data', isError: true);
        }
      }
    } catch (e) {
      if (mounted) showCrmSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _customerCtrl.dispose();
    _phoneCtrl.dispose();
    _mobileCtrl.dispose();
    _faxCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _noEmpCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _regionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                    title: "Lead Information",
                    icon: Icons.info_outline_rounded,
                    children: [
                      CrmDropdownField(
                        label: "Business",
                        items: _businesses,
                        value: _busCode,
                        onChanged: (v) async {
                          setState(() {
                            _busCode = v;
                            _ownerUser = null;
                          });
                          await _loadSalesForBusiness(setDefaultOwner: true);
                        },
                      ),
                      CrmDropdownField(
                        label: "Lead Source",
                        items: _leadSources,
                        value: _leadSourceCode,
                        onChanged: (v) => setState(() => _leadSourceCode = v),
                        enabled: _masterDataReady,
                      ),
                      CrmDropdownField(
                        label: "Lead Status",
                        items: _leadStatuses,
                        value: _leadStatusCode,
                        onChanged: (v) => setState(() => _leadStatusCode = v),
                        enabled: _masterDataReady,
                      ),
                      CrmDropdownField(
                        label: "LOB",
                        items: _lobs,
                        value: _lobCode,
                        onChanged: (v) => setState(() => _lobCode = v),
                        enabled: _masterDataReady,
                      ),
                      CrmDropdownField(
                        label: "Owner",
                        items: _sales,
                        value: _ownerUser,
                        onChanged: (v) => setState(() => _ownerUser = v),
                        onSearch: _searchOwners,
                        enabled: _busCode != null,
                      ),
                      CrmTextField(
                        label: "Customer Name",
                        icon: Icons.person_outline_rounded,
                        controller: _customerCtrl,
                      ),
                      CrmTextField(
                        label: "Company",
                        icon: Icons.business_rounded,
                        controller: _companyCtrl,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CrmTextField(
                              label: "Phone",
                              icon: Icons.phone_outlined,
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CrmTextField(
                              label: "Mobile",
                              icon: Icons.smartphone_rounded,
                              controller: _mobileCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CrmTextField(
                              label: "Fax",
                              icon: Icons.fax_outlined,
                              controller: _faxCtrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CrmTextField(
                              label: "No of Employee",
                              icon: Icons.people_outline,
                              controller: _noEmpCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      CrmTextField(
                        label: "Email",
                        icon: Icons.email_outlined,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      CrmTextField(
                        label: "Website",
                        icon: Icons.language_rounded,
                        controller: _websiteCtrl,
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: "Location Details",
                    icon: Icons.location_on_outlined,
                    children: [
                      CrmTextField(
                        label: "Address",
                        icon: Icons.map_outlined,
                        controller: _addressCtrl,
                        maxLines: 2,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CrmTextField(
                              label: "City",
                              icon: Icons.location_city_rounded,
                              controller: _cityCtrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CrmTextField(
                              label: "State",
                              icon: Icons.flag_outlined,
                              controller: _stateCtrl,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CrmTextField(
                              label: "ZIP Code",
                              icon: Icons.pin_drop_outlined,
                              controller: _zipCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CrmTextField(
                              label: "Country / Region",
                              icon: Icons.public_rounded,
                              controller: _regionCtrl,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: "Additional Info",
                    icon: Icons.note_add_outlined,
                    children: [
                      CrmTextField(
                        label: "Description",
                        icon: Icons.description_outlined,
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
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
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
            color: const Color(0xFF1E4CCB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person_add_alt_1, color: Color(0xFF1E4CCB)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Edit Lead" : "Create New Lead",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              isEdit ? "Update lead details below" : "Fill in the details below",
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          flex: 2,
          child: ElevatedButton(
            onPressed: _saveLead,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E4CCB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text(
              "Save Lead",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
