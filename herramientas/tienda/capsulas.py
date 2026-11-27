"""Cápsulas de Steam y portada de itch.io a partir del fondo de fondo.gd.

Uso: python3 herramientas/tienda/capsulas.py /tmp/tienda
Lee <dir>/fondo.png y escribe <dir>/capsulas/*.png. Solo lleva el título
(Steam no admite otro texto en las cápsulas).
"""
import math, os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
R=os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..") + "/"
D=sys.argv[1] if len(sys.argv) > 1 else "/tmp/tienda"
bg0=Image.open(D + "/fondo.png").convert("RGB").crop((90,110,1620,940))
vig=Image.open(R+"assets/visual/enemies/vigia.png").convert("RGBA").crop((128,0,192,96))
pro=Image.open(R+"assets/visual/protagonist_sheet_f.png").convert("RGBA").crop((0,56,40,112))
FONT=R+"assets/fonts/Jacquard24-Regular.ttf"

def cover(img,W,H):
    r=max(W/img.width,H/img.height); im=img.resize((math.ceil(img.width*r),math.ceil(img.height*r)),Image.LANCZOS)
    x=(im.width-W)//2; y=(im.height-H)//2; return im.crop((x,y,x+W,y+H))

def glow(W,H,cx,cy,rad,col,alpha):
    m=Image.new("L",(W,H),0); d=ImageDraw.Draw(m); d.ellipse((cx-rad,cy-rad,cx+rad,cy+rad),fill=alpha)
    m=m.filter(ImageFilter.GaussianBlur(rad*0.5)); c=Image.new("RGB",(W,H),col); return c,m

def title(im,lines,cx,cy,size,spacing=1.0):
    d=ImageDraw.Draw(im); f=ImageFont.truetype(FONT,size)
    hs=[d.textbbox((0,0),l,font=f) for l in lines]; tot=sum(b[3]-b[1] for b in hs)+int(size*0.15)*(len(lines)-1)
    y=cy-tot//2
    for l,b in zip(lines,hs):
        w=b[2]-b[0]; x=cx-w//2-b[0]; yy=y-b[1]
        # sombra y contorno
        sh=Image.new("L",im.size,0); ds=ImageDraw.Draw(sh); ds.text((x,yy+size//14),l,font=f,fill=255); sh=sh.filter(ImageFilter.GaussianBlur(size/10))
        im.paste((0,0,0),(0,0),sh.point(lambda v:min(255,v*2)))
        ms=Image.new("L",im.size,0); dm=ImageDraw.Draw(ms); dm.text((x,yy),l,font=f,fill=255,stroke_width=max(2,size//18),stroke_fill=255)
        im.paste((24,10,8),(0,0),ms)
        mt=Image.new("L",im.size,0); ImageDraw.Draw(mt).text((x,yy),l,font=f,fill=255)
        grad=Image.new("RGB",im.size); gd=ImageDraw.Draw(grad)
        top=yy+b[1]; bot=yy+b[3]
        for j in range(im.size[1]):
            t=min(1,max(0,(j-top)/max(1,bot-top)))
            c=[int(a+(bb-a)*t) for a,bb in zip((249,239,208),(160,112,60))] if t<1 else (114,87,55)
            gd.line((0,j,im.size[0],j),fill=tuple(c))
        im.paste(grad,(0,0),mt)
        y+=b[3]-b[1]+int(size*0.15)
    return im

def scene(W,H,vx,vy,vs,px,py,ps,dark=0.55):
    im=cover(bg0,W,H); im=ImageEnhance.Brightness(im).enhance(dark); im=im.filter(ImageFilter.GaussianBlur(max(1,W/900)))
    # tinte rojizo
    im=Image.blend(im,Image.new("RGB",(W,H),(40,6,10)),0.25)
    if vs:
        c,m=glow(W,H,vx,vy,int(vs*40),(150,20,30),150); im.paste(c,(0,0),m)
        v=vig.resize((64*vs,96*vs),Image.NEAREST); im.paste(v,(vx-v.width//2,vy-v.height//2),v)
    if ps:
        c,m=glow(W,H,px,py,int(ps*30),(255,150,60),140); im.paste(c,(0,0),m)
        p=pro.resize((40*ps,56*ps),Image.NEAREST); im.paste(p,(px-p.width//2,py-p.height//2),p)
    # viñeta
    vm=Image.new("L",(W,H),0); ImageDraw.Draw(vm).ellipse((-W*0.15,-H*0.2,W*1.15,H*1.2),fill=255); vm=vm.filter(ImageFilter.GaussianBlur(min(W,H)/5))
    im=Image.composite(im,Image.new("RGB",(W,H),(0,0,0)),vm)
    return im

O=D + "/capsulas/"
os.makedirs(O, exist_ok=True)
im=scene(920,430,700,200,4,250,330,3); title(im,["El Templo","de los Ecos"],330,150,92).save(O+"header_capsule_920x430.png")
im=scene(1232,706,930,330,6,330,560,4); title(im,["El Templo","de los Ecos"],440,250,128).save(O+"main_capsule_1232x706.png")
im=scene(748,896,374,300,6,374,800,3,0.5); title(im,["El Templo","de los Ecos"],374,625,100).save(O+"vertical_capsule_748x896.png")
im=scene(600,900,300,300,5,300,815,3,0.5); title(im,["El Templo","de los Ecos"],300,610,84).save(O+"library_capsule_600x900.png")
im=scene(462,174,0,0,0,0,0,0,0.45); title(im,["El Templo","de los Ecos"],231,87,74).save(O+"small_capsule_462x174.png")
im=scene(3840,1240,2900,600,10,1000,950,6); im.save(O+"library_hero_3840x1240.png")
im=scene(1438,810,1100,380,6,300,640,4,0.35); im.save(O+"page_background_1438x810.png")
im=scene(630,500,470,230,3,170,380,2); title(im,["El Templo","de los Ecos"],230,170,64).save(O+"itch_cover_630x500.png")
