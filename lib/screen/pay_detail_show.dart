import 'package:school_konnect/screen/payment_screen.dart';
import 'package:flutter/material.dart';

class PayDetailShow extends StatefulWidget {
  const PayDetailShow({super.key});
  @override
  State<PayDetailShow> createState() => _PayDetailShowState();
}

class _PayDetailShowState extends State<PayDetailShow> {
  Future<void> _pay() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentScreen(
          amount: '499.00',
          productInfo: 'Premium Plan',
          firstName: 'John',
          email: 'karan@infowayindia.com',
          phone: '9876543210',
        ),
      ),
    );

    if (!mounted) return;

    switch (result?['status']) {
      case 'success':
        _snack('✅ Payment Successful!', Colors.green);
        break;
      case 'failure':
        _snack('❌ Payment Failed', Colors.red);
        break;
      case 'cancelled':
        _snack('⚠️ Cancelled', Colors.orange);
        break;
      case 'error':
        _snack('🚨 Error occurred', Colors.red);
        break;
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PayU CheckoutPro')),
      body: Center(
        child: ElevatedButton(
          onPressed: _pay,
          child: const Text('Pay ₹499'),
        ),
      ),
    );
  }
}