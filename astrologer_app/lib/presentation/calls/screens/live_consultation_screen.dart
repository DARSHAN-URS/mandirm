import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/consultation_model.dart';
import '../../common/widgets/app_image.dart';

class LiveConsultationScreen extends StatefulWidget {
  final DevoteeConsultationRequest consultation;

  const LiveConsultationScreen({
    super.key,
    required this.consultation,
  });

  @override
  State<LiveConsultationScreen> createState() => _LiveConsultationScreenState();
}

class _LiveConsultationScreenState extends State<LiveConsultationScreen> {
  int _callDurationSeconds = 0;
  Timer? _callTimer;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;
  bool _isSpeakerOn = true;
  final Set<String> _prescribedRemedies = {};

  // Real Agora RTC Engine state
  RtcEngine? _engine;
  bool _isAgoraInitialized = false;
  bool _isJoined = false;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
    _initAgora();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  Future<void> _initAgora() async {
    final isVideo = widget.consultation.type == 'video';

    // Request device hardware permissions
    try {
      if (isVideo) {
        await [Permission.camera, Permission.microphone].request();
      } else {
        await Permission.microphone.request();
      }
    } catch (e) {
      debugPrint('[Agora] Hardware permission request error: $e');
    }

    try {
      const appId = AppConstants.agoraAppId;
      if (appId.isEmpty) {
        debugPrint('[Agora] Agora App ID not provided. Running in fallback UI mode.');
        return;
      }

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        const RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint('[Agora] Successfully joined channel: ${connection.channelId}');
            if (mounted) {
              setState(() => _isJoined = true);
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint('[Agora] Devotee joined video room: $remoteUid');
            if (mounted) {
              setState(() => _remoteUid = remoteUid);
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint('[Agora] Devotee left video room: $remoteUid ($reason)');
            if (mounted) {
              setState(() => _remoteUid = null);
            }
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('[Agora] Notice ($err): $msg');
          },
        ),
      );

      if (isVideo) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.enableAudio();
        await _engine!.setDefaultAudioRouteToSpeakerphone(true);
      }

      final channelId = widget.consultation.callRoomId;
      final token = widget.consultation.callToken;

      await _engine!.joinChannel(
        token: token,
        channelId: channelId,
        uid: 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: isVideo && !_isVideoOff,
          publishMicrophoneTrack: !_isMuted,
        ),
      );

      if (mounted) {
        setState(() => _isAgoraInitialized = true);
      }
    } catch (e) {
      debugPrint('[Agora] RtcEngine initialization notice (fallback active): $e');
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _destroyAgora();
    super.dispose();
  }

  Future<void> _destroyAgora() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
      }
    } catch (_) {}
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _engine?.muteLocalAudioStream(_isMuted);
  }

  void _toggleVideo() {
    setState(() => _isVideoOff = !_isVideoOff);
    _engine?.muteLocalVideoStream(_isVideoOff);
  }

  void _switchCamera() {
    setState(() => _isFrontCamera = !_isFrontCamera);
    _engine?.switchCamera();
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    _engine?.setEnableSpeakerphone(_isSpeakerOn);
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _currentEarnings {
    final elapsedMinutes = (_callDurationSeconds / 60);
    return elapsedMinutes * widget.consultation.perMinuteRate;
  }

  void _onEndCall() {
    final remediesSummary = _prescribedRemedies.isNotEmpty
        ? '\n\nPrescribed Remedies (${_prescribedRemedies.length}):\n• ${_prescribedRemedies.join('\n• ')}'
        : '\n\nNo remedies prescribed in this session.';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AstrologerColors.cosmicCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AstrologerColors.borderSubtle),
        ),
        title: Text(
          'End Consultation?',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Total Duration: ${_formatDuration(_callDurationSeconds)}\nEarned: ₹${_currentEarnings.toStringAsFixed(2)}$remediesSummary\n\nWould you like to complete and settle this consultation?',
          style: GoogleFonts.poppins(color: AstrologerColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Resume Call', style: TextStyle(color: AstrologerColors.vedicGold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AstrologerColors.statusOffline,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, {
                'completed': true,
                'duration': _callDurationSeconds,
                'earnings': _currentEarnings,
                'prescribed_remedies': _prescribedRemedies.toList(),
              });
            },
            child: const Text('End & Settle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dev = widget.consultation;
    final isVideo = dev.type == 'video';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video View (if devotee connected over Agora Video) OR Sacred Devotee Aura Background
          Positioned.fill(
            child: (isVideo && _remoteUid != null && _isAgoraInitialized && _engine != null)
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine!,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: RtcConnection(channelId: widget.consultation.callRoomId),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Color(0xFF2E1065),
                          Color(0xFF0F172A),
                          Colors.black,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AstrologerColors.vedicGold.withOpacity(0.4),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AstrologerColors.vedicGold.withOpacity(0.15),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              ClipOval(
                                child: AppImage.network(
                                  dev.devoteePhoto,
                                  fallbackAsset: AppConstants.logoAsset,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            dev.devoteeName,
                            style: GoogleFonts.cinzel(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AstrologerColors.vedicGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.3)),
                            ),
                            child: Text(
                              'Gotra: ${dev.devoteeGotra} • Rashi: ${dev.devoteeRashi}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AstrologerColors.vedicGold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVideo ? Icons.videocam : Icons.phone_in_talk,
                                color: AstrologerColors.vedicGold,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isVideo
                                    ? (_remoteUid != null ? 'Devotee Video Active' : 'Connecting Devotee Video...')
                                    : 'Live Vedic Voice Call • Encrypted',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Top Overlay: Status, Time, and Real-Time Earnings
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isJoined ? AstrologerColors.statusOnline : Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_callDurationSeconds),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (_isJoined) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AstrologerColors.statusOnline.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'RTC LIVE',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AstrologerColors.statusOnline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AstrologerColors.royalPurple.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.currency_rupee, color: AstrologerColors.vedicGold, size: 14),
                      Text(
                        _currentEarnings.toStringAsFixed(2),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ' (₹${dev.perMinuteRate.toInt()}/m)',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Self-View Pip (Astrologer Live Camera or Avatar)
          if (isVideo)
            Positioned(
              top: 105,
              right: 16,
              child: Container(
                width: 105,
                height: 145,
                decoration: BoxDecoration(
                  color: AstrologerColors.cosmicCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.5)),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _isVideoOff
                            ? Container(
                                color: const Color(0xFF1E1B4B),
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam_off,
                                    color: AstrologerColors.vedicGold,
                                    size: 32,
                                  ),
                                ),
                              )
                            : (_isAgoraInitialized && _engine != null)
                                ? AgoraVideoView(
                                    controller: VideoViewController(
                                      rtcEngine: _engine!,
                                      canvas: const VideoCanvas(uid: 0),
                                    ),
                                  )
                                : AppImage.network(
                                    AppConstants.cdnUrl(AppConstants.astroRajeshAsset),
                                    fallbackAsset: AppConstants.logoAsset,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 6,
                        child: Text(
                          'You (Acharya)',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Topic Banner
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.help_outline, color: AstrologerColors.vedicGold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Consultation Topic:',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white60),
                        ),
                        Text(
                          dev.problemTopic,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: AstrologerColors.vedicGold.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.auto_graph, color: AstrologerColors.vedicGold, size: 16),
                    label: Text(
                      'Kundli',
                      style: GoogleFonts.poppins(color: AstrologerColors.vedicGold, fontSize: 12),
                    ),
                    onPressed: () {
                      _showKundliModal(context, dev);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Control Actions (Phone Call vs Video Call)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallAction(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.white24,
                  onTap: _toggleMute,
                ),
                if (isVideo) ...[
                  _buildCallAction(
                    icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                    color: _isVideoOff ? Colors.red : Colors.white24,
                    onTap: _toggleVideo,
                  ),
                  _buildCallAction(
                    icon: Icons.flip_camera_ios,
                    color: Colors.white24,
                    onTap: _switchCamera,
                  ),
                ] else ...[
                  _buildCallAction(
                    icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                    color: _isSpeakerOn ? AstrologerColors.vedicGold.withOpacity(0.3) : Colors.white24,
                    iconColor: _isSpeakerOn ? AstrologerColors.vedicGold : Colors.white,
                    onTap: _toggleSpeaker,
                  ),
                ],
                _buildCallAction(
                  icon: Icons.call_end,
                  color: AstrologerColors.statusOffline,
                  iconColor: Colors.white,
                  size: 60,
                  onTap: _onEndCall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallAction({
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
    double size = 50,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }

  void _showKundliModal(BuildContext context, DevoteeConsultationRequest dev) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AstrologerColors.cosmicCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vedic Birth Chart (Kundli)',
                            style: GoogleFonts.cinzel(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AstrologerColors.vedicGold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AstrologerColors.royalPurple.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${dev.devoteeRashi} • ${_prescribedRemedies.length} Prescribed',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Devotee Profile Header with Avatar
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AstrologerColors.cosmicDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: AppImage.network(
                                dev.devoteePhoto,
                                fallbackAsset: AppConstants.logoAsset,
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dev.devoteeName,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  Text(
                                    'Topic: ${dev.problemTopic}',
                                    style: GoogleFonts.poppins(
                                      color: AstrologerColors.vedicGold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildKundliDataGrid(dev),
                      const SizedBox(height: 20),
                      Text(
                        'Planetary Alignments (Grahas)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildGrahaCard('Surya (Sun)', '10th House (Digbala)', 'Career peak & public success'),
                      _buildGrahaCard('Brihaspati (Jupiter)', '1st House (Lagna)', 'Strong spiritual & health blessing'),
                      _buildGrahaCard('Shani (Saturn)', '7th House (Retrograde)', 'Delay in business partnership resolution'),
                      _buildGrahaCard('Chandra (Moon)', 'Exalted in Taurus', 'Mental peace & creative intuition'),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prescribed Vedic Remedies (अनुशंसित उपाय)',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Tap to Add/Remove',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AstrologerColors.vedicGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildRemedyCard(
                        'Yellow Sapphire (पुखराज रत्न)',
                        'Gemstone for Guru Brihaspati vitality',
                        AppConstants.catYantraAsset,
                        isPrescribed: _prescribedRemedies.contains('Yellow Sapphire (पुखराज रत्न)'),
                        onToggle: () {
                          setModalState(() {
                            if (_prescribedRemedies.contains('Yellow Sapphire (पुखराज रत्न)')) {
                              _prescribedRemedies.remove('Yellow Sapphire (पुखराज रत्न)');
                            } else {
                              _prescribedRemedies.add('Yellow Sapphire (पुखराज रत्न)');
                            }
                          });
                          setState(() {});
                        },
                      ),
                      _buildRemedyCard(
                        '5-Mukhi Indonesian Rudraksha',
                        'Sacred bead for focus & spiritual health',
                        AppConstants.deityRudrakshaAsset,
                        isPrescribed: _prescribedRemedies.contains('5-Mukhi Indonesian Rudraksha'),
                        onToggle: () {
                          setModalState(() {
                            if (_prescribedRemedies.contains('5-Mukhi Indonesian Rudraksha')) {
                              _prescribedRemedies.remove('5-Mukhi Indonesian Rudraksha');
                            } else {
                              _prescribedRemedies.add('5-Mukhi Indonesian Rudraksha');
                            }
                          });
                          setState(() {});
                        },
                      ),
                      _buildRemedyCard(
                        'Navagraha Shanti Sankalp Puja',
                        'Auspicious temple ritual for pacification',
                        AppConstants.pujaNavgrahaAsset,
                        isPrescribed: _prescribedRemedies.contains('Navagraha Shanti Sankalp Puja'),
                        onToggle: () {
                          setModalState(() {
                            if (_prescribedRemedies.contains('Navagraha Shanti Sankalp Puja')) {
                              _prescribedRemedies.remove('Navagraha Shanti Sankalp Puja');
                            } else {
                              _prescribedRemedies.add('Navagraha Shanti Sankalp Puja');
                            }
                          });
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRemedyCard(
    String title,
    String desc,
    String imagePath, {
    required bool isPrescribed,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isPrescribed
              ? AstrologerColors.vedicGold.withOpacity(0.14)
              : AstrologerColors.cosmicDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrescribed ? AstrologerColors.vedicGold : Colors.white10,
            width: isPrescribed ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppImage.network(
                  AppConstants.cdnUrl(imagePath),
                  fallbackAsset: AppConstants.logoAsset,
                  width: 44,
                  height: 44,
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
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPrescribed) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AstrologerColors.vedicGold.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PRESCRIBED',
                            style: GoogleFonts.poppins(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: AstrologerColors.vedicGold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isPrescribed ? Colors.white70 : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isPrescribed ? Icons.check_circle_rounded : Icons.add_circle_outline,
              color: isPrescribed ? AstrologerColors.vedicGold : Colors.white60,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKundliDataGrid(DevoteeConsultationRequest dev) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstrologerColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDetailItem('Devotee Name', dev.devoteeName)),
              Expanded(child: _buildDetailItem('Gotra', dev.devoteeGotra)),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            children: [
              Expanded(child: _buildDetailItem('Date of Birth', dev.birthDob)),
              Expanded(child: _buildDetailItem('Birth Time', dev.birthTime)),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            children: [
              Expanded(child: _buildDetailItem('Birth Place', dev.birthPlace)),
              Expanded(child: _buildDetailItem('Vedic Lagna', 'Mesha (Aries)')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildGrahaCard(String graha, String position, String effect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AstrologerColors.vedicGold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny_outlined, color: AstrologerColors.vedicGold, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      graha,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Text(
                      position,
                      style: GoogleFonts.poppins(fontSize: 11, color: AstrologerColors.vedicGold),
                    ),
                  ],
                ),
                Text(
                  effect,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
