import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../shared/utils/crm_session.dart';
import '../../../../shared/utils/pref_manager.dart';
import '../../../../shared/widgets/crm_form_widgets.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _crmService = VenusCRMService();
  final _session = CrmSession();
  final _formKey = GlobalKey<FormState>();
  
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _session.load();
      
      // Java Concept: Validation against stored password
      final prefs = await SharedPreferences.getInstance();
      // Note: Assuming password was stored in 'user_pwd' during login to match Java logic
      final storedPwd = prefs.getString('user_pwd') ?? '';

      if (_currentPwdCtrl.text != storedPwd) {
        if (mounted) showCrmSnackBar(context, 'Invalid old Password', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      if (_newPwdCtrl.text != _confirmPwdCtrl.text) {
        if (mounted) showCrmSnackBar(context, 'Invalid New Password', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      final result = await _crmService.uploadNewPassword(
        _session.username,
        _newPwdCtrl.text.trim(),
      );

      if (mounted) {
        if (result?.status == true) {
          showCrmSnackBar(context, 'Data successfully saved');
          
          // Java Logic: After save success, redirect to Login
          await PrefManager.clear(); // Clear session
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        } else {
          showCrmSnackBar(context, 'Failed to save data', isError: true);
        }
      }
    } catch (e) {
      if (mounted) showCrmSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    // Field 1: Old Password (Java: txtPwd)
                    TextFormField(
                      controller: _currentPwdCtrl,
                      obscureText: _obscureCurrent,
                      decoration: InputDecoration(
                        labelText: "Current Password",
                        prefixIcon: const Icon(Icons.lock_open_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please fill the blank field' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Field 2: New Password (Java: txtNewPwd)
                    TextFormField(
                      controller: _newPwdCtrl,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please fill the blank field' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Field 3: Confirm New Password (Java: txtRetype)
                    TextFormField(
                      controller: _confirmPwdCtrl,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: "Confirm New Password",
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please fill the blank field' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E4CCB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: const Text("Update Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
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
          decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.security_rounded, color: Colors.amber),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Change Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Update your account security", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
