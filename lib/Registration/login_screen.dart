import 'package:flutter/material.dart';
import '../structure/user_model.dart';
import '../structure/main_scaffold.dart'; 
import 'role_select_screen.dart'; 
import '../structure/firebase_service.dart';
import 'forgot_password_screen.dart'; 
import '../structure/notification_service.dart';
import 'package:provider/provider.dart';
import '../structure/user_provider.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _loading = false;
  bool _obscurePassword = true;

  final FirebaseAuthService _authService = FirebaseAuthService();


  static const Color tealAccent = Color(0xFF18BAA4);
  static const Color grayField = Color(0xFFF1F5F9); 
  static const Color textDark = Color(0xFF1E293B);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      final User? loggedInUser = await _authService.loginUser(email, password);

      if (loggedInUser != null) {
        if (mounted) Provider.of<UserProvider>(context, listen: false).setUser(loggedInUser);
        await NotificationService().initNotifications(loggedInUser.email);

        if (mounted) {
          _showSnackbar('تم تسجيل الدخول بنجاح!', Colors.green);
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (_) => const MainScaffold(), 
            ),
          );
        }
      } else {
        _showSnackbar('حدث خطأ أثناء تسجيل الدخول.', Colors.red);
      }
    } catch (e) {
      _showSnackbar(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }
  
  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: grayField,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: type,
        textAlign: TextAlign.right, 
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form( 
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
       
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: tealAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded, size: 60, color: tealAccent),
                ),
              ),
              const SizedBox(height: 35),
              
              const Text(
                "أهلاً بعودتك!", 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark)
              ),
              const SizedBox(height: 8),
              Text(
                "سجل دخولك الآن للمتابعة", 
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600)
              ),
              
              const SizedBox(height: 40),

              _buildInputField(
                label: "البريد الإلكتروني", 
                icon: Icons.email_outlined, 
                controller: _emailController, 
                type: TextInputType.emailAddress
              ),
              
              _buildInputField(
                label: "كلمة المرور", 
                icon: Icons.lock_outline, 
                controller: _passwordController, 
                isPassword: true
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text(
                    "نسيت كلمة المرور؟", 
                    style: TextStyle(color: tealAccent, fontWeight: FontWeight.w600, fontSize: 13)
                  ),
                ),
              ),

              const SizedBox(height: 35),

              _loading
                  ? const Center(child: CircularProgressIndicator(color: tealAccent))
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tealAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("تسجيل الدخول", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

              const SizedBox(height: 40),

            
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("ليس لديك حساب؟", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelectScreen())),
                    child: const Text("سجل الآن", style: TextStyle(color: tealAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}