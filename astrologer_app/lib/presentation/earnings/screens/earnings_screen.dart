import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AstrologerEarningsScreen extends StatefulWidget {
  const AstrologerEarningsScreen({super.key});

  @override
  State<AstrologerEarningsScreen> createState() => _AstrologerEarningsScreenState();
}

class _AstrologerEarningsScreenState extends State<AstrologerEarningsScreen> {
  double _walletBalance = 18750.0;
  final double _pendingSettlement = 2450.0;

  void _requestWithdrawal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AstrologerColors.cosmicCard,
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
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Withdraw to Bank Account',
              style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Available for instant payout: ₹${_walletBalance.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontSize: 13, color: AstrologerColors.vedicGold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AstrologerColors.cosmicDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AstrologerColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance, color: AstrologerColors.vedicGold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HDFC Bank •••• 8912', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                        Text('IFSC: HDFC0001244 • Verified', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AstrologerColors.statusOnline, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AstrologerColors.vedicGold,
                  foregroundColor: const Color(0xFF1E1B4B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _walletBalance = 0.0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payout request of ₹18,750 sent to HDFC Bank! Funds will settle in 2-4 hours.'),
                      backgroundColor: AstrologerColors.statusOnline,
                    ),
                  );
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
      backgroundColor: AstrologerColors.cosmicDark,
      appBar: AppBar(
        backgroundColor: AstrologerColors.cosmicDark,
        elevation: 0,
        title: Text(
          'Earnings & Wallet',
          style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Wallet Balance Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D28D9), Color(0xFF4C1D95), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Withdrawable Balance', style: GoogleFonts.poppins(color: AstrologerColors.amberGlow, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                        child: Text('Auto-Settlement ON', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee, color: AstrologerColors.vedicGold, size: 30),
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
                        style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AstrologerColors.vedicGold,
                        foregroundColor: const Color(0xFF1E1B4B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.account_balance_wallet, size: 18),
                      label: Text('Withdraw Payout', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                      onPressed: _walletBalance > 0 ? _requestWithdrawal : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Service Breakdown
            Text(
              'Earnings by Consultation Type',
              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTypeCard('Video Calls', '₹11,400', '60%', Icons.videocam, AstrologerColors.mysticalViolet)),
                const SizedBox(width: 10),
                Expanded(child: _buildTypeCard('Voice Calls', '₹5,100', '28%', Icons.phone, Colors.lightBlue)),
                const SizedBox(width: 10),
                Expanded(child: _buildTypeCard('Vedic Chat', '₹2,250', '12%', Icons.chat, Colors.greenAccent)),
              ],
            ),
            const SizedBox(height: 24),

            // Payout History
            Text(
              'Recent Payout Transactions',
              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildPayoutRow('TXN-882193', 'Settled to HDFC •••• 8912', '₹14,500', '25 Sep 2026', true),
            _buildPayoutRow('TXN-774011', 'Settled to HDFC •••• 8912', '₹12,800', '18 Sep 2026', true),
            _buildPayoutRow('TXN-661902', 'Settled to HDFC •••• 8912', '₹9,450', '11 Sep 2026', true),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String title, String amount, String share, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AstrologerColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(amount, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildPayoutRow(String txnId, String desc, String amount, String date, bool isSuccess) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AstrologerColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AstrologerColors.statusOnline.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_downward, color: AstrologerColors.statusOnline, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('$txnId • $date', style: GoogleFonts.poppins(fontSize: 11, color: AstrologerColors.textMuted)),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AstrologerColors.vedicGold),
          ),
        ],
      ),
    );
  }
}
