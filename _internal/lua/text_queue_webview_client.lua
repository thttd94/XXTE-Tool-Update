
local sys = require("sys")
local webview = require("webview")
local ok_pb, pasteboard = pcall(require, "pasteboard")

local WV_ID = 73
local IDLE_TIMEOUT_MS = 600000
local last_active_ms = os.time() * 1000
local LAST_PATH = '/var/mobile/Media/1ferver/text_queue_last_acc.json'
local HISTORY_PATH = '/var/mobile/Media/1ferver/text_queue_history.jsonl'
local MACHINE = tostring(rawget(_G, 'XXT_MACHINE') or rawget(_G, 'OC_MACHINE') or '798')
local html = [==[
<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
html,body{margin:0;padding:0;width:100%;height:100%;background:transparent;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,sans-serif;-webkit-user-select:none;user-select:none;-webkit-touch-callout:none}
*{-webkit-user-select:none;user-select:none;-webkit-touch-callout:none;-webkit-tap-highlight-color:transparent;box-sizing:border-box}
#bar{width:100%;height:100%;display:flex;flex-direction:column;gap:8px;background:rgba(2,6,23,.86);border-radius:12px;padding:8px;color:white}
#top{display:flex;gap:8px;align-items:center}.row{display:flex;gap:8px;align-items:center}
button{height:38px;border:0;border-radius:10px;padding:0 10px;background:#2563eb;color:#fff;font-size:13px;font-weight:800}
.txt{background:#16a34a;max-width:230px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;flex:1}.histbtn{background:#facc15;color:#111;width:28px;padding:0}.navbtn{background:#facc15;color:#111;flex:1}.clearbtn{background:#dc2626;color:#fff;flex:1}.auth{background:#dc2626;font-size:7px;letter-spacing:-0.4px;line-height:1.0;padding:0 2px}
#status{font-size:13px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;flex:1;color:#e5e7eb}.hidden{display:none!important}
</style>
<script>
const MACHINE = '__MACHINE__';
const SERVERS = ['http://__TEXT_HOST_IP__:8765'];
const WITHDRAW_MAIL='trumvtc18@gmail.com';
window.__mail_set = new Set();
function splitMail(m){let p=String(m||'jonhsnowgotn@gmail.com').split('@');return {user:p[0]||'jonhsnowgotn',domain:'@'+(p[1]||'gmail.com')};}
function rnd(n){const c='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';let r='';for(let i=0;i<n;i++)r+=c.charAt(Math.floor(Math.random()*c.length));return r;}
function dotUser(u){let r=u[0]||'j';for(let i=1;i<u.length;i++){if(Math.random()>0.5)r+='.';r+=u[i];}return r;}
function genMail(){markUse();let p=splitMail(WITHDRAW_MAIL),e;do{e=dotUser(p.user)+'+'+rnd(20)+p.domain;}while(window.__mail_set.has(e));window.__mail_set.add(e);window.__xxt_copy=e;window.__xxt_action='copy';setStatus('Đã copy mail rút'); setTimeout(function(){setStatus(window.__stt_status || 'STT ACC: -');},1200);return false;}
window.__xxt_action='';
window.__xxt_copy='';
window.__xxt_touch=Date.now();
function markUse(){window.__xxt_touch=Date.now();}
window.__history=[]; window.__hist_index=-1; window.__nav_timer=null;
function setHome(){document.getElementById('texts').classList.remove('hidden');document.getElementById('nav').classList.add('hidden');document.getElementById('btnGetAcc').classList.remove('hidden');document.getElementById('btnMail').classList.remove('hidden');document.getElementById('btnHomeAssist').classList.add('hidden');document.getElementById('btnVpn').classList.add('hidden');}
function openNav(){markUse();document.getElementById('texts').classList.add('hidden');document.getElementById('nav').classList.remove('hidden');document.getElementById('btnGetAcc').classList.add('hidden');document.getElementById('btnMail').classList.add('hidden');document.getElementById('btnHomeAssist').classList.remove('hidden');document.getElementById('btnVpn').classList.remove('hidden'); if(window.__nav_timer)clearTimeout(window.__nav_timer); window.__nav_timer=setTimeout(setHome,3000); return false;}
function touchNav(){if(window.__nav_timer)clearTimeout(window.__nav_timer); window.__nav_timer=setTimeout(setHome,3000);}
function fakeHome(){markUse(); window.__xxt_action='toggle_assistive'; setStatus('HOME ảo...'); touchNav(); return false;}
function toggleVpn(){markUse(); window.__xxt_action='toggle_vpn'; setStatus('VPN...'); touchNav(); return false;}
function pushHistory(j){ if(!j||!j.ok)return; window.__history.push(j); window.__hist_index=window.__history.length-1; }
function showHistory(delta){markUse(); touchNav(); if(!window.__history.length){setStatus('Chưa có acc cũ');return false;} window.__hist_index += delta; if(window.__hist_index<0)window.__hist_index=0; if(window.__hist_index>=window.__history.length)window.__hist_index=window.__history.length-1; showTexts(window.__history[window.__hist_index]); setStatus('STT ACC: '+(window.__history[window.__hist_index].acc_id||'?')); return false; }
let __clearAccCount=0; let __clearAccTimer=null;
function clearHistory(){markUse(); __clearAccCount+=1; setStatus('Xác nhận Clear: '+__clearAccCount+'/2'); if(__clearAccTimer) return false; __clearAccTimer=setTimeout(function(){var n=__clearAccCount; __clearAccCount=0; __clearAccTimer=null; if(n===2){ window.__history=[]; window.__hist_index=-1; window.__texts=null; window.__auth_code=''; window.__auth_remain=0; document.getElementById('texts').classList.add('hidden'); document.getElementById('nav').classList.add('hidden'); document.getElementById('btnGetAcc').classList.remove('hidden'); document.getElementById('btnMail').classList.remove('hidden'); document.getElementById('btnHomeAssist').classList.add('hidden'); document.getElementById('btnVpn').classList.add('hidden'); window.__xxt_action='clear_history'; setStatus('STT ACC: -'); }else{ setStatus(window.__stt_status || 'STT ACC: -'); touchNav(); }},1000); return false; }
function setStatus(s){document.getElementById('status').textContent=String(s||'');}
function rrot(n,b){return (n>>>b)|(n<<(32-b));}
function sha1(msg){
 var ml=msg.length*8; msg=msg.slice(); msg.push(0x80); while((msg.length%64)!=56)msg.push(0); msg.push(0,0,0,0,(ml>>>24)&255,(ml>>>16)&255,(ml>>>8)&255,ml&255);
 var h0=0x67452301,h1=0xEFCDAB89,h2=0x98BADCFE,h3=0x10325476,h4=0xC3D2E1F0;
 for(var i=0;i<msg.length;i+=64){var w=new Array(80); for(var j=0;j<16;j++){var k=i+j*4; w[j]=((msg[k]<<24)|(msg[k+1]<<16)|(msg[k+2]<<8)|msg[k+3])>>>0;} for(j=16;j<80;j++)w[j]=rrot(w[j-3]^w[j-8]^w[j-14]^w[j-16],31)>>>0; var a=h0,b=h1,c=h2,d=h3,e=h4; for(j=0;j<80;j++){var f,kk;if(j<20){f=(b&c)|((~b)&d);kk=0x5A827999;}else if(j<40){f=b^c^d;kk=0x6ED9EBA1;}else if(j<60){f=(b&c)|(b&d)|(c&d);kk=0x8F1BBCDC;}else{f=b^c^d;kk=0xCA62C1D6;}var temp=(rrot(a,27)+f+e+kk+w[j])>>>0;e=d;d=c;c=rrot(b,2)>>>0;b=a;a=temp;} h0=(h0+a)>>>0;h1=(h1+b)>>>0;h2=(h2+c)>>>0;h3=(h3+d)>>>0;h4=(h4+e)>>>0;}
 var out=[]; [h0,h1,h2,h3,h4].forEach(function(h){out.push((h>>>24)&255,(h>>>16)&255,(h>>>8)&255,h&255);}); return out;
}
function b32decode(s){var abc='ABCDEFGHIJKLMNOPQRSTUVWXYZ234567',bits='',out=[];s=String(s||'').toUpperCase().replace(/[^A-Z2-7]/g,''); for(var i=0;i<s.length;i++){var v=abc.indexOf(s[i]); if(v<0)continue; bits+=v.toString(2).padStart(5,'0'); while(bits.length>=8){out.push(parseInt(bits.slice(0,8),2)); bits=bits.slice(8);}} return out;}
function hmacSha1(key,msg){if(key.length>64)key=sha1(key); while(key.length<64)key.push(0); var o=[],i=[]; for(var x=0;x<64;x++){o[x]=key[x]^0x5c;i[x]=key[x]^0x36;} return sha1(o.concat(sha1(i.concat(msg))));}
function totp(secret){try{var key=b32decode(secret), t=Math.floor(Date.now()/1000/30), msg=[]; for(var i=7;i>=0;i--)msg.push((t/Math.pow(256,i))&255); var h=hmacSha1(key,msg), off=h[19]&15, bin=((h[off]&127)<<24)|(h[off+1]<<16)|(h[off+2]<<8)|h[off+3]; return String(bin%1000000).padStart(6,'0');}catch(e){return 'ERR';}}
async function refreshAuth(){
 if(!window.__texts || !window.__texts[3]) return;
 if(window.__auth_refreshing) return;
 window.__auth_refreshing = true;
 for(const base of SERVERS){
  try{
   const r = await fetch(base + '/api/text/totp?secret=' + encodeURIComponent(window.__texts[3]) + '&t=' + Date.now(), {cache:'no-store'});
   const j = await r.json();
   if(j && j.ok){
    window.__auth_code = j.auth_code || '';
    window.__auth_remain = j.auth_remain || (30 - Math.floor(Date.now()/1000)%30);
    window.__auth_period = Math.floor(Date.now()/30000);
    document.getElementById('t3').textContent=(window.__auth_code||'ERR')+' '+window.__auth_remain+'s';
    window.__auth_refreshing = false;
    return;
   }
  }catch(e){}
 }
 window.__auth_refreshing = false;
}
function tickAuth(){
 if(!window.__texts || !window.__texts[3]) return;
 var period = Math.floor(Date.now()/30000);
 var left = 30 - (Math.floor(Date.now()/1000) % 30);
 if(window.__auth_period === undefined || period !== window.__auth_period || !window.__auth_code){
   document.getElementById('t3').textContent=(window.__auth_code||'...')+' '+left+'s';
   refreshAuth();
   return;
 }
 window.__auth_remain = left;
 document.getElementById('t3').textContent=(window.__auth_code||'...')+' '+left+'s';
}
setInterval(tickAuth,1000);
function actCopy(n){markUse(); window.__xxt_copy = (n==3) ? (window.__auth_code || '') : (window.__texts ? (window.__texts[n] || '') : ''); window.__xxt_action='copy'; return false; }
function showTexts(t){ window.__texts={1:t.text1||'',2:t.text2||'',3:t.text3||''}; window.__stt_status='STT ACC: '+(t.acc_id || '?'); window.__auth_code=t.auth_code||''; window.__auth_remain=t.auth_remain||30; window.__auth_period=Math.floor(Date.now()/30000); document.getElementById('t1').textContent=window.__texts[1]||'Text 1'; document.getElementById('t2').textContent='Pass'; document.getElementById('t3').textContent=(window.__auth_code||'...')+' '+window.__auth_remain+'s'; document.getElementById('texts').classList.remove('hidden'); if(!window.__auth_code){ refreshAuth(); } }
let __getAccCount = 0;
let __getAccTimer = null;
function getText(){
 markUse();
 __getAccCount += 1;
 setStatus('Xác nhận lấy acc: '+__getAccCount+'/2');
 if(__getAccTimer) return false;
 __getAccTimer = setTimeout(function(){
   var n = __getAccCount;
   __getAccCount = 0;
   __getAccTimer = null;
   if(n === 2){
     doGetAcc();
   }else{
     setStatus(window.__stt_status || 'STT ACC: -');
   }
 }, 1000);
 return false;
}
async function doGetAcc(){
 setStatus('Đang lấy...');
 for(const base of SERVERS){
   try{
    setStatus('Thử '+base);
    const r = await fetch(base + '/api/text/next?machine=' + encodeURIComponent(MACHINE), {cache:'no-store'});
    const j = await r.json();
    if(j && j.ok){ showTexts(j); pushHistory(j); window.__xxt_last_raw = JSON.stringify(j); window.__xxt_action='save'; setStatus(window.__stt_status || ('STT ACC: '+(j.acc_id || '?'))); return false; }
    setStatus((j && j.error) ? j.error : 'empty');
   }catch(e){ setStatus('Fail '+base); }
 }
 setStatus('Không kết nối được server');
 return false;
}
</script></head><body>
<div id="bar">
 <div id="top"><button id="btnGetAcc" onclick="return getText()">LẤY ACC</button><button class="histbtn" onclick="return openNav()"></button><button id="btnHomeAssist" class="navbtn hidden" onclick="return fakeHome()">HOME ẢO</button><button id="btnVpn" class="navbtn hidden" onclick="return toggleVpn()">VPN</button><div id="status">STT ACC: -</div><button id="btnMail" onclick="return genMail()">LẤY MAIL RÚT</button></div>
 <div id="texts" class="row hidden"><button class="txt" id="t1" onclick="return actCopy(1)">Text 1</button><button class="txt" id="t2" onclick="return actCopy(2)">Pass</button><button class="txt auth" id="t3" onclick="return actCopy(3)">2FA --s</button></div>
 <div id="nav" class="row hidden"><button class="navbtn" onclick="return showHistory(-1)">◀</button><button class="clearbtn" onclick="return clearHistory()">Clear Acc</button><button class="navbtn" onclick="return showHistory(1)">▶</button></div>
</div>
</body></html>
]==]

html = string.gsub(html, "797", MACHINE)
local function read_file(path)
  local f = io.open(path, 'rb')
  if not f then return '' end
  local d = f:read('*a') or ''
  f:close()
  return d
end
local function write_file(path, data)
  local f = io.open(path, 'wb')
  if f then f:write(tostring(data or '')); f:close(); return true end
  return false
end
local function append_file(path, data)
  local f = io.open(path, 'ab')
  if f then f:write(tostring(data or '')); f:close(); return true end
  return false
end
local function jsq(s)
  s = tostring(s or '')
  s = string.gsub(s, "\\", "\\\\")
  s = string.gsub(s, "\r", "")
  s = string.gsub(s, "\n", "\\n")
  s = string.gsub(s, "'", "\\'")
  return "'" .. s .. "'"
end

webview.show({id=WV_ID, html=html, x=1, y=1, width=750, height=190, alpha=1.0, corner_radius=12, opaque=false, can_drag=false, ignores_hit=false})
sys.msleep(200)
local last_raw = read_file(LAST_PATH)
if last_raw ~= '' then
  pcall(webview.eval, "try{var j=JSON.parse(" .. jsq(last_raw) .. "); showTexts(j); window.__stt_status='STT ACC: ' + (j.acc_id || '?'); setStatus(window.__stt_status);}catch(e){setStatus('Sẵn sàng');}", WV_ID)
end
local hist_raw = read_file(HISTORY_PATH)
if hist_raw ~= '' then
  pcall(webview.eval, "try{window.__history=[];var lines=" .. jsq(hist_raw) .. ".split(/\\n/); for(var i=0;i<lines.length;i++){if(lines[i].trim()){window.__history.push(JSON.parse(lines[i]));}} window.__hist_index=window.__history.length-1;}catch(e){}", WV_ID)
end

while true do
  local js_touch = tonumber(webview.eval('window.__xxt_touch || 0;', WV_ID) or 0) or 0
  if js_touch > last_active_ms then last_active_ms = js_touch end
  local now_ms = os.time() * 1000
  if now_ms - last_active_ms >= IDLE_TIMEOUT_MS then
    pcall(webview.hide, WV_ID)
    pcall(webview.close, WV_ID)
    sys.toast('Text script idle 10p - stopped')
    os.exit()
  end
  local action = tostring(webview.eval('window.__xxt_action || "";', WV_ID) or '')
  if action == 'save' then
    local raw = tostring(webview.eval('window.__xxt_last_raw || "";', WV_ID) or '')
    if raw ~= '' then write_file(LAST_PATH, raw); append_file(HISTORY_PATH, raw .. '\n') end
    webview.eval('window.__xxt_action="";', WV_ID)
  elseif action == 'toggle_assistive' then
    webview.eval('window.__xxt_action="";', WV_ID)
    local flag = read_file('/tmp/text_queue_assistive_on')
    if flag == '1' then
      pcall(function() sys.assistive_touch_off() end)
      write_file('/tmp/text_queue_assistive_on', '0')
      pcall(webview.eval, "setStatus('HOME ảo OFF'); setTimeout(function(){setStatus(window.__stt_status || 'STT ACC: -');},1200);", WV_ID)
    else
      pcall(function() sys.assistive_touch_on() end)
      write_file('/tmp/text_queue_assistive_on', '1')
      pcall(webview.eval, "setStatus('HOME ảo ON'); setTimeout(function(){setStatus(window.__stt_status || 'STT ACC: -');},1200);", WV_ID)
    end
  elseif action == 'toggle_vpn' then
    webview.eval('window.__xxt_action="";', WV_ID)
    local ok_dev, device = pcall(require, 'device')
    local on = false
    if ok_dev and device then
      pcall(function() on = device.is_vpn_on() end)
      if on then
        pcall(function() device.turn_off_vpn() end)
        pcall(webview.eval, "setStatus('VPN OFF'); setTimeout(function(){setStatus(window.__stt_status || 'STT ACC: -');},1200);", WV_ID)
      else
        pcall(function() device.turn_on_vpn() end)
        pcall(webview.eval, "setStatus('VPN ON'); setTimeout(function(){setStatus(window.__stt_status || 'STT ACC: -');},1200);", WV_ID)
      end
    else
      pcall(webview.eval, "setStatus('VPN module lỗi');", WV_ID)
    end
  elseif action == 'clear_history' then
    write_file(LAST_PATH, '')
    write_file(HISTORY_PATH, '')
    webview.eval('window.__xxt_action="";', WV_ID)
  elseif action == 'copy' then
    local text = tostring(webview.eval('window.__xxt_copy || "";', WV_ID) or '')
    webview.eval('window.__xxt_action=""; window.__xxt_copy="";', WV_ID)
    if text ~= '' then
      if ok_pb and pasteboard and pasteboard.write then pasteboard.write(text) else local f=io.open("/tmp/text_queue_copy.txt","wb"); if f then f:write(text); f:close(); os.execute("pbcopy < /tmp/text_queue_copy.txt") end end
      pcall(webview.eval, "setStatus('Copied'); setTimeout(function(){setStatus(window.__stt_status || 'STT ACC: -');},1200);", WV_ID)
      sys.toast('Copied')
    else
      pcall(webview.eval, "setStatus('Text rỗng');", WV_ID)
    end
  end
  sys.msleep(150)
end

