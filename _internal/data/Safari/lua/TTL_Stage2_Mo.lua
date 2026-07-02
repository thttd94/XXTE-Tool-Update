

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
    return show_webview_status()
end

app = require("app")
device = require("device")
sys = require("sys")

while (device.is_screen_locked()) do
 device.unlock_screen()
 sys.msleep(1000)
end

app.run("com.apple.springboard")
print("HOME Đang chạy ...")
print("HOME_OK")

screen.init(0)
local device = require("device")
local __ok_image, image = pcall(require, "image")
if not __ok_image then image = nil end

local function oc_swipe(x1, y1, x2, y2, durationMs)
 durationMs = durationMs or 300
 if touch and type(touch.down) == "function" and type(touch.move) == "function" and type(touch.up) == "function" then
  touch.down(1, x1, y1)
  sys.msleep(math.floor(durationMs / 3))
  touch.move(1, math.floor((x1 + x2) / 2), math.floor((y1 + y2) / 2))
  sys.msleep(math.floor(durationMs / 3))
  touch.move(1, x2, y2)
  sys.msleep(math.floor(durationMs / 3))
  touch.up(1)
  return true
 end
 if touch and type(touch.on) == "function" then
  local ok, t = pcall(touch.on, 1, x1, y1)
  if not ok or not t then ok, t = pcall(touch.on, x1, y1) end
  if ok and t then
   sys.msleep(math.floor(durationMs / 3))
   if type(t.move) == "function" then t:move(math.floor((x1 + x2) / 2), math.floor((y1 + y2) / 2)) end
   sys.msleep(math.floor(durationMs / 3))
   if type(t.move) == "function" then t:move(x2, y2) end
   sys.msleep(math.floor(durationMs / 3))
   if type(t.off) == "function" then t:off() end
   return true
  end
 end
 return false
end
local __WEBVIEW_STATUS_TEXT = "Nuôi Phôi TTL đang tiến hành ...."
local __ok_webview_status, __webview_status = pcall(require, "webview")
local __WEBVIEW_STATUS_ID = 88
local __WEBVIEW_STATUS_HTML = [[
<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"><style>
html,body{margin:0;padding:0;width:100%;height:100%;background:transparent;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,sans-serif;-webkit-user-select:none;user-select:none;-webkit-touch-callout:none}
#bar{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.58);color:#fff;border-radius:12px;font-size:17px;font-weight:700;text-align:center;white-space:nowrap;box-sizing:border-box}
</style></head><body><div id="bar">Nuôi Phôi TTL đang tiến hành ....</div></body></html>
]]
function show_webview_status()
 if __ok_webview_status and __webview_status and type(__webview_status.show) == "function" then
  pcall(__webview_status.show, { id = __WEBVIEW_STATUS_ID, html = __WEBVIEW_STATUS_HTML, x = 1, y = 1, width = 748, height = 38, alpha = 1.0, corner_radius = 12, opaque = false, can_drag = false, ignores_hit = true })
 end
end
show_webview_status()
function __oc_toast_replacement(text, ...) if type(oc_status) == "function" then pcall(oc_status, __WEBVIEW_STATUS_TEXT) end; show_webview_status(); return nil end
sys = sys or {}
sys["toast"] = __oc_toast_replacement

function oc_assistive_touch_off()
 pcall(function() if sys and type(sys.assistive_touch_off) == "function" then sys.assistive_touch_off() end end)
end

function oc_assistive_touch_on()
 pcall(function() if sys and type(sys.assistive_touch_on) == "function" then sys.assistive_touch_on() end end)
end




oc_assistive_touch_off()

local TOUCH_ID_IMG = "/var/mobile/Media/1ferver/lua/examples/touchID.png"
local touch_id_x, touch_id_y = screen.find_image(TOUCH_ID_IMG, 82, 0, 0, 750, 1334)
if touch_id_x ~= -1 then
    touch.tap(381, 792)
    oc_toast("Tapped Touch ID", 1)
    sys.msleep(1000)
end

clear.app_data("com.ss.iphone.ugc.Ame")
clear.app_data("com.ss.iphone.ugc.tiktok.lite")
oc_toast("clear tiktok done", 1)
sys.msleep(1000)

local SCRIPT_VERSION = "TL_ALLIN1_V9_STAGE2_EVENT"
local TIKTOK_BUNDLE = "com.ss.iphone.ugc.Ame"
local TIKTOK_LITE_BUNDLE = "com.ss.iphone.ugc.tiktok.lite"
local APPMANAGER_BUNDLE = "com.tigisoftware.ADManager"
local APPSTORE_BUNDLE = "com.apple.AppStore"
local TIKTOK_LITE_STORE_URL = "https://apps.apple.com/jp/app/tiktok-lite/id6447160980?l=en-US"
local RES_DIR = "/var/mobile/Media/1ferver/lua/examples/"

local CLOUD_IMG = RES_DIR .. "cloudTTL.png"
local OPEN_IMG = RES_DIR .. "openTTL.png"
local CHECK_ERROR1_IMG = RES_DIR .. "check_error1.png"
local TAP_ERROR1_IMG = RES_DIR .. "tap_error1.png"
local CHECK_ERROR2_IMG = RES_DIR .. "check_error2.png"
local TAP_ERROR2_IMG = RES_DIR .. "tap_error2.png"

local CHECK_POPUP_WELLCOME = RES_DIR .. "check_popup_wellcome.png"
local TAP_POPUP_WELLCOME = RES_DIR .. "tap_popup_wellcome.png"
local CHECK_POPUP_PERMISS_LIST = {
 RES_DIR .. "check_popup_permiss.png",
 RES_DIR .. "check_popup_permis1.png",
 RES_DIR .. "check_popup_permis2.png",
 RES_DIR .. "check_popup_permis3.png"
}
local TAP_POPUP_PERMISS = RES_DIR .. "tap_popup_permiss.png"
local CHECK_POPUP_ALLOW = RES_DIR .. "check_popup_allow.png"
local TAP_POPUP_ALLOW = RES_DIR .. "tap_popup_allow.png"
local CHECK_POPUP_TAPPING = RES_DIR .. "check_popup_tapping.png"
local TAP_POPUP_TAPPING = RES_DIR .. "tap_popup_tapping.png"
local CHECK_POPUP_CHOOSE_LIST = {
 RES_DIR .. "check_popup_choose.png",
 RES_DIR .. "check_popup_choose1.png"
}
local POPUP_1_CHECK1 = RES_DIR .. "Popup_1_check1.png"
local POPUP_1_TAP = RES_DIR .. "Popup_1_tap.png"
local CAPTCHA_IMG = RES_DIR .. "capcha.png"
local CHECK_POPUP_SWIPE = RES_DIR .. "check_popup_swipe.png"
local CHECK_POPUP_EVENT1 = RES_DIR .. "check_popup_Event1.png"
local CHECK_POPUP_EVENT2 = RES_DIR .. "check_popup_Event2.png"
local CHECK_POPUP_INTERNET = RES_DIR .. "check_popup_internet.png"
local XULITE_IMG = RES_DIR .. "Xulite.png"

local CHECK_TTL = RES_DIR .. "check_TTL.png"
local CHECK_BACKUPTTL = RES_DIR .. "check_backupttl.png"
local TAP_BACKUPTTL = RES_DIR .. "tap_backupttl.png"
local TAP_BACKUP = RES_DIR .. "tap_backup.png"
local CHECK_BACKUPING = RES_DIR .. "check_backuping.png"
local CHECK_BACKUPDONE = RES_DIR .. "check_backupdone.png"

local CHECK_TRACK_PATTERN = {
 {181,470,0x000000},
 {402,455,0x000000},
 {449,605,0x000000},
 {567,515,0x000000},
 {523,799,0x007aff},
 {398,790,0x007aff},
 {403,881,0x007aff},
 {340,888,0x007aff},
}

local EVENT_COLOR_PATTERN = {
 {173,235,0xe83128},
 {172,204,0xe83128},
 {215,207,0xe83128},
 {215,235,0xe83128},
 {533,206,0xe83128},
 {532,237,0xe83128},
 {576,208,0xe83128},
 {482,297,0xffdf35},
 {243,237,0xffdf35},
 {599,856,0xe73129},
 {244,870,0xe93128},
 {645,197,0x000000},
}

local NEW_POPUP_COLOR_PATTERN = {
 {197,1240,0x000000},
 {193,1239,0x000000},
 {186,1242,0x000000},
 {187,1246,0x000000},
 {194,1249,0x000000},
 {198,1255,0x000000},
 {186,1257,0x000000},
 {215,1245,0x000000},
 {206,1252,0x000000},
 {206,1258,0x000000},
 {216,1259,0x000000},
 {224,1239,0x000000},
 {232,1249,0x000000},
 {232,1257,0x000000},
 {232,1265,0x000000},
 {244,1254,0x000000},
 {238,1259,0x000000},
}

local POST_OPEN_COLOR_PATTERN_1 = {
 {230,799,0x007aff},{219,800,0x007aff},{225,786,0x007aff},{247,791,0x007aff},{241,797,0x007aff},{249,800,0x007aff},{244,807,0x007aff},{284,799,0x007aff},{289,799,0x007aff},{295,799,0x007aff},{325,799,0x007aff},{337,802,0x007aff},{390,798,0x007aff},{398,789,0x007aff},{398,793,0x007aff},{398,798,0x007aff},{437,791,0x007aff},{440,797,0x007aff},{462,800,0x007aff},{474,793,0x007aff},{497,798,0x007aff},{504,793,0x007aff},{523,785,0x007aff},
}

local POST_OPEN_COLOR_PATTERN_2 = {
 {157,797,0x007aff},{157,818,0x007aff},{173,811,0x007aff},{220,797,0x007aff},{229,804,0x007aff},{229,802,0x007aff},{232,803,0x007aff},{256,799,0x007aff},{261,812,0x007aff},{314,804,0x007aff},{308,818,0x007aff},{319,817,0x007aff},{323,807,0x007aff},
}

local XULITE_TAPPED_SCREEN_PATTERN = {
 {73,156,0xffffff},
 {685,148,0xffffff},
 {90,428,0xffffff},
 {616,997,0xffffff},
 {628,983,0xffffff},
 {474,968,0xffffff},
}

local FINAL_COLOR_PATTERN = {
 {662,601,0xe31a10},
 {122,594,0xe41a10},
 {639,360,0xffec86},
 {591,156,0xffec86},
 {153,174,0xffec86},
 {113,363,0xffec86},
}

local function sleep(ms)
 sys.msleep(ms)
end

local __last_status = ""
local __last_status_at = 0
local __phase = ""

local function shortText(t)
 if #t > 40 then
  return string.sub(t, 1, 37) .. "..."
 end
 return t
end

function status(t)
 t = shortText(t)
 local text = "Ver " .. SCRIPT_VERSION .. " : " .. t
 local now = os.time()
 if text ~= __last_status or now - __last_status_at >= 1 then
  if type(__oc_write_status) == "function" then pcall(__oc_write_status, text) end
  oc_toast(text, 0)
  __last_status = text
  __last_status_at = now
 end
end

local function failStatus(t)
 status("ERROR: " .. tostring(t or "Lỗi script"))
 error(tostring(t or "Lỗi script"))
end

function phase(t)
 __phase = t
 __last_status = ""
 show_webview_status()
 status(t)
end

function phaseProgress(sec)
 status(__phase .. " " .. sec .. "s")
end

function statusScan(img)
 local name = tostring(img or "")
 local simple = string.match(name, "([^/]+)$") or name
 status("Scan " .. simple)
end

function waitPhase(ms)
 local remain = ms
 local lastShown = -1

 while remain > 0 do
  local sec = math.ceil(remain / 1000)
  if sec ~= lastShown then
   phaseProgress(sec)
   lastShown = sec
  end

  local step = 1000
  if remain < 1000 then
   step = remain
  end

  sleep(step)
  remain = remain - step
 end
end

function findImage(img, sim, x1, y1, x2, y2)
 statusScan(img)
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

function findAnyImage(imgList, sim, x1, y1, x2, y2)
 for i = 1, #imgList do
  local ok, x, y = findImage(imgList[i], sim, x1, y1, x2, y2)
  if ok then
   return true, x, y, imgList[i]
  end
 end

 return false, -1, -1, nil
end

function findTrackPopup()
 status("Scan check track")
 local x, y = screen.find_color(CHECK_TRACK_PATTERN, 95, 0, 0, 0, 0)
 if x ~= -1 then
  status("Hit check track")
  return true, x, y
 end
  return false, -1, -1
end

function findEventByColor()
 status("Scan event color")
 local x, y = screen.find_color(EVENT_COLOR_PATTERN, 95, 0, 0, 0, 0)
 if x ~= -1 then
  status("Hit event color")
  return true, x, y
 end
 return false, -1, -1
end

function findNewPopupByColor()
 status("Scan popup color")
 local x, y = screen.find_color(NEW_POPUP_COLOR_PATTERN, 95, 0, 0, 0, 0)
 if x ~= -1 then
  status("Hit popup color")
  return true, x, y
 end
 return false, -1, -1
end

function getImageCenter(path, x, y)
 if not image or type(image.load_file) ~= "function" then
  return x, y
 end
 local ok, img = pcall(image.load_file, path)
 if not ok or not img then
  return x, y
 end

 local okSize, w, h = pcall(function() return img:size() end)
 if not okSize or not w or not h then
  return x, y
 end

 local cx = math.floor(x + (w / 2))
 local cy = math.floor(y + (h / 2))
 return cx, cy
end

function tapByImageCenter(img, sim, x1, y1, x2, y2)
 local ok, x, y = findImage(img, sim, x1, y1, x2, y2)
 if ok then
  local cx, cy = getImageCenter(img, x, y)
  status("Tap " .. (string.match(img, "([^/]+)$") or img))
  touch.tap(cx, cy)
  return true, cx, cy
 end

 return false, -1, -1
end

function hasBundle(bundleId)
 local bundles = app.bundles()
 if type(bundles) ~= "table" then
  return nil
 end

 for _, bid in ipairs(bundles) do
  if bid == bundleId then
   return true
  end
 end

 return false
end

function swipeUpOnce()
 status("Swipe up")
 oc_swipe(360, 1050, 360, 860, 120)
end

function quitApp(bundleId, label)
 phase("Quit " .. label)
 app.quit(bundleId)
 waitPhase(1500)
end

function openApp(bundleId, label, waitMs)
 phase("Mở " .. label)
 app.run(bundleId)
 waitPhase(waitMs or 4000)
end

function waitUninstallGone(bundleId, label, timeoutSec)
 local start_wait = os.time()
 local lastShown = -1
 phase("Chờ gỡ " .. label)

 while os.time() - start_wait < timeoutSec do
  local remain = timeoutSec - (os.time() - start_wait)
  if remain ~= lastShown then
   phaseProgress(remain)
   lastShown = remain
  end

  local installed_now = hasBundle(bundleId)
  if installed_now == false then
   phase(label .. " đã gỡ")
   waitPhase(1200)
   return true
  end

  sleep(1000)
 end

 return false
end

function uninstallIfPresent(bundleId, label)
 local installed_before = hasBundle(bundleId)
 if installed_before == false then
  phase(label .. " không có")
  waitPhase(800)
  return true
 end

 phase("Gỡ " .. label)
 app.uninstall(bundleId)
 waitPhase(2500)

 if waitUninstallGone(bundleId, label, 120) then return true end

 phase("Gỡ lại " .. label)
 app.uninstall(bundleId)
 waitPhase(2500)

 if waitUninstallGone(bundleId, label, 90) then return true end

 phase("Gỡ lỗi " .. label)
 return false
end

function openTikTokLiteStore()
 phase("Mở link TikTok Lite")
 app.open_url(TIKTOK_LITE_STORE_URL)
 waitPostOpenColor5s()
 waitPhase(3000)
 app.open_url(TIKTOK_LITE_STORE_URL)
 waitPostOpenColor5s()
end

function restartTikTokLiteStore(reason)
 phase(tostring(reason or "Không vào được AppStore") .. " - quit AppStore + mở lại link")
 pcall(function() app.quit(APPSTORE_BUNDLE) end)
 waitPhase(2000)
 openTikTokLiteStore()
end

function handleError1UntilClear()
 local found = findImage(CHECK_ERROR1_IMG, 82, 0, 0, 750, 1334)
 if not found then return false end

 phase("Lỗi tải 1")
 while true do
  local stillThere = findImage(CHECK_ERROR1_IMG, 82, 0, 0, 750, 1334)
  if not stillThere then return true end

  local tapped = tapByImageCenter(TAP_ERROR1_IMG, 82, 0, 0, 750, 1334)
  if not tapped then
   touch.tap(375, 667)
   status("Tap lỗi 1 fb")
  else
   status("Tap lỗi 1")
  end
  waitPhase(1200)
 end
end

function hasError2()
 if findImage(CHECK_ERROR2_IMG, 82, 0, 0, 750, 1334) then return true end
 if findImage(CHECK_ERROR2_IMG, 80, 0, 0, 750, 1334) then return true end
 if findImage(CHECK_ERROR2_IMG, 78, 0, 0, 750, 1334) then return true end
 return false
end

function tapError2Button()
 local ok, x, y = findImage(TAP_ERROR2_IMG, 82, 0, 0, 750, 1334)
 if ok then local cx, cy = getImageCenter(TAP_ERROR2_IMG, x, y) status("Tap retry img82") touch.tap(cx, cy) return true end
 ok, x, y = findImage(TAP_ERROR2_IMG, 80, 0, 0, 750, 1334)
 if ok then local cx, cy = getImageCenter(TAP_ERROR2_IMG, x, y) status("Tap retry img80") touch.tap(cx, cy) return true end
 ok, x, y = findImage(TAP_ERROR2_IMG, 78, 0, 0, 750, 1334)
 if ok then local cx, cy = getImageCenter(TAP_ERROR2_IMG, x, y) status("Tap retry img78") touch.tap(cx, cy) return true end
 return false
end

function handleError2Tap()
 if not hasError2() then return false end
 phase("Lỗi mạng")
 if tapError2Button() then waitPhase(1200) return true end
 touch.tap(379, 750)
 status("Tap retry fb1")
 waitPhase(800)
 if hasError2() then
  if tapError2Button() then waitPhase(1200) return true end
  touch.tap(379, 750)
  status("Tap retry fb2")
  waitPhase(800)
 end
 return true
end

function waitError2Cycle(waitSec)
 phase("Chờ retry")
 local remain = waitSec
 local lastShown = -1
 while remain > 0 do
  if findImage(CLOUD_IMG, 82, 0, 0, 750, 1334) then return "cloud" end
  if handleError1UntilClear() then phase("Xong lỗi 1") end
  if remain ~= lastShown then phaseProgress(remain) lastShown = remain end
  sleep(1000)
  remain = remain - 1
 end
 return "timeout"
end

function handlePostOpenColorOnce()
 local x, y = screen.find_color(POST_OPEN_COLOR_PATTERN_1, 95, 0, 0, 0, 0)
 if x ~= -1 then
  status("Hit post-open color 1")
  touch.tap(x, y)
  waitPhase(800)
  return true
 end
 x, y = screen.find_color(POST_OPEN_COLOR_PATTERN_2, 95, 0, 0, 0, 0)
 if x ~= -1 then
  status("Hit post-open color 2")
  touch.tap(x, y)
  waitPhase(800)
  return true
 end
 return false
end

function waitPostOpenColor5s()
 local start = os.time()
 phase("Check popup sau mở app")
 while os.time() - start < 5 do
  if handlePostOpenColorOnce() then return true end
  sleep(300)
 end
 return false
end

function runStage1()
 phase("Stage 1")
 local ok_tiktok = uninstallIfPresent(TIKTOK_BUNDLE, "TikTok")
 local ok_tiktok_lite = uninstallIfPresent(TIKTOK_LITE_BUNDLE, "TikTok Lite")
 if not (ok_tiktok and ok_tiktok_lite) then return false end

 openTikTokLiteStore()
 local retry_waits = {10, 30, 60, 300, 600, 1200, 2400}
 local idx = 1
 local cloud_wait_start = os.time()

 while true do
  if os.time() - cloud_wait_start >= 180 then
   restartTikTokLiteStore("Sau 3p mở link không thấy cloud")
   idx = 1
   cloud_wait_start = os.time()
  end

  if findImage(CLOUD_IMG, 82, 0, 0, 750, 1334) then
   tapByImageCenter(CLOUD_IMG, 82, 0, 0, 750, 1334)
   waitPhase(2000)
   break
  end

  if handleError1UntilClear() then phase("Xong lỗi 1") end

  if hasError2() then
    local waitSec = retry_waits[idx]
    handleError2Tap()
    local cycleResult = waitError2Cycle(waitSec)
    if cycleResult == "cloud" then
      tapByImageCenter(CLOUD_IMG, 82, 0, 0, 750, 1334)
      waitPhase(2000)
      break
    end
    if idx < #retry_waits then idx = idx + 1 else retry_waits[#retry_waits + 1] = retry_waits[#retry_waits] * 2 idx = idx + 1 end
  else
    waitPhase(1000)
  end
 end

 while true do
  if findImage(OPEN_IMG, 82, 0, 0, 750, 1334) then
   phase("Stage 1 xong")
   return true
  end
  if handleError1UntilClear() then phase("Xử lý lỗi 1 xong") else
   if findImage(CLOUD_IMG, 82, 0, 0, 750, 1334) then
    tapByImageCenter(CLOUD_IMG, 82, 0, 0, 750, 1334)
    waitPhase(2000)
   else
    phase("Đang tải")
    waitPhase(1000)
   end
  end
 end
end

function openTikTokLite()
 phase("Mở TikTok Lite")
 app.run(TIKTOK_LITE_BUNDLE)
 waitPhase(30000)
end

function ensureTikTokLiteForeground()
 local front = app.front_bid()
 if front == TIKTOK_LITE_BUNDLE then
  return true
 end

 phase("Mở lại TikTok Lite")
 app.run(TIKTOK_LITE_BUNDLE)
 waitPhase(5000)
 return app.front_bid() == TIKTOK_LITE_BUNDLE
end

function hasEventPopup()
 if findImage(CHECK_POPUP_EVENT1, 82, 0, 0, 750, 1334) then return true end
 if findImage(CHECK_POPUP_EVENT2, 82, 0, 0, 750, 1334) then return true end
 if findEventByColor() then return true end
 return false
end

function handlePopupByImage(name, checkImg, tapImg)
 local ok = findImage(checkImg, 82, 0, 0, 750, 1334)
 if not ok then return false end
 phase(name)
 waitPhase(2000)
 local tapped = tapByImageCenter(tapImg, 82, 0, 0, 750, 1334)
 if tapped then waitPhase(1200) else status(name .. " fail tap") waitPhase(800) end
 return true
end

function handlePopupPermiss()
 local ok = findAnyImage(CHECK_POPUP_PERMISS_LIST, 82, 0, 0, 750, 1334)
 if not ok then
  return false
 end

 phase("Popup permiss")
 waitPhase(2000)

 local tapped = tapByImageCenter(TAP_POPUP_PERMISS, 82, 0, 0, 750, 1334)
 if tapped then
  waitPhase(1200)
 else
  status("Popup permiss fail tap")
  waitPhase(800)
 end

 return true
end

function handlePopupTrack()
 local ok = findTrackPopup()
 if not ok then
  return false
 end

 phase("Popup track")
 waitPhase(2000)
 touch.tap(399, 792)
 waitPhase(1200)
 return true
end

function handleNewPopupByColor()
 local ok, x, y = findNewPopupByColor()
 if not ok then return false end
 phase("Popup color")
 touch.tap(x, y)
 waitPhase(500)
 return true
end

function handlePopupChoose()
 local ok = findAnyImage(CHECK_POPUP_CHOOSE_LIST, 82, 0, 0, 750, 1334)
 local colorOk = false
 local colorX, colorY = -1, -1
 if not ok then
  colorOk, colorX, colorY = findNewPopupByColor()
  if not colorOk then return false end
 end
 phase("Popup choose")
 if colorOk then
  status("Popup choose fallback color tap " .. tostring(colorX) .. "," .. tostring(colorY))
  touch.tap(colorX, colorY)
  waitPhase(500)
  return true
 end
 -- Ưu tiên điểm màu thay thế nếu nó xuất hiện ngay cả khi ảnh choose cũng match.
 if handleNewPopupByColor() then return true end
 local points = {{185,513},{119,645},{138,761},{163,879},{157,993},{178,1093},{540,1243}}
 for i = 1, #points do
  touch.tap(points[i][1], points[i][2])
  waitPhase(250)
  if handleNewPopupByColor() then return true end
 end
 return true
end

function handlePopupSwipe()
 local ok = findImage(CHECK_POPUP_SWIPE, 82, 0, 0, 750, 1334)
 if not ok then return false end
 phase("Popup swipe")
 waitPhase(7000)
 swipeUpOnce()
 waitPhase(1000)
 return true
end

function tapXuliteIfVisibleOnce()
 local x, y = screen.find_image(XULITE_IMG, 82, 0, 0, 750, 1334)
 if x == -1 then return false end
 local cx, cy = getImageCenter(XULITE_IMG, x, y)
 status("Tap Xulite " .. tostring(cx) .. "," .. tostring(cy))
 touch.tap(cx, cy)
 return true
end

function hasXuliteTappedScreen()
 local x, y = screen.find_color(XULITE_TAPPED_SCREEN_PATTERN, 95, 0, 0, 0, 0)
 if x ~= -1 then
  status("Xulite tapped screen hit " .. tostring(x) .. "," .. tostring(y))
  return true
 end
 return false
end

function waitXuliteTappedScreenQuick(maxMs)
 local remain = maxMs or 1500
 while remain > 0 do
  if hasXuliteTappedScreen() then return true end
  local step = 150
  if remain < step then step = remain end
  sleep(step)
  remain = remain - step
 end
 return false
end

function waitFinalColorStable(stableSec, timeoutSec)
 local stableStart = nil
 local start = os.time()
 while os.time() - start < timeoutSec do
  local x, y = screen.find_color(FINAL_COLOR_PATTERN, 95, 0, 0, 0, 0)
  if x ~= -1 then
   if not stableStart then stableStart = os.time() end
   status("Final color stable " .. tostring(os.time() - stableStart) .. "/" .. tostring(stableSec) .. "s")
   if os.time() - stableStart >= stableSec then return true end
  else
   stableStart = nil
  end
  sleep(500)
 end
 return false
end

function swipeRightOnce()
 status("Swipe right")
 oc_swipe(120, 680, 650, 680, 300)
end

function tryTapXuliteLight(timeoutSec)
 local start = os.time()
 local everSeenXulite = false
 local everTappedXulite = false
 while os.time() - start < timeoutSec do
  local x, y = screen.find_image(XULITE_IMG, 82, 0, 0, 750, 1334)
  if x ~= -1 then
   everSeenXulite = true
   local cx, cy = getImageCenter(XULITE_IMG, x, y)
   status("Tap Xulite " .. tostring(cx) .. "," .. tostring(cy))
   touch.tap(cx, cy)
   everTappedXulite = true
   if waitXuliteTappedScreenQuick(1500) then return true, "tapped_screen" end
  end
  sleep(500)
 end
 if everTappedXulite then return false, "tapped_but_no_confirm" end
 if everSeenXulite then return false, "seen_not_tapped" end
 return false, "not_seen"
end

function runAfterXuliteTappedFlow()
 if waitFinalColorStable(5, 120) then
  swipeRightOnce()
  waitPhase(5000)
  for i = 1, 3 do
   swipeUpOnce()
   if i < 3 then waitPhase(5000) end
  end
  local tappedAgain = tryTapXuliteLight(30)
  if tappedAgain then
   waitFinalColorStable(10, 120)
  end
 end
 phase("Stage 2 xong")
 return true
end

function waitXuliteOrRestartStage1(timeoutSec)
 local start = os.time()
 while os.time() - start < timeoutSec do
  local tappedXulite, xuliteState = tryTapXuliteLight(5)
  if tappedXulite and xuliteState == "tapped_screen" then return true, xuliteState end
  swipeUpOnce()
  handleStage2PopupOnce()
 end
 status("Không thấy Xulite trong thời gian chờ, quay lại Stage 1")
 return false, "not_seen"
end

function finishByEventPopup()
 if not hasEventPopup() then return false end
 phase("Popup Event")
 touch.tap(644, 182)
 waitPhase(1200)
 local start = os.time()
 while os.time() - start < 15 do
  if not hasEventPopup() then break end
  touch.tap(644, 182)
  waitPhase(1000)
 end
 if hasEventPopup() then return false end
 waitPhase(5000)
 local tappedXulite, xuliteState = waitXuliteOrRestartStage1(120)
 if tappedXulite and xuliteState == "tapped_screen" then
  return runAfterXuliteTappedFlow()
 end
 return "restart_stage1"
end

function handleStage2PopupOnce()
 if handleNoInternetSpecial() then return true end
 if handlePopupByImage("Popup welcome", CHECK_POPUP_WELLCOME, TAP_POPUP_WELLCOME) then return true end
 if handlePopupPermiss() then return true end
 if handlePopupByImage("Popup allow", CHECK_POPUP_ALLOW, TAP_POPUP_ALLOW) then return true end
 if handlePopupByImage("Popup tapping", CHECK_POPUP_TAPPING, TAP_POPUP_TAPPING) then return true end
 if handlePopupTrack() then return true end
 if handleNewPopupByColor() then return true end
 if handlePopupChoose() then return true end
 if handlePopupSwipe() then return true end
 return false
end

function handleNoInternetSpecial()
 local ok = findImage(CHECK_POPUP_INTERNET, 82, 0, 0, 750, 1334)
 if not ok then return false end
 phase("No internet")
 while findImage(CHECK_POPUP_INTERNET, 82, 0, 0, 750, 1334) do
  touch.tap(744, 182)
  waitPhase(10000)
 end
 phase("Đợi internet quay lại")
 local startClear = os.time()
 while os.time() - startClear < 30 do
  if findImage(CHECK_POPUP_INTERNET, 82, 0, 0, 750, 1334) then startClear = os.time() end
  waitPhase(1000)
 end
 app.quit(TIKTOK_LITE_BUNDLE)
 waitPhase(2000)
 while true do
  ensureTikTokLiteForeground()
  if handlePopupByImage("Popup welcome", CHECK_POPUP_WELLCOME, TAP_POPUP_WELLCOME) then goto continue_loop end
  if handlePopupPermiss() then goto continue_loop end
  if handlePopupByImage("Popup allow", CHECK_POPUP_ALLOW, TAP_POPUP_ALLOW) then goto continue_loop end
  if handlePopupByImage("Popup tapping", CHECK_POPUP_TAPPING, TAP_POPUP_TAPPING) then goto continue_loop end
  if handlePopupTrack() then goto continue_loop end
  if handleNewPopupByColor() then goto continue_loop end
  if handlePopupChoose() then goto continue_loop end
  if handlePopupSwipe() then goto continue_loop end
  if finishByEventPopup() then return true end
  waitPhase(1000)
  ::continue_loop::
 end
end

local TIKTOK_LITE_EVENT_URL = TIKTOK_LITE_EVENT_URL or "snssdk473824://webview?url=https%3A%2F%2Finapp.tiktokv.com%2Ffalcon%2Fincentive_campaign%2Fgold_coin.html"
local stage2_last_open_at = 0
local stage2_open_link_count = 0
local stage2_restart_stage1 = false

local function stage2_sleep(ms)
 sys.msleep(ms)
end

local function stage2_esc(s)
 s = tostring(s or "")
 s = s:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"):gsub('"',"&quot;")
 return s
end

local function stage2_status(msg, color)
 color = color or "rgba(0,0,0,.80)"
 local html = [[
<html><head><meta name="viewport" content="width=device-width,initial-scale=1">
<style>
html,body{margin:0;padding:0;background:transparent;overflow:hidden;font-family:-apple-system,Arial}
#b{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:]] .. color .. [[;color:#fff;border-radius:12px;font-size:15px;font-weight:800;text-align:center;box-sizing:border-box;padding:0 8px;white-space:normal}
</style></head><body><div id="b">Nuôi Phôi TTL đang tiến hành ....</div></body></html>
]]
 pcall(function()
  if __ok_webview_status and __webview_status and type(__webview_status.show) == "function" then
   __webview_status.show{ id=88, html=html, x=1, y=1, width=748, height=70, alpha=1.0, corner_radius=12, opaque=false, can_drag=false, ignores_hit=true, level=999999, animation_duration=0 }
  else
   local ok,wv=pcall(require,"webview")
   if ok and wv and type(wv.show)=="function" then
    wv.show{ id=88, html=html, x=1, y=1, width=748, height=70, alpha=1.0, corner_radius=12, opaque=false, can_drag=false, ignores_hit=true, level=999999, animation_duration=0 }
   end
  end
 end)
 pcall(function() if type(__oc_write_status)=="function" then __oc_write_status(tostring(msg or "")) end end)
end

local stage2_ocr_tap_open_popup_until_front

local function stage2_reopen_event(reason)
 stage2_open_link_count = (stage2_open_link_count or 0) + 1
 if stage2_open_link_count > 20 then
  stage2_status("STAGE2: mở link >20 lần -> quay lại Stage 1", "rgba(190,0,0,.92)")
  stage2_restart_stage1 = true
  return "restart_stage1"
 end
 stage2_status("REOPEN " .. tostring(stage2_open_link_count) .. "/20: " .. tostring(reason) .. " -> quit + mở link sự kiện", "rgba(170,90,0,.92)")
 pcall(function() app.quit(TIKTOK_LITE_BUNDLE) end)
 stage2_sleep(2000)
 stage2_last_open_at = os.time()
 pcall(function() app.open_url(TIKTOK_LITE_EVENT_URL) end)
 stage2_sleep(8000)
 return "reopen_stage2"
end

local function stage2_ttl_loading_black()
 return screen.is_colors({
  {93,29,0x000000},
  {132,27,0x000000},
  {186,29,0x000000},
  {461,22,0x000000},
  {628,142,0x000000},
  {622,405,0x000000},
 }, 90)
end

local function stage2_wait_ttl_ready_before_event(reason)
 stage2_status("STAGE2 INIT: run TTL, chờ hết nền đen " .. tostring(reason or ""))
 pcall(function() app.run(TIKTOK_LITE_BUNDLE) end)
 stage2_sleep(1000)
 while true do
  local front = ""
  pcall(function() front = tostring(app.front_bid() or "") end)
  if front ~= TIKTOK_LITE_BUNDLE then
   stage2_status("STAGE2 INIT: TTL văng/Home -> app.run lại, chưa mở event", "rgba(170,90,0,.92)")
   pcall(function() app.run(TIKTOK_LITE_BUNDLE) end)
   stage2_sleep(3000)
  elseif stage2_ttl_loading_black() then
   stage2_status("STAGE2 INIT: TTL còn nền đen loading, chờ")
   stage2_sleep(1000)
  else
   stage2_status("STAGE2 INIT: TTL đã qua loading -> quit rồi mở event", "rgba(0,140,40,.90)")
   return true
  end
 end
end

local function stage2_open_event_from_app(reason)
 stage2_open_link_count = (stage2_open_link_count or 0) + 1
 if stage2_open_link_count > 20 then
  stage2_status("STAGE2: mở link >20 lần -> quay lại Stage 1", "rgba(190,0,0,.92)")
  stage2_restart_stage1 = true
  return "restart_stage1"
 end
 stage2_wait_ttl_ready_before_event(reason)
 pcall(function() app.quit(TIKTOK_LITE_BUNDLE) end)
 stage2_sleep(2000)
 stage2_last_open_at = os.time()
 pcall(function() app.open_url(TIKTOK_LITE_EVENT_URL) end)
 stage2_ocr_tap_open_popup_until_front(25)
 stage2_sleep(8000)
 return "reopen_stage2"
end

local function stage2_ensure_front()
 local front = ""
 pcall(function() front = tostring(app.front_bid() or "") end)
 if front ~= TIKTOK_LITE_BUNDLE then
  local since_open = os.time() - (stage2_last_open_at or 0)
  if since_open >= 0 and since_open < 25 then
   stage2_status("STAGE2: đang chờ TikTok Lite vào app " .. tostring(since_open) .. "/25s")
   stage2_sleep(500)
   return false
  end
  if stage2_reopen_event("front=" .. front) == "restart_stage1" then return "restart_stage1" end
  return false
 end
 return true
end

local function stage2_norm(s)
 s = tostring(s or ""):lower()
 s = s:gsub("[\r\n]+"," ")
 s = s:gsub("%s+"," ")
 return s
end

local function stage2_match_agree(s)
 s = stage2_norm(s)
 local a = s:find("agree",1,true)
 local c = s:find("continue",1,true) or s:find("countinue",1,true) or s:find("countinuie",1,true) or s:find("contlnue",1,true) or s:find("contin",1,true)
 return a and c
end

local function stage2_item_text(v)
 if type(v) ~= "table" then return tostring(v or "") end
 return tostring(v.text or v.word or v.label or v.value or v.content or v[1] or "")
end

local function stage2_item_box(v)
 if type(v) ~= "table" then return nil end
 local x = tonumber(v.x or v.left or v[2])
 local y = tonumber(v.y or v.top or v[3])
 local w = tonumber(v.width or v.w)
 local h = tonumber(v.height or v.h)
 local r = tonumber(v.right)
 local b = tonumber(v.bottom)
 if x and y and w and h then return x,y,x+w,y+h end
 if x and y and r and b then return x,y,r,b end
 if type(v.bounds) == "table" then
  local bb = v.bounds
  local bx = tonumber(bb.x or bb.left or bb[1])
  local by = tonumber(bb.y or bb.top or bb[2])
  local bw = tonumber(bb.width or bb.w or bb[3])
  local bh = tonumber(bb.height or bb.h or bb[4])
  if bx and by and bw and bh then return bx,by,bx+bw,by+bh end
 end
 return nil
end

local function stage2_match_open_tiktok_lite(s)
 s = stage2_norm(s)
 if s == "" then return false end
 if s:find("open",1,true) then return true end
 if s:find("mo",1,true) or s:find("mở",1,true) then return true end
 if s:find("tiktok lite",1,true) and (s:find("open",1,true) or s:find("mo",1,true) or s:find("mở",1,true)) then return true end
 if s:find("開く",1,true) or s:find("開け",1,true) then return true end
 return false
end

function stage2_ocr_tap_open_popup_until_front(maxSeconds)
 maxSeconds = maxSeconds or 25
 local start = os.time()
 while os.time() - start < maxSeconds do
  local front = ""
  pcall(function() front = tostring(app.front_bid() or "") end)
  if front == TIKTOK_LITE_BUNDLE then
   stage2_status("OPEN LINK OCR: TikTok Lite đã foreground -> dừng OCR", "rgba(0,120,40,.90)")
   return true
  end

  local calls = {
   function() return screen.ocr_text(0,0,750,1334) end,
   function() return screen.ocr_text{ x=0,y=0,width=750,height=1334 } end,
  }
  for _,fn in ipairs(calls) do
   local ok,res = pcall(fn)
   if ok and res then
    if type(res) == "table" then
     local all = {}
     for _,v in pairs(res) do
      local t = stage2_item_text(v)
      if t ~= "" then all[#all+1] = t end
      if stage2_match_open_tiktok_lite(t) then
       local x1,y1,x2,y2 = stage2_item_box(v)
       if x1 and y1 and x2 and y2 then
        local x = math.floor((x1+x2)/2)
        local y = math.floor((y1+y2)/2)
        stage2_status("OPEN LINK OCR: tap Open bbox " .. x .. "," .. y .. " -> dừng OCR", "rgba(0,140,40,.90)")
        touch.tap(x,y)
        stage2_sleep(700)
        return true
       end
      end
     end
     local joined = table.concat(all, " ")
     if stage2_match_open_tiktok_lite(joined) then
      stage2_status("OPEN LINK OCR: thấy Open -> tap fallback 571,773 -> dừng OCR", "rgba(0,140,40,.90)")
      touch.tap(571,773)
      stage2_sleep(700)
      return true
     end
    else
     local txt = tostring(res or "")
     if stage2_match_open_tiktok_lite(txt) then
      stage2_status("OPEN LINK OCR text: Open -> tap fallback 571,773 -> dừng OCR", "rgba(0,140,40,.90)")
      touch.tap(571,773)
      stage2_sleep(700)
      return true
     end
    end
   end
  end
  stage2_status("OPEN LINK OCR: đang quét popup Open")
  stage2_sleep(300)
 end
 return false
end

local function stage2_popup1_agree_ocr()
 local RX1,RY1,RX2,RY2 = 180,735,570,835
 local step_start = os.time()
 while true do
  if os.time() - step_start >= 60 then stage2_reopen_event("popup1 >60s"); return "reopen_stage2" end
  stage2_ensure_front()
  local calls = {
   function() return screen.ocr_text(RX1,RY1,RX2,RY2) end,
   function() return screen.ocr_text{ x=RX1,y=RY1,width=RX2-RX1,height=RY2-RY1 } end,
  }
  for _,fn in ipairs(calls) do
   local ok,res = pcall(fn)
   if ok and res then
    if type(res) == "table" then
     local all = {}
     for _,v in pairs(res) do local t=stage2_item_text(v); if t~="" then all[#all+1]=t end end
     local joined = table.concat(all," ")
     stage2_status("POPUP1 OCR: " .. joined)
     if stage2_match_agree(joined) then
      for _,v in pairs(res) do
       local t=stage2_item_text(v); local nt=stage2_norm(t)
       if nt:find("agree",1,true) or nt:find("contin",1,true) then
        local x1,y1,x2,y2=stage2_item_box(v)
        if x1 and y1 and x2 and y2 then
         local x=math.floor((x1+x2)/2); local y=math.floor((y1+y2)/2)
         stage2_status("POPUP1 OK: tap OCR bbox "..x..","..y, "rgba(0,140,40,.90)")
         touch.tap(x,y); stage2_sleep(250); return true
        end
       end
      end
      stage2_status("POPUP1 OK: thấy chữ -> tap 375,795", "rgba(0,140,40,.90)")
      touch.tap(375,795); stage2_sleep(250); return true
     end
    else
     local txt=tostring(res or "")
     stage2_status("POPUP1 OCR text: " .. txt)
     if stage2_match_agree(txt) then touch.tap(375,795); stage2_sleep(250); return true end
    end
   end
  end
  stage2_sleep(200)
 end
end

local function stage2_popup2_color()
 local step_start = os.time()
 while true do
  if os.time() - step_start >= 60 then stage2_reopen_event("popup2 >60s"); return "reopen_stage2" end
  stage2_ensure_front()
  if screen.is_colors({
   {157,791,0x007AFF},{157,793,0x007AFF},{157,796,0x007AFF},{157,798,0x007AFF},{157,802,0x007AFF},{157,805,0x007AFF},{157,809,0x007AFF},{157,811,0x007AFF},{160,812,0x007AFF},{165,812,0x007AFF},{169,811,0x007AFF},{172,807,0x007AFF},{173,803,0x007AFF},{173,798,0x007AFF},{172,795,0x007AFF},{170,793,0x007AFF},{167,791,0x007AFF},{162,790,0x0B7EFE},{160,791,0x007AFF},{180,802,0x007AFF},{180,804,0x007AFF},{181,809,0x007AFF},{185,812,0x007AFF},{188,812,0x007AFF},{193,807,0x007AFF},{193,802,0x007AFF},{188,797,0x007AFF},{199,797,0x007AFF},{200,800,0x007AFF},{200,805,0x007AFF},{199,810,0x007AFF},{203,798,0x047BFE},{206,797,0x007AFF},{210,798,0x007AFF},{212,804,0x007AFF},{211,811,0x007AFF},{219,798,0x017AFF},{219,794,0x007AFF},{220,790,0x0B7EFE},{229,792,0x007AFF},{229,796,0x007AFF},{229,799,0x007AFF},{228,805,0x007AFF},{232,812,0x007AFF},{247,812,0x007AFF},{250,805,0x007AFF},{255,805,0x007AFF},{259,806,0x007AFF},{255,791,0x007AFF},{263,812,0x007AFF},{270,790,0x007AFF},{271,795,0x007AFF},{270,802,0x007AFF},{270,806,0x007AFF},{271,810,0x007AFF},{278,791,0x007AFF},{277,795,0x007AFF},{278,812,0x007AFF},{285,805,0x007AFF},{289,812,0x007AFF},{297,810,0x007AFF},{299,805,0x007AFF},{293,796,0x007AFF},{304,797,0x007AFF},{308,812,0x007AFF},{313,797,0x007AFF},{319,812,0x007AFF},{324,797,0x007AFF},
  },90) then
   stage2_status("POPUP2 OK -> tap 240,802", "rgba(0,140,40,.90)")
   touch.tap(240,802); stage2_sleep(250); return true
  end
  stage2_status("POPUP2: chưa thấy, chờ tiếp"); stage2_sleep(150)
 end
end

local function stage2_popup3_color()
 local step_start = os.time()
 while true do
  if os.time() - step_start >= 60 then stage2_reopen_event("popup3 >60s"); return "reopen_stage2" end
  stage2_ensure_front()
  if screen.is_colors({
   {224,775,0x007AFF},{223,778,0x007AFF},{221,782,0x007AFF},{220,785,0x007AFF},{219,789,0x007AFF},{216,794,0x1481FC},{222,789,0x007AFF},{225,789,0x007AFF},{227,789,0x007AFF},{229,788,0x007AFF},{230,785,0x007AFF},{230,789,0x007AFF},{233,794,0x007AFF},{233,795,0x007AFF},{225,774,0x007AFF},{240,783,0x007AFF},{245,779,0x007AFF},{249,782,0x007AFF},{244,787,0x007AFF},{248,788,0x007AFF},{250,791,0x007AFF},{248,794,0x007AFF},{244,796,0x007AFF},{239,793,0x007AFF},{255,773,0x007AFF},{255,776,0x007AFF},{255,780,0x007AFF},{255,782,0x007AFF},{255,786,0x007AFF},{255,791,0x007AFF},{255,794,0x007AFF},{256,788,0x007AFF},{259,787,0x007AFF},{266,779,0x1983FB},{261,789,0x007AFF},{264,792,0x007AFF},{285,789,0x007AFF},{288,789,0x007AFF},{291,789,0x007AFF},{293,789,0x007AFF},{286,783,0x007AFF},{289,775,0x007AFF},{298,795,0x007AFF},{282,795,0x007AFF},{305,782,0x007AFF},{305,784,0x007AFF},{304,786,0x007AFF},{305,789,0x007AFF},{304,792,0x007AFF},{305,796,0x007AFF},{304,801,0x007AFF},{325,802,0x067CFE},{325,798,0x007AFF},{324,793,0x007AFF},{325,785,0x007AFF},{338,787,0x007AFF},{317,789,0x007AFF},{353,795,0x007AFF},{353,786,0x007AFF},{353,778,0x007AFF},{364,790,0x017AFF},{368,794,0x007AFF},{369,787,0x007AFF},{370,779,0x007AFF},{369,774,0x007AFF},{418,780,0x007AFF},{418,785,0x007AFF},{418,790,0x007AFF},{434,795,0x007AFF},{440,789,0x007AFF},{427,789,0x007AFF},{433,780,0x007AFF},{461,773,0x0A7EFD},{469,773,0x0A7EFD},{462,783,0x007AFF},{462,794,0x007AFF},{523,787,0x007AFF},{526,787,0x007AFF},{533,780,0x007AFF},{534,795,0x007AFF},{509,795,0x007AFF},{509,780,0x007AFF},
  },90) then
   stage2_status("POPUP3 OK -> tap 365,787", "rgba(0,140,40,.90)")
   touch.tap(365,787); stage2_sleep(250); return true
  end
  stage2_status("POPUP3: chưa thấy, chờ tiếp"); stage2_sleep(150)
 end
end

local function stage2_popup4_color()
 local step_start = os.time()
 while true do
  if os.time() - step_start >= 60 then stage2_reopen_event("popup4 >60s"); return "reopen_stage2" end
  stage2_ensure_front()
  if screen.is_colors({
   {317,753,0xFE2C55},{314,738,0xFE2C55},{319,729,0xFE2C55},{338,728,0xFE2C55},{323,738,0xFFFFFF},{323,750,0xFFFFFF},{332,753,0xFFFFFF},{341,752,0xFFFFFF},{341,740,0xFFFFFF},{333,737,0xFFFFFF},{356,738,0xFFFFFF},{364,738,0xFFFFFF},{367,741,0xFFFFFF},{361,749,0xFFFFFF},{386,743,0xFFFFFF},{390,748,0xFFFFFF},{398,747,0xFE2C55},{419,727,0xFE2C55},{433,746,0xFE2C55},{419,753,0xFE2C55},{416,744,0xFE2C55},{384,734,0xFE2C55},{373,733,0xFE5B7B},{366,748,0xFE345C},
  },90) then
   stage2_status("POPUP4 OK -> tap 372,920", "rgba(0,140,40,.90)")
   touch.tap(372,920); stage2_sleep(250); return true
  end
  stage2_status("POPUP4: chưa thấy, chờ tiếp"); stage2_sleep(150)
 end
end


local function stage2_try_popup1_agree_once()
 local RX1,RY1,RX2,RY2 = 180,735,570,835
 local calls = {
  function() return screen.ocr_text(RX1,RY1,RX2,RY2) end,
  function() return screen.ocr_text{ x=RX1,y=RY1,width=RX2-RX1,height=RY2-RY1 } end,
 }
 for _,fn in ipairs(calls) do
  local ok,res = pcall(fn)
  if ok and res then
   if type(res) == "table" then
    local all = {}
    for _,v in pairs(res) do local t=stage2_item_text(v); if t~="" then all[#all+1]=t end end
    local joined = table.concat(all," ")
    if stage2_match_agree(joined) then
     for _,v in pairs(res) do
      local t=stage2_item_text(v); local nt=stage2_norm(t)
      if nt:find("agree",1,true) or nt:find("contin",1,true) then
       local x1,y1,x2,y2=stage2_item_box(v)
       if x1 and y1 and x2 and y2 then
        local x=math.floor((x1+x2)/2); local y=math.floor((y1+y2)/2)
        stage2_status("POPUP1 OK: tap OCR bbox "..x..","..y, "rgba(0,140,40,.90)")
        touch.tap(x,y); stage2_sleep(250); return true
       end
      end
     end
     stage2_status("POPUP1 OK: thấy chữ -> tap 375,795", "rgba(0,140,40,.90)")
     touch.tap(375,795); stage2_sleep(250); return true
    end
   else
    local tx=tostring(res or "")
    if stage2_match_agree(tx) then
     stage2_status("POPUP1 OK: text-only -> tap 375,795", "rgba(0,140,40,.90)")
     touch.tap(375,795); stage2_sleep(250); return true
    end
   end
  end
 end
 return false
end

local function stage2_try_popup2_once()
 if screen.is_colors({
   {157,791,0x007AFF},{157,793,0x007AFF},{157,796,0x007AFF},{157,798,0x007AFF},{157,802,0x007AFF},{157,805,0x007AFF},{157,809,0x007AFF},{157,811,0x007AFF},{160,812,0x007AFF},{165,812,0x007AFF},{169,811,0x007AFF},{172,807,0x007AFF},{173,803,0x007AFF},{173,798,0x007AFF},{172,795,0x007AFF},{170,793,0x007AFF},{167,791,0x007AFF},{162,790,0x0B7EFE},{160,791,0x007AFF},{180,802,0x007AFF},{180,804,0x007AFF},{181,809,0x007AFF},{185,812,0x007AFF},{188,812,0x007AFF},{193,807,0x007AFF},{193,802,0x007AFF},{188,797,0x007AFF},{199,797,0x007AFF},{200,800,0x007AFF},{200,805,0x007AFF},{199,810,0x007AFF},{203,798,0x047BFE},{206,797,0x007AFF},{210,798,0x007AFF},{212,804,0x007AFF},{211,811,0x007AFF},{219,798,0x017AFF},{219,794,0x007AFF},{220,790,0x0B7EFE},{229,792,0x007AFF},{229,796,0x007AFF},{229,799,0x007AFF},{228,805,0x007AFF},{232,812,0x007AFF},{247,812,0x007AFF},{250,805,0x007AFF},{255,805,0x007AFF},{259,806,0x007AFF},{255,791,0x007AFF},{263,812,0x007AFF},{270,790,0x007AFF},{271,795,0x007AFF},{270,802,0x007AFF},{270,806,0x007AFF},{271,810,0x007AFF},{278,791,0x007AFF},{277,795,0x007AFF},{278,812,0x007AFF},{285,805,0x007AFF},{289,812,0x007AFF},{297,810,0x007AFF},{299,805,0x007AFF},{293,796,0x007AFF},{304,797,0x007AFF},{308,812,0x007AFF},{313,797,0x007AFF},{319,812,0x007AFF},{324,797,0x007AFF},
 },90) then
  stage2_status("POPUP2 OK -> tap 240,802", "rgba(0,140,40,.90)")
  touch.tap(240,802); stage2_sleep(250); return true
 end
 return false
end

local function stage2_try_popup23_once()
 if screen.is_colors({
  {157,812,0x007AFF},
  {157,817,0x007AFF},
  {157,821,0x007AFF},
  {157,832,0x007AFF},
  {169,831,0x007AFF},
  {173,818,0x007AFF},
  {179,824,0x007AFF},
  {193,825,0x007AFF},
  {220,812,0x007AFF},
  {298,825,0x007AFF},
  {308,832,0x007AFF},
  {320,832,0x007AFF},
  {255,812,0x007AFF},
 },90) then
  stage2_status("POPUP2.3 OK -> tap 240,802", "rgba(0,140,40,.90)")
  touch.tap(240,802); stage2_sleep(250); return true
 end
 return false
end

local function stage2_try_popup32_once()
 if screen.is_colors({
  {231,789,0x007AFF},
  {217,793,0x007AFF},
  {290,774,0x007AFF},
  {401,780,0x007AFF},
  {418,780,0x007AFF},
  {463,774,0x007AFF},
  {524,787,0x007AFF},
 },90) then
  stage2_status("POPUP3.2 OK -> tap 240,802", "rgba(0,140,40,.90)")
  touch.tap(240,802); stage2_sleep(250); return true
 end
 return false
end

local function stage2_try_popup3_once()
 if screen.is_colors({
   {224,775,0x007AFF},{223,778,0x007AFF},{221,782,0x007AFF},{220,785,0x007AFF},{219,789,0x007AFF},{216,794,0x1481FC},{222,789,0x007AFF},{225,789,0x007AFF},{227,789,0x007AFF},{229,788,0x007AFF},{230,785,0x007AFF},{230,789,0x007AFF},{233,794,0x007AFF},{233,795,0x007AFF},{225,774,0x007AFF},{240,783,0x007AFF},{245,779,0x007AFF},{249,782,0x007AFF},{244,787,0x007AFF},{248,788,0x007AFF},{250,791,0x007AFF},{248,794,0x007AFF},{244,796,0x007AFF},{239,793,0x007AFF},{255,773,0x007AFF},{255,776,0x007AFF},{255,780,0x007AFF},{255,782,0x007AFF},{255,786,0x007AFF},{255,791,0x007AFF},{255,794,0x007AFF},{256,788,0x007AFF},{259,787,0x007AFF},{266,779,0x1983FB},{261,789,0x007AFF},{264,792,0x007AFF},{285,789,0x007AFF},{288,789,0x007AFF},{291,789,0x007AFF},{293,789,0x007AFF},{286,783,0x007AFF},{289,775,0x007AFF},{298,795,0x007AFF},{282,795,0x007AFF},{305,782,0x007AFF},{305,784,0x007AFF},{304,786,0x007AFF},{305,789,0x007AFF},{304,792,0x007AFF},{305,796,0x007AFF},{304,801,0x007AFF},{325,802,0x067CFE},{325,798,0x007AFF},{324,793,0x007AFF},{325,785,0x007AFF},{338,787,0x007AFF},{317,789,0x007AFF},{353,795,0x007AFF},{353,786,0x007AFF},{353,778,0x007AFF},{364,790,0x017AFF},{368,794,0x007AFF},{369,787,0x007AFF},{370,779,0x007AFF},{369,774,0x007AFF},{418,780,0x007AFF},{418,785,0x007AFF},{418,790,0x007AFF},{434,795,0x007AFF},{440,789,0x007AFF},{427,789,0x007AFF},{433,780,0x007AFF},{461,773,0x0A7EFD},{469,773,0x0A7EFD},{462,783,0x007AFF},{462,794,0x007AFF},{523,787,0x007AFF},{526,787,0x007AFF},{533,780,0x007AFF},{534,795,0x007AFF},{509,795,0x007AFF},{509,780,0x007AFF},
 },90) then
  stage2_status("POPUP3 OK -> tap 365,787", "rgba(0,140,40,.90)")
  touch.tap(365,787); stage2_sleep(250); return true
 end
 return false
end


local function stage2_has_reopen_popup()
 if findAnyImage(CHECK_POPUP_CHOOSE_LIST, 82, 0, 0, 750, 1334) then return true, "check_popup_choose" end
 if findImage(POPUP_1_CHECK1, 82, 0, 0, 750, 1334) then return true, "Popup_1_check1" end
 if findImage(POPUP_1_TAP, 82, 0, 0, 750, 1334) then return true, "Popup_1_tap" end
 return false, ""
end

local function stage2_reopen_if_special_popup()
 local ok, name = stage2_has_reopen_popup()
 if ok then
  if stage2_reopen_event("special popup " .. tostring(name)) == "restart_stage1" then return "restart_stage1" end
  return true
 end
 return false
end

local function stage2_handle_captcha_once()
 if not findImage(CAPTCHA_IMG, 82, 0, 0, 750, 1334) then return false end
 stage2_status("STAGE2: Popup capcha -> tap 643,401", "rgba(120,70,0,.90)")
 stage2_sleep(1000)
 touch.tap(643,401)
 stage2_sleep(500)
 return true
end

local function stage2_try_popup4_once()
 if screen.is_colors({
   {317,753,0xFE2C55},{314,738,0xFE2C55},{319,729,0xFE2C55},{338,728,0xFE2C55},{323,738,0xFFFFFF},{323,750,0xFFFFFF},{332,753,0xFFFFFF},{341,752,0xFFFFFF},{341,740,0xFFFFFF},{333,737,0xFFFFFF},{356,738,0xFFFFFF},{364,738,0xFFFFFF},{367,741,0xFFFFFF},{361,749,0xFFFFFF},{386,743,0xFFFFFF},{390,748,0xFFFFFF},{398,747,0xFE2C55},{419,727,0xFE2C55},{433,746,0xFE2C55},{419,753,0xFE2C55},{416,744,0xFE2C55},{384,734,0xFE2C55},{373,733,0xFE5B7B},{366,748,0xFE345C},
 },90) then
  stage2_status("POPUP4 OK -> tap 372,920", "rgba(0,140,40,.90)")
  touch.tap(372,920); stage2_sleep(250); return true
 end
 return false
end

local function stage2_handle_popups_123_any_order()
 local done1,done2,done3 = false,false,false
 local step_start = os.time()
 while not (done1 and done2 and done3) do
  stage2_ensure_front()
  if os.time() - step_start >= 60 then
   if stage2_reopen_event("popup1/2/3 no progress >60s") == "restart_stage1" then return "restart_stage1" end
   return "reopen_stage2"
  end
  local progressed = false
  if stage2_reopen_if_special_popup() then return "reopen_stage2" end
  -- Popup4 can appear alone after prior reopen(s). If seen, handle it immediately;
  -- popup1/2/3 are not mandatory once popup4 is reached.
  if stage2_try_popup4_once() then return "popup4_done" end
  if stage2_handle_captcha_once() then progressed=true end
  if not done2 and stage2_try_popup2_once() then done2=true; progressed=true end
  if not done2 and stage2_try_popup23_once() then done2=true; progressed=true end
  if not done3 and stage2_try_popup3_once() then done3=true; progressed=true end
  if not done3 and stage2_try_popup32_once() then done3=true; progressed=true end
  if not done1 and stage2_try_popup1_agree_once() then done1=true; progressed=true end
  if progressed then
   step_start = os.time()
   stage2_status("POPUP123: done1="..tostring(done1).." done2="..tostring(done2).." done3="..tostring(done3), "rgba(0,140,40,.90)")
  else
   stage2_status("POPUP123: chờ popup bất kỳ 1/2/3")
   stage2_sleep(150)
  end
 end
 return true
end


local function stage2_white_pattern()
 return screen.is_colors({
  {142,285,0xffffff},{270,295,0xffffff},{436,295,0xffffff},{570,305,0xffffff},{598,517,0xffffff},{596,841,0xffffff},{182,597,0xffffff},{344,517,0xffffff},{586,809,0xffffff},{454,535,0xffffff},{374,283,0xffffff},{636,211,0xffffff},{454,1053,0xffffff},{324,1053,0xffffff},{228,1025,0xffffff},
 },90)
end

local function stage2_post_popup4_watch()
 local white_since = nil
 while true do
  stage2_ensure_front()
  if stage2_white_pattern() then
   if white_since == nil then white_since=os.time(); stage2_status("SAU POPUP4: thấy màn trắng, đếm 45s") end
   local sec=os.time()-white_since
   if sec >= 45 then
    stage2_status("SAU POPUP4: trắng >=45s -> mở lại link", "rgba(170,90,0,.92)")
    if stage2_reopen_event("white >=45s after popup4") == "restart_stage1" then return "restart_stage1" end
    return "reopen_stage2"
   end
   stage2_status("SAU POPUP4: trắng "..tostring(sec).."/45s")
   stage2_sleep(150)
  else
   stage2_status("SAU POPUP4: hết trắng/có nội dung khác -> Stage2 DONE", "rgba(0,140,40,.90)")
   -- Done thì giữ TikTok Lite mở, không quit app.
   stage2_sleep(1500)
   return true
  end
 end
end

function runStage2()
 stage2_open_link_count = 0
 stage2_restart_stage1 = false
 if stage2_open_event_from_app("start") == "restart_stage1" then return "restart_stage1" end

 local last_progress_at = os.time()
 local last_step_name = "start"
 local last_step_at = os.time()
 local function stage2_mark_step(name)
  name = tostring(name or "unknown")
  local now = os.time()
  if name ~= last_step_name then
   last_step_name = name
   last_step_at = now
  elseif now - last_step_at >= 60 then
   if stage2_reopen_event("Stage2 kẹt tại " .. name .. " >60s") == "restart_stage1" then return "restart_stage1" end
   last_step_name = "reopen"
   last_step_at = os.time()
   last_progress_at = os.time()
   return "reopen_stage2"
  end
  last_progress_at = now
  return true
 end

 while true do
  stage2_ensure_front()
  if stage2_restart_stage1 then return "restart_stage1" end
  if stage2_reopen_if_special_popup() then
   stage2_mark_step("special_popup_reopen")
  end

  -- Event-driven: không ép thứ tự, không ép phải đủ popup 1/2/3.
  -- Popup nào thật sự xuất hiện thì xử lý ngay.
  if stage2_handle_captcha_once() then
   stage2_mark_step("captcha")
  elseif stage2_try_popup4_once() then
   local mark = stage2_mark_step("popup4")
   if mark ~= "reopen_stage2" then
    local r = stage2_post_popup4_watch()
    if r == true then return true end
    if r == "reopen_stage2" then
     stage2_status("STAGE2: popup4 xong nhưng cần mở lại, xử lý từ đầu")
     stage2_mark_step("popup4_reopen")
    end
   end
  elseif stage2_try_popup2_once() then
   stage2_mark_step("popup2")
  elseif stage2_try_popup23_once() then
   stage2_mark_step("popup2.3")
  elseif stage2_try_popup3_once() then
   stage2_mark_step("popup3")
  elseif stage2_try_popup32_once() then
   stage2_mark_step("popup3.2")
  elseif stage2_try_popup1_agree_once() then
   stage2_mark_step("popup1")
  else
   if os.time() - last_progress_at >= 60 then
    if stage2_reopen_event("Stage2 đứng yên >60s") == "restart_stage1" then return "restart_stage1" end
    last_progress_at = os.time()
    last_step_name = "reopen_idle"
    last_step_at = os.time()
   else
    stage2_status("STAGE2: đang chờ popup xuất hiện")
    stage2_sleep(150)
   end
  end
 end
end

function waitTapImage(img, msg, timeoutSec, sim, x1, y1, x2, y2)
 local start = os.time()
 local lastShown = -1
 phase(msg)
 while os.time() - start < timeoutSec do
  local remain = timeoutSec - (os.time() - start)
  if remain ~= lastShown then phaseProgress(remain) lastShown = remain end
  local tapped = tapByImageCenter(img, sim or 82, x1, y1, x2, y2)
  if tapped then waitPhase(1200) return true end
  sleep(500)
 end
 return false
end

function waitImageAppear(img, msg, timeoutSec, sim, x1, y1, x2, y2)
 local start = os.time()
 local lastShown = -1
 phase(msg)
 while os.time() - start < timeoutSec do
  local remain = timeoutSec - (os.time() - start)
  if remain ~= lastShown then phaseProgress(remain) lastShown = remain end
  if findImage(img, sim or 82, x1, y1, x2, y2) then return true end
  sleep(500)
 end
 return false
end

function waitImageDisappear(img, msg, timeoutSec, sim, x1, y1, x2, y2)
 local start = os.time()
 local lastShown = -1
 phase(msg)
 while os.time() - start < timeoutSec do
  local remain = timeoutSec - (os.time() - start)
  local sec = math.ceil(remain)
  if sec ~= lastShown then status("Đang backup " .. sec .. "s") lastShown = sec end
  if not findImage(img, sim or 82, x1, y1, x2, y2) then return true end
  sleep(1000)
 end
 return false
end

function waitTapImageForever(img, msg, sim, x1, y1, x2, y2)
 phase(msg)
 while true do
  if tapByImageCenter(img, sim or 82, x1, y1, x2, y2) then
   waitPhase(1200)
   return true
  end
  status(msg .. " - chờ ảnh")
  sleep(500)
 end
end

function waitImageAppearForever(img, msg, sim, x1, y1, x2, y2)
 phase(msg)
 while true do
  if findImage(img, sim or 82, x1, y1, x2, y2) then return true end
  status(msg .. " - chờ ảnh")
  sleep(500)
 end
end

function waitImageDisappearForever(img, msg, sim, x1, y1, x2, y2)
 phase(msg)
 while true do
  if not findImage(img, sim or 82, x1, y1, x2, y2) then return true end
  status(msg .. " - đang chờ xong")
  sleep(1000)
 end
end

function stage3_has_backupttl_color()
 return screen.is_colors({
  {36,890,0x007AFF},{36,892,0x007AFF},{35,896,0x0D81FF},{36,899,0x007AFF},{36,903,0x007AFF},{36,912,0x007AFF},{40,912,0x007AFF},{43,912,0x007AFF},{46,911,0x007AFF},{48,910,0x007AFF},{50,908,0x007AFF},{51,905,0x007AFF},{49,903,0x007AFF},{48,902,0x007AFF},{44,901,0x007AFF},{40,900,0x007AFF},{49,895,0x007AFF},{50,893,0x007AFF},{37,889,0x007AFF},{39,889,0x0B80FF},{42,889,0x0B80FF},{57,898,0x007AFF},{58,896,0x007AFF},{61,895,0x007AFF},{63,895,0x067DFF},{65,896,0x007AFF},{66,897,0x007AFF},{67,899,0x007AFF},{67,902,0x007AFF},{67,904,0x007AFF},{67,907,0x007AFF},{67,912,0x007AFF},{61,912,0x007AFF},{59,911,0x007AFF},{57,910,0x007AFF},{55,908,0x007AFF},{57,905,0x007AFF},{59,903,0x0E81FF},{62,902,0x9BCBFF},{62,903,0x007AFF},{74,901,0x007AFF},{74,903,0x007AFF},{74,906,0x007AFF},{76,910,0x007AFF},{81,912,0x007AFF},{86,910,0x097FFF},{86,908,0x007AFF},{86,899,0x007AFF},{84,897,0x007AFF},{80,895,0x007AFF},{77,897,0x007AFF},{92,888,0x007AFF},{93,893,0x007AFF},{93,912,0x007AFF},{96,903,0x007AFF},{103,895,0x1A88FF},{103,912,0x027BFF},{111,907,0x007AFF},{122,896,0x007AFF},{116,912,0x007AFF},{122,912,0x007AFF},{130,917,0x007AFF},{131,899,0x007AFF},{136,896,0x007AFF},{137,895,0x007AFF},{141,897,0x007AFF},{143,900,0x007AFF},{143,904,0x007AFF},{142,909,0x007AFF},{138,912,0x007AFF},{46,890,0x007AFF},{36,907,0x007AFF},{38,912,0x007AFF},{42,911,0x007AFF},{93,900,0x007AFF},{93,907,0x007AFF},{110,900,0x007AFF},{122,902,0x007AFF},{130,906,0x007AFF},{122,907,0x007AFF},{110,903,0x007AFF},{111,896,0x007AFF},
 }, 90)
end

function waitBackupTTLColorForever()
 phase("Chờ BackupTTL color")
 while true do
  if stage3_has_backupttl_color() then
   status("Thấy BackupTTL color -> tap 90,902")
   touch.tap(90, 902)
   waitPhase(1200)
   return true
  end
  status("BackupTTL color - chờ điểm ảnh")
  sleep(500)
 end
end

function runStage3()
 phase("Stage 3")
 quitApp(APPMANAGER_BUNDLE, "AppManager")
 quitApp(TIKTOK_LITE_BUNDLE, "TikTok Lite")
 openApp(APPMANAGER_BUNDLE, "AppManager", 5000)
 waitPostOpenColor5s()
 waitTapImageForever(CHECK_TTL, "Chọn TTL", 82, 0, 0, 750, 1334)
 phase("Vuốt trước BackupTTL")
 for i = 1, 3 do
  swipeUpOnce()
  if i < 3 then waitPhase(3000) else waitPhase(1000) end
 end
 waitBackupTTLColorForever()
 waitTapImageForever(TAP_BACKUP, "Tap Backup", 82, 0, 0, 750, 1334)
 waitImageAppearForever(CHECK_BACKUPING, "Chờ backuping", 82, 0, 0, 750, 1334)
 waitImageDisappearForever(CHECK_BACKUPING, "Backup", 82, 0, 0, 750, 1334)
 waitTapImageForever(CHECK_BACKUPDONE, "Tap BackupDone", 82, 0, 0, 750, 1334)
 phase("Stage 3 xong")
 return true
end


phase("Mở TTL - Stage 2")
local stage2Result = runStage2()
if stage2Result ~= true then failStatus("Lỗi Stage 2: " .. tostring(stage2Result)) end
phase("Mở TTL OK")
oc_assistive_touch_on()
return true
