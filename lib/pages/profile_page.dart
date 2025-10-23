import 'package:flutter/material.dart';
import 'manage_events_page.dart';
import 'manage_categories_page.dart';
import 'analytics_page_new.dart';
import 'manage_analytics_page.dart';
import 'account_settings_page.dart';
import 'privacy_security_page.dart';
import '../main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Alex Morgan',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primaryContainer,
                          cs.secondaryContainer,
                          cs.tertiaryContainer,
                        ],
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.tertiary.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Profile content
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 60),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile picture with border
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: cs.primary,
                            child: Text(
                              'AM',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // User info
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.surface.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        size: 14,
                                        color: cs.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Premium User',
                                        style: TextStyle(
                                          color: cs.onSurface,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Sections
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Account Section
                _SectionHeader(
                  title: 'Account',
                  icon: Icons.account_circle,
                  color: cs.primary,
                ),
                const SizedBox(height: 12),

                _ProfileCard(
                  icon: Icons.person,
                  title: 'Account',
                  subtitle: 'Manage your personal information and settings',
                  color: cs.primaryContainer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountSettingsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _ProfileCard(
                  icon: Icons.security,
                  title: 'Privacy & Security',
                  subtitle: 'Security settings and user agreements',
                  color: cs.tertiaryContainer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacySecurityPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Management Section
                _SectionHeader(
                  title: 'Management',
                  icon: Icons.settings,
                  color: cs.tertiary,
                ),
                const SizedBox(height: 12),

                _ProfileCard(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  subtitle: 'View detailed insights and statistics',
                  color: cs.primaryContainer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsPageNew(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _ProfileCard(
                  icon: Icons.manage_search,
                  title: 'Manage Analytics',
                  subtitle: 'Filter and manage event analytics',
                  color: cs.tertiaryContainer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageAnalyticsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _ProfileCard(
                  icon: Icons.event,
                  title: 'Event Management',
                  subtitle: 'View, edit, and organize your events',
                  color: cs.secondaryContainer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageEventsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _ProfileCard(
                  icon: Icons.category,
                  title: 'Category Management',
                  subtitle: 'Manage your event categories',
                  color: cs.tertiaryContainer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageCategoriesPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _ProfileCard(
                  icon: Icons.tune,
                  title: 'App Preferences',
                  subtitle: 'Theme, language, and display settings',
                  color: cs.primaryContainer.withOpacity(0.8),
                  onTap: () {
                    _showAppPreferencesDialog(context);
                  },
                ),

                const SizedBox(height: 32),

                // AI Assistant Section
                _SectionHeader(
                  title: 'AI Assistant',
                  icon: Icons.auto_awesome,
                  color: cs.tertiary,
                ),
                const SizedBox(height: 12),

                _ProfileCard(
                  icon: Icons.auto_awesome,
                  title: 'AI Assist',
                  subtitle: 'Get help with scheduling and planning',
                  color: cs.tertiaryContainer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AiAssistScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // App Info Section
                _SectionHeader(
                  title: 'About',
                  icon: Icons.info_outline,
                  color: cs.outline,
                ),
                const SizedBox(height: 12),

                Card(
                  color: cs.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ScheduleMe',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your personal scheduling assistant',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.code,
                              size: 16,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

void _showAppPreferencesDialog(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: cs.surfaceContainerHigh,
      title: Text('App Preferences', style: TextStyle(color: cs.onSurface)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme section
            Text(
              'Appearance',
              style: TextStyle(
                color: cs.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.dark_mode, color: cs.primary),
              title: Text('Dark Mode', style: TextStyle(color: cs.onSurface)),
              subtitle: Text(
                'Currently using Super AMOLED Dark',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: cs.primary,
              ),
            ),
            ListTile(
              leading: Icon(Icons.format_size, color: cs.primary),
              title: Text('Font Size', style: TextStyle(color: cs.onSurface)),
              subtitle: Text(
                'Adjust text size',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Font size adjustment')),
                );
              },
            ),
            Divider(color: cs.outlineVariant),

            // Language section
            const SizedBox(height: 8),
            Text(
              'Language & Region',
              style: TextStyle(
                color: cs.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.language, color: cs.primary),
              title: Text('Language', style: TextStyle(color: cs.onSurface)),
              subtitle: Text(
                'English (US)',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language selection')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: cs.primary),
              title: Text('Date Format', style: TextStyle(color: cs.onSurface)),
              subtitle: Text(
                'DD/MM/YYYY',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Date format selection')),
                );
              },
            ),
            Divider(color: cs.outlineVariant),

            // Display section
            const SizedBox(height: 8),
            Text(
              'Display',
              style: TextStyle(
                color: cs.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: Icon(Icons.animation, color: cs.primary),
              title: Text('Animations', style: TextStyle(color: cs.onSurface)),
              subtitle: Text(
                'Enable smooth transitions',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              value: true,
              onChanged: (value) {},
              activeColor: cs.primary,
            ),
            SwitchListTile(
              secondary: Icon(Icons.compress, color: cs.primary),
              title: Text(
                'Compact View',
                style: TextStyle(color: cs.onSurface),
              ),
              subtitle: Text(
                'Show more items on screen',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              value: false,
              onChanged: (value) {},
              activeColor: cs.primary,
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

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProfileCard({
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
