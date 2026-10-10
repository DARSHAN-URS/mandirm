import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/api/api_service.dart';
import '../../../services/auth/auth_service.dart';
import '../../common/widgets/app_image.dart';
import '../../common/widgets/mandirm_header.dart';

class AstrologerEarningsScreen extends StatefulWidget {
  const AstrologerEarningsScreen({super.key});

  @override
  State<AstrologerEarningsScreen> createState() => _AstrologerEarningsScreenState();
}

class _AstrologerEarningsScreenState extends State<AstrologerEarningsScreen> {
  double _walletBalance = 18750.0;
  double _pendingSettlement = 2450.0;
  int _completedConsultations = 6;
  final List<Map<String, dynamic>> _payoutTransactions = [
    {
      'id': 'TXN-882193',
      'desc': 'Settled to HDFC •••• 8912',
      'amount': '₹14,500',
      'date': '25 Sep 2026',
      'is_success': true,
    },
    {
      'id': 'TXN-774011',
      'desc': 'Settled to HDFC •••• 8912',
      'amount': '₹12,800',
      'date': '18 Sep 2026',
      'is_success': true,
    },
    {
      'id': 'TXN-661902',
      'desc': 'Settled to HDFC •••• 8912',
      'amount': '₹9,450',
      'date': '11 Sep 2026',
      'is_success': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  void _loadEarnings() async {
    final astroId = AuthService().currentProfile?.id ?? 'astro_1';
    try {
      final res = await ApiService().getAstrologerEarnings(astroId);
      if (res != null && mounted) {
        setState(() {
          _walletBalance = (res['wallet_balance'] as num?)?.toDouble() ?? _walletBalance;
          _pendingSettlement = (res['total_earned'] as num?)?.toDouble() ?? _pendingSettlement;
          _completedConsultations = (res['completed_consultations'] as num?)?.toInt() ?? _completedConsultations;
        });
      }
    } catch (_) {}

    try {
      final payouts = await ApiService().getAstrologerPayouts(astroId);
      if (payouts.isNotEmpty && mounted) {
        setState(() {
          _payoutTransactions.clear();
          for (var p in payouts) {
            _payoutTransactions.add({
              'id': p['id']?.toString() ?? 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              'desc': p['description']?.toString() ?? 'Settled to HDFC •••• 8912',
              'amount': '₹${((p['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0)}',
              'date': p['created_at']?.toString().split('T').first ?? 'Recent',
              'is_success': (p['status'] ?? 'settled').toString().toLowerCase() != 'failed',
            });
          }
        });
      }
    } catch (_) {}
  }

  void _requestWithdrawal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFDF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Withdraw to Bank Account',
              style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Available for instant payout: ₹${_walletBalance.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primaryMaroon, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance, color: AppColors.primaryMaroon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HDFC Bank •••• 8912', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        Text('IFSC: HDFC0001244 • Verified Acharya Account', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppColors.statusOnline, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMaroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final requestedAmount = _walletBalance;
                  final astroId = AuthService().currentProfile?.id ?? 'astro_1';
                  try {
                    final res = await ApiService().requestAstrologerPayout(
                      astroId,
                      amount: requestedAmount,
                      bankAccount: 'HDFC0001244',
                    );
                    if (!mounted) return;
                    setState(() {
                      _walletBalance = (res?['new_wallet_balance'] as num?)?.toDouble() ?? 0.0;
                      _payoutTransactions.insert(0, {
                        'id': 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                        'desc': 'Transfer to HDFC Bank •••• 8912',
                        'amount': '₹${requestedAmount.toStringAsFixed(0)}',
                        'date': 'Today, Just now',
                        'is_success': true,
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payout request of ₹${requestedAmount.toStringAsFixed(0)} processed on Mandirm server! Funds will settle in 2-4 hours.'),
                        backgroundColor: AppColors.statusOnline,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payout request error: $e'),
                        backgroundColor: AppColors.statusOffline,
                      ),
                    );
                  }
                },
                child: Text('Confirm Payout Transfer', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Unified Mandirm Header (same as consumer app)
          const MandirmHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Big Wallet Balance Card with Devotional Maroon & Gold styling
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryMaroon, AppColors.kumkumMaroon, Color(0xFF991B1B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.marigoldGold.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryMaroon.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -15,
                          bottom: -15,
                          child: Opacity(
                            opacity: 0.12,
                            child: Image.asset(
                              AppConstants.flameLogoAsset,
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Withdrawable Balance', style: GoogleFonts.poppins(color: const Color(0xFFFFF6E5), fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                              child: Text('Auto-Settlement ON', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.currency_rupee, color: Color(0xFFFFD54F), size: 30),
                            Text(
                              _walletBalance.toStringAsFixed(0),
                              style: GoogleFonts.cinzel(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              'Pending T+1 Clearing: ₹${_pendingSettlement.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(color: const Color(0xFFFFF6E5).withOpacity(0.8), fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryMaroon,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.account_balance_wallet, size: 18),
                            label: Text('Withdraw Payout', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                            onPressed: _walletBalance > 0 ? _requestWithdrawal : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
                  const SizedBox(height: 18),

                  // Acharya Festival Payout Incentive Banner with Image
                  Container(
                    width: double.infinity,
                    height: 95,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightBorder),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppImage.network(
                            AppConstants.cdnUrl(AppConstants.astroFeatureGraphic),
                            fallbackAsset: AppConstants.astroBannerArt,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryMaroon.withOpacity(0.92),
                                  AppColors.primaryMaroon.withOpacity(0.72),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.stars_rounded, color: Color(0xFFFFD54F), size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '॥ विशेष आचार्य प्रोत्साहन (15% Bonus) ॥',
                                        style: GoogleFonts.cinzel(
                                          color: const Color(0xFFFFD54F),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Earn 15% extra payout on consultations during Shubh Muhurat and evening hours.',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Service Breakdown
                  Text(
                    'Earnings by Consultation Type',
                    style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTypeCard('Video Calls', '₹11,400', '60%', Icons.videocam, AppColors.primaryMaroon)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTypeCard('Voice Calls', '₹5,100', '28%', Icons.phone, AppColors.deepAmber)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTypeCard('Vedic Chat', '₹2,250', '12%', Icons.chat, AppColors.statusOnline)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Payout History
                  Text(
                    'Recent Payout Transactions',
                    style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ..._payoutTransactions.map(
                    (tx) => _buildPayoutRow(
                      tx['id'] as String,
                      tx['desc'] as String,
                      tx['amount'] as String,
                      tx['date'] as String,
                      tx['is_success'] as bool,
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

  Widget _buildTypeCard(String title, String amount, String share, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(amount, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildPayoutRow(String txnId, String desc, String amount, String date, bool isSuccess) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.statusOnline.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_downward, color: AppColors.statusOnline, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('$txnId • $date', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryMaroon),
          ),
        ],
      ),
    );
  }
}
