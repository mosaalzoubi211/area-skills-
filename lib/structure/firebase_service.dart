import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart'; 


class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // دالة إنشاء الحساب
  Future<User?> signUpUser(User user, String password) async {
    try {
      final String safeEmail = user.email.toLowerCase().trim();

      firebase_auth.UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: safeEmail,
        password: password,
      );

      if (credential.user != null) {

        await credential.user!.sendEmailVerification();

        Map<String, dynamic> userData = user.toMap();
        userData.remove('password');
        userData['email'] = safeEmail;

        await _firestore.collection('users').doc(safeEmail).set(userData);
        return user;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message); 
    }
    return null;
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      final String safeEmail = email.toLowerCase().trim();
      await _auth.signInWithEmailAndPassword(email: safeEmail, password: password);
      
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(safeEmail).get();

      if (userDoc.exists) {
        return User.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        throw Exception("بيانات المستخدم غير موجودة!");
      }
    } on firebase_auth.FirebaseAuthException {
      throw Exception("تأكد من البريد الإلكتروني وكلمة المرور");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload(); 
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }
}


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> getUser(String email) async {
    final doc = await _db.collection('users').doc(email).get();
    if (doc.exists) return User.fromMap(doc.data() as Map<String, dynamic>);
    return null;
  }

  Future<void> updateUser(User user) async {
    await _db.collection('users').doc(user.email).update(user.toMap());
  }

  Future<List<User>> getAllWorkers() async {
    final snapshot = await _db.collection('users').where('role', isEqualTo: 'worker').get();
    return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }

  Future<List<User>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }


  Future<void> createTask(String clientEmail, String workerEmail, String serviceName, String date, {String? description, int isPublic = 0}) async {
    await _db.collection('tasks').add({
      'clientEmail': clientEmail,
      'workerEmail': workerEmail,
      'serviceName': serviceName,
      'date': date,
      'status': 'pending',
      'isPublic': isPublic,
      'description': description ?? "",
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  Stream<List<Map<String, dynamic>>> getClientTasksStream(String clientEmail) {
    return _db.collection('tasks')
        .where('clientEmail', isEqualTo: clientEmail)
        .orderBy('timestamp', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; 
        return data;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getWorkerTasksStream(String workerEmail, {String? service}) {
    return _db.collection('tasks').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        var data = doc.data();
        return data['workerEmail'] == workerEmail || (data['isPublic'] == 1 && data['serviceName'] == service);
      }).map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<Map<String, int>> getWorkerTaskCounts(String workerEmail) async {
    final snapshot = await _db.collection('tasks').where('workerEmail', isEqualTo: workerEmail).get();
    int pending = 0, accepted = 0, completed = 0;
    for (var doc in snapshot.docs) {
      var status = doc.data()['status'];
      if (status == 'pending') {
        pending++;
      } else if (status == 'accepted') accepted++;
      else if (status == 'completed') completed++;
    }
    return {'pending': pending, 'accepted': accepted, 'completed': completed};
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    await _db.collection('tasks').doc(taskId).update({'status': status});
  }

  Future<void> completeAndRateTask(String taskId, String workerEmail, double newRating, String comment, String clientName) async {
    try {
      WriteBatch batch = _db.batch();

      batch.update(_db.collection('tasks').doc(taskId), {'status': 'completed'});
      

      batch.update(_db.collection('users').doc(workerEmail), {'rating': newRating});


      if (comment.isNotEmpty) {
        DocumentReference reviewRef = _db.collection('users').doc(workerEmail).collection('reviews').doc();
        
        batch.set(reviewRef, {
          'clientName': clientName,
          'rating': newRating,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print("Error completing task: $e");
      throw Exception("حدث خطأ أثناء حفظ التقييم");
    }
  }

  String _getChatRoomId(String u1, String u2) {
    List<String> ids = [u1, u2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> sendMessage(ChatMessage message) async {
    String roomId = _getChatRoomId(message.senderEmail, message.receiverEmail);
    var msgData = message.toMap();
    msgData['isRead'] = false;
    msgData['timestamp'] = FieldValue.serverTimestamp();

    await _db.collection('chats').doc(roomId).collection('messages').add(msgData);
  }

  Stream<List<ChatMessage>> getChatMessagesStream(String user1, String user2) {
    String roomId = _getChatRoomId(user1, user2);
    return _db.collection('chats').doc(roomId).collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList();
    });
  }

  Future<int> getUnreadCount(String currentUserEmail, String senderEmail) async {
    String roomId = _getChatRoomId(currentUserEmail, senderEmail);
    var snapshot = await _db.collection('chats').doc(roomId).collection('messages')
        .where('receiverEmail', isEqualTo: currentUserEmail)
        .where('isRead', isEqualTo: false).get();
    return snapshot.docs.length;
  }

  Future<void> markMessagesAsRead(String currentUserEmail, String senderEmail) async {
    String roomId = _getChatRoomId(currentUserEmail, senderEmail);
    var snapshot = await _db.collection('chats').doc(roomId).collection('messages')
        .where('receiverEmail', isEqualTo: currentUserEmail)
        .where('isRead', isEqualTo: false).get();
        
    WriteBatch batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}