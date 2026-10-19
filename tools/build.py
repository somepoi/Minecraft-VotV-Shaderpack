"""Build the normal atlas and reproducible shaderpack/source ZIPs."""
from pathlib import Path
import argparse, hashlib, json, zipfile
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
NAME='Minecraft-VotV-Shaderpack-1.0.0'
DIST=ROOT/'dist'
BUILTIN_BINARY_SUFFIXES={'.png','.zip','.jar'}
def normalized_bytes(p):
    data=p.read_bytes()
    return data if p.suffix.lower() in BUILTIN_BINARY_SUFFIXES else data.replace(b'\r\n',b'\n')
def digest(p):return hashlib.sha256(normalized_bytes(p)).hexdigest()
def atlas():
    image=Image.new('RGBA',(4096,2048),(128,128,255,255))
    entries=[]
    for i,name in enumerate(['waterNorm1','waterNorm1_2x','waterNorm1_4x','water_n']):
        p=ROOT/'assets/source-normals'/f'{name}.png'
        base=Image.open(p).convert('RGBA');s=base.width
        assert base.size==(s,s) and s in [512,1024]
        levels=[]
        for level in range(s.bit_length()):
            size=s>>level
            origin=(i*1024,0) if level==0 else (i*1024+s-(s>>(level-1)),s)
            mip=base if level==0 else base.resize((size,size),Image.Resampling.BOX)
            image.paste(mip,origin)
            levels.append({'level':level,'origin':origin,'size':size})
        entries.append({'source':p.relative_to(ROOT).as_posix(),'sha256':digest(p),'size':s,'levels':levels})
    dest=ROOT/'shaders/textures/votv_normals.png';dest.parent.mkdir(parents=True,exist_ok=True)
    unchanged=False
    if dest.is_file():
        with Image.open(dest) as current:
            unchanged=current.size==image.size and current.convert('RGBA').tobytes()==image.tobytes()
    if not unchanged:
        image.save(dest,optimize=True)
    (ROOT/'NORMAL_TEXTURES.json').write_text(json.dumps({'source':'User-supplied VotV installation; see README.md','atlas_sha256':digest(dest),'textures':entries},indent=2)+'\n','utf-8',newline='\n')
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--atlas-only',action='store_true');a=ap.parse_args()
    atlas()
    shaders=ROOT/'shaders'
    for p in list(shaders.glob('*.vsh'))+list(shaders.glob('*.fsh')):
        source=p.read_text('utf-8');assert source.startswith('#version 330 compatibility\n')
        target=shaders/'program'/(p.name+'.glsl');target.parent.mkdir(parents=True,exist_ok=True)
        target.write_text(source.split('\n',1)[1],'utf-8',newline='\n')
        for dimension in ['world-1','world1']:
            target=shaders/dimension/p.name;target.parent.mkdir(parents=True,exist_ok=True)
            target.write_text('#version 330 compatibility\n#define VT_OTHER_DIMENSION\n#include "/program/'+p.name+'.glsl"\n','utf-8',newline='\n')
    if a.atlas_only:return
    shaderfiles=sorted(p for p in (ROOT/'shaders').rglob('*') if p.is_file())
    (ROOT/'SHADERS.sha256').write_text(''.join(f'{digest(p)}  {p.relative_to(ROOT).as_posix()}\n' for p in shaderfiles),'utf-8',newline='\n')
    files=sorted(p for p in ROOT.rglob('*') if p.is_file() and not ({'.git','__pycache__','dist','.venv'} & set(p.relative_to(ROOT).parts)) and p.suffix not in ['.pyc','.zip'])
    DIST.mkdir(exist_ok=True)
    for sources in [False,True]:
        archive=DIST/(NAME+('-sources' if sources else '')+'.zip')
        selected=files if sources else [p for p in files if p.relative_to(ROOT).parts[0]=='shaders']
        prefix=NAME+'/' if sources else ''
        with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
            for p in selected:
                e=zipfile.ZipInfo(prefix+p.relative_to(ROOT).as_posix(),(2026,10,19,0,0,0));e.compress_type=zipfile.ZIP_DEFLATED;e.external_attr=0o644<<16
                z.writestr(e,normalized_bytes(p))
        with zipfile.ZipFile(archive) as z:
            assert z.testzip() is None and len(z.namelist())==len(set(z.namelist()))
            assert prefix+'shaders/gbuffers_water.fsh' in z.namelist()
        archive.with_suffix(archive.suffix+'.sha256').write_text(hashlib.sha256(archive.read_bytes()).hexdigest()+'  '+archive.name+'\n','utf-8',newline='\n')
        print(archive.name,archive.stat().st_size,digest(archive))
if __name__=='__main__':main()
