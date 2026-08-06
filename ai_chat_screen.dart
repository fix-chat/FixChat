import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ChatRole { user, ai }

class ChatMessage {
  final ChatRole role;
  final String text;
  ChatMessage(this.role, this.text);
}

class AiChatScreen extends StatefulWidget {
  final bool startWithVoice;
  final bool startWithImage;

  const AiChatScreen({
    super.key,
    this.startWithVoice = false,
    this.startWithImage = false,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isExecuting = false;
  bool _showFixButton = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      ChatRole.ai,
      'হাই! আমি FixChat 👋\nতোমার সমস্যাটা লিখো, বলো, বা স্ক্রিনশট দাও — আমি বুঝে সমাধান বের করে দেবো।',
    ));
    if (widget.startWithVoice) {
      // TODO: Voice input UI hook করা হবে (speech_to_text প্যাকেজ দিয়ে)
    }
    if (widget.startWithImage) {
      // TODO: Screenshot/Image picker হুক করা হবে (image_picker প্যাকেজ দিয়ে)
    }
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(ChatRole.user, text));
      _controller.clear();
    });
    _scrollToBottom();

    // TODO: এখানে real AI API call বসবে (Gemini/OpenAI)
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          ChatRole.ai,
          'বুঝেছি। এটা সমাধান করতে আমাকে সেটিংস চেক করতে হবে। প্রস্তুত হলে নিচের বাটনে ট্যাপ করো।',
        ));
        _showFixButton = true;
      });
      _scrollToBottom();
    });
  }

  void _startAutoFix() {
    setState(() {
      _showFixButton = false;
      _isExecuting = true;
      _progress = 0.0;
    });

    // Simulated execution progress - real dhaap-e AI execution engine বসবে
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted || !_isExecuting) return false;
      setState(() => _progress += 0.2);
      if (_progress >= 1.0) {
        setState(() {
          _isExecuting = false;
          _messages.add(ChatMessage(
            ChatRole.ai,
            'সমাধান সম্পন্ন হয়েছে ✅ আর কিছু লাগলে বলো।',
          ));
        });
        _scrollToBottom();
        return false;
      }
      return true;
    });
  }

  void _stopExecution() {
    setState(() => _isExecuting = false);
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
      appBar: AppBar(title: const Text('AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _bubble(_messages[index]),
            ),
          ),
          if (_isExecuting) _executionBar(),
          if (_showFixButton) _fixButton(),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _bubble(ChatMessage msg) {
    final isUser = msg.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.dark,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _fixButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _startAutoFix,
          icon: const Icon(Icons.auto_fix_high_rounded),
          label: const Text('Fix Automatically'),
        ),
      ),
    );
  }

  Widget _executionBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              const Text('AI is working...',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${(_progress * 100).clamp(0, 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: _stopExecution,
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: const Text('Stop'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.pause_circle_outline, size: 18),
                label: const Text('Pause'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.pan_tool_outlined, size: 18),
                label: const Text('Take Control'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined),
              color: Colors.grey.shade600,
              onPressed: () {
                // TODO: image_picker দিয়ে screenshot upload
              },
            ),
            IconButton(
              icon: const Icon(Icons.mic_none_rounded),
              color: Colors.grey.shade600,
              onPressed: () {
                // TODO: speech_to_text দিয়ে voice input
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(
                  hintText: 'তোমার সমস্যাটা লিখো...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _sendMessage(),
              icon: const Icon(Icons.arrow_upward_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
