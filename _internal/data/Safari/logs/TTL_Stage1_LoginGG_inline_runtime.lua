
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
 local f=io.open('/var/mobile/Media/1ferver/log/combo_clear_safari_pre_stage1.txt','w'); if f then f:write(os.date('%H:%M:%S')..' PRE_STAGE1_CLEAR_V2 sp='..tostring(sp)..'\n'); f:close() end
 if sys and sys.toast then sys.toast("Pre-clear Safari xong",0) end
 sleep(1000)
end
__oc_clear_safari_v2()

screen.init(0)

local app = require("app")
local sys = require("sys")
local touch = require("touch")
local file = require("file")

local SCRIPT_VERSION = "TTL_STAGE1_CLEAN_V1_OPEN_ONLY"
local TIKTOK_BUNDLE = "com.ss.iphone.ugc.Ame"
local TIKTOK_LITE_BUNDLE = "com.ss.iphone.ugc.tiktok.lite"
local APPSTORE_BUNDLE = "com.apple.AppStore"
local TIKTOK_LITE_STORE_URL = "https://apps.apple.com/jp/app/tiktok-lite/id6447160980?l=en-US"
local RES_DIR = "/var/mobile/Media/1ferver/lua/examples/"
local CLOUD_IMG = RES_DIR .. "cloudTTL.png"
local OPEN_IMG = RES_DIR .. "openTTL.png"
local CHECK_ERROR1_IMG = RES_DIR .. "check_error1.png"
local TAP_ERROR1_IMG = RES_DIR .. "tap_error1.png"
local CHECK_ERROR2_IMG = RES_DIR .. "check_error2.png"
local TAP_ERROR2_IMG = RES_DIR .. "tap_error2.png"

local OC_STATUS_PATH = rawget(_G, "OC_STATUS_PATH") or "/var/mobile/Media/1ferver/lua/examples/oc_status.txt"
local WV_ID = 88
local ok_wv, webview = pcall(require, "webview")
local function show_top_status(text)
 text = tostring(text or "")
 if ok_wv and webview and type(webview.show)=="function" then
  local html='<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;padding:0;background:transparent;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,sans-serif}#b{height:38px;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.62);color:white;border-radius:12px;font-size:17px;font-weight:800;white-space:nowrap}</style></head><body><div id="b">'..text..'</div></body></html>'
  pcall(webview.show,{id=WV_ID,html=html,x=1,y=1,width=748,height=38,alpha=1.0,corner_radius=12,opaque=false,can_drag=false,ignores_hit=true})
 end
end
local function write_status(text)
 text = tostring(text or "")
 pcall(function()
  local f = io.open(OC_STATUS_PATH, "w")
  if f then f:write(tostring(os.time()) .. "|" .. text); f:close() end
 end)
 show_top_status(text)
 pcall(function() sys.toast(text, 0) end)
 print(text)
end
local function phase(s) write_status(s) end
local function sleep(ms) sys.msleep(ms) end
local function waitPhase(ms) local t=0; while t<ms do sleep(500); t=t+500 end end

local function findImage(img, sim, x1,y1,x2,y2)
 sim=sim or 82; x1=x1 or 0; y1=y1 or 0; x2=x2 or 750; y2=y2 or 1334
 local x,y = screen.find_image(img, sim, x1,y1,x2,y2)
 return x ~= -1, x, y
end
local function imageCenter(imgPath,x,y)
 local ok_image,image=pcall(require,"image")
 if not ok_image then return x,y end
 local img=image.load_file(imgPath); if not img then return x,y end
 local w,h=img:size(); if not w or not h then return x,y end
 return math.floor(x+w/2), math.floor(y+h/2)
end
local function tapByImageCenter(img, sim, x1,y1,x2,y2)
 local ok,x,y = findImage(img, sim, x1,y1,x2,y2)
 if not ok then return false end
 local cx,cy=imageCenter(img,x,y)
 touch.tap(cx,cy)
 return true
end

local function hasBundle(bundleId)
 local ok, bundles = pcall(function() return app.bundles() end)
 if ok and type(bundles)=="table" then
  for _,bid in ipairs(bundles) do if bid == bundleId then return true end end
 end
 local ok2,path = pcall(function() return app.bundle_path(bundleId) end)
 return ok2 and path and tostring(path) ~= "" and tostring(path) ~= "nil"
end
local function waitUninstallGone(bundleId, label, timeoutSec)
 local start=os.time()
 phase("Chờ gỡ " .. label)
 while os.time()-start < timeoutSec do
  if not hasBundle(bundleId) then phase(label .. " đã gỡ"); waitPhase(1000); return true end
  waitPhase(1000)
 end
 return false
end
local function uninstallIfPresent(bundleId,label)
 if not hasBundle(bundleId) then phase(label .. " không có"); waitPhase(500); return true end
 phase("Gỡ " .. label)
 pcall(function() app.uninstall(bundleId) end)
 waitPhase(2500)
 if waitUninstallGone(bundleId,label,120) then return true end
 phase("Gỡ lại " .. label)
 pcall(function() app.uninstall(bundleId) end)
 waitPhase(2500)
 return waitUninstallGone(bundleId,label,90)
end

local function openStore()
 phase("Mở link TikTok Lite")
 pcall(function() app.quit(APPSTORE_BUNDLE) end)
 waitPhase(1000)
 app.open_url(TIKTOK_LITE_STORE_URL)
 waitPhase(3000)
 app.open_url(TIKTOK_LITE_STORE_URL)
 waitPhase(3000)
end
local function hasError2()
 return findImage(CHECK_ERROR2_IMG,82,0,0,750,1334) or findImage(CHECK_ERROR2_IMG,78,0,0,750,1334)
end
local function handleError2()
 if not hasError2() then return false end
 phase("Lỗi mạng - tap retry")
 if not tapByImageCenter(TAP_ERROR2_IMG,82,0,0,750,1334) then touch.tap(379,750) end
 waitPhase(1500)
 return true
end
local function handleError1()
 local ok = findImage(CHECK_ERROR1_IMG,82,0,0,750,1334)
 if not ok then return false end
 phase("Lỗi tải 1 - xử lý")
 if not tapByImageCenter(TAP_ERROR1_IMG,82,0,0,750,1334) then touch.tap(375,667) end
 waitPhase(1500)
 return true
end
local function tapCloudIfVisible()
 if screen.is_colors({{337,319,0x007aff},{336,313,0x007aff}}, 90) then
  phase("Tap cloud by color")
  touch.tap(337,319)
  waitPhase(2000)
  return true
 end
 if tapByImageCenter(CLOUD_IMG,82,0,0,750,1334) then
  phase("Tap cloud image")
  waitPhase(2000)
  return true
 end
 return false
end
local function isOpenButtonVisible()
 local tries = {
  {86,0,0,750,1334},{82,0,0,750,1334},{78,0,0,750,1334},{72,0,0,750,1334},
  {72,430,160,740,520},{66,430,160,740,520},{62,400,120,750,620}
 }
 for _,t in ipairs(tries) do
  if findImage(OPEN_IMG,t[1],t[2],t[3],t[4],t[5]) then return true end
 end
 return false
end

local function runStage1()
 phase("Stage1 CLEAN: chỉ tải TTL, chờ openTTL.png")
 if not uninstallIfPresent(TIKTOK_BUNDLE,"TikTok") then return false end
 if not uninstallIfPresent(TIKTOK_LITE_BUNDLE,"TikTok Lite") then return false end
 openStore()
 local lastOpenStore=os.time()
 local tapped=false
 local waitCount=0
 while true do
  if isOpenButtonVisible() then
   phase("Stage1 xong: thấy openTTL.png")
   return true
  end
  handleError1()
  handleError2()
  if not tapped then
   if tapCloudIfVisible() then tapped=true; waitCount=0 end
  end
  if tapped then
   waitCount=waitCount+1
   if waitCount % 30 == 0 then phase("Đang chờ tải xong/openTTL.png " .. tostring(waitCount) .. "s") end
  else
   if os.time()-lastOpenStore >= 180 then openStore(); lastOpenStore=os.time() end
   phase("Chờ cloudTTL.png")
  end
  if waitCount >= 900 then
   phase("Chờ quá 15p - mở lại App Store")
   openStore(); waitCount=0; tapped=false; lastOpenStore=os.time()
  end
  waitPhase(1000)
 end
end

if not runStage1() then phase("Lỗi Stage1 CLEAN"); return false end
-- Stage1 done, continue LoginGG


-- ===== INLINE AUTO CONTINUE: LOGIN GG =====
local f=io.open('/var/mobile/Media/1ferver/log/stage1_to_login_marker.txt','w'); if f then f:write(os.date('%H:%M:%S')..' INLINE_LOGIN_NO_DELAY\n'); f:close() end
local __ok,__err=xpcall(function()
screen.init(0)

local app = require("app")
local file = require("file")
local sys = require("sys")
local key = require("key")
local touch = require("touch")
local image = require("image")
local ok_pb, pasteboard = pcall(require, "pasteboard")


-- OpenClaw/PYW status sync: write readable status for GUI polling even when run directly on client.
local OC_STATUS_PATH = rawget(_G, "OC_STATUS_PATH") or "/var/mobile/Media/1ferver/lua/examples/oc_status.txt"
function oc_status(text)
    text = tostring(text or "")
    if type(__oc_write_status) == "function" then pcall(__oc_write_status, text) end
    pcall(function()
        local line = tostring(os.time()) .. "|" .. text
        local wrote = false
        local ok_file, file = pcall(require, "file")
        if ok_file and file then
            if type(file.writes) == "function" then local ok = pcall(file.writes, OC_STATUS_PATH, line); wrote = ok or wrote end
            if (not wrote) and type(file.write) == "function" then local ok = pcall(file.write, OC_STATUS_PATH, line); wrote = ok or wrote end
        end
        if not wrote then
            local f = io.open(OC_STATUS_PATH, "w")
            if f then f:write(line) f:close() end
        end
    end)
end
function oc_toast(text, ...)
    text = tostring(text or "")
    oc_status(text)
    if sys and type(sys.toast) == "function" then return sys.toast(text, ...) end
end


local SCRIPT_VERSION = "STAGE6_TIKTOK_FULL_OLD_LAZY_ACC_V1"

app.quit("com.apple.mobilesafari")
sys.msleep(1000)

local LOGIN_STATUS_BASE = "Quá trình login gg đang thực hiện "
local login_status_dots = 0
local login_status_last_at = 0

function showLoginStatus(force)
 local now = os.time()
 if force or now ~= login_status_last_at then
  login_status_last_at = now
  login_status_dots = login_status_dots + 1
  if login_status_dots > 7 then login_status_dots = 1 end
  oc_toast(LOGIN_STATUS_BASE .. string.rep(".", login_status_dots), 0)
 end
end

showLoginStatus(true)

local RES_DIR = "/var/mobile/Media/1ferver/lua/examples/"
local INPUT_PATH = RES_DIR .. "input.txt"
local SIGN_IMG = RES_DIR .. "sign.png"
local WELLCOM_IMG = RES_DIR .. "wellcom.png"
local INDERSTAND_IMG = RES_DIR .. "inderstand.png"
local NOTNOW_IMG = RES_DIR .. "notnow.png"

-- Link mở TikTok. Nếu anh có link cụ thể khác thì đổi đúng dòng này.
local TIKTOK_OPEN_URL = "https://accounts.google.com/signin"
local PC_API = "http://192.16.1.10:8788|http://192.168.9.201:8788|http://169.254.83.107:8788|http://192.17.1.10:8788|http://192.14.1.10:8788|http://192.15.1.10:8788|http://172.23.80.1:8788"
local MACHINE = "592"
local PC_API_PLACEHOLDER = "__" .. "PC_API" .. "__"
local MACHINE_PLACEHOLDER = "__" .. "MACHINE" .. "__"
if PC_API == PC_API_PLACEHOLDER or PC_API == "PC_API" or PC_API == "" then PC_API = "http://192.14.1.10:8788|http://192.168.9.201:8788" end
if MACHINE == MACHINE_PLACEHOLDER or MACHINE == "MACHINE" or MACHINE == "" then MACHINE = "" end

local __last_status = ""
local __last_status_at = 0
local __phase = ""

local function sleep(ms)
 showLoginStatus(false)
 sys.msleep(ms)
 showLoginStatus(false)
end

local function shortText(t)
 t = tostring(t or "")
 if #t > 40 then
  return string.sub(t, 1, 37) .. "..."
 end
 return t
end

function status(t)
 showLoginStatus(false)
end

function phase(t)
 __phase = tostring(t or "")
 showLoginStatus(false)
end

function phaseProgress(sec)
 showLoginStatus(false)
end

function findImage(img, sim, x1, y1, x2, y2)
 sim = sim or 82
 x1 = x1 or 0
 y1 = y1 or 0
 x2 = x2 or 750
 y2 = y2 or 1334
 local x, y = screen.find_image(img, sim, x1, y1, x2, y2)
 if x ~= -1 then
  status("Hit " .. (string.match(img, "([^/]+)$") or img))
  return true, x, y
 end
 return false, -1, -1
end

function imageCenter(imgPath, x, y)
 local img = image.load_file(imgPath)
 if not img then return x, y end
 local w, h = img:size()
 if not w or not h then return x, y end
 return math.floor(x + (w / 2)), math.floor(y + (h / 2))
end

function handleNotNow()
 local ok, x, y = findImage(NOTNOW_IMG, 82, 0, 0, 750, 1334)
 if ok then
  phase("Tạm dừng bấm notnow")
  sleep(2000)
  touch.tap(x, y)
  sleep(1000)
  return true
 end
 return false
end

function waitPhase(ms)
 local remain = ms
 local lastShown = -1
 while remain > 0 do
  handleNotNow()
  local sec = math.ceil(remain / 1000)
  if sec ~= lastShown then
   phaseProgress(sec)
   lastShown = sec
  end
  local step = 500
  if remain < step then step = remain end
  sleep(step)
  remain = remain - step
 end
end

function runActiveXXTE()
 phase("Active XXTE")

 local function find_cookie()
  local bases = {
   "/private/var/mobile/Containers/Shared/AppGroup",
   "/var/mobile/Containers/Shared/AppGroup"
  }

  local paths = {
   "File Provider Storage/Downloads",
   "Downloads",
   "Documents/Downloads"
  }

  for _, base in ipairs(bases) do
   local groups = file.list(base)

   if type(groups) == "table" then
    for _, folder in pairs(groups) do
     for _, p in ipairs(paths) do
      local src = base .. "/" .. folder .. "/" .. p .. "/Cookies.binarycookies"
      if file.exists(src) then
       return src
      end
     end
    end
   end
  end

  return nil
 end

 local safariPath = app.data_path("com.apple.mobilesafari") or ""
 local cookiePath = safariPath .. "/Library/Cookies/Cookies.binarycookies"
 local backupPath = safariPath .. "/Library/Cookies/Cookies_backup.binarycookies"

 local function q(path)
  return string.format("%q", tostring(path or ""))
 end
 local function rm_path(path)
  if not path or path == "" then return end
  pcall(function() if file.remove then file.remove(path) end end)
  pcall(function() os.remove(path) end)
  os.execute("rm -rf " .. q(path) .. " 2>/dev/null")
 end
 local function clean_dir(path)
  if not path or path == "" then return end
  -- XXTouch file.remove đôi khi không xoá sạch folder sqlite/WKWebsiteData; dùng rm -rf + dotfiles.
  os.execute("rm -rf " .. q(path) .. "/* " .. q(path) .. "/.[!.]* " .. q(path) .. "/..?* 2>/dev/null")
 end
 local function recreate(path)
  if not path or path == "" then return end
  os.execute("mkdir -p " .. q(path) .. " 2>/dev/null")
 end

 -- Kill Safari/WebKit trước khi xoá; nếu còn process thì WebsiteData/Cookies tự sinh lại.
 pcall(function() app.quit("com.apple.mobilesafari") end)
 pcall(function() app.quit("com.apple.WebApp") end)
 os.execute("killall MobileSafari WebKit.WebContent WebKit.Networking com.apple.WebKit.Networking 2>/dev/null")
 sleep(1500)

 -- clear cookies bằng hàm chính chủ XXTouch trước, rồi fallback xoá tay mạnh hơn
 pcall(function()
  local okc, clear_mod = pcall(require, "clear")
  if okc and clear_mod and clear_mod.cookies then clear_mod.cookies() end
 end)

 -- backup cookie cũ rồi xoá sạch Safari để tránh vào acc cũ
 if file.exists(cookiePath) then
  local old = file.reads(cookiePath)
  if old then pcall(function() file.writes(backupPath, old) end) end
 end
 local clear_targets = {
  safariPath .. "/Library/Cookies",
  safariPath .. "/Library/Safari",
  safariPath .. "/Library/WebKit",
  safariPath .. "/Library/Caches",
  safariPath .. "/Library/Preferences",
  safariPath .. "/Library/Application Support",
  safariPath .. "/Documents",
  safariPath .. "/tmp",
  safariPath .. "/StoreKit",
  "/var/mobile/Library/Safari",
  "/private/var/mobile/Library/Safari",
  "/var/mobile/Library/Cookies",
  "/private/var/mobile/Library/Cookies",
  "/var/mobile/Library/Caches/com.apple.mobilesafari",
  "/private/var/mobile/Library/Caches/com.apple.mobilesafari",
  "/var/mobile/Library/WebKit/com.apple.mobilesafari",
  "/private/var/mobile/Library/WebKit/com.apple.mobilesafari",
  "/var/mobile/Library/WebKit/WebsiteData",
  "/private/var/mobile/Library/WebKit/WebsiteData",
  "/var/mobile/Library/Caches/com.apple.WebKit.Networking",
  "/private/var/mobile/Library/Caches/com.apple.WebKit.Networking"
 }
 for _, p in ipairs(clear_targets) do
  clean_dir(p)
  rm_path(p)
  recreate(p)
 end
 rm_path(cookiePath)
 rm_path("/var/mobile/Media/1ferver/ipa/Cookies.binarycookies")
 rm_path("/var/mobile/Media/1ferver/ipa/Safari_Cookies.binarycookies")
 rm_path(safariPath .. "/Library/WebKit/WebsiteData")
 rm_path(safariPath .. "/Library/Safari/History.db")
 rm_path(safariPath .. "/Library/Safari/BrowserState.db")
 os.execute("find " .. q(safariPath) .. " /var/mobile/Library /private/var/mobile/Library -iname '*google*' -o -iname '*gmail*' -o -iname '*account*' 2>/dev/null | while read p; do rm -rf \"$p\"; done")
 os.execute("sync")

 -- Không tự load cookie local ở đây nữa.
 -- Nhập Cookies là nút riêng; LoginGG phải clear Safari trắng để tránh vào acc cũ.

 local cf=io.open('/var/mobile/Media/1ferver/log/login_clear_safari_done.txt','w')
 if cf then cf:write(os.date('%H:%M:%S')..' CLEAR_V2_DONE safariPath='..tostring(safariPath)..'\n'); cf:close() end
 oc_toast("Clear Safari xong", 0)
 waitPhase(5000)
 return true
end

function httpGet(url)
 local oks,sh=pcall(require,"socket.http")
 if oks and sh and sh.request then
  local body,code=sh.request(url)
  if tostring(code)=="200" and type(body)=="string" and body~="" then return body,nil end
  return nil,tostring(code or body or "http_fail")
 end
 local okh,http=pcall(require,"http")
 if okh and http and http.get then
  local ok,res=pcall(http.get,url)
  if ok and type(res)=="string" and res:find("^{") then return res,nil end
  return nil,tostring(res or "http_get_fail")
 end
 return nil,"no_http_lib"
end

function parseAccJson(data)
 data=(data or ""):gsub("\r",""):gsub("\n","")
 if data:find('"ok"%s*:%s*false') then return nil,nil,"server hết acc" end
 local line=data:match('"acc"%s*:%s*"(.-)"')
 if not line or line=="" then return nil,nil,"server trả acc rỗng" end
 line=line:gsub('\\/','/'):gsub('\\"','"')
 local left,right=line:match("^(.-)|(.*)$")
 if not left then return nil,nil,"acc thiếu dấu |" end
 return left,right,nil
end

function fetchAccount()
 phase("Lấy acc từ server")
 local lastErr=""
 for base in tostring(PC_API):gmatch("[^|]+") do
  local url=base .. "/api/safari_next_acc?machine=" .. MACHINE
  phase("GET acc server")
  local data,err=httpGet(url)
  if data then
   local a,b,e=parseAccJson(data)
   if a then return a,b,nil end
   lastErr=e or "parse"
  else
   lastErr=tostring(err or "http_fail")
  end
 end
 return nil,nil,"Không lấy được acc server: " .. lastErr
end

function pasteText(text)
 text = tostring(text or "")
 if ok_pb and pasteboard and pasteboard.write then pasteboard.write(text) end
 sleep(300)
 key.send_text(text)
end

function tapReturn(label)
 phase(label or "Bấm return")
 touch.tap(658, 1289)
 waitPhase(3000)
 return true
end

function tapFieldAndPaste(x, y, text, label)
 phase(label)
 touch.tap(x, y)
 waitPhase(1000)
 pasteText(text)
 waitPhase(1500)
 return true
end

function swipeDownFrom614119()
 phase("Vuốt xuống trước sign")
 touch.down(1, 614, 119)
 sleep(800)
 touch.move(1, 614, 720)
 sleep(800)
 touch.up(1)
 waitPhase(1000)
end

-- Chỉ dùng trước lúc nhập input lần đầu.
-- Sau khi thấy sign.png và bắt đầu nhập input thì không check/vuốt xuống sign nữa.
function waitSign()
 phase("Đợi sign.png trước input 1")
 local lastSwipeAt = os.time()
 while true do
  handleNotNow()
  local ok, x, y = findImage(SIGN_IMG, 82, 0, 0, 750, 1334)
  if ok then
   phase("Thấy sign.png")
   return true, x, y
  end
  if os.time() - lastSwipeAt >= 60 then
   swipeDownFrom614119()
   lastSwipeAt = os.time()
  else
   status("Đợi sign.png")
   sleep(500)
  end
 end
end

function waitWellcom()
 phase("Đợi wellcom.png")
 while true do
  handleNotNow()
  local ok, x, y = findImage(WELLCOM_IMG, 82, 0, 0, 750, 1334)
  if ok then
   phase("Thấy wellcom.png")
   return true, x, y
  end
  status("Đợi wellcom.png")
  sleep(500)
 end
end

function swipeUpOnceNormal()
 phase("Vuốt lên")
 touch.down(1, 360, 1050)
 sleep(30)
 touch.move(1, 360, 820)
 sleep(30)
 touch.up(1)
 waitPhase(1200)
end

function swipeUpUntilInderstand()
 phase("Tìm inderstand.png")
 local startAt = os.time()
 while os.time() - startAt < 300 do
  handleNotNow()
  local ok, x, y = findImage(INDERSTAND_IMG, 82, 0, 0, 750, 1334)
  if ok then
   phase("Thấy inderstand.png")
   sleep(2000)
   local cx, cy = imageCenter(INDERSTAND_IMG, x, y)
   touch.tap(cx, cy)
   sleep(1000)
   return true, cx, cy
  end
  swipeUpOnceNormal()
 end
 oc_toast("Không thấy inderstand.png sau 5 phút", 1)
 return false, -1, -1
end

function runStage6()
 phase("Stage 6")

 phase("Mở Google signin")
 app.open_url(TIKTOK_OPEN_URL)
 waitPhase(5000)

 -- Bước 1: chỉ ở đoạn này mới đợi sign.png và 60s vuốt xuống một lần nếu chưa thấy.
 -- Qua tới nhập input lần đầu thì tuyệt đối không check/vuốt xuống sign nữa.
 phase("Bước 1: chờ sign")
 waitSign()
 local beforePipe, afterPipe, err = fetchAccount()
 if err then
  phase(err)
  return false
 end
 tapFieldAndPaste(356, 527, beforePipe, "Bước 1: dán trước dấu |")
 tapReturn("Bước 1: bấm return lần 1")
 waitPhase(2000)

 -- Bước 2: đợi wellcom.png, dán nội dung sau dấu |, bắt buộc bấm return xong mới sang bước 3.
 phase("Bước 2: chờ wellcom")
 waitWellcom()
 tapFieldAndPaste(445, 638, afterPipe, "Bước 2: dán sau dấu |")
 tapReturn("Bước 2: bấm return lần 2")
 phase("Bước 2: đã bấm return lần 2")
 waitPhase(5000)

 -- Bước 3: chỉ bắt đầu sau khi bước 2 đã dán input lần 2 và bấm return lần 2 xong.
 -- Đoạn này chỉ vuốt lên bình thường, không ấn giữ lâu. Ấn giữ chỉ dùng lúc vuốt xuống tìm sign.png ban đầu.
 phase("Bước 3: tìm inderstand")
 if not swipeUpUntilInderstand() then
  return false
 end

 oc_toast("Hoàn thành login gg", 1)
 return true
end

phase("Khởi động " .. SCRIPT_VERSION)
waitPhase(1000)
if not runStage6() then
 phase("Lỗi Stage 6")
 return
end
phase("ALL DONE")
return

end, debug.traceback)
if not __ok then local f=io.open('/var/mobile/Media/1ferver/log/inline_login_error.txt','w'); if f then f:write(tostring(__err)); f:close() end; error(__err) end

