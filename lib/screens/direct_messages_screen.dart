import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_detail_screen.dart';

class DirectMessagesScreen extends StatefulWidget {
  const DirectMessagesScreen({super.key});

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  late Future<List<_NodeEntry>> _nodesFuture;

  @override
  void initState() {
    super.initState();
    _nodesFuture = _fetchNodes();
  }

  Future<List<_NodeEntry>> _fetchNodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('device_ip')?.trim();
      final savedPort = prefs.getString('device_port')?.trim();

      final ip = (savedIp != null && savedIp.isNotEmpty)
          ? savedIp
          : '';
      final port = (savedPort != null && savedPort.isNotEmpty)
          ? savedPort
          : '';

      final uri = Uri.parse('http://$ip:$port/nodes');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode != 200) {
        return const [];
      }

      final raw = jsonDecode(response.body);
      if (raw is! List) return const [];

      return raw.map<_NodeEntry>((e) {
        final id = e['id'] is int
            ? e['id'] as int
            : int.tryParse('${e['id']}') ?? 0;
        final nickname = (e['nickname'] as String?)?.trim() ?? '';
        final rssi = (e['rssi'] as String?)?.trim() ?? '';
        final displayName = nickname.isNotEmpty ? nickname : 'Node $id';
        return _NodeEntry(id: id, name: displayName, rssi: rssi);
      }).toList();
    } catch (e) {
      debugPrint('Failed to load nodes: $e');
      return const [];
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _nodesFuture = _fetchNodes();
    });
    await _nodesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Messages'),
        elevation: 0,
      ),
      body: FutureBuilder<List<_NodeEntry>>(
        future: _nodesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: Container(
                margin: EdgeInsets.all(20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                  color: theme.colorScheme.surface.withOpacity(0.8),
                ),
                child: const Text(
                  'No nodes found. Please connect to a node to start messaging.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            );
          }

          final nodes = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              itemCount: nodes.length,
              separatorBuilder: (_, __) => const SizedBox.shrink(),
              itemBuilder: (context, index) {
                final node = nodes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text(
                        node.name[0],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    title: Text(
                      node.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      node.rssi.isNotEmpty ? 'RSSI ${node.rssi}' : '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            title: node.name,
                            targetNodeId: node.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NodeEntry {
  const _NodeEntry({
    required this.id,
    required this.name,
    required this.rssi,
  });

  final int id;
  final String name;
  final String rssi;
}

