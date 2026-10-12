import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../domain/models/consultation_model.dart';
import '../../../services/api/api_service.dart';
import '../../../services/auth/auth_service.dart';
import '../../calls/screens/live_consultation_screen.dart';
import 'astrologer_chat_screen.dart';
import '../../common/widgets/app_image.dart';
import '../../common/widgets/mandirm_header.dart';

class AstrologerConsultationsScreen extends StatefulWidget {
  const AstrologerConsultationsScreen({super.key});

  @override
  State<AstrologerConsultationsScreen> createState() => _AstrologerConsultationsScreenState();
}

class _AstrologerConsultationsScreenState extends State<AstrologerConsultationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _pollingTimer;
  final List<DevoteeConsultationRequest> _liveQueue =
      List.from(DevoteeConsultationRequest.mockQueue);
  final List<AstrologerServiceBooking> _serviceBookings =
      List.from(AstrologerServiceBooking.mockBookings);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQueue();
    // Auto-poll live queue every 8 seconds for real-time customer bookings
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) _loadQueue();
    });
  }


  Future<void> _loadQueue() async {
    final astroId = AuthService().currentProfile?.id ?? 'astro_1';
    try {
      final cons = await ApiService().getAstrologerConsultations(astroId);
      if (cons.isNotEmpty && mounted) {
        final List<DevoteeConsultationRequest> fetchedQueue = [];
        for (var c in cons) {
          final status = (c['status'] ?? 'requested').toString().toLowerCase();
          if (status == 'requested' || status == 'active') {
            fetchedQueue.add(DevoteeConsultationRequest.fromJson(c));
          }
        }
        if (fetchedQueue.isNotEmpty) {
          setState(() {
            _liveQueue.clear();
            _liveQueue.addAll(fetchedQueue);
          });
        }
      }
    } catch (e) {
      debugPrint('[ConsultationsScreen] Error loading queue: $e');
    }

    try {
      final bookingsData = await ApiService().getAstrologerServiceBookings(astroId);
      if (bookingsData.isNotEmpty && mounted) {
        setState(() {
          _serviceBookings.clear();
          _serviceBookings.addAll(
            bookingsData.map((b) => AstrologerServiceBooking.fromJson(b)).toList(),
          );
        });
      }
    } catch (e) {
      debugPrint('[ConsultationsScreen] Error loading service bookings: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }


  void _startConsultation(DevoteeConsultationRequest request) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => request.type == 'chat'
            ? AstrologerWhatsAppChatScreen(consultation: request)
            : LiveConsultationScreen(consultation: request),
      ),
    );

    if (result != null && result['completed'] == true) {
      final remediesList = result['prescribed_remedies'] as List?;
      final remediesNotes = (remediesList != null && remediesList.isNotEmpty)
          ? 'Prescribed remedies: ${remediesList.join(', ')}'
          : null;

      ApiService().updateConsultationStatus(
        request.id,
        status: 'completed',
        durationMinutes: ((result['duration'] as int?) ?? 60) ~/ 60,
        totalAmount: (result['earnings'] as num?)?.toDouble() ?? 375.0,
        notes: remediesNotes,
      );
      setState(() {
        _liveQueue.removeWhere((r) => r.id == request.id);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Consultation with ${request.devoteeName} concluded successfully.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.statusOnline,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Unified Mandirm Header (same as consumer app)
          const MandirmHeader(),

          // Subheader & TabBar with consumer app styling
          Container(
            decoration: const BoxDecoration(
              color: AppColors.headerBg,
              border: Border(bottom: BorderSide(color: AppColors.lightBorder, width: 1.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AstroStrings.t('requests_console'),
                        style: TextStyle(fontFamily: 'Headway', 
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        AstroStrings.t('requests_subtitle'),
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryMaroon,
                  indicatorWeight: 3,
                  labelColor: AppColors.primaryMaroon,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AstroStrings.t('tab_consultations')),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMaroon,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_liveQueue.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(text: AstroStrings.t('tab_services')),
                  ],
                ),
              ],
            ),
          ),

          // Tab View Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLiveQueueView(),
                _buildUpcomingBookingsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveQueueView() {
    if (_liveQueue.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadQueue,
        color: AppColors.primaryMaroon,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warmCream,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.marigoldGold.withOpacity(0.4)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Image.asset(
                      AppConstants.flameLogoAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 48,
                        color: AppColors.statusOnline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Devotees in Queue',
                    style: TextStyle(fontFamily: 'Headway', 
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your status is active. Incoming calls will alert here.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQueue,
      color: AppColors.primaryMaroon,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _liveQueue.length + 1,
        itemBuilder: (context, index) {
        if (index == 0) {
          // Devotional Guidance Banner with Image
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage.network(
                    AppConstants.cdnUrl(AppConstants.astroBannerArt),
                    fallbackAsset: AppConstants.splashBackgroundAsset,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryMaroon.withOpacity(0.92),
                          AppColors.primaryMaroon.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Color(0xFFFFD54F), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '॥ परामर्श मर्यादा व आचार संहिता ॥',
                                style: TextStyle(fontFamily: 'Headway', 
                                  color: const Color(0xFFFFD54F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Provide honest Vedic remedies. Respect devotee privacy.',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                ),
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
          );
        }

        final request = _liveQueue[index - 1];
        final isVideo = request.type == 'video';
        final diffMins = DateTime.now().difference(request.requestedAt).inMinutes;
        final waitingStr = diffMins <= 1 ? 'Just now' : '$diffMins mins ago';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isVideo ? AppColors.primaryMaroon.withOpacity(0.3) : AppColors.lightBorder,
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lightBorder, width: 1.5),
                    ),
                    child: ClipOval(
                      child: AppImage.network(
                        request.devoteePhoto,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              request.devoteeName,
                              style: GoogleFonts.poppins(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isVideo
                                    ? AppColors.primaryMaroon.withOpacity(0.1)
                                    : AppColors.deepAmber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVideo ? Icons.videocam : Icons.phone_in_talk,
                                    size: 14,
                                    color: isVideo ? AppColors.primaryMaroon : AppColors.deepAmber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isVideo ? 'Video Call' : 'Voice Call',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isVideo ? AppColors.primaryMaroon : AppColors.deepAmber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Waiting: $waitingStr • Rate: ₹${request.perMinuteRate.toStringAsFixed(0)}/min',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Devotee Details Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warmCream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.deepAmber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DOB: ${request.birthDob} • Rashi: ${request.devoteeRashi} • Topic: ${request.problemTopic}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Persist rejection to backend & Supabase
                        ApiService().updateConsultationStatus(request.id, status: 'rejected');
                        setState(() {
                          _liveQueue.removeWhere((r) => r.id == request.id);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Request from ${request.devoteeName} passed.', style: GoogleFonts.poppins()),
                            backgroundColor: AppColors.warmCream,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.lightBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Pass',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _startConsultation(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(
                        isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                        size: 18,
                      ),
                      label: Text(
                        'Accept & Start',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

  void _updateBookingStatus(AstrologerServiceBooking booking, String newStatus) async {
    final idx = _serviceBookings.indexWhere((b) => b.id == booking.id);
    if (idx != -1) {
      setState(() {
        _serviceBookings[idx] = booking.copyWith(status: newStatus);
      });
    }

    await ApiService().updateServiceBookingStatus(
      booking.id,
      status: newStatus,
      resolutionNotes: newStatus == 'completed'
          ? 'Kundli / Vedic remedies analysis prepared and dispatched to devotee.'
          : 'Preparation started by Acharya.',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'completed'
              ? 'Service marked completed and dispatched to ${booking.devoteeName}.'
              : 'Service status updated to ${newStatus.toUpperCase()} on Mandirm.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: newStatus == 'completed' ? AppColors.statusOnline : AppColors.primaryMaroon,
      ),
    );
  }

  Widget _buildUpcomingBookingsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _serviceBookings.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage.network(
                    AppConstants.cdnUrl(AppConstants.astroHeroBannerAsset),
                    fallbackAsset: AppConstants.astroFeatureGraphic,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryMaroon.withOpacity(0.92),
                          AppColors.primaryMaroon.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFFFFD54F), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '॥ विशेष सेवा अनुरोध (Special Service Requests) ॥',
                                style: TextStyle(fontFamily: 'Headway', 
                                  color: const Color(0xFFFFD54F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Kundli preparation, matchmaking & remedial service requests',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                ),
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
          );
        }

        final b = _serviceBookings[i - 1];
        final isCompleted = b.status == 'completed';
        final isInProgress = b.status == 'in_progress';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? AppColors.statusOnline.withOpacity(0.4)
                  : (isInProgress ? AppColors.deepAmber.withOpacity(0.5) : AppColors.lightBorder),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lightBorder, width: 1.5),
                    ),
                    child: ClipOval(
                      child: AppImage.network(
                        b.devoteePhoto,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                b.devoteeName,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? AppColors.statusOnline.withOpacity(0.12)
                                    : (isInProgress
                                        ? AppColors.deepAmber.withOpacity(0.15)
                                        : AppColors.primaryMaroon.withOpacity(0.08)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isCompleted ? 'COMPLETED' : (isInProgress ? 'IN PROGRESS' : 'REQUESTED'),
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isCompleted
                                      ? AppColors.statusOnline
                                      : (isInProgress ? AppColors.deepAmber : AppColors.primaryMaroon),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${b.serviceType} • ${b.time}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warmCream,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Text(
                      b.rate,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                  ),
                ],
              ),
              if (b.notes != null && b.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warmCream,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          b.notes!,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  if (!isCompleted) ...[
                    if (!isInProgress)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _updateBookingStatus(b, 'in_progress'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryMaroon),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.play_circle_outline, size: 16, color: AppColors.primaryMaroon),
                          label: Text(
                            'Begin Prep',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryMaroon,
                            ),
                          ),
                        ),
                      ),
                    if (!isInProgress) const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateBookingStatus(b, 'completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusOnline,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(
                          'Mark Delivered',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.statusOnline.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.statusOnline.withOpacity(0.3)),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.statusOnline, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Kundli Fulfilled & Dispatched to Devotee',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.statusOnline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
