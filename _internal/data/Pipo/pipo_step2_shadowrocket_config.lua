-- Pipo step2: Shadowrocket popup tap + basic config
-- IMPORTANT: XXTE Manager should replace __PC_IP__ with host local IP before sending.
local PC_IP = "__PC_IP__"
local PROXY_PORT = "8881"
local OUT = "/var/mobile/Media/1ferver/log/pipo_step2_shadowrocket_config.txt"

local function log(s)
  s = tostring(s or "")
  print(s)
  local f = io.open(OUT, "a")
  if f then f:write(os.date("%H:%M:%S ") .. s .. "\n"); f:close() end
end

local function reset_log()
  local f = io.open(OUT, "w")
  if f then f:write("START pipo step2 Shadowrocket config\n"); f:close() end
end

local ok_screen, screen = pcall(require, "screen")
local ok_touch, touch = pcall(require, "touch")
local ok_app, app = pcall(require, "app")
local ok_file, file = pcall(require, "file")
local ok_lfs, lfs = pcall(require, "lfs")
local ok_sys, sys = pcall(require, "sys")
local ok_key, key = pcall(require, "key")
local ok_pasteboard, pasteboard = pcall(require, "pasteboard")

local roots = {
  "/var/containers/Bundle/Application",
  "/private/var/containers/Bundle/Application",
}
local data_roots = {
  "/var/mobile/Containers/Data/Application",
  "/private/var/mobile/Containers/Data/Application",
}

local function exists(p)
  local f = io.open(p, "rb")
  if f then local n = f:seek("end") or 0; f:close(); return true, n end
  return false, 0
end

local function list(p)
  if ok_file and file and file.list then
    local ok, t = pcall(file.list, p)
    if ok and type(t) == "table" then return t end
  end
  return {}
end

local function mkdirp(p)
  if not p or p == "" then return end
  local cur = ""
  for part in tostring(p):gmatch("[^/]+") do
    cur = cur .. "/" .. part
    pcall(function() if ok_lfs and lfs and lfs.mkdir then lfs.mkdir(cur) end end)
    pcall(function() if ok_file and file and file.mkdir then file.mkdir(cur) end end)
    pcall(function() os.execute("mkdir -p '" .. cur:gsub("'", "'\\''") .. "'") end)
  end
end

local function dirname(p)
  return tostring(p):match("^(.+)/[^/]+$") or "/"
end

local function write_file(p, content)
  mkdirp(dirname(p))
  local f, err = io.open(p, "w")
  if not f then log("WRITE_FAIL " .. p .. " err=" .. tostring(err)); return false end
  f:write(content or "")
  f:close()
  log("WRITE_OK " .. p .. " len=" .. tostring(#(content or "")))
  return true
end

local function read_file(p)
  local f = io.open(p, "rb")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function sleep_ms(ms)
  if ok_sys and sys and sys.msleep then
    sys.msleep(ms)
  else
    os.execute("sleep " .. tostring(math.max(1, math.floor(ms / 1000))))
  end
end

local function tap_xy(x, y)
  log("TAP " .. x .. "," .. y)
  if ok_touch and touch then
    if touch.on then
      local ok, obj = pcall(touch.on, x, y)
      sleep_ms(90)
      if ok and obj then
        pcall(function() obj:off() end)
        sleep_ms(450)
        return true
      end
    end
    if touch.tap then pcall(touch.tap, x, y); sleep_ms(450); return true end
  end
  return false
end

local function send_text(s)
  s = tostring(s or "")
  if ok_pasteboard and pasteboard and pasteboard.write then pcall(pasteboard.write, s) end
  sleep_ms(150)
  if ok_key and key and key.send_text then
    pcall(key.send_text, s)
    sleep_ms(500)
    return true
  end
  log("NO_KEY_SEND_TEXT")
  return false
end

local function wait_and_tap_first_popup(timeout_sec)
  timeout_sec = timeout_sec or 20
  if not ok_screen or not screen or not screen.is_colors then
    log("NO_SCREEN_MODULE skip popup tap")
    return false
  end
  local t0 = os.time()
  while os.time() - t0 < timeout_sec do
    local ok, matched = pcall(screen.is_colors, {
      {474,805,0x007aff},
      {479,805,0x007aff},
      {485,806,0x007aff},
      {489,813,0x007aff},
      {532,811,0x007aff},
      {543,811,0x007aff},
      {548,796,0x1886fd},
    }, 90)
    if ok and matched then
      log("POPUP_MATCH")
      tap_xy(511, 806)
      return true
    end
    sleep_ms(500)
  end
  log("POPUP_NOT_FOUND")
  return false
end

local function find_shadowrocket_app()
  for _, root in ipairs(roots) do
    for _, uuid in ipairs(list(root)) do
      local dir = root .. "/" .. tostring(uuid)
      for _, name in ipairs(list(dir)) do
        if tostring(name) == "Shadowrocket.app" then
          return dir .. "/" .. tostring(name)
        end
      end
    end
  end
  return nil
end

local function find_shadowrocket_data()
  for _, root in ipairs(data_roots) do
    for _, uuid in ipairs(list(root)) do
      local base = root .. "/" .. tostring(uuid)
      local pref = base .. "/Library/Preferences/com.liguangming.Shadowrocket.plist"
      local db = base .. "/Documents/Databases/default.db"
      local okp = exists(pref)
      local okd = exists(db)
      if okp or okd then return base, db end
    end
  end
  return nil, nil
end

local function shadow_conf()
  return table.concat({
    "[General]",
    "bypass-system = true",
    "skip-proxy = 127.0.0.1, localhost, *.local",
    "dns-server = system",
    "",
    "[Proxy]",
    "PROXY = http, " .. PC_IP .. ", " .. PROXY_PORT,
    "",
    "[Rule]",
    "DOMAIN-SUFFIX,pipopay.com,PROXY",
    "DOMAIN-SUFFIX,mitm.it,PROXY",
    "FINAL,DIRECT",
    "",
  }, "\n")
end

local function try_sqlite_db(db)
  if not db or db == "" then return false end
  local ok_sqlite, sqlite3 = pcall(require, "sqlite3")
  if not ok_sqlite or not sqlite3 then
    ok_sqlite, sqlite3 = pcall(require, "lsqlite3")
  end
  if not ok_sqlite or not sqlite3 then
    log("SQLITE_MODULE_MISSING skip DB edit")
    return false
  end
  local open_fn = sqlite3.open or sqlite3.open_memory
  if not sqlite3.open then log("SQLITE_OPEN_MISSING"); return false end
  local conn = sqlite3.open(db)
  if not conn then log("SQLITE_OPEN_FAIL " .. tostring(db)); return false end
  local function exec(sql)
    local ok, err = pcall(function() return conn:exec(sql) end)
    if not ok then log("SQL_ERR " .. tostring(err) .. " sql=" .. sql); return false end
    return true
  end
  exec("delete from config where section='rule' and ((name='DOMAIN-SUFFIX' and value in ('pipopay.com','mitm.it')) or name='FINAL')")
  exec("insert into config(section,name,value,option,ext,remarks,created) values('rule','DOMAIN-SUFFIX','pipopay.com','PROXY','','',strftime('%s','now'))")
  exec("insert into config(section,name,value,option,ext,remarks,created) values('rule','DOMAIN-SUFFIX','mitm.it','PROXY','','',strftime('%s','now'))")
  exec("insert into config(section,name,value,option,ext,remarks,created) values('rule','FINAL','','DIRECT','','',strftime('%s','now'))")
  pcall(function() conn:close() end)
  log("SQLITE_DB_RULES_OK")
  return true
end

local function create_http_server_ui()
  if not (ok_app and app and app.run) then log("NO_APP_MODULE skip server UI"); return false end
  if not (ok_touch and touch) then log("NO_TOUCH_MODULE skip server UI"); return false end
  pcall(app.run, "com.liguangming.Shadowrocket")
  sleep_ms(1200)
  -- Coordinates are iPhone 750x1334 logical points used by this fleet.
  tap_xy(92, 1277)     -- Home tab
  sleep_ms(700)
  tap_xy(690, 83)      -- top-right plus; if no action, Add Server row is still below
  sleep_ms(900)
  -- If still on Home, tap Add Server row center/right.
  tap_xy(380, 608)
  sleep_ms(900)
  -- Type row -> choose HTTP.
  tap_xy(530, 213)
  sleep_ms(700)
  tap_xy(120, 1045)    -- HTTP row in Type screen
  sleep_ms(900)
  -- Address + Port.
  tap_xy(390, 380)
  send_text(PC_IP)
  tap_xy(300, 480)
  send_text(PROXY_PORT)
  -- Close keyboard and save.
  tap_xy(675, 858)     -- Done on numeric keyboard
  sleep_ms(700)
  tap_xy(680, 83)      -- Save
  sleep_ms(1800)
  log("SERVER_UI_DONE")
  return true
end

reset_log()
log("PC_IP=" .. tostring(PC_IP) .. " PORT=" .. tostring(PROXY_PORT))
if PC_IP == "__PC_IP__" or PC_IP == "" then
  log("ERROR: PC_IP not replaced")
  return false
end

if ok_app and app and app.run then
  pcall(app.run, "com.liguangming.Shadowrocket")
  log("RUN Shadowrocket")
end

wait_and_tap_first_popup(20)

local app_path = find_shadowrocket_app()
log("APP_PATH=" .. tostring(app_path))
local data_path, db_path = find_shadowrocket_data()
log("DATA_PATH=" .. tostring(data_path))
log("DB_PATH=" .. tostring(db_path))
if not data_path then
  log("ERROR: Shadowrocket data container not found")
  return false
end

local conf = shadow_conf()
write_file(data_path .. "/Documents/default.conf", conf)
write_file(data_path .. "/Documents/Profiles/default.conf", conf)
try_sqlite_db(db_path)

if ok_app and app and app.run then
  pcall(app.run, "com.liguangming.Shadowrocket")
end
create_http_server_ui()
log("DONE step2 config")
return true
