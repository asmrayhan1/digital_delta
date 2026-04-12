import 'dart:async';
import 'package:digital_delta/core/services/mesh_service.dart';
import 'package:flutter/material.dart';

/// Mesh Chat Screen — Send and receive E2E encrypted messages via mesh relay
class MeshChatScreen extends StatefulWidget {
  final MeshSyncManager meshManager;

  const MeshChatScreen({super.key, required this.meshManager});

  @override
  State<MeshChatScreen> createState() => _MeshChatScreenState();
}

class _MeshChatScreenState extends State<MeshChatScreen> {
  MeshSyncManager get _mesh => widget.meshManager;
  final _msgController = TextEditingController();
  final _destController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  late StreamSubscription _msgSub;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _msgSub = _mesh.messageStream.listen((_) => _loadMessages());
  }

  Future<void> _loadMessages() async {
    final msgs = await _mesh.getMessages();
    if (mounted) {
      setState(() => _messages = msgs);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgSub.cancel();
    _msgController.dispose();
    _destController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    final dest = _destController.text.trim();
    if (text.isEmpty || dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both destination and message')),
      );
      return;
    }

    await _mesh.sendMessage(dest, text);
    _msgController.clear();
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text('Mesh Chat'),
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        actions: [
          // Peer count indicator
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2EC4B6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${_mesh.connectedPeers.length} peers',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Destination ID input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: TextField(
              controller: _destController,
              decoration: InputDecoration(
                hintText: 'Recipient User ID',
                prefixIcon: const Icon(Icons.person_search, size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const Divider(height: 1),

          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.forum_outlined,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No messages yet.',
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('Messages are E2E encrypted\nand relayed through the mesh.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isMine = msg['sender_id'] == _mesh.userId;
                      return _chatBubble(
                        text: msg['content'] as String? ?? '',
                        senderId: msg['sender_id'] as String? ?? '?',
                        timestamp: msg['timestamp'] as int? ?? 0,
                        isMine: isMine,
                      );
                    },
                  ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2EC4B6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
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

  Widget _chatBubble({
    required String text,
    required String senderId,
    required int timestamp,
    required bool isMine,
  }) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFF0B1F33) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(
                senderId.length > 12
                    ? '${senderId.substring(0, 12)}...'
                    : senderId,
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2EC4B6),
                    fontWeight: FontWeight.bold),
              ),
            if (!isMine) const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                  color: isMine ? Colors.white : Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock,
                    size: 10,
                    color: isMine ? Colors.white38 : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                      fontSize: 10,
                      color: isMine ? Colors.white38 : Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
