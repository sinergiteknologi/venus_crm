import 'package:flutter/material.dart';
import 'features/lead/presentation/pages/lead_page.dart';
import 'features/contact/presentation/pages/contact_page.dart';
import 'features/potential/presentation/pages/potential_page.dart';
import 'features/activity/presentation/pages/activity_page.dart';
import 'features/find_view/presentation/pages/find_view_page.dart';
import 'features/calendar/presentation/pages/calendar_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/change_password_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'shared/widgets/app_logo.dart';
import 'shared/utils/pref_manager.dart';
import 'shared/utils/crm_session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Venus CRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E4CCB),
          primary: const Color(0xFF1E4CCB),
          surface: const Color(0xFFF8FAFF),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E4CCB),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginPage(
          onLoginSuccess: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
        '/home': (context) => HomeWithDrawer(
          onLogout: () => Navigator.of(context).pushReplacementNamed('/login'),
        ),
      },
    );
  }
}

enum DrawerMenuKey {
  profile,
  lead,
  contact,
  potential,
  activity,
  findView,
  calendarActivity,
  changePassword,
}

class HomeWithDrawer extends StatefulWidget {
  final VoidCallback onLogout;
  const HomeWithDrawer({super.key, required this.onLogout});

  @override
  State<HomeWithDrawer> createState() => _HomeWithDrawerState();
}

class _HomeWithDrawerState extends State<HomeWithDrawer> {
  DrawerMenuKey _selected = DrawerMenuKey.lead;
  final _session = CrmSession();
  String _userName = 'Venus User';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    await _session.load();
    if (mounted) {
      setState(() {
        _userName = _session.salesName.isNotEmpty ? _session.salesName : _session.username;
        _userEmail = _session.username.isNotEmpty ? _session.username : 'user@venus-crm.com';
      });
    }
  }

  String get _title {
    switch (_selected) {
      case DrawerMenuKey.profile: return 'My Profile';
      case DrawerMenuKey.lead: return 'Leads';
      case DrawerMenuKey.contact: return 'Contacts';
      case DrawerMenuKey.potential: return 'Potentials';
      case DrawerMenuKey.activity: return 'Activities';
      case DrawerMenuKey.findView: return 'Find View';
      case DrawerMenuKey.calendarActivity: return 'Calendar';
      case DrawerMenuKey.changePassword: return 'Settings';
    }
  }

  IconData _getIcon(DrawerMenuKey key) {
    switch (key) {
      case DrawerMenuKey.profile: return Icons.person_outline;
      case DrawerMenuKey.lead: return Icons.person_add_alt_1_outlined;
      case DrawerMenuKey.contact: return Icons.contact_page_outlined;
      case DrawerMenuKey.potential: return Icons.star_outline;
      case DrawerMenuKey.activity: return Icons.local_activity_outlined;
      case DrawerMenuKey.findView: return Icons.search_rounded;
      case DrawerMenuKey.calendarActivity: return Icons.calendar_month_outlined;
      case DrawerMenuKey.changePassword: return Icons.lock_outline;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PrefManager.clear();
              widget.onLogout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1E4CCB),
                borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: AppLogo(size: 56, fit: BoxFit.cover),
                ),
              ),
              accountName: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(_userEmail),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const SizedBox(height: 10),
                  _buildDrawerTile('Profile', DrawerMenuKey.profile),
                  const Divider(height: 20, thickness: 0.5),
                  _buildDrawerTile('Lead', DrawerMenuKey.lead, badge: '+'),
                  _buildDrawerTile('Contact', DrawerMenuKey.contact),
                  _buildDrawerTile('Potential', DrawerMenuKey.potential),
                  _buildDrawerTile('Activity', DrawerMenuKey.activity),
                  const Divider(height: 20, thickness: 0.5),
                  _buildDrawerTile('Find View', DrawerMenuKey.findView),
                  _buildDrawerTile('Calendar', DrawerMenuKey.calendarActivity, badge: '+'),
                  _buildDrawerTile('Change Password', DrawerMenuKey.changePassword),
                ],
              ),
            ),
            const Divider(),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildPageContent(),
      ),
    );
  }

  Widget _buildDrawerTile(String title, DrawerMenuKey key, {String? badge}) {
    final isSelected = _selected == key;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isSelected
            ? const Color(0xFF1E4CCB).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(_getIcon(key), color: isSelected ? const Color(0xFF1E4CCB) : Colors.grey[700]),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1E4CCB) : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          trailing: badge != null
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              : null,
          onTap: () => _select(key),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    Widget page;
    switch (_selected) {
      case DrawerMenuKey.profile:
        page = const ProfilePage();
        break;
      case DrawerMenuKey.lead:
        page = LeadPage(
          onBack: () => setState(() => _selected = DrawerMenuKey.findView),
        );
        break;
      case DrawerMenuKey.contact:
        page = ContactPage(
          onBack: () => setState(() => _selected = DrawerMenuKey.findView),
        );
        break;
      case DrawerMenuKey.potential:
        page = const PotentialPage();
        break;
      case DrawerMenuKey.activity:
        page = const ActivityPage();
        break;
      case DrawerMenuKey.findView:
        page = const FindViewPage();
        break;
      case DrawerMenuKey.calendarActivity:
        page = const CalendarActivityPage();
        break;
      case DrawerMenuKey.changePassword:
        page = const ChangePasswordPage();
        break;
    }

    return Container(
      key: ValueKey(_selected),
      child: page,
    );
  }

  void _select(DrawerMenuKey key) {
    setState(() => _selected = key);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
