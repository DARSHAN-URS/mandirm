import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';

/// Universal image widget that loads images from CDN with disk/memory caching via
/// [CachedNetworkImage], showing a smooth shimmer effect while loading and
/// automatically falling back to local bundled assets or placeholder icons if offline.
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

  /// Convenience constructor for local asset paths that should be loaded from CDN
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

  /// Convenience constructor for explicit network/CDN URLs
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
    Widget imageWidget;

    // Resolve URL and whether CDN is enabled
    final targetUrl = _resolveUrl();

    if (AppConstants.enableCdnImages && targetUrl != null && targetUrl.isNotEmpty) {
      imageWidget = CachedNetworkImage(
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
    } else {
      imageWidget = _buildFallbackWidget();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  String? _resolveUrl() {
    if (imageUrl != null && (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'))) {
      return imageUrl;
    }
    if (assetPath != null && assetPath!.isNotEmpty) {
      return AppConstants.cdnUrl(assetPath!);
    }
    return null;
  }

  Widget _buildFallbackWidget() {
    if (assetPath != null && assetPath!.isNotEmpty) {
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
    return _buildDefaultPlaceholder();
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.amber.shade100.withAlpha(120),
      highlightColor: Colors.amber.shade50.withAlpha(200),
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.amber.shade50,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: (width != null && width! < 40) ? 16 : 28,
        color: Colors.amber.shade300,
      ),
    );
  }
}
