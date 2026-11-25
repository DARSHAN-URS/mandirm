import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Universal image widget for Astrologer App:
/// 1. Base64 data URLs (`data:image/...;base64,...`) uploaded via Admin/Console
/// 2. CDN & Supabase storage network URLs (`https://...`)
/// 3. Bundled assets (`assets/images/...`)
class AppImage extends StatelessWidget {
  final String? assetPath;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Alignment alignment;

  const AppImage({
    super.key,
    this.assetPath,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.color,
    this.colorBlendMode,
    this.placeholder,
    this.errorWidget,
    this.alignment = Alignment.center,
  }) : assert(assetPath != null || imageUrl != null, 'Either assetPath or imageUrl must be provided');

  const AppImage.asset(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? color,
    BlendMode? colorBlendMode,
    Widget? placeholder,
    Widget? errorWidget,
    Alignment alignment = Alignment.center,
  }) : this(
          key: key,
          assetPath: path,
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
          color: color,
          colorBlendMode: colorBlendMode,
          placeholder: placeholder,
          errorWidget: errorWidget,
          alignment: alignment,
        );

  const AppImage.network(
    String url, {
    Key? key,
    String? fallbackAsset,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? color,
    BlendMode? colorBlendMode,
    Widget? placeholder,
    Widget? errorWidget,
    Alignment alignment = Alignment.center,
  }) : this(
          key: key,
          imageUrl: url,
          assetPath: fallbackAsset,
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
          color: color,
          colorBlendMode: colorBlendMode,
          placeholder: placeholder,
          errorWidget: errorWidget,
          alignment: alignment,
        );

  @override
  Widget build(BuildContext context) {
    final raw = (imageUrl ?? assetPath ?? '').trim();

    // 1. Base64 Data URLs
    if (raw.startsWith('data:image/') || (raw.startsWith('data:') && raw.contains(';base64,'))) {
      try {
        final commaIdx = raw.indexOf(',');
        if (commaIdx != -1) {
          final b64Str = raw.substring(commaIdx + 1).trim();
          final Uint8List bytes = base64Decode(b64Str);
          final imgWidget = Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            color: color,
            colorBlendMode: colorBlendMode,
            alignment: alignment,
            errorBuilder: (_, __, ___) => errorWidget ?? _buildFallbackWidget(),
          );
          return _applyBorder(imgWidget);
        }
      } catch (e) {
        debugPrint('[AppImage] Base64 decode exception: $e');
      }
    }

    // 2. Reject broken / fake paths
    if (raw.contains('fakepath') ||
        raw.startsWith('C:\\') ||
        raw.startsWith('D:\\') ||
        raw.startsWith('file://') ||
        raw == 'null' ||
        raw == 'undefined' ||
        raw.isEmpty) {
      return _applyBorder(errorWidget ?? _buildFallbackWidget());
    }

    // 3. Bundled local assets
    if (raw.startsWith('assets/')) {
      final imgWidget = Image.asset(
        raw,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        alignment: alignment,
        errorBuilder: (_, __, ___) => errorWidget ?? _buildFallbackWidget(),
      );
      return _applyBorder(imgWidget);
    }

    // 4. Resolve network / CDN URL
    final targetUrl = _resolveUrl(raw);

    if (AppConstants.enableCdnImages && targetUrl != null && (targetUrl.startsWith('http://') || targetUrl.startsWith('https://'))) {
      final imgWidget = CachedNetworkImage(
        imageUrl: targetUrl,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        alignment: alignment,
        placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildFallbackWidget(),
      );
      return _applyBorder(imgWidget);
    }

    return _applyBorder(errorWidget ?? _buildFallbackWidget());
  }

  Widget _applyBorder(Widget widget) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: widget,
      );
    }
    return widget;
  }

  String? _resolveUrl(String raw) {
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    if (raw.startsWith('/')) {
      return '${AppConstants.cdnBaseUrl}$raw';
    }
    if (raw.isNotEmpty) {
      return '${AppConstants.cdnBaseUrl}/$raw';
    }
    return null;
  }

  Widget _buildFallbackWidget() {
    if (assetPath != null && assetPath!.isNotEmpty && assetPath!.startsWith('assets/')) {
      return Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _buildDefaultPlaceholder(),
      );
    }
    return Image.asset(
      AppConstants.logoAsset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _buildDefaultPlaceholder(),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.amber.shade50,
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFFBF4E8),
      alignment: Alignment.center,
      child: const Icon(
        Icons.account_circle_outlined,
        size: 28,
        color: Color(0xFF8B1E1E),
      ),
    );
  }
}
