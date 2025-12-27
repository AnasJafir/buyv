import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'security/secure_token_manager.dart';

class StripeService {
  static final StripeService instance = StripeService._internal();
  factory StripeService() => instance;
  StripeService._internal();

  /// Initialize Stripe with Publishable Key (Configured in main.dart ideally, or here lazily)
  void init() {
    // Ideally STRIPE_PUBLISHABLE_KEY should be handled via env,
    // but flutter_dotenv must be loaded before this.
    // Assuming keys are set in main.dart
  }

  Future<void> makePayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required Future<void> Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      debugPrint('💳 Starting Stripe payment for \$${amount.toStringAsFixed(2)}');
      
      // 1. Create Payment Intent on Backend
      debugPrint('💳 Step 1: Creating payment intent...');
      final paymentData = await _createPaymentIntent(amount, currency);

      if (paymentData == null) {
        debugPrint('❌ Payment intent creation failed');
        onError('Failed to create payment intent');
        return;
      }

      debugPrint('✅ Payment intent created: ${paymentData['clientSecret']?.substring(0, 20)}...');

      // 2. Initialize Payment Sheet
      debugPrint('💳 Step 2: Initializing payment sheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentData['clientSecret'],
          merchantDisplayName: 'BuyV Store',
          customerId: paymentData['customer'],
          customerEphemeralKeySecret: paymentData['ephemeralKey'],
          // style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Color(0xFFE94057)),
          ),
        ),
      );

      debugPrint('✅ Payment sheet initialized');

      // 3. Present Payment Sheet
      debugPrint('💳 Step 3: Presenting payment sheet...');
      await Stripe.instance.presentPaymentSheet();

      debugPrint('✅ Payment completed successfully!');
      // 4. Success - AWAIT the callback
      await onSuccess();
      debugPrint('✅ onSuccess callback completed');
    } on StripeException catch (e) {
      debugPrint('❌ Stripe exception: ${e.error.code} - ${e.error.localizedMessage}');
      if (e.error.code == FailureCode.Canceled) {
        // User canceled, do nothing or show toast
        debugPrint('ℹ️ User canceled payment');
        return;
      }
      onError('Payment Request Failed: ${e.error.localizedMessage}');
    } catch (e) {
      debugPrint('❌ Unexpected payment error: $e');
      onError('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent(
    double amount,
    String currency,
  ) async {
    try {
      final token = await SecureTokenManager.getAccessToken();
      final url = Uri.parse(
        '${AppConstants.fastApiBaseUrl}/payments/create-payment-intent',
      );

      // Amount must be integer cents
      final int amountCents = (amount * 100).toInt();

      debugPrint('💳 Requesting payment intent: $amountCents cents');
      debugPrint('💳 URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amountCents, 'currency': currency}),
      );

      debugPrint('💳 Backend response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('💳 Payment data received: clientSecret=${data['clientSecret'] != null}, customer=${data['customer']}');
        return data;
      } else {
        debugPrint('❌ Backend payment intent error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Create payment intent exception: $e');
      return null;
    }
  }
}
