import 'package:flutter/material.dart';
import '../structure/firebase_service.dart';
import '../structure/user_model.dart';

class WorkerTasksScreen extends StatefulWidget {
  final User worker;
  const WorkerTasksScreen({super.key, required this.worker});

  @override
  State<WorkerTasksScreen> createState() => _WorkerTasksScreenState();
}

class _WorkerTasksScreenState extends State<WorkerTasksScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // 🟢
   
  Future<void> _updateStatus(String taskId, String newStatus) async {
    try {
      await _firestoreService.updateTaskStatus(taskId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم تحديث حالة الطلب إلى: $newStatus")),
        );
      }
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        title: const Text("مهامي والطلبات", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getWorkerTasksStream(widget.worker.email, service: widget.worker.service),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ في تحميل البيانات: ${snapshot.error}"));
          }

          final myTasks = snapshot.data ?? [];

          if (myTasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("لا يوجد طلبات حالياً", style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: myTasks.length,
            itemBuilder: (context, index) {
              final task = myTasks[index];
              final bool isPublic = task['isPublic'] == 1; 
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(task['clientEmail'] ?? "زبون مجهول",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Row(
                            children: [
                              if (isPublic) _buildPublicBadge(), 
                              const SizedBox(width: 5),
                              _buildStatusBadge(task['status']),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("الخدمة المطلوبة: ${task['serviceName']}", 
                        style: const TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.bold)),
                      
                      if (task['description'] != null && task['description'].toString().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade100)
                          ),
                          child: Text("التفاصيل: ${task['description']}", 
                            style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        ),
                      ],
                      
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(task['date'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Divider(height: 30),
                      
                      if (task['status'] == 'pending')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus(task['id'], 'accepted'), // 🟢
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text("قبول الطلب"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green, 
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _updateStatus(task['id'], 'rejected'), // 🟢
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text("رفض"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'accepted': color = Colors.green; text = "مقبول"; break;
      case 'rejected': color = Colors.red; text = "مرفوض"; break;
      case 'completed': color = Colors.blue; text = "مكتمل"; break;
      default: color = Colors.orange; text = "قيد الانتظار";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(10)
      ),
      child: Text(text, 
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPublicBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.3))
      ),
      child: const Text("طلب عام", 
        style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}