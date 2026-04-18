import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'assign_volunteer_screen.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  Color _priorityColor(String p) {
    if (p == 'HIGH') return Colors.red;
    if (p == 'MEDIUM') return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text('No reports yet',
                style: TextStyle(color: Colors.grey)));
          }
          final docs = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final priority = data['priority'] as String? ?? 'LOW';
              final assigned = data['assignedTo'] != null;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _priorityColor(priority).withOpacity(0.15),
                    child: Icon(Icons.report_problem,
                      color: _priorityColor(priority), size: 20),
                  ),
                  title: Text(data['problemType'] ?? 'Report',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((data['description']?.toString().length ?? 0) > 60
                        ? '${data['description'].toString().substring(0, 60)}...'
                        : data['description'] ?? '',
                        style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _priorityColor(priority).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(priority,
                            style: TextStyle(
                              fontSize: 11,
                              color: _priorityColor(priority),
                              fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        if (assigned)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Assigned',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold)),
                          ),
                      ]),
                    ],
                  ),
                  trailing: assigned
                    ? const Icon(Icons.check_circle,
                        color: Colors.teal, size: 20)
                    : ElevatedButton(
                        onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                            AssignVolunteerScreen(
                              reportId: docs[i].id,
                              reportData: data,
                            ))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Assign'),
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}