import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.title,
    this.targetNodeId,
  });

  final String title;
  final int? targetNodeId;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isConnected = false;
  final List<ChatMessage> _messages = [];
  String deviceIp = ''; // Loaded from SharedPreferences
  String devicePort = ''; // Loaded from SharedPreferences
  Timer? _messagePollTimer;
  int _currentMessageLength = 0;
  final Set<String> _seenChatLines = <String>{};
  bool _initializedChatSnapshot = false;

  @override
  void initState() {
    super.initState();
    // Add a welcome message
    _messages.add(ChatMessage(
      text:
          'Welcome to Meshtastic Chat! Connect to a mesh network to start messaging.',
      sender: 'System',
      timestamp: DateTime.now(),
      isSystem: true,
    ));

    // Load saved connection settings from shared preferences
    _loadConnectionPrefs();

    // Start polling for incoming messages
    _messagePollTimer = Timer.periodic(
      const Duration(milliseconds: 800),
      (_) => _fetchMessages(),
    );
    // And fetch once immediately
    _fetchMessages();
  }

  @override
  void dispose() {
    _messagePollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConnectionPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('device_ip')?.trim();
      final savedPort = prefs.getString('device_port')?.trim();

      if (!mounted) return;

      setState(() {
        // Fallback to sensible defaults if nothing saved yet
        deviceIp =
            (savedIp != null && savedIp.isNotEmpty) ? savedIp : '';
        devicePort =
            (savedPort != null && savedPort.isNotEmpty) ? savedPort : '';
        _isConnected = true;
      });

      // If this chat was opened for a specific node, tell the device which
      // target to use for subsequent /send calls.
      if (widget.targetNodeId != null) {
        await _selectTargetNode(widget.targetNodeId!);
      }
    } catch (e) {
      debugPrint('Failed to load connection prefs: $e');
    }
  }

  Future<void> _selectTargetNode(int id) async {
    try {
      final uri = Uri.parse('http://$deviceIp:$devicePort/select');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'id=$id',
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
    } catch (e) {
      debugPrint('Failed to select target node $id: $e');
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final uri = Uri.parse('http://$deviceIp:$devicePort/chat');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode != 200) return;

      final responseText = response.body.trim();
      if (responseText.isEmpty) return;

      // Expected plain-text format: \"Node X: message text\\n\"
      final lines = responseText
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (lines.isEmpty) return;

      // On first open of the chat screen, treat the existing history as
      // \"cleared\": mark all current lines as seen but don't display them.
      if (!_initializedChatSnapshot) {
        _seenChatLines.addAll(lines);
        _initializedChatSnapshot = true;
        return;
      }

      for (var line in lines) {
        // Skip lines we've already processed in this session.
        if (_seenChatLines.contains(line)) continue;

        final match = RegExp(r'^Node (\d+):\s*(.+)$').firstMatch(line);
        if (match == null) continue;

        final fromNode = match.group(1) ?? '0';
        final text = match.group(2) ?? '';
        if (text.isEmpty) continue;

        setState(() {
          _seenChatLines.add(line);
          _messages.add(
            ChatMessage(
              text: text,
              sender: 'Node $fromNode',
              timestamp: DateTime.now(),
              isSystem: false,
            ),
          );
        });
      }

      _scrollToBottom();
    } catch (e) {
      // Swallow fetch errors to avoid spamming the user
      debugPrint('Failed to fetch messages: $e');
    }
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
          _currentMessageLength = 0;
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
        throw Exception(
            'Server returned: ${response.statusCode} - ${response.body}');
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Column(
        children: [
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // Message input
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type a message…',
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              maxLines: 4,
                              minLines: 1,
                              maxLength: 120,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              onChanged: (value) {
                                setState(() {
                                  _currentMessageLength =
                                      value.length.clamp(0, 120);
                                });
                              },
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Send button
                        SizedBox(
                          height: 44,
                          width: 44,
                          child: ElevatedButton(
                            onPressed: _sendMessage,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                              elevation: 1,
                            ),
                            child: Image.asset(
                              'assets/icons/send.png',
                              width: 22,
                              height: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${_currentMessageLength} / 120',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
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

