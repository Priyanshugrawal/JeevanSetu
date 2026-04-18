import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_service.dart';
import '../../models/report_model.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});
  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _locationCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _auth   = AuthService();
  final _gemini = GeminiService();

  String _problemType = 'Flood';
  bool _loading = false;
  bool _analyzed = false;

  // Gemini result yahan store hoga
  String _priority = '';
  String _aiReason = '';
  String _suggestedSkills = '';

  final List<String> _problemTypes = [
    'Flood', 'Fire', 'Medical Emergency',
    'Food Shortage', 'Water Issue',
    'Shelter Problem', 'Earthquake',
    'Disease Outbreak', 'Other',
  ];

  Color get _priorityColor {
    switch (_priority) {
      case 'HIGH':   return Colors.red.shade700;
      case 'MEDIUM': return Colors.orange.shade700;
      default:       return Colors.green.shade700;
    }
  }

  Future<void> _analyzeWithGemini() async {
    if (_locationCtrl.text.isEmpty || _descriptionCtrl.text.isEmpty) {
      _showSnack('Location aur description dono bharo');
      return;
    }
    setState(() => _loading = true);

    final result = await _gemini.analyzePriority(
      problemType: _problemType,
      description: _descriptionCtrl.text,
      location:    _locationCtrl.text,
    );

    setState(() {
      _priority        = result['priority'] ?? 'MEDIUM';
      _aiReason        = result['reason'] ?? '';
      _suggestedSkills = result['skills'] ?? '';
      _analyzed        = true;
      _loading         = false;
    });
  }

  Future<void> _submitReport() async {
    if (!_analyzed) {
      _showSnack('Pehle AI Analysis karo');
      return;
    }
    setState(() => _loading = true);

    final user = await _auth.getUserData(_auth.currentUser!.uid);
    final docRef = FirebaseFirestore.instance.collection('reports').doc();

    final report = ReportModel(
      id:              docRef.id,
      submittedBy:     _auth.currentUser!.uid,
      submitterName:   user?.name ?? 'Unknown',
      problemType:     _problemType,
      description:     _descriptionCtrl.text.trim(),
      location:        _locationCtrl.text.trim(),
      priority:        _priority,
      aiReason:        _aiReason,
      suggestedSkills: _suggestedSkills,
      createdAt:       DateTime.now().toIso8601String(),
    );

    await docRef.set(report.toMap());

    if (!mounted) return;
    setState(() => _loading = false);
    _showSnack('Report successfully submit ho gayi!');
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Problem'),
        backgroundColor: Colors.deepOrange.shade50,
      ),
      backgroundColor: Colors.deepOrange.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Problem Type Dropdown
            const Text('Problem Type',
              style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _problemType,
                  isExpanded: true,
                  items: _problemTypes.map((type) =>
                    DropdownMenuItem(value: type, child: Text(type))
                  ).toList(),
                  onChanged: (v) => setState(() {
                    _problemType = v!;
                    _analyzed = false;
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            const Text('Location',
              style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationCtrl,
              onChanged: (_) => setState(() => _analyzed = false),
              decoration: InputDecoration(
                hintText: 'e.g. Raipur, Chhattisgarh',
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text('Describe the Problem',
              style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 4,
              onChanged: (_) => setState(() => _analyzed = false),
              decoration: InputDecoration(
                hintText: 'Poori situation detail mein likho...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Gemini Analyze Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _analyzeWithGemini,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Gemini se Analyze Karo',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            // Loading indicator
            if (_loading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(
                child: Text('Gemini analyze kar raha hai...',
                  style: TextStyle(color: Colors.grey))),
            ],

            // AI Result Card
            if (_analyzed && !_loading) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _priorityColor, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.auto_awesome,
                        color: Colors.deepPurple, size: 18),
                      const SizedBox(width: 6),
                      const Text('Gemini AI Analysis',
                        style: TextStyle(fontWeight: FontWeight.w600,
                          color: Colors.deepPurple)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Text('Priority: ',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _priorityColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_priority,
                          style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text('Reason: $_aiReason',
                      style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    Text('Skills Needed: $_suggestedSkills',
                      style: TextStyle(fontSize: 13,
                        color: Colors.teal.shade700)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Final Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Report Submit Karo',
                    style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}