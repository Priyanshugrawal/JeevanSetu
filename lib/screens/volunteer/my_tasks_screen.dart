import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  Color _priorityColor(String p) {
    if (p == 'HIGH') return Colors.red;
    if (p == 'MEDIUM') return Colors.orange;
    return Colors.green;
  }

  Future<void> _markComplete(String taskId, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(taskId)
        .update({'status': 'completed'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task marked as completed!')));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('volunteerId', isEqualTo: uid)
            .snapshots(),
        builder: (context, AsyncSnapshot snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                    size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No tasks assigned yet',
                    style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          final tasks = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tasks.length,
            itemBuilder: (context, i) {
              final t = tasks[i].data() as Map<String, dynamic>;
              final priority = t['priority'] as String? ?? 'LOW';
              final completed = t['status'] == 'completed';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t['problemType'] ?? 'Task',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: completed
                                ? Colors.teal.shade50
                                : _priorityColor(priority).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              completed ? 'Completed' : priority,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: completed
                                  ? Colors.teal.shade700
                                  : _priorityColor(priority)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(t['description'] ?? '',
                        style: const TextStyle(
                          fontSize: 13, color: Colors.grey)),
                      if (t['location'] != null) ...[
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(t['location'],
                            style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                        ]),
                      ],
                      if (!completed) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                              _markComplete(tasks[i].id, context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Mark as Complete'),
                          ),
                        ),
                      ],
                    ],
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