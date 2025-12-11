import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:fitmate/screens/body_measurements_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppDataService _appData = AppDataService();

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    await _appData.loadBodyMeasurements(); // Ensure we have latest
    await _appData.loadUserMetrics();
    if (mounted) setState(() {});
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
            _buildSettingsOption(
                icon: Icons.notifications_outlined, title: 'Notifications'),
            _buildSettingsOption(
                icon: Icons.lock_outline, title: 'Privacy & Security'),
            _buildSettingsOption(
                icon: Icons.help_outline, title: 'Help & Support'),
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

  Widget _buildSettingsOption({required IconData icon, required String title}) {
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
        onTap: () {},
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
