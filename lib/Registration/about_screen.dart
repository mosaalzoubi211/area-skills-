import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // خلفية هادئة مثل الصورة
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "About Area skill",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // القسم الأول: معلومات التطبيق
            _buildAboutCard(),
            const SizedBox(height: 20),
            // القسم الثاني: تواصل معنا
            _buildContactCard(),
          ],
        ),
      ),
    );
  }

  // بطاقة المعلومات الرئيسية
  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.info_outline, color: Colors.white),
              ),
              const SizedBox(width: 15),
              const Text("Area skill", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: const Text(
              "\"Your choice for better community\"",
              style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic, fontSize: 13),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Area skill, your compassionate guide to greater independence for individuals with special needs. It uniquely blends smart offline AI with the warmth of human connection. Easily book flexible volunteer appointments or connect via live video calls for face-to-face personalized support. Daleel empowers your daily confidence, merging the best of technology and human touch.",
            style: TextStyle(color: Colors.black87, height: 1.6, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.business, "Developed by: Area Team"),
        ],
      ),
    );
  }

  // بطاقة تواصل معنا
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.help_outline, color: Colors.white),
              ),
              const SizedBox(width: 15),
              const Text("Contact Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.email_outlined, "alzoubi03@gmail.com", showArrow: true),
        ],
      ),
    );
  }

  // ويدجت صف معلومات بسيط مع أيقونة
  Widget _buildInfoRow(IconData icon, String text, {bool showArrow = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87))),
          if (showArrow) const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}