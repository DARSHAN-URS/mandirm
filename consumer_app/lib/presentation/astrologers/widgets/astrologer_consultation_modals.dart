import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/devotee_data_service.dart';

/// Realistic Live Consultation Call Dialog
class LiveConsultationCallDialog extends StatefulWidget {
  final Map<String, dynamic> astrologer;
  final bool isVideo;
  final VoidCallback onFinished;

  const LiveConsultationCallDialog({
    super.key,
    required this.astrologer,
    required this.isVideo,
    required this.onFinished,
  });

  @override
  State<LiveConsultationCallDialog> createState() =>
      _LiveConsultationCallDialogState();
}

class _LiveConsultationCallDialogState
    extends State<LiveConsultationCallDialog> {
  bool _isConnected = false;
  int _seconds = 0;
  Timer? _timer;
  bool _isMuted = false;
  bool _isSpeaker = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isConnected = true);
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _endCall() {
    _timer?.cancel();
    final mins = (_seconds / 60.0).ceil();
    final rate = (widget.astrologer['priceNumeric'] as int? ?? 22);
    final totalCost = (mins * rate).clamp(rate, 500);

    final consultation = {
      'id': 'CNS-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'astrologerName': widget.astrologer['name'],
      'specialty': widget.astrologer['specialties'] ?? widget.astrologer['specialty'] ?? 'Vedic Astrology',
      'date': 'Just now',
      'duration': '$mins mins',
      'amount': '₹ $totalCost',
      'remedy':
          'Daily Gayatri Japa (21x), offer water to Sun in copper vessel every morning for Surya peace.',
      'rating': 5.0,
    };

    DevoteeDataService().addConsultation(consultation);

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('Consultation Complete',
                style: GoogleFonts.cinzel(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session with ${widget.astrologer['name']}',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text('Duration: $mins mins • Total Fee: ₹$totalCost',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF7A0C16),
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFFBEBC7),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prescribed Vedic Remedies:',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF78350F))),
                  const SizedBox(height: 4),
                  Text(
                    '• Daily Gayatri Japa 21 times at sunrise\n• Offer Arghya to Lord Surya in copper vessel\n• Wear 5-Mukhi Rudraksha on Monday',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1E1E),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onFinished();
            },
            child: const Text('View in Consultation History',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1528),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Portrait Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: widget.astrologer['imageAsset'] != null
                  ? Image.asset(
                      widget.astrologer['imageAsset'] as String,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFFBEBC7),
                        child: Text('🧘‍♂️', style: TextStyle(fontSize: 36)),
                      ),
                    )
                  : const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFFBEBC7),
                      child: Text('🧘‍♂️', style: TextStyle(fontSize: 36)),
                    ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.astrologer['name'] as String,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              widget.astrologer['specialties'] as String? ??
                  widget.astrologer['specialty'] as String? ??
                  'Vedic Jyotish Acharya',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.amber.shade200),
            ),
            const SizedBox(height: 16),

            // Connection state & timer
            if (!_isConnected) ...[
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.amber.shade200, strokeWidth: 2),
              ),
              const SizedBox(height: 10),
              Text(
                'Connecting with Acharya Ji...',
                style:
                    GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
            ] else ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: Text(
                  'Connected • $_formattedTime',
                  style: GoogleFonts.poppins(
                    color: Colors.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_stories,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Acharya is analyzing your Kundali & Nakshatra',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(_isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white),
                  onPressed: () => setState(() => _isMuted = !_isMuted),
                ),
                IconButton(
                  icon: Icon(_isSpeaker ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white),
                  onPressed: () => setState(() => _isSpeaker = !_isSpeaker),
                ),
                FloatingActionButton(
                  backgroundColor: const Color(0xFFDC2626),
                  onPressed: _endCall,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Live Interactive Chat Modal
class LiveChatModal extends StatefulWidget {
  final Map<String, dynamic> astrologer;
  final VoidCallback onFinished;

  const LiveChatModal({
    super.key,
    required this.astrologer,
    required this.onFinished,
  });

  @override
  State<LiveChatModal> createState() => _LiveChatModalState();
}

class _LiveChatModalState extends State<LiveChatModal> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  late final List<Map<String, String>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'sender': 'astrologer',
        'text':
            'Pranam! I am ${widget.astrologer['name']}. Please share your Date of Birth, Time, and place for personalized Vedic guidance.',
      },
    ];
  }

  @override
  void dispose() {
    _msgController.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _msgController.clear();
    });

    _chatScroll.animateTo(
      _chatScroll.position.maxScrollExtent + 60,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Simulated Astrologer Response
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'astrologer',
            'text':
                'Blessed soul, your current planetary transit of Jupiter is very auspicious. For lasting peace and prosperity, chant the Gayatri Mantra daily and offer arghya to Surya Dev.',
          });
        });

        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEDE4D4))),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.astrologer['imageAsset'] != null
                      ? Image.asset(
                          widget.astrologer['imageAsset'] as String,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFFBEBC7),
                          child: Text('🧘‍♂️', style: TextStyle(fontSize: 20)),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.astrologer['name'] as String,
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Online • Free First Chat',
                            style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                color: const Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _chatScroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                final isMe = m['sender'] == 'user';

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF8B1E1E)
                          : const Color(0xFFF4ECE4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      m['text']!,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: isMe ? Colors.white : const Color(0xFF231E1B),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEDE4D4))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type your question to Acharya Ji...',
                      hintStyle: GoogleFonts.poppins(fontSize: 12.5),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5DDD0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF8B1E1E),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                    onPressed: _sendMessage,
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

/// Gift Offering Dialog to Acharya
class GiftOfferingDialog extends StatelessWidget {
  final Map<String, dynamic> astrologer;

  const GiftOfferingDialog({super.key, required this.astrologer});

  @override
  Widget build(BuildContext context) {
    final gifts = [
      {'name': 'Holy Tulsi Mala', 'price': '₹ 51', 'icon': '📿'},
      {'name': 'Saffron Prasad', 'price': '₹ 101', 'icon': '🍬'},
      {'name': 'Golden Bell Seva', 'price': '₹ 251', 'icon': '🔔'},
      {'name': 'Gurudakshina', 'price': '₹ 501', 'icon': '🪙'},
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            'Gift to Acharya',
            style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offer your heartfelt gratitude & blessings to ${astrologer['name']}',
            style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF5A4E46)),
          ),
          const SizedBox(height: 14),
          ...gifts.map((g) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEDE4D4)),
                ),
                child: Row(
                  children: [
                    Text(g['icon']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        g['name']!,
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      g['price']!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7A0C16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1E1E),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Offered ${g['name']} to ${astrologer['name']} with blessings! 🙏',
                            ),
                            backgroundColor: const Color(0xFF8B1E1E),
                          ),
                        );
                      },
                      child: const Text('Send', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
