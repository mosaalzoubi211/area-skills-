import 'package:flutter/material.dart';
import 'signup_screen.dart'; 
import 'login_screen.dart'; 

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  static const Color tealAccent = Color(0xFF18BAA4);
  static const Color textDark = Color(0xFF1E293B);
  static const Color bgScaffold = Color(0xFFF8FAFC);

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7, 
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: bgScaffold,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Center(
                        child: Text(
                          "About Area Skills",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildInfoCard(
                        icon: Icons.info_outline_rounded,
                        title: "Area Skills",
                        quote: "\"Your choice for a better community\"",
                        description: "Area skills, your compassionate guide to greater independence for individuals with special needs. It uniquely blends smart offline AI with the warmth of human connection. Easily book flexible appointments or connect via live calls for face-to-face personalized support.",
                        footer: "Developed by: Area Team",
                      ),
                      const SizedBox(height: 20),
                      _buildContactCard(
                        icon: Icons.help_outline_rounded,
                        title: "Contact Us",
                        email: "kaddumi07@gmail.com",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgScaffold,
      body: SafeArea(
        child: SingleChildScrollView( 
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                const SizedBox(height: 20),
                
                Center(
                  child: Image.asset(
                    'assets/images/name.jpg', 
                    height: 100,      
                    fit: BoxFit.contain,
                  ),
                ),
                
                const SizedBox(height: 25),
              
                const Text(
                  "Connect with skilled workers or offer your services",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 45),
             
                _roleCard(
                  context, 
                  icon: Icons.search_rounded, 
                  color: tealAccent, 
                  title: "I need services", 
                  desc: "Find skilled workers for plumbing, electrical, and more", 
                  role: "client"
                ),
                const SizedBox(height: 20),
                _roleCard(
                  context, 
                  icon: Icons.handyman_rounded, 
                  color: textDark, 
                  title: "I offer services", 
                  desc: "Get hired for your skills and grow your freelance business", 
                  role: "worker"
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    TextButton(
                      onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      child: const Text(
                          "Log In",
                          style: TextStyle(color: tealAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Center(
                  child: TextButton.icon(
                    onPressed: () => _showAboutSheet(context),
                    icon: const Icon(Icons.info_outline_rounded, size: 20, color: Colors.grey),
                    label: const Text(
                      "About Us - تعرف علينا",
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                
                const Text(
                  "ابدأ رحلتك في 3 خطوات سهلة!", 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                ),
                const SizedBox(height: 25),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProcessStep(icon: Icons.how_to_reg_rounded, label: "سجّل", color: tealAccent),
                    _buildProcessStep(icon: Icons.search_rounded, label: "ابحث", color: tealAccent.withOpacity(0.7)),
                    _buildProcessStep(icon: Icons.done_all_rounded, label: "أنجز", color: textDark.withOpacity(0.8)),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String quote, required String description, required String footer}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: tealAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: tealAccent)),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            ],
          ),
          const SizedBox(height: 15),
          Text(quote, style: const TextStyle(color: tealAccent, fontStyle: FontStyle.italic, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: Colors.grey.shade700, height: 1.6, fontSize: 14)),
          const SizedBox(height: 15),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
          const SizedBox(height: 10),
          Row(children: [const Icon(Icons.business_rounded, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(footer, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required String title, required String email}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: tealAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: tealAccent)),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: bgScaffold, borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                const Icon(Icons.email_outlined, size: 20, color: textDark),
                const SizedBox(width: 12),
                Expanded(child: Text(email, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleCard(BuildContext context, {required IconData icon, required Color color, required String title, required String desc, required String role}) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen(), settings: RouteSettings(arguments: role))),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 6),
                  Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18), 
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStep({required IconData icon, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle, 
            color: Colors.white, 
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
          ),
          child: Icon(icon, size: 26, color: color),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
      ],
    );
  }
}