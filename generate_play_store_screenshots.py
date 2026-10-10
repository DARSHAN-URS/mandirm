import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

user_uploaded_dir = r"C:\Users\Sunil\.gemini\antigravity-ide\brain\e66a5d85-3fdc-49b5-9b83-5c857dae6b55\.user_uploaded"
base_dir = r"c:\Users\Sunil\OneDrive\Desktop\mandirm\play_store_assets"

phone_dir = os.path.join(base_dir, "phone_screenshots")
phone_showcase_dir = os.path.join(base_dir, "phone_showcase")
tablet_7_dir = os.path.join(base_dir, "tablet_7_inch")
tablet_10_dir = os.path.join(base_dir, "tablet_10_inch")

for d in [phone_dir, phone_showcase_dir, tablet_7_dir, tablet_10_dir]:
    os.makedirs(d, exist_ok=True)

# 5 Screens mapping with captions
screens = [
    {
        "filename": "media_1791552289899.jpg",
        "name": "01_requests_queue",
        "tag": "LIVE DEVOTEE QUEUE",
        "title": "Accept Voice & Video Requests",
        "desc": "Manage incoming devotee consultations with instant kundli details"
    },
    {
        "filename": "media_1791552282361.jpg",
        "name": "02_video_consultation",
        "tag": "VEDIC CONSULTATIONS",
        "title": "1-on-1 HD Video & Audio Calls",
        "desc": "Conduct live consultations with real-time kundli access & timer"
    },
    {
        "filename": "media_1791552285979.jpg",
        "name": "03_consultation_history",
        "tag": "DEVOTEE RECORDS & KUNDLIS",
        "title": "Past Sessions & Prescribed Remedies",
        "desc": "Track detailed devotee history, suggested remedies & reviews"
    },
    {
        "filename": "media_1791552269007.jpg",
        "name": "04_notifications_dakshina",
        "tag": "ACHARYA NOTIFICATIONS",
        "title": "Instant Queue & Dakshina Alerts",
        "desc": "Get notified for waiting devotees, reviews & wallet credit updates"
    },
    {
        "filename": "media_1791552293659.jpg",
        "name": "05_acharya_profile_hub",
        "tag": "ACHARYA CONTROL CONSOLE",
        "title": "Duty Status, Pricing & Profile",
        "desc": "Toggle online/offline duty, manage consultation rates & bio"
    }
]

# Fonts
font_paths = [
    r"C:\Windows\Fonts\georgiab.ttf",
    r"C:\Windows\Fonts\arialbd.ttf",
    r"C:\Windows\Fonts\segoeuib.ttf"
]

def get_font(size, bold=True):
    for fp in font_paths:
        if os.path.exists(fp):
            try:
                return ImageFont.truetype(fp, size)
            except Exception:
                pass
    return ImageFont.load_default()

def get_regular_font(size):
    for fp in [r"C:\Windows\Fonts\segoeui.ttf", r"C:\Windows\Fonts\arial.ttf", r"C:\Windows\Fonts\georgia.ttf"]:
        if os.path.exists(fp):
            try:
                return ImageFont.truetype(fp, size)
            except Exception:
                pass
    return ImageFont.load_default()

def create_gradient(width, height, color_top, color_bottom):
    base = Image.new("RGB", (width, height), color_top)
    top_r, top_g, top_b = color_top
    bot_r, bot_g, bot_b = color_bottom
    
    # Fast row-based gradient
    lines = []
    for y in range(height):
        factor = y / float(height)
        r = int(top_r + (bot_r - top_r) * factor)
        g = int(top_g + (bot_g - top_g) * factor)
        b = int(top_b + (bot_b - top_b) * factor)
        lines.append((r, g, b))
    
    img = Image.new("RGB", (width, height))
    draw = ImageDraw.Draw(img)
    for y, col in enumerate(lines):
        draw.line([(0, y), (width, y)], fill=col)
    return img

def round_corners(image, radius):
    mask = Image.new("L", image.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), image.size], radius=radius, fill=255)
    rounded = Image.new("RGBA", image.size, (0, 0, 0, 0))
    rounded.paste(image.convert("RGBA"), (0, 0), mask)
    return rounded

print("Starting generation...")

for idx, item in enumerate(screens):
    src_path = os.path.join(user_uploaded_dir, item["filename"])
    if not os.path.exists(src_path):
        print(f"Skipping {src_path}, not found.")
        continue
    
    orig = Image.open(src_path).convert("RGB")
    
    # -------------------------------------------------------------
    # 1. PURE PHONE SCREENSHOT (1080 x 2400)
    # -------------------------------------------------------------
    phone_img = orig.resize((1080, 2400), Image.Resampling.LANCZOS)
    phone_out = os.path.join(phone_dir, f"{item['name']}.png")
    phone_img.save(phone_out, "PNG", optimize=True)
    print(f"Saved Phone: {phone_out}")
    
    # -------------------------------------------------------------
    # 2. PHONE SHOWCASE SCREENSHOT (1080 x 2400 with headers)
    # -------------------------------------------------------------
    canvas_phone = create_gradient(1080, 2400, (30, 7, 3), (74, 18, 12))
    draw_p = ImageDraw.Draw(canvas_phone)
    
    # Decorative gold bar
    draw_p.rectangle([(390, 60), (690, 64)], fill=(234, 179, 8))
    
    # Tag
    font_tag = get_font(32)
    bbox_tag = draw_p.textbbox((0, 0), item["tag"], font=font_tag)
    tw = bbox_tag[2] - bbox_tag[0]
    draw_p.text(((1080 - tw) / 2, 85), item["tag"], fill=(255, 213, 79), font=font_tag)
    
    # Title
    font_title = get_font(52)
    bbox_title = draw_p.textbbox((0, 0), item["title"], font=font_title)
    tw = bbox_title[2] - bbox_title[0]
    draw_p.text(((1080 - tw) / 2, 140), item["title"], fill=(255, 255, 255), font=font_title)
    
    # Subtitle
    font_desc = get_regular_font(28)
    bbox_desc = draw_p.textbbox((0, 0), item["desc"], font=font_desc)
    tw = bbox_desc[2] - bbox_desc[0]
    draw_p.text(((1080 - tw) / 2, 215), item["desc"], fill=(225, 205, 190), font=font_desc)
    
    # Phone card inside canvas
    # Target phone width: 860, height: 1912
    device_w, device_h = 860, 1912
    resized_phone = orig.resize((device_w, device_h), Image.Resampling.LANCZOS)
    rounded_phone = round_corners(resized_phone, 44)
    
    pos_x = (1080 - device_w) // 2
    pos_y = 300
    
    # Drop shadow
    shadow = Image.new("RGBA", (device_w + 40, device_h + 40), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow)
    s_draw.rounded_rectangle([(10, 10), (device_w + 30, device_h + 30)], radius=46, fill=(0, 0, 0, 160))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    
    canvas_phone.paste(shadow, (pos_x - 20, pos_y - 10), shadow)
    
    # Device border
    canvas_phone.paste(rounded_phone, (pos_x, pos_y), rounded_phone)
    draw_p.rounded_rectangle([(pos_x - 3, pos_y - 3), (pos_x + device_w + 3, pos_y + device_h + 3)], radius=46, outline=(234, 179, 8), width=3)
    
    showcase_out = os.path.join(phone_showcase_dir, f"{item['name']}_showcase.png")
    canvas_phone.save(showcase_out, "PNG", optimize=True)
    print(f"Saved Phone Showcase: {showcase_out}")

    # -------------------------------------------------------------
    # 3. 7-INCH TABLET SCREENSHOT (1200 x 1920)
    # -------------------------------------------------------------
    tab7 = create_gradient(1200, 1920, (30, 7, 3), (70, 15, 10))
    draw_7 = ImageDraw.Draw(tab7)
    
    # Mandirm Branding Header
    draw_7.text(((1200 - 360) / 2, 70), "|| MANDIRM JYOTISH ACHARYA ||", fill=(255, 213, 79), font=get_font(26))
    
    # Main Headline
    f_title7 = get_font(52)
    bbox = draw_7.textbbox((0, 0), item["title"], font=f_title7)
    draw_7.text(((1200 - (bbox[2] - bbox[0])) / 2, 115), item["title"], fill=(255, 255, 255), font=f_title7)
    
    # Subtitle
    f_desc7 = get_regular_font(30)
    bbox = draw_7.textbbox((0, 0), item["desc"], font=f_desc7)
    draw_7.text(((1200 - (bbox[2] - bbox[0])) / 2, 185), item["desc"], fill=(225, 205, 190), font=f_desc7)
    
    # Device card
    # Available height from 270 to 1860 = 1590
    t7_h = 1550
    t7_w = int(t7_h * (460.0 / 1024.0))  # approx 696
    
    resized_t7 = orig.resize((t7_w, t7_h), Image.Resampling.LANCZOS)
    rounded_t7 = round_corners(resized_t7, 36)
    
    x7 = (1200 - t7_w) // 2
    y7 = 270
    
    # Shadow
    shadow7 = Image.new("RGBA", (t7_w + 40, t7_h + 40), (0, 0, 0, 0))
    s7_draw = ImageDraw.Draw(shadow7)
    s7_draw.rounded_rectangle([(10, 10), (t7_w + 30, t7_h + 30)], radius=40, fill=(0, 0, 0, 180))
    shadow7 = shadow7.filter(ImageFilter.GaussianBlur(16))
    
    tab7.paste(shadow7, (x7 - 20, y7 - 10), shadow7)
    tab7.paste(rounded_t7, (x7, y7), rounded_t7)
    draw_7.rounded_rectangle([(x7 - 2, y7 - 2), (x7 + t7_w + 2, y7 + t7_h + 2)], radius=38, outline=(234, 179, 8), width=3)
    
    tab7_out = os.path.join(tablet_7_dir, f"{item['name']}_7inch.png")
    tab7.save(tab7_out, "PNG", optimize=True)
    print(f"Saved 7-inch Tablet: {tab7_out}")

    # -------------------------------------------------------------
    # 4. 10-INCH TABLET SCREENSHOT (1600 x 2560)
    # -------------------------------------------------------------
    tab10 = create_gradient(1600, 2560, (28, 6, 3), (68, 14, 10))
    draw_10 = ImageDraw.Draw(tab10)
    
    # Golden crest line
    draw_10.rectangle([(650, 80), (950, 85)], fill=(234, 179, 8))
    
    # Mandirm Branding Header
    draw_10.text(((1600 - 480) / 2, 105), "|| MANDIRM JYOTISH ACHARYA PORTAL ||", fill=(255, 213, 79), font=get_font(34))
    
    # Main Headline
    f_title10 = get_font(68)
    bbox = draw_10.textbbox((0, 0), item["title"], font=f_title10)
    draw_10.text(((1600 - (bbox[2] - bbox[0])) / 2, 165), item["title"], fill=(255, 255, 255), font=f_title10)
    
    # Subtitle
    f_desc10 = get_regular_font(38)
    bbox = draw_10.textbbox((0, 0), item["desc"], font=f_desc10)
    draw_10.text(((1600 - (bbox[2] - bbox[0])) / 2, 260), item["desc"], fill=(225, 205, 190), font=f_desc10)
    
    # Device card
    # Available height from 360 to 2480 = 2120
    t10_h = 2080
    t10_w = int(t10_h * (460.0 / 1024.0))  # approx 934
    
    resized_t10 = orig.resize((t10_w, t10_h), Image.Resampling.LANCZOS)
    rounded_t10 = round_corners(resized_t10, 48)
    
    x10 = (1600 - t10_w) // 2
    y10 = 360
    
    # Shadow
    shadow10 = Image.new("RGBA", (t10_w + 60, t10_h + 60), (0, 0, 0, 0))
    s10_draw = ImageDraw.Draw(shadow10)
    s10_draw.rounded_rectangle([(15, 15), (t10_w + 45, t10_h + 45)], radius=54, fill=(0, 0, 0, 190))
    shadow10 = shadow10.filter(ImageFilter.GaussianBlur(22))
    
    tab10.paste(shadow10, (x10 - 30, y10 - 15), shadow10)
    tab10.paste(rounded_t10, (x10, y10), rounded_t10)
    draw_10.rounded_rectangle([(x10 - 3, y10 - 3), (x10 + t10_w + 3, y10 + t10_h + 3)], radius=50, outline=(234, 179, 8), width=4)
    
    tab10_out = os.path.join(tablet_10_dir, f"{item['name']}_10inch.png")
    tab10.save(tab10_out, "PNG", optimize=True)
    print(f"Saved 10-inch Tablet: {tab10_out}")

print("All screenshots generated successfully!")
