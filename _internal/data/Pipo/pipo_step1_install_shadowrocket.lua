local IPA_URL = "https://github.com/thttd94/dante-proxy-install/releases/download/v3/Shadowrocket-IPAOMTK.COM.ipa"
local IPA = "/var/mobile/Media/1ferver/ipa/Shadowrocket-IPAOMTK.COM.ipa"
local IPA_EXPECT_SIZE = 22750740
local IPA_EXPECT_SHA1 = "e22bffe8cea81cff89e459cb71a7575136e89f21"

local roots = {
  "/var/containers/Bundle/Application",
  "/private/var/containers/Bundle/Application",
}

local lines = {}
local mkdirp

local ok_webview, webview = pcall(require, "webview")
local WEBVIEW_ID = 91

local function esc_html(s)
  s = tostring(s or "")
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
  return s
end

local function show_top(msg, color)
  color = color or "rgba(0,0,0,.82)"
  if ok_webview and webview and type(webview.show) == "function" then
    local html = [[<html><head><meta name="viewport" content="width=device-width,initial-scale=1">
<style>html,body{margin:0;padding:0;background:transparent;overflow:hidden;font-family:-apple-system,Arial}#b{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:]] .. color .. [[;color:#fff;border-radius:12px;font-size:15px;font-weight:800;text-align:center;box-sizing:border-box;padding:0 8px;white-space:normal}</style>
</head><body><div id="b">]] .. esc_html(msg) .. [[</div></body></html>]]
    pcall(function()
      webview.show{ id=WEBVIEW_ID, html=html, x=1, y=1, width=748, height=70, alpha=1.0, corner_radius=12, opaque=false, can_drag=false, ignores_hit=true, level=999999, animation_duration=0 }
    end)
  end
end

local function add(s)
  lines[#lines + 1] = tostring(s or "")
  pcall(function()
    mkdirp("/var/mobile/Media/1ferver")
    local f = io.open("/var/mobile/Media/1ferver/pipo_stage1_shadow.log", "w")
    if f then f:write(table.concat(lines, "\n\n")); f:close() end
  end)
  show_top(s)
end

local function exists(p)
  local f = io.open(p, "rb")
  if f then
    local len = f:seek("end") or -1
    f:close()
    return true, len
  end
  return false, -1
end

local ok_file, file = pcall(require, "file")
local ok_lfs, lfs = pcall(require, "lfs")
local ok_sys, sys = pcall(require, "sys")

local function sleep_ms(ms)
  if ok_sys and sys and sys.msleep then
    sys.msleep(ms)
  else
    os.execute("sleep " .. tostring(math.max(1, math.floor((ms or 1000) / 1000))))
  end
end

local function dirname(p)
  return tostring(p):match("^(.+)/[^/]+$")
end

mkdirp = function(p)
  if not p or p == "" then return end
  local cur = ""
  for part in tostring(p):gmatch("[^/]+") do
    cur = cur .. "/" .. part
    pcall(function()
      if ok_lfs and lfs and lfs.mkdir then lfs.mkdir(cur) end
    end)
    pcall(function()
      if ok_file and file and file.mkdir then file.mkdir(cur) end
    end)
    pcall(function()
      os.execute("mkdir -p " .. "'" .. cur:gsub("'", "'\\''") .. "'")
    end)
  end
end

local function list(p)
  if ok_file and file and file.list then
    local ok, t = pcall(file.list, p)
    if ok and type(t) == "table" then
      return t
    end
  end
  return {}
end

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function sh(cmd)
  add("$ " .. cmd)
  local f = io.popen(cmd .. " 2>&1")
  local o = ""
  if f then
    o = f:read("*a") or ""
    local ok, why, code = f:close()
    o = o .. "\nCLOSE " .. tostring(ok) .. " " .. tostring(why) .. " " .. tostring(code)
  else
    o = "io.popen failed"
  end
  add(o)
  return o
end

local function download_with_lua_socket(url, dst)
  local ok_http, http = pcall(require, "socket.http")
  local ok_ltn12, ltn12 = pcall(require, "ltn12")

  if not ok_http or not http or not ok_ltn12 or not ltn12 then
    add("Lua socket.http/ltn12 missing")
    return false
  end

  local f, err = io.open(dst, "wb")
  if not f then
    add("Lua download open dst fail: " .. tostring(err))
    return false
  end

  local ok, code, headers, status = http.request({
    url = url,
    sink = ltn12.sink.file(f),
    redirect = true,
  })

  add("Lua http.request ok=" .. tostring(ok) .. " code=" .. tostring(code) .. " status=" .. tostring(status))

  local ex, len = exists(dst)
  return ex and len and len > 1024 * 1024
end

local function file_sha1(path)
  local cmds = {
    "/usr/bin/shasum -a 1 " .. shell_quote(path) .. " 2>/dev/null",
    "/var/jb/usr/bin/shasum -a 1 " .. shell_quote(path) .. " 2>/dev/null",
    "/usr/bin/openssl sha1 " .. shell_quote(path) .. " 2>/dev/null",
    "/var/jb/usr/bin/openssl sha1 " .. shell_quote(path) .. " 2>/dev/null",
  }
  for _,cmd in ipairs(cmds) do
    local out = sh(cmd)
    local h = tostring(out or ""):match("([a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9])")
    if h then return string.lower(h) end
  end
  return nil
end

local function delete_ipa(reason)
  add("IPA invalid: " .. tostring(reason) .. " -> delete and re-download")
  pcall(os.remove, IPA)
  pcall(function() if ok_file and file and file.delete then file.delete(IPA) end end)
end

local function ipa_valid(label)
  local ok, len = exists(IPA)
  if not ok then return false, "missing" end
  if tonumber(len or 0) ~= tonumber(IPA_EXPECT_SIZE) then
    return false, "size=" .. tostring(len) .. " expect=" .. tostring(IPA_EXPECT_SIZE)
  end
  local h = file_sha1(IPA)
  if h and h ~= IPA_EXPECT_SHA1 then
    return false, "sha1=" .. tostring(h) .. " expect=" .. IPA_EXPECT_SHA1
  end
  if not h then
    add("IPA " .. tostring(label or "check") .. " size OK, sha1 command unavailable -> accept by exact size")
  else
    add("IPA " .. tostring(label or "check") .. " OK size=" .. tostring(len) .. " sha1=" .. h)
  end
  return true, "ok"
end

local function download_ipa()
  mkdirp(dirname(IPA))

  local valid, why = ipa_valid("cache")
  if valid then
    add("IPA exists before download -> use cached")
    return true
  end
  local ok = exists(IPA)
  if ok then delete_ipa(why) end

  add("Downloading Shadowrocket IPA...")

  local cmds = {
    "/usr/bin/curl -L --fail --connect-timeout 5 --max-time 120 -o " .. shell_quote(IPA) .. " " .. shell_quote(IPA_URL),
    "/var/jb/usr/bin/curl -L --fail --connect-timeout 5 --max-time 120 -o " .. shell_quote(IPA) .. " " .. shell_quote(IPA_URL),
    "/usr/bin/wget -O " .. shell_quote(IPA) .. " " .. shell_quote(IPA_URL),
    "/var/jb/usr/bin/wget -O " .. shell_quote(IPA) .. " " .. shell_quote(IPA_URL),
  }
  for _,cmd in ipairs(cmds) do
    sh(cmd)
    valid, why = ipa_valid("download")
    if valid then return true end
    if exists(IPA) then delete_ipa(why) end
  end

  if download_with_lua_socket(IPA_URL, IPA) then
    valid, why = ipa_valid("lua_socket")
    if valid then return true end
    delete_ipa(why)
  end

  local ex, len = exists(IPA)
  add("DOWNLOAD_FAIL exists=" .. tostring(ex) .. " len=" .. tostring(len) .. " why=" .. tostring(why))
  return false
end

local function find_trollstore()
for _, root in ipairs(roots) do
    for _, uuid in ipairs(list(root)) do
      local dir = root .. "/" .. tostring(uuid)
      for _, name in ipairs(list(dir)) do
        local appname = tostring(name)
        local apppath = dir .. "/" .. appname

        if appname == "TrollStore.app" then
          local helper = apppath .. "/trollstorehelper"
          local ok = exists(helper)
          if ok then
            return apppath, helper
          end
        end
      end
    end
  end
  return nil, nil
end

local function find_shadowrocket()
  local found = nil
  local count = 0

  for _, root in ipairs(roots) do
    for _, uuid in ipairs(list(root)) do
      local dir = root .. "/" .. tostring(uuid)
      for _, name in ipairs(list(dir)) do
        local appname = tostring(name)
        if appname == "Shadowrocket.app" then
          count = count + 1
          found = dir .. "/" .. appname
          add("FOUND Shadowrocket " .. found)
        end
      end
    end
  end

  return found, count
end

local function open_shadowrocket()
  local opened = false
  local ok_app, app = pcall(require, "app")

  if ok_app and app then
    if app.run then
      local ok, err = pcall(app.run, "com.liguangming.Shadowrocket")
      add("app.run com.liguangming.Shadowrocket ok=" .. tostring(ok) .. " err=" .. tostring(err))
      opened = opened or ok
    end

    if app.open then
      local ok, err = pcall(app.open, "com.liguangming.Shadowrocket")
      add("app.open com.liguangming.Shadowrocket ok=" .. tostring(ok) .. " err=" .. tostring(err))
      opened = opened or ok
    end
  end

  return opened
end

add("IPA_URL=" .. IPA_URL)
add("IPA=" .. IPA)

local dl_ok = download_ipa()
local ipa_ok, ipa_len = exists(IPA)

add("DOWNLOAD_OK=" .. tostring(dl_ok))
add("IPA exists=" .. tostring(ipa_ok) .. " len=" .. tostring(ipa_len))

local ts, helper = find_trollstore()
add("TROLLSTORE=" .. tostring(ts))
add("HELPER=" .. tostring(helper))

if not ipa_ok or ipa_len <= 1024 * 1024 then
  add("ERROR: IPA download missing/too small")
elseif not helper then
  add("ERROR: TrollStore helper missing")
else
  add("Installing Shadowrocket via TrollStore...")
  local install_out = sh(shell_quote(helper) .. " install " .. shell_quote(IPA))
  if tostring(install_out):find("MachO is encrypted", 1, true) or tostring(install_out):find("returning 180", 1, true) then
    add("ERROR: IPA encrypted - cần decrypted IPA")
  end
  add("Refreshing TrollStore apps...")
  sh(shell_quote(helper) .. " refresh")
end

local app_path, count = find_shadowrocket()
add("COUNT=" .. tostring(count))
add("APP_PATH=" .. tostring(app_path))

local opened = false
if count > 0 then
  opened = open_shadowrocket()
  if opened then
    sleep_ms(1500)
    local ok_touch, touch = pcall(require, "touch")
    if ok_touch and touch and touch.tap then
      touch.tap(495, 802)
      add("TAP_AFTER_OPEN=495,802")
      sleep_ms(500)
    else
      add("TAP_AFTER_OPEN_FAIL no touch.tap")
    end
  end
else
  add("Skip open: Shadowrocket not installed")
end
add("OPENED=" .. tostring(opened))

local text = table.concat(lines, "\n\n")

pcall(function()
  mkdirp("/var/mobile/Media/1ferver")
  local f = io.open("/var/mobile/Media/1ferver/pipo_stage1_shadow.log", "w")
  if f then f:write(text); f:close() end
end)

print(text)

local ok_sys, sys = pcall(require, "sys")
if ok_sys and sys and sys.toast then
  if count > 0 then
    show_top("Shadowrocket installed/opened", "rgba(0,140,40,.90)")
    sys.toast("Shadowrocket installed/opened")
  else
    show_top("Shadowrocket install failed", "rgba(190,0,0,.92)")
    sys.toast("Shadowrocket install failed")
  end
end

return count > 0

