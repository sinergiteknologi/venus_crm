import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../models/login.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/utils/pref_manager.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  
  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final VenusCRMService _crmService = VenusCRMService();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Login? result = await _crmService.getLogin(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      // Sesuai contoh XML: Login berhasil jika Pref1 tidak kosong
      if (result != null && result.pref1 != null && result.pref1!.isNotEmpty) {
        // Simpan ke SharedPreferences
        await PrefManager.saveLoginData(result);
        
        // Simpan password mentah untuk keperluan validasi Change Password (sesuai legacy logic)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_pwd', _passwordController.text.trim());

        widget.onLoginSuccess();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Username or Password"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo Section
                  Center(
                    child: AppLogo(
                      size: 60,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4CCB).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      "Venus CRM",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E4CCB),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Manage your business smartly",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Username Field
                  const Text(
                    "Username",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _usernameController,
                    hint: "Enter your username",
                    icon: Icons.person_outline,
                    validator: (value) => value == null || value.isEmpty ? "Please enter username" : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // Password Field
                  const Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hint: "Enter your password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    validator: (value) => value == null || value.isEmpty ? "Please enter password" : null,
                    onTogglePassword: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E4CCB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF1E4CCB).withValues(alpha: 0.4),
                      ),
                      child: _isLoading 
                        ? const Text(
                            "Processing...",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        : const Text(
                            "Sign In",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "v1.0.0",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1E4CCB), width: 1.5),
        ),
      ),
    );
  }
}
