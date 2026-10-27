import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:web/web.dart' as web;
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
  String? _error;
  bool _updateRequired = false;
  bool _isChecking = true;
  final _crmService = VenusCRMService();
  int? _requiredBuild;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _initialize();
  }

  Future<void> _initialize() async {
    if (mounted) {
      setState(() {
        _error = null;
        _updateRequired = false;
        _isChecking = true;
      });
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final localBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      final remote = await _crmService.getVersi();
      if (remote == null || !remote.isValid) {
        throw const FormatException('Invalid version response');
      }

      if (!mounted) return;
      setState(() => _version = 'v${remote.versionName}');

      if (remote.isMandatory && remote.versionCode! > localBuild) {
        setState(() {
          _updateRequired = true;
          _requiredBuild = remote.versionCode;
          _isChecking = false;
        });
        return;
      }

      await Future<void>.delayed(const Duration(seconds: 1));
      final loggedIn = await PrefManager.isLoggedIn();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(loggedIn ? '/home' : '/login');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to connect to Venus CRM. Check your connection.';
        _isChecking = false;
      });
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
              const SizedBox(height: 48),
              if (_isChecking)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                )
              else
                Container(
                  width: 360,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _updateRequired ? Icons.system_update_alt_rounded : Icons.cloud_off_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _updateRequired
                            ? 'A new version is required to continue.'
                            : _error ?? 'Unable to continue.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _updateRequired
                            ? () {
                                final uri = Uri.base.replace(
                                  queryParameters: {
                                    ...Uri.base.queryParameters,
                                    'build': '${_requiredBuild ?? DateTime.now().millisecondsSinceEpoch}',
                                  },
                                );
                                web.window.location.replace(uri.toString());
                              }
                            : _initialize,
                        icon: Icon(_updateRequired ? Icons.refresh_rounded : Icons.sync_rounded),
                        label: Text(_updateRequired ? 'Update Now' : 'Try Again'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E4CCB),
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
}
