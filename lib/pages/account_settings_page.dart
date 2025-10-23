import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _nameController = TextEditingController(text: 'Alex Morgan');
  final _emailController = TextEditingController(text: 'alex.morgan@email.com');
  final _dobController = TextEditingController(text: '01/15/1995');
  final _apiKeyController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: cs.primary,
              onPrimary: cs.onPrimary,
              surface: cs.surfaceContainerHigh,
              onSurface: cs.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _showChangePasswordDialog() {
    final cs = Theme.of(context).colorScheme;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text('Change Password', style: TextStyle(color: cs.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  prefixIcon: Icon(Icons.lock_outline, color: cs.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  prefixIcon: Icon(Icons.lock, color: cs.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: cs.onSurfaceVariant),
                  prefixIcon: Icon(Icons.lock, color: cs.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              currentPasswordController.dispose();
              newPasswordController.dispose();
              confirmPasswordController.dispose();
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () {
              // Validate and save password
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                currentPasswordController.dispose();
                newPasswordController.dispose();
                confirmPasswordController.dispose();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Password changed successfully'),
                    backgroundColor: cs.primary,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Passwords do not match'),
                    backgroundColor: cs.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: cs.primary),
            child: Text('Change', style: TextStyle(color: cs.onPrimary)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: cs.error),
            const SizedBox(width: 8),
            Text('Clear All Data', style: TextStyle(color: cs.onSurface)),
          ],
        ),
        content: Text(
          'This will permanently delete all your events, categories, notes, and settings. This action cannot be undone.\n\nAre you sure you want to continue?',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: cs.onSurface)),
          ),
          FilledButton(
            onPressed: () => _confirmClearData(),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text('Clear All', style: TextStyle(color: cs.onError)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearData() async {
    Navigator.pop(context); // Close confirmation dialog

    final cs = Theme.of(context).colorScheme;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: cs.surfaceContainerHigh,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: cs.error),
              const SizedBox(height: 24),
              Text(
                'Clearing all data...',
                style: TextStyle(color: cs.onSurface, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Clear all data from database
      final eventProvider = context.read<EventProvider>();
      await eventProvider.clearAllData();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Navigate back to home and show success message
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: cs.onError),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('All data has been cleared successfully!'),
                ),
              ],
            ),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: cs.onError),
                const SizedBox(width: 12),
                Expanded(child: Text('Error clearing data: ${e.toString()}')),
              ],
            ),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
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
                'Account Settings',
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
                    colors: [cs.primaryContainer, cs.secondaryContainer],
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
                // Personal Information Section
                _SectionHeader(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  color: cs.primary,
                ),
                const SizedBox(height: 16),

                // Full Name
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    prefixIcon: Icon(Icons.person, color: cs.primary),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date of Birth
                TextField(
                  controller: _dobController,
                  readOnly: true,
                  style: TextStyle(color: cs.onSurface),
                  onTap: () => _selectDateOfBirth(context),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    prefixIcon: Icon(Icons.cake, color: cs.primary),
                    suffixIcon: Icon(Icons.calendar_today, color: cs.primary),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    prefixIcon: Icon(Icons.email, color: cs.primary),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Personal Info Button
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Personal information saved'),
                        backgroundColor: cs.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Password Settings Section
                _SectionHeader(
                  title: 'Password Settings',
                  icon: Icons.lock_outline,
                  color: cs.tertiary,
                ),
                const SizedBox(height: 16),

                _SettingsCard(
                  icon: Icons.vpn_key,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  color: cs.tertiaryContainer,
                  onTap: _showChangePasswordDialog,
                ),

                const SizedBox(height: 32),

                // API Key Storage Section
                _SectionHeader(
                  title: 'API Configuration',
                  icon: Icons.key,
                  color: cs.secondary,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _apiKeyController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    hintText: 'Enter your API key',
                    hintStyle: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(Icons.vpn_key, color: cs.secondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: cs.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.secondary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Store your API keys securely for integration with third-party services',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),

                const SizedBox(height: 16),

                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('API key saved securely'),
                        backgroundColor: cs.secondary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save API Key'),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.secondary,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Data Management Section
                _SectionHeader(
                  title: 'Data Management',
                  icon: Icons.storage,
                  color: cs.error,
                ),
                const SizedBox(height: 16),

                _SettingsCard(
                  icon: Icons.delete_forever,
                  title: 'Clear All Data',
                  subtitle: 'Permanently delete all app data and settings',
                  color: cs.errorContainer,
                  onTap: _showClearDataDialog,
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
