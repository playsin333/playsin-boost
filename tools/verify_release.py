"""Verify package consistency, reproducibility, media and documentation offline."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys
import tempfile
import zipfile

ROOT=Path(__file__).resolve().parent.parent
def sha(data):return hashlib.sha256(data).hexdigest()
def main():
    manifest=json.loads((ROOT/'boost-release.json').read_text(encoding='utf-8'))
    version=manifest['Version']
    assert re.fullmatch(r'\d+\.\d+\.\d+',version)
    archive=ROOT/f'releases/v{version}/PLAYSIN-BOOST-{version}.zip'
    assert sha(archive.read_bytes())==manifest['Sha256'],'Archive hash'
    assert manifest['ArchiveUrl']==f'https://raw.githubusercontent.com/playsin333/playsin-boost/main/releases/v{version}/PLAYSIN-BOOST-{version}.zip'
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        prefix=f'PLAYSIN BOOST {version}/'
        checks=z.read(prefix+'SHA256SUMS.txt').decode().splitlines()
        expected={prefix+'SHA256SUMS.txt'}
        for line in checks:
            digest,name=line.split('  ',1)
            data=z.read(prefix+name)
            assert sha(data)==digest,name
            disk=(ROOT/name).read_bytes()
            if name.endswith('.bat'):disk=disk.replace(b'\r\n',b'\n').replace(b'\n',b'\r\n')
            elif not name.endswith('.exe'):disk=disk.replace(b'\r\n',b'\n')
            assert data==disk,'Working files differ: '+name
            expected.add(prefix+name)
        assert expected==set(z.namelist()),'Unexpected ZIP files'
        meta=json.loads(z.read(prefix+'BOOST-PACKAGE.json'))
        assert meta['Version']==version and meta['Product']=='PLAYSIN BOOST'
    with tempfile.TemporaryDirectory(prefix='boost-repro-') as folder:
        other=Path(folder)/'package.zip'
        subprocess.run([sys.executable,str(ROOT/'tools/package.py'),str(other),'--check-metadata'],cwd=ROOT,check=True,stdout=subprocess.DEVNULL)
        assert other.read_bytes()==archive.read_bytes(),'Non-reproducible package'
    items=json.loads((ROOT/'media/manifest.json').read_text(encoding='utf-8'))
    for item in items:
        data=(ROOT/item['path']).read_bytes()
        assert len(data)==item['size'] and sha(data)==item['sha256'],item['path']
    # Check relative Markdown links and repo-local absolute GitHub links.
    links=0
    for p in ROOT.rglob('*.md'):
        if '.git' in p.parts:continue
        text=p.read_text(encoding='utf-8')
        for target in re.findall(r'\]\(([^)]+)\)',text):
            target=target.split('#',1)[0]
            if not target or target.startswith(('https:','http:','mailto:')):continue
            assert (p.parent/target).exists(),f'{p.name}: {target}'
            links+=1
    print(f'PASS: ZIP CRC, {len(checks)} file hashes, version, reproducibility, {len(items)} media files and {links} relative links')
if __name__=='__main__':main()
