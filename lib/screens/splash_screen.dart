import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'admin/admin_dashboard.dart';
import 'volunteer/volunteer_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    final userData = await AuthService().getUserData(user.uid);
    if (!mounted) return;
    if (userData?.role == 'admin') {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()));
    } else {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const VolunteerDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.hub_rounded,
                size: 52, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('JeevanSetu',
              style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.bold,
                color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 6),
            Text('Smart Resource Allocator',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8))),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}