import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../structure/user_model.dart';
import 'chat_screen.dart';
import '../structure/utils.dart';
import '../structure/firebase_service.dart';

class WorkerProfileScreen extends StatefulWidget {
  final User currentUser;
  final User worker;

  const WorkerProfileScreen({super.key, required this.currentUser, required this.worker});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("الملف الشخصي", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildContactAndActionSection(context),
            const SizedBox(height: 20),
            const Divider(thickness: 5, color: Color(0xFFF1F5F9)),
            _buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blue.shade50,
          backgroundImage: getImageProvider(widget.worker.profileImage),
          child: (widget.worker.profileImage == null || widget.worker.profileImage!.isEmpty)
              ? Text(
                  widget.worker.name.isNotEmpty ? widget.worker.name[0].toUpperCase() : "?",
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                )
              : null,
        ),
        const SizedBox(height: 15),
        Text(
          widget.worker.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3E50)),
        ),
        const SizedBox(height: 5),
        Text(
          widget.worker.service ?? "خدمة عامة",
          style: const TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 5),
            Text(
              "${widget.worker.rating ?? 5.0}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactAndActionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (widget.worker.phone != null && widget.worker.phone!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    widget.worker.phone!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _bookTask(context, widget.worker),
                  icon: const Icon(Icons.calendar_today, size: 20),
                  label: const Text("طلب الخدمة الآن", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatScreen(currentUser: widget.currentUser, otherUser: widget.worker)),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.blueAccent),
                  iconSize: 28,
                  tooltip: "مراسلة",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "آراء العملاء",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3E50)),
          ),
          const SizedBox(height: 15),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.worker.email)
                .collection('reviews')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(Icons.rate_review_outlined, size: 50, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text("لا توجد تعليقات حتى الآن", style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                );
              }

              final reviews = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  var reviewData = reviews[index].data() as Map<String, dynamic>;
                  double rating = (reviewData['rating'] ?? 5.0).toDouble();
                  String comment = reviewData['comment'] ?? "";
                  String clientName = reviewData['clientName'] ?? "عميل Area Skills";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                        if (comment.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(comment, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                        ]
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _bookTask(BuildContext context, User worker) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedDate != null && pickedTime != null) {
      final fullDateTime = DateTime(
        pickedDate.year, pickedDate.month, pickedDate.day,
        pickedTime.hour, pickedTime.minute,
      );

      await _firestoreService.createTask(
        widget.currentUser.email,
        worker.email,
        worker.service ?? "خدمة عامة",
        fullDateTime.toIso8601String(),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم إرسال طلبك لـ ${worker.name} بنجاح!"), backgroundColor: Colors.green),
        );
      }
    }
    }
}