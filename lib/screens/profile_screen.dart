import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/services/notification_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:fitmate/screens/body_measurements_screen.dart';
import 'package:fitmate/screens/help_support_screen.dart';
import 'package:fitmate/screens/privacy_security_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppDataService _appData = AppDataService();

  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _loadNotificationSettings();
  }

  Future<void> _loadMetrics() async {
    await _appData.loadBodyMeasurements(); // Ensure we have latest
    await _appData.loadUserMetrics();
    if (mounted) setState(() {});
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await NotificationService().areNotificationsEnabled;
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _toggleNotifications(bool value) async {
    await NotificationService().setNotificationsEnabled(value);
    setState(() => _notificationsEnabled = value);
    // Request permission if enabling for the first time on Android 13+ / iOS
    // keeping it simple for now as per minimal viable impl
    if (value) {
      await NotificationService().init();
      // Test check immediately? No, user wants it "if workout scheduled for today"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BODY METRICS',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: primaryColor, size: 20),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const BodyMeasurementsScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<Map<String, String>>(
              valueListenable: _appData.userMetrics,
              builder: (context, metrics, child) {
                return _buildBodyMetrics(metrics);
              },
            ),
            const SizedBox(height: 24),
            // Placeholder for other settings
            const Text(
              'SETTINGS',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildNotificationOption(),
            _buildSettingsOption(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacySecurityScreen()),
              ),
            ),
            _buildSettingsOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen()),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  _appData.clearData();
                  _appData.apiClient.logout();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: const Text('Log Out',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary:
            const Icon(Icons.notifications_outlined, color: primaryColor),
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
        activeColor: primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 2),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: cardBackgroundColor,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _appData.apiClient.username ?? 'User Name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _appData.apiClient.email ?? 'user@example.com',
            style: const TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetrics(Map<String, String> metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _MetricCard(
                    label: 'Height',
                    value: metrics['height'] ?? '-',
                    icon: Icons.height)),
            const SizedBox(width: 16),
            Expanded(
                child: _MetricCard(
                    label: 'Weight',
                    value: metrics['weight'] ?? '-',
                    icon: Icons.monitor_weight_outlined)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _MetricCard(
                    label: 'Body Fat',
                    value: metrics['bodyFat'] ?? '-',
                    icon: Icons.pie_chart_outline)),
            const SizedBox(width: 16),
            Expanded(
                child: _MetricCard(
                    label: 'BMI',
                    value: metrics['bmi'] ?? '-',
                    icon: Icons.calculate_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsOption(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: secondaryTextColor),
        onTap: onTap,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 28),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: secondaryTextColor, fontSize: 14)),
        ],
      ),
    );
  }
}
