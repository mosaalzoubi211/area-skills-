class User {
  String name;
  String email;
  String password;
  String role;
  String location;
  String? service;
  double? price;
  String? profileImage;
  double? rating;
  String? phone;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.location,
    this.service,
    this.price,
    this.profileImage,
    this.rating = 0.0,
    this.phone,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'],
      service: map['service'],
      price: (map['price'] as num?)?.toDouble(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      profileImage: map['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'location': location,
      'phone': phone,
      'service': service,
      'price': price,
      'rating': rating,
      'profileImage': profileImage,
    };
  }
}

class ChatMessage {
  final String senderEmail;
  final String receiverEmail;
  final String text;
  final DateTime time; 

  ChatMessage({
    required this.senderEmail,
    required this.receiverEmail,
    required this.text,
    required this.time, 
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderEmail: map['senderEmail'] ?? '',
      receiverEmail: map['receiverEmail'] ?? '',
      text: map['text'] ?? '',
      time: map['time'] is String ? DateTime.parse(map['time']) : (map['time']?.toDate() ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'text': text,
      'time': time.toIso8601String(),
    };
  }
}

class ServiceTask {
  final String? id; 
  final String clientEmail;
  final String workerEmail;
  final String serviceName;
  final String date; 
  String status;
  final String? description;
  final int isPublic;

  ServiceTask({
    this.id,
    required this.clientEmail,
    required this.workerEmail,
    required this.serviceName,
    required this.date,
    this.status = 'pending', 
    this.description,
    this.isPublic = 0,
  });

  factory ServiceTask.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ServiceTask(
      id: docId ?? map['id'],
      clientEmail: map['clientEmail'] ?? '',
      workerEmail: map['workerEmail'] ?? '',
      serviceName: map['serviceName'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'pending',
      description: map['description'],
      isPublic: map['isPublic'] ?? 0,
    );
  }
}