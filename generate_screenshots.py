import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

base_out = r'C:\Users\Sunil\OneDrive\Desktop\mandirm\play_store_assets'
phone_dir = os.path.join(base_out, 'phone')
t7_dir = os.path.join(base_out, 'tablet_7_inch')
t10_dir = os.path.join(base_out, 'tablet_10_inch')

os.makedirs(phone_dir, exist_ok=True)
os.makedirs(t7_dir, exist_ok=True)
os.makedirs(t10_dir, exist_ok=True)

media_dir = r'C:\Users\Sunil\.gemini\antigravity-ide\brain\c4e95fd3-e94d-492b-98f2-d73a05e6d4cd\.user_uploaded'

screens = [
    {
        'file': os.path.join(media_dir, 'media_1791478307636.jpg'),
        'name': '01_home_screen',
        'title': 'Mandirm - Sacred Devotion & Astrology',
        'subtitle': 'Book Online Pujas & Consult Verified Astrologers'
    },
    {
        'file': os.path.join(media_dir, 'media_1791478303210.jpg'),
        'name': '02_online_puja',
        'title': 'Authentic Vedic Pujas',
        'subtitle': 'Performed by Verified Pandits with Personal Sankalp'
    },
    {
        'file': os.path.join(media_dir, 'media_1791478294932.jpg'),
        'name': '03_temple_chadhawa',
        'title': 'Sacred Temple Chadhawa',
        'subtitle': "Blessed Offerings at India's Holy Pilgrimage Centers"
    },
    {
        'file': os.path.join(media_dir, 'media_1791478290519.jpg'),
        'name': '04_puja_store',
        'title': 'Mantra Energized Divine Store',
        'subtitle': '100% Pure & Sacred Idols, Yantras & Puja Samagri'
    },
    {
        'file': os.path.join(media_dir, 'media_1791478376195.jpg'),
        'name': '05_spiritual_products',
        'title': 'Blessed Spiritual Artifacts',
        'subtitle': 'Certified Rudraksha, Pendants & Holy Offerings'
    }
]

def generate_phone_screenshot(src_path, out_path):
    img = Image.open(src_path).convert('RGB')
    # Standard crisp 1080 x 2400 (Google Play standard 20:9 phone ratio)
    resized = img.resize((1080, 2400), Image.Resampling.LANCZOS)
    resized.save(out_path, format='PNG', optimize=True)

def generate_tablet_screenshot(src_path, title, subtitle, target_w, target_h, out_path):
    canvas = Image.new('RGB', (target_w, target_h), (254, 252, 248))
    draw = ImageDraw.Draw(canvas)
    
    # Warm spiritual subtle gradient
    for y in range(target_h):
        ratio = y / target_h
        r = int(255 - ratio * 14)
        g = int(252 - ratio * 18)
        b = int(246 - ratio * 24)
        draw.line([(0, y), (target_w, y)], fill=(r, g, b))
        
    # Font setup
    try:
        font_title = ImageFont.truetype('arialbd.ttf', int(target_h * 0.030))
        font_sub = ImageFont.truetype('arial.ttf', int(target_h * 0.019))
    except Exception:
        font_title = ImageFont.load_default()
        font_sub = ImageFont.load_default()
        
    t_bbox = draw.textbbox((0, 0), title, font=font_title)
    s_bbox = draw.textbbox((0, 0), subtitle, font=font_sub)
    
    t_w = t_bbox[2] - t_bbox[0]
    s_w = s_bbox[2] - s_bbox[0]
    
    title_y = int(target_h * 0.042)
    sub_y = title_y + (t_bbox[3] - t_bbox[1]) + int(target_h * 0.010)
    
    # Mandirm rich maroon (#8B1E1E) & subtle gold/brown (#664433)
    draw.text(((target_w - t_w) // 2, title_y), title, fill=(139, 30, 30), font=font_title)
    draw.text(((target_w - s_w) // 2, sub_y), subtitle, fill=(110, 80, 60), font=font_sub)
    
    # Device phone card inside tablet
    src = Image.open(src_path).convert('RGBA')
    
    card_top = sub_y + (s_bbox[3] - s_bbox[1]) + int(target_h * 0.032)
    card_avail_h = target_h - card_top - int(target_h * 0.025)
    
    scale = card_avail_h / src.height
    new_w = int(src.width * scale)
    new_h = int(src.height * scale)
    
    max_w = int(target_w * 0.84)
    if new_w > max_w:
        scale = max_w / src.width
        new_w = int(src.width * scale)
        new_h = int(src.height * scale)
        
    src_resized = src.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    # Rounded corners
    corner_radius = int(new_w * 0.045)
    mask = Image.new('L', (new_w, new_h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (new_w, new_h)], radius=corner_radius, fill=255)
    
    # Drop shadow
    shadow_offset = int(target_h * 0.008)
    shadow_blur = int(target_h * 0.016)
    shadow_img = Image.new('RGBA', (target_w, target_h), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow_img)
    
    pos_x = (target_w - new_w) // 2
    pos_y = card_top + (card_avail_h - new_h) // 2
    
    s_draw.rounded_rectangle(
        [(pos_x, pos_y + shadow_offset), (pos_x + new_w, pos_y + new_h + shadow_offset)],
        radius=corner_radius,
        fill=(0, 0, 0, 48)
    )
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(shadow_blur))
    
    canvas_rgba = canvas.convert('RGBA')
    canvas_rgba = Image.alpha_composite(canvas_rgba, shadow_img)
    canvas_rgba.paste(src_resized, (pos_x, pos_y), mask)
    
    # Subtle elegant outline border
    border_img = Image.new('RGBA', (target_w, target_h), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(border_img)
    b_draw.rounded_rectangle(
        [(pos_x, pos_y), (pos_x + new_w, pos_y + new_h)],
        radius=corner_radius,
        outline=(210, 195, 175, 180),
        width=int(target_w * 0.003)
    )
    canvas_rgba = Image.alpha_composite(canvas_rgba, border_img)
    
    canvas_final = canvas_rgba.convert('RGB')
    canvas_final.save(out_path, format='PNG', optimize=True)

if __name__ == '__main__':
    print('Starting screenshot generation...')
    for s in screens:
        p_path = os.path.join(phone_dir, s['name'] + '.png')
        generate_phone_screenshot(s['file'], p_path)
        print('Created Phone:', s['name'])
        
        t7_path = os.path.join(t7_dir, s['name'] + '.png')
        generate_tablet_screenshot(s['file'], s['title'], s['subtitle'], 1200, 1920, t7_path)
        print('Created 7-inch Tablet:', s['name'])
        
        t10_path = os.path.join(t10_dir, s['name'] + '.png')
        generate_tablet_screenshot(s['file'], s['title'], s['subtitle'], 1600, 2560, t10_path)
        print('Created 10-inch Tablet:', s['name'])
        
    print('SUCCESS: All 15 assets generated!')
