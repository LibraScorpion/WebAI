import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../state/settings_provider.dart';
import '../../services/auth/secure_storage_service.dart';
import 'custom_dialog.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Drawer(
      child: Column(
        children: [
          _buildHeader(context, authProvider),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.chat,
                  title: 'Chat',
                  onTap: () => _navigateToPage(context, '/chat'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.image,
                  title: 'Image Generation',
                  onTap: () => _navigateToPage(context, '/image-generation'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: 'History',
                  onTap: () => _navigateToPage(context, '/history'),
                ),
                const Divider(),
                _buildThemeSwitch(context, settingsProvider),
                _buildNotificationSwitch(context, settingsProvider),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () => _navigateToPage(context, '/settings'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () => _navigateToPage(context, '/help'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info,
                  title: 'About',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => _handleLogout(context, authProvider),
                ),
              ],
            ),
          ),
          _buildVersion(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.person),
      ),
      accountName: Text(authProvider.user?.name ?? 'Guest'),
      accountEmail: Text(authProvider.user?.email ?? ''),
      onDetailsPressed: () => _navigateToPage(context, '/profile'),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  Widget _buildThemeSwitch(BuildContext context, SettingsProvider settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.brightness_6),
      title: const Text('Dark Theme'),
      value: settings.isDarkMode,
      onChanged: (value) => settings.setDarkMode(value),
    );
  }

  Widget _buildNotificationSwitch(BuildContext context, SettingsProvider settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications),
      title: const Text('Notifications'),
      value: settings.notificationsEnabled,
      onChanged: (value) => settings.setNotificationsEnabled(value),
    );
  }

  Widget _buildVersion() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Version 1.0.0',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await CustomDialog.showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
    );

    if (confirmed ?? false) {
      final secureStorage = SecureStorageService();
      await secureStorage.deleteAuthToken();
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Future<void> _showAboutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'WebAI Mobile',
        applicationVersion: '1.0.0',
        applicationIcon: const FlutterLogo(size: 48),
        children: [
          const Text(
            'WebAI Mobile is a powerful AI assistant that helps you with various tasks including chat, image generation, and more.',
          ),
        ],
      ),
    );
  }
}
