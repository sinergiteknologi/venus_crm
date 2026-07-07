import 'package:flutter/material.dart';
import '../../../../dao/venus_crm_service.dart';
import '../../../../shared/utils/pref_manager.dart';
import '../../../../shared/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _version = 'v1.0.0';
  final _crmService = VenusCRMService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    
    _checkLoginStatus();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    try {
      final versi = await _crmService.getVersi();
      if (versi?.versi != null && mounted) {
        setState(() => _version = 'v${versi!.versi}');
      }
    } catch (_) {}
  }

  Future<void> _checkLoginStatus() async {
    // Memberikan waktu splash screen tampil (misal 2 detik)
    await Future.delayed(const Duration(seconds: 2));
    
    bool loggedIn = await PrefManager.isLoggedIn();
    
    if (mounted) {
      if (loggedIn) {
        // Jika sudah login, navigasi ke Dashboard (HomeWithDrawer)
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Jika belum login, navigasi ke Login Page
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E4CCB),
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(
                size: 80,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Venus CRM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _version,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
