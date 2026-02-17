import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onThemeChanged,
    this.onLanguageChanged,
  });

  final void Function(bool dark)? onThemeChanged;
  final void Function(bool isKhmer)? onLanguageChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = false;
  bool _isKhmer = false; // false = English, true = Khmer
  bool _notificationsEnabled = true;
  bool _locationSharingEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _loadLocalePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('dark_mode');
    if (dark != null && mounted) {
      setState(() => _darkModeEnabled = dark);
    }
  }

  Future<void> _loadLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null && mounted) {
      setState(() => _isKhmer = code == 'km');
    }
  }

  Future<void> _setTheme(bool dark) async {
    setState(() => _darkModeEnabled = dark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', dark);
    widget.onThemeChanged?.call(dark);
  }

  Future<void> _setLanguage(bool isKhmer) async {
    setState(() => _isKhmer = isKhmer);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', isKhmer ? 'km' : 'en');
    widget.onLanguageChanged?.call(isKhmer);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('settings')),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: Text(
              l10n.tr('appearance'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile.adaptive(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(l10n.tr('changeThemes')),
            subtitle: Text(
              _darkModeEnabled ? l10n.tr('darkMode') : l10n.tr('lightMode'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: _darkModeEnabled,
            onChanged: (value) => _setTheme(value),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: Text(
              l10n.tr('languages'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile.adaptive(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(l10n.tr('changeLanguages')),
            subtitle: Text(
              _isKhmer ? l10n.tr('khmer') : l10n.tr('english'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: _isKhmer,
            onChanged: (value) => _setLanguage(value),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: Text(
              l10n.tr('preferences'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile.adaptive(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(l10n.tr('notifications')),
            subtitle: Text(
              l10n.tr('notificationsSubtitle'),
              style: const TextStyle(fontSize: 12),
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile.adaptive(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(l10n.tr('locationSharing')),
            subtitle: Text(
              l10n.tr('locationSharingSubtitle'),
              style: const TextStyle(fontSize: 12),
            ),
            value: _locationSharingEnabled,
            onChanged: (value) {
              setState(() {
                _locationSharingEnabled = value;
              });
            },
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: Text(
              l10n.tr('about'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.info, size: 20),
            title: Text(l10n.tr('appVersion')),
            subtitle: const Text(
              '1.0.0',
              style: TextStyle(fontSize: 12),
            ),
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.help, size: 20),
            title: Text(l10n.tr('helpSupport')),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.tr('helpSupport'))),
              );
            },
          ),
        ],
      ),
    );
  }
}

