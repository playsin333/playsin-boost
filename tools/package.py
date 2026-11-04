"""Package the existing hybrid BOOST BAT and its unchanged NVIDIA runtime files."""
from pathlib import Path
import argparse
import hashlib
import re
import json
from urllib.parse import urlparse
import zipfile

ROOT = Path(__file__).resolve().parent.parent
FILES = [
    'PLAYSIN BOOST 3.0.bat', 'README.md', 'START-HERE.txt', 'THIRD-PARTY-NOTICES.md', 'PLAYSIN-BOOST-update-source.json',
    'nvidia/nvidiaProfileInspector.exe', 'nvidia/nvidiaProfileInspector.exe.config',
    'nvidia/Reference.xml', 'nvidia/NOTICE.txt', 'nvidia/LICENSE',
    'checker/PLAYSIN TWEAK CHECK.bat', 'checker/LICENSE', 'checker/SOURCE.json',
]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--sync-metadata', action='store_true', help='Refresh tracked metadata for GitHub Download ZIP before committing')
    parser.add_argument('--check-metadata', action='store_true', help='Fail if tracked metadata differs from the packaged files')
    parser.add_argument('--archive-url', help='Public HTTPS URL for the packaged ZIP; no upload is performed')
    parser.add_argument('--release-manifest', type=Path, help='Write the online update manifest locally')
    args = parser.parse_args()
    if bool(args.archive_url) != bool(args.release_manifest):
        parser.error('--archive-url and --release-manifest must be used together')
    if args.archive_url and (urlparse(args.archive_url).scheme != 'https' or urlparse(args.archive_url).username):
        parser.error('archive URL must be HTTPS without embedded credentials')
    version = re.search(r"\$P3Version\s*=\s*'([^']+)'", (ROOT / 'PLAYSIN BOOST 3.0.bat').read_text(encoding='utf-8')).group(1)
    prefix = f'PLAYSIN BOOST {version}/'
    program_root = ROOT / 'Программы'
    program_files = sorted(p.relative_to(ROOT).as_posix() for p in program_root.rglob('*') if p.is_file())
    if not program_files:
        raise ValueError('Missing program guides')
    for name in program_files:
        if Path(name).suffix.lower() not in {'.txt', '.html', '.json'}:
            raise ValueError('Unexpected distributable in guides: ' + name)
    catalog = json.loads((program_root / 'catalog.json').read_text(encoding='utf-8'))
    index = (program_root / 'Открыть гайды.html').read_text(encoding='utf-8')
    for item in catalog:
        guide = item['guide']
        if Path(guide).name != guide or not (program_root / guide).is_file() or guide not in index:
            raise ValueError('Missing or unsafe guide: ' + guide)
        if urlparse(item['url']).scheme != 'https' or not urlparse(item['url']).hostname:
            raise ValueError('Guide URL must use HTTPS')
    entries = {name: (ROOT / name).read_bytes() for name in FILES + program_files}
    # Match .gitattributes so release ZIPs and GitHub source ZIPs have the same bytes.
    for name, data in list(entries.items()):
        if name.endswith('.bat'):
            entries[name] = data.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')
        elif not name.endswith('.exe'):
            entries[name] = data.replace(b'\r\n', b'\n')
    entries['BOOST-PACKAGE.json'] = (json.dumps({'Schema': 1, 'Product': 'PLAYSIN BOOST', 'Version': version}, indent=2) + '\n').encode('utf-8')
    checksums = ''.join(f'{hashlib.sha256(data).hexdigest()}  {name}\n' for name, data in sorted(entries.items()))
    entries['SHA256SUMS.txt'] = checksums.encode('utf-8')
    for name in ('BOOST-PACKAGE.json', 'SHA256SUMS.txt'):
        if args.sync_metadata:
            (ROOT / name).write_bytes(entries[name])
        if args.check_metadata and (ROOT / name).read_bytes() != entries[name]:
            raise ValueError('Stale package metadata; run with --sync-metadata: ' + name)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(args.output, 'w', zipfile.ZIP_DEFLATED) as archive:
        for name, data in entries.items():
            info = zipfile.ZipInfo(prefix + name, date_time=(1980, 1, 1, 0, 0, 0))
            # ZipInfo otherwise records a different creator OS on Windows and Linux.
            info.create_system = 3
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, data)
    with zipfile.ZipFile(args.output) as archive:
        assert archive.testzip() is None
        for name, data in entries.items():
            assert archive.read(prefix + name) == data
    if args.release_manifest:
        release = {'Schema': 1, 'Product': 'PLAYSIN BOOST', 'Version': version, 'ArchiveUrl': args.archive_url, 'Sha256': hashlib.sha256(args.output.read_bytes()).hexdigest()}
        args.release_manifest.parent.mkdir(parents=True, exist_ok=True)
        args.release_manifest.write_text(json.dumps(release, indent=2) + '\n')
    print(f'Created and verified {args.output} ({len(entries)} files)')

if __name__ == '__main__':
    main()
