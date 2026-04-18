import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../volunteer/volunteer_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _auth      = AuthService();

  String _role = 'volunteer';
  bool _loading = false;
  List<String> _selectedSkills = [];

  final List<String> _allSkills = [
    'Doctor', 'Nurse', 'Driver', 'Teacher',
    'Engineer', 'Cook', 'Translator', 'Counselor',
  ];

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
      _showSnack('Please fill all fields');
      return;
    }
    setState(() => _loading = true);

    String? error = await _auth.register(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      phone:    _phoneCtrl.text.trim(),
      role:     _role,
      skills:   _selectedSkills,
    );

    if (error != null) {
      _showSnack('Registration failed');
      setState(() => _loading = false);
      return;
    }

    if (!mounted) return;
    if (_role == 'admin') {
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
        (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const VolunteerDashboard()),
        (route) => false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.teal.shade50,
      ),
      backgroundColor: Colors.teal.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(_nameCtrl, 'Full name', Icons.person_outline),
            const SizedBox(height: 12),
            _buildField(_emailCtrl, 'Email', Icons.email_outlined,
              type: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildField(_passCtrl, 'Password', Icons.lock_outline,
              obscure: true),
            const SizedBox(height: 12),
            _buildField(_phoneCtrl, 'Phone number', Icons.phone_outlined,
              type: TextInputType.phone),
            const SizedBox(height: 20),
            Text('I am registering as:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                color: Colors.teal.shade800)),
            const SizedBox(height: 10),
            Row(children: [
              _roleCard('volunteer', 'Volunteer',
                Icons.volunteer_activism_outlined),
              const SizedBox(width: 12),
              _roleCard('admin', 'NGO Admin',
                Icons.admin_panel_settings_outlined),
            ]),
            if (_role == 'volunteer') ...[
              const SizedBox(height: 20),
              Text('My skills (select all that apply):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                  color: Colors.teal.shade800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _allSkills.map((skill) {
                  final selected = _selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: selected,
                    onSelected: (v) => setState(() {
                      if (v) _selectedSkills.add(skill);
                      else _selectedSkills.remove(skill);
                    }),
                    selectedColor: Colors.teal.shade100,
                    checkmarkColor: Colors.teal.shade800,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Account',
                      style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, IconData icon,
    {TextInputType type = TextInputType.text, bool obscure = false}) {
    return TextField(
      controller: c,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _roleCard(String value, String label, IconData icon) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? Colors.teal.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.teal.shade600 : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(children: [
            Icon(icon, size: 32,
              color: selected ? Colors.teal.shade700 : Colors.grey),
            const SizedBox(height: 6),
            Text(label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: selected
                  ? Colors.teal.shade800
                  : Colors.grey.shade600,
              )),
          ]),
        ),
      ),
    );
  }
}