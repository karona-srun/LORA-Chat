import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  Timer? _connectionCheckTimer;

  @override
  void initState() {
    super.initState();
    _refreshSavedConnection();
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 50),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  void _refreshConnectionStatus() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshSavedConnection() async {
    if (!mounted) return;
    setState(() {});
  }

  Future<_StatusInfo?> _fetchStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('device_ip')?.trim();
      final savedPort = prefs.getString('device_port')?.trim();

      final ip = (savedIp != null && savedIp.isNotEmpty) ? savedIp : '';
      final port = (savedPort != null && savedPort.isNotEmpty) ? savedPort : '';

      final uri = Uri.parse('http://$ip:$port/status');
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      if (response.statusCode != 200) return null;

      final raw = jsonDecode(response.body);
      if (raw is! Map) return null;

      return _StatusInfo(
        node: raw['node'] is int
            ? raw['node'] as int
            : int.tryParse('${raw['node']}') ?? 0,
        battery: raw['battery'] is int
            ? raw['battery'] as int
            : int.tryParse('${raw['battery']}') ?? 0,
        rssiCurrent: (raw['rssi_current'] as String?)?.trim() ?? '',
        rssiAverage: raw['rssi_average'] is num
            ? (raw['rssi_average'] as num).toDouble()
            : 0.0,
        role: (raw['role'] as String?)?.trim() ?? '',
      );
    } catch (e) {
      debugPrint('Failed to load status: $e');
      return null;
    }
  }

  Future<void> _clearSavedConnection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_ip');
    await prefs.remove('device_port');

    if (!mounted) return;
    setState(() {});

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Saved connection removed'),
    //   ),
    // );
  }

  void _showConnectionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.wifi, size: 24),
                title: const Text(
                  'Connect via WiFi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Connect to a LoRa device over WiFi network',
                  style: TextStyle(fontSize: 13),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _connectViaWiFi(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.bluetooth, size: 24),
                title: const Text(
                  'Connect via Bluetooth',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Connect to a LoRa device via Bluetooth',
                  style: TextStyle(fontSize: 13),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _connectViaBluetooth(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _connectViaWiFi(BuildContext context) async {
    // Load previously saved IP and port if available
    final prefs = await SharedPreferences.getInstance();
    final ipController = TextEditingController(
      text: prefs.getString('device_ip') ?? '192.168.4.1',
    );
    final portController = TextEditingController(
      text: prefs.getString('device_port') ?? '80',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          title: const Text(
            'Connect via WiFi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ipController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  labelStyle: const TextStyle(fontSize: 13),
                  hintText: '192.168.1.1',
                  hintStyle: const TextStyle(fontSize: 13),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Port',
                  labelStyle: const TextStyle(fontSize: 13),
                  hintText: '4403',
                  hintStyle: const TextStyle(fontSize: 13),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 13),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 13),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: () async {
                final ip = ipController.text.trim();
                final port = portController.text.trim();

                if (ip.isEmpty || port.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter IP address and port'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                await prefs.setString('device_ip', ip);
                await prefs.setString('device_port', port);

                // Refresh saved connection in this screen
                await _refreshSavedConnection();

                if (context.mounted) {
                  Navigator.pop(context);
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text('Saved connection: $ip:$port'),
                  //     backgroundColor: Colors.blue,
                  //   ),
                  // );
                }
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  void _connectViaBluetooth(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scanning for Bluetooth devices...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    // In a real app, you would implement Bluetooth scanning here
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select Bluetooth Device'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.bluetooth),
                      title: const Text('LoRa Device 1'),
                      subtitle: const Text('00:11:22:33:44:55'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connecting to LoRa Device 1...'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.bluetooth),
                      title: const Text('LoRa Device 2'),
                      subtitle: const Text('00:11:22:33:44:56'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connecting to LoRa Device 2...'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('connect')),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
        children: [
          // Connection status card
          Container(
            // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            // decoration: BoxDecoration(
            //   color: colorScheme.surfaceVariant.withOpacity(0.35),
            //   borderRadius: BorderRadius.circular(12),
            // ),
            child: Row(
              children: [
                // Icon(
                //   Icons.link_off,
                //   color: Colors.redAccent,
                //   size: 32,
                // ),
                // const SizedBox(width: 12),
                // const Expanded(
                //   child: Text(
                //     'No device connected',
                //     style: TextStyle(
                //       fontSize: 16,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Radios',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  Icon(Icons.add, color: colorScheme.primary, size: 16),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      _showConnectionOptions(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Manual'),
                  ),
                ],
              ),
            ],
          ),
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final prefs = snapshot.data!;
              final ip = prefs.getString('device_ip')?.trim();
              final port = prefs.getString('device_port')?.trim();

              final hasSavedConnection =
                  ip != null &&
                  ip.isNotEmpty &&
                  port != null &&
                  port.isNotEmpty;

              if (hasSavedConnection) {
                // When we have a saved connection, show live status from /status.
                return FutureBuilder<_StatusInfo?>(
                  future: _fetchStatus(),
                  builder: (context, statusSnap) {
                    final status = statusSnap.data;
                    final isConnected =
                        statusSnap.hasData && status != null;
                    final isLoading = statusSnap.connectionState ==
                        ConnectionState.waiting;
                    if (isLoading && !statusSnap.hasData) {
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary.withOpacity(0.25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                status != null ? 'N${status.node}' : '?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isConnected
                                            ? Icons.check_circle
                                            : Icons.link_off,
                                        size: 16,
                                        color: isConnected
                                            ? Colors.green
                                            : Colors.redAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        status != null
                                            ? 'Node ${status.node}'
                                            : 'Disconnected',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (status != null) ...[
                                    Row(
                                      children: [
                                        const Icon(Icons.router, size: 13),
                                        const SizedBox(width: 5),
                                        Text(
                                          status.role,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.battery_full_outlined,
                                            size: 13),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${status.battery}%',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'RSSI: ${status.rssiCurrent} • Avg ${status.rssiAverage.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: status.rssiAverage
                                                .clamp(0.0, 1.0),
                                            minHeight: 4,
                                            backgroundColor: Colors
                                                .grey.withOpacity(0.2),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    tooltip: 'Refresh connection',
                                    onPressed: _refreshConnectionStatus,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      size: 18,
                                      color: Colors.redAccent,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    tooltip: 'Remove saved connection',
                                    onPressed: _clearSavedConnection,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              // No saved connection yet: show helpful placeholder.
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No radios found nearby',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Turn on your LoRa device or use Manual to add one.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusInfo {
  const _StatusInfo({
    required this.node,
    required this.battery,
    required this.rssiCurrent,
    required this.rssiAverage,
    required this.role,
  });

  final int node;
  final int battery;
  final String rssiCurrent;
  final double rssiAverage;
  final String role;
}
