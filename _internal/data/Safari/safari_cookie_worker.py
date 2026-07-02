import json, sys, time, shlex
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from xxtouch_openapi_client import XXTouchOpenAPIClient

REMOTE = '/var/mobile/Media/1ferver/ipa/Safari_Cookies.binarycookies'

def find_machine(machine):
    cfg = ROOT / 'data' / 'xxtouch_router_config.json'
    data = json.loads(cfg.read_text(encoding='utf-8'))
    routers = data if isinstance(data, list) else data.get('routers', [])
    for r in routers:
        for row in r.get('rows', []) or []:
            if str(row.get('machine','')).strip() == str(machine).strip():
                return str(row.get('ip') or '').strip()
    return ''

def main():
    machine = sys.argv[1] if len(sys.argv) > 1 else ''
    ip = sys.argv[2] if len(sys.argv) > 2 else ''
    if not ip:
        ip = find_machine(machine)
    if not ip:
        raise RuntimeError(f'Không tìm thấy IP máy {machine}')
    c = XXTouchOpenAPIClient(f'http://{ip}:46952', connect_timeout=1.2, read_timeout=12)
    lua = r'''
local app=require("app")
local sys=require("sys")
local file=require("file")
local safariPath=app.data_path("com.apple.mobilesafari") or ""
local cookiePath=safariPath .. "/Library/Cookies/Cookies.binarycookies"
local outDir="/var/mobile/Media/1ferver/ipa"
local outPath=outDir .. "/Safari_Cookies.binarycookies"
os.execute("mkdir -p " .. outDir)
os.execute("rm -f " .. outPath)
local function exists(p)
 if file and file.exists then return file.exists(p) end
 local f=io.open(p,"rb"); if f then f:close(); return true end; return false
end
if not exists(cookiePath) then
 local f=io.open("/var/mobile/Media/1ferver/ipa/safari_cookie_status.txt","w"); if f then f:write("src_missing "..tostring(cookiePath)); f:close() end
 error("src_missing "..tostring(cookiePath))
end
local rf,e1=io.open(cookiePath,"rb")
if not rf then error("open_src_fail "..tostring(e1)) end
local data=rf:read("*a"); rf:close()
if not data or #data==0 then error("cookie_empty") end
local wf,e2=io.open(outPath,"wb")
if not wf then error("open_dst_fail "..tostring(e2)) end
wf:write(data); wf:close()
if sys and sys.toast then sys.toast("Safari cookie OK",0) end
return true
'''
    try:
        c.spawn(lua)
    except Exception as e:
        # If source cookie is missing, spawn may return HTTP 400; still report cleanly.
        last_spawn = str(e)
    else:
        last_spawn = ''
    last_err = last_spawn
    data = None
    for i in range(18):
        time.sleep(0.7)
        try:
            data = c.download_file(REMOTE)
            if data:
                break
        except Exception as e:
            last_err = str(e)
    if not data:
        raise RuntimeError('Không lấy được Safari cookie: ' + last_err)
    out_root = ROOT / 'data' / 'Safari' / 'CookieData'
    out_root.mkdir(parents=True, exist_ok=True)
    import random, string
    suffix = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(5))
    folder = out_root / f"M{machine}_{time.strftime('%Y%m%d_%H%M%S')}_{suffix}"
    folder.mkdir(parents=True, exist_ok=False)
    out = folder / 'Cookies.binarycookies'
    out.write_bytes(data)
    meta = {'machine': machine, 'ip': ip, 'created_at': time.strftime('%Y-%m-%d %H:%M:%S'), 'source': REMOTE, 'file': str(out)}
    (folder/'meta.json').write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps({'ok': True, 'machine': machine, 'folder': folder.name, 'bytes': len(data)}, ensure_ascii=False))

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(json.dumps({'ok': False, 'error': str(e)}, ensure_ascii=False))
        sys.exit(2)
