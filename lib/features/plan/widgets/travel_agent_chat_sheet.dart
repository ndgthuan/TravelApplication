import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/features/plan/viewmodels/activity_plan_view_model.dart';

// Bottom sheet chat với Travel Agent để chỉnh sửa kế hoạch bằng lời nói.
class TravelAgentChatSheet extends StatefulWidget {
  final PlanModel plan;
  final ActivityPlanViewModel viewModel;

  const TravelAgentChatSheet({
    super.key,
    required this.plan,
    required this.viewModel,
  });

  @override
  State<TravelAgentChatSheet> createState() => _TravelAgentChatSheetState();
}

class _TravelAgentChatSheetState extends State<TravelAgentChatSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _scrollToBottom();

    final history = _messages.length > 1
        ? _messages
            .sublist(0, _messages.length - 1)
            .map((m) => {'role': m['role'] as String, 'content': (m['content'] ?? '') as String})
            .toList()
        : <Map<String, String>>[];
    final result = await widget.viewModel.applyAgentEdit(
      text,
      conversationHistory: history,
    );

    if (!mounted) return;
    _handleResult(result);
  }

  void _handleResult(
    ({
      bool success,
      String? error,
      bool isAskUser,
      List<Map<String, dynamic>> choices,
    }) result,
  ) {
    setState(() {
      _isLoading = false;
      if (result.success) {
        _messages.add({
          'role': 'assistant',
          'content': result.error ?? 'plan.agent_update_success'.tr(),
        });
      } else {
        final msg = <String, dynamic>{
          'role': 'assistant',
          'content': result.isAskUser
              ? (result.error ?? '')
              : 'plan.agent_sorry'.tr(),
        };
        if (result.isAskUser && result.choices.isNotEmpty) {
          msg['choices'] = result.choices;
        }
        _messages.add(msg);
      }
    });
    _scrollToBottom();

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'plan.agent_changes_applied'.tr(),
              style: GoogleFonts.beVietnamPro(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFFF6D00),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _sendWithChoice(Map<String, dynamic> choice) async {
    final reply = choice['reply_suggestion'] as String? ?? '';
    final label = choice['label'] as String? ?? reply;
    if (reply.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'content': label});
      _isLoading = true;
    });
    _scrollToBottom();

    final history = _messages
        .sublist(0, _messages.length - 1)
        .map((m) => {'role': m['role'] as String, 'content': m['content'] as String})
        .toList();
    final result = await widget.viewModel.applyAgentEdit(
      reply,
      conversationHistory: history,
    );

    if (!mounted) return;
    _handleResult(result);
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
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'lib/assets/images/chatbot.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'plan.travel_agent'.tr(),
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'plan.agent_hint'.tr(),
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFF6D00),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'general.processing'.tr(),
                          style: GoogleFonts.beVietnamPro(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }
                final m = _messages[i];
                final isUser = m['role'] == 'user';
                final content = m['content']?.toString() ?? '';
                final choices = m['choices'] as List<dynamic>?;
                final hasChoices = choices != null && choices.isNotEmpty && !isUser;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFFF6D00).withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            content,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          if (hasChoices) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                for (final c in choices)
                                  if (c is Map<String, dynamic>)
                                    FilledButton.tonal(
                                      onPressed: _isLoading
                                          ? null
                                          : () => _sendWithChoice(c),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF6D00).withValues(alpha: 0.25),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        c['label']?.toString() ?? 'plan.choose'.tr(),
                                        style: GoogleFonts.beVietnamPro(fontSize: 13),
                                      ),
                                    ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              8,
              8 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isLoading,
                    style: GoogleFonts.beVietnamPro(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'VD: Điểm thứ 2 tôi không thích, đổi thành quán café khác',
                      hintStyle: GoogleFonts.beVietnamPro(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isLoading ? null : _send,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
