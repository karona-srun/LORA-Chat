import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';

class ChannelScreen extends StatelessWidget {
  const ChannelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Channels and Direct Messages List
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.group,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            title: const Text(
              'Channels',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ChannelsListScreen(),
                ),
              );
            },
          ),
          // const Divider(height: 1),
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            title: const Text(
              'Direct Messages',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DirectMessagesScreen(),
                ),
              );
            },
          ),
          // const Divider(height: 1),
          const Spacer(),
          // Info Box
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You can send and receive channel (group chats) and direct messages. From any message you can long press to see available actions like copy, reply, tapback and delete as well as delivery details.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChannelsListScreen extends StatelessWidget {
  const ChannelsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      'Mesh Group',
      'Nearby Nodes',
      'Emergency Channel',
      'Test Channel',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text(
              'Available channels',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _buildChannelTile(
            context,
            name: 'LongFast',
            description: 'Primary channel for long-range communication',
            isActive: true,
          ),
          const Divider(height: 1),
          _buildChannelTile(
            context,
            name: 'LongSlow',
            description: 'Reliable channel with slower data rate',
            isActive: false,
          ),
          const Divider(height: 1),
          _buildChannelTile(
            context,
            name: 'ShortFast',
            description: 'Fast communication for nearby nodes',
            isActive: false,
          ),
          const Divider(height: 1),
          _buildChannelTile(
            context,
            name: 'ShortSlow',
            description: 'Reliable short-range channel',
            isActive: false,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text(
              'Channel Chats',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...chats.asMap().entries.map((entry) {
            final index = entry.key;
            final name = entry.value;
            return Column(
              children: [
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  leading: CircleAvatar(
                    radius: 16,
                    child: Text(
                      name[0],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Last message preview...',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '12:30',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(title: name),
                      ),
                    );
                  },
                ),
                if (index < chats.length - 1) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChannelTile(
    BuildContext context, {
    required String name,
    required String description,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: isActive ? colorScheme.primary : Colors.grey,
        child: Icon(
          Icons.radio,
          size: 18,
          color: isActive ? Colors.white : Colors.grey[300],
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: isActive
          ? Icon(
              Icons.check,
              size: 18,
              color: colorScheme.primary,
            )
          : null,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to $name channel')),
        );
      },
    );
  }
}

class DirectMessagesScreen extends StatelessWidget {
  const DirectMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final directMessages = [
      'Node 1',
      'Node 2',
      'Node 3',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Messages'),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: directMessages.length,
        separatorBuilder: (_, __) => const Divider(height: 0.1),
        itemBuilder: (context, index) {
          final name = directMessages[index];
          return ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            leading: CircleAvatar(
              radius: 16,
              child: Text(
                name[0],
                style: const TextStyle(fontSize: 14),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'Last message preview...',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '12:30',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(title: name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isConnected = false;
  int _nodeCount = 0;
  final List<ChatMessage> _messages = [];
  String deviceIp = '192.168.4.1'; // Default Arduino AP IP
  String devicePort = '80'; // Default HTTP port
  Timer? _messagePollTimer;

  @override
  void initState() {
    super.initState();
    // Add a welcome message
    _messages.add(ChatMessage(
      text: 'Welcome to Meshtastic Chat! Connect to a mesh network to start messaging.',
      sender: 'System',
      timestamp: DateTime.now(),
      isSystem: true,
    ));
  }

  @override
  void dispose() {
    _messagePollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect to a mesh network first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Following Arduino code pattern: POST /send with body m=MESSAGE
    try {
      final uri = Uri.parse('http://$deviceIp:$devicePort/send');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'm=${Uri.encodeComponent(messageText)}',
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      final responseBody = response.body.trim().toUpperCase();
      
      if (response.statusCode == 200 && responseBody == 'OK') {
        // Message sent successfully - add to local messages
        setState(() {
          _messages.add(ChatMessage(
            text: messageText,
            sender: 'You',
            timestamp: DateTime.now(),
            isSystem: false,
          ));
        });

        _messageController.clear();
        _scrollToBottom();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        throw Exception('Server returned: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchMessages() async {
    if (!_isConnected) return;

    try {
      final uri = Uri.parse('http://$deviceIp:$devicePort/chat');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final responseText = response.body.trim();
        if (responseText.isEmpty) return;
        
        // Parse plain text messages (format: "Node X: message text\n")
        final lines = responseText.split('\n').where((line) => line.trim().isNotEmpty).toList();
        
        // Process received messages
        for (var line in lines) {
          line = line.trim();
          if (line.isEmpty) continue;
          
          // Parse format: "Node X: message text"
          final nodeMatch = RegExp(r'^Node (\d+):\s*(.+)$').firstMatch(line);
          if (nodeMatch == null) continue;
          
          final fromNode = nodeMatch.group(1) ?? '0';
          final text = nodeMatch.group(2) ?? '';
          
          // Skip if we've already received this message (check existing messages)
          final isDuplicate = _messages.any((msg) => 
            msg.sender == 'Node $fromNode' && 
            msg.text == text && 
            !msg.isSystem
          );
          
          if (isDuplicate) continue;
          
          // Add new message to list
          setState(() {
            _messages.add(ChatMessage(
              text: text,
              sender: 'Node $fromNode',
              timestamp: DateTime.now(),
              isSystem: false,
            ));
          });
        }
        
        _scrollToBottom();
      }
    } catch (e) {
      // Silently handle errors to avoid spam
      debugPrint('Error fetching messages: $e');
    }
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
      if (_isConnected) {
        _nodeCount = 3; // Simulated node count
        _messages.add(ChatMessage(
          text: 'Connected to mesh network. $_nodeCount nodes available.',
          sender: 'System',
          timestamp: DateTime.now(),
          isSystem: true,
        ));
        // Start polling for messages every 500ms (matching Arduino web UI)
        _messagePollTimer?.cancel();
        _messagePollTimer = Timer.periodic(
          const Duration(milliseconds: 500),
          (_) => _fetchMessages(),
        );
        // Fetch immediately
        _fetchMessages();
      } else {
        _nodeCount = 0;
        _messagePollTimer?.cancel();
        _messagePollTimer = null;
        _messages.add(ChatMessage(
          text: 'Disconnected from mesh network.',
          sender: 'System',
          timestamp: DateTime.now(),
          isSystem: true,
        ));
      }
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
                _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            onPressed: _toggleConnection,
            tooltip: _isConnected ? 'Disconnect' : 'Connect',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'nodes',
                child: Row(
                  children: [
                    Icon(Icons.devices, size: 20),
                    SizedBox(width: 8),
                    Text('View Nodes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'location',
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 20),
                    SizedBox(width: 8),
                    Text('Share Location'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: _isConnected
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected
                      ? 'Connected • $_nodeCount nodes in mesh'
                      : 'Not Connected • Tap Bluetooth icon to connect',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: _messages[index]);
                    },
                  ),
          ),
          // Message Input
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        minimumSize: const Size(48, 48),
                      ),  
                        child: Image.asset(
                          'assets/icons/send.png',
                          width: 28,
                          height: 28,
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}