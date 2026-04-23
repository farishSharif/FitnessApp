import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _quickReplies = [
    '💪 Bench press tips',
    '🥗 Protein intake',
    '😴 Recovery advice',
    '🏃 Cardio tips',
    '🔥 Motivation boost',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final provider = context.read<WorkoutProvider>();
    _controller.clear();

    provider.addChatMessage(text.trim(), true);
    _scrollToBottom();

    setState(() => _isTyping = true);

    // Simulate AI thinking
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    final response = provider.generateCoachResponse(text.trim());
    provider.addChatMessage(response, false);
    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Coach',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Always here for you',
                            style: TextStyle(color: Color(0xFF808080), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF2A2A2A), height: 1),

            // Messages list
            Expanded(
              child: Consumer<WorkoutProvider>(
                builder: (context, provider, _) {
                  final messages = provider.chatMessages;
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      final msg = messages[index];
                      return _buildMessageBubble(msg);
                    },
                  );
                },
              ),
            ),

            // Quick replies
            if (!_isTyping)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickReplies.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _sendMessage(_quickReplies[index]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Text(
                          _quickReplies[index],
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            // Input bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        maxLines: null,
                        onSubmitted: _sendMessage,
                        decoration: const InputDecoration(
                          hintText: 'Ask your coach...',
                          hintStyle: TextStyle(color: Color(0xFF606060)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.white : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                  color: isUser ? Colors.black : Colors.white,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4ADE80), Color(0xFF22C55E)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true, period: Duration(milliseconds: 800 + i * 150));
    });
    _animations = _controllers.map((c) => Tween(begin: 0.3, end: 1.0).animate(c)).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
          child: AnimatedBuilder(
            animation: _animations[i],
            builder: (_, __) => Opacity(
              opacity: _animations[i].value,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
