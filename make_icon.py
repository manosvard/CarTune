import math, os
from PIL import Image, ImageDraw, ImageFilter

S = 4096  # σχεδίαση σε μεγάλη ανάλυση για λείες άκρες
img = Image.new("RGB", (S, S))
px = img.load()

# Φόντο: διαγώνιο gradient βαθύ μπλε -> μοβ -> σκούρο
c1, c2, c3 = (10, 12, 40), (60, 25, 110), (8, 8, 20)
for y in range(S):
    for x in range(0, S):
        t = (x + y) / (2 * S)
        if t < 0.5:
            k = t / 0.5; a, b = c1, c2
        else:
            k = (t - 0.5) / 0.5; a, b = c2, c3
        px[x, y] = tuple(int(a[i] + (b[i] - a[i]) * k) for i in range(3))

# Λάμψη πορτοκαλί από κάτω
glow = Image.new("RGB", (S, S), (0, 0, 0))
gd = ImageDraw.Draw(glow)
gd.ellipse([S*0.15, S*0.55, S*0.85, S*1.25], fill=(255, 110, 20))
glow = glow.filter(ImageFilter.GaussianBlur(S * 0.12))
img = Image.blend(img, Image.composite(glow, img, glow.convert("L")), 0.55)

d = ImageDraw.Draw(img, "RGBA")
cx, cy, R = S / 2, S * 0.54, S * 0.33

# Τόξο στροφόμετρου (135° -> 405°)
start, end = 135, 405
width = int(S * 0.055)
box = [cx - R, cy - R, cx + R, cy + R]
d.arc(box, start, end, fill=(255, 255, 255, 60), width=width)
prog_end = start + (end - start) * 0.78
steps = 200
for i in range(steps):
    a0 = start + (prog_end - start) * i / steps
    a1 = start + (prog_end - start) * (i + 1) / steps + 0.6
    k = i / steps
    col = (int(255), int(190 - 110 * k), int(40 - 20 * k), 255)
    d.arc(box, a0, a1, fill=col, width=width)

# Ticks
for i in range(0, 28):
    ang = math.radians(start + (end - start) * i / 27)
    r0, r1 = R - width * 1.25, R - width * (2.0 if i % 3 == 0 else 1.65)
    d.line([cx + r0 * math.cos(ang), cy + r0 * math.sin(ang),
            cx + r1 * math.cos(ang), cy + r1 * math.sin(ang)],
           fill=(255, 255, 255, 170 if i % 3 == 0 else 90), width=int(S * 0.008))

# Αστραπή στο κέντρο
bolt = [(-0.10, -0.32), (0.13, -0.32), (0.02, -0.06), (0.17, -0.06), (-0.12, 0.34), (-0.04, 0.03), (-0.18, 0.03)]
pts = [(cx + x * S * 0.78, cy + y * S * 0.78) for x, y in bolt]
shadow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
ImageDraw.Draw(shadow).polygon(pts, fill=(255, 140, 30, 255))
shadow = shadow.filter(ImageFilter.GaussianBlur(S * 0.03))
img.paste(shadow, (0, 0), shadow)
d = ImageDraw.Draw(img, "RGBA")
d.polygon(pts, fill=(255, 245, 225, 255))

# Λεπτή λάμψη στην κορυφή
sheen = Image.new("RGBA", (S, S), (0, 0, 0, 0))
ImageDraw.Draw(sheen).ellipse([-S*0.2, -S*0.7, S*1.2, S*0.35], fill=(255, 255, 255, 16))
img.paste(sheen, (0, 0), sheen)

icon = img.resize((1024, 1024), Image.LANCZOS).convert("RGB")
out = "Sources/Assets.xcassets/AppIcon.appiconset"
os.makedirs(out, exist_ok=True)
icon.save(f"{out}/icon-1024.png")
print("icon saved")
