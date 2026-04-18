import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../shared/report_form_screen.dart';
import 'my_tasks_screen.dart';

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Dashboard'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
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
        label: const Text('Report Problem',
          style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) => const MyTasksScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.15),
                    child: const Icon(Icons.assignment,
                      color: Colors.purple),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Tasks',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                      Text('View your assigned tasks',
                        style: TextStyle(
                          fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}