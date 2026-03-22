import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../structure/user_provider.dart'; 
import '../structure/firebase_service.dart';
import '../structure/user_model.dart';
import '../Registration/login_screen.dart';
import 'dart:convert'; 
import 'dart:typed_data'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key}); 

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? currentUser;
  bool loading = true;
  bool isSaving = false;

  final _phoneController = TextEditingController(); 
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  int completedTasksCount = 0;
  final FirestoreService _firestoreService = FirestoreService(); 

  static const Color tealAccent = Color(0xFF18BAA4);
  static const Color textDark = Color(0xFF1E293B);
  static const Color bgScaffold = Color(0xFFF8FAFC);
  static const Color grayField = Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 30,  
        maxWidth: 500,    
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
        _showSnackbar("تم اختيار الصورة بنجاح، اضغط حفظ للتأكيد", const Color(0xFF10B981));
      }
    } catch (e) {
      _showSnackbar("حدث خطأ أثناء اختيار الصورة", Colors.red);
    }
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final User? foundUser = userProvider.currentUser;

    if (foundUser != null) {
      int tasksCount = 0;
      if (foundUser.role == 'worker') {
        final counts = await _firestoreService.getWorkerTaskCounts(foundUser.email); 
        tasksCount = counts['completed'] ?? 0;
      }

      setState(() {
        currentUser = User.fromMap(foundUser.toMap());
        _nameController.text = foundUser.name;
        _priceController.text = foundUser.price?.toString() ?? '';
        _phoneController.text = foundUser.phone ?? '';
        completedTasksCount = tasksCount;
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  ImageProvider? _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!); 
    }
    if (currentUser?.profileImage != null && currentUser!.profileImage!.isNotEmpty) {
      try {
        Uint8List imageBytes = base64Decode(currentUser!.profileImage!);
        return MemoryImage(imageBytes);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void _showVerificationBeforePassword() {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text("التحقق من الهوية", textAlign: TextAlign.center, style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("أدخل رمز التحقق المرسل لهاتفك (وهمي)", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold, color: textDark),
              decoration: InputDecoration(
                hintText: "0000",
                counterText: "",
                filled: true,
                fillColor: grayField,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("إلغاء", style: TextStyle(color: Colors.grey.shade600))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tealAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (codeController.text.length == 4) {
                Navigator.pop(context); 
                _showChangePasswordDialog(); 
              } else {
                _showSnackbar("يرجى إدخال 4 أرقام", Colors.orange);
              }
            },
            child: const Text("تحقق", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text("تغيير كلمة السر", textAlign: TextAlign.center, style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(controller: newPasswordController, label: "كلمة السر الجديدة", icon: Icons.lock_outline_rounded, obscure: true),
            const SizedBox(height: 15),
            _buildTextField(controller: confirmPasswordController, label: "تأكيد كلمة السر", icon: Icons.lock_reset_rounded, obscure: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("إلغاء", style: TextStyle(color: Colors.grey.shade600))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tealAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (newPasswordController.text == confirmPasswordController.text && newPasswordController.text.isNotEmpty) {
                setState(() => currentUser!.password = newPasswordController.text);
                await _firestoreService.updateUser(currentUser!); 
                
                if (mounted) Provider.of<UserProvider>(context, listen: false).setUser(currentUser!);

                Navigator.pop(context);
                _showSnackbar("تم تحديث كلمة السر بنجاح", const Color(0xFF10B981));
              } else {
                _showSnackbar("كلمات السر غير متطابقة", Colors.orange);
              }
            },
            child: const Text("حفظ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => isSaving = true);
    
    currentUser?.name = _nameController.text;
    currentUser?.phone = _phoneController.text;
    if (currentUser?.role == 'worker') {
      currentUser?.price = double.tryParse(_priceController.text);
    }
    
    if (_imageFile != null) {
      try {
        _showSnackbar("جاري معالجة الصورة وحفظها...", tealAccent);
        List<int> imageBytes = await _imageFile!.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        currentUser?.profileImage = base64Image;
      } catch (e) {
        _showSnackbar("حدث خطأ أثناء معالجة الصورة، حجمها قد يكون كبيراً", Colors.red);
      }
    }

    await _firestoreService.updateUser(currentUser!); 
    
    if (mounted) {
      Provider.of<UserProvider>(context, listen: false).setUser(currentUser!);
    }

    await Future.delayed(const Duration(milliseconds: 500)); 
    
    if (mounted) {
      _showSnackbar('تم حفظ جميع التعديلات بنجاح!', const Color(0xFF10B981));
      setState(() => isSaving = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading || currentUser == null) return const Scaffold(backgroundColor: bgScaffold, body: Center(child: CircularProgressIndicator(color: tealAccent)));

    final isWorker = currentUser?.role == 'worker';

    return Scaffold(
      backgroundColor: bgScaffold,
      appBar: AppBar(
        title: const Text("حسابي", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textDark)),
        centerTitle: false, 
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildProfileHeader(),
            const SizedBox(height: 35),

            if (isWorker) _buildWorkerStats(),

            _buildSectionTitle("المعلومات الشخصية"),
            _buildCard([
              _buildTextField(controller: _nameController, label: "الاسم الكامل", icon: Icons.person_outline_rounded),
              const SizedBox(height: 15),
              _buildInfoTile("البريد الإلكتروني", currentUser!.email, Icons.email_outlined),
              const SizedBox(height: 15),
              _buildTextField(controller: _phoneController, label: "رقم الهاتف", icon: Icons.phone_iphone_rounded, isPhone: true),
            ]),

            const SizedBox(height: 25),

            _buildSectionTitle("الأمان"),
            _buildCard([
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.lock_outline_rounded, color: Colors.orange),
                ),
                title: const Text("كلمة المرور", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                subtitle: Text("********", style: TextStyle(color: Colors.grey.shade500)),
                trailing: TextButton(
                  onPressed: _showVerificationBeforePassword,
                  child: const Text("تغيير", style: TextStyle(fontWeight: FontWeight.bold, color: tealAccent)),
                ),
              ),
            ]),

            const SizedBox(height: 25),

            if (isWorker) ...[
              _buildSectionTitle("إعدادات العمل"),
              _buildCard([
                _buildInfoTile("المهنة", currentUser!.service ?? 'عام', Icons.handyman_outlined),
                const SizedBox(height: 15),
                _buildTextField(controller: _priceController, label: "سعر الخدمة (JD)", icon: Icons.payments_outlined, isNumber: true),
              ]),
              const SizedBox(height: 30),
            ],

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tealAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("حفظ التغييرات", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 15),

            TextButton.icon(
              onPressed: () async {
                await FirebaseAuthService().logout(); 
                
                if (context.mounted) {
                  Provider.of<UserProvider>(context, listen: false).clearUser();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              label: const Text("تسجيل الخروج", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    ImageProvider? imageProvider = _getProfileImage();

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tealAccent.withOpacity(0.3), width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: tealAccent.withOpacity(0.1),
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Text(currentUser!.name.isNotEmpty ? currentUser!.name[0].toUpperCase() : "?",
                          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: tealAccent))
                      : null,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: tealAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(currentUser!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: tealAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(currentUser!.role == 'worker' ? "حساب محترف" : "حساب مستخدم",
              style: const TextStyle(color: tealAccent, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildWorkerStats() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("التقييم", currentUser!.rating.toString(), Icons.star_rounded, Colors.amber),
          _buildStatItem("مكتملة", completedTasksCount.toString(), Icons.done_all_rounded, const Color(0xFF10B981)),
          _buildStatItem("السعر", "${currentUser!.price} JD", Icons.payments_rounded, tealAccent),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12, right: 5),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark), textAlign: TextAlign.right),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPhone = false, bool isNumber = false, bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(color: grayField, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: isPhone ? TextInputType.phone : (isNumber ? TextInputType.number : TextInputType.text),
        textAlign: TextAlign.right,
        style: const TextStyle(color: textDark, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
        ]),
        const SizedBox(width: 15),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: grayField, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: tealAccent, size: 20),
        ),
      ],
    );
  }
}