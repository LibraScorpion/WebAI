import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/settings_provider.dart';
import '../../widgets/common_widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              const _SectionHeader(title: 'Appearance'),
              SettingsTile(
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                trailing: Switch(
                  value: settings.isDarkMode,
                  onChanged: (value) => settings.setDarkMode(value),
                ),
              ),
              SettingsTile(
                title: 'Language',
                subtitle: settings.currentLanguage,
                onTap: () => _showLanguageDialog(context),
              ),
              const _SectionHeader(title: 'Notifications'),
              SettingsTile(
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                trailing: Switch(
                  value: settings.pushNotificationsEnabled,
                  onChanged: (value) => settings.setPushNotifications(value),
                ),
              ),
              SettingsTile(
                title: 'Chat Notifications',
                subtitle: 'Receive chat notifications',
                trailing: Switch(
                  value: settings.chatNotificationsEnabled,
                  onChanged: (value) => settings.setChatNotifications(value),
                ),
              ),
              const _SectionHeader(title: 'Storage'),
              SettingsTile(
                title: 'Clear Chat History',
                subtitle: 'Delete all chat messages',
                onTap: () => _showClearHistoryDialog(context),
              ),
              SettingsTile(
                title: 'Clear Image Cache',
                subtitle: 'Delete cached images',
                onTap: () => _showClearCacheDialog(context),
              ),
              const _SectionHeader(title: 'About'),
              SettingsTile(
                title: 'Version',
                subtitle: settings.appVersion,
              ),
              SettingsTile(
                title: 'Privacy Policy',
                onTap: () => settings.openPrivacyPolicy(),
              ),
              SettingsTile(
                title: 'Terms of Service',
                onTap: () => settings.openTermsOfService(),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final languages = settings.availableLanguages;
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return ListTile(
                title: Text(language),
                onTap: () {
                  settings.setLanguage(language);
                  Navigator.pop(context);
                },
                trailing: language == settings.currentLanguage
                    ? const Icon(Icons.check)
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showClearHistoryDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Chat History'),
          content: const Text(
            'Are you sure you want to clear all chat history? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SettingsProvider>().clearChatHistory();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Image Cache'),
          content: const Text(
            'Are you sure you want to clear the image cache? This will free up storage space.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SettingsProvider>().clearImageCache();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
