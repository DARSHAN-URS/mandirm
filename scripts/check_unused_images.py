from pathlib import Path

repo = Path('.').resolve()
assets = [f.name for f in (repo / 'assets_archive' / 'images').iterdir() if f.is_file() and not f.name.startswith('.')]
dart_files = [f for f in (repo / 'consumer_app' / 'lib').glob('**/*.dart') if f.name != 'app_constants.dart']

text = '\n'.join([f.read_text(encoding='utf-8', errors='ignore') for f in dart_files])

constants_file = repo / 'consumer_app' / 'lib' / 'core' / 'constants' / 'app_constants.dart'
const_lines = constants_file.read_text(encoding='utf-8', errors='ignore').splitlines()
const_map = {}
for line in const_lines:
    if 'static const String' in line and '=' in line:
        parts = line.split('=')
        cname = parts[0].replace('static const String', '').strip()
        val = parts[1].replace(';', '').replace("'", "").replace('"', '').strip()
        if 'assets/images/' in val:
            img_name = val.split('/')[-1]
            const_map[cname] = img_name

truly_used_images = set()

for img in assets:
    if img in text:
        truly_used_images.add(img)

for cname, img_name in const_map.items():
    if cname in text:
        truly_used_images.add(img_name)

# Icons used by launcher and pubspec
truly_used_images.add('app_icon.png')
truly_used_images.add('app_icon_foreground.png')

unused_images = [img for img in assets if img not in truly_used_images]
used_images = [img for img in assets if img in truly_used_images]

print(f"=== TRULY USED IMAGES ({len(used_images)}) ===")
for u in sorted(used_images):
    print(f"  [USED] {u}")

print(f"\n=== UNUSED / DEAD MOCKUP IMAGES ({len(unused_images)}) ===")
for nu in sorted(unused_images):
    print(f"  [DEAD/UNUSED] {nu}")
