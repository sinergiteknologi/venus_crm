import 'package:flutter/material.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../envelopes/post_contact_envelope.dart';
import '../../../../shared/models/dropdown_option.dart';
import '../../../../shared/utils/crm_session.dart';
import '../../../../shared/utils/pipe_data_parser.dart';
import '../../../../shared/widgets/crm_form_widgets.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class ContactEditData {
  final String contactId;
  final String busName;
  final String account;
  final String sales;
  final String name;
  final String phone;
  final String mobile;
  final String fax;
  final String email;
  final String birthDay;
  final String assistant;
  final String leadSource;
  final String position;
  final String description;
  final bool isSuspend;

  const ContactEditData({
    required this.contactId,
    required this.busName,
    required this.account,
    required this.sales,
    required this.name,
    required this.phone,
    required this.mobile,
    required this.fax,
    required this.email,
    required this.birthDay,
    required this.assistant,
    required this.leadSource,
    required this.position,
    required this.description,
    required this.isSuspend,
  });
}

class ContactPage extends StatefulWidget {
  final ContactEditData? editData;
  final VoidCallback? onBack;

  const ContactPage({super.key, this.editData, this.onBack});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _crmService = VenusCRMService();
  final _session = CrmSession();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSuspend = false;
  bool _masterDataReady = false;

  String? _busCode;
  String? _ownerUser;
  String? _leadSourceCode;
  String? _accountCode;
  String _contactId = '';

  List<DropdownOption> _businesses = [];
  List<DropdownOption> _allSales = [];
  List<DropdownOption> _sales = [];
  List<DropdownOption> _leadSources = [];
  List<DropdownOption> _accounts = [];

  final _picNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _faxCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _homeCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _assistantCtrl = TextEditingController();
  final _assistantPhoneCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contactId = widget.editData?.contactId ?? '';
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
      final leadSourceResult = await _crmService.getLeadSource(bus);

      if (mounted) {
        setState(() {
          _businesses = PipeDataParser.parseCodeName(
            businessResult?.code,
            businessResult?.name,
          );
          _leadSources = PipeDataParser.withEmptyOption(
            PipeDataParser.parseCodeName(
              leadSourceResult?.code,
              leadSourceResult?.name,
            ),
          );

          if (_busCode == null && _businesses.isNotEmpty) {
            _busCode = _businesses.first.code;
          }
        });
      }

      await _loadSalesForBusiness(setDefaultOwner: widget.editData == null);

      if (mounted && widget.editData != null) {
        await _applyEditData(widget.editData!);
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

  Future<List<DropdownOption>> _searchAccounts(String query) async {
    if (_busCode == null) return [];
    final result = await _crmService.getAccount(
      _busCode!,
      _session.userAuth,
      query,
      'CONTACT',
    );
    final accounts = PipeDataParser.parseCodeName(result?.code, result?.name);
    if (mounted) setState(() => _accounts = accounts);
    return accounts;
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

  Future<void> _applyEditData(ContactEditData data) async {
    await _searchAccounts(data.account);

    if (!mounted) return;

    setState(() {
      _contactId = data.contactId;
      _busCode = _codeByName(_businesses, data.busName) ?? _busCode;
      _accountCode = _codeByName(_accounts, data.account);
      _ownerUser = _codeByName(_allSales, data.sales);
      _leadSourceCode = _codeByName(_leadSources, data.leadSource);
      _picNameCtrl.text = data.name;
      _phoneCtrl.text = data.phone;
      _mobileCtrl.text = data.mobile;
      _faxCtrl.text = data.fax;
      _emailCtrl.text = data.email;
      _dobCtrl.text = data.birthDay;
      _assistantCtrl.text = data.assistant;
      _positionCtrl.text = data.position;
      _descCtrl.text = data.description;
      _isSuspend = data.isSuspend;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
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
    if (_accountCode == null || _accountCode!.isEmpty) {
      showCrmSnackBar(
        context,
        'Account field is blank, please fill the Account field',
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
    if (_picNameCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'PIC name field is blank, please fill the Name field',
        isError: true,
      );
      return false;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'Phone field is blank, please fill the Name field',
        isError: true,
      );
      return false;
    }
    if (_mobileCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'Mobile field is blank, please fill the Name field',
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
    if (_positionCtrl.text.trim().isEmpty) {
      showCrmSnackBar(
        context,
        'Position is blank, please fill the Name field',
        isError: true,
      );
      return false;
    }

    final validAccount = _accounts.any((account) => account.code == _accountCode);
    if (!validAccount) {
      showCrmSnackBar(
        context,
        'Invalid Account, please fill the Account field with a right data.',
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

  Future<void> _saveContact() async {
    FocusScope.of(context).unfocus();
    if (!_validationSave()) return;

    setState(() => _isLoading = true);
    try {
      final envelope = PostContactEnvelope(
        prmBusCode: _busCode!,
        prmContactID: _contactId,
        prmAccountCode: _accountCode!,
        prmContactName: _picNameCtrl.text.trim(),
        prmPositionCode: _positionCtrl.text.trim(),
        prmOwner: _ownerUser!,
        prmEmail: _emailCtrl.text.trim(),
        prmPhone: _phoneCtrl.text.trim(),
        prmMobile: _mobileCtrl.text.trim(),
        prmDivision: _homeCtrl.text.trim(),
        prmEmailAlt: _faxCtrl.text.trim(),
        prmBirthDay: _dobCtrl.text.trim(),
        prmReligion: _assistantCtrl.text.trim(),
        prmLeadSourceCode: _leadSourceCode ?? '',
        prmDescription: _descCtrl.text.trim(),
        prmIsSuspend: _isSuspend ? '1' : '0',
        prmUser: _session.username,
      );

      final result = await _crmService.postContact(envelope);
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
    _picNameCtrl.dispose();
    _phoneCtrl.dispose();
    _mobileCtrl.dispose();
    _faxCtrl.dispose();
    _emailCtrl.dispose();
    _homeCtrl.dispose();
    _websiteCtrl.dispose();
    _dobCtrl.dispose();
    _assistantCtrl.dispose();
    _assistantPhoneCtrl.dispose();
    _positionCtrl.dispose();
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
                    title: "Contact Information",
                    icon: Icons.contact_mail_outlined,
                    children: [
                      CrmDropdownField(
                        label: "Business",
                        items: _businesses,
                        value: _busCode,
                        onChanged: (v) async {
                          setState(() {
                            _busCode = v;
                            _accountCode = null;
                            _accounts = [];
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
                        label: "Account",
                        items: _accounts,
                        value: _accountCode,
                        onChanged: (v) => setState(() => _accountCode = v),
                        onSearch: _searchAccounts,
                        enabled: _busCode != null,
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
                        label: "PIC Name",
                        icon: Icons.person_pin_outlined,
                        controller: _picNameCtrl,
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
                              label: "Email",
                              icon: Icons.email_outlined,
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      CrmTextField(
                        label: "Home",
                        icon: Icons.home_outlined,
                        controller: _homeCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      CrmTextField(
                        label: "Website",
                        icon: Icons.language_rounded,
                        controller: _websiteCtrl,
                        keyboardType: TextInputType.url,
                      ),
                      CrmTextField(
                        label: "Birth Day",
                        icon: Icons.calendar_today_outlined,
                        controller: _dobCtrl,
                        readOnly: true,
                        onTap: _selectDate,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CrmTextField(
                              label: "Assistant",
                              icon: Icons.support_agent,
                              controller: _assistantCtrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CrmTextField(
                              label: "Assistant Phone",
                              icon: Icons.phone_callback,
                              controller: _assistantPhoneCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      CrmTextField(
                        label: "Position",
                        icon: Icons.work_outline,
                        controller: _positionCtrl,
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
                        onChanged: (v) => setState(() => _isSuspend = v),
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
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.contact_page, color: Colors.orange),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Edit Contact" : "Create New Contact",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              isEdit ? "Update contact details below" : "Manage your relationship",
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            onPressed: _saveContact,
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
              "Save Contact",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
