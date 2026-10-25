import os
import sys
from PIL import Image, ImageFilter
import numpy as np
import scipy.ndimage as ndi

REPO_ROOT = r"c:\Users\Sunil\OneDrive\Desktop\mandirm"
SOURCE_IMAGE = r"C:\Users\Sunil\.gemini\antigravity-ide\brain\0c091893-cebf-46f8-9dcf-acef9fb02551\.user_uploaded\media_1792755753715.jpg"

def main():
    print(f"Loading source icon: {SOURCE_IMAGE}")
    src_img = Image.open(SOURCE_IMAGE).convert("RGB")
    w, h = src_img.size
    print(f"Source image size: {w}x{h}")
    assert w == 1024 and h == 1024, "Expected 1024x1024 source"

    arr = np.array(src_img, dtype=np.float32)

    # 1. Detect outer white corners with floodfill from the 4 corners
    is_near_white = (arr[:, :, 0] > 242) & (arr[:, :, 1] > 242) & (arr[:, :, 2] > 242)
    labeled, num_features = ndi.label(is_near_white)

    outer_mask = np.zeros((h, w), dtype=bool)
    for corner in [(0, 0), (0, w - 1), (h - 1, 0), (h - 1, w - 1)]:
        c_label = labeled[corner[0], corner[1]]
        if c_label != 0:
            outer_mask |= (labeled == c_label)

    print(f"Detected outer corner white pixels: {np.sum(outer_mask)}")

    # 2. Smooth distance-transform alpha ramp for anti-aliased edge
    dist_outside = ndi.distance_transform_edt(outer_mask)
    dist_inside = ndi.distance_transform_edt(~outer_mask)
    # Signed distance: positive inside, negative outside
    signed_dist = dist_inside - dist_outside
    # Smooth step between -1.5 and +1.5 pixels
    alpha = np.clip((signed_dist + 1.5) / 3.0, 0.0, 1.0) * 255.0

    rgba_clean = np.zeros((h, w, 4), dtype=np.uint8)
    rgba_clean[:, :, :3] = np.clip(arr, 0, 255).astype(np.uint8)
    rgba_clean[:, :, 3] = alpha.astype(np.uint8)
    clean_icon_transparent = Image.fromarray(rgba_clean, "RGBA")
    print("Created transparent icon master")

    # 3. Create full-bleed solid RGB app_icon.png (for iOS, macOS, legacy Android)
    # To avoid white corners on square crops, inpaint outer pixels with the outer border golden color
    # Border gold color is sampled around the boundary of the squircle
    border_gold_color = (255, 174, 0) # #FFAE00
    
    # Create background with warm golden radial gradient
    bg_solid = Image.new("RGB", (1024, 1024), border_gold_color)
    # Paste clean icon with its smooth anti-aliased alpha
    bg_solid.paste(clean_icon_transparent, (0, 0), clean_icon_transparent)
    app_icon_solid = bg_solid
    print("Created full-bleed solid 1024x1024 app_icon")

    # 4. Create Android Adaptive Foreground (1024x1024)
    # Safe zone for Android adaptive icons is 66% - 72% (~720-760px).
    # Scaling to 740px ensures the entire golden squircle and emblem sit safely inside any mask
    fg_target_size = 750
    fg_scaled = clean_icon_transparent.resize((fg_target_size, fg_target_size), Image.Resampling.LANCZOS)
    app_icon_fg = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    offset = (1024 - fg_target_size) // 2
    app_icon_fg.paste(fg_scaled, (offset, offset), fg_scaled)
    print(f"Created adaptive foreground: {fg_target_size}x{fg_target_size} centered in 1024x1024")

    # Helper to save
    def save_img(img, rel_path, **kwargs):
        full_path = os.path.join(REPO_ROOT, rel_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        img.save(full_path, **kwargs)
        print(f"Saved: {rel_path} ({img.size})")

    # Save to both apps' assets
    for app in ["consumer_app", "astrologer_app"]:
        save_img(app_icon_solid, f"{app}/assets/images/app_icon.png")
        save_img(app_icon_fg, f"{app}/assets/images/app_icon_foreground.png")
        save_img(clean_icon_transparent, f"{app}/assets/images/app_icon_clean.png")

    # Web icons & favicons
    for app in ["consumer_app", "astrologer_app"]:
        save_img(app_icon_solid.resize((192, 192), Image.Resampling.LANCZOS), f"{app}/web/icons/Icon-192.png")
        save_img(app_icon_solid.resize((512, 512), Image.Resampling.LANCZOS), f"{app}/web/icons/Icon-512.png")
        save_img(app_icon_solid.resize((192, 192), Image.Resampling.LANCZOS), f"{app}/web/icons/Icon-maskable-192.png")
        save_img(app_icon_solid.resize((512, 512), Image.Resampling.LANCZOS), f"{app}/web/icons/Icon-maskable-512.png")
        save_img(app_icon_solid.resize((32, 32), Image.Resampling.LANCZOS), f"{app}/web/favicon.png")

    # macOS icons
    macos_sizes = [16, 32, 64, 128, 256, 512, 1024]
    for app in ["consumer_app", "astrologer_app"]:
        for s in macos_sizes:
            save_img(app_icon_solid.resize((s, s), Image.Resampling.LANCZOS), f"{app}/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_{s}.png")

    # Android launcher icons
    android_mipmaps = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    android_drawables = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432,
    }
    for app in ["consumer_app", "astrologer_app"]:
        res_dir = f"{app}/android/app/src/main/res"
        for folder, sz in android_mipmaps.items():
            save_img(app_icon_solid.resize((sz, sz), Image.Resampling.LANCZOS), f"{res_dir}/{folder}/ic_launcher.png")
        for folder, sz in android_drawables.items():
            save_img(app_icon_fg.resize((sz, sz), Image.Resampling.LANCZOS), f"{res_dir}/{folder}/ic_launcher_foreground.png")

    # iOS AppIcon images
    ios_icons = [
        ("Icon-App-20x20@1x.png", 20),
        ("Icon-App-20x20@2x.png", 40),
        ("Icon-App-20x20@3x.png", 60),
        ("Icon-App-29x29@1x.png", 29),
        ("Icon-App-29x29@2x.png", 58),
        ("Icon-App-29x29@3x.png", 87),
        ("Icon-App-40x40@1x.png", 40),
        ("Icon-App-40x40@2x.png", 80),
        ("Icon-App-40x40@3x.png", 120),
        ("Icon-App-50x50@1x.png", 50),
        ("Icon-App-50x50@2x.png", 100),
        ("Icon-App-57x57@1x.png", 57),
        ("Icon-App-57x57@2x.png", 114),
        ("Icon-App-60x60@2x.png", 120),
        ("Icon-App-60x60@3x.png", 180),
        ("Icon-App-72x72@1x.png", 72),
        ("Icon-App-72x72@2x.png", 144),
        ("Icon-App-76x76@1x.png", 76),
        ("Icon-App-76x76@2x.png", 152),
        ("Icon-App-83.5x83.5@2x.png", 167),
        ("Icon-App-1024x1024@1x.png", 1024),
    ]
    for app in ["consumer_app", "astrologer_app"]:
        ios_dir = f"{app}/ios/Runner/Assets.xcassets/AppIcon.appiconset"
        for name, sz in ios_icons:
            save_img(app_icon_solid.resize((sz, sz), Image.Resampling.LANCZOS), f"{ios_dir}/{name}")

    # Windows .ico
    ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    for app in ["consumer_app", "astrologer_app"]:
        ico_path = os.path.join(REPO_ROOT, f"{app}/windows/runner/resources/app_icon.ico")
        app_icon_solid.save(ico_path, sizes=ico_sizes)
        print(f"Saved: {app}/windows/runner/resources/app_icon.ico")

    print("\nSuccessfully applied new icon across both consumer_app and astrologer_app!")

if __name__ == "__main__":
    main()
