import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/l10n/locale_service.dart';
import '../../temples/screens/temples_screen.dart';

class RealQrScannerSheet extends StatefulWidget {
  final Function(String mandirName)? onMandirSelected;

  const RealQrScannerSheet({
    super.key,
    this.onMandirSelected,
  });

  @override
  State<RealQrScannerSheet> createState() => _RealQrScannerSheetState();
}

class _RealQrScannerSheetState extends State<RealQrScannerSheet> with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _laserAnimController;
  late Animation<double> _laserAnimation;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  bool _hasScanned = false;

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _accentGold = Color(0xFFFDCB06);

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _laserAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserAnimController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue ?? '';
    if (rawValue.isEmpty) return;

    setState(() {
      _hasScanned = true;
    });

    HapticFeedback.heavyImpact();

    // Determine recognized temple or sanctum
    String temple = 'Kashi Vishwanath Mandir';
    final lower = rawValue.toLowerCase();
    if (lower.contains('mahakal') || lower.contains('ujjain')) {
      temple = 'Mahakaleshwar Jyotirlinga';
    } else if (lower.contains('tirupati') || lower.contains('balaji')) {
      temple = 'Tirupati Balaji Mandir';
    } else if (lower.contains('kedarnath')) {
      temple = 'Kedarnath Dham';
    } else if (lower.contains('siddhivinayak') || lower.contains('ganesh')) {
      temple = 'Siddhivinayak Temple';
    } else if (lower.contains('vaishno')) {
      temple = 'Mata Vaishno Devi';
    } else if (rawValue.length > 3) {
      temple = rawValue;
    }

    _showScannedSuccessDialog(temple, rawValue);
  }

  void _showScannedSuccessDialog(String templeName, String rawData) {
    final isHi = LocaleService().isHindi;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFFDF8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isHi ? 'पवित्र धाम QR सत्यापित!' : 'Sanctum QR Verified!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHi ? 'सत्यापित मंदिर / संकल्प:' : 'Connected Temple Sanctum:',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              templeName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8F3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5DDD0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 20, color: _primaryMaroon),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rawData,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              setState(() => _hasScanned = false);
            },
            child: Text(
              isHi ? 'पुनः स्कैन करें' : 'Scan Again',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryMaroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dlgCtx); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              if (widget.onMandirSelected != null) {
                widget.onMandirSelected!(templeName);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TemplesScreen(
                      onBookPuja: (m) => Navigator.pop(context),
                    ),
                  ),
                );
              }
            },
            child: Text(
              isHi ? 'दर्शन व पूजा में प्रवेश करें' : 'Enter Darshan & Puja',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.86,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0406),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Live Camera Viewfinder (fills the sheet)
          Positioned.fill(
            top: 26,
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _accentGold, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _accentGold.withAlpha(40),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Real Live Camera Stream
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onBarcodeDetected,
                      errorBuilder: (context, error) {
                        return Container(
                          color: const Color(0xFF1B0B0E),
                          child: const Center(
                            child: Icon(
                              Icons.videocam_off_rounded,
                              color: Colors.amber,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),

                    // Golden Viewfinder Corner Guides
                    Positioned(
                      top: 18,
                      left: 18,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: _accentGold, width: 4),
                            left: BorderSide(color: _accentGold, width: 4),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 18,
                      right: 18,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: _accentGold, width: 4),
                            right: BorderSide(color: _accentGold, width: 4),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 18,
                      left: 18,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: _accentGold, width: 4),
                            left: BorderSide(color: _accentGold, width: 4),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 18,
                      right: 18,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: _accentGold, width: 4),
                            right: BorderSide(color: _accentGold, width: 4),
                          ),
                        ),
                      ),
                    ),

                    // Animated Glowing Laser Scan Line
                    AnimatedBuilder(
                      animation: _laserAnimation,
                      builder: (context, _) {
                        return Positioned(
                          top: _laserAnimation.value * (size.height * 0.70),
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  _accentGold,
                                  Color(0xFFFF5722),
                                  _accentGold,
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _accentGold.withAlpha(180),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Live Camera Controls Floating Overlay (Flash & Switch Camera)
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Torch Toggle
                          GestureDetector(
                            onTap: () async {
                              await _scannerController.toggleTorch();
                              setState(() => _isTorchOn = !_isTorchOn);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(180),
                                shape: BoxShape.circle,
                                border: Border.all(color: _accentGold.withAlpha(160), width: 1.5),
                              ),
                              child: Icon(
                                _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                color: _isTorchOn ? _accentGold : Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Switch Front/Back Camera
                          GestureDetector(
                            onTap: () async {
                              await _scannerController.switchCamera();
                              setState(() => _isFrontCamera = !_isFrontCamera);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(180),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white54, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.flip_camera_ios_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Drag handle at top
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(90),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Close button at top right
          Positioned(
            top: 6,
            right: 12,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
