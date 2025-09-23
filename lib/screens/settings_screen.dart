import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/subscription_service.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'firebase_setup_screen.dart';
import 'premium_landing_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoPlay = true;
  bool _highQualityStreaming = false;
  bool _dataSaverMode = false;
  bool _notifications = true;
  String _streamQuality = 'Auto';
  
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }
  
  Future<void> _initializeAndLoad() async {
    // Initialize data service if not already done
    await _dataService.initialize();
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Load other preferences but not showFavoritesOnly since it's now subscription-based
    setState(() {
      // Other preferences can be loaded here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    title: const Text('Theme'),
                    subtitle: Text('Current: ${AppThemes.getThemeName(themeProvider.currentTheme)}'),
                    leading: Icon(AppThemes.getThemeIcon(themeProvider.currentTheme)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeDialog(context, themeProvider),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Playback',
            children: [
              SwitchListTile(
                title: const Text('Auto-play on app launch'),
                subtitle: const Text('Resume last playing station'),
                value: _autoPlay,
                onChanged: (value) {
                  setState(() {
                    _autoPlay = value;
                  });
                },
              ),
              ListTile(
                title: const Text('Stream Quality'),
                subtitle: Text(_streamQuality),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showStreamQualityDialog,
              ),
              SwitchListTile(
                title: const Text('High Quality Streaming'),
                subtitle: const Text('Use highest available bitrate'),
                value: _highQualityStreaming,
                onChanged: (value) {
                  setState(() {
                    _highQualityStreaming = value;
                  });
                },
              ),
            ],
          ),
          Consumer<SubscriptionService>(
            builder: (context, subscriptionService, child) {
              return _buildSection(
                title: 'Subscription',
                children: [
                  ListTile(
                    title: const Text('Premium Status'),
                    subtitle: Text(subscriptionService.statusText),
                    leading: Icon(
                      subscriptionService.hasPremiumFeatures ? Icons.stars : Icons.person,
                      color: subscriptionService.hasPremiumFeatures ? Colors.amber : null,
                    ),
                    trailing: subscriptionService.hasPremiumFeatures 
                      ? null
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PremiumLandingScreen(),
                              ),
                            );
                          },
                          child: const Text('Upgrade'),
                        ),
                  ),
                  if (subscriptionService.isInFreeTrial)
                    ListTile(
                      title: const Text('Free Trial'),
                      subtitle: Text('${subscriptionService.trialDaysRemaining} days remaining'),
                      leading: const Icon(Icons.schedule, color: Colors.orange),
                    ),
                  ListTile(
                    title: const Text('Station Access'),
                    subtitle: Text(_dataService.getStationCountInfo()),
                    leading: Icon(
                      subscriptionService.hasPremiumFeatures ? Icons.public : Icons.radio,
                      color: subscriptionService.hasPremiumFeatures ? Colors.green : Colors.blue,
                    ),
                  ),
                  // EMERGENCY PREMIUM BUTTON - ALWAYS SHOWS
                  ListTile(
                    title: Text(
                      subscriptionService.hasPremiumFeatures 
                        ? '✅ Premium Active' 
                        : '🚀 ACTIVATE PREMIUM NOW'
                    ),
                    subtitle: Text(
                      subscriptionService.hasPremiumFeatures
                        ? 'Access to 35,000+ stations'
                        : 'Tap here to fix station access!'
                    ),
                    leading: Icon(
                      Icons.rocket_launch, 
                      color: subscriptionService.hasPremiumFeatures ? Colors.green : Colors.red,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    tileColor: subscriptionService.hasPremiumFeatures ? null : Colors.red.withOpacity(0.1),
                    onTap: () async {
                      if (!subscriptionService.hasPremiumFeatures) {
                        await subscriptionService.activatePremium();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Premium activated! Restart app to load all stations'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Premium is already active!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  if (kDebugMode) ...[
                    if (!subscriptionService.hasPremiumFeatures)
                      ListTile(
                        title: const Text('Debug: Activate Premium'),
                        subtitle: const Text('Unlock all 35,000+ stations for testing'),
                        leading: const Icon(Icons.rocket_launch, color: Colors.green),
                        onTap: () async {
                          await subscriptionService.activatePremium();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Premium activated! Access to 35,000+ stations'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    if (subscriptionService.hasPremiumFeatures)
                      ListTile(
                        title: const Text('Debug: Deactivate Premium'),
                        subtitle: const Text('Return to free tier (22 stations)'),
                        leading: const Icon(Icons.remove_circle, color: Colors.orange),
                        onTap: () async {
                          await subscriptionService.cancelSubscription();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Premium deactivated! Back to 22 curated stations'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ListTile(
                      title: const Text('Debug: Reset Subscription'),
                      subtitle: const Text('Reset all subscription data (debug only)'),
                      leading: const Icon(Icons.refresh, color: Colors.red),
                      onTap: () async {
                        await subscriptionService.resetSubscriptionForDebug();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Subscription data reset'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
          _buildSection(
            title: 'Data Usage',
            children: [
              SwitchListTile(
                title: const Text('Data Saver Mode'),
                subtitle: const Text('Reduce data usage on mobile networks'),
                value: _dataSaverMode,
                onChanged: (value) {
                  setState(() {
                    _dataSaverMode = value;
                  });
                },
              ),
              ListTile(
                title: const Text('Clear Cache'),
                subtitle: const Text('Free up storage space'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Clear cache
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Show playback controls in notification'),
                value: _notifications,
                onChanged: (value) {
                  setState(() {
                    _notifications = value;
                  });
                },
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Open privacy policy
                },
              ),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Open terms
                },
              ),
              ListTile(
                title: const Text('Rate App'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Open app store
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Firebase',
            children: [
              ListTile(
                title: const Text('Firebase Setup'),
                subtitle: const Text('Initialize Firebase and populate data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FirebaseSetupScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          Consumer<SubscriptionService>(
            builder: (context, subscriptionService, child) {
              return _buildSection(
                title: 'Account',
                children: [
                  if (subscriptionService.hasPremiumFeatures)
                    ListTile(
                      title: const Text('Manage Subscription'),
                      subtitle: const Text('Change or cancel subscription'),
                      leading: const Icon(Icons.manage_accounts),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        // For demo purposes, allow canceling premium
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Manage Subscription'),
                            content: const Text('Cancel premium subscription?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Keep Premium'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        );
                        if (result == true) {
                          await subscriptionService.cancelSubscription();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Subscription canceled'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    )
                  else
                    ListTile(
                      title: const Text('Restore Purchases'),
                      subtitle: const Text('Restore previous subscription'),
                      leading: const Icon(Icons.restore),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final success = await subscriptionService.restorePurchases();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success 
                              ? 'Purchases restored successfully!' 
                              : 'No purchases found to restore'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ListTile(
                    title: const Text('Sign In'),
                    subtitle: const Text('Sync favorites across devices'),
                    leading: const Icon(Icons.login),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Sign in implementation
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themeProvider.availableThemes.map((themeData) {
            final theme = themeData['theme'] as AppTheme;
            final name = themeData['name'] as String;
            final icon = themeData['icon'] as IconData;
            final isSelected = themeData['isSelected'] as bool;
            
            return RadioListTile<AppTheme>(
              title: Text(name),
              subtitle: Text(_getThemeDescription(theme)),
              secondary: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
              value: theme,
              groupValue: themeProvider.currentTheme,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setTheme(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Theme changed to $name'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getThemeDescription(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return 'Perfect for night listening';
      case AppTheme.light:
        return 'Clean and bright interface';
      case AppTheme.pastel:
        return 'Soft and colorful design';
    }
  }

  void _showStreamQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stream Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Auto'),
              subtitle: const Text('Adjust based on connection'),
              value: 'Auto',
              groupValue: _streamQuality,
              onChanged: (value) {
                setState(() {
                  _streamQuality = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('High'),
              subtitle: const Text('Best quality, more data'),
              value: 'High',
              groupValue: _streamQuality,
              onChanged: (value) {
                setState(() {
                  _streamQuality = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Medium'),
              subtitle: const Text('Balanced quality and data'),
              value: 'Medium',
              groupValue: _streamQuality,
              onChanged: (value) {
                setState(() {
                  _streamQuality = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Low'),
              subtitle: const Text('Save data, lower quality'),
              value: 'Low',
              groupValue: _streamQuality,
              onChanged: (value) {
                setState(() {
                  _streamQuality = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}