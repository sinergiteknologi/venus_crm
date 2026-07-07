import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/utils/crm_session.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _session = CrmSession();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _session.load();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E4CCB)));
    }

    final login = _session.login;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: AppLogo(size: 96, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          Text(_session.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(_session.salesName, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          _infoCard("Business", _session.busName),
          _infoCard("Business Code", _session.busCode),
          _infoCard("Sales Code", _session.salesCode),
          _infoCard("User Authority", login?.pref8 ?? '-'),
          _infoCard("Business Authority", login?.pref7 ?? '-'),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
