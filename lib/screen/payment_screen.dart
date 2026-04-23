import 'package:school_konnect/api/post.dart';
import 'package:flutter/material.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../extras/dimension.dart';
import '../services/hash_service.dart';
import '../services/local_hash_service.dart';

class PaymentScreen extends StatefulWidget {
  final String amount;
  final String productInfo;
  final String firstName;
  final String email;
  final String phone;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.productInfo,
    required this.firstName,
    required this.email,
    required this.phone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    implements PayUCheckoutProProtocol {

  late PayUCheckoutProFlutter _checkoutPro;

  static const String _merchantKey = 'Pd4KWd'; // public key, safe in app
  static const String _environment = '1'; // 1 = Test, 0 = Production
  final Post _post = Post();
  String  token = "";
  @override
  void initState() {
    super.initState();
    // Step 1: Initialize SDK with current object
    _checkoutPro = PayUCheckoutProFlutter(this);
    // Step 2: Start payment after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPayment());
  }

  Future<void> _startPayment() async {
     token = await getUserToken();
    print('sdsd');
    final txnId = DateTime.now().millisecondsSinceEpoch.toString();
    print('sdsd 1');
    // Step 3: Build payment params
    final Map<String, dynamic> payUPaymentParams = {
      PayUPaymentParamKey.key: _merchantKey,
      PayUPaymentParamKey.amount: widget.amount,
      PayUPaymentParamKey.productInfo: widget.productInfo,
      PayUPaymentParamKey.firstName: widget.firstName,
      PayUPaymentParamKey.email: widget.email,
      PayUPaymentParamKey.phone: widget.phone,
      PayUPaymentParamKey.transactionId: txnId,
      PayUPaymentParamKey.environment: _environment,
      PayUPaymentParamKey.android_surl: 'https://cbjs.payu.in/sdk/success',
      PayUPaymentParamKey.android_furl: 'https://cbjs.payu.in/sdk/failure',
      PayUPaymentParamKey.ios_surl: 'https://cbjs.payu.in/sdk/success',
      PayUPaymentParamKey.ios_furl: 'https://cbjs.payu.in/sdk/failure',
      //PayUPaymentParamKey.userCredential: '$_merchantKey:${widget.email}',
    };

    print('sdsd 2 $payUPaymentParams');

    // Step 4: Launch CheckoutPro
    _checkoutPro.openCheckoutScreen(
      payUPaymentParams: payUPaymentParams,
      payUCheckoutProConfig:<String, dynamic>{},// optional config
    );

    print('sdsd 3');
  }

  // ─── PayUCheckoutProProtocol callbacks ────────────────────────────

  /// SDK calls this whenever it needs a hash — forward to your backend
  /**@override
  generateHash(Map response) async {
    try {
      /**final hashName = response[PayUHashConstantsKeys.hashName];
      final hashString = response[PayUHashConstantsKeys.hashString];
      final hashType = response[PayUHashConstantsKeys.hashType];
      final postSalt = response[PayUHashConstantsKeys.postSalt];

      print('hashName $hashName hashString $hashString hashType $hashType postSalt $postSalt');

      // Call your backend
      final result = await HashService.getHash(
        hashName: hashName,
        hashString: hashString,
        hashType: hashType ?? 'V1',
        postSalt: postSalt,
      );

      final Map<String, dynamic> hashResponse = Map<String, dynamic>.from(response);
      hashResponse[hashName] = result['hash'];

      _checkoutPro.hashGenerated(hash: hashResponse);**/

      final String hashName = response[PayUHashConstantsKeys.hashName] as String;

      // ⚠️ Local hash — for testing only
      final String hash = LocalHashService.generateHash(response);

      final Map<String, dynamic> hashResponse =
      Map<String, dynamic>.from(response);
      hashResponse[hashName] = hash;

      _checkoutPro.hashGenerated(hash: hashResponse);

      // Pass hash back to SDK
    //  _checkoutPro.hashGenerated(hash: {
     //   result['hashName']!: result['hash']!,
     // });
    } catch (e) {
      debugPrint('Hash generation error: $e');
    }
  }**/

  Future<String> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_bearer_token') ?? '';
  }

  /**@override
  void generateHash(Map response) async {
    try {
      debugPrint('PayU hash request: $response');

      final String hashName =
      response[PayUHashConstantsKeys.hashName] as String;

      final String hashString =
      response[PayUHashConstantsKeys.hashString] as String;

      final String? postSalt =
      response[PayUHashConstantsKeys.postSalt] as String?;

      final result = await _post.getHash(
        hashName: hashName,
        hashString: hashString,
        postSalt: postSalt,
        token: token,
      );

      debugPrint('Laravel hash response: $result');

      _checkoutPro.hashGenerated(hash: result);
    } catch (e) {
      debugPrint('generateHash error: $e');
    }
  }**/

  @override
  void generateHash(Map response) {
    try {
      debugPrint('PayU hash request: $response');

      final String hashName =
      response[PayUHashConstantsKeys.hashName] as String;

      final String hashString =
      response[PayUHashConstantsKeys.hashString] as String;

      final String? hashType =
      response[PayUHashConstantsKeys.hashType] as String?;

      final String? postSalt =
      response[PayUHashConstantsKeys.postSalt] as String?;

      final String hash = LocalHashService.generateHash(
        hashName: hashName,
        hashString: hashString,
        hashType: hashType ?? 'V1',
        postSalt: postSalt,
      );

      debugPrint('Generated hash: $hash');

      _checkoutPro.hashGenerated(hash: {
        hashName: hash,
      });
    } catch (e) {
      debugPrint('generateHash error: $e');
    }
  }

  @override
  onPaymentSuccess(dynamic response) {
    Navigator.pop(context, {'status': 'success', 'response': response});
  }

  @override
  onPaymentFailure(dynamic response) {
    Navigator.pop(context, {'status': 'failure', 'response': response});
  }

  @override
  onPaymentCancel(Map? response) {
    Navigator.pop(context, {'status': 'cancelled'});
  }

  @override
  onError(Map? response) {
    Navigator.pop(context, {'status': 'error', 'response': response});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF3E8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'initials',
                  style: const TextStyle(
                    color: Color(0xFF75292A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.paddingM),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, Student',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(

                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
          const Text("sdsdsd")
        ],
      )
    );
  }
}
