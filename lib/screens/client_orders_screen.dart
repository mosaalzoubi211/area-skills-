import 'package:flutter/material.dart';
import '../structure/firebase_service.dart'; 
import '../structure/user_model.dart';

class ClientOrdersScreen extends StatefulWidget {
  final User currentUser;
  const ClientOrdersScreen({super.key, required this.currentUser});

  @override
  State<ClientOrdersScreen> createState() => _ClientOrdersScreenState();
}

class _ClientOrdersScreenState extends State<ClientOrdersScreen> {
  final FirestoreService _firestoreService = FirestoreService(); 

  // 🎨 ألوان الثيم العصري
  static const Color tealAccent = Color(0xFF18BAA4);
  static const Color textDark = Color(0xFF1E293B);
  static const Color bgScaffold = Color(0xFFF8FAFC);
  static const Color grayField = Color(0xFFF1F5F9);

  // 🟢 نافذة الدفع بالستايل النظيف
  void _showPaymentSheet(BuildContext parentContext, Map<String, dynamic> order) {
    final double amount = 20.0; 
    final double commission = amount * 0.10;
    final double total = amount + commission;

    showModalBottomSheet(
      context: parentContext, 
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            
            const Text("الدفع الآمن لإتمام المهمة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 15),
            

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: grayField, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _buildSummaryRow("قيمة الخدمة", "$amount JD"),
                  const Divider(color: Colors.white, thickness: 2, height: 20),
                  _buildSummaryRow("رسوم التطبيق (10%)", "$commission JD"),
                  const Divider(color: Colors.white, thickness: 2, height: 20),
                  _buildSummaryRow("المجموع الكلي", "$total JD", isBold: true, valueColor: tealAccent),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            _buildPaymentField("رقم البطاقة", Icons.credit_card_rounded),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildPaymentField("MM/YY", Icons.calendar_month_rounded)),
                const SizedBox(width: 15),
                Expanded(child: _buildPaymentField("CVV", Icons.lock_outline_rounded)),
              ],
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tealAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (parentContext.mounted) {
                      _showProcessingDialog(parentContext, order);
                    }
                  });
                },
                child: Text("دفع $total JD وتأكيد الإتمام", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentField(String hint, IconData icon) {
    return TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: grayField,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  void _showProcessingDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: tealAccent)),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); 
      _showRatingDialog(context, order['id'], order['workerEmail']); 
    });
  }

  void _showRatingDialog(BuildContext context, String taskId, String workerEmail) {
    double selectedRating = 5.0;
    final TextEditingController commentController = TextEditingController(); 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Column(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 50),
              SizedBox(height: 10),
              Text("تم الدفع بنجاح!", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
              SizedBox(height: 5),
              Text("كيف كانت تجربتك مع المحترف؟", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(index < selectedRating ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 36),
                    onPressed: () => setState(() => selectedRating = index + 1.0),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                textAlign: TextAlign.right,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "اكتب رأيك في الخدمة (اختياري)...",
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: grayField,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tealAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(context); 
                  await _completeAndRateTaskInDB(taskId, workerEmail, selectedRating, commentController.text.trim());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("شكراً لتقييمك!"), backgroundColor: Color(0xFF10B981)));
                  }
                },
                child: const Text("إرسال وإنهاء", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: isBold ? textDark : Colors.grey.shade600, fontSize: isBold ? 15 : 13)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: valueColor ?? textDark, fontSize: isBold ? 16 : 14)),
      ],
    );
  }

  Future<void> _completeAndRateTaskInDB(String taskId, String workerEmail, double newRating, String comment) async {
    await _firestoreService.completeAndRateTask(taskId, workerEmail, newRating, comment, widget.currentUser.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgScaffold,
      appBar: AppBar(
        title: const Text("طلباتي", style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        centerTitle: false,
        iconTheme: const IconThemeData(color: textDark),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getClientTasksStream(widget.currentUser.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: tealAccent));
          }
          final myOrders = snapshot.data ?? [];
          
          if (myOrders.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: myOrders.length,
            itemBuilder: (context, index) {
              final order = myOrders[index];
              return _buildOrderCard(context, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
            child: Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          Text("لم تقم بإرسال أي طلبات بعد", style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("مع المحترف:", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(order['workerEmail'] ?? "محترف غير معروف", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                  ],
                ),
              ),
              _buildStatusBadge(order['status']),
            ],
          ),
          
          const SizedBox(height: 15),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
          const SizedBox(height: 10),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: tealAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.handyman_rounded, color: tealAccent, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("الخدمة المطلوبة", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  Text(order['serviceName'] ?? "غير محدد", style: const TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 14)),
                ],
              ),
            ],
          ),
          
          if (order['status'] == 'accepted') ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentSheet(context, order), 
                icon: const Icon(Icons.payments_rounded, size: 18),
                label: const Text("الدفع وإنهاء الطلب", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tealAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],

          if (order['status'] == 'completed')
            Container(
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 5),
                  Text("تم الدفع وإكمال المهمة بنجاح", style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'accepted':
        bgColor = const Color(0xFF10B981).withOpacity(0.1);
        textColor = const Color(0xFF10B981); // أخضر منعش
        text = "مقبول";
        break;
      case 'rejected':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = "مرفوض";
        break;
      case 'completed':
        bgColor = tealAccent.withOpacity(0.1);
        textColor = tealAccent;
        text = "مكتمل";
        break;
      default:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        text = "قيد الانتظار";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}