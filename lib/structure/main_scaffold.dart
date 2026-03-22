import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../structure/user_provider.dart'; 
import '../structure/user_model.dart';
import '../structure/firebase_service.dart'; 
import '../screens/settings_screen.dart';
import '../screens/search_screen.dart';
import '../screens/worker_tasks_screen.dart';
import '../screens/messages_list_screen.dart';
import '../screens/client_home_content.dart'; 

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  bool _loading = true;
  String? selectedServiceFilter;

  int pendingCount = 0;
  int activeCount = 0;
  int completedCount = 0;

  final FirestoreService _firestoreService = FirestoreService();

  static const Color tealAccent = Color(0xFF18BAA4);
  static const Color textDark = Color(0xFF1E293B);
  static const Color bgScaffold = Color(0xFFF8FAFC);
  static const Color grayField = Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkerStats();
    });
  }

  Future<void> _loadWorkerStats() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    
    if (user != null && user.role == 'worker') {
      final counts = await _firestoreService.getWorkerTaskCounts(user.email); 
      if (mounted) {
        setState(() {
          pendingCount = counts['pending'] ?? 0;
          activeCount = counts['accepted'] ?? 0;
          completedCount = counts['completed'] ?? 0;
          _loading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showAddPublicOrderSheet() {
    String selectedCategory = "سباكة";
    final TextEditingController detailsController = TextEditingController();
    final currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 25, top: 15, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text("نشر طلب صيانة عام", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
              const SizedBox(height: 5),
              Text("سيصل طلبك لجميع العمال المتوفرين لتقديم عروضهم", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(color: grayField, borderRadius: BorderRadius.circular(15)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                    value: selectedCategory,
                    items: ["سباكة", "كهرباء", "نجارة", "دهان", "تنظيف", "تكييف"].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                    onChanged: (val) => setModalState(() => selectedCategory = val!),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              
              Container(
                decoration: BoxDecoration(color: grayField, borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "اشرح المشكلة باختصار...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              
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
                    if (detailsController.text.isEmpty || currentUser == null) return;
                    
                    await _firestoreService.createTask(
                      currentUser.email, "", selectedCategory, DateTime.now().toString().split(' ')[0],
                      description: detailsController.text, isPublic: 1,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم نشر طلبك بنجاح!"), backgroundColor: Colors.green));
                    }
                  },
                  child: const Text("نشر الطلب الآن", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;

    if (_loading || currentUser == null) {
      return const Scaffold(backgroundColor: bgScaffold, body: Center(child: CircularProgressIndicator(color: tealAccent)));
    }

    final List<Widget> pages = [
      _buildDynamicHome(currentUser), 
      currentUser.role == 'worker'
          ? WorkerTasksScreen(worker: currentUser)
          : SearchScreen(currentUser: currentUser, initialQuery: selectedServiceFilter),
      MessagesListScreen(currentUser: currentUser),
      const SettingsScreen(), 
    ];

    return Scaffold(
      backgroundColor: bgScaffold,
      appBar: (_selectedIndex == 0 && currentUser.role == 'worker') ? _buildAppBar(currentUser) : null, 
      body: IndexedStack(index: _selectedIndex, children: pages),
      
      floatingActionButton: (currentUser.role == 'client' && _selectedIndex == 0)
          ? FloatingActionButton.extended(
              onPressed: _showAddPublicOrderSheet,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              label: const Text("طلب سريع", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              icon: const Icon(Icons.bolt_rounded),
              backgroundColor: tealAccent,
            )
          : null,
          
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: tealAccent,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: [
            const BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_rounded)), label: "الرئيسية"),
            BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.only(bottom: 4), child: Icon(currentUser.role == 'worker' ? Icons.assignment_rounded : Icons.search_rounded)),
              label: currentUser.role == 'worker' ? "مهامي" : "بحث",
            ),
            const BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.chat_bubble_rounded)), label: "الرسائل"),
            const BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_rounded)), label: "حسابي"),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicHome(User currentUser) {
    if (currentUser.role == 'worker') {
      return _buildWorkerHome();
    } else {
      return ClientHomeContent(
        currentUser: currentUser,
        onServiceSelected: (service) {
          setState(() {
            selectedServiceFilter = service;
            _selectedIndex = 1;
          });
        },
      );
    }
  }

  PreferredSizeWidget _buildAppBar(User currentUser) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("مرحباً بك،", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          Text(currentUser.name, style: const TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: textDark, size: 22)),
        ),
      ],
    );
  }


  Widget _buildWorkerHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ملخص الأداء", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("معلقة", pendingCount.toString(), Colors.orange),
                _buildStatItem("نشطة", activeCount.toString(), Colors.blue),
                _buildStatItem("مكتملة", completedCount.toString(), tealAccent),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text("نشاطك الأخير", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 15),
          Center(child: Text("لا يوجد نشاطات لعرضها حالياً", style: TextStyle(color: Colors.grey.shade400, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }
}