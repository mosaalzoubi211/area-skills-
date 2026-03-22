import 'dart:async';
import 'package:flutter/material.dart';
import '../structure/main_scaffold.dart';
import '../structure/firebase_service.dart'; 
class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService(); // 🟢
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    bool isVerified = await _authService.isEmailVerified();
    
    if (isVerified) {
      _timer?.cancel(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تأكيد الحساب بنجاح! 🎉"), backgroundColor: Colors.green),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
           MaterialPageRoute(builder: (_) => const MainScaffold()),
          (route) => false,
        );
      }
    }
  }


  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await _authService.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إعادة إرسال الرابط بنجاح! تفقد صندوق الوارد أو البريد المزعج (Spam)"), backgroundColor: Colors.blueAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى الانتظار قليلاً قبل المحاولة مرة أخرى"), backgroundColor: Colors.orange),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
             _timer?.cancel();
             Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_unread_outlined, size: 70, color: Colors.blueAccent),
            ),
            const SizedBox(height: 30),
            const Text(
              "تحقق من بريدك الإلكتروني",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.grey, fontSize: 16, fontFamily: 'Tahoma', height: 1.5),
                children: [
                  const TextSpan(text: "لقد أرسلنا رابط تأكيد إلى البريد:\n"),
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: "\n\nيرجى فتح بريدك والضغط على الرابط لتفعيل حسابك. سيتم نقلك تلقائياً فور التأكيد."),
                ],
              ),
            ),
            const SizedBox(height: 50),

            const CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text("في انتظار تأكيدك...", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),

            const SizedBox(height: 50),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("لم يصلك الرابط؟ ", style: TextStyle(color: Colors.grey)),
                _isResending 
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(
                      onPressed: _resendEmail,
                      child: const Text("إعادة إرسال", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}