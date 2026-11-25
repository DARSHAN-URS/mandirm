import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../services/devotee_data_service.dart';
import '../../../services/api_service.dart';
import '../../../services/razorpay_service.dart';
import 'devotee_birth_details_sheet.dart';
import '../../../services/razorpay_service.dart';
import '../../../core/l10n/locale_service.dart';
import 'devotee_birth_details_sheet.dart';

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
    final isAi = widget.astrologer['isAi'] == true ||
        widget.astrologer['is_ai'] == 1 ||
        widget.astrologer['is_ai'] == true ||
        widget.astrologer['id']?.toString().startsWith('astro_ai_') == true ||
        widget.astrologer['id'] == 'ast_ai_jyotish' ||
        (widget.astrologer['name']?.toString().toLowerCase().contains('ai') ?? false);

    if (isAi) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This astrologer offers text chat only. Please use the Chat option.'),
              backgroundColor: Color(0xFF7A0C16),
            ),
          );
        }
      });
      return;
    }

    final astroId = widget.astrologer['id']?.toString() ?? 'astro_1';
    final astroName = widget.astrologer['name']?.toString() ?? 'Vedic Acharya';
    ApiService().requestConsultation(
      astrologerId: astroId,
      astrologerName: astroName,
      type: widget.isVideo ? 'video' : 'voice',
      problemTopic: widget.astrologer['specialty']?.toString() ?? 'Vedic Kundli Guidance',
      perMinuteRate: (widget.astrologer['priceNumeric'] as num?)?.toDouble() ?? 25.0,
    );

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

    final rate = (widget.astrologer['priceNumeric'] is num)
        ? (widget.astrologer['priceNumeric'] as num).toInt()
        : int.tryParse(widget.astrologer['priceNumeric']?.toString() ?? '') ?? 15;
    final totalAmount = rate * (mins > 0 ? mins : 1);

    final consultation = {
      'id': 'CNS-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'astrologerName': widget.astrologer['name'],
      'specialty': widget.astrologer['specialties'] ?? widget.astrologer['specialty'] ?? 'Vedic Astrology',
      'date': 'Just now',
      'duration': '$mins mins',
      'amount': '₹$totalAmount',
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
                style: TextStyle(fontFamily: 'Headway', 
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
            Text('Duration: $mins mins • Total: ₹$totalAmount (₹$rate/min)',
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
              style: TextStyle(fontFamily: 'Headway', 
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

/// Live Interactive WhatsApp-Style Consultation Chat Modal (Without File Sharing)
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
  final String _consultationId = 'cons_live_${DateTime.now().millisecondsSinceEpoch}';

  bool _isTyping = false;
  Map<String, String>? _replyingTo;

  // Real-time phone, email & UPI anti-disintermediation regex
  final RegExp _phoneRegex = RegExp(
    r'(?:(?:\+|0{0,2})91[\s.-]*)?[6-9]\d{2}[\s.-]*\d{3}[\s.-]*\d{4}|\b[6-9]\d{9}\b',
  );
  final RegExp _upiRegex = RegExp(
    r'[a-zA-Z0-9.\-_]{2,256}@(oksbi|okhdfcbank|okaxis|paytm|upi|ybl|ibl)\b',
    caseSensitive: false,
  );
  final RegExp _emailRegex = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
  );

  late List<Map<String, dynamic>> _messages;

  // Wallet & Devotee Details state
  Map<String, dynamic>? _devoteeDetails;
  Timer? _billingTimer;
  int _chatDurationSeconds = 0;
  bool _isLowBalance = false;

  double get _perMinuteRate =>
      ((widget.astrologer['per_minute_chat_rate'] ??
        widget.astrologer['priceNumeric'] ??
        20.0) as num).toDouble();

  @override
  void initState() {
    super.initState();
    final astroId = widget.astrologer['id']?.toString() ?? 'astro_1';
    final astroName = widget.astrologer['name']?.toString() ?? 'Vedic Acharya';
    ApiService().requestConsultation(
      astrologerId: astroId,
      astrologerName: astroName,
      type: 'chat',
      problemTopic: 'Vedic Horoscope & Kundli Chat',
      perMinuteRate: _perMinuteRate,
    );

    _messages = [
      {
        'id': 'msg_001',
        'sender': 'astrologer',
        'text':
            'Pranam! I am Acharya ${widget.astrologer['name']}. Please share your birth details (Date, Time, City) or select a quick topic below for divine Vedic guidance.',
        'time': _formatCurrentTime(),
        'status': 'read',
        'reaction': null,
        'replyTo': null,
      },
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDevoteeAndWallet();
    });
  }

  Future<void> _initDevoteeAndWallet() async {
    // 1. Devotee birth details (asked once)
    _devoteeDetails = DevoteeDataService().birthDetails;
    if (_devoteeDetails == null) {
      _devoteeDetails = await DevoteeDataService().loadBirthDetails();
    }

    if (_devoteeDetails != null && mounted) {
      final name = _devoteeDetails!['name'] ?? 'Devotee';
      final dob = _devoteeDetails!['dobFormatted'] ?? _devoteeDetails!['dob'] ?? '';
      final pob = _devoteeDetails!['pob'] ?? '';
      final concern = _devoteeDetails!['concern'] ?? 'Horoscope';
      final isHi = LocaleService().isHindi;

      setState(() {
        _messages[0]['text'] = isHi
            ? 'प्रणाम $name जी! 🙏 मैं आचार्य ${widget.astrologer['name']} हूँ। मुझे आपका जन्म विवरण प्राप्त हो गया है ($dob, $pob)। आपके $concern से संबंधित प्रश्न का वैदिक विश्लेषण करने के लिए प्रस्तुत हूँ।'
            : 'Pranam $name! 🙏 I am Acharya ${widget.astrologer['name']}. I have received your birth details ($dob, $pob). Please ask your questions regarding $concern for divine Vedic guidance.';
      });
    }

    // 2. Refresh Sacred Wallet balance
    await DevoteeDataService().refreshWalletBalance();
    if (!mounted) return;

    final currentBal = DevoteeDataService().walletBalanceNotifier.value;
    if (currentBal < _perMinuteRate) {
      setState(() {
        _isLowBalance = true;
        _messages.add({
          'id': 'msg_init_low',
          'sender': 'system',
          'text': LocaleService().isHindi
              ? '⚠️ अपर्याप्त बैलेंस: इस चैट के लिए न्यूनतम ₹${_perMinuteRate.toInt()} की आवश्यकता है। उपलब्ध बैलेंस: ₹${currentBal.toStringAsFixed(1)}। कृपया चैट शुरू करने हेतु वॉलेट रिचार्ज करें।'
              : '⚠️ Not enough balance: Minimum ₹${_perMinuteRate.toInt()} required for this chat. Current balance: ₹${currentBal.toStringAsFixed(1)}. Please recharge your wallet to continue.',
          'time': _formatCurrentTime(),
          'status': 'read',
        });
      });
      _showRechargeBottomSheet();
    } else {
      _startBillingTimer();
    }
  }

  void _startBillingTimer() {
    _billingTimer?.cancel();
    _billingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      setState(() {
        _chatDurationSeconds++;
      });

      // Real-time per-minute billing deduction
      if (_chatDurationSeconds > 0 && _chatDurationSeconds % 60 == 0) {
        final success = await DevoteeDataService().deductChatMinute(
          amount: _perMinuteRate,
          astrologerName: widget.astrologer['name']?.toString() ?? 'Astrologer',
          consultationId: _consultationId,
        );

        final remaining = DevoteeDataService().walletBalanceNotifier.value;
        if (!success || remaining < _perMinuteRate) {
          _billingTimer?.cancel();
          if (!mounted) return;
          setState(() {
            _isLowBalance = true;
            _messages.add({
              'id': 'msg_low_${DateTime.now().millisecondsSinceEpoch}',
              'sender': 'system',
              'text': LocaleService().isHindi
                  ? '⚠️ वॉलेट बैलेंस समाप्त हो गया है। परामर्श रोक दिया गया है। चैट जारी रखने के लिए कृपया वॉलेट रिचार्ज करें।'
                  : '⚠️ Sacred Wallet balance is exhausted. Chat consultation paused. Please recharge your wallet to continue.',
              'time': _formatCurrentTime(),
              'status': 'read',
            });
          });
          _scrollToBottom();
          _showRechargeBottomSheet();
        }
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _editDevoteeDetails() async {
    final updated = await DevoteeBirthDetailsSheet.show(
      context,
      astrologer: widget.astrologer,
      forceShow: true,
    );
    if (updated != null && mounted) {
      setState(() {
        _devoteeDetails = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleService().isHindi
              ? 'जन्म विवरण सफलतापूर्वक अपडेट किया गया!'
              : 'Birth details updated successfully!'),
          backgroundColor: const Color(0xFF00A884),
        ),
      );
    }
  }

  void _showRechargeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildRechargeSheet(ctx),
    );
  }

  Widget _buildRechargeSheet(BuildContext ctx) {
    final isHi = LocaleService().isHindi;
    final packs = [100.0, 250.0, 500.0, 1000.0];
    double selectedAmount = 250.0;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: const Center(child: Text('🪙', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi
                              ? 'अपर्याप्त वॉलेट बैलेंस • रिचार्ज करें'
                              : 'Low Sacred Wallet Balance',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF991B1B),
                          ),
                        ),
                        Text(
                          isHi
                              ? 'परामर्श दर: ₹${_perMinuteRate.toInt()}/मिनट • न्यूनतम बैलेंस आवश्यक'
                              : 'Rate: ₹${_perMinuteRate.toInt()}/min • Minimum balance required',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF7F1D1D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Current Balance Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5D5C5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHi ? 'वर्तमान वॉलेट बैलेंस:' : 'Current Wallet Balance:',
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF5A4E46)),
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: DevoteeDataService().walletBalanceNotifier,
                      builder: (_, bal, __) => Text(
                        '₹${bal.toStringAsFixed(1)}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF8B1E1E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                isHi ? 'त्वरित रिचार्ज पैक चुनें:' : 'Select Quick Recharge Pack:',
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Row(
                children: packs.map((amt) {
                  final isSelected = selectedAmount == amt;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => setSheetState(() => selectedAmount = amt),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8B1E1E) : const Color(0xFFFBF8F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF8B1E1E) : const Color(0xFFE5D5C5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+₹${amt.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF2D1810),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Recharge Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1E1E),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final result = await RazorpayService().openPayment(
                      amount: selectedAmount,
                      referenceType: 'wallet_recharge',
                      referenceId: 'rech_${DateTime.now().millisecondsSinceEpoch}',
                      title: 'Sacred Wallet Recharge',
                      description: 'Recharge for Astrologer Consultation',
                      isWalletRecharge: true,
                      devoteeName: _devoteeDetails?['name'],
                    );

                    if (result.isSuccess) {
                      await DevoteeDataService().refreshWalletBalance();
                      final newBal = DevoteeDataService().walletBalanceNotifier.value;
                      if (newBal >= _perMinuteRate && mounted) {
                        setState(() {
                          _isLowBalance = false;
                        });
                        _startBillingTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isHi
                                  ? '₹${selectedAmount.toInt()} वॉलेट में जुड़े! परामर्श पुनः प्रारंभ हुआ।'
                                  : '₹${selectedAmount.toInt()} added to Sacred Wallet! Consultation resumed.',
                            ),
                            backgroundColor: const Color(0xFF00A884),
                          ),
                        );
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt, color: Color(0xFFFFD54F), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        isHi
                            ? '₹${selectedAmount.toInt()} का वॉलेट रिचार्ज करें'
                            : 'Recharge ₹${selectedAmount.toInt()} via Razorpay',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  isHi
                      ? '100% सुरक्षित भुगतान • रेज़रपे (UPI / कार्ड / नेटबैंकिंग)'
                      : '100% Secure Payment • Razorpay (UPI / Card / NetBanking)',
                  style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _billingTimer?.cancel();
    _msgController.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showModerationAlert(String reason) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Mandirm Safety Policy',
              style: TextStyle(fontFamily: 'Headway', fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF8B1E1E)),
            ),
          ],
        ),
        content: Text(
          reason,
          style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Understood',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF8B1E1E)),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage({String? customText}) {
    if (_isLowBalance) {
      _showRechargeBottomSheet();
      return;
    }

    final text = (customText ?? _msgController.text).trim();
    if (text.isEmpty) return;

    // 1. Client-Side Real-Time Moderation Interception
    if (_phoneRegex.hasMatch(text)) {
      _showModerationAlert(
        'Sharing personal phone numbers is prohibited in Mandirm consultation chat. All consultations are safely recorded and protected within the app.',
      );
      return;
    }
    if (_upiRegex.hasMatch(text)) {
      _showModerationAlert(
        'Direct UPI payments or external money transfer requests are prohibited. Dakshina and consultations must proceed through secure Mandirm checkout.',
      );
      return;
    }
    if (_emailRegex.hasMatch(text)) {
      _showModerationAlert(
        'Sharing email addresses is disabled to protect devotee privacy and safety.',
      );
      return;
    }

    final newMsg = {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'sender': 'user',
      'text': text,
      'time': _formatCurrentTime(),
      'status': 'sent', // Single grey tick
      'reaction': null,
      'replyTo': _replyingTo != null ? Map<String, String>.from(_replyingTo!) : null,
    };

    setState(() {
      _messages.add(newMsg);
      _msgController.clear();
      _replyingTo = null;
    });
    _scrollToBottom();

    final replyMap = newMsg['replyTo'] as Map<String, String>?;
    // Sync to backend API
    ApiService().sendChatMessage(
      _consultationId,
      message: text,
      replyToId: replyMap?['id'],
      replyToText: replyMap?['text'],
    ).catchError((err) {
      debugPrint('[LiveChat] Backend sync note: $err');
      return null;
    });

    // WhatsApp Double Grey Tick (Delivered) after 600ms
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          newMsg['status'] = 'delivered';
        });
      }
    });

    // WhatsApp "typing..." indicator after 1.2s
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isTyping = true);
      }
    });

    // Astrologer Response & WhatsApp Double Blue Tick (Read)
    Future.delayed(const Duration(milliseconds: 1400), () async {
      if (!mounted) return;

      // Query live AI astrologer service
      String reply = 'Blessed soul, I have examined your request. Your planetary configuration indicates favorable Brihaspati (Jupiter) transit. Continue regular prayers to Lord Shiva and chant the Maha Mrityunjaya mantra.';
      try {
        final history = _messages
            .where((m) => m['sender'] == 'user' || m['sender'] == 'devotee' || m['sender'] == 'astrologer')
            .map((m) => {
                  'role': (m['sender'] == 'user' || m['sender'] == 'devotee') ? 'user' : 'assistant',
                  'text': (m['text'] ?? '').toString(),
                })
            .toList();

        final astroId = widget.astrologer['id']?.toString();
        final res = await ApiService().queryAiJyotish(
          query: text,
          astrologerId: astroId,
          devoteeName: _devoteeDetails?['name']?.toString(),
          dob: (_devoteeDetails?['dobFormatted'] ?? _devoteeDetails?['dob'])?.toString(),
          tob: _devoteeDetails?['tob']?.toString(),
          pob: _devoteeDetails?['pob']?.toString(),
          language: LocaleService().isHindi ? 'hi' : 'en',
          chatHistory: history,
        );
        if (res != null && res['text'] != null && (res['text'] as String).trim().isNotEmpty) {
          reply = res['text'];
        } else if (text.toLowerCase().contains('kundli') || text.toLowerCase().contains('birth')) {
          reply = 'Pranam. I have received your birth details. The Lagna lord is well-placed in the 9th house of Dharma & Fortune. You will experience career elevation in the coming months.';
        } else if (text.toLowerCase().contains('career') || text.toLowerCase().contains('job')) {
          reply = 'For your professional growth, Surya Arghya at sunrise on Sundays and wearing yellow on Thursdays will remove Saturn dasha obstacles.';
        } else if (text.toLowerCase().contains('marriage') || text.toLowerCase().contains('relationship')) {
          reply = 'Venus and Jupiter are aligning harmoniously. Auspicious marriage proposals will arrive within 6 to 9 months.';
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _isTyping = false;
        newMsg['status'] = 'read'; // Double blue tick!

        _messages.add({
          'id': 'msg_astro_${DateTime.now().millisecondsSinceEpoch}',
          'sender': 'astrologer',
          'text': reply,
          'time': _formatCurrentTime(),
          'status': 'read',
          'reaction': null,
          'replyTo': null,
        });
      });
      _scrollToBottom();
    });
  }

  void _showReactionPicker(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['🙏', '🕉️', '❤️', '👍', '🌺', '🚩'].map((emoji) {
            return InkWell(
              onTap: () {
                setState(() {
                  message['reaction'] = message['reaction'] == emoji ? null : emoji;
                });
                Navigator.pop(ctx);
              },
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showReportDialog(Map<String, dynamic> message) {
    String selectedReason = 'Off-platform contact sharing';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Report Message',
            style: TextStyle(fontFamily: 'Headway', fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Help Mandirm maintain a sacred, safe space. Why are you reporting this message?',
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF666666)),
              ),
              const SizedBox(height: 12),
              ...[
                'Off-platform contact sharing',
                'Inappropriate / Abusive language',
                'Soliciting external payment',
                'Other safety concern'
              ].map((reason) {
                return RadioListTile<String>(
                  dense: true,
                  title: Text(reason, style: GoogleFonts.poppins(fontSize: 12)),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedReason = val);
                  },
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                ApiService().reportMessage(
                  _consultationId,
                  message['id'] ?? 'msg_001',
                  reason: selectedReason,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message reported. Our safety team will review it.', style: GoogleFonts.poppins()),
                    backgroundColor: const Color(0xFF8B1E1E),
                  ),
                );
              },
              child: Text('Report', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTickIcon(String status) {
    if (status == 'sent') {
      return const Icon(Icons.done, size: 14, color: Color(0xFF8696A0));
    } else if (status == 'delivered') {
      return const Icon(Icons.done_all, size: 14, color: Color(0xFF8696A0));
    } else {
      // Read: WhatsApp signature blue double ticks
      return const Icon(Icons.done_all, size: 14, color: Color(0xFF53BDEB));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFEFEAE2), // WhatsApp Wallpaper Background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          children: [
            // WhatsApp-Styled App Bar
            Container(
              padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top > 0 ? 8 : 12, 8, 10),
              decoration: const BoxDecoration(
                color: Color(0xFF075E54), // WhatsApp Emerald Green / Temple Maroon
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFFBEBC7),
                    backgroundImage: widget.astrologer['imageAsset'] != null
                        ? AssetImage(widget.astrologer['imageAsset'] as String)
                        : null,
                    child: widget.astrologer['imageAsset'] == null
                        ? const Text('🧘‍♂️', style: TextStyle(fontSize: 18))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.astrologer['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _isTyping ? 'typing...' : 'online',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _isTyping ? const Color(0xFF25D366) : const Color(0xFFD4E7C5),
                            fontStyle: _isTyping ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: DevoteeDataService().walletBalanceNotifier,
                    builder: (ctx, balance, _) {
                      final isLow = balance < _perMinuteRate;
                      return InkWell(
                        onTap: _showRechargeBottomSheet,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLow ? const Color(0xFFDC2626) : const Color(0xFF004D40),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isLow ? const Color(0xFFFCA5A5) : const Color(0xFFFFD54F),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(isLow ? '⚠️' : '🪙', style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Text(
                                '₹${balance.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '• ${_formatDuration(_chatDurationSeconds)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFD4E7C5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (widget.astrologer['isAi'] != true &&
                      widget.astrologer['is_ai'] != 1 &&
                      widget.astrologer['is_ai'] != true &&
                      widget.astrologer['id']?.toString().startsWith('astro_ai_') != true &&
                      widget.astrologer['id'] != 'ast_ai_jyotish' &&
                      !(widget.astrologer['name']?.toString().toLowerCase().contains('ai') ?? false))
                    IconButton(
                      icon: const Icon(Icons.call_outlined, color: Colors.white, size: 20),
                      tooltip: 'Start Voice Call',
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => LiveConsultationCallDialog(
                            astrologer: widget.astrologer,
                            isVideo: false,
                            onFinished: widget.onFinished,
                          ),
                        );
                      },
                    ),
                  ValueListenableBuilder<double>(
                    valueListenable: DevoteeDataService().walletBalanceNotifier,
                    builder: (ctx, balance, _) {
                      final isLow = balance < _perMinuteRate;
                      return InkWell(
                        onTap: _showRechargeBottomSheet,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLow ? const Color(0xFFDC2626) : const Color(0xFF004D40),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isLow ? const Color(0xFFFCA5A5) : const Color(0xFFFFD54F),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(isLow ? '⚠️' : '🪙', style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '₹${balance.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '• ${_formatDuration(_chatDurationSeconds)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFD4E7C5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                    onSelected: (val) {
                      if (val == 'report') {
                        _showReportDialog(_messages.first);
                      } else if (val == 'end') {
                        Navigator.pop(context);
                        widget.onFinished();
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'report',
                        child: Text('Report Astrologer', style: GoogleFonts.poppins(fontSize: 13)),
                      ),
                      PopupMenuItem(
                        value: 'end',
                        child: Text('End Consultation', style: GoogleFonts.poppins(fontSize: 13, color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Devotee Profile Chip (Asked once, editable anytime)
            if (_devoteeDetails != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_devoteeDetails!['name']} • ${_devoteeDetails!['dobFormatted'] ?? _devoteeDetails!['dob']} • ${_devoteeDetails!['pob']}',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF92400E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: _editDevoteeDetails,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          LocaleService().isHindi ? 'बदलें' : 'Edit',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF8B1E1E),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Encrypted Consultation Notice
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082), width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 14, color: Color(0xFFB78103)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔒 Encrypted consultation. Sharing personal contact numbers or external payment handles is disabled for your safety.',
                      style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF7A5800)),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _chatScroll,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  final m = _messages[i];
                  final isMe = m['sender'] == 'user';
                  final replyTo = m['replyTo'] as Map<String, dynamic>?;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: GestureDetector(
                      onLongPress: () => _showReactionPicker(m),
                      onDoubleTap: () {
                        setState(() {
                          _replyingTo = {
                            'id': m['id'] ?? '',
                            'sender': isMe ? 'You' : widget.astrologer['name'],
                            'text': m['text'] ?? '',
                          };
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          // WhatsApp Colors: Devotee (#D9FDD3), Acharya (#FFFFFF)
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
                            // Quoted Reply Preview
                            if (replyTo != null) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border(
                                    left: BorderSide(
                                      color: isMe ? const Color(0xFF00A884) : const Color(0xFF8B1E1E),
                                      width: 3.5,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      replyTo['sender'] ?? 'Participant',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isMe ? const Color(0xFF00A884) : const Color(0xFF8B1E1E),
                                      ),
                                    ),
                                    Text(
                                      replyTo['text'] ?? '',
                                      style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF666666)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Message Text
                            Text(
                              m['text'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF111B21),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Timestamp and WhatsApp Ticks
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Spacer(),
                                Text(
                                  m['time'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    color: const Color(0xFF667781),
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  _buildTickIcon(m['status'] ?? 'sent'),
                                ],
                              ],
                            ),

                            // Emoji Reaction Pill
                            if (m['reaction'] != null) ...[
                              Transform.translate(
                                offset: const Offset(0, 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 2),
                                    ],
                                  ),
                                  child: Text(
                                    m['reaction'] as String,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
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

            // Devotional Quick Action Chips (Devotional Alternative to File Sharing)
            Container(
              height: 38,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  ActionChip(
                    avatar: const Text('🕉️', style: TextStyle(fontSize: 14)),
                    label: Text('Send My Kundli Details', style: GoogleFonts.poppins(fontSize: 11)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFD4E7C5)),
                    onPressed: () {
                      _sendMessage(
                        customText: '🕉️ Kundli Details: Name: Devotee, DOB: 14-Aug-1995, Time: 08:30 AM, Place: Varanasi, Gotra: Kashyapa. Please analyze Dasha & Remedies.',
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    avatar: const Text('🙏', style: TextStyle(fontSize: 14)),
                    label: Text('Pranam Guruji', style: GoogleFonts.poppins(fontSize: 11)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFD4E7C5)),
                    onPressed: () => _sendMessage(customText: '🙏 Pranam Acharya Ji! Seeking your blessings.'),
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    avatar: const Text('✨', style: TextStyle(fontSize: 14)),
                    label: Text('Career Guidance', style: GoogleFonts.poppins(fontSize: 11)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFD4E7C5)),
                    onPressed: () => _sendMessage(customText: 'Acharya Ji, when will my career stabilize and job promotion occur?'),
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    avatar: const Text('💍', style: TextStyle(fontSize: 14)),
                    label: Text('Marriage Yoga', style: GoogleFonts.poppins(fontSize: 11)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFD4E7C5)),
                    onPressed: () => _sendMessage(customText: 'Guruji, please check my Kundli for marriage yoga and partner compatibility.'),
                  ),
                ],
              ),
            ),

            // Quoted Reply Preview Bar
            if (_replyingTo != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 36,
                      color: const Color(0xFF00A884),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replying to ${_replyingTo!['sender']}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00A884),
                            ),
                          ),
                          Text(
                            _replyingTo!['text'] ?? '',
                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF666666)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Color(0xFF8696A0)),
                      onPressed: () => setState(() => _replyingTo = null),
                    ),
                  ],
                ),
              ),
            ],

            // Not Enough Balance Warning Banner (Chat stopped)
            if (_isLowBalance)
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocaleService().isHindi
                                ? 'अपर्याप्त बैलेंस • चैट रोक दी गई है'
                                : 'Not Enough Balance • Chat Stopped',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF991B1B),
                            ),
                          ),
                          Text(
                            LocaleService().isHindi
                                ? 'शेष: ₹${DevoteeDataService().walletBalanceNotifier.value.toStringAsFixed(1)} (न्यूनतम आवश्यक: ₹${_perMinuteRate.toInt()}/मिनट)'
                                : 'Balance: ₹${DevoteeDataService().walletBalanceNotifier.value.toStringAsFixed(1)} (Required: ₹${_perMinuteRate.toInt()}/min)',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: const Color(0xFF7F1D1D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1E1E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showRechargeBottomSheet,
                      child: Text(
                        LocaleService().isHindi ? 'रिचार्ज करें' : 'Recharge',
                        style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

            // WhatsApp Bottom Input Bar (STRICTLY WITHOUT FILE SHARING)
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
                        color: _isLowBalance ? const Color(0xFFF3F4F6) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Text(_isLowBalance ? '🔒' : '🕉️', style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              enabled: !_isLowBalance,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: _isLowBalance ? Colors.grey : const Color(0xFF1F2937),
                              ),
                              decoration: InputDecoration(
                                hintText: _isLowBalance
                                    ? (LocaleService().isHindi
                                        ? 'अपर्याप्त बैलेंस • चैट जारी रखने हेतु रिचार्ज करें'
                                        : 'Not enough balance. Recharge to continue.')
                                    : (LocaleService().isHindi ? 'संदेश लिखें...' : 'Type a message...'),
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: _isLowBalance ? const Color(0xFFDC2626) : const Color(0xFF8696A0),
                                  fontWeight: _isLowBalance ? FontWeight.w500 : FontWeight.normal,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          // Strictly NO attachment or file upload icon here
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // WhatsApp Circular Action Button
                  GestureDetector(
                    onTap: _isLowBalance ? _showRechargeBottomSheet : _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isLowBalance
                            ? const Color(0xFFD97706) // Amber recharge icon
                            : const Color(0xFF00A884), // WhatsApp Emerald Send Green
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isLowBalance ? Icons.account_balance_wallet_rounded : Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
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
            style: TextStyle(fontFamily: 'Headway', fontSize: 16, fontWeight: FontWeight.w700),
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
