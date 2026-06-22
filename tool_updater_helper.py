import argparse, json, os, shutil, subprocess, sys, time
from pathlib import Path

PRESERVE_PREFIXES = ('data/', 'logs/', '_update_staging/', '_tool_update_backups/')
KILL_NAMES = {'xxtouch_only_gui_demo.pyw', 'xxtouch_only_gui_demo.py', 'XXTE Manager.exe', 'remote_webview_host.exe'}

def norm_rel(p):
    return str(p).replace('\\', '/').lstrip('/')

def should_preserve(rel):
    r = norm_rel(rel).lower()
    return any(r.startswith(x.lower()) for x in PRESERVE_PREFIXES) or r.endswith('.lock')

def run(cmd):
    try:
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=8)
    except Exception:
        pass

def kill_related(app_dir, self_pid):
    # Kill only processes whose command line points inside this XXTE Manager folder or named helper apps.
    ps = f"""
$root = {str(app_dir)!r}
$selfPid = {int(self_pid)}
Get-CimInstance Win32_Process | ForEach-Object {{
  $pidv = [int]$_.ProcessId
  if ($pidv -eq $selfPid) {{ return }}
  $name = [string]$_.Name
  $cmd = [string]$_.CommandLine
  if (($cmd -like ('*' + $root + '*')) -or ($name -eq 'remote_webview_host.exe')) {{
    try {{ Stop-Process -Id $pidv -Force -ErrorAction SilentlyContinue }} catch {{}}
  }}
}}
"""
    run(['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', ps])

def copy_tree(src, dst, manifest_files=None):
    # Copy every staged file, including files extracted from archives (for example _internal/web2).
    for s in src.rglob('*'):
        if not s.is_file():
            continue
        rel = norm_rel(s.relative_to(src))
        if not rel or should_preserve(rel):
            continue
        d = dst / rel
        d.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(s, d)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--app-dir', required=True)
    ap.add_argument('--staging', required=True)
    ap.add_argument('--manifest', required=True)
    ap.add_argument('--restart', default='xxtouch_only_gui_demo.pyw')
    args = ap.parse_args()
    app_dir = Path(args.app_dir).resolve()
    staging = Path(args.staging).resolve()
    manifest = json.loads(Path(args.manifest).read_text(encoding='utf-8'))
    time.sleep(1.5)
    kill_related(app_dir, os.getpid())
    time.sleep(1.0)
    copy_tree(staging, app_dir, manifest.get('files') or [])
    (app_dir / 'data').mkdir(exist_ok=True)
    (app_dir / 'data' / 'current_tool_version.json').write_text(json.dumps({'version': manifest.get('version'), 'updated_at': int(time.time())}, ensure_ascii=False, indent=2), encoding='utf-8')
    target = app_dir / args.restart
    if target.exists():
        os.startfile(str(target))
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
