
local sys = require("sys")
local webview = require("webview")
local ok_app, app = pcall(require, "app")
local ok_pb, pasteboard = pcall(require, "pasteboard")

local WV_ID = 73
local LAST_PATH = '/var/mobile/Media/1ferver/text_queue_last_acc.json'
local HISTORY_PATH = '/var/mobile/Media/1ferver/text_queue_history.jsonl'
local THEME_PATH = '/var/mobile/Media/1ferver/text_queue_theme.txt'
local THEME_HISTORY_PATH = '/var/mobile/Media/1ferver/text_queue_theme_history.json'
local VIDEO_STATE_PATH = '/var/mobile/Media/1ferver/text_queue_video_state.txt'
local DEBUG_PATH = '/var/mobile/Media/1ferver/text_queue_debug.log'
local MACHINE = tostring(rawget(_G, 'XXT_MACHINE') or rawget(_G, 'OC_MACHINE') or '114')
local html = [==[
<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
html,body{margin:0;padding:0;width:100%;height:100%;background:transparent;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,sans-serif;-webkit-user-select:none;user-select:none;-webkit-touch-callout:none}
*{-webkit-user-select:none;user-select:none;-webkit-touch-callout:none;-webkit-tap-highlight-color:transparent;box-sizing:border-box}
#bar{width:100%;height:100%;display:flex;flex-direction:column;gap:8px;background:#020617;border-radius:12px;padding:8px;color:white}
#top{display:flex;gap:8px;align-items:center}.row{display:flex;gap:8px;align-items:center}
button{height:38px;border:2px solid #000!important;border-radius:10px;padding:0 10px;background:#2563eb;color:#fff;font-size:13px;font-weight:800}
.txt{background:#16a34a;max-width:230px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;flex:1}.timerbtn{background:#0f172a!important;color:#f8fafc!important;border:2px solid #334155!important;flex:1;font-size:12px}.histbtn{background:#facc15;color:#111;width:28px;padding:0}.menubtn{background:#dc2626;color:#fff;width:28px;padding:0}.safaribtn{background:#16a34a!important;color:#fff!important;border:2px solid #000!important;width:28px;padding:0}.navbtn{background:#facc15;color:#111;flex:1}.clearbtn{background:#dc2626;color:#fff;flex:1}.auth{background:#dc2626;font-size:7px;letter-spacing:-0.4px;line-height:1.0;padding:0 2px}
#status{font-size:13px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;flex:1;color:#e5e7eb}.hidden{display:none!important}.menubtn,.histbtn,.redbtn,.yellowbtn,.greenbtn,.purplebtn{color:#fff!important;border:2px solid #000!important}.menubtn{background:#dc2626!important;width:28px;padding:0}.histbtn{background:#facc15!important;width:28px;padding:0}.redbtn,.yellowbtn,.greenbtn,.purplebtn{flex:1}.redbtn{background:#dc2626!important}.yellowbtn{background:#facc15!important}.greenbtn{background:#16a34a!important}.purplebtn{background:#8b5cf6!important}.wide{flex:1}body.theme-red #bar{background:#dc2626!important}body.theme-red button{background:#fecaca;color:#111}body.theme-red .redbtn,body.theme-red .menubtn{background:#dc2626!important;color:#fff!important;border:2px solid #000!important}body.theme-yellow #bar{background:#facc15!important;color:#111}body.theme-yellow button{background:#111827;color:#fff}body.theme-yellow .yellowbtn,body.theme-yellow .histbtn{background:#facc15!important;color:#fff!important;border:2px solid #000!important}body.theme-green #bar{background:#16a34a!important}body.theme-green button{background:#dcfce7;color:#111}body.theme-green .greenbtn{background:#16a34a!important;color:#fff!important;border:2px solid #000!important}body.theme-purple #bar{background:#8b5cf6!important}body.theme-purple button{background:#ede9fe;color:#111}body.theme-purple .purplebtn{background:#8b5cf6!important;color:#fff!important;border:2px solid #000!important}body.theme-red_sub #bar{background:#ffffff!important;color:#111}body.theme-red_sub button{background:#ffffff;color:#111}body.theme-yellow_sub #bar{background:#f97316!important;color:#111}body.theme-yellow_sub button{background:#fed7aa;color:#111}body.theme-green_sub #bar{background:#7dd3fc!important;color:#111}body.theme-green_sub button{background:#e0f2fe;color:#111}body.theme-purple_sub #bar{background:#1e3a8a!important;color:#fff}body.theme-purple_sub button{background:#dbeafe;color:#111}
</style>
<script>
const MACHINE = '114';
const SERVERS = ["http://192.16.1.10:8765", "http://192.168.9.201:8765", "http://169.254.83.107:8765", "http://192.17.1.10:8765", "http://192.14.1.10:8765", "http://192.15.1.10:8765", "http://172.23.80.1:8765"];
const SAFARI_SERVERS = SERVERS;
const WITHDRAW_MAIL='trumvtc18@gmail.com';
window.__xxt_debug='';
function dbg(s){try{window.__xxt_debug=(new Date().toISOString())+' '+String(s||'');}catch(e){}}
window.__mail_set = new Set();
function splitMail(m){let p=String(m||'jonhsnowgotn@gmail.com').split('@');return {user:p[0]||'jonhsnowgotn',domain:'@'+(p[1]||'gmail.com')};}
function rnd(n){const c='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';let r='';for(let i=0;i<n;i++)r+=c.charAt(Math.floor(Math.random()*c.length));return r;}
function dotUser(u){let r=u[0]||'j';for(let i=1;i<u.length;i++){if(Math.random()>0.5)r+='.';r+=u[i];}return r;}
function genMail(){markUse();let p=splitMail(WITHDRAW_MAIL),e;do{e=dotUser(p.user)+'+'+rnd(20)+p.domain;}while(window.__mail_set.has(e));window.__mail_set.add(e);window.__xxt_copy=e;window.__xxt_action='copy';setStatus('Đã copy mail rút'); setTimeout(function(){setStatus(window.__stt_status || 'ACC : -');},1200);return false;}
window.__xxt_action='';
window.__xxt_copy='';
window.__xxt_touch=Date.now();
const VIDEO_LINKS=["https://lite.tiktok.com/t/ZSCPL5LkJ/", "https://lite.tiktok.com/t/ZSCPLvnaw/", "https://lite.tiktok.com/t/ZSCPL4yKH/", "https://lite.tiktok.com/t/ZSCPLVDpR/", "https://lite.tiktok.com/t/ZSCPL4cpf/", "https://lite.tiktok.com/t/ZSCPLVxUG/", "https://lite.tiktok.com/t/ZSCPN27pK/", "https://lite.tiktok.com/t/ZSCPLwRYY/", "https://lite.tiktok.com/t/ZSCPLKpdk/", "https://lite.tiktok.com/t/ZSCPNFAsa/", "https://lite.tiktok.com/t/ZSCPNMwDe/", "https://lite.tiktok.com/t/ZSCPNJnEL/", "https://lite.tiktok.com/t/ZSCPNk7So/", "https://lite.tiktok.com/t/ZSCPNA2Na/", "https://lite.tiktok.com/t/ZSCPNNA5N/", "https://lite.tiktok.com/t/ZSCPNd7Kf/", "https://lite.tiktok.com/t/ZSCPLEPPn/", "https://lite.tiktok.com/t/ZSCPNYpd8/", "https://lite.tiktok.com/t/ZSCPNYKeV/", "https://lite.tiktok.com/t/ZSCPLEvXo/", "https://lite.tiktok.com/t/ZSCPNDFh1/", "https://lite.tiktok.com/t/ZSCPNSDRE/", "https://lite.tiktok.com/t/ZSCPNBo5N/", "https://lite.tiktok.com/t/ZSCPNAAeE/", "https://lite.tiktok.com/t/ZSCPNjw7U/", "https://lite.tiktok.com/t/ZSCPNenNu/", "https://lite.tiktok.com/t/ZSCPNj26D/", "https://lite.tiktok.com/t/ZSCPNXFuy/", "https://lite.tiktok.com/t/ZSCPNCaLH/", "https://lite.tiktok.com/t/ZSCPNxArb/", "https://lite.tiktok.com/t/ZSCPNV55k/", "https://lite.tiktok.com/t/ZSCPNs33M/", "https://lite.tiktok.com/t/ZSCPNpG8N/", "https://lite.tiktok.com/t/ZSCPN4xPL/", "https://lite.tiktok.com/t/ZSCPN9PB5/", "https://lite.tiktok.com/t/ZSCPNuDW4/", "https://lite.tiktok.com/t/ZSCPNCS5y/", "https://lite.tiktok.com/t/ZSCPNpc4B/", "https://lite.tiktok.com/t/ZSCPNxu1D/", "https://lite.tiktok.com/t/ZSCPNPFR5/", "https://lite.tiktok.com/t/ZSCPNmYRd/", "https://lite.tiktok.com/t/ZSCPN9DM6/", "https://lite.tiktok.com/t/ZSCPNHmus/", "https://lite.tiktok.com/t/ZSCPNQv4N/", "https://lite.tiktok.com/t/ZSCPNyCTT/", "https://lite.tiktok.com/t/ZSCPNPruW/", "https://lite.tiktok.com/t/ZSCPNVk8c/", "https://lite.tiktok.com/t/ZSCPFeHmf/", "https://lite.tiktok.com/t/ZSCPNEfx8/", "https://lite.tiktok.com/t/ZSCPNwnX5/", "https://lite.tiktok.com/t/ZSCPFDBML/", "https://lite.tiktok.com/t/ZSCPF3Mx2/", "https://lite.tiktok.com/t/ZSCPY8FoH/", "https://lite.tiktok.com/t/ZSCPYeAwV/", "https://lite.tiktok.com/t/ZSCPFotwB/", "https://lite.tiktok.com/t/ZSCPFceoU/", "https://lite.tiktok.com/t/ZSCPFtpY8/", "https://lite.tiktok.com/t/ZSCPF3Doc/", "https://lite.tiktok.com/t/ZSCPYYvXP/", "https://lite.tiktok.com/t/ZSCPF716f/"];
window.__video_links=VIDEO_LINKS.slice();window.__video_timer=null;window.__video_running=false;window.__video_started_at=0;window.__video_next_at=0;window.__view='home';
function openMenu(){markUse();window.__view='menu';document.getElementById('top').classList.add('hidden');document.getElementById('texts').classList.add('hidden');document.getElementById('nav').classList.add('hidden');document.getElementById('videoStats').classList.add('hidden');document.getElementById('extra').classList.remove('hidden'); if(window.__nav_timer)clearTimeout(window.__nav_timer); return false;}
window.__xxt_theme_history=[];
function themeDay(){return String(new Date().getDate()).padStart(2,'0');}
function normalizeThemeHistory(){if(!Array.isArray(window.__xxt_theme_history))window.__xxt_theme_history=[];window.__xxt_theme_history=window.__xxt_theme_history.filter(function(x){return x&&x.theme&&x.day;}).slice(-20);}
function reportTheme(c){try{normalizeThemeHistory();fetch(SERVERS[0] + '/api/text/theme?machine=' + encodeURIComponent(MACHINE) + '&theme=' + encodeURIComponent(c) + '&history=' + encodeURIComponent(JSON.stringify(window.__xxt_theme_history)) + '&t=' + Date.now(), {cache:'no-store'}).catch(function(){});}catch(e){}}
function applyTheme(c){markUse();document.body.className='theme-'+c;window.__xxt_theme=c;normalizeThemeHistory();let d=themeDay();let last=window.__xxt_theme_history[window.__xxt_theme_history.length-1];if(!(last&&last.theme===c&&String(last.day)===d)){window.__xxt_theme_history.push({theme:c,day:d,ts:Math.floor(Date.now()/1000)});window.__xxt_theme_history=window.__xxt_theme_history.slice(-20);}window.__xxt_theme_history_json=JSON.stringify(window.__xxt_theme_history);window.__xxt_action='save_theme';reportTheme(c);return false;}
window.__theme_tap_count={};window.__theme_tap_timer={};
function themeTap(c){markUse();let child={red:'red_sub',yellow:'yellow_sub',green:'green_sub',purple:'purple_sub'};let cur=window.__xxt_theme||'';if(cur!==c && cur!==child[c]){applyTheme(c);setStatus('Nhóm '+c);return false;}window.__theme_tap_count[c]=(window.__theme_tap_count[c]||0)+1;setStatus('Double tap: '+window.__theme_tap_count[c]+'/2');if(window.__theme_tap_timer[c])return false;window.__theme_tap_timer[c]=setTimeout(function(){let n=window.__theme_tap_count[c]||0;window.__theme_tap_count[c]=0;window.__theme_tap_timer[c]=null;if(n>=2){let now=window.__xxt_theme||'';applyTheme(now===child[c]?c:(child[c]||c));}else{setStatus(window.__stt_status || 'ACC : -');}},550);return false;}
function resetTheme(){document.body.className='';window.__xxt_theme='';window.__xxt_theme_history_json=JSON.stringify(window.__xxt_theme_history||[]);window.__xxt_action='save_theme';}
function startDD20(){markUse();setStatus('DD 20P: blank');touchNav();return false;}
function fmtMS(ms){ms=Math.max(0,Math.floor(ms/1000));let m=Math.floor(ms/60),s=ms%60;return m+':'+String(s).padStart(2,'0');}
function updateVideoStats(){let row=document.getElementById('videoStats');if(!row)return;if(window.__view!=='home'){row.classList.add('hidden');return;}if(window.__video_running && Date.now()-window.__xxt_touch>30000){document.getElementById('texts').classList.add('hidden');row.classList.remove('hidden');}else{row.classList.add('hidden'); if(window.__texts)document.getElementById('texts').classList.remove('hidden');} if(window.__video_running){document.getElementById('videoNextBtn').textContent='Video ti\u1ebfp theo : '+fmtMS(window.__video_next_at-Date.now());document.getElementById('videoRunBtn').textContent='Time \u0111\u00e3 ch\u1ea1y : '+fmtMS(Date.now()-window.__video_started_at);}}
function videoNext(){if(!window.__video_links.length){setStatus('Video h\u1ebft link');window.__video_running=false;return false;}window.__video_open_count=(window.__video_open_count||0)+1;let i=Math.floor(Math.random()*window.__video_links.length);let u=window.__video_links.splice(i,1)[0];window.__xxt_open_url=u;window.__xxt_video_quit=(window.__video_open_count>1 && ((window.__video_open_count-1)%20===0))?'1':'';window.__xxt_action='open_url';window.__xxt_video_state=window.__video_links.join('\n');window.__video_next_at=Date.now()+170000;setStatus((window.__xxt_video_quit?'Quit TikTok Lite + ':'')+'Video c\u00f2n '+window.__video_links.length);if(window.__video_links.length){window.__video_timer=setTimeout(videoNext,170000);}return false;}
function startVideo5p(){markUse();touchNav();if(window.__video_timer)clearTimeout(window.__video_timer);if(!window.__video_links.length)window.__video_links=VIDEO_LINKS.slice();window.__video_running=true;window.__video_started_at=Date.now();return videoNext();}
function markUse(){window.__xxt_touch=Date.now();updateVideoStats();}
window.__history=[]; window.__hist_index=-1; window.__nav_timer=null;
function setHome(){window.__view='home';document.getElementById('top').classList.remove('hidden');document.getElementById('texts').classList.remove('hidden');document.getElementById('nav').classList.add('hidden');document.getElementById('extra').classList.add('hidden');document.getElementById('safari').classList.add('hidden');document.getElementById('videoStats').classList.add('hidden');document.getElementById('btnGetAcc').classList.remove('hidden');document.getElementById('btnMail').classList.remove('hidden');document.getElementById('btnHomeAssist').classList.add('hidden');document.getElementById('btnVpn').classList.add('hidden');}
function openNav(){markUse();window.__view='nav';document.getElementById('texts').classList.add('hidden');document.getElementById('nav').classList.remove('hidden');document.getElementById('extra').classList.add('hidden');document.getElementById('safari').classList.add('hidden');document.getElementById('btnGetAcc').classList.add('hidden');document.getElementById('btnMail').classList.add('hidden');document.getElementById('btnHomeAssist').classList.remove('hidden');document.getElementById('btnVpn').classList.remove('hidden'); if(window.__nav_timer)clearTimeout(window.__nav_timer); window.__nav_timer=setTimeout(setHome,3000); return false;}
function touchNav(){if(window.__nav_timer)clearTimeout(window.__nav_timer); window.__nav_timer=setTimeout(setHome,3000);}
function fakeHome(){markUse(); window.__xxt_action='toggle_assistive'; setStatus('HOME ảo...'); touchNav(); return false;}
function toggleVpn(){markUse(); window.__xxt_action='toggle_vpn'; setStatus('VPN...'); touchNav(); return false;}
function openSafari(){markUse();window.__view='safari';if(window.__nav_timer)clearTimeout(window.__nav_timer);document.getElementById('top').classList.add('hidden');document.getElementById('texts').classList.add('hidden');document.getElementById('nav').classList.add('hidden');document.getElementById('extra').classList.add('hidden');document.getElementById('videoStats').classList.add('hidden');document.getElementById('safari').classList.remove('hidden');return false;}
async function safariFetch(path){path=String(path||'');if(path.indexOf('/api/')===0)path=path.slice(4);let sep=(path.indexOf('?')>=0?'&':'?');let last='';for(const base of SAFARI_SERVERS){try{let pr=await fetch(base+'/api/text/ping?t='+Date.now(),{cache:'no-store'});let pj=await pr.json();if(!pj||pj.version!=='xxte-text-safari-v3.1'){last='old server '+base;continue;}let r=await fetch(base+'/api/safari'+path+sep+'machine='+encodeURIComponent(MACHINE),{cache:'no-store'});let txt=await r.text();try{return {base:base,json:JSON.parse(txt)}}catch(e){last='JSON '+txt.slice(0,80);}}catch(e){last=String(e);}}throw new Error(last||'no safari api');}
function restoreSafariView(){try{setTimeout(function(){openSafari();},80);}catch(e){}}
async function safariWatchJob(j,label,base){openSafari();if(!j||!j.ok){setStatus('Lỗi '+((j&&j.error)||''));restoreSafariView();return false;}let id=j.job_id||'';if(!id){setStatus(j.message||label+' OK');restoreSafariView();return false;}setStatus(label+' đã nhận, chờ lượt');restoreSafariView();for(let i=0;i<180;i++){await new Promise(r=>setTimeout(r,1000));try{let r=await fetch(base+'/api/safari/job_status?id='+encodeURIComponent(id),{cache:'no-store'});let x=await r.json();if(x.status==='running'){setStatus(label+' đang chạy...');restoreSafariView();}else if(x.status==='done'){setStatus(x.message||label+' thành công');restoreSafariView();return false;}else if(x.status==='fail'){setStatus((x.message||'Lỗi')+(x.error?(': '+x.error):''));restoreSafariView();return false;}}catch(e){}}setStatus(label+' chưa xong, xem log server');restoreSafariView();return false;}
async function safariJob(path,label){openSafari();setStatus(label+'...');try{let res=await safariFetch(path);return safariWatchJob(res.json,label,res.base);}catch(e){setStatus('Safari không thấy PC API'); dbg('safari '+label+' '+e);restoreSafariView();}return false;}
function safariReimp(){return safariJob('/api/reimport','Nhập lại')}
function safariExport(){return safariJob('/api/export','Xuất TK')}
let __safariImportTap=0,__safariImportTimer=null,__safariCookieTap=0,__safariCookieTimer=null;
function safariImport(){__safariImportTap++;setStatus('Chạm lần 2 để Nhập TK '+__safariImportTap+'/2');if(__safariImportTimer)return false;__safariImportTimer=setTimeout(function(){let n=__safariImportTap;__safariImportTap=0;__safariImportTimer=null;if(n>=2)safariJob('/api/import?index=1','Nhập TK');else setStatus(window.__stt_status||'ACC : -');},500);return false;}
function safariCookie(){return safariJob('/api/export_cookie','Xuất Cookies')}
function safariImportCookie(){__safariCookieTap++;setStatus('Chạm lần 2 để Nhập Cookies '+__safariCookieTap+'/2');if(__safariCookieTimer)return false;__safariCookieTimer=setTimeout(function(){let n=__safariCookieTap;__safariCookieTap=0;__safariCookieTimer=null;if(n>=2)safariJob('/api/import_cookie','Nhập Cookies');else setStatus(window.__stt_status||'ACC : -');},500);return false;}
function pushHistory(j){ if(!j||!j.ok)return; window.__history.push(j); window.__hist_index=window.__history.length-1; }
function showHistory(delta){markUse(); touchNav(); if(!window.__history.length){setStatus('Chưa có acc cũ');return false;} window.__hist_index += delta; if(window.__hist_index<0)window.__hist_index=0; if(window.__hist_index>=window.__history.length)window.__hist_index=window.__history.length-1; showTexts(window.__history[window.__hist_index]); setStatus('ACC : '+(window.__history[window.__hist_index].acc_id||'?')); return false; }
let __clearAccCount=0; let __clearAccTimer=null;
function clearHistory(){markUse(); __clearAccCount+=1; setStatus('Xác nhận Clear: '+__clearAccCount+'/2'); if(__clearAccTimer) return false; __clearAccTimer=setTimeout(function(){var n=__clearAccCount; __clearAccCount=0; __clearAccTimer=null; if(n===2){ window.__history=[]; window.__hist_index=-1; window.__texts=null; window.__auth_code=''; window.__auth_remain=0; document.getElementById('texts').classList.add('hidden'); document.getElementById('nav').classList.add('hidden'); document.getElementById('btnGetAcc').classList.remove('hidden'); document.getElementById('btnMail').classList.remove('hidden'); document.getElementById('btnHomeAssist').classList.add('hidden'); document.getElementById('btnVpn').classList.add('hidden'); window.__xxt_action='clear_history'; setStatus('ACC : -'); }else{ setStatus(window.__stt_status || 'ACC : -'); touchNav(); }},1000); return false; }
function updateGetAccButton(){
 var b=document.getElementById('btnGetAcc'); if(!b)return;
 var st=String(window.__stt_status || '').trim();
 var msg=String(window.__status_msg || '').trim();
 if(!msg || msg==='ACC : -') { b.textContent='LẤY ACC'; return; }
 b.textContent = window.__status_flip ? msg : 'LẤY ACC';
}
setInterval(function(){window.__status_flip=!window.__status_flip;updateGetAccButton();},1200);
function setStatus(s){
 window.__status_msg=String(s||'');
 window.__xxt_toast=window.__status_msg;
 var el=document.getElementById('status'); if(el) el.textContent='';
 updateGetAccButton();
}
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
 var code = totp(window.__texts[3]);
 if(code && code !== 'ERR'){
   window.__auth_code = code;
   window.__auth_period = period;
   window.__auth_remain = left;
   document.getElementById('t3').textContent=code+' '+left+'s';
   return;
 }
 if(window.__auth_period === undefined || period !== window.__auth_period || !window.__auth_code){
   document.getElementById('t3').textContent=(window.__auth_code||'...')+' '+left+'s';
   refreshAuth();
   return;
 }
 window.__auth_remain = left;
 document.getElementById('t3').textContent=(window.__auth_code||'...')+' '+left+'s';
}
setInterval(tickAuth,1000);setInterval(updateVideoStats,1000);
function actCopy(n){tickAuth(); markUse(); window.__xxt_copy = (n==3) ? (window.__auth_code || '') : (window.__texts ? (window.__texts[n] || '') : ''); window.__xxt_action='copy'; return false; }
function showTexts(t){ window.__texts={1:t.text1||'',2:t.text2||'',3:t.text3||''}; window.__stt_status='ACC : '+(t.acc_id || '?'); window.__auth_code=t.auth_code||''; window.__auth_remain=t.auth_remain||30; window.__auth_period=undefined; document.getElementById('t1').textContent=window.__texts[1]||'Text 1'; document.getElementById('t2').textContent='Pass'; document.getElementById('texts').classList.remove('hidden'); updateVideoStats(); tickAuth(); if(!window.__auth_code){ refreshAuth(); } }
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
     setStatus(window.__stt_status || 'ACC : -');
   }
 }, 1000);
 return false;
}
async function doGetAcc(){
 setStatus('Đang lấy...'); dbg('GET start machine='+MACHINE+' servers='+JSON.stringify(SERVERS));
 for(let si=0; si<SERVERS.length; si++){
   const base = SERVERS[si];
   try{
    setStatus('Đang kết nối PC'); dbg('ping '+base);
    const pr = await fetch(base + '/api/text/ping?t=' + Date.now(), {cache:'no-store'});
    const pj = await pr.json();
    if(!pj || pj.version !== 'xxte-text-safari-v3.1'){dbg('skip old server '+base+' '+JSON.stringify(pj)); continue;}
    const url = base + '/api/text/next?machine=' + encodeURIComponent(MACHINE) + '&t=' + Date.now();
    dbg('fetch '+url);
    const r = await fetch(url, {cache:'no-store'});
    dbg('http '+r.status+' '+base);
    let txt = await r.text();
    dbg('body '+txt.slice(0,300));
    let j = null;
    try{ j = JSON.parse(txt); }catch(je){ dbg('json_error '+je+' body='+txt.slice(0,120)); setStatus('JSON lỗi'); continue; }
    if(j && j.ok){ resetTheme(); showTexts(j); pushHistory(j); window.__xxt_last_raw = JSON.stringify(j); window.__xxt_action='save'; setStatus(window.__stt_status || ('ACC : '+(j.acc_id || '?'))); dbg('OK acc_id='+(j.acc_id||'?')+' remain='+(j.remain||'?')); return false; }
    setStatus((j && j.error) ? j.error : 'empty'); dbg('not_ok '+JSON.stringify(j));
   }catch(e){ setStatus('Fail '+base); dbg('catch '+base+' '+(e && (e.stack||e.message||e))); }
 }
 setStatus('Không thấy PC API - tạo script lại / mở firewall'); dbg('GET failed all servers='+JSON.stringify(SERVERS));
 return false;
}
</script></head><body>
<div id="bar" onclick="if(event.target.id==='bar'){markUse();setHome();}">
 <div id="top"><button id="btnGetAcc" onclick="return getText()">LẤY ACC</button><button class="histbtn" onclick="return openNav()"></button><button class="safaribtn" onclick="return openSafari()"></button><button id="btnHomeAssist" class="navbtn hidden" onclick="return fakeHome()">HOME ẢO</button><button id="btnVpn" class="navbtn hidden" onclick="return toggleVpn()">VPN</button><div id="status"></div><button class="menubtn" onclick="return openMenu()"></button><button id="btnMail" onclick="return genMail()">MAIL RÚT</button></div>
 <div id="texts" class="row hidden"><button class="txt" id="t1" onclick="return actCopy(1)">Text 1</button><button class="txt" id="t2" onclick="return actCopy(2)">Pass</button><button class="txt auth" id="t3" onclick="return actCopy(3)">2FA --s</button></div>
 <div id="videoStats" class="row hidden"><button class="timerbtn" id="videoNextBtn">Video ti\u1ebfp theo : -</button><button class="timerbtn" id="videoRunBtn">Time \u0111\u00e3 ch\u1ea1y : 0:00</button></div>
 <div id="nav" class="row hidden"><button class="navbtn" onclick="return showHistory(-1)">â—€</button><button class="clearbtn" onclick="return clearHistory()">Clear Acc</button><button class="navbtn" onclick="return showHistory(1)">â–¶</button></div>
 <div id="extra" class="hidden"><div class="row"><button class="wide" onclick="setHome();return false;">Home</button><button class="wide" onclick="return startDD20()">DD 20P</button><button class="wide" onclick="return startVideo5p()">Video 5p</button></div><div class="row" style="margin-top:8px"><button class="redbtn" onclick="return themeTap('red')">FAQ</button><button class="yellowbtn" onclick="return themeTap('yellow')">Kích</button><button class="greenbtn" onclick="return themeTap('green')">Video</button><button class="purplebtn" onclick="return themeTap('purple')">Hạ</button></div></div>
 <div id="safari" class="hidden"><div class="row"><button class="wide" onclick="setHome();return false;">Home</button><button class="greenbtn" onclick="return safariExport()">Xuất TK</button><button class="yellowbtn" onclick="return safariImport()">Nhập TK</button><button class="purplebtn" onclick="return safariReimp()">Nhập lại TK</button></div></div>
</div>
</body></html>
]==]

html = string.gsub(html, "114", MACHINE)
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
  pcall(webview.eval, "try{var j=JSON.parse(" .. jsq(last_raw) .. "); showTexts(j); window.__stt_status='ACC : ' + (j.acc_id || '?'); setStatus(window.__stt_status);}catch(e){setStatus('Sẵn sàng');}", WV_ID)
end
local hist_raw = read_file(HISTORY_PATH)
if hist_raw ~= '' then
  pcall(webview.eval, "try{window.__history=[];var lines=" .. jsq(hist_raw) .. ".split(/\\n/); for(var i=0;i<lines.length;i++){if(lines[i].trim()){window.__history.push(JSON.parse(lines[i]));}} window.__hist_index=window.__history.length-1;}catch(e){}", WV_ID)
end
local saved_theme_history = read_file(THEME_HISTORY_PATH)
if saved_theme_history ~= '' then
  pcall(webview.eval, "try{window.__xxt_theme_history=JSON.parse(" .. jsq(saved_theme_history) .. "); window.__xxt_theme_history_json=JSON.stringify(window.__xxt_theme_history||[]);}catch(e){window.__xxt_theme_history=[];}", WV_ID)
end
local saved_theme = read_file(THEME_PATH)
if saved_theme ~= '' then pcall(webview.eval, "try{var th='" .. saved_theme:gsub('[^a-z_]', '') .. "'; document.body.className='theme-'+th; window.__xxt_theme=th;}catch(e){}", WV_ID) end
local video_state = read_file(VIDEO_STATE_PATH)
if video_state ~= '' then pcall(webview.eval, "try{window.__video_links=" .. jsq(video_state) .. ".split(/\\n/).filter(Boolean);}catch(e){}", WV_ID) end

local last_dbg = ''
while true do
  local dbg = tostring(webview.eval('window.__xxt_debug || "";', WV_ID) or '')
  if dbg ~= '' and dbg ~= last_dbg then
    last_dbg = dbg
    append_file(DEBUG_PATH, os.date('%Y-%m-%d %H:%M:%S') .. ' | ' .. dbg .. '\n')
    print('TEXT_DEBUG ' .. dbg)
  end
  local toast_msg = tostring(webview.eval('window.__xxt_toast || "";', WV_ID) or '')
  if toast_msg ~= '' then
    webview.eval('window.__xxt_toast="";', WV_ID)
    pcall(function() sys.toast(toast_msg, 0) end)
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
      pcall(webview.eval, "setStatus('HOME ảo OFF'); setTimeout(function(){setStatus(window.__stt_status || 'ACC : -');},1200);", WV_ID)
    else
      pcall(function() sys.assistive_touch_on() end)
      write_file('/tmp/text_queue_assistive_on', '1')
      pcall(webview.eval, "setStatus('HOME ảo ON'); setTimeout(function(){setStatus(window.__stt_status || 'ACC : -');},1200);", WV_ID)
    end
  elseif action == 'toggle_vpn' then
    webview.eval('window.__xxt_action="";', WV_ID)
    local ok_dev, device = pcall(require, 'device')
    local on = false
    if ok_dev and device then
      pcall(function() on = device.is_vpn_on() end)
      if on then
        pcall(function() device.turn_off_vpn() end)
        pcall(webview.eval, "setStatus('VPN OFF'); setTimeout(function(){setStatus(window.__stt_status || 'ACC : -');},1200);", WV_ID)
      else
        pcall(function() device.turn_on_vpn() end)
        pcall(webview.eval, "setStatus('VPN ON'); setTimeout(function(){setStatus(window.__stt_status || 'ACC : -');},1200);", WV_ID)
      end
    else
      pcall(webview.eval, "setStatus('VPN module lỗi');", WV_ID)
    end
  elseif action == 'save_theme' then
    local th = tostring(webview.eval('window.__xxt_theme || "";', WV_ID) or '')
    local th_hist = tostring(webview.eval('window.__xxt_theme_history_json || JSON.stringify(window.__xxt_theme_history || []);', WV_ID) or '[]')
    write_file(THEME_PATH, th)
    write_file(THEME_HISTORY_PATH, th_hist)
    webview.eval('window.__xxt_action="";', WV_ID)
  elseif action == 'open_url' then
    local url = tostring(webview.eval('window.__xxt_open_url || "";', WV_ID) or '')
    local remain = tostring(webview.eval('window.__xxt_video_state || "";', WV_ID) or '')
    local need_quit = tostring(webview.eval('window.__xxt_video_quit || "";', WV_ID) or '')
    write_file(VIDEO_STATE_PATH, remain)
    webview.eval('window.__xxt_action=""; window.__xxt_open_url=""; window.__xxt_video_quit="";', WV_ID)
    if need_quit ~= '' and ok_app and app then
      pcall(function() if app.quit then app.quit('com.ss.iphone.ugc.tiktok.lite') end end)
      pcall(function() if app.close then app.close('com.ss.iphone.ugc.tiktok.lite') end end)
      pcall(function() if app.kill then app.kill('com.ss.iphone.ugc.tiktok.lite') end end)
      pcall(function() sys.msleep(1500) end)
    end
    if url ~= '' then if ok_app and app and app.open_url then pcall(function() app.open_url(url) end) end; pcall(function() sys.open_url(url) end) end
  elseif action == 'clear_history' then
    write_file(LAST_PATH, '')
    write_file(HISTORY_PATH, '')
    webview.eval('window.__xxt_action="";', WV_ID)
  elseif action == 'copy' then
    local text = tostring(webview.eval('window.__xxt_copy || "";', WV_ID) or '')
    webview.eval('window.__xxt_action=""; window.__xxt_copy="";', WV_ID)
    if text ~= '' then
      if ok_pb and pasteboard and pasteboard.write then pasteboard.write(text) else local f=io.open("/tmp/text_queue_copy.txt","wb"); if f then f:write(text); f:close(); os.execute("pbcopy < /tmp/text_queue_copy.txt") end end
      pcall(webview.eval, "setStatus('Copied'); setTimeout(function(){setStatus(window.__stt_status || 'ACC : -');},1200);", WV_ID)
      sys.toast('Copied')
    else
      pcall(webview.eval, "setStatus('Text rỗng');", WV_ID)
    end
  end
  sys.msleep(150)
end

