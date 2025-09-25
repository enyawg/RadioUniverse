/// Stripe Configuration for RadioUniverse
/// 
/// IMPORTANT: These are TEST keys for development only.
/// Never commit production keys to version control.
/// 
/// For production:
/// 1. Use environment variables or secure storage
/// 2. Never expose secret keys in client code
/// 3. Handle secret key operations on your backend

class StripeConfig {
  // TEST KEYS - Safe to use in development
  static const String publishableKeyTest = 'pk_test_51S3EtAFnyOcliGum6TI4BDeCTOWUyUOxjVXV16OiW8P3L54mkeUEqZP5vtrkCRIOTUxZww2Em6dwKjUqOt3n6ptq00zFuwWMPV';
  
  // NEVER put secret key in client code - this is just for reference
  // Secret key should only be used on your backend server
  // static const String secretKeyTest = 'sk_test_...'; // DO NOT USE IN APP
  
  // Test Account ID
  static const String testAccountId = 'acct_1S3G8bFk2QPLYv75';
  
  // Product IDs (create these in Stripe Dashboard)
  static const String premiumMonthlyProductId = 'prod_test_premium_monthly';
  static const String premiumYearlyProductId = 'prod_test_premium_yearly';
  
  // Price IDs (create these in Stripe Dashboard)
  static const String premiumMonthlyPriceId = 'price_test_premium_monthly';
  static const String premiumYearlyPriceId = 'price_test_premium_yearly';
  
  // URLs for your backend (when you set it up)
  static const String baseUrl = 'https://your-backend.com/api';
  static const String createPaymentIntentUrl = '$baseUrl/create-payment-intent';
  static const String createSubscriptionUrl = '$baseUrl/create-subscription';
  
  // Test card numbers for sandbox
  static const Map<String, String> testCards = {
    'success': '4242 4242 4242 4242',
    'declined': '4000 0000 0000 0002',
    'requires_auth': '4000 0025 0000 3155',
  };
}