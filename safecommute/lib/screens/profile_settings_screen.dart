import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationSharing = true;
  bool _offlineMode = false;
  bool _biometricLogin = false;
  String _selectedLanguage = 'English';
  String _safetyPreference = 'Balanced';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile & Settings'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveSettings)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'John Doe',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'john.doe@example.com',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Safety Score', '4.8', Icons.shield),
                      _buildStatCard('Reports', '12', Icons.report),
                      _buildStatCard('Routes', '45', Icons.route),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Safety Preferences
            _buildSectionCard(
              title: 'Safety Preferences',
              children: [
                _buildDropdownTile(
                  title: 'Route Preference',
                  value: _safetyPreference,
                  items: ['Safest', 'Balanced', 'Fastest'],
                  onChanged: (value) {
                    setState(() {
                      _safetyPreference = value!;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Location Sharing',
                  subtitle: 'Share location with emergency contacts',
                  value: _locationSharing,
                  onChanged: (value) {
                    setState(() {
                      _locationSharing = value;
                    });
                  },
                ),
                _buildListTile(
                  title: 'Emergency Contacts',
                  subtitle: '3 contacts configured',
                  icon: Icons.contact_emergency,
                  onTap: () => _showEmergencyContacts(),
                ),
              ],
            ),

            SizedBox(height: 16),

            // App Settings
            _buildSectionCard(
              title: 'App Settings',
              children: [
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Receive safety alerts and updates',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Offline Mode',
                  subtitle: 'Use cached data when offline',
                  value: _offlineMode,
                  onChanged: (value) {
                    setState(() {
                      _offlineMode = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint or face ID',
                  value: _biometricLogin,
                  onChanged: (value) {
                    setState(() {
                      _biometricLogin = value;
                    });
                  },
                ),
                _buildDropdownTile(
                  title: 'Language',
                  value: _selectedLanguage,
                  items: ['English', 'Afrikaans', 'Zulu', 'Xhosa'],
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 16),

            // Privacy & Security
            _buildSectionCard(
              title: 'Privacy & Security',
              children: [
                _buildListTile(
                  title: 'Data Usage',
                  subtitle: 'Manage app data consumption',
                  icon: Icons.data_usage,
                  onTap: () => _showDataUsage(),
                ),
                _buildListTile(
                  title: 'Privacy Settings',
                  subtitle: 'Control data sharing',
                  icon: Icons.privacy_tip,
                  onTap: () => _showPrivacySettings(),
                ),
                _buildListTile(
                  title: 'Security',
                  subtitle: 'Change password and 2FA',
                  icon: Icons.security,
                  onTap: () => _showSecuritySettings(),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Support & Help
            _buildSectionCard(
              title: 'Support & Help',
              children: [
                _buildListTile(
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  icon: Icons.help_center,
                  onTap: () => _showHelpCenter(),
                ),
                _buildListTile(
                  title: 'Contact Support',
                  subtitle: 'Get in touch with our team',
                  icon: Icons.support_agent,
                  onTap: () => _contactSupport(),
                ),
                _buildListTile(
                  title: 'Report App Issues',
                  subtitle: 'Report bugs and issues',
                  icon: Icons.bug_report,
                  onTap: () => _reportIssue(),
                ),
                _buildListTile(
                  title: 'Safety Tips',
                  subtitle: 'Learn about staying safe',
                  icon: Icons.lightbulb,
                  onTap: () => _showSafetyTips(),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Account Management
            _buildSectionCard(
              title: 'Account',
              children: [
                _buildListTile(
                  title: 'Backup & Sync',
                  subtitle: 'Manage data backup',
                  icon: Icons.backup,
                  onTap: () => _showBackupSettings(),
                ),
                _buildListTile(
                  title: 'Terms & Privacy Policy',
                  subtitle: 'Read our terms and privacy policy',
                  icon: Icons.description,
                  onTap: () => _showTermsAndPrivacy(),
                ),
                _buildListTile(
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  icon: Icons.logout,
                  onTap: () => _showSignOutDialog(),
                  textColor: AppColors.alertRed,
                ),
                _buildListTile(
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  icon: Icons.delete_forever,
                  onTap: () => _showDeleteAccountDialog(),
                  textColor: AppColors.alertRed,
                ),
              ],
            ),

            SizedBox(height: 24),

            // App Version
            Text(
              'SafeCommute v1.0.0',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primaryBlue),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primarySafetyGreen,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: AppColors.primarySafetyGreen,
      ),
    );
  }

  void _showEmergencyContacts() {
    // Navigate to emergency contacts screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Emergency contacts feature coming soon')),
    );
  }

  void _showDataUsage() {
    // Show data usage screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Data usage feature coming soon')));
  }

  void _showPrivacySettings() {
    // Show privacy settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Privacy settings feature coming soon')),
    );
  }

  void _showSecuritySettings() {
    // Show security settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Security settings feature coming soon')),
    );
  }

  void _showHelpCenter() {
    // Show help center
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Help center feature coming soon')));
  }

  void _contactSupport() {
    // Contact support
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Support contact feature coming soon')),
    );
  }

  void _reportIssue() {
    // Report issue
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Issue reporting feature coming soon')),
    );
  }

  void _showSafetyTips() {
    // Show safety tips
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Safety tips feature coming soon')));
  }

  void _showBackupSettings() {
    // Show backup settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup settings feature coming soon')),
    );
  }

  void _showTermsAndPrivacy() {
    // Show terms and privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terms & Privacy feature coming soon')),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/auth',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deletion requested'),
                  backgroundColor: AppColors.alertRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
