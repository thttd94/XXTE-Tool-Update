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
return true
