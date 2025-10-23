import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _biometricEnabled = false;
  bool _appLockEnabled = false;
  bool _autoLockEnabled = true;
  String _autoLockDuration = '5 minutes';

  void _showUserAgreementsDialog() {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text('User Agreements', style: TextStyle(color: cs.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AgreementItem(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () {
                  Navigator.pop(context);
                  _showTermsOfService();
                },
              ),
              Divider(color: cs.outlineVariant),
              _AgreementItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.pop(context);
                  _showPrivacyPolicy();
                },
              ),
              Divider(color: cs.outlineVariant),
              _AgreementItem(
                icon: Icons.cookie,
                title: 'Cookie Policy',
                onTap: () {
                  Navigator.pop(context);
                  _showCookiePolicy();
                },
              ),
              Divider(color: cs.outlineVariant),
              _AgreementItem(
                icon: Icons.article,
                title: 'End User License Agreement',
                onTap: () {
                  Navigator.pop(context);
                  _showEULA();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text('Terms of Service', style: TextStyle(color: cs.onSurface)),
        content: SingleChildScrollView(
          child: Text(
            '''Welcome to ScheduleMe!

By using this application, you agree to the following terms and conditions:

1. USER RESPONSIBILITIES
• You are responsible for maintaining the confidentiality of your account
• You must provide accurate and complete information
• You are responsible for all activities under your account

2. DATA USAGE
• We collect and store data necessary for app functionality
• Your data is stored locally on your device
• We do not share your personal information with third parties

3. PROHIBITED ACTIVITIES
• Do not use the app for illegal purposes
• Do not attempt to hack or modify the application
• Do not share inappropriate content

4. INTELLECTUAL PROPERTY
• All content and features are owned by ScheduleMe
• You may not copy, modify, or distribute the app

5. LIMITATION OF LIABILITY
• The app is provided "as is" without warranties
• We are not liable for any damages from app usage

6. MODIFICATIONS
• We reserve the right to modify these terms at any time
• Continued use constitutes acceptance of changes

Last updated: October 2025''',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text('Privacy Policy', style: TextStyle(color: cs.onSurface)),
        content: SingleChildScrollView(
          child: Text(
            '''Privacy Policy for ScheduleMe

This Privacy Policy describes how we collect, use, and protect your information.

1. INFORMATION WE COLLECT
• Personal information (name, email, date of birth)
• Event and scheduling data
• App usage statistics
• Device information

2. HOW WE USE YOUR INFORMATION
• To provide and maintain our services
• To improve app functionality and user experience
• To send notifications and reminders
• To provide customer support

3. DATA STORAGE
• All data is stored locally on your device
• Optional cloud backup (if enabled)
• Encrypted storage for sensitive information

4. DATA SHARING
• We do not sell your personal information
• We do not share data with third parties for marketing
• Data may be shared with service providers for app functionality

5. YOUR RIGHTS
• Access your personal data
• Request data correction or deletion
• Opt-out of data collection (may limit functionality)
• Export your data

6. SECURITY MEASURES
• End-to-end encryption for sensitive data
• Biometric authentication option
• Regular security updates

7. CHILDREN'S PRIVACY
• Our app is not intended for children under 13
• We do not knowingly collect data from children

8. CHANGES TO POLICY
• We may update this policy periodically
• Users will be notified of significant changes

Contact: privacy@scheduleme.app

Last updated: October 2025''',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  void _showCookiePolicy() {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text('Cookie Policy', style: TextStyle(color: cs.onSurface)),
        content: SingleChildScrollView(
          child: Text(
            '''Cookie Policy

This Cookie Policy explains how ScheduleMe uses cookies and similar technologies.

1. WHAT ARE COOKIES?
• Small text files stored on your device
• Help improve app functionality and user experience
• Can be session-based or persistent

2. TYPES OF COOKIES WE USE
• Essential Cookies: Required for basic app functionality
• Performance Cookies: Help us understand app usage
• Preference Cookies: Remember your settings
• Analytics Cookies: Track user interactions

3. HOW WE USE COOKIES
• Maintain user sessions
• Remember user preferences
• Analyze app performance
• Improve user experience

4. MANAGING COOKIES
• You can control cookies through app settings
• Disabling certain cookies may limit functionality
• Clear cookies through device settings

5. THIRD-PARTY COOKIES
• We may use third-party services that set cookies
• These are governed by their respective privacy policies

6. UPDATES
• This policy may be updated periodically
• Check back for changes

For questions, contact: cookies@scheduleme.app

Last updated: October 2025''',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  void _showEULA() {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text(
          'End User License Agreement',
          style: TextStyle(color: cs.onSurface),
        ),
        content: SingleChildScrollView(
          child: Text(
            '''END USER LICENSE AGREEMENT (EULA)

This End User License Agreement ("Agreement") is between you and ScheduleMe.

1. LICENSE GRANT
• We grant you a limited, non-exclusive, non-transferable license
• Use the app for personal, non-commercial purposes
• Subject to terms and conditions herein

2. RESTRICTIONS
• You may not copy or modify the app
• You may not reverse engineer or decompile
• You may not rent, lease, or transfer the app
• You may not remove copyright notices

3. OWNERSHIP
• ScheduleMe retains all rights and ownership
• This is a license, not a sale
• All intellectual property remains with ScheduleMe

4. UPDATES
• We may provide updates and patches
• Updates may be required for continued use
• New features may be subject to additional terms

5. TERMINATION
• This license is effective until terminated
• Terminates automatically if you breach terms
• Upon termination, cease all use and delete app

6. WARRANTY DISCLAIMER
• App is provided "AS IS" without warranty
• No guarantee of uninterrupted or error-free operation
• Use at your own risk

7. LIMITATION OF LIABILITY
• We are not liable for any damages
• Maximum liability limited to amount paid (if any)
• Some jurisdictions may not allow limitations

8. GOVERNING LAW
• Governed by applicable laws
• Disputes resolved through arbitration

9. ENTIRE AGREEMENT
• This agreement constitutes the entire agreement
• Supersedes all prior agreements

By using ScheduleMe, you acknowledge that you have read and agree to this EULA.

Last updated: October 2025''',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  void _showAutoLockDurationDialog() {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text(
          'Auto Lock Duration',
          style: TextStyle(color: cs.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DurationOption(
              title: 'Immediately',
              value: 'Immediately',
              groupValue: _autoLockDuration,
              onChanged: (value) {
                setState(() => _autoLockDuration = value!);
                Navigator.pop(context);
              },
            ),
            _DurationOption(
              title: '1 minute',
              value: '1 minute',
              groupValue: _autoLockDuration,
              onChanged: (value) {
                setState(() => _autoLockDuration = value!);
                Navigator.pop(context);
              },
            ),
            _DurationOption(
              title: '5 minutes',
              value: '5 minutes',
              groupValue: _autoLockDuration,
              onChanged: (value) {
                setState(() => _autoLockDuration = value!);
                Navigator.pop(context);
              },
            ),
            _DurationOption(
              title: '10 minutes',
              value: '10 minutes',
              groupValue: _autoLockDuration,
              onChanged: (value) {
                setState(() => _autoLockDuration = value!);
                Navigator.pop(context);
              },
            ),
            _DurationOption(
              title: '30 minutes',
              value: '30 minutes',
              groupValue: _autoLockDuration,
              onChanged: (value) {
                setState(() => _autoLockDuration = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: cs.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Privacy & Security',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.tertiaryContainer, cs.secondaryContainer],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // User Agreements Section
                _SectionHeader(
                  title: 'User Agreements',
                  icon: Icons.gavel,
                  color: cs.primary,
                ),
                const SizedBox(height: 16),

                _SettingsCard(
                  icon: Icons.description,
                  title: 'Legal Documents',
                  subtitle: 'View terms, policies, and agreements',
                  color: cs.primaryContainer,
                  onTap: _showUserAgreementsDialog,
                ),

                const SizedBox(height: 32),

                // Biometric Security Section
                _SectionHeader(
                  title: 'Biometric Authentication',
                  icon: Icons.fingerprint,
                  color: cs.tertiary,
                ),
                const SizedBox(height: 16),

                Card(
                  color: cs.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.surface.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.fingerprint,
                                size: 28,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enable Biometric',
                                    style: TextStyle(
                                      color: cs.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Use fingerprint or face unlock',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _biometricEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _biometricEnabled = value;
                                  if (value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Biometric authentication enabled',
                                        ),
                                        backgroundColor: cs.tertiary,
                                      ),
                                    );
                                  }
                                });
                              },
                              activeColor: cs.tertiary,
                            ),
                          ],
                        ),
                        if (_biometricEnabled) ...[
                          const SizedBox(height: 16),
                          Divider(color: cs.outlineVariant),
                          const SizedBox(height: 16),
                          Text(
                            'Supported methods on this device:',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.fingerprint,
                                    color: cs.tertiary,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Fingerprint',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(
                                    Icons.face,
                                    color: cs.tertiary,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Face ID',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App Lock Section
                _SectionHeader(
                  title: 'App Lock',
                  icon: Icons.lock,
                  color: cs.secondary,
                ),
                const SizedBox(height: 16),

                Card(
                  color: cs.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.surface.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.lock,
                                size: 28,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enable App Lock',
                                    style: TextStyle(
                                      color: cs.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Require authentication to open app',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _appLockEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _appLockEnabled = value;
                                  if (value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('App lock enabled'),
                                        backgroundColor: cs.secondary,
                                      ),
                                    );
                                  }
                                });
                              },
                              activeColor: cs.secondary,
                            ),
                          ],
                        ),
                        if (_appLockEnabled) ...[
                          const SizedBox(height: 16),
                          Divider(color: cs.outlineVariant),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Auto Lock',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Lock app when inactive',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            value: _autoLockEnabled,
                            onChanged: (value) {
                              setState(() => _autoLockEnabled = value);
                            },
                            activeColor: cs.secondary,
                          ),
                          if (_autoLockEnabled) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _showAutoLockDurationDialog,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Auto Lock After',
                                      style: TextStyle(
                                        color: cs.onSurface,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          _autoLockDuration,
                                          style: TextStyle(
                                            color: cs.secondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Additional Security Options
                _SectionHeader(
                  title: 'Additional Security',
                  icon: Icons.security,
                  color: cs.primary,
                ),
                const SizedBox(height: 16),

                _SettingsCard(
                  icon: Icons.shield,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add an extra layer of security',
                  color: cs.primaryContainer,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Two-factor authentication setup'),
                        backgroundColor: cs.primary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _SettingsCard(
                  icon: Icons.devices,
                  title: 'Trusted Devices',
                  subtitle: 'Manage devices with access to your account',
                  color: cs.secondaryContainer,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Trusted devices management'),
                        backgroundColor: cs.secondary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _SettingsCard(
                  icon: Icons.history,
                  title: 'Login History',
                  subtitle: 'View your recent login activity',
                  color: cs.tertiaryContainer,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Login history'),
                        backgroundColor: cs.tertiary,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 100), // Space for nav bar
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: cs.onSurface),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AgreementItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(
        title,
        style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: cs.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

class _DurationOption extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _DurationOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RadioListTile<String>(
      title: Text(title, style: TextStyle(color: cs.onSurface)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: cs.primary,
    );
  }
}
