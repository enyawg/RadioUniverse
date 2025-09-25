import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/stripe_config.dart';
import 'subscription_service.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();
  
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  // Pricing (in cents)
  static const int monthlyPriceCents = 399; // $3.99
  static const int yearlyPriceCents = 3999; // $39.99
  
  // Display prices
  static const String monthlyPriceDisplay = '\$3.99/month';
  static const String yearlyPriceDisplay = '\$39.99/year';
  static const String yearlySavings = 'Save 17%';
  
  /// Initialize payment sheet for subscription
  Future<bool> initializePaymentSheet({
    required bool isYearly,
  }) async {
    try {
      // In production, you would:
      // 1. Call your backend to create a payment intent
      // 2. Get the client secret from backend
      // 3. Initialize the payment sheet with the client secret
      
      // For testing, we'll simulate the flow
      print('🔧 Initializing payment sheet for ${isYearly ? 'yearly' : 'monthly'} subscription');
      
      // TODO: Replace with actual backend call
      // final response = await http.post(
      //   Uri.parse(StripeConfig.createSubscriptionUrl),
      //   body: {
      //     'priceId': isYearly ? StripeConfig.premiumYearlyPriceId : StripeConfig.premiumMonthlyPriceId,
      //     'customerId': userId,
      //   },
      // );
      
      // For now, show test payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: 'test_secret', // Replace with actual secret from backend
          merchantDisplayName: 'Radio Universe',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF6750A4), // Your theme color
            ),
          ),
        ),
      );
      
      return true;
    } catch (e) {
      print('❌ Error initializing payment sheet: $e');
      return false;
    }
  }
  
  /// Present payment sheet to user
  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      
      // Payment successful
      print('✅ Payment successful!');
      
      // Activate premium
      await _subscriptionService.activatePremium();
      
      return true;
    } on StripeException catch (e) {
      print('❌ Payment cancelled or failed: ${e.error.message}');
      return false;
    }
  }
  
  /// Test payment flow (for sandbox testing)
  Future<void> testPaymentFlow({required bool isYearly}) async {
    print('🧪 Starting test payment flow for ${isYearly ? 'yearly' : 'monthly'} subscription');
    print('💳 Test card: 4242 4242 4242 4242');
    print('📅 Expiry: Any future date');
    print('🔐 CVC: Any 3 digits');
    print('📮 ZIP: Any 5 digits');
    
    // In sandbox, you can simulate successful payment
    await Future.delayed(const Duration(seconds: 2));
    await _subscriptionService.activatePremium();
    print('✅ Test payment successful - Premium activated!');
  }
}