import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../shared/report_form_screen.dart';
import 'map_dashboard.dart';
import 'reports_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Admin Dashboard'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Live Map',
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MapDashboard())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ReportFormScreen())),
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text('New Report',
          style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dashCard(
              context,
              icon: Icons.list_alt,
              label: 'View All Reports',
              subtitle: 'Assign volunteers to incidents',
              color: Colors.teal,
              onTap: () => Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) => const ReportsListScreen())),
            ),
            const SizedBox(height: 16),
            _dashCard(
              context,
              icon: Icons.map_outlined,
              label: 'Live Incident Map',
              subtitle: 'See all reports on map',
              color: Colors.blue,
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MapDashboard())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
              style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
            Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ]),
      ),
    );
  }
}