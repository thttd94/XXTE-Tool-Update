screen.init(0)
local __WEBVIEW_STATUS_TEXT = "Xuáº¥t TK Lite Äang cháº¡y ..."
local __ok_webview_status, __webview_status = pcall(require, "webview")
local __WEBVIEW_STATUS_ID = 88
local __WEBVIEW_STATUS_HTML = [[
<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"><style>
html,body{margin:0;padding:0;width:100%;height:100%;background:transparent;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,sans-serif;-webkit-user-select:none;user-select:none;-webkit-touch-callout:none}
#bar{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.58);color:#fff;border-radius:12px;font-size:17px;font-weight:700;text-align:center;white-space:nowrap;box-sizing:border-box}
</style></head><body><div id="bar">Xuáº¥t TK Lite Äang cháº¡y ...</div></body></html>
]]
function show_webview_status()
 if __ok_webview_status and __webview_status and type(__webview_status.show) == "function" then
  pcall(__webview_status.show, { id = __WEBVIEW_STATUS_ID, html = __WEBVIEW_STATUS_HTML, x = 1, y = 1, width = 748, height = 38, alpha = 1.0, corner_radius = 12, opaque = false, can_drag = false, ignores_hit = true })
 end
end
show_webview_status()
function __oc_toast_replacement(text, ...) if type(oc_status) == "function" then pcall(oc_status, __WEBVIEW_STATUS_TEXT) end; show_webview_status(); return nil end
sys = sys or {}; sys["toast"] = __oc_toast_replacement
local app = app or require("app")

local BID = "com.ss.iphone.ugc.tiktok.lite"
local ARCHIVE_DIR = "/var/mobile/Media/1ferver/bin/tiktok_lite"
local OUT_COOKIES = ARCHIVE_DIR .. "/Cookies.binarycookies"
local OUT_ARCHIVER = ARCHIVE_DIR .. "/ttaccountSDKUserInfo.archiver"
local OUT_PLIST = ARCHIVE_DIR .. "/com.ss.iphone.ugc.tiktok.lite.plist"
local OUT_STATUS = ARCHIVE_DIR .. "/status.txt"
local OUT_SANDBOX_TGZ = ARCHIVE_DIR .. "/lite_sandbox.tgz"

local function status(t, holdMs) show_webview_status(); sys.msleep(holdMs or 1000) end
local ok_lfs, lfs = pcall(require, "lfs")
local ok_file, file = pcall(require, "file")
local function mkdirp(p)
 local cur = ""
 for part in tostring(p or ""):gmatch("[^/]+") do
  cur = cur .. "/" .. part
  if ok_lfs and lfs and lfs.mkdir then pcall(lfs.mkdir, cur) end
  if ok_file and file and file.mkdir then pcall(file.mkdir, cur) end
 end
end
local function readAll(path) local f=io.open(path,"rb"); if not f then return nil end; local d=f:read("*a"); f:close(); return d end
local function writeAll(path,data) mkdirp((path:match("^(.+)/[^/]+$") or "/tmp")); local f=io.open(path,"wb"); if not f then return false end; f:write(data); f:close(); return true end
local function copyFile(label, src, dst) local d=readAll(src); if not d then status(label.." miss",1200); return false end; if not writeAll(dst,d) then status(label.." write lá»—i",1200); return false end; status(label.." OK",700); return true end
local function firstExisting(paths) for _,p in ipairs(paths) do local f=io.open(p,"rb"); if f then f:close(); return p end end return nil end
local function resolveGlob(pattern) local p=io.popen("ls -1 "..pattern.." 2>/dev/null | head -n 1"); if not p then return nil end; local out=p:read("*l") or ""; p:close(); if out=="" then return nil end; return out end
mkdirp(ARCHIVE_DIR)
local dataPath = app.data_path(BID)
local ok = 0
local lines = {}
if not dataPath or dataPath == "" then
 writeAll(OUT_STATUS, "ok=0\nerror=no data_path for "..BID.."\n")
 status("KhÃ´ng tháº¥y Lite", 3000)
 return
end
local files = {
 {"cookies", dataPath.."/Library/Cookies/Cookies.binarycookies", OUT_COOKIES},
 {"archiver", dataPath.."/Documents/ttaccountSDKUserInfo.archiver", OUT_ARCHIVER},
 {"plist", dataPath.."/Library/Preferences/com.ss.iphone.ugc.tiktok.lite.plist", OUT_PLIST},
}
for _,it in ipairs(files) do if copyFile(it[1], it[2], it[3]) then ok=ok+1; table.insert(lines,it[1].."="..it[3]) end end
local function q(s) return "'" .. tostring(s):gsub("'", "'\''") .. "'" end
local tar_cmd = "cd " .. q(dataPath) .. " && tar -czf " .. q(OUT_SANDBOX_TGZ) .. " Documents Library/Cookies Library/Preferences 'Library/Application Support' Library/Caches 2>/dev/null"
local rc = os.execute(tar_cmd)
local f=io.open(OUT_SANDBOX_TGZ,"rb")
if f then f:close(); ok=ok+1; table.insert(lines,"sandbox="..OUT_SANDBOX_TGZ) else table.insert(lines,"sandbox_miss rc="..tostring(rc)) end
writeAll(OUT_STATUS, "ok="..tostring(ok).."/3\ndataPath="..tostring(dataPath).."\n"..table.concat(lines,"\n").."\n")
status("Xuáº¥t Lite xong "..tostring(ok).."/3", 2500)


