import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; 
import '../structure/firebase_service.dart'; 
import '../structure/user_model.dart';
import 'chat_screen.dart';
import 'worker_profile_screen.dart'; 


class SearchScreen extends StatefulWidget {
  final User currentUser;
  final String? initialQuery;

  const SearchScreen({super.key, required this.currentUser, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  String searchQuery = "";
  bool sortByRating = false;
  bool filterByLocation = true; 
  List<User> _allWorkers = []; 
  bool _isLoading = true;

  final FirestoreService _firestoreService = FirestoreService(); 

  static const Color tealAccent = Color(0xFF18BAA4);
  static const Color textDark = Color(0xFF1E293B);
  static const Color bgScaffold = Color(0xFFF8FAFC);
  static const Color grayField = Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    searchQuery = widget.initialQuery ?? "";
    _searchController = TextEditingController(text: searchQuery);
    _loadWorkers(); 
  }

  Future<void> _loadWorkers() async {
    await Future.delayed(const Duration(milliseconds: 1000)); 
    final workers = await _firestoreService.getAllWorkers(); 
    
    if (mounted) {
      setState(() {
        _allWorkers = workers;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<User> filteredUsers = _allWorkers.where((worker) {
      final matchesSearch = (worker.service ?? "").toLowerCase().contains(searchQuery.toLowerCase()) ||
                            (worker.name).toLowerCase().contains(searchQuery.toLowerCase());
      
      bool matchesLocation = true;
      if (filterByLocation) {
        matchesLocation = worker.location == widget.currentUser.location;
      }

      return matchesSearch && matchesLocation;
    }).toList();

    if (sortByRating) {
      filteredUsers.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
    }

    return Scaffold(
      backgroundColor: bgScaffold,
      appBar: AppBar(
        title: const Text("البحث عن محترفين", style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.location_on_rounded, color: filterByLocation ? tealAccent : Colors.grey.shade400, size: 24),
            onPressed: () {
              setState(() => filterByLocation = !filterByLocation);
              _showLocationToast();
            },
            tooltip: "عرض العمال القريبين فقط",
          ),
          IconButton(
            icon: Icon(Icons.sort_rounded, color: sortByRating ? tealAccent : Colors.grey.shade400, size: 24),
            onPressed: () => setState(() => sortByRating = !sortByRating),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          if (filterByLocation)
            Container(
              width: double.infinity,
              color: tealAccent.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.my_location_rounded, color: tealAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "عرض النتائج في: ${widget.currentUser.location}",
                    style: const TextStyle(fontSize: 13, color: tealAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "ابحث عن خدمة (سباكة، نجارة...)",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded, color: Colors.grey), onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = "");
                        })
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading 
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 4, 
                    itemBuilder: (context, index) => _buildShimmerEffect(),
                  )
                : filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) => _buildWorkerCard(filteredUsers[index]),
                      ),
          ),
        ],
      ),
    );
  }


  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(width: 55, height: 55, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
                      const SizedBox(height: 10),
                      Container(width: 80, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
                    ],
                  ),
                ),
                Container(width: 50, height: 25, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: Container(height: 45, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
                const SizedBox(width: 10),
                Expanded(child: Container(height: 45, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showLocationToast() {
    final msg = filterByLocation ? "تم حصر البحث في منطقتك" : "عرض العمال من كافة المناطق";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1), backgroundColor: textDark),
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
            child: Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          Text(
            filterByLocation 
              ? "لا يوجد عمال في ${widget.currentUser.location} حالياً" 
              : "لا توجد نتائج تطابق بحثك",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (filterByLocation) ...[
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: () => setState(() => filterByLocation = false),
              icon: const Icon(Icons.travel_explore_rounded, color: tealAccent, size: 18),
              label: const Text("البحث في كافة المحافظات", style: TextStyle(color: tealAccent, fontWeight: FontWeight.bold)),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildWorkerCard(User worker) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkerProfileScreen(currentUser: widget.currentUser, worker: worker),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: tealAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      worker.name.isNotEmpty ? worker.name[0].toUpperCase() : "?",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: tealAccent, fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(worker.location.split(' ')[0], style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    worker.service ?? "عام",
                    style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text("${worker.rating ?? 0.0}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                  ],
                ),
                Row(
                  children: [
                    Text("JD/ساعة ", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    Text("${worker.price ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: tealAccent)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(currentUser: widget.currentUser, otherUser: worker),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: textDark),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: () => _bookTask(worker),
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: const Text("اطلب الآن", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: tealAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookTask(User worker) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: tealAccent,
              onPrimary: Colors.white,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: tealAccent),
          ),
          child: child!,
        );
      },
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم إرسال طلبك لـ ${worker.name} بنجاح!"), backgroundColor: const Color(0xFF10B981)),
        );
      }
    }
    }
}