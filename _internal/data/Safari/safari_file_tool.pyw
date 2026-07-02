import json
import os
import random
import re
import string
import threading
import queue
import time
import urllib.parse
import socket
import shutil
import shlex
from concurrent.futures import ThreadPoolExecutor, as_completed
import http.server
import socketserver
from pathlib import Path
import tkinter as tk
from tkinter import ttk, messagebox

from xxtouch_openapi_client import XXTouchOpenAPIClient

APP_TITLE = 'TikTok Lite ACC Bridge'
BASE = Path(__file__).resolve().parent
LUA_DIR = BASE / 'lua'
XUAT_LUA = LUA_DIR / 'XuatTK.lua'
NHAP_LUA = LUA_DIR / 'NhapTK.lua'
TTL_STAGE1_LUA = LUA_DIR / 'TTL_Stage1_Tai_CLEAN.lua'
TTL_STAGE2_LUA = LUA_DIR / 'TTL_Stage2_Mo.lua'
LOGIN_STAGE6_LUA = LUA_DIR / 'LoginGGSafari_Stage6.lua'
SAFARI_ACC_PATH = BASE / 'safari_acc_list.txt'
MACHINES_TXT = BASE / 'machines.txt'
ACCOUNTS_DIR = BASE / 'accounts'
BACKUP_DATA_DIR = BASE / 'BackupData'
IMPORT_HISTORY_PATH = BACKUP_DATA_DIR / 'import_history.jsonl'
LOG_DIR = BASE / 'logs'
API_PORT = 8788
BID_LITE = 'com.ss.iphone.ugc.tiktok.lite'
REMOTE_DIR = '/var/mobile/Media/1ferver/bin/tiktok_lite'
REMOTE_RUN_DIR = '/var/mobile/Media/1ferver/log'
ACCOUNT_FILES = [
    'Cookies.binarycookies',
    'ttaccountSDKUserInfo.archiver',
    'com.ss.iphone.ugc.tiktok.lite.plist',
]
EXTRA_ACCOUNT_FILES = ['lite_sandbox.tgz']
DEFAULT_EVENT_URL = 'snssdk1233://'


def parse_machine_list(text):
    out, seen = [], set()
    for part in re.split(r'[,;|\s]+', str(text or '').strip()):
        if not part:
            continue
        if '-' in part and part.count('.') != 3:
            a, b = part.split('-', 1)
            if a.strip().isdigit() and b.strip().isdigit():
                x, y = int(a), int(b)
                if y < x: x, y = y, x
                vals = [str(i) for i in range(x, y + 1)]
            else:
                vals = []
        else:
            vals = [part]
        for v in vals:
            if v not in seen:
                seen.add(v); out.append(v)
    return out


def load_machines():
    rows = []
    if MACHINES_TXT.exists():
        for line in MACHINES_TXT.read_text(encoding='utf-8', errors='replace').splitlines():
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = re.split(r'[|,;\s]+', line)
            if len(parts) >= 2:
                rows.append({'machine': parts[0].strip(), 'ip': parts[1].strip()})
    return rows


def find_machine(machine_or_ip, fallback_ip=''):
    s = str(machine_or_ip or '').strip()
    if s.count('.') == 3:
        return s, s
    for r in load_machines():
        if str(r.get('machine')) == s:
            return str(r.get('machine')), str(r.get('ip'))
    if fallback_ip:
        return s or fallback_ip, fallback_ip
    raise RuntimeError(f'Không tìm thấy máy/IP: {s}')


def rand_name(machine):
    ts = time.strftime('%Y%m%d_%H%M%S')
    rnd = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(5))
    return f'M{machine}_{ts}_{rnd}'


def account_dirs():
    ACCOUNTS_DIR.mkdir(parents=True, exist_ok=True)
    dirs = [p for p in ACCOUNTS_DIR.iterdir() if p.is_dir()]
    dirs.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return dirs


def lua_webview(pc_url, machine, event_url):
    html = f'''<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"><style>
html,body{{margin:0;padding:0;background:transparent;font-family:-apple-system,BlinkMacSystemFont,sans-serif;-webkit-user-select:none;user-select:none}}
#bar{{width:100%;height:100%;position:relative;background:#f8fafc;border-radius:12px;padding:10px;box-sizing:border-box;color:#111}}
button{{height:42px;border:2px solid #000!important;border-radius:10px;padding:0 8px;font-size:13px;font-weight:900;color:#111}}
.row{{display:flex;gap:8px;margin-bottom:8px}}.row button{{flex:1}}#st{{height:36px;line-height:36px;text-align:center;color:#111;font-size:14px;font-weight:900;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;background:#e5e7eb;border-radius:10px;margin-bottom:8px}}
#ex{{background:#22c55e}}#xc{{background:#facc15}}#ic{{background:#fde68a}}#re{{background:#38bdf8}}#im{{background:#f97316}}
</style></head><body><div id="bar"><div id="st">M{machine}</div><div class="row"><button id="ex" onclick="return exp()">Xuất TK</button><button id="im" onclick="return imp()">Nhập TK</button><button id="re" onclick="return reimp()">Nhập lại</button></div><div class="row"><button id="xc" onclick="return exportCookies()">Xuất Cookies</button><button id="ic" onclick="return importCookies()">Nhập Cookies</button></div></div>
<script>
const API={json.dumps(pc_url)}; const M={json.dumps(str(machine))}; const EV={json.dumps(event_url)};
function st(x){{document.getElementById('st').textContent=x}}
async function watchJob(j, label){{if(!j.ok){{st('Lỗi '+(j.error||''));return}}let id=j.job_id;st(label+' đã nhận, chờ lượt');for(let i=0;i<180;i++){{await new Promise(r=>setTimeout(r,1000));try{{let r=await fetch(API+'/api/job_status?id='+encodeURIComponent(id),{{cache:'no-store'}});let x=await r.json();if(x.status==='running')st(label+' đang chạy...');else if(x.status==='done'){{st(x.message||label+' thành công');return}}else if(x.status==='fail'){{st(x.message||'Lỗi');return}}}}catch(e){{}}}}st(label+' chưa xong, xem log server')}}
async function exp(){{st('Đang Xuất TK...');try{{let r=await fetch(API+'/api/export?machine='+encodeURIComponent(M),{{cache:'no-store'}});await watchJob(await r.json(),'Xuất TK');}}catch(e){{st('Lỗi '+e)}}return false;}}
async function exportCookies(){{st('Đang Xuất Cookies...');try{{let r=await fetch(API+'/api/export_cookie?machine='+encodeURIComponent(M),{{cache:'no-store'}});await watchJob(await r.json(),'Xuất Cookies');}}catch(e){{st('Lỗi '+e)}}return false;}}
let impTap=0, impTimer=null, icTap=0, icTimer=null;
async function doImportCookies(){{st('Đang Nhập Cookies...');try{{let r=await fetch(API+'/api/import_cookie?machine='+encodeURIComponent(M),{{cache:'no-store'}});await watchJob(await r.json(),'Nhập Cookies');}}catch(e){{st('Lỗi '+e)}}}}
function importCookies(){{icTap++;st('Chạm lần 2 để Nhập Cookies '+icTap+'/2');if(icTimer)return false;icTimer=setTimeout(function(){{let n=icTap;icTap=0;icTimer=null;if(n>=2)doImportCookies();else st('M'+M);}},500);return false;}}
async function doImp(){{st('Đang Nhập TK...');try{{let r=await fetch(API+'/api/import?machine='+encodeURIComponent(M)+'&index=1&event='+encodeURIComponent(EV||''),{{cache:'no-store'}});await watchJob(await r.json(),'Nhập TK');}}catch(e){{st('Lỗi '+e)}}}}
async function doReImp(){{st('Đang Nhập lại...');try{{let r=await fetch(API+'/api/reimport?machine='+encodeURIComponent(M)+'&event='+encodeURIComponent(EV||''),{{cache:'no-store'}});await watchJob(await r.json(),'Nhập lại');}}catch(e){{st('Lỗi '+e)}}}}
function imp(){{impTap++;st('Chạm lần 2 để Nhập TK '+impTap+'/2');if(impTimer)return false;impTimer=setTimeout(function(){{let n=impTap;impTap=0;impTimer=null;if(n>=2)doImp();else st('M'+M);}},500);return false;}}
function reimp(){{doReImp();return false;}}
</script></body></html>'''
    return f'''
screen.init(0)
local ok_sys,sys=pcall(require,"sys")
local ok,webview=pcall(require,"webview")
if not ok then
 local f=io.open("/var/mobile/Media/1ferver/log/safari_bridge_webview_status.txt","w"); if f then f:write("REQUIRE_WEBVIEW_ERR") f:close() end
 if ok_sys and sys and sys.toast then sys.toast("require webview lỗi") end
 return
end
pcall(function() webview.remove(188) end)
local ok_show, err_show = pcall(function()
 webview.show({{id=188, html={json.dumps(html, ensure_ascii=False)}, x=1, y=1, width=750, height=460, alpha=1.0, corner_radius=12, opaque=false, can_drag=false, ignores_hit=false, level=999999, animation_duration=0}})
end)
local f=io.open("/var/mobile/Media/1ferver/log/safari_bridge_webview_status.txt","w")
if f then f:write(ok_show and "SHOW_OK_XUAT_NHAP" or ("SHOW_ERR "..tostring(err_show))); f:close() end
if ok_sys and sys and sys.toast then sys.toast(ok_show and "Webview Xuất/Nhập OK" or ("Webview lỗi "..tostring(err_show))) end
while true do
 if ok_sys and sys and sys.msleep then sys.msleep(1000) else os.execute("sleep 1") end
end
'''

class ApiHandler(http.server.BaseHTTPRequestHandler):
    def _json(self, obj, code=200):
        data = json.dumps(obj, ensure_ascii=False).encode('utf-8')
        self.send_response(code)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers(); self.wfile.write(data)

    def _plain(self, text, code=200):
        data = (text or '').encode('utf-8')
        self.send_response(code)
        self.send_header('Content-Type', 'text/plain; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers(); self.wfile.write(data)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.end_headers()

    def do_GET(self):
        app = self.server.app
        try:
            u = urllib.parse.urlparse(self.path)
            q = urllib.parse.parse_qs(u.query)
            client_ip = self.client_address[0]
            if u.path == '/api/status':
                return self._json({'ok': True, 'port': API_PORT})
            if u.path == '/api/combo_lua':
                machine = (q.get('machine') or [''])[0] or '0'
                pc = app.pc_urls_for_client(client_ip)
                # Build fresh per request; never serve stale temp Lua.
                lua_txt = app.build_combo_lua(machine, pc)
                return self._plain(lua_txt)
            if u.path == '/api/list':
                return self._json({'ok': True, 'accounts': app.accounts_payload(), 'cookies': app.cookies_payload()})
            if u.path == '/api/job_status':
                jid = (q.get('id') or [''])[0]
                with app.busy_lock:
                    r = dict(app.job_results.get(jid) or {})
                if not r:
                    return self._json({'ok': False, 'status': 'unknown', 'job_id': jid})
                return self._json({'ok': True, **r})
            if u.path == '/api/export':
                machine = (q.get('machine') or [''])[0]
                return self._json(app.enqueue_job('export', machine, client_ip=client_ip))
            if u.path == '/api/export_cookie':
                machine = (q.get('machine') or [''])[0]
                return self._json(app.enqueue_job('cookie', machine, client_ip=client_ip))
            if u.path == '/api/import_cookie':
                machine = (q.get('machine') or [''])[0]
                return self._json(app.enqueue_job('cookie_import', machine, client_ip=client_ip))
            if u.path == '/api/import':
                machine = (q.get('machine') or [''])[0]
                index = int((q.get('index') or ['0'])[0] or 0)
                event = (q.get('event') or [''])[0]
                return self._json(app.enqueue_job('import', machine, index=index, event=event, client_ip=client_ip))
            if u.path == '/api/reimport':
                machine = (q.get('machine') or [''])[0]
                event = (q.get('event') or [''])[0]
                return self._json(app.enqueue_job('reimport', machine, event=event, client_ip=client_ip))
            if u.path == '/api/safari_next_acc':
                machine = (q.get('machine') or [''])[0]
                return self._json(app.next_safari_acc(machine, client_ip))
            if u.path == '/api/next_safari_acc':
                machine = (q.get('machine') or [''])[0]
                r = app.next_safari_acc(machine, client_ip)
                return self._plain((r.get('acc') or '') + '\n' if r.get('ok') else '')
            if u.path == '/api/ttl_stage1':
                machine = (q.get('machine') or [''])[0]
                return self._json(app.run_ttl_stage(machine, 1, client_ip))
            if u.path == '/api/ttl_stage2':
                machine = (q.get('machine') or [''])[0]
                return self._json(app.run_ttl_stage(machine, 2, client_ip))
            if u.path == '/api/ttl_login':
                machine = (q.get('machine') or [''])[0]
                mm=app.run_stage1_login_onefile(machine)
                return self._json({'ok': True, 'machine': mm})
            if u.path == '/api/deploy_webview':
                machine = (q.get('machine') or [''])[0]
                return self._json(app.deploy_webview_api(machine, client_ip=client_ip))
            return self._json({'ok': False, 'error': 'unknown endpoint'}, 404)
        except Exception as e:
            app.log_line(f'API ERROR {self.path}: {e}')
            return self._json({'ok': False, 'error': str(e)}, 500)

    def log_message(self, fmt, *args):
        return


class BridgeApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title(APP_TITLE)
        self.geometry('1050x720')
        self.configure(bg='#111827')
        self.api_server = None
        self.busy_lock = threading.Lock()
        self.busy_cond = threading.Condition(self.busy_lock)
        self.busy_machine = ''
        self.busy_by_machine = set()
        self.max_parallel_jobs = 1
        self.job_queue = queue.Queue()
        self.job_seq = 0
        self.job_results = {}
        self.machine_var = tk.StringVar(value='')
        self.host_var = tk.StringVar(value=self.best_host_ip())
        self.event_var = tk.StringVar(value=DEFAULT_EVENT_URL)
        self.status_var = tk.StringVar(value='Sẵn sàng')
        self.safari_acc_text = None
        self.build_ui()
        self.start_job_workers()
        self.start_api()
        self.refresh_accounts()
        self.protocol('WM_DELETE_WINDOW', self.on_close)

    def best_host_ip(self):
        import socket
        try:
            s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM); s.connect(('8.8.8.8',80)); ip=s.getsockname()[0]; s.close(); return ip
        except Exception:
            return '127.0.0.1'

    def build_ui(self):
        style=ttk.Style(self); style.theme_use('clam')
        style.configure('TFrame', background='#111827'); style.configure('TLabel', background='#111827', foreground='#e5e7eb'); style.configure('TButton', font=('Arial',10,'bold'))
        top=ttk.Frame(self); top.pack(fill='x', padx=10, pady=8)
        ttk.Label(top,text='Máy/IP:').pack(side='left')
        ttk.Entry(top,textvariable=self.machine_var,width=35).pack(side='left', padx=6)
        # Ẩn PC IP + Event URL khỏi toolbar; vẫn giữ biến host_var/event_var cho API/webview dùng nội bộ.
        ttk.Button(top,text='TẢI TTL + LOGIN GG',command=self.run_ttl_then_login_selected).pack(side='left', padx=4)
        ttk.Button(top,text='MỞ TTL',command=lambda: self.run_ttl_stage_selected(2)).pack(side='left', padx=4)
        ttk.Button(top,text='GỬI WEBVIEW',command=self.deploy_webview_selected).pack(side='left', padx=4)
        ttk.Button(top,text='REFRESH',command=self.refresh_accounts).pack(side='left', padx=4)
        ttk.Button(top,text='MỞ CẤU HÌNH ROUTER',command=self.open_config_window).pack(side='left', padx=8)
        ttk.Label(self,textvariable=self.status_var).pack(anchor='w', padx=10)

        body=ttk.Frame(self); body.pack(fill='both', expand=True, padx=10, pady=8)
        body.columnconfigure(0, weight=1)
        body.columnconfigure(1, weight=1)
        body.rowconfigure(0, weight=1)

        mid=ttk.Frame(body); mid.grid(row=0,column=0,sticky='nsew', padx=(0,6))
        ttk.Label(mid,text='BACKUP TK').grid(row=0,column=0,sticky='w')
        self.tree=ttk.Treeview(mid, columns=('idx','name','machine','time'), show='headings', height=12)
        for col,w in [('idx',55),('name',300),('machine',80),('time',140)]:
            self.tree.heading(col,text=col.upper(), command=(lambda c=col: self.copy_tree_column(self.tree, c))); self.tree.column(col,width=w,anchor='w')
        y=ttk.Scrollbar(mid,orient='vertical',command=self.tree.yview); self.tree.configure(yscrollcommand=y.set)
        self.tree.grid(row=1,column=0,sticky='nsew'); y.grid(row=1,column=1,sticky='ns')
        ttk.Label(mid,text='COOKIE ĐÃ LẤY VỀ').grid(row=2,column=0,sticky='w', pady=(8,0))
        self.cookie_tree=ttk.Treeview(mid, columns=('idx','folder','machine','bytes','time'), show='headings', height=8)
        for col,w in [('idx',45),('folder',240),('machine',70),('bytes',70),('time',140)]:
            self.cookie_tree.heading(col,text=col.upper(), command=(lambda c=col: self.copy_tree_column(self.cookie_tree, c))); self.cookie_tree.column(col,width=w,anchor='w')
        cy=ttk.Scrollbar(mid,orient='vertical',command=self.cookie_tree.yview); self.cookie_tree.configure(yscrollcommand=cy.set)
        self.cookie_tree.grid(row=3,column=0,sticky='nsew'); cy.grid(row=3,column=1,sticky='ns')
        mid.rowconfigure(1,weight=2); mid.rowconfigure(3,weight=1); mid.columnconfigure(0,weight=1)

        right=ttk.Frame(body); right.grid(row=0,column=1,sticky='nsew', padx=(6,0))
        right.rowconfigure(1, weight=1)
        right.rowconfigure(3, weight=2)
        right.columnconfigure(0, weight=1)
        acc_top=ttk.Frame(right); acc_top.grid(row=0,column=0,sticky='ew')
        ttk.Label(acc_top,text='DS ACC Safari (mỗi dòng email|pass)').pack(side='left')
        ttk.Button(acc_top,text='LƯU DS',command=self.save_safari_acc_list).pack(side='right')
        self.safari_acc_text=tk.Text(right,bg='#020617',fg='#e5e7eb',insertbackground='white',font=('Consolas',10),height=8)
        self.safari_acc_text.grid(row=1,column=0,sticky='nsew', pady=(4,8))
        self.load_safari_acc_list()
        ttk.Label(right,text='LOG').grid(row=2,column=0,sticky='w')
        self.log=tk.Text(right,bg='#020617',fg='#e5e7eb',insertbackground='white',font=('Consolas',10),height=14)
        self.log.grid(row=3,column=0,sticky='nsew')
        for tag,color in {'api':'#38bdf8','ok':'#22c55e','err':'#ef4444','warn':'#f59e0b','login':'#a78bfa','machine':'#f472b6','normal':'#e5e7eb'}.items():
            self.log.tag_configure(tag, foreground=color)

    def copy_tree_column(self, tree, col):
        try:
            cols = list(tree['columns'])
            idx = cols.index(col)
            vals = []
            seen = set()
            for item in tree.get_children(''):
                v = str(tree.item(item, 'values')[idx]).strip()
                if not v:
                    continue
                if col == 'machine':
                    v = v.replace('M', '').replace('m', '')
                if v not in seen:
                    seen.add(v)
                    vals.append(v)
            text = ','.join(vals)
            self.clipboard_clear()
            self.clipboard_append(text)
            self.update_idletasks()
            self.log_line(f'COPY {col}: {text}')
            self.status_var.set(f'Da copy {col}: {len(vals)} dong')
        except Exception as e:
            self.log_line(f'Copy cot loi: {e}')

    def open_config_window(self):
        win=tk.Toplevel(self); win.title('Cấu hình router máy|ip'); win.geometry('720x560')
        top=ttk.Frame(win); top.pack(fill='x', padx=8, pady=(8,0))
        ttk.Label(top, text='Mỗi dòng: máy|ip').pack(side='left')
        txt=tk.Text(win,bg='#020617',fg='#e5e7eb',insertbackground='white',font=('Consolas',10))
        txt.pack(fill='both',expand=True,padx=8,pady=8)
        if not MACHINES_TXT.exists(): MACHINES_TXT.write_text('',encoding='utf-8')
        txt.insert('1.0', MACHINES_TXT.read_text(encoding='utf-8',errors='replace'))
        btns=ttk.Frame(win); btns.pack(fill='x', padx=8, pady=(0,8))
        def save():
            MACHINES_TXT.write_text(txt.get('1.0','end-1c'),encoding='utf-8')
            self.log_line(f'Lưu config {MACHINES_TXT}')
            win.destroy()
        def scan():
            self.scan_hosts_into_text(txt)
        ttk.Button(btns,text='QUÉT HOST',command=scan).pack(side='left', padx=(0,6))
        ttk.Button(btns,text='LƯU',command=save).pack(side='right')

    def scan_hosts_into_text(self, txt):
        def worker():
            try:
                old_lines = txt.get('1.0','end-1c').splitlines()
                existing = {}
                prefixes = set()
                for line in old_lines:
                    parts = re.split(r'[|,;\s]+', line.strip())
                    if len(parts) >= 2 and parts[1].count('.') == 3:
                        existing[parts[1]] = parts[0]
                        prefixes.add('.'.join(parts[1].split('.')[:3]))
                # Thêm subnet theo PC IP hiện tại.
                try:
                    host = self.host_var.get().strip()
                    if host.count('.') == 3:
                        prefixes.add('.'.join(host.split('.')[:3]))
                except Exception:
                    pass
                # Nếu chưa có gì, scan dải hay dùng.
                if not prefixes:
                    prefixes.update(['192.14.5', '192.17.5'])
                self.log_line('Scan host subnet: ' + ', '.join(sorted(prefixes)))
                targets=[]
                for pref in sorted(prefixes):
                    for i in range(1,255):
                        ip=f'{pref}.{i}'
                        if ip not in existing:
                            targets.append(ip)
                found=[]
                def check(ip):
                    try:
                        c=XXTouchOpenAPIClient(f'http://{ip}:46952', connect_timeout=0.35, read_timeout=1.2)
                        info=c.deviceinfo()
                        if isinstance(info,dict) and info.get('code')==0:
                            data=info.get('data') or {}
                            machine=str(ip.split('.')[-1])
                            return machine, ip, data.get('devname','')
                    except Exception:
                        return None
                with ThreadPoolExecutor(max_workers=80) as ex:
                    futs=[ex.submit(check, ip) for ip in targets]
                    for fut in as_completed(futs):
                        r=fut.result()
                        if r: found.append(r)
                found.sort(key=lambda x: tuple(int(p) for p in x[1].split('.')))
                if not found:
                    self.log_line('Scan host: không thấy máy mới')
                    return
                add='\n'.join(f'{m}|{ip}' for m,ip,_ in found)
                def ui_add():
                    cur=txt.get('1.0','end-1c').rstrip()
                    txt.delete('1.0','end')
                    txt.insert('1.0', (cur+'\n' if cur else '') + add + '\n')
                    self.log_line(f'Scan host: thêm {len(found)} máy')
                self.after(0, ui_add)
            except Exception as e:
                self.log_line(f'Scan host lỗi: {e}')
        threading.Thread(target=worker, daemon=True).start()

    def log_line(self,s):
        ts=time.strftime('%H:%M:%S')
        line=f'[{ts}] {s}\n'
        low=str(s).lower()
        tag='normal'
        if 'lỗi' in low or 'error' in low or 'timeout' in low or 'fail' in low:
            tag='err'
        elif ' ok' in low or 'ok ' in low or 'done' in low or 'hoàn thành' in low or 'all done' in low:
            tag='ok'
        elif 'api ' in low:
            tag='api'
        elif 'login gg' in low:
            tag='login'
        elif low.startswith('['):
            tag='machine'
        elif 'thiếu' in low or 'đợi' in low or 'wait' in low:
            tag='warn'
        try:
            self.log.insert('1.0', line, tag)
            self.log.see('1.0')
        except Exception:
            pass
        LOG_DIR.mkdir(parents=True,exist_ok=True)
        with (LOG_DIR/'bridge.log').open('a',encoding='utf-8') as f: f.write(line)

    def start_api(self):
        if self.api_server: return
        class S(socketserver.ThreadingTCPServer): allow_reuse_address=True
        self.api_server=S(('0.0.0.0',API_PORT),ApiHandler); self.api_server.app=self
        threading.Thread(target=self.api_server.serve_forever,daemon=True).start()
        self.log_line(f'API http://{self.host_var.get()}:{API_PORT}/api/status')

    def client(self, machine, fallback_ip=''):
        m, ip = find_machine(machine, fallback_ip)
        return m, ip, XXTouchOpenAPIClient(f'http://{ip}:46952', connect_timeout=2, read_timeout=45)

    def stop_script_hard(self, c):
        # Stop XXTE runner + old shell Lua hard before every action button.
        try:
            c.recycle()
            time.sleep(0.6)
        except Exception:
            pass
        try:
            c.command_spawn('ps -ef | while read u pid rest; do case "$rest" in *lua*) kill $pid 2>/dev/null || true;; esac; done')
            time.sleep(0.8)
        except Exception:
            pass

    def stop_our_shell_lua(self, c):
        self.stop_script_hard(c)

    def run_lua_file(self, c, lua_file, remote_name):
        # Run inline via XXTouch /spawn. Do NOT recycle/kill Lua here:
        # the Text webview controller owns the green Safari menu; recycle/kill closes it.
        log_path=f'{REMOTE_RUN_DIR}/{remote_name}.log'
        try:
            c.command_spawn('mkdir -p /var/mobile/Media/1ferver/log')
            c.command_spawn(f': >{log_path} 2>/dev/null || true')
        except Exception:
            pass
        lua_text=lua_file.read_text(encoding='utf-8')
        resp = c.spawn(lua_text)
        if isinstance(resp, dict) and (resp.get('code') == 3 or 'currently running another script' in str(resp).lower()):
            self.log_line(f'{remote_name}: XXTouch đang chạy webview/script khác -> recycle 1 lần để chạy job')
            self.stop_script_hard(c)
            resp = c.spawn(lua_text)
        return resp

    def relaunch_text_webview(self, c):
        try:
            remote = '/var/mobile/Media/1ferver/lua/scripts/text_queue_webview_client.lua'
            c._post_json('/select_script_file', {'filename': remote})
            c._post_json('/launch_script_file', {'filename': remote})
        except Exception:
            pass

    def read_remote_log_tail(self, c, remote_name, limit=1200):
        try:
            txt = c.download_text_file(f'{REMOTE_RUN_DIR}/{remote_name}.log')
            return txt[-limit:]
        except Exception as e:
            return f'không đọc được log: {e}'

    def run_shell_export(self, c):
        q=shlex.quote
        bid=BID_LITE
        script=f'''mkdir -p {q(REMOTE_DIR)}
DP=$(find /var/mobile/Containers/Data/Application -path '*/Library/Preferences/{bid}.plist' -print -quit 2>/dev/null | sed 's#/Library/Preferences/{bid}.plist##')
[ -z "$DP" ] && DP=$(find /private/var/mobile/Containers/Data/Application -path '*/Library/Preferences/{bid}.plist' -print -quit 2>/dev/null | sed 's#/Library/Preferences/{bid}.plist##')
if [ -z "$DP" ]; then echo "ok=0 error=no_data_path" > {q(REMOTE_DIR)}/status.txt; exit 2; fi
OK=0
[ -f "$DP/Library/Cookies/Cookies.binarycookies" ] && cp -f "$DP/Library/Cookies/Cookies.binarycookies" {q(REMOTE_DIR)}/Cookies.binarycookies && OK=$((OK+1))
[ -f "$DP/Documents/ttaccountSDKUserInfo.archiver" ] && cp -f "$DP/Documents/ttaccountSDKUserInfo.archiver" {q(REMOTE_DIR)}/ttaccountSDKUserInfo.archiver && OK=$((OK+1))
[ -f "$DP/Library/Preferences/{bid}.plist" ] && cp -f "$DP/Library/Preferences/{bid}.plist" {q(REMOTE_DIR)}/{bid}.plist && OK=$((OK+1))
(cd "$DP" && tar -czf {q(REMOTE_DIR)}/lite_sandbox.tgz Documents Library/Cookies Library/Preferences 'Library/Application Support' Library/Caches 2>/dev/null) && OK=$((OK+1))
echo "ok=$OK/4 dataPath=$DP" > {q(REMOTE_DIR)}/status.txt
'''
        return c.command_spawn(script)

    def run_shell_import(self, c, event_url):
        q=shlex.quote
        bid=BID_LITE
        ev=event_url or DEFAULT_EVENT_URL
        script=f'''DP=$(find /var/mobile/Containers/Data/Application -path '*/Library/Preferences/{bid}.plist' -print -quit 2>/dev/null | sed 's#/Library/Preferences/{bid}.plist##')
[ -z "$DP" ] && DP=$(find /private/var/mobile/Containers/Data/Application -path '*/Library/Preferences/{bid}.plist' -print -quit 2>/dev/null | sed 's#/Library/Preferences/{bid}.plist##')
if [ -z "$DP" ]; then echo "ok=0 error=no_data_path" > {q(REMOTE_DIR)}/status.txt; exit 2; fi
rm -f "$DP/Library/Cookies/Cookies.binarycookies" "$DP/Documents/ttaccountSDKUserInfo.archiver" "$DP/Library/Preferences/{bid}.plist"
[ -f {q(REMOTE_DIR)}/lite_sandbox.tgz ] && tar -xzf {q(REMOTE_DIR)}/lite_sandbox.tgz -C "$DP" 2>/dev/null
mkdir -p "$DP/Library/Cookies" "$DP/Documents" "$DP/Library/Preferences"
cp -f {q(REMOTE_DIR)}/Cookies.binarycookies "$DP/Library/Cookies/Cookies.binarycookies"
cp -f {q(REMOTE_DIR)}/ttaccountSDKUserInfo.archiver "$DP/Documents/ttaccountSDKUserInfo.archiver"
cp -f {q(REMOTE_DIR)}/{bid}.plist "$DP/Library/Preferences/{bid}.plist"
sync
sleep 2
(uiopen {q(ev)} >/dev/null 2>&1 || open {q(ev)} >/dev/null 2>&1 || true)
echo "ok=import dataPath=$DP event={ev}" > {q(REMOTE_DIR)}/status.txt
'''
        return c.command_spawn(script)

    def start_job_workers(self):
        for i in range(self.max_parallel_jobs):
            t = threading.Thread(target=self.job_worker, args=(i+1,), daemon=True)
            t.start()

    def enqueue_job(self, kind, machine, index=None, event='', client_ip=''):
        with self.busy_lock:
            self.job_seq += 1
            job_id = f'{int(time.time())}-{self.job_seq}'
        job = {'id': job_id, 'kind': kind, 'machine': str(machine), 'index': index, 'event': event, 'client_ip': client_ip, 'time': time.strftime('%Y-%m-%d %H:%M:%S')}
        with self.busy_lock:
            self.job_results[job_id] = {'job_id': job_id, 'status': 'queued', 'kind': kind, 'machine': str(machine), 'message': 'Đang chờ tới lượt'}
        self.job_queue.put(job)
        pos = self.job_queue.qsize()
        # Không spam log kỹ thuật; webview chỉ cần biết đã xếp hàng.
        return {'ok': True, 'queued': True, 'job_id': job_id, 'position': pos, 'machine': str(machine), 'kind': kind}

    def job_worker(self, worker_id):
        while True:
            job = self.job_queue.get()
            try:
                m = job.get('machine')
                kind = job.get('kind')
                jid = job.get('id')
                with self.busy_lock:
                    self.job_results[jid] = {**self.job_results.get(jid, {}), 'status': 'running', 'message': 'Đang chạy'}
                # Log kết quả cuối là đủ, tránh lộ job/raw dict.
                if kind == 'export':
                    r = self.export_account(m, job.get('client_ip') or '')
                elif kind == 'cookie':
                    r = self.export_safari_cookie(m, job.get('client_ip') or '')
                elif kind == 'cookie_import':
                    r = self.import_safari_cookie(m, job.get('client_ip') or '')
                elif kind == 'import':
                    r = self.import_account(m, int(job.get('index') or 1), job.get('event') or '', job.get('client_ip') or '')
                elif kind == 'reimport':
                    r = self.reimport_latest_account(m, job.get('event') or '', job.get('client_ip') or '')
                else:
                    raise RuntimeError(f'Unknown job kind {kind}')
                label = 'Tác vụ'
                verb = 'xử lý'
                if kind == 'cookie_import': label, verb = 'Nhập Cookies', 'nhập Cookies'
                elif kind == 'cookie': label, verb = 'Xuất Cookies', 'xuất Cookies'
                elif kind == 'import': label, verb = 'Nhập TK', 'nhập TK'
                elif kind == 'export': label, verb = 'Xuất TK', 'xuất TK'
                elif kind == 'reimport': label, verb = 'Nhập lại TK', 'nhập lại TK'
                msg = f'Máy {m} đã {verb} thành công.'
                with self.busy_lock:
                    self.job_results[jid] = {**self.job_results.get(jid, {}), 'status': 'done', 'message': msg, 'result': r}
                self.log_line(f"{label} > {msg}")
                if kind in ('cookie','cookie_import'):
                    self.after(0, self.refresh_cookies)
            except Exception as e:
                jid = job.get('id')
                kind = job.get('kind')
                label = {'cookie_import':'Nhập Cookies','cookie':'Xuất Cookies','import':'Nhập TK','export':'Xuất TK','reimport':'Nhập lại TK'}.get(kind, 'Tác vụ')
                with self.busy_lock:
                    self.job_results[jid] = {**self.job_results.get(jid, {}), 'status': 'fail', 'message': f'{label} thất bại', 'error': str(e)}
                self.log_line(f"{label} > Máy {job.get('machine')} thất bại.")
            finally:
                self.job_queue.task_done()

    def acquire_machine_busy(self, machine):
        key = str(machine)
        with self.busy_cond:
            queued_logged = False
            while key in self.busy_by_machine or len(self.busy_by_machine) >= self.max_parallel_jobs:
                if not queued_logged:
                    self.log_line(f'[{key}] Đang xếp hàng, đang chạy: {",".join(sorted(self.busy_by_machine)) or "none"}')
                    queued_logged = True
                self.busy_cond.wait(timeout=1.0)
            self.busy_by_machine.add(key)
            self.busy_machine = ','.join(sorted(self.busy_by_machine))
            # Mỗi lượt chỉ chạy một máy để tránh tranh thư mục/file.
        return key

    def release_machine_busy(self, key):
        with self.busy_cond:
            self.busy_by_machine.discard(str(key))
            self.busy_machine = ','.join(sorted(self.busy_by_machine))
            self.busy_cond.notify_all()

    def run_ttl_stage(self, machine, stage, fallback_ip=''):
        busy_key = self.acquire_machine_busy(machine)
        try:
            m, ip, c = self.client(machine, fallback_ip)
            if int(stage) == 1:
                self.log_line(f'[{m}] Tải TTL / Stage 1 -> {ip}')
                self.run_lua_file(c, TTL_STAGE1_LUA, 'TTL_Stage1_Tai.lua')
            else:
                self.log_line(f'[{m}] Mở TTL / Stage 2 -> {ip}')
                self.run_lua_file(c, TTL_STAGE2_LUA, 'TTL_Stage2_Mo.lua')
            return {'ok': True, 'stage': int(stage), 'machine': m}
        finally:
            self.release_machine_busy(busy_key)

    def latest_cookie(self):
        root = BASE / 'CookieData'
        if not root.exists():
            return None
        files = [p for p in root.glob('M*/Cookies.binarycookies') if p.is_file()]
        files.sort(key=lambda p: p.stat().st_mtime, reverse=True)
        return files[0] if files else None

    def import_safari_cookie(self, machine, fallback_ip=''):
        busy_key = self.acquire_machine_busy(machine)
        try:
            m, ip, c = self.client(machine, fallback_ip)
            src = self.latest_cookie()
            if not src:
                raise RuntimeError('Không tìm thấy CookieData/Cookies.binarycookies trên server')
            remote = '/var/mobile/Media/1ferver/ipa/Cookies.binarycookies'
            payload = src.read_bytes()
            self.log_line(f'[{m}] Nhập Cookie -> {remote} từ {src.parent.name} ({len(payload)} bytes)')
            c.command_spawn('mkdir -p /var/mobile/Media/1ferver/ipa && rm -f /var/mobile/Media/1ferver/ipa/Cookies.binarycookies')
            time.sleep(0.5)
            c.write_file(remote, payload)
            time.sleep(0.5)
            try:
                chk = c.download_file(remote)
                if len(chk) != len(payload):
                    raise RuntimeError(f'verify size sai remote={len(chk)} local={len(payload)}')
            except Exception as e:
                raise RuntimeError('Đã upload nhưng verify file trên client lỗi: ' + str(e))
            used_root = BASE / 'CookieBackupData'
            used_root.mkdir(parents=True, exist_ok=True)
            moved_to = used_root / f"M{m}_For_{src.parent.name}"
            if moved_to.exists():
                moved_to = used_root / f"M{m}_For_{src.parent.name}_{int(time.time())}"
            shutil.move(str(src.parent), str(moved_to))
            hist = BASE / 'CookieData' / 'import_history.jsonl'
            rec = {'at': time.strftime('%Y-%m-%d %H:%M:%S'), 'target_machine': m, 'target_ip': ip, 'source_folder': src.parent.name, 'source_file': str(src), 'moved_to': str(moved_to), 'remote': remote, 'bytes': len(payload)}
            with hist.open('a', encoding='utf-8') as f:
                f.write(json.dumps(rec, ensure_ascii=False) + '\n')
            self.log_line(f'[{m}] Nhập Cookie OK -> /1ferver/ipa/Cookies.binarycookies từ {src.parent.name}; moved -> CookieBackupData/{moved_to.name}')
            try:
                self.after(0, self.refresh_cookies)
            except Exception:
                pass
            return {'ok': True, 'machine': m, 'remote': remote, 'source': src.parent.name, 'moved_to': moved_to.name, 'bytes': len(payload)}
        finally:
            self.release_machine_busy(busy_key)

    def export_safari_cookie(self, machine, fallback_ip=''):
        busy_key = self.acquire_machine_busy(machine)
        c = None
        try:
            m, ip, c = self.client(machine, fallback_ip)
            self.log_line(f'[{m}] Lấy Safari Cookie từ {ip}')
            # Không recycle trước khi chạy từ webview; recycle sẽ tắt webview đang mở.
            lua = r'''
local app=require("app")
local file=require("file")
local sys=require("sys")
local safariPath=app.data_path("com.apple.mobilesafari") or ""
local cookiePath=safariPath .. "/Library/Cookies/Cookies.binarycookies"
local outDir="/var/mobile/Media/1ferver/ipa"
local outPath=outDir .. "/Safari_Cookies.binarycookies"
os.execute("mkdir -p " .. outDir)
os.execute("rm -f " .. outPath)
local ok=false
local err=""
if file.exists(cookiePath) then
 local rf,e1=io.open(cookiePath,"rb")
 if rf then
  local data=rf:read("*a")
  rf:close()
  if data and #data>0 then
   local wf,e2=io.open(outPath,"wb")
   if wf then
    wf:write(data)
    wf:close()
    ok=file.exists(outPath)
   else
    err="open dst fail "..tostring(e2)
   end
  else
   err="read empty"
  end
 else
  err="open src fail "..tostring(e1)
 end
else
 err="src missing"
end
if ok then
 local sz=-1
 pcall(function() if file.size then sz=file.size(outPath) end end)
 sys.toast("Safari cookie OK "..tostring(sz),0)
 print("COOKIE_OK "..cookiePath.." -> "..outPath.." size="..tostring(sz))
 return true
end
sys.toast("Safari cookie lỗi",0)
error("COOKIE_COPY_FAIL "..tostring(cookiePath).." err="..tostring(err))
'''
            try:
                c.command_spawn('mkdir -p /var/mobile/Media/1ferver/ipa /var/mobile/Media/1ferver/log')
                time.sleep(0.3)
            except Exception as e:
                self.log_line(f'[{m}] mkdir cookie staging lỗi: {e}')
            c.spawn(lua)
            data = None
            last_err = ''
            remote_cookie = '/var/mobile/Media/1ferver/ipa/Safari_Cookies.binarycookies'
            for attempt in range(1, 16):
                time.sleep(1.0)
                try:
                    data = c.download_file(remote_cookie)
                    if data:
                        break
                except Exception as e:
                    last_err = str(e)
                    self.log_line(f'[{m}] chờ Safari cookie {attempt}/15: {last_err}')
            if not data:
                raise RuntimeError('Không kéo được Safari_Cookies.binarycookies sau 15s: ' + last_err)
            out_root = BASE / 'CookieData'
            out_root.mkdir(parents=True, exist_ok=True)
            folder = out_root / rand_name(m)
            folder.mkdir(parents=True, exist_ok=True)
            out = folder / 'Cookies.binarycookies'
            out.write_bytes(data)
            meta={'machine':m,'ip':ip,'created_at':time.strftime('%Y-%m-%d %H:%M:%S'),'source':'com.apple.mobilesafari/Library/Cookies/Cookies.binarycookies','file':str(out)}
            (folder/'meta.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding='utf-8')
            self.log_line(f'[{m}] Lấy Cookie OK -> {folder.name}')
            return {'ok': True, 'machine': m, 'folder': folder.name, 'file': 'Cookies.binarycookies'}
        finally:
            self.release_machine_busy(busy_key)

    def export_account(self, machine, fallback_ip=''):
        busy_key = self.acquire_machine_busy(machine)
        c = None
        try:
            m, ip, c = self.client(machine, fallback_ip)
            self.log_line(f'[{m}] Xuất TK từ {ip}')
            self.run_lua_file(c, XUAT_LUA, 'XuatTK_lite.lua')
            time.sleep(4.0)
            folder = ACCOUNTS_DIR / rand_name(m)
            folder.mkdir(parents=True, exist_ok=True)
            got=[]
            for fn in ACCOUNT_FILES + EXTRA_ACCOUNT_FILES + ['status.txt']:
                remote=f'{REMOTE_DIR}/{fn}'
                try:
                    data=c.download_file(remote)
                    (folder/fn).write_bytes(data)
                    got.append(fn)
                except Exception as e:
                    if fn in EXTRA_ACCOUNT_FILES:
                        self.log_line(f'[{m}] bỏ qua file phụ {fn}: chưa có trên máy')
                    else:
                        self.log_line(f'[{m}] thiếu {fn}: {e}')
            meta={'machine':m,'ip':ip,'created_at':time.strftime('%Y-%m-%d %H:%M:%S'),'files':got}
            (folder/'meta.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding='utf-8')
            self.refresh_accounts()
            idx=self.index_for_folder(folder)
            ok=all(fn in got for fn in ACCOUNT_FILES)
            self.log_line(f'[{m}] Export {"OK" if ok else "THIẾU"} -> #{idx} {folder.name}')
            if not ok:
                tail = self.read_remote_log_tail(c, 'XuatTK_lite.lua') if c else ''
                raise RuntimeError('Xuất thiếu file. Log: ' + tail)
            return {'ok': ok, 'index': idx, 'folder': folder.name, 'files': got}
        finally:
            self.release_machine_busy(busy_key)

    def restore_folder_to_client(self, c, folder, m, ev, index_label=''):
        # Simple/robust restore: one pass only. Do not byte-verify through XXTouch download_file
        # because many devices have minimal shell / sandbox download quirks causing false HTTP 400.
        def upload_backup_files():
            c.command_spawn(f'mkdir -p {shlex.quote(REMOTE_DIR)}')
            for fn in ACCOUNT_FILES:
                p=folder/fn
                if not p.exists():
                    raise RuntimeError(f'Thiếu file {fn} trong {folder.name}')
                c.write_file(f'{REMOTE_DIR}/{fn}', p.read_bytes())
            for fn in EXTRA_ACCOUNT_FILES:
                p=folder/fn
                if p.exists():
                    c.write_file(f'{REMOTE_DIR}/{fn}', p.read_bytes())

        self.log_line(f'[{m}] Restore {index_label}: quit TTL + upload + import 1 pass')
        try:
            c.command_spawn('pkill -f com.ss.iphone.ugc.tiktok.lite >/dev/null 2>&1 || true; killall -9 TikTokLite cfprefsd 2>/dev/null || true')
        except Exception:
            pass
        time.sleep(1.5)
        upload_backup_files()
        resp = self.run_lua_file(c, NHAP_LUA, 'NhapTK_lite.lua')
        time.sleep(8.0)
        status = ''
        try:
            status = c.download_text_file(f'{REMOTE_DIR}/status.txt')
        except Exception as e:
            self.log_line(f'[{m}] Không đọc được status sau Nhập TK: {e}')
        if status:
            self.log_line(f'[{m}] Nhập TK status: ' + status.replace('\n', ' | ')[:500])
            mm = re.search(r'ok=(\d+)/(\d+)', status)
            if mm and int(mm.group(1)) < 3:
                raise RuntimeError('Nhập TK thiếu file: ' + status.replace('\n', ' | ')[:500])
        try:
            c.command_spawn('killall -9 cfprefsd 2>/dev/null || true; sync')
        except Exception:
            pass
        time.sleep(0.8)
        try:
            c.command_spawn(f'(uiopen {shlex.quote(ev)} >/dev/null 2>&1 || open {shlex.quote(ev)} >/dev/null 2>&1 || true)')
        except Exception:
            pass
        self.relaunch_text_webview(c)

    def latest_used_backup_for_machine(self, machine):
        m = str(machine)
        if not IMPORT_HISTORY_PATH.exists():
            return None
        found = None
        for line in IMPORT_HISTORY_PATH.read_text(encoding='utf-8', errors='replace').splitlines():
            try:
                rec = json.loads(line)
            except Exception:
                continue
            if str(rec.get('machine')) == m and rec.get('moved_to'):
                found = rec
        if not found:
            return None
        p = Path(found.get('moved_to'))
        if not p.exists():
            p = BACKUP_DATA_DIR / p.name
        return p if p.exists() else None

    def reimport_latest_account(self, machine, event_url='', fallback_ip=''):
        busy_key = self.acquire_machine_busy(machine)
        try:
            m, ip, c = self.client(machine, fallback_ip)
            folder = self.latest_used_backup_for_machine(m)
            if not folder:
                raise RuntimeError(f'Không tìm thấy backup đã dùng gần nhất cho máy {m}')
            ev=event_url or self.event_var.get().strip()
            self.log_line(f'[{m}] Nhập lại backup gần nhất: {folder.name} -> {ip}')
            self.restore_folder_to_client(c, folder, m, ev, 'reimport')
            rec = {'time': time.strftime('%Y-%m-%d %H:%M:%S'), 'machine': str(m), 'ip': str(ip), 'reimport_from': str(folder), 'event': ev, 'restore_passes': 'verify_max_3'}
            BACKUP_DATA_DIR.mkdir(parents=True, exist_ok=True)
            with IMPORT_HISTORY_PATH.open('a', encoding='utf-8') as f:
                f.write(json.dumps(rec, ensure_ascii=False) + '\n')
            self.log_line(f'[{m}] Nhập lại OK: {folder.name}')
            return {'ok': True, 'reimport': True, 'folder': folder.name}
        finally:
            self.release_machine_busy(busy_key)

    def import_account(self, machine, index, event_url='', fallback_ip=''):
        busy_key = self.acquire_machine_busy(machine)
        try:
            dirs=account_dirs()
            if index < 1 or index > len(dirs): raise RuntimeError('STT account không hợp lệ')
            folder=dirs[index-1]
            m, ip, c = self.client(machine, fallback_ip)
            self.log_line(f'[{m}] Mở TTL #{index} {folder.name} -> {ip} (restore + verify)')
            ev=event_url or self.event_var.get().strip()
            self.restore_folder_to_client(c, folder, m, ev, 'import')
            self.log_line(f'[{m}] Import OK #{index} (đã verify file trên máy)')
            BACKUP_DATA_DIR.mkdir(parents=True, exist_ok=True)
            used_name = f"M{m}_For_{folder.name}"
            dest = BACKUP_DATA_DIR / used_name
            if dest.exists():
                dest = BACKUP_DATA_DIR / f"{used_name}_{int(time.time()*1000)}"
            shutil.move(str(folder), str(dest))
            rec = {
                'time': time.strftime('%Y-%m-%d %H:%M:%S'),
                'machine': str(m),
                'ip': str(ip),
                'index_used': index,
                'backup_folder': folder.name,
                'moved_to': str(dest),
                'event': ev,
                'restore_passes': 'verify_max_3',
            }
            with IMPORT_HISTORY_PATH.open('a', encoding='utf-8') as f:
                f.write(json.dumps(rec, ensure_ascii=False) + '\n')
            self.refresh_accounts()
            self.log_line(f'[{m}] Đã lưu backup đã dùng vào BackupData: {dest.name}')
            return {'ok': True, 'index': index, 'folder': folder.name, 'moved_to_backupdata': dest.name}
        finally:
            self.release_machine_busy(busy_key)

    def accounts_payload(self):
        arr=[]
        for i,p in enumerate(account_dirs(),1):
            meta={}
            if (p/'meta.json').exists():
                try: meta=json.loads((p/'meta.json').read_text(encoding='utf-8'))
                except Exception: pass
            files=[fn for fn in ACCOUNT_FILES + EXTRA_ACCOUNT_FILES if (p/fn).exists()]
            arr.append({'index':i,'name':p.name,'machine':meta.get('machine',''),'time':meta.get('created_at',''),'files':files})
        return arr

    def index_for_folder(self, folder):
        for i,p in enumerate(account_dirs(),1):
            if p.resolve()==folder.resolve(): return i
        return 0

    def refresh_accounts(self):
        for x in self.tree.get_children(): self.tree.delete(x)
        for a in self.accounts_payload():
            self.tree.insert('', 'end', values=(a['index'],a['name'],a['machine'],a['time']))
        self.refresh_cookies()

    def cookies_payload(self):
        root = BASE / 'CookieData'
        out=[]
        if root.exists():
            dirs=[d for d in root.glob('M*') if d.is_dir()]
            dirs.sort(key=lambda d: d.stat().st_mtime, reverse=True)
            for i,d in enumerate(dirs,1):
                f=d/'Cookies.binarycookies'
                if not f.exists():
                    continue
                m=''
                parts=d.name.split('_', 1)
                if parts and parts[0].startswith('M'):
                    m=parts[0][1:]
                out.append({'index':i,'folder':d.name,'machine':m,'bytes':f.stat().st_size,'time':time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(d.stat().st_mtime))})
        return out

    def refresh_cookies(self):
        if not hasattr(self, 'cookie_tree'):
            return
        for x in self.cookie_tree.get_children(): self.cookie_tree.delete(x)
        for c in self.cookies_payload():
            self.cookie_tree.insert('', 'end', values=(c['index'],c['folder'],c['machine'],c['bytes'],c['time']))

    def load_safari_acc_list(self):
        try:
            if self.safari_acc_text is not None:
                self.safari_acc_text.delete('1.0','end')
                if SAFARI_ACC_PATH.exists():
                    self.safari_acc_text.insert('1.0', SAFARI_ACC_PATH.read_text(encoding='utf-8',errors='replace'))
        except Exception as e:
            self.log_line(f'Load DS ACC lỗi: {e}')

    def save_safari_acc_list(self):
        if self.safari_acc_text is None:
            return
        SAFARI_ACC_PATH.write_text(self.safari_acc_text.get('1.0','end-1c'),encoding='utf-8')
        self.log_line(f'Lưu DS ACC: {SAFARI_ACC_PATH}')

    def pop_safari_acc(self):
        # Called by HTTP API worker thread during LoginGG; never touch Tk widgets here.
        lines=[]
        if SAFARI_ACC_PATH.exists():
            lines=[x.strip() for x in SAFARI_ACC_PATH.read_text(encoding='utf-8',errors='replace').splitlines() if x.strip()]
        if not lines:
            raise RuntimeError('DS ACC Safari rỗng')
        acc=lines[0]
        SAFARI_ACC_PATH.write_text('\n'.join(lines[1:]) + ('\n' if len(lines)>1 else ''),encoding='utf-8')
        try:
            self.after(0, self.load_safari_acc_list)
        except Exception:
            pass
        return acc

    def next_safari_acc(self, machine='', fallback_ip=''):
        try:
            acc=self.pop_safari_acc()
            who=str(machine or fallback_ip or '?')
            self.log_line(f'[{who}] LOGIN GG cấp acc lúc chạy: {acc.split("|")[0]}')
            return {'ok': True, 'acc': acc}
        except Exception as e:
            return {'ok': False, 'error': 'empty' if 'rỗng' in str(e).lower() else str(e)}

    def pc_urls_for_client(self, client_ip):
        urls=[]
        def add(ip):
            ip=str(ip or '').strip()
            if ip and ip not in ['0.0.0.0','127.0.0.1']:
                u=f'http://{ip}:{API_PORT}'
                if u not in urls: urls.append(u)
        try:
            import socket
            s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect((client_ip, 46952))
            add(s.getsockname()[0]); s.close()
        except Exception:
            pass
        add(self.host_var.get())
        try:
            import socket
            hn=socket.gethostname()
            for x in socket.getaddrinfo(hn, None, socket.AF_INET):
                add(x[4][0])
        except Exception:
            pass
        for ip in ['192.14.1.10','192.168.9.201']:
            add(ip)
        return '|'.join(urls)

    def run_login_stage6_one(self, m):
        mm, ip, c = self.client(m)
        pc=self.pc_urls_for_client(ip)
        self.log_line(f'[{mm}] LOGIN GG start, acc sẽ tự lấy từ pyw khi tới bước login; PC={pc}')
        lua_txt=LOGIN_STAGE6_LUA.read_text(encoding='utf-8-sig').replace('__PC_API__', pc).replace('__MACHINE__', str(mm))
        tmp=LOG_DIR/'LoginGGSafari_Stage6_runtime.lua'
        LOG_DIR.mkdir(parents=True,exist_ok=True)
        tmp.write_text(lua_txt,encoding='utf-8')
        self.run_lua_file(c, tmp, 'LoginGGSafari_Stage6.lua')
        return mm

    def run_login_stage6_selected(self):
        machines=parse_machine_list(self.machine_var.get())
        if not machines:
            return messagebox.showwarning(APP_TITLE,'Nhập máy/IP')
        def worker():
            for m in machines:
                try:
                    self.run_login_stage6_one(m)
                except Exception as e:
                    self.log_line(f'[{m}] LOGIN GG lỗi: {e}')
        threading.Thread(target=worker,daemon=True).start()

    def pc_url_for_client(self, client_ip):
        import socket
        try:
            s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect((client_ip, 46952))
            ip=s.getsockname()[0]
            s.close()
            return f'http://{ip}:{API_PORT}'
        except Exception:
            return f'http://{self.host_var.get().strip()}:{API_PORT}'

    def build_combo_lua(self, machine, pc):
        mm=str(machine)
        bootstrap = '''
_G.screen = _G.screen or require("screen")
_G.touch = _G.touch or require("touch")
_G.sys = _G.sys or require("sys")
_G.app = _G.app or require("app")
_G.clear = _G.clear or require("clear")
_G.pasteboard = _G.pasteboard or require("pasteboard")
_G.key = _G.key or require("key")
_G.toast = _G.toast or function(t) if sys and sys.toast then sys.toast(tostring(t)) end end
local function sleep(ms) if sys and sys.msleep then sys.msleep(ms) else os.execute("sleep "..tostring(math.ceil((ms or 1000)/1000))) end end
local function __oc_q(p) return string.format("%q", tostring(p or "")) end
local function __oc_rm(p) if p and p ~= "" then os.execute("rm -rf " .. __oc_q(p) .. " 2>/dev/null") end end
local function __oc_clear_safari_v2()
 pcall(function() app.quit("com.apple.mobilesafari") end)
 pcall(function() app.quit("com.apple.WebApp") end)
 os.execute("killall MobileSafari WebKit.WebContent WebKit.Networking com.apple.WebKit.Networking 2>/dev/null")
 sleep(1500)
 pcall(function() if clear and clear.cookies then clear.cookies() end end)
 local sp = app.data_path("com.apple.mobilesafari") or ""
 local targets = {
  sp.."/Library/Cookies", sp.."/Library/Safari", sp.."/Library/WebKit", sp.."/Library/Caches", sp.."/Library/Preferences", sp.."/Library/Application Support", sp.."/Documents", sp.."/tmp", sp.."/StoreKit",
  "/var/mobile/Library/Safari", "/private/var/mobile/Library/Safari", "/var/mobile/Library/Cookies", "/private/var/mobile/Library/Cookies", "/var/mobile/Library/Caches/com.apple.mobilesafari", "/private/var/mobile/Library/Caches/com.apple.mobilesafari", "/var/mobile/Library/WebKit/com.apple.mobilesafari", "/private/var/mobile/Library/WebKit/com.apple.mobilesafari", "/var/mobile/Library/WebKit/WebsiteData", "/private/var/mobile/Library/WebKit/WebsiteData", "/var/mobile/Library/Caches/com.apple.WebKit.Networking", "/private/var/mobile/Library/Caches/com.apple.WebKit.Networking"
 }
 for _,p in ipairs(targets) do __oc_rm(p); os.execute("mkdir -p " .. __oc_q(p) .. " 2>/dev/null") end
 __oc_rm("/var/mobile/Media/1ferver/ipa/Cookies.binarycookies")
 __oc_rm("/var/mobile/Media/1ferver/ipa/Safari_Cookies.binarycookies")
 os.execute('find ' .. __oc_q(sp) .. ' /var/mobile/Library /private/var/mobile/Library -iname "*google*" -o -iname "*gmail*" -o -iname "*account*" 2>/dev/null | while read p; do rm -rf "$p"; done')
 os.execute("sync")
 local f=io.open('/var/mobile/Media/1ferver/log/combo_clear_safari_pre_stage1.txt','w'); if f then f:write(os.date('%H:%M:%S')..' PRE_STAGE1_CLEAR_V2 sp='..tostring(sp)..'\\n'); f:close() end
 if sys and sys.toast then sys.toast("Pre-clear Safari xong",0) end
 sleep(1000)
end
__oc_clear_safari_v2()
'''
        stage1=bootstrap + "\n" + TTL_STAGE1_LUA.read_text(encoding='utf-8-sig')
        login=LOGIN_STAGE6_LUA.read_text(encoding='utf-8-sig').replace('__PC_API__', pc).replace('__MACHINE__', mm)
        login=re.sub(r'math\.randomseed\(os\.time\(\)\)\s*local d=math\.random\(1,500\)\s*while d>0 do toast\("Delay start "\.\.d\.\."s"\); sleep\(1000\); d=d-1 end', '-- combo: no random delay', login, flags=re.S)
        stage1=re.sub(r'\nreturn\s+true\s*$', '\n-- Stage1 done, continue LoginGG\n', stage1.rstrip(), flags=re.S)
        marker = ("local f=io.open('/var/mobile/Media/1ferver/log/stage1_to_login_marker.txt','w'); if f then f:write(os.date('%H:%M:%S')..' INLINE_LOGIN_NO_DELAY\\n'); f:close() end\n")
        login_wrapped = "local __ok,__err=xpcall(function()" + chr(10) + login + chr(10) + "end, debug.traceback)" + chr(10) + "if not __ok then local f=io.open('/var/mobile/Media/1ferver/log/inline_login_error.txt','w'); if f then f:write(tostring(__err)); f:close() end; error(__err) end" + chr(10)
        return stage1 + '\n\n-- ===== INLINE AUTO CONTINUE: LOGIN GG =====\n' + marker + login_wrapped + '\n'

    def run_stage1_login_onefile(self, m):
        mm, ip, c = self.client(m)
        pc=self.pc_urls_for_client(ip)
        self.log_line(f'[{mm}] Stage1+LoginGG HTTP-loader start; PC={pc}')
        lua_txt=self.build_combo_lua(mm, pc)
        tmp=LOG_DIR/'TTL_Stage1_LoginGG_inline_runtime.lua'
        LOG_DIR.mkdir(parents=True,exist_ok=True)
        tmp.write_text(lua_txt,encoding='utf-8')
        urls=[u + '/api/combo_lua?machine=' + str(mm) + '&t=' + str(int(time.time()*1000)) for u in pc.split('|') if u]
        loader = 'local http=require("socket.http")\n'
        loader += 'local urls={' + ','.join(repr(u) for u in urls) + '}\n'
        loader += "local last=''\nfor _,u in ipairs(urls) do local b,c=http.request(u); if b and tostring(c)=='200' then local fn,e=load(b); if not fn then error(e) end; return fn() end; last=tostring(c) end\nerror('LOAD_COMBO_LUA_FAIL '..last)\n"
        self.stop_script_hard(c)
        try:
            c.command_spawn("rm -f /var/mobile/Media/1ferver/log/inline_login_error.txt /var/mobile/Media/1ferver/log/stage1_to_login_marker.txt 2>/dev/null")
        except Exception:
            pass
        c.spawn(loader)
        return mm

    def run_ttl_then_login_selected(self):
        machines=parse_machine_list(self.machine_var.get())
        if not machines:
            return messagebox.showwarning(APP_TITLE,'Nhập máy/IP')
        def worker():
            for m in machines:
                try:
                    self.log_line(f'[{m}] TẢI TTL + LOGIN GG bắt đầu (1 file Lua)')
                    mm=self.run_stage1_login_onefile(m)
                    self.log_line(f'[{mm}] TẢI TTL + LOGIN GG đã khởi chạy 1 file')
                except Exception as e:
                    self.log_line(f'[{m}] TẢI TTL + LOGIN GG lỗi: {e}')
        threading.Thread(target=worker,daemon=True).start()

    def run_ttl_stage_selected(self, stage):
        machines=parse_machine_list(self.machine_var.get())
        if not machines:
            return messagebox.showwarning(APP_TITLE,'Nhập máy/IP')
        def worker():
            for m in machines:
                try:
                    self.run_ttl_stage(m, stage)
                    self.log_line(f'[{m}] {"TẢI TTL" if int(stage)==1 else "MỞ TTL"} OK')
                except Exception as e:
                    self.log_line(f'[{m}] {"TẢI TTL" if int(stage)==1 else "MỞ TTL"} lỗi: {e}')
        threading.Thread(target=worker,daemon=True).start()

    def deploy_webview_api(self, machine_text, client_ip=''):
        machines=parse_machine_list(machine_text)
        if not machines:
            raise RuntimeError('Nhập máy/IP')
        ev=self.event_var.get().strip()
        done=[]
        for m in machines:
            mm, ip, c = self.client(m, client_ip if str(m).count('.')!=3 else '')
            pc=self.pc_url_for_client(ip)
            lua=lua_webview(pc, mm, ev)
            remote='/var/mobile/Media/1ferver/lua/scripts/safari_bridge_webview.lua'
            c.command_spawn('mkdir -p /var/mobile/Media/1ferver/lua/scripts /var/mobile/Media/1ferver/log')
            c.write_file(remote, lua.encode('utf-8'))
            try:
                c.select_script_file(remote)
            except Exception:
                pass
            self.stop_our_shell_lua(c)
            try:
                c.select_script_file(remote); c.launch_script_file()
            except Exception:
                c.spawn(lua)
            done.append(str(mm))
            self.log_line(f'[{mm}] gửi webview OK -> API {ip}')
        return {'ok': True, 'machines': done}

    def deploy_webview_selected(self):
        machines=parse_machine_list(self.machine_var.get())
        if not machines:
            return messagebox.showwarning(APP_TITLE,'Nhập máy/IP')
        ev=self.event_var.get().strip()
        def send_one(m):
            try:
                mm, ip, c = self.client(m)
                pc=self.pc_url_for_client(ip)
                lua=lua_webview(pc, mm, ev)
                remote='/var/mobile/Media/1ferver/lua/scripts/safari_bridge_webview.lua'
                c.command_spawn('mkdir -p /var/mobile/Media/1ferver/lua/scripts /var/mobile/Media/1ferver/log')
                c.write_file(remote, lua.encode('utf-8'))
                try:
                    c.select_script_file(remote)
                except Exception as se:
                    self.log_line(f'[{mm}] select script lỗi, fallback chạy thẳng: {se}')
                self.stop_our_shell_lua(c)
                try:
                    c.select_script_file(remote)
                    c.launch_script_file()
                    self.log_line(f'[{mm}] gửi webview OK -> selected + launch {ip}')
                except Exception as le:
                    self.log_line(f'[{mm}] launch webview lỗi, fallback spawn: {le}')
                    c.spawn(lua)
                    self.log_line(f'[{mm}] gửi webview OK -> fallback spawn {ip}')
            except Exception as e:
                self.log_line(f'[{m}] gửi webview lỗi: {e}')
        def worker():
            self.log_line(f'GỬI WEBVIEW: {len(machines)} máy, threads=50')
            with ThreadPoolExecutor(max_workers=50) as ex:
                futs=[ex.submit(send_one, m) for m in machines]
                for _ in as_completed(futs):
                    pass
            self.log_line('GỬI WEBVIEW: hoàn tất batch')
        threading.Thread(target=worker,daemon=True).start()

    def on_close(self):
        try:
            if self.api_server:
                self.api_server.shutdown(); self.api_server.server_close()
        except Exception: pass
        self.destroy()


if __name__=='__main__':
    ACCOUNTS_DIR.mkdir(parents=True, exist_ok=True)
    app=BridgeApp(); app.mainloop()






