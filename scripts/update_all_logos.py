import os
import sys
from PIL import Image
import numpy as np
import scipy.ndimage as ndi

REPO_ROOT = r"c:\Users\Sunil\OneDrive\Desktop\mandirm"
SOURCE_IMAGE = r"C:\Users\Sunil\.gemini\antigravity-ide\brain\d9b628b0-0342-4d97-a5af-a96c3c9b2f53\.user_uploaded\media_1792653502055.jpg"

def main():
    print("Loading source logo:", SOURCE_IMAGE)
    src_img = Image.open(SOURCE_IMAGE).convert("RGB")
    src_w, src_h = src_img.size
    print(f"Source image dimensions: {src_w}x{src_h}")

    # 1. Create Square Master (1024x1024) with black background
    sq_size = 1024
    sq_img = Image.new("RGB", (sq_size, sq_size), (0, 0, 0))
    offset_y = (sq_size - src_h) // 2
    offset_x = (sq_size - src_w) // 2
    sq_img.paste(src_img, (offset_x, offset_y))
    print("Created 1024x1024 square logo on black background")

    # 1b. Create 1254x1254 Square Master
    sq_1254 = Image.new("RGB", (1254, 1254), (0, 0, 0))
    offset_1254_y = (1254 - src_h) // 2
    offset_1254_x = (1254 - src_w) // 2
    sq_1254.paste(src_img, (offset_1254_x, offset_1254_y))

    # 2. Create Transparent Master PNG
    rgba = np.array(src_img.convert("RGBA"), dtype=np.float32)
    rgb = rgba[:, :, :3]
    max_c = np.max(rgb, axis=2)

    # Floodfill exterior black pixels connected to (0,0)
    is_dark = max_c <= 18
    labeled, _ = ndi.label(is_dark)
    exterior_mask = labeled == labeled[0, 0]

    dist = ndi.distance_transform_edt(exterior_mask)
    alpha_dist = np.clip(1.0 - (dist / 2.0), 0.0, 1.0) * 255.0
    alpha_ramp = np.clip((max_c - 4.0) / 16.0, 0.0, 1.0) * 255.0
    alpha_final = np.where(exterior_mask, np.minimum(alpha_dist, alpha_ramp), 255.0)

    rgba_clean = rgba.copy()
    rgba_clean[:, :, 3] = alpha_final
    clean_im = Image.fromarray(rgba_clean.astype(np.uint8))

    # Crop clean image to tight bounding box with slight 8px margin
    bbox = clean_im.getbbox()
    margin = 8
    crop_box = (
        max(0, bbox[0] - margin),
        max(0, bbox[1] - margin),
        min(src_w, bbox[2] + margin),
        min(src_h, bbox[3] + margin),
    )
    clean_cropped = clean_im.crop(crop_box)
    print("Created transparent logo:", clean_cropped.size)

    # 3. Create App Icon (1024x1024)
    # The logo fits in center with comfortable padding
    app_icon = Image.new("RGB", (1024, 1024), (0, 0, 0))
    # Scale source to fit ~840px width
    target_w = 880
    scale = target_w / src_w
    target_h = int(src_h * scale)
    scaled_logo = src_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
    app_icon.paste(scaled_logo, ((1024 - target_w) // 2, (1024 - target_h) // 2))

    # 4. Create App Icon Foreground (Adaptive, 1024x1024)
    # Adaptive safe zone is inner 66% (circle of radius 0.33 * size)
    # Scale clean logo to fit ~620px width
    app_icon_fg = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    fg_target_w = 640
    fg_scale = fg_target_w / clean_cropped.width
    fg_target_h = int(clean_cropped.height * fg_scale)
    scaled_fg = clean_cropped.resize((fg_target_w, fg_target_h), Image.Resampling.LANCZOS)
    app_icon_fg.paste(scaled_fg, ((1024 - fg_target_w) // 2, (1024 - fg_target_h) // 2), scaled_fg)

    # Save to all destination paths
    def save_img(img, rel_path, **kwargs):
        full_path = os.path.join(REPO_ROOT, rel_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        img.save(full_path, **kwargs)
        print(f"Saved: {rel_path} ({img.size})")

    # Root logo
    save_img(sq_1254, "logo.jpeg", quality=95)

    # Consumer App assets
    save_img(sq_img, "consumer_app/assets/images/inner_logo.jpg", quality=95)
    save_img(clean_cropped, "consumer_app/assets/images/mandirm_flame_logo.png")
    save_img(app_icon, "consumer_app/assets/images/app_icon.png")
    save_img(app_icon_fg, "consumer_app/assets/images/app_icon_foreground.png")

    # Astrologer App assets
    save_img(sq_img, "astrologer_app/assets/images/inner_logo.jpg", quality=95)
    save_img(sq_1254, "astrologer_app/assets/images/logo.jpeg", quality=95)
    save_img(sq_img, "astrologer_app/assets/images/logo.png")
    save_img(clean_cropped, "astrologer_app/assets/images/mandirm_flame_logo.png")
    save_img(app_icon, "astrologer_app/assets/images/app_icon.png")
    save_img(app_icon_fg, "astrologer_app/assets/images/app_icon_foreground.png")

    # Consumer Website assets
    save_img(sq_img, "consumer_website/public/images/inner_logo.jpg", quality=95)
    save_img(clean_cropped, "consumer_website/public/images/inner_logo_clean.png")
    save_img(clean_cropped, "consumer_website/public/images/inner_logo_cropped.png")
    save_img(clean_cropped, "consumer_website/public/images/inner_logo_horizontal.png")
    save_img(clean_cropped, "consumer_website/public/images/mandirm_flame_logo.png")
    save_img(app_icon, "consumer_website/public/images/app_icon.png")
    save_img(app_icon_fg, "consumer_website/public/images/app_icon_foreground.png")

    # Admin Panel assets
    save_img(sq_1254, "admin_panel/public/images/logo.jpeg", quality=95)
    save_img(sq_img, "admin_panel/public/images/inner_logo.jpg", quality=95)
    save_img(clean_cropped, "admin_panel/public/images/inner_logo_clean.png")
    save_img(clean_cropped, "admin_panel/public/images/inner_logo_horizontal.png")
    save_img(clean_cropped, "admin_panel/public/images/mandirm_flame_logo.png")

    # Assets archive
    save_img(app_icon, "assets_archive/images/app_icon.png")
    save_img(app_icon_fg, "assets_archive/images/app_icon_foreground.png")
    save_img(sq_img, "assets_archive/images/inner_logo.jpg", quality=95)
    save_img(clean_cropped, "assets_archive/images/mandirm_flame_logo.png")

    # Favicons
    ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64)]
    app_icon.save(os.path.join(REPO_ROOT, "consumer_website/public/favicon.ico"), sizes=ico_sizes)
    print("Saved consumer_website/public/favicon.ico")
    app_icon.save(os.path.join(REPO_ROOT, "admin_panel/public/favicon.ico"), sizes=ico_sizes)
    print("Saved admin_panel/public/favicon.ico")

    # Web icons & favicons
    for app_dir in ["consumer_app", "astrologer_app"]:
        save_img(app_icon.resize((192, 192), Image.Resampling.LANCZOS), f"{app_dir}/web/icons/Icon-192.png")
        save_img(app_icon.resize((512, 512), Image.Resampling.LANCZOS), f"{app_dir}/web/icons/Icon-512.png")
        save_img(app_icon.resize((192, 192), Image.Resampling.LANCZOS), f"{app_dir}/web/icons/Icon-maskable-192.png")
        save_img(app_icon.resize((512, 512), Image.Resampling.LANCZOS), f"{app_dir}/web/icons/Icon-maskable-512.png")
        save_img(app_icon.resize((32, 32), Image.Resampling.LANCZOS), f"{app_dir}/web/favicon.png")

    # macOS icons
    macos_sizes = [16, 32, 64, 128, 256, 512, 1024]
    for app_dir in ["consumer_app", "astrologer_app"]:
        for s in macos_sizes:
            save_img(app_icon.resize((s, s), Image.Resampling.LANCZOS), f"{app_dir}/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_{s}.png")

    # Android launcher icons
    # mipmap sizes: mdpi=48, hdpi=72, xhdpi=96, xxhdpi=144, xxxhdpi=192
    # drawable foreground sizes: mdpi=108, hdpi=162, xhdpi=216, xxhdpi=324, xxxhdpi=432
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
    for app_dir in ["consumer_app", "astrologer_app"]:
        res_dir = f"{app_dir}/android/app/src/main/res"
        for folder, sz in android_mipmaps.items():
            save_img(app_icon.resize((sz, sz), Image.Resampling.LANCZOS), f"{res_dir}/{folder}/ic_launcher.png")
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
    for app_dir in ["consumer_app", "astrologer_app"]:
        ios_dir = f"{app_dir}/ios/Runner/Assets.xcassets/AppIcon.appiconset"
        for name, sz in ios_icons:
            save_img(app_icon.resize((sz, sz), Image.Resampling.LANCZOS), f"{ios_dir}/{name}")

    print("\nAll logo variants and platform icons generated successfully!")

if __name__ == "__main__":
    main()
