import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isConnected = false;
  bool _notificationsEnabled = true;
  bool _locationSharingEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // Connection section
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: Text(
              'Connection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile.adaptive(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text('Mesh Network'),
            subtitle: Text(
              _isConnected ? 'Connected' : 'Disconnected',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: _isConnected,
            onChanged: (value) {
              setState(() {
                _isConnected = value;
              });
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.bluetooth, size: 20),
            title: const Text('Bluetooth Settings'),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bluetooth settings')),
              );
            },
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.devices, size: 20),
            title: const Text('View Nodes'),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View nodes')),
              );
            },
          ),
          const Divider(height: 24),
          // Preferences section
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile.adaptive(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text('Notifications'),
            subtitle: const Text(
              'Receive message notifications',
              style: TextStyle(fontSize: 12),
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
            title: const Text('Location Sharing'),
            subtitle: const Text(
              'Share your location with mesh network',
              style: TextStyle(fontSize: 12),
            ),
            value: _locationSharingEnabled,
            onChanged: (value) {
              setState(() {
                _locationSharingEnabled = value;
              });
            },
          ),
          const Divider(height: 24),
          // About section
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.info, size: 20),
            title: const Text('App Version'),
            subtitle: const Text(
              '1.0.0',
              style: TextStyle(fontSize: 12),
            ),
          ),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.help, size: 20),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support')),
              );
            },
          ),
        ],
      ),
    );
  }
}

