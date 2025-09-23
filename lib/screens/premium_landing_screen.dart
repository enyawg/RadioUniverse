import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';

class PremiumLandingScreen extends StatefulWidget {
  final bool showFromFavoriteLimit;
  
  const PremiumLandingScreen({
    super.key,
    this.showFromFavoriteLimit = false,
  });

  @override
  State<PremiumLandingScreen> createState() => _PremiumLandingScreenState();
}

class _PremiumLandingScreenState extends State<PremiumLandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e), // Dark blue like TuneIn
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header with close button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Premium badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Vintage radio image
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'lib/assets/images/landing-radio.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to a radio icon if image not found
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6B35),
                                    const Color(0xFFFF6B35).withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.radio,
                                size: 100,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Main title
                    const Text(
                      'Get Radio Universe Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Features list with checkmarks like TuneIn
                    Consumer<SubscriptionService>(
                      builder: (context, subscriptionService, child) {
                        final benefits = subscriptionService.premiumBenefits;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: benefits.map((benefit) => 
                            _buildBenefitItem(benefit),
                          ).toList(),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Pricing like TuneIn
                    const Text(
                      '7 days free, then \$4.99/month. Cancel anytime!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // CTA Button
                    Consumer<SubscriptionService>(
                      builder: (context, subscriptionService, child) {
                        final hasFeatures = subscriptionService.hasPremiumFeatures;
                        
                        if (!hasFeatures) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleStartFreeTrial,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35), // Orange like TuneIn
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'START YOUR FREE TRIAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.green.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  subscriptionService.statusText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (subscriptionService.isInFreeTrial)
                                  const Text(
                                    'Enjoy your premium features!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Restore purchases button
                    Consumer<SubscriptionService>(
                      builder: (context, subscriptionService, child) {
                        if (!subscriptionService.isPremium) {
                          return TextButton(
                            onPressed: _handleRestorePurchases,
                            child: const Text(
                              'Restore Purchases',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Terms and privacy
                    const Text(
                      'Terms of Service and Privacy Policy',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check,
            color: Color(0xFFFF6B35), // Orange checkmark like TuneIn
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStartFreeTrial() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    try {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      await subscriptionService.startFreeTrial();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 7-day free trial started! Enjoy premium features.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
        
        // Close the premium screen after successful trial start
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting trial: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleRestorePurchases() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    try {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      final success = await subscriptionService.restorePurchases();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? '✅ Purchases restored successfully!' 
              : '❌ No purchases found to restore'),
            duration: const Duration(seconds: 3),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
        
        if (success) {
          // Close the premium screen after successful restore
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring purchases: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}