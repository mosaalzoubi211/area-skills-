import 'package:flutter/material.dart';
import '../structure/user_model.dart';
import 'login_screen.dart';
import 'verification_screen.dart';
import '../structure/firebase_service.dart'; 
import 'package:geolocator/geolocator.dart'; 
import 'package:geocoding/geocoding.dart'; 
import '../structure/notification_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _serviceController = TextEditingController();
  final _priceController = TextEditingController();
  
  final _locationController = TextEditingController(); 
  bool _isGettingLocation = false;
  String? _selectedLocation;
  
  late String _selectedRole;
  bool _loading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuthService _authService = FirebaseAuthService();


  static const Color tealAccent = Color(0xFF18BAA4);
  static const Color grayField = Color(0xFFF1F5F9); 
  static const Color textDark = Color(0xFF1E293B);
  static const Color bgScaffold = Color(0xFFF8FAFC);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _selectedRole = args != null ? args as String : 'client';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _serviceController.dispose();
    _priceController.dispose();
    _locationController.dispose(); 
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackbar('يرجى تفعيل خدمة الموقع (GPS) في هاتفك', Colors.orange);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackbar('تم رفض صلاحية الوصول للموقع', Colors.red);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackbar('صلاحيات الموقع معطلة بشكل دائم، يرجى تفعيلها من الإعدادات', Colors.red);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.administrativeArea ?? ''} - ${place.locality ?? ''}";
        
        setState(() {
          _locationController.text = address; 
          _selectedLocation = address;        
        });
        _showSnackbar('تم تحديد موقعك بنجاح!', Colors.green);
      }
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء جلب الموقع', Colors.red);
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar('يرجى تعبئة جميع الحقول المطلوبة.', Colors.orange);
      return;
    }
    
    setState(() => _loading = true);

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String name = _nameController.text.trim();
      final String location = _selectedLocation!;
      final bool isWorker = _selectedRole == 'worker';

      final newUser = User(
        name: name,
        email: email, 
        password: password, 
        role: _selectedRole,
        location: location,
        service: isWorker ? _serviceController.text.trim() : null,
        price: isWorker ? (double.tryParse(_priceController.text) ?? 0.0) : null,
      );

      final createdUser = await _authService.signUpUser(newUser, password); 
      
      if (createdUser != null) {
        await NotificationService().initNotifications(createdUser.email);
        _showSnackbar('تم إنشاء الحساب بنجاح، جاري التحقق...', Colors.green);
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VerificationScreen(email: email),
            ),
          );
        }
      } else {
        _showSnackbar('حدث خطأ غير معروف أثناء إنشاء الحساب.', Colors.red);
      }
      
    } catch (e) {
      _showSnackbar(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right), backgroundColor: color, behavior: SnackBarBehavior.floating)
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    bool isPassword = false,
    TextInputType? type,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: grayField,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: type,
        maxLines: maxLines,
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
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
          if (label == "البريد الإلكتروني" && !value.contains('@')) return 'بريد غير صالح';
          if (label == "كلمة المرور" && value.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'; 
          return null;
        },
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: grayField,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _locationController,
        readOnly: true, 
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: "الموقع الجغرافي",
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          hintText: "اضغط على الزر لتحديد موقعك",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey.shade400, size: 22),
          suffixIcon: _isGettingLocation 
              ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2, color: tealAccent))
              : IconButton(
                  icon: const Icon(Icons.my_location_rounded, color: tealAccent),
                  onPressed: _getCurrentLocation,
                  tooltip: "تحديد موقعي الآن",
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'يرجى تحديد موقعك الجغرافي باستخدام الزر';
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWorker = _selectedRole == 'worker';

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form( 
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: tealAccent.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(isWorker ? Icons.handyman_rounded : Icons.person_add_rounded, size: 50, color: tealAccent),
                ),
              ),
              const SizedBox(height: 25),
              
              Text(
                isWorker ? "حساب محترف جديد" : "حساب عميل جديد", 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark)
              ),
              const SizedBox(height: 8),
              Text("أدخل بياناتك لإنشاء الحساب والبدء", style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
              const SizedBox(height: 35),

              // 🟢 الحقول
              _buildInputField(label: "الاسم الكامل", icon: Icons.person_outline_rounded, controller: _nameController),
              _buildInputField(label: "البريد الإلكتروني", icon: Icons.email_outlined, controller: _emailController, type: TextInputType.emailAddress),
              _buildInputField(label: "كلمة المرور", icon: Icons.lock_outline, controller: _passwordController, isPassword: true),
              
              _buildLocationField(), 

              if (isWorker) ...[
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                const SizedBox(height: 10),
                _buildInputField(label: "نوع الخدمة (مثلاً: سباكة)", icon: Icons.build_outlined, controller: _serviceController),
                _buildInputField(label: "السعر المتوقع (JD)", icon: Icons.payments_outlined, controller: _priceController, type: TextInputType.number),
              ],

              const SizedBox(height: 35),
              
              _loading
                  ? const Center(child: CircularProgressIndicator(color: tealAccent))
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tealAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(isWorker ? "انضم كعامل محترف" : "إنشاء حسابي", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("لديك حساب بالفعل؟", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text("سجل دخولك", style: TextStyle(color: tealAccent, fontWeight: FontWeight.bold, fontSize: 14)),
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