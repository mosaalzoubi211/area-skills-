import 'package:flutter/material.dart';
import '../structure/user_model.dart';
import 'chat_screen.dart';
import 'client_orders_screen.dart';
import '../structure/firebase_service.dart'; 

class ClientHomeContent extends StatelessWidget {
  final User currentUser;
  final Function(String) onServiceSelected;
  
  final FirestoreService _firestoreService = FirestoreService();

  
  static const Color tealAccent = Color(0xFF18BAA4);
  static const Color textDark = Color(0xFF1E293B);
  static const Color grayField = Color(0xFFF1F5F9);

  ClientHomeContent({
    super.key,
    required this.currentUser,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      physics: const BouncingScrollPhysics(),
      children: [
        
        _buildSearchBar(),
        const SizedBox(height: 25),


        _buildPromoAndStudentButtons(context),
        const SizedBox(height: 25),

 
        _buildMyOrdersButton(context),
        const SizedBox(height: 35),

        
        const Text("ما الخدمة التي تحتاجها؟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 15),
        _buildServicesGrid(),
        const SizedBox(height: 35),

        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("أفضل المحترفين المقترحين", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            TextButton(onPressed: () {}, child: const Text("عرض الكل", style: TextStyle(color: tealAccent, fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 10),
        _buildTopWorkersList(context),
        const SizedBox(height: 30),
      ],
    );
  }

  

  Widget _buildSearchBar() {
    return Container(
      height: 55,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        textAlign: TextAlign.right,
        readOnly: true, 
        onTap: () => onServiceSelected(""), 
        decoration: InputDecoration(
          hintText: "ابحث عن خدمة أو محترف...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }


  Widget _buildPromoAndStudentButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _showTaskDialog(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(color: tealAccent, borderRadius: BorderRadius.circular(16)),
              child: const Column(
                children: [
                  Icon(Icons.school_outlined, color: Colors.white, size: 32),
                  SizedBox(height: 10),
                  Text("عمل جزئي", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        
        Expanded(
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لا توجد خصومات متاحة حالياً!")));
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(color: textDark, borderRadius: BorderRadius.circular(16)),
              child: const Column(
                children: [
                  Icon(Icons.local_offer_outlined, color: Colors.white, size: 32),
                  SizedBox(height: 10),
                  Text("خصم محدود", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTaskDialog(BuildContext context) {
    final dController = TextEditingController();
    final pController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("نشر مهمة للطلاب", textAlign: TextAlign.right, style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("انشر مهام بسيطة (نقل، طباعة، الخ) ليقوم بها الطلاب المتاحون.", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: grayField, borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: dController, 
                textAlign: TextAlign.right, 
                decoration: InputDecoration(
                  hintText: "ماذا تحتاج؟", 
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none, 
                  contentPadding: const EdgeInsets.all(15)
                )
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: grayField, borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: pController, 
                textAlign: TextAlign.right, 
                keyboardType: TextInputType.number, 
                decoration: InputDecoration(
                  hintText: "المبلغ المقترح (JD)", 
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none, 
                  contentPadding: const EdgeInsets.all(15)
                )
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("إلغاء", style: TextStyle(color: Colors.grey.shade600))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tealAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (dController.text.isNotEmpty) {
                await _firestoreService.createTask(
                  currentUser.email, 
                  "public", 
                  "طالب", 
                  DateTime.now().toString().split(' ')[0],
                  description: "${dController.text} - السعر المتوقع: ${pController.text} JD",
                  isPublic: 1,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم نشر طلبك للطلاب بنجاح!"), backgroundColor: Color(0xFF10B981))
                  );
                }
              }
            },
            child: const Text("نشر الآن", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOrdersButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientOrdersScreen(currentUser: currentUser))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: tealAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.receipt_long_rounded, color: tealAccent, size: 20),
            ),
            const SizedBox(width: 15),
            const Text("متابعة حالة طلباتي", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    final List<Map<String, dynamic>> services = [
      {'name': 'سباكة', 'icon': Icons.plumbing_rounded, 'color': Colors.blue},
      {'name': 'كهرباء', 'icon': Icons.electrical_services_rounded, 'color': Colors.orange},
      {'name': 'نجارة', 'icon': Icons.handyman_rounded, 'color': Colors.brown},
      {'name': 'دهان', 'icon': Icons.format_paint_rounded, 'color': Colors.pink},
      {'name': 'تنظيف', 'icon': Icons.cleaning_services_rounded, 'color': Colors.teal},
      {'name': 'تكييف', 'icon': Icons.ac_unit_rounded, 'color': Colors.lightBlue},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 0.95, crossAxisSpacing: 15, mainAxisSpacing: 15),
      itemBuilder: (context, index) {
        final s = services[index];
        return InkWell(
          onTap: () => onServiceSelected(s['name']),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: s['color'].withOpacity(0.1),
                child: Icon(s['icon'], color: s['color'], size: 24),
              ),
              const SizedBox(height: 10),
              Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildTopWorkersList(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _firestoreService.getAllWorkers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: tealAccent));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("لا يوجد عمال مقترحون حالياً", style: TextStyle(color: Colors.grey.shade500)));
        }

        final workers = snapshot.data!.take(4).toList(); 
        
        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(currentUser: currentUser, otherUser: worker))),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CircleAvatar(
                      radius: 30, 
                      backgroundColor: tealAccent.withOpacity(0.1),
                      child: Text(worker.name[0], style: const TextStyle(color: tealAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(worker.service ?? "عام", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}