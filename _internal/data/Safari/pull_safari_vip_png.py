import json
import sys
import time
from pathlib import Path

from xxtouch_openapi_client import XXTouchOpenAPIClient

BASE = Path(__file__).resolve().parent
CONFIG = Path(r'D:\XXTE Manager\data\xxtouch_router_config.json')
OUT_BASE = BASE / 'downloads'
REMOTE_TMP = '/var/mobile/Media/1ferver/pull/vip.png'
REMOTE_LOG = '/var/mobile/Media/1ferver/log/pull_safari_vip_png.txt'


def load_rows():
    data = json.loads(CONFIG.read_text(encoding='utf-8', errors='replace'))
    rows = []
    if isinstance(data, list):
        for router in data:
            if isinstance(router, dict):
                for row in router.get('rows', []) or []:
                    if isinstance(row, dict):
                        rows.append(row)
    elif isinstance(data, dict):
        for router in data.get('routers', []) or []:
            if isinstance(router, dict):
                for row in router.get('rows', []) or []:
                    if isinstance(row, dict):
                        rows.append(row)
        for row in data.get('rows', []) or []:
            if isinstance(row, dict):
                rows.append(row)
    return rows


def find_ip(machine_or_ip):
    s = str(machine_or_ip).strip()
    if s.count('.') == 3:
        return s, s
    for row in load_rows():
        m = str(row.get('machine', '')).strip()
        ip = str(row.get('ip', '')).strip()
        if m == s and ip:
            return m, ip
    raise SystemExit(f'KhÃ´ng tÃ¬m tháº¥y mÃ¡y/IP: {s}')


def pull_one(machine_or_ip):
    machine, ip = find_ip(machine_or_ip)
    c = XXTouchOpenAPIClient(f'http://{ip}:46952', connect_timeout=2, read_timeout=30)
    lua = f'''
local app = require("app")
local file = require("file")
local lfs = require("lfs")
local function mkdirp(p)
  local cur = ""
  for part in tostring(p):gmatch("[^/]+") do
    cur = cur .. "/" .. part
    pcall(lfs.mkdir, cur)
  end
end
local logp = "{REMOTE_LOG}"
local outp = "{REMOTE_TMP}"
local safariPath = app.data_path("com.apple.mobilesafari") or ""
local cookiePath = safariPath .. "/Library/Cookies/vip.png"
mkdirp("/var/mobile/Media/1ferver/pull")
mkdirp("/var/mobile/Media/1ferver/log")
local ok = false
local sz = 0
local src = io.open(cookiePath, "rb")
if src then
  local data = src:read("*a") or ""
  src:close()
  local dst = io.open(outp, "wb")
  if dst then
    dst:write(data)
    dst:close()
    ok = true
    sz = #data
  end
end
local f = io.open(logp, "w")
if f then
  f:write("safariPath=" .. tostring(safariPath) .. "\n")
  f:write("cookiePath=" .. tostring(cookiePath) .. "\n")
  f:write("outPath=" .. tostring(outp) .. "\n")
  f:write("ok=" .. tostring(ok) .. "\n")
  f:write("size=" .. tostring(sz) .. "\n")
  f:close()
end
'''
    try:
        c.recycle(); time.sleep(0.5)
    except Exception:
        pass
    c.spawn(lua)
    time.sleep(1.5)
    log = c.download_text_file(REMOTE_LOG)
    if 'ok=true' not in log:
        print(f'[{machine}] FAIL {ip}')
        print(log)
        return False
    data = c.download_file(REMOTE_TMP)
    outdir = OUT_BASE / str(machine)
    outdir.mkdir(parents=True, exist_ok=True)
    out = outdir / 'vip.png'
    out.write_bytes(data)
    print(f'[{machine}] OK {ip} -> {out} ({len(data)} bytes)')
    print(log.strip())
    return True


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('DÃ¹ng: python pull_safari_vip_png.py <mÃ¡y|ip> [mÃ¡y|ip...]')
        print('VD: python pull_safari_vip_png.py 1087')
        raise SystemExit(2)
    ok = 0
    for arg in sys.argv[1:]:
        try:
            ok += 1 if pull_one(arg) else 0
        except Exception as e:
            print(f'[{arg}] ERROR {e}')
    print(f'DONE ok={ok}/{len(sys.argv)-1}')

