import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignVolunteerScreen extends StatefulWidget {
  final String reportId;
  final Map<String, dynamic> reportData;

  const AssignVolunteerScreen({
    super.key,
    required this.reportId,
    required this.reportData,
  });

  @override
  State<AssignVolunteerScreen> createState() =>
      _AssignVolunteerScreenState();
}

class _AssignVolunteerScreenState extends State<AssignVolunteerScreen> {
  String? _selectedVolunteerId;
  String? _selectedVolunteerName;
  bool _assigning = false;

  Future<void> _assign() async {
    if (_selectedVolunteerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a volunteer')));
      return;
    }
    setState(() => _assigning = true);
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(widget.reportId)
        .update({
      'assignedTo': _selectedVolunteerId,
      'assignedToName': _selectedVolunteerName,
      'assignedAt': DateTime.now().toIso8601String(),
      'status': 'assigned',
    });
    await FirebaseFirestore.instance
        .collection('tasks')
        .add({
      'reportId': widget.reportId,
      'volunteerId': _selectedVolunteerId,
      'volunteerName': _selectedVolunteerName,
      'problemType': widget.reportData['problemType'],
      'description': widget.reportData['description'],
      'priority': widget.reportData['priority'],
      'location': widget.reportData['location'],
      'status': 'pending',
      'assignedAt': DateTime.now().toIso8601String(),
    });
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          'Assigned to $_selectedVolunteerName successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final priority = widget.reportData['priority'] as String? ?? 'LOW';
    final neededSkills =
        List<String>.from(widget.reportData['requiredSkills'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Volunteer'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.reportData['problemType'] ?? 'Report',
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(widget.reportData['description'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                if (neededSkills.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: neededSkills.map((s) => Chip(
                      label: Text(s,
                        style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.teal.shade100,
                      padding: EdgeInsets.zero,
                    )).toList(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Select a volunteer:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade800)),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'volunteer')
                  .snapshots(),
              builder: (context, AsyncSnapshot snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final volunteers = snap.data!.docs;
                if (volunteers.isEmpty) {
                  return const Center(
                    child: Text('No volunteers registered yet',
                      style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: volunteers.length,
                  itemBuilder: (context, i) {
                    final v = volunteers[i].data() as Map<String, dynamic>;
                    final vid = volunteers[i].id;
                    final skills = List<String>.from(v['skills'] ?? []);
                    final isSelected = _selectedVolunteerId == vid;
                    final hasMatch = neededSkills.isEmpty ||
                        skills.any((s) => neededSkills.contains(s));
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                            ? Colors.teal.shade400
                            : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => setState(() {
                          _selectedVolunteerId = vid;
                          _selectedVolunteerName = v['name'];
                        }),
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          child: Text(
                            (v['name'] as String? ?? 'V')
                              .substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(children: [
                          Text(v['name'] ?? 'Volunteer'),
                          if (hasMatch) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Skill match',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade800)),
                            ),
                          ],
                        ]),
                        subtitle: Text(skills.isEmpty
                          ? 'No skills listed'
                          : skills.join(', '),
                          style: const TextStyle(fontSize: 12)),
                        trailing: isSelected
                          ? Icon(Icons.check_circle,
                              color: Colors.teal.shade600)
                          : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _assigning ? null : _assign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                ),
                child: _assigning
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm Assignment',
                      style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}