import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final double commissionRate = 0.10;

  const PaymentScreen({super.key, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  double get commission => widget.amount * widget.commissionRate;
  double get totalAmount => widget.amount + commission;


void _processPayment() async {

  if (_formKey.currentState == null) return;

  if (_formKey.currentState!.validate()) {
    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      setState(() => _isProcessing = false);

      _showSuccessDialog();
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      print("Error during payment: $e");
    }
  }
}


void _showSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (innerContext) => AlertDialog( 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text("تم الدفع بنجاح", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {

              Navigator.of(innerContext).pop(); 

              Navigator.of(context).pop(); 
            },
            child: const Text("موافق"),
          )
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الدفع الآمن"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 30),
              const Text("معلومات البطاقة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              _buildValidatedField(
                label: "رقم البطاقة",
                hint: "1234 5678 1234 5678",
                icon: Icons.credit_card,
                minLength: 16,
                errorText: "رقم البطاقة يجب أن يكون 16 رقماً",
              ),
              const SizedBox(height: 15),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildValidatedField(
                      label: "التاريخ",
                      hint: "MM/YY",
                      icon: Icons.calendar_today,
                      minLength: 4,
                      errorText: "تحقق من التاريخ",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildValidatedField(
                      label: "رمز CVV",
                      hint: "123",
                      icon: Icons.lock,
                      minLength: 3,
                      errorText: "تحقق من الرمز",
                      isObscure: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              _isProcessing 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("دفع ${totalAmount.toStringAsFixed(2)} JD", 
                      style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _summaryRow("قيمة العمل:", "${widget.amount} JD"),
          const Divider(),
          _summaryRow("عمولة التطبيق (10%):", "${commission.toStringAsFixed(2)} JD"),
          const Divider(thickness: 2),
          _summaryRow("المجموع الكلي:", "${totalAmount.toStringAsFixed(2)} JD", isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.blue : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildValidatedField({
    required String label, 
    required String hint, 
    required IconData icon, 
    required int minLength, 
    required String errorText,
    bool isObscure = false,
  }) {
    return TextFormField(
      obscureText: isObscure,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(minLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorStyle: const TextStyle(fontSize: 10),
      ),

      validator: (value) {
        if (value == null || value.isEmpty) {
          return "مطلوب";
        }
        if (value.length < minLength) {
          return errorText;
        }
        return null;
      },
    );
  }
}