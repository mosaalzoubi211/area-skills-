import 'package:flutter/material.dart';
import '../structure/firebase_service.dart'; 
import '../structure/user_model.dart';
import 'chat_screen.dart';
import '../structure/utils.dart';

class MessagesListScreen extends StatefulWidget {
  final User currentUser;
  const MessagesListScreen({super.key, required this.currentUser});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final FirestoreService _firestoreService = FirestoreService(); 
  String _searchQuery = ""; 
  
  static const Color tealAccent = Color(0xFF18BAA4);
  static const Color textDark = Color(0xFF1E293B);
  static const Color bgScaffold = Color(0xFFF8FAFC);
  static const Color grayField = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgScaffold,
      appBar: AppBar(
        title: const Text(
          "المحادثات",
          style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 22),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                textAlign: TextAlign.right,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "ابحث في المحادثات...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _firestoreService.getAllUsers(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: tealAccent));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final otherUsers = snapshot.data!
                    .where((u) => u.email != widget.currentUser.email)
                    .where((u) => u.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                if (otherUsers.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: otherUsers.length,
                  itemBuilder: (context, index) {
                    final user = otherUsers[index];
                    return _buildChatCard(context, user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, User user) {
    return FutureBuilder<int>(
      future: _firestoreService.getUnreadCount(widget.currentUser.email, user.email), 
      builder: (context, snapshot) {
        int unreadCount = snapshot.data ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: tealAccent.withOpacity(0.1),
                  backgroundImage: getImageProvider(user.profileImage),
                  child: (user.profileImage == null || user.profileImage!.isEmpty)
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tealAccent,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textDark,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                children: [
                  Icon(
                    user.role == 'worker' ? Icons.handyman_rounded : Icons.person_rounded,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.role == 'worker' ? "عامل: ${user.service}" : "عميل",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            trailing: unreadCount > 0 
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: tealAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
              
            onTap: () async {
              await _firestoreService.markMessagesAsRead(widget.currentUser.email, user.email); 
              
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(currentUser: widget.currentUser, otherUser: user),
                  ),
                ).then((_) {
                  setState(() {}); 
                });
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty ? "لا توجد نتائج مطابقة لبحثك" : "لا توجد محادثات نشطة حالياً",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}