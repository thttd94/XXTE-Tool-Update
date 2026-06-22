import hashlib
import json
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = 'thttd94/XXTE-Tool-Update'

def run(cmd, check=True):
    print('>', ' '.join(map(str, cmd)))
    return subprocess.run(cmd, cwd=ROOT, check=check)

def out(cmd):
    return subprocess.check_output(cmd, cwd=ROOT, text=True).strip()

def sha1_file(path: Path) -> str:
    h = hashlib.sha1()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()

def main():
    manifest_path = ROOT / 'update_manifest.json'
    if not manifest_path.exists():
        raise SystemExit('ERROR: missing update_manifest.json')
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    version = str(manifest.get('version') or '0')
    tag = f'v{version}'

    web2_zip_arg = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('WEB2_ZIP', '')
    web2_zip = Path(web2_zip_arg).resolve() if web2_zip_arg else None
    if web2_zip and not web2_zip.exists():
        raise SystemExit(f'ERROR: web2 zip not found: {web2_zip}')

    print(f'Version: {version}')
    print(f'Tag: {tag}')
    if web2_zip:
        print(f'web2 zip: {web2_zip}')

    rel = subprocess.run(['gh', 'release', 'view', tag], cwd=ROOT)
    if rel.returncode != 0:
        run(['gh', 'release', 'create', tag, '--title', f'XXTE Tool Update {version}', '--notes', f'XXTE Tool Update {version} assets'])

    if web2_zip:
        run(['gh', 'release', 'upload', tag, str(web2_zip), '--clobber'])

    # Commit payload first so file URLs can pin to immutable commit.
    run(['git', 'add', '-A'])
    c1 = subprocess.run(['git', 'commit', '-m', f'Prepare XXTE update payload {version}'], cwd=ROOT)
    if c1.returncode != 0:
        print('No payload commit needed.')

    payload_sha = out(['git', 'rev-parse', 'HEAD'])
    base = f'https://github.com/{REPO}/raw/{payload_sha}/'

    tracked = out(['git', 'ls-files']).splitlines()
    skip_exact = {'.gitignore', 'update_manifest.json', 'PUSH_UPDATE.bat', 'PUSH_UPDATE.py'}
    files = []
    for rel in tracked:
        rel = rel.replace('\\', '/')
        if rel in skip_exact or rel.startswith('web2/') or rel.startswith('BUILD/'):
            continue
        p = ROOT / rel
        if not p.is_file():
            continue
        files.append({
            'path': rel,
            'size': p.stat().st_size,
            'sha1': sha1_file(p),
            'url': base + rel.replace(' ', '%20'),
        })

    archives = []
    if web2_zip:
        archives.append({
            'name': 'web2.zip',
            'root': 'web2',
            'size': web2_zip.stat().st_size,
            'sha1': sha1_file(web2_zip),
            'url': f'https://github.com/{REPO}/releases/download/{tag}/web2.zip',
        })

    sig_payload = [(f['path'], f['size'], f['sha1']) for f in files] + [(a['name'], a['size'], a['sha1']) for a in archives]
    signature = hashlib.sha1(json.dumps(sig_payload, ensure_ascii=False, separators=(',', ':')).encode()).hexdigest()
    manifest.update({
        'updated_at': int(time.time()),
        'files_signature': signature,
        'files': files,
        'archives': archives,
        'launcher': 'XXTE Manager.exe',
    })
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'manifest files={len(files)} archives={len(archives)} signature={signature}')

    run(['git', 'add', 'update_manifest.json', '.gitignore', 'PUSH_UPDATE.bat', 'PUSH_UPDATE.py'])
    c2 = subprocess.run(['git', 'commit', '-m', f'Update manifest {version}'], cwd=ROOT)
    if c2.returncode != 0:
        print('No manifest commit needed.')

    run(['git', 'push'])
    print('DONE')

if __name__ == '__main__':
    main()
