screen.init(0)

local app = require("app")
local file = require("file")
local sys = require("sys")
local key = require("key")

local SCRIPT_VERSION = "STAGE6_TIKTOK_V4_CLEAR_FILEAPI_20260701"
local BID_SAFARI = "com.apple.mobilesafari"
local RES_DIR = "/var/mobile/Media/1ferver/lua/examples/"
local SIGN_IMG = RES_DIR .. "sign.png"
local WELLCOM_IMG = RES_DIR .. "wellcom.png"
local INDERSTAND_IMG = RES_DIR .. "inderstand.png"
local NOTNOW_IMG = RES_DIR .. "notnow.png"
local TIKTOK_OPEN_URL = "https://accounts.google.com/ServiceLogin?hl=en&flowName=GlifWebSignIn&flowEntry=ServiceLogin"
local PC_API = "http://192.14.1.10:8788|http://192.168.9.201:8788|http://169.254.83.107:8788|http://192.17.1.10:8788|http://192.16.1.10:8788|http://192.15.1.10:8788|http://172.23.80.1:8788"
local MACHINE = "115"
local DEBUG_LOG = "/var/mobile/Media/1ferver/log/LoginGGSafari_Stage6_debug.log"

local function dlog(s)
 pcall(function()
  local f=io.open(DEBUG_LOG,"a")
  if f then f:write(os.date("%H:%M:%S ") .. tostring(s or "") .. "\n"); f:close() end
 end)
end

local function sleep(ms) sys.msleep(ms) end
local function toast(s) pcall(sys.toast, tostring(s or ""), 0) end
local function phase(s) dlog(s); toast(tostring(s or "")) end

local function waitPhase(ms)
 local remain=ms
 while remain>0 do
  local step=math.min(5,remain)
  sleep(step); remain=remain-step
 end
end

local function shellQuote(s)
 s=tostring(s or "")
 return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function httpGet(url)
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
local function parseAccJson(data)
 data=(data or ""):gsub("\r",""):gsub("\n","")
 if data:find('"ok"%s*:%s*false') then return nil,nil,"pyw hết acc" end
 local line=data:match('"acc"%s*:%s*"(.-)"')
 if not line or line=="" then return nil,nil,"pyw trả acc rỗng" end
 line=line:gsub('\\/','/'):gsub('\\"','"')
 local left,right=line:match("^(.-)|(.*)$")
 if not left then return nil,nil,"acc thiếu dấu |" end
 return left,right,nil
end

local function fetchAccount()
 phase("Lấy acc từ pyw")
 local lastErr=""
 for base in tostring(PC_API):gmatch("[^|]+") do
  local url=base .. "/api/safari_next_acc?machine=" .. MACHINE
  dlog("GET " .. url)
  local data,err=httpGet(url)
  if data then
   dlog("GET OK " .. tostring(data):sub(1,120))
   local a,b,e=parseAccJson(data)
   if a then return a,b,nil end
   lastErr=e or "parse"
  else
   dlog("GET FAIL " .. tostring(err))
   lastErr=tostring(err or "http_fail")
  end
 end
 return nil,nil,"Không lấy được acc pyw: " .. lastErr
end
local function pathJoin(a,b)
 if tostring(a):sub(-1)=="/" then return a .. b end
 return a .. "/" .. b
end

local function cleanDirLua(dir)
 dir=tostring(dir or "")
 if dir=="" then return 0 end
 dlog("CLEAN_DIR "..dir)
 local okList, items = pcall(function() return file.list(dir) end)
 if not okList or type(items) ~= "table" then dlog("LIST_ERR "..dir); return 0 end
 local count=0
 for _,name in pairs(items) do
  name=tostring(name)
  if name ~= "." and name ~= ".." then
   local path=pathJoin(dir,name)
   pcall(function() cleanDirLua(path) end)
   local ok1=pcall(function() if type(file.remove)=="function" then file.remove(path) end end)
   local ok2=pcall(function() os.remove(path) end)
   dlog("DEL "..path.." file.remove="..tostring(ok1).." os.remove="..tostring(ok2))
   count=count+1
  end
 end
 return count
end

local function clearSafariAll()
 phase("Clear Safari FULL")
 pcall(app.quit, BID_SAFARI)
 waitPhase(1200)
 os.execute("killall -9 MobileSafari SafariViewService com.apple.WebKit.WebContent com.apple.WebKit.Networking cfprefsd 2>/dev/null || true")
 waitPhase(800)
 local safariData = app.data_path(BID_SAFARI) or ""
 dlog("SAFARI_DATA="..tostring(safariData))
 -- Xoá bằng Lua file API trước: ổn hơn shell trên XXTE.
 local dirs = {
  "/var/mobile/Library/Safari",
  "/private/var/mobile/Library/Safari",
  "/var/mobile/Library/WebKit",
  "/private/var/mobile/Library/WebKit",
  "/var/mobile/Library/Cookies",
  "/private/var/mobile/Library/Cookies",
  "/var/mobile/Library/Saved Application State/com.apple.mobilesafari.savedState",
 }
 if safariData ~= "" then
  dirs[#dirs+1]=safariData.."/Library/Safari"
  dirs[#dirs+1]=safariData.."/Library/WebKit"
  dirs[#dirs+1]=safariData.."/Library/Cookies"
  dirs[#dirs+1]=safariData.."/Library/Caches"
  dirs[#dirs+1]=safariData.."/Library/Saved Application State"
  dirs[#dirs+1]=safariData.."/Documents"
  dirs[#dirs+1]=safariData.."/tmp"
 end
 for _,dir in ipairs(dirs) do cleanDirLua(dir) end
 local files = {
  "/var/mobile/Library/Preferences/com.apple.mobilesafari.plist",
  "/private/var/mobile/Library/Preferences/com.apple.mobilesafari.plist",
 }
 if safariData ~= "" then files[#files+1]=safariData.."/Library/Preferences/com.apple.mobilesafari.plist" end
 for _,path in ipairs(files) do pcall(function() file.remove(path) end); pcall(function() os.remove(path) end); dlog("DEL_FILE "..path) end
 -- Shell fallback, không phụ thuộc curl/sync.
 local cmds = {
  "rm -rf /var/mobile/Library/Safari/* /private/var/mobile/Library/Safari/* 2>/dev/null",
  "rm -rf /var/mobile/Library/WebKit/* /private/var/mobile/Library/WebKit/* 2>/dev/null",
  "rm -rf /var/mobile/Library/Cookies/* /private/var/mobile/Library/Cookies/* 2>/dev/null",
  "rm -rf /var/mobile/Library/Caches/com.apple.mobilesafari* /private/var/mobile/Library/Caches/com.apple.mobilesafari* 2>/dev/null",
  "rm -rf /var/mobile/Library/Caches/com.apple.WebKit* /private/var/mobile/Library/Caches/com.apple.WebKit* 2>/dev/null",
  "rm -rf /var/mobile/Library/Saved\\ Application\\ State/com.apple.mobilesafari.savedState 2>/dev/null",
  "rm -f /var/mobile/Library/Preferences/com.apple.mobilesafari.plist /private/var/mobile/Library/Preferences/com.apple.mobilesafari.plist 2>/dev/null",
  "mkdir -p /var/mobile/Library/Safari 2>/dev/null",
 }
 if safariData ~= "" then
  cmds[#cmds+1] = "rm -rf " .. string.format("%q", safariData .. "/Library/Safari") .. " " .. string.format("%q", safariData .. "/Library/WebKit") .. " " .. string.format("%q", safariData .. "/Library/Caches") .. " " .. string.format("%q", safariData .. "/Library/Cookies") .. " " .. string.format("%q", safariData .. "/Documents") .. " " .. string.format("%q", safariData .. "/tmp") .. " 2>/dev/null"
 end
 for _,cmd in ipairs(cmds) do dlog("CMD "..cmd); os.execute(cmd) end
 os.execute("killall -9 cfprefsd 2>/dev/null || true")
 waitPhase(1500)
 pcall(app.quit, BID_SAFARI)
 return true
end
local function pasteText(text)
 text=tostring(text or "")
 pcall(function() pasteboard.write(text) end)
 sleep(300)
 pcall(function() key.send_text(text) end)
end

local function findImage(img, sim, x1,y1,x2,y2)
 sim=sim or 82; x1=x1 or 0; y1=y1 or 0; x2=x2 or 750; y2=y2 or 1334
 local x,y=screen.find_image(img,sim,x1,y1,x2,y2)
 return x~=-1,x,y
end

local function imageCenter(imgPath,x,y)
 local ok_image,image=pcall(require,"image")
 if not ok_image then return x,y end
 local img=image.load_file(imgPath); if not img then return x,y end
 local w,h=img:size(); if not w or not h then return x,y end
 return math.floor(x+w/2), math.floor(y+h/2)
end

local function handleNotNow()
 local ok,x,y=findImage(NOTNOW_IMG,82,0,0,750,1334)
 if ok then sleep(2000); touch.tap(x,y); sleep(1000); return true end
 return false
end

local function tapReturn(label)
 phase(label or "Return")
 touch.tap(658,1289)
 waitPhase(3000)
end

local function tapFieldAndPaste(x,y,text,label)
 phase(label)
 touch.tap(x,y); waitPhase(1000); pasteText(text); waitPhase(1500)
end

local function swipeDownFrom614119()
 phase("Vuốt xuống tìm sign")
 touch.down(1,614,119); sleep(800); touch.move(1,614,720); sleep(800); touch.up(1); waitPhase(1000)
end

local function forceOpenSignin()
 phase("Force Google signin URL")
 pcall(app.open_url, TIKTOK_OPEN_URL)
 waitPhase(2500)
 -- Nếu Safari đang nằm ở gstatic/about.google/terms, ép thanh địa chỉ về login.
 pcall(function() touch.tap(335,1077) end) -- bottom address bar on iPhone 115
 waitPhase(600)
 pcall(function() key.send_text(TIKTOK_OPEN_URL) end)
 waitPhase(500)
 pcall(function() touch.tap(657,1289) end) -- Return
 waitPhase(5000)
end

local function handleGoogleBlockingUi()
 -- Máy 115 hay mở Google preview/cookie sheet: about.google + Agree/No thanks + menu Open.
 -- Tap nhẹ các vùng này; nếu không có UI thì harmless.
 pcall(function() touch.tap(365,1038) end) -- Open trong context menu nếu đang hiện
 sleep(300)
 pcall(function() touch.tap(492,914) end) -- No thanks cookie
 sleep(300)
 pcall(function() touch.tap(186,914) end) -- Agree cookie fallback
 sleep(300)
end

local function waitSign()
 phase("Đợi sign.png")
 local lastSwipeAt=os.time()
 while true do
  handleNotNow()
  handleGoogleBlockingUi()
  local ok,x,y=findImage(SIGN_IMG,82,0,0,750,1334)
  if ok then return true,x,y end
  if os.time()-lastSwipeAt>=60 then forceOpenSignin(); lastSwipeAt=os.time() else sleep(500) end
 end
end

local function waitWellcom()
 phase("Đợi wellcom.png")
 while true do
  handleNotNow()
  local ok,x,y=findImage(WELLCOM_IMG,82,0,0,750,1334)
  if ok then return true,x,y end
  sleep(500)
 end
end

local function swipeUpOnceNormal()
 touch.down(1,360,1050); sleep(30); touch.move(1,360,820); sleep(30); touch.up(1); waitPhase(1200)
end

local function swipeUpUntilInderstand()
 phase("Tìm inderstand.png")
 local startAt=os.time()
 while os.time()-startAt<300 do
  handleNotNow()
  local ok,x,y=findImage(INDERSTAND_IMG,82,0,0,750,1334)
  if ok then local cx,cy=imageCenter(INDERSTAND_IMG,x,y); sleep(2000); touch.tap(cx,cy); sleep(1000); return true end
  swipeUpOnceNormal()
 end
 return false
end

local function runStage6()
 phase("Stage6 start")
 clearSafariAll()
 phase("Mở Google signin")
 forceOpenSignin()
 handleGoogleBlockingUi()
 forceOpenSignin()
 waitSign()
 local beforePipe,afterPipe,err=fetchAccount()
 if err then phase(err); return false end
 tapFieldAndPaste(356,527,beforePipe,"Dán email")
 tapReturn("Return 1")
 waitPhase(2000)
 waitWellcom()
 tapFieldAndPaste(445,638,afterPipe,"Dán pass")
 tapReturn("Return 2")
 waitPhase(5000)
 if not swipeUpUntilInderstand() then return false end
 phase("Hoàn thành login gg")
 return true
end

math.randomseed(os.time())
local d=math.random(1,500)
while d>0 do toast("Delay start "..d.."s"); sleep(1000); d=d-1 end
if not runStage6() then phase("Lỗi Stage6"); return end
phase("ALL DONE")
return




