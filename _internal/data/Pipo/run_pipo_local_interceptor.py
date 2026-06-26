import os, shutil, subprocess, sys
from pathlib import Path

BASE = Path(__file__).resolve().parent
PORT = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('PIPO_LOCAL_PORT', '8891')
ADDON = BASE / 'pipo_local_interceptor.py'
CONFDIR = BASE / 'mitm_conf_local'
CONFDIR.mkdir(parents=True, exist_ok=True)
mitmdump = shutil.which('mitmdump') or shutil.which('mitmdump.exe')
if not mitmdump:
    raise SystemExit('mitmdump not found in PATH')
if not ADDON.exists():
    raise SystemExit(f'missing addon: {ADDON}')
env = os.environ.copy()
env['PYTHONIOENCODING'] = 'utf-8'
env['PYTHONUTF8'] = '1'
cmd = [mitmdump, '--set', f'confdir={CONFDIR}', '-p', str(PORT), '--listen-host', '0.0.0.0', '-s', str(ADDON), '--set', 'block_global=false', '--set', 'ssl_insecure=true']
print('PIPO_LOCAL_INTERCEPTOR')
print('port=', PORT)
print('addon=', ADDON)
print('cmd=', ' '.join(map(str, cmd)))
subprocess.run(cmd, cwd=str(BASE), env=env)
