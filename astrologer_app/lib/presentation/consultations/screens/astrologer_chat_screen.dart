import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/consultation_model.dart';
import '../../../services/api/api_service.dart';

class AstrologerWhatsAppChatScreen extends StatefulWidget {
  final DevoteeConsultationRequest consultation;

  const AstrologerWhatsAppChatScreen({
    super.key,
    required this.consultation,
  });

  @override
  State<AstrologerWhatsAppChatScreen> createState() =>
      _AstrologerWhatsAppChatScreenState();
}

class _AstrologerWhatsAppChatScreenState
    extends State<AstrologerWhatsAppChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _sessionDurationSeconds = 0;
  Timer? _sessionTimer;
  Map<String, String>? _replyingTo;

  // Moderation regexes
  final RegExp _phoneRegex = RegExp(
    r'(?:(?:\+|0{0,2})91[\s.-]*)?[6-9]\d{2}[\s.-]*\d{3}[\s.-]*\d{4}|\b[6-9]\d{9}\b',
  );
  final RegExp _upiRegex = RegExp(
    r'[a-zA-Z0-9.\-_]{2,256}@(oksbi|okhdfcbank|okaxis|paytm|upi|ybl|ibl)\b',
    caseSensitive: false,
  );

  final List<Map<String, dynamic>> _messages = [];
  final Set<String> _prescribedRemedies = {};

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
    _loadInitialMessages();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _sessionDurationSeconds++);
      }
    });
  }

  void _loadInitialMessages() {
    _messages.add({
      'id': 'msg_init_devotee',
      'sender': 'user',
      'text':
          'Pranam Acharya Ji! Here are my details: DOB: ${widget.consultation.birthDob}, Time: ${widget.consultation.birthTime}, Place: ${widget.consultation.birthPlace}. Problem: ${widget.consultation.problemTopic}.',
      'time': _formatCurrentTime(),
      'status': 'read',
      'reaction': null,
      'replyTo': null,
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatSessionTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showModerationAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Safety & Policy Compliance',
              style: TextStyle(fontFamily: 'Headway', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryMaroon),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 12.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Understood', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryMaroon)),
          ),
        ],
      ),
    );
  }

  void _sendMessage({String? customText}) {
    final text = (customText ?? _textController.text).trim();
    if (text.isEmpty) return;

    // Safety checks: Disallow off-platform contact or outside payments
    if (_phoneRegex.hasMatch(text)) {
      _showModerationAlert(
        'Astrologers are strictly prohibited from sharing personal phone numbers or soliciting off-platform contacts. Violations result in immediate account suspension.',
      );
      return;
    }
    if (_upiRegex.hasMatch(text)) {
      _showModerationAlert(
        'Sharing external UPI handles or asking for direct bank transfer is prohibited. All earnings are safely disbursed through Mandirm portal.',
      );
      return;
    }

    final newMsg = {
      'id': 'msg_astro_${DateTime.now().millisecondsSinceEpoch}',
      'sender': 'astrologer',
      'text': text,
      'time': _formatCurrentTime(),
      'status': 'sent',
      'reaction': null,
      'replyTo': _replyingTo != null ? Map<String, String>.from(_replyingTo!) : null,
    };

    setState(() {
      _messages.add(newMsg);
      _textController.clear();
      _replyingTo = null;
    });
    _scrollToBottom();

    final replyMap = newMsg['replyTo'] as Map<String, String>?;
    // Call backend API
    ApiService().sendChatMessage(
      widget.consultation.id,
      message: text,
      senderType: 'astrologer',
      replyToId: replyMap?['id'],
      replyToText: replyMap?['text'],
    ).catchError((err) {
      debugPrint('[AstrologerChat] API error: $err');
      return null;
    });

    // Simulate WhatsApp Double Grey Tick (Delivered)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => newMsg['status'] = 'delivered');
      }
    });

    // Simulate Devotee Reading (Double Blue Tick)
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => newMsg['status'] = 'read');
      }
    });
  }

  void _endConsultation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('End Chat Session?', style: TextStyle(fontFamily: 'Headway', fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'Total Duration: ${_formatSessionTimer(_sessionDurationSeconds)}\nEstimated Dakshina: ₹${((_sessionDurationSeconds / 60) * widget.consultation.perMinuteRate).clamp(widget.consultation.perMinuteRate, 5000).toStringAsFixed(1)}',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Continue Chat', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMaroon,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, {
                'completed': true,
                'duration': _sessionDurationSeconds,
                'earnings': ((_sessionDurationSeconds / 60) * widget.consultation.perMinuteRate).clamp(widget.consultation.perMinuteRate, 5000),
                'prescribed_remedies': _prescribedRemedies.toList(),
              });
            },
            child: Text('Complete Session', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTickIcon(String status) {
    if (status == 'sent') {
      return const Icon(Icons.done, size: 14, color: Color(0xFF8696A0));
    } else if (status == 'delivered') {
      return const Icon(Icons.done_all, size: 14, color: Color(0xFF8696A0));
    } else {
      return const Icon(Icons.done_all, size: 14, color: Color(0xFF53BDEB));
    }
  }

  @override
  Widget build(BuildContext context) {
    final earnings = ((_sessionDurationSeconds / 60) * widget.consultation.perMinuteRate)
        .clamp(widget.consultation.perMinuteRate, 5000)
        .toStringAsFixed(0);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEAE2), // WhatsApp Wallpaper Color
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54), // WhatsApp Classic Green
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFBEBC7),
              child: Text(
                widget.consultation.devoteeName.isNotEmpty
                    ? widget.consultation.devoteeName[0]
                    : 'D',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B1E1E)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.consultation.devoteeName,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_formatSessionTimer(_sessionDurationSeconds)} • ₹$earnings (₹${widget.consultation.perMinuteRate.toInt()}/m)',
                    style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFFD4E7C5)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _endConsultation,
            child: Text(
              'End Chat',
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Devotee Kundli Overview Header (Sacred details without file sharing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFFFFF8E7),
            child: Row(
              children: [
                const Text('📜', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Devotee: ${widget.consultation.devoteeName} | DOB: ${widget.consultation.birthDob} ${widget.consultation.birthTime} | ${widget.consultation.birthPlace}',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF5A4400)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.consultation.problemTopic,
                    style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                final isMe = m['sender'] == 'astrologer';
                final replyTo = m['replyTo'] as Map<String, dynamic>?;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFD9FDD3) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (replyTo != null) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                              border: const Border(
                                left: BorderSide(color: Color(0xFF00A884), width: 3.5),
                              ),
                            ),
                            child: Text(
                              replyTo['text'] ?? '',
                              style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF555555)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        Text(
                          m['text'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF111B21), height: 1.35),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Spacer(),
                            Text(
                              m['time'] ?? '',
                              style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFF667781)),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              _buildTickIcon(m['status'] ?? 'sent'),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Astrologer Quick Remedy Prescription Chips (Devotional alternative to file sharing)
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ActionChip(
                  avatar: const Text('📿', style: TextStyle(fontSize: 14)),
                  label: Text('Prescribe 5-Mukhi Rudraksha', style: GoogleFonts.poppins(fontSize: 11)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD4E7C5)),
                  onPressed: () {
                    _prescribedRemedies.add('5-Mukhi Rudraksha');
                    _sendMessage(
                      customText: '✨ Remedy Prescribed: Wear a certified 5-Mukhi Rudraksha on Monday after energizing with "Om Namah Shivaya" mantra for mental peace and clarity.',
                    );
                  },
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Text('🕉️', style: TextStyle(fontSize: 14)),
                  label: Text('Prescribe Gayatri Mantra', style: GoogleFonts.poppins(fontSize: 11)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD4E7C5)),
                  onPressed: () {
                    _prescribedRemedies.add('Gayatri Mantra Jaap');
                    _sendMessage(
                      customText: '✨ Remedy Prescribed: Chant the Gayatri Mantra 108 times during Brahma Muhurta daily to dispel negative planetary influences.',
                    );
                  },
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Text('🟡', style: TextStyle(fontSize: 14)),
                  label: Text('Offer Surya Arghya', style: GoogleFonts.poppins(fontSize: 11)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD4E7C5)),
                  onPressed: () {
                    _prescribedRemedies.add('Surya Arghya');
                    _sendMessage(
                      customText: '✨ Remedy Prescribed: Offer copper-vessel water to Lord Surya at sunrise on Sundays mixed with red sandalwood and akshat.',
                    );
                  },
                ),
              ],
            ),
          ),

          // WhatsApp Bottom Input Bar (STRICTLY NO FILE SHARING)
          Container(
            padding: EdgeInsets.fromLTRB(
              10,
              6,
              10,
              MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            color: const Color(0xFFEFEAE2),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Text('🧘‍♂️', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Type guidance to devotee...',
                              hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF8696A0)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        // No file attachment icon
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A884), // WhatsApp Emerald Send Button
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
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
