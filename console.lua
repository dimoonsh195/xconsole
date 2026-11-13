local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer

-- ============ GITHUB PATHS ============
local GITHUB_REPO    = "https://raw.githubusercontent.com/dimoonsh195/xconsole/main/"
local GITHUB_PLUGINS = GITHUB_REPO .. "plugins/"
local GITHUB_LIBS    = GITHUB_REPO .. "libraries/"

-- ============ WORKSHOP PLUGINS ============
local WORKSHOP_PLUGINS = {
    {
        name = "LegacyConsole", author = "dimoonsh", isVerified = true, isSystem = true,
        desc = "Creates a legacy style console GUI.",
        imageId = "18794851856", downloadUrl = GITHUB_PLUGINS .. "legacyconsole.xconr",
    },
    {
        name = "Xcode", author = "dimoonsh", isVerified = true, isSystem = true,
        desc = "Write and run Lua code directly.",
        imageId = "90599253456267", downloadUrl = nil,
    },
    {
        name = "CustomCommand", author = "dimoonsh", isVerified = true, isSystem = false,
        desc = "Create custom shortcuts to Lua code/commands.",
        imageId = "6767454861", downloadUrl = GITHUB_PLUGINS .. "customcommand.xconr",
    },
    {
        name = "ItemGiver", author = "dimoonsh", isVerified = true, isSystem = false,
        desc = "Toolbox-style item browser. Search, view, and give items.",
        imageId = "84410706391069", downloadUrl = GITHUB_PLUGINS .. "itemgiver.xconr",
    },
    {
        name = "MacroRecorder", author = "dimoonsh", isVerified = true, isSystem = false,
        desc = "Record commands with timestamps. Replay with original delays.",
        imageId = "10272025820", downloadUrl = GITHUB_PLUGINS .. "macrorecorder.xconr",
    },
    {
        name = "AutoExecutor", author = "dimoonsh", isVerified = true, isSystem = false,
        desc = "Trigger Lua code on conditions: HP, every N sec, position change.",
        imageId = "99401578254704", downloadUrl = GITHUB_PLUGINS .. "autoexecutor.xconr",
    },
    {
        name = "PlayerTracker", author = "dimoonsh", isVerified = true, isSystem = false,
        desc = "Separate window with event feed: join, leave, death.",
        imageId = "2795572803", downloadUrl = GITHUB_PLUGINS .. "playertracker.xconr",
    },
    {
        name = "KeybindManager", author = "dimoonsh", isVerified = true, isSystem = false,
        desc = "GUI for managing keybinds.",
        imageId = "13254238415", downloadUrl = GITHUB_PLUGINS .. "keybindmanager.xconr",
    },
}

-- ============ WORKSHOP LIBRARIES ============
local WORKSHOP_LIBS = {
    {
        name = "Adaptive", author = "dimoonsh", isVerified = true, isSystem = true,
        desc = "Automatically adapts console to device screen.",
        imageId = "6252577932", downloadUrl = nil, libId = "adaptive",
    },
    {
        name = "IconLoader", author = "dimoonsh", isVerified = true, isSystem = true,
        desc = "Loads all console icons via thumbnails API.",
        imageId = "6252577932", downloadUrl = nil, libId = "iconloader",
    },
    {
        name = "Janitor", author = "howmanysmall", isVerified = false, isSystem = false,
        desc = "Cleans up connections, instances, callbacks on plugin unload.",
        imageId = "6252577932", downloadUrl = GITHUB_LIBS .. "janitor.xconr", libId = "janitor",
    },
    {
        name = "Signal", author = "Roblox", isVerified = true, isSystem = false,
        desc = "Event class for plugin-to-plugin communication.",
        imageId = "6252577932", downloadUrl = GITHUB_LIBS .. "signal.xconr", libId = "signal",
    },
    {
        name = "LineCleaner", author = "dimoonsh", isVerified = true, isSystem = false,
        desc = "Strips empty lines from pasted code before execution.",
        imageId = "6252577932", downloadUrl = GITHUB_LIBS .. "linecleaner.xconr", libId = "linecleaner",
    },
    {
        name = "ObjectPool", author = "Roblox", isVerified = false, isSystem = false,
        desc = "Reuses objects instead of Instance.new/Destroy.",
        imageId = "6252577932", downloadUrl = GITHUB_LIBS .. "objectpool.xconr", libId = "objectpool",
    },
    {
        name = "Memoize", author = "community", isVerified = false, isSystem = false,
        desc = "Caches function results for identical arguments.",
        imageId = "6252577932", downloadUrl = GITHUB_LIBS .. "memoize.xconr", libId = "memoize",
    },
    {
        name = "LRUCache", author = "community", isVerified = false, isSystem = false,
        desc = "Limited-size cache with eviction.",
        imageId = "6252577932", downloadUrl = GITHUB_LIBS .. "lrucache.xconr", libId = "lrucache",
    },
    {
        name = "ThreadPool", author = "community", isVerified = false, isSystem = false,
        desc = "Reuses coroutines.",
        imageId = "6252577932", downloadUrl = GITHUB_LIBS .. "threadpool.xconr", libId = "threadpool",
    },
}

local LIB_LIST = { "janitor", "signal", "linecleaner", "objectpool", "memoize", "lrucache", "threadpool" }

-- ============ FORWARD DECLS ============
local SaveBtn, LoadBtn, eventsTitleLabel, eventBoxes, eventLabels
local SettingsFrame, SettingsScroll, SettingsTitle, BackBtn
local themeButtons, themeLabel, secretBtn, win10Btn
local bgRow, bgBox, bgApplyBtn, bgLabel
local HideBtn, ExtraIcon, SettingsBtn, PhoneIconBtn, WorkshopBtn
local filterPrintBtn, filterWarnBtn, filterErrorBtn, filterSuccessBtn, filterEchoBtn
local premiumEnabled = false
local customBgId = ""
local currentDevice = "PC"
local showPrint, showWarn, showError, showSuccess, showEcho = true, true, true, true, true
local commands = {}
local applyThemeToSettings, saveConfig, refreshThemeButtons, setupBind
local SECRET = "100110101011000101"
local WIN10_THEME_ID = "13932338252"
eventBoxes = {}; eventLabels = {}
themeButtons = {}

local pluginCommands = {}
local loadedPlugins = {}
local pluginEventHooks = {}
local backupPlugins = {}
local customCommands = {}
local PLUGIN_EXT = ".xconr"
local useFallbackText = false

local loadedLibs = {}
local backupLibs = {}
local pendingPluginSettings = {}
local pendingLibSettings = {}
local CUSTOM_PLUGINS_DIR = "workspace/xcon_custom/plugins"
local CUSTOM_LIBS_DIR    = "workspace/xcon_custom/libs"

local function normName(name)
    return tostring(name or ""):lower():gsub("%s+", "")
end
local function slugify(name)
    return tostring(name):lower():gsub("[^%w_]+", "_"):sub(1, 32)
end
local function ensureDir(path)
    if isfolder and not isfolder(path) then pcall(makefolder, path) end
end

-- ============ THEMES ============
local THEMES = {
    default = { background=Color3.fromRGB(15,15,15), header=Color3.fromRGB(25,25,25), input=Color3.fromRGB(30,30,30), log=Color3.fromRGB(10,10,10), accent=Color3.fromRGB(255,255,255), text=Color3.fromRGB(255,255,255), stroke=Color3.fromRGB(255,255,255) },
    winter = { background=Color3.fromRGB(80,140,200), header=Color3.fromRGB(60,120,180), input=Color3.fromRGB(100,160,215), log=Color3.fromRGB(50,110,170), accent=Color3.fromRGB(220,240,255), text=Color3.fromRGB(240,250,255), stroke=Color3.fromRGB(180,220,255) },
    halloween = { background=Color3.fromRGB(45,28,15), header=Color3.fromRGB(60,38,20), input=Color3.fromRGB(55,35,18), log=Color3.fromRGB(35,20,10), accent=Color3.fromRGB(255,140,0), text=Color3.fromRGB(255,160,40), stroke=Color3.fromRGB(255,140,0) },
    [SECRET] = { background=Color3.fromRGB(60,60,60), header=Color3.fromRGB(40,40,40), input=Color3.fromRGB(50,50,50), log=Color3.fromRGB(30,30,30), accent=Color3.fromRGB(220,220,220), text=Color3.fromRGB(235,235,235), stroke=Color3.fromRGB(140,140,140) },
    win10 = { background=Color3.fromRGB(20,20,20), header=Color3.fromRGB(35,35,35), input=Color3.fromRGB(45,45,45), log=Color3.fromRGB(15,15,15), accent=Color3.fromRGB(0,120,215), text=Color3.fromRGB(240,240,240), stroke=Color3.fromRGB(0,120,215) },
    custom = { background=Color3.fromRGB(20,20,20), header=Color3.fromRGB(35,35,35), input=Color3.fromRGB(45,45,45), log=Color3.fromRGB(15,15,15), accent=Color3.fromRGB(255,255,255), text=Color3.fromRGB(240,240,240), stroke=Color3.fromRGB(255,255,255) },
}
local currentTheme = "default"

local function getThumb(id)
    local num = tostring(id):match("%d+")
    if not num then return "" end
    return "rbxthumb://type=Asset&id=" .. num .. "&w=768&h=432"
end
local function getIcon(id)
    local num = tostring(id):match("%d+")
    if not num then return "" end
    return "rbxthumb://type=Asset&id=" .. num .. "&w=150&h=150"
end

local CONFIG = { Font = Enum.Font.Code, MaxHistory = 50 }
local COLORS = { Error=Color3.fromRGB(255,100,100), Success=Color3.fromRGB(100,255,100), Info=Color3.fromRGB(255,200,100), Echo=Color3.fromRGB(150,150,150), Default=Color3.fromRGB(255,255,255), Output=Color3.fromRGB(200,200,255) }

local commandHistory, historyIndex = {}, 0
local logConnection = nil
local binds, bindConns = {}, {}
local STATES = {
    flying=false, flyConn=nil, noclip=false, noclipConn=nil, esp=false, espFolder=nil, espConn=nil, swim=false, swimConn=nil, fling=false, flingConn=nil, infjump=false, infjumpConn=nil, spasm=false, spasmConn=nil, fullbright=false, fbBackup=nil, nofog=false, fogBackup=nil, enableDrop=false, dropConn=nil, enableJump=false, jumpConn=nil, jumpBackup=nil, jumpRequestConn=nil, enableSit=false, sitInputConn=nil, enableZoom=false, zoomConn=nil, zoomBackup=nil, velocityActive=false, velocityConn=nil, velocityCollideBackup=nil, velocitySpeedBackup=nil,
    events = { onKilled="", onDied="", onSpawn="", onExecute="", onJoin="", onDamage="", onLeave="" },
}

local originalWalkSpeed = nil
local speedCaptured = false
local consoleHidden = false
local CONFIG_FILE = "xconsole_config.json"

local function getGuiParent()
    if type(gethui) == "function" then local ok, hui = pcall(gethui); if ok and hui then return hui end end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    local ok2, pg = pcall(function() return LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if ok2 and pg then return pg end
end
local guiParent = getGuiParent()
if not guiParent then return end
for _, name in ipairs({"SimpleConsole","XcodeGui","MainMenu"}) do
    if guiParent:FindFirstChild(name) then guiParent[name]:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleConsole"; ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true; ScreenGui.DisplayOrder = 5000; ScreenGui.Parent = guiParent

local ConsoleFrame = Instance.new("Frame")
ConsoleFrame.Size = UDim2.new(0,600,0,350); ConsoleFrame.Position = UDim2.new(0,20,0,20)
ConsoleFrame.BackgroundColor3 = THEMES.default.background; ConsoleFrame.BackgroundTransparency = 0
ConsoleFrame.BorderSizePixel = 0; ConsoleFrame.Active = true; ConsoleFrame.Draggable = true; ConsoleFrame.Visible = false; ConsoleFrame.Parent = ScreenGui
local consoleCorner = Instance.new("UICorner", ConsoleFrame); consoleCorner.CornerRadius = UDim.new(0,6)

local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1,0,1,0); bgImage.Position = UDim2.new(0,0,0,0)
bgImage.BackgroundTransparency = 1; bgImage.ImageTransparency = 0; bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 1; bgImage.Visible = false; bgImage.Parent = ConsoleFrame
Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0,6)

local stroke = Instance.new("UIStroke")
stroke.Color = THEMES.default.stroke; stroke.Thickness = 1; stroke.Transparency = 0.5; stroke.Parent = ConsoleFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,30); Header.BackgroundColor3 = THEMES.default.header
Header.BackgroundTransparency = 0; Header.BorderSizePixel = 0; Header.ZIndex = 2; Header.Parent = ConsoleFrame
local headerCorner = Instance.new("UICorner", Header); headerCorner.CornerRadius = UDim.new(0,6)

local Title = Instance.new("ImageButton")
Title.Size = UDim2.new(0,26,0,26); Title.Position = UDim2.new(0,4,0,2)
Title.BackgroundTransparency = 1; Title.Image = getIcon(54479712); Title.ScaleType = Enum.ScaleType.Fit
Title.ZIndex = 3; Title.Parent = Header

ExtraIcon = Instance.new("ImageButton")
ExtraIcon.Size = UDim2.new(0,24,0,24); ExtraIcon.Position = UDim2.new(1,-136,0,3)
ExtraIcon.BackgroundTransparency = 1; ExtraIcon.Image = getIcon(2484276650); ExtraIcon.ScaleType = Enum.ScaleType.Fit
ExtraIcon.ZIndex = 3; ExtraIcon.Parent = Header

SettingsBtn = Instance.new("ImageButton")
SettingsBtn.Size = UDim2.new(0,24,0,24); SettingsBtn.Position = UDim2.new(1,-84,0,3)
SettingsBtn.BackgroundTransparency = 1; SettingsBtn.Image = getIcon(9405931596); SettingsBtn.ScaleType = Enum.ScaleType.Fit
SettingsBtn.ZIndex = 3; SettingsBtn.Parent = Header

WorkshopBtn = Instance.new("ImageButton")
WorkshopBtn.Size = UDim2.new(0,24,0,24); WorkshopBtn.Position = UDim2.new(1,-110,0,3)
WorkshopBtn.BackgroundTransparency = 1; WorkshopBtn.Image = getIcon(11395780614); WorkshopBtn.ScaleType = Enum.ScaleType.Fit
WorkshopBtn.ZIndex = 3; WorkshopBtn.Parent = Header

HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0,28,0,28); HideBtn.Position = UDim2.new(1,-58,0,1)
HideBtn.BackgroundTransparency = 1; HideBtn.Text = ""; HideBtn.BorderSizePixel = 0; HideBtn.ZIndex = 3; HideBtn.Parent = Header

local HideDash = Instance.new("Frame")
HideDash.Size = UDim2.new(0,16,0,3); HideDash.Position = UDim2.new(0.5,-8,0.5,-1.5)
HideDash.BackgroundColor3 = Color3.fromRGB(255,255,255); HideDash.BorderSizePixel = 0; HideDash.ZIndex = 4; HideDash.Parent = HideBtn
Instance.new("UICorner", HideDash).CornerRadius = UDim.new(1,0)

CloseBtn = Instance.new("ImageButton")
CloseBtn.Size = UDim2.new(0,24,0,24); CloseBtn.Position = UDim2.new(1,-28,0,3)
CloseBtn.BackgroundTransparency = 1; CloseBtn.Image = getIcon(111716979356360); CloseBtn.ScaleType = Enum.ScaleType.Fit
CloseBtn.ZIndex = 3; CloseBtn.Parent = Header

PhoneIconBtn = Instance.new("ImageButton")
PhoneIconBtn.Size = UDim2.new(0, 40, 0, 40); PhoneIconBtn.Position = UDim2.new(0, 20, 0, 20)
PhoneIconBtn.BackgroundTransparency = 1; PhoneIconBtn.Image = getIcon(54479712); PhoneIconBtn.ScaleType = Enum.ScaleType.Fit
PhoneIconBtn.Visible = false; PhoneIconBtn.ZIndex = 10; PhoneIconBtn.Parent = ScreenGui

PhoneIconBtn.MouseButton1Click:Connect(function()
    consoleHidden = false; ConsoleFrame.Visible = true; PhoneIconBtn.Visible = false
end)

local LogBg = Instance.new("Frame")
LogBg.Size = UDim2.new(1,-10,1,-75); LogBg.Position = UDim2.new(0,5,0,35)
LogBg.BackgroundColor3 = THEMES.default.log; LogBg.BackgroundTransparency = 0
LogBg.BorderSizePixel = 0; LogBg.ZIndex = 1; LogBg.Parent = ConsoleFrame
Instance.new("UICorner", LogBg).CornerRadius = UDim.new(0,4)

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1,-10,1,-75); LogFrame.Position = UDim2.new(0,5,0,35)
LogFrame.BackgroundTransparency = 1; LogFrame.BorderSizePixel = 0; LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = THEMES.default.accent; LogFrame.CanvasSize = UDim2.new(0,0,0,0)
LogFrame.ZIndex = 5; LogFrame.Parent = ConsoleFrame

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder; logLayout.Padding = UDim.new(0,2); logLayout.Parent = LogFrame

local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1,-10,0,30); InputFrame.Position = UDim2.new(0,5,1,-35)
InputFrame.BackgroundColor3 = THEMES.default.input; InputFrame.BackgroundTransparency = 0
InputFrame.BorderSizePixel = 0; InputFrame.ZIndex = 2; InputFrame.Parent = ConsoleFrame
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0,4)

local CommandBox = Instance.new("TextBox")
CommandBox.Size = UDim2.new(1,-10,1,-6); CommandBox.Position = UDim2.new(0,5,0,3)
CommandBox.BackgroundTransparency = 1; CommandBox.Text = ""; CommandBox.PlaceholderText = "Enter command or Lua code..."
CommandBox.PlaceholderColor3 = Color3.fromRGB(100,100,100); CommandBox.TextColor3 = THEMES.default.accent
CommandBox.Font = CONFIG.Font; CommandBox.TextSize = 16; CommandBox.TextXAlignment = Enum.TextXAlignment.Left
CommandBox.ClearTextOnFocus = false; CommandBox.ZIndex = 3; CommandBox.Parent = InputFrame

local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.new(0,16,0,16); ResizeHandle.Position = UDim2.new(1,-16,1,-16)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(50,50,50); ResizeHandle.Text = "◢"
ResizeHandle.TextColor3 = Color3.fromRGB(150,150,150); ResizeHandle.Font = CONFIG.Font
ResizeHandle.TextSize = 12; ResizeHandle.BorderSizePixel = 0; ResizeHandle.ZIndex = 5; ResizeHandle.Parent = ConsoleFrame
Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0,4)

local function log(text, colorType, force)
    if not force then
        local pass = true
        if colorType == "Error" and not showError then pass = false end
        if colorType == "Info" and not showWarn then pass = false end
        if colorType == "Success" and not showSuccess then pass = false end
        if colorType == "Echo" and not showEcho then pass = false end
        if (not colorType or colorType == "Default" or colorType == "Output") and not showPrint then pass = false end
        if not pass then return end
    end

    local color = COLORS[colorType] or COLORS.Default
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-5,0,18); label.BackgroundTransparency = 1
    label.Text = "> " .. tostring(text); label.TextColor3 = color
    label.Font = CONFIG.Font; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6; label.Parent = LogFrame

    task.defer(function()
        if not label.Parent then return end
        local h = logLayout.AbsoluteContentSize.Y + 10
        LogFrame.CanvasSize = UDim2.new(0,0,0, h)
        LogFrame.CanvasPosition = Vector2.new(0, math.max(0, h - LogFrame.AbsoluteWindowSize.Y))
    end)
end

local function getSystemLogData(mt)
    if mt == Enum.MessageType.MessageError then return "[ERROR]", COLORS.Error, "Error"
    elseif mt == Enum.MessageType.MessageWarning then return "[WARN]", COLORS.Info, "Info"
    elseif mt == Enum.MessageType.MessageInfo then return "[INFO]", COLORS.Output, "Output"
    else return "[OUTPUT]", COLORS.Output, "Output" end
end

if logConnection then logConnection:Disconnect() end
logConnection = LogService.MessageOut:Connect(function(message, messageType)
    if not ConsoleFrame or not ConsoleFrame.Parent then if logConnection then logConnection:Disconnect() end; return end
    local prefix, color, cType = getSystemLogData(messageType)
    local pass = true
    if cType == "Error" and not showError then pass = false end
    if cType == "Info" and not showWarn then pass = false end
    if (cType == "Output" or cType == "Default") and not showPrint then pass = false end
    if not pass then return end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-5,0,18); label.BackgroundTransparency = 1
    label.Text = string.format("%s %s", prefix, tostring(message))
    label.TextColor3 = color; label.Font = CONFIG.Font; label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 6; label.Parent = LogFrame

    task.defer(function()
        if not label.Parent then return end
        local h = logLayout.AbsoluteContentSize.Y + 10
        LogFrame.CanvasSize = UDim2.new(0,0,0, h)
        LogFrame.CanvasPosition = Vector2.new(0, math.max(0, h - LogFrame.AbsoluteWindowSize.Y))
    end)
end)

local function executeLua(code)
    if type(code) ~= "string" or code:match("^%s*$") then return end
    local fn, err = loadstring(code)
    if not fn then log("Lua compile error: " .. tostring(err), "Error"); return end
    local ok, e = pcall(fn)
    if not ok then log("Lua runtime error: " .. tostring(e), "Error") end
end

local function getChar()
    local char = LocalPlayer.Character; if not char then return end
    return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local function applyFallback()
    local t = THEMES[currentTheme] or THEMES.default
    local function setBtn(btn, imgId, txt)
        if not btn then return end
        local txtLbl = btn:FindFirstChild("FallbackText")
        if useFallbackText then
            btn.Image = ""
            if not txtLbl then
                txtLbl = Instance.new("TextLabel")
                txtLbl.Name = "FallbackText"; txtLbl.Size = UDim2.new(1,0,1,0); txtLbl.BackgroundTransparency = 1
                txtLbl.TextColor3 = Color3.fromRGB(255,255,255); txtLbl.Font = Enum.Font.Code; txtLbl.TextSize = 14
                txtLbl.ZIndex = btn.ZIndex + 1; txtLbl.Parent = btn
            end
            txtLbl.Text = txt; btn.BackgroundColor3 = t.input; btn.BackgroundTransparency = 0.5
        else
            btn.Image = getIcon(imgId)
            if txtLbl then txtLbl.Text = "" end
            btn.BackgroundTransparency = 1
        end
    end
    setBtn(Title, 54479712, ">_"); setBtn(ExtraIcon, 2484276650, "S"); setBtn(SettingsBtn, 9405931596, "S")
    setBtn(WorkshopBtn, 11395780614, "W"); setBtn(CloseBtn, 111716979356360, "x"); setBtn(BackBtn, 8674072445, "<")
    setBtn(WorkshopBackBtn, 8674072445, "<"); setBtn(SettingsTitle, 9405931596, "S")
    setBtn(filterPrintBtn, 15000633149, "P"); setBtn(filterWarnBtn, 18797417835, "W")
    setBtn(filterErrorBtn, 8511577150, "E"); setBtn(filterSuccessBtn, 108191615793694, "S"); setBtn(filterEchoBtn, 124871982298256, "E")
end

local loadBuiltinLib = function(libId)
    if libId == "iconloader" then
        local cache = {}
        local function fetchAll(callback)
            local ICON_IDS = {54479712, 2484276650, 9405931596, 11395780614, 111716979356360, 8674072445, 15000633149, 18797417835, 8511577150, 108191615793694, 124871982298256}
            local ids = {}; for _, id in ipairs(ICON_IDS) do table.insert(ids, tostring(id)) end
            local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. table.concat(ids, ",") .. "&size=150x150&format=Png"
            task.spawn(function()
                local ok, res = pcall(game.HttpGet, game, url)
                if not ok or not res then callback({}); return end
                local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
                if not ok2 or not data or not data.data then callback({}); return end
                local map = {}; for i, entry in ipairs(data.data) do if entry.imageUrl then map[ids[i]] = entry.imageUrl end end
                callback(map)
            end)
        end
        local function get(id) return cache[tostring(id)] end
        local function applyTo(button, id, fallbackText)
            if not button then return end
            local url = get(id)
            if url then
                button.Image = url; local lbl = button:FindFirstChild("FallbackText"); if lbl then lbl.Text = "" end
                button.BackgroundTransparency = 1
            else
                button.Image = ""; local lbl = button:FindFirstChild("FallbackText")
                if not lbl then
                    lbl = Instance.new("TextLabel"); lbl.Name = "FallbackText"; lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.Code
                    lbl.TextSize = 14; lbl.ZIndex = button.ZIndex + 1; lbl.Parent = button
                end
                lbl.Text = fallbackText or "?"; button.BackgroundTransparency = 0.5
            end
        end
        local function init()
            fetchAll(function(map)
                cache = map; useFallbackText = (#map == 0); if useFallbackText then applyFallback() end
            end)
        end
        return { init = init, get = get, applyTo = applyTo }
    end

    if libId == "adaptive" then
        local function init()
            local isPhone = UIS.TouchEnabled and not UIS.KeyboardEnabled
            if isPhone then ConsoleFrame.Size = UDim2.new(1, -20, 1, -40); ConsoleFrame.Position = UDim2.new(0, 10, 0, 30) end
            currentDevice = isPhone and "Phone" or "PC"
        end
        return { init = init }
    end
    return nil
end

local loadLibrary, unloadLibrary, listLibs

loadLibrary = function(libId)
    libId = tostring(libId or ""):gsub("%.xconr$", ""):match("^%s*(.-)%s*$")
    if libId == "" then return false end
    local norm = normName(libId)
    for existing in pairs(loadedLibs) do if normName(existing) == norm then log("Library already loaded: " .. existing, "Error"); return false end end

    local builtin = loadBuiltinLib(libId)
    if builtin then
        loadedLibs[libId] = { meta = { version = "1.0" }, api = builtin, settings = {} }
        if pendingLibSettings[libId] then for k, v in pairs(pendingLibSettings[libId]) do loadedLibs[libId].settings[k] = v end; pendingLibSettings[libId] = nil end
        if builtin.init then pcall(builtin.init) end
        log("Library loaded: " .. libId .. " (builtin)", "Success", true); return true
    end

    local source = nil
    local customLua = CUSTOM_LIBS_DIR .. "/" .. slugify(libId) .. ".lua"
    if isfile and isfile(customLua) then local ok, raw = pcall(readfile, customLua); if ok and raw then source = raw end end
    if not source then
        local path = "workspace/xcon_libs/" .. libId .. ".xconr"
        if isfile and isfile(path) then local ok, raw = pcall(readfile, path); if ok and raw then source = raw end end
    end
    if not source then
        local url = GITHUB_LIBS .. libId .. ".xconr"
        local ok, raw = pcall(game.HttpGet, game, url, true)
        if ok and raw and not raw:find("404: Not Found") and not raw:find("<!DOCTYPE") then source = raw end
    end

    if not source then log("Library not found: " .. libId, "Error"); return false end
    local fn, err = loadstring(source, "=lib_" .. libId)
    if not fn then log("Library compile error: " .. libId .. " — " .. tostring(err), "Error"); return false end
    local ok2, lib = pcall(fn)
    if not ok2 then log("Library runtime error: " .. libId .. " — " .. tostring(lib), "Error"); return false end

    loadedLibs[libId] = { meta = (type(lib) == "table" and lib) or { version = "1.0" }, api = lib, settings = {} }
    if pendingLibSettings[libId] then for k, v in pairs(pendingLibSettings[libId]) do loadedLibs[libId].settings[k] = v end; pendingLibSettings[libId] = nil end
    for i = #backupLibs, 1, -1 do if backupLibs[i] == libId then table.remove(backupLibs, i) end end
    log("Library loaded: " .. libId, "Success"); return true
end

unloadLibrary = function(libId, skipBackup)
    libId = tostring(libId or ""):gsub("%.xconr$", ""):match("^%s*(.-)%s*$")
    for _, l in ipairs(WORKSHOP_LIBS) do if l.libId == libId and l.isSystem then log("System library cannot be unloaded: " .. l.name, "Error"); return false end end
    local data = loadedLibs[libId]
    if not data then log("Library not loaded: " .. libId, "Error"); return false end
    if data.meta and type(data.meta.onUnload) == "function" then pcall(data.meta.onUnload, data.api) end
    loadedLibs[libId] = nil
    if not skipBackup then
        local found = false; for _, n in ipairs(backupLibs) do if n == libId then found = true; break end end
        if not found then table.insert(backupLibs, libId) end
    end
    log("Library unloaded: " .. libId, "Info"); return true
end

listLibs = function()
    local lines = {}
    for id, data in pairs(loadedLibs) do
        local v = (data.meta and data.meta.version) or "?"
        table.insert(lines, "  " .. id .. " v" .. tostring(v))
    end
    if #lines == 0 then return end
    log("Loaded libraries:", "Info"); for _, line in ipairs(lines) do log(line, "Default") end
end

local function autoLoadLibsFromGitHub()
    for _, id in ipairs(LIB_LIST) do
        task.spawn(function()
            local url = GITHUB_LIBS .. id .. ".xconr"
            local ok, src = pcall(game.HttpGet, game, url, true)
            if not ok or not src then log("Lib fetch failed: " .. id, "Error"); return end
            if src:find("404: Not Found") or src:find("<!DOCTYPE") then log("Lib not found on GitHub: " .. id, "Error"); return end
            local fn, err = loadstring(src, "=lib_" .. id)
            if not fn then log("Lib compile error: " .. id .. " — " .. tostring(err), "Error"); return end
            local ok2, lib = pcall(fn)
            if not ok2 then log("Lib runtime error: " .. id .. " — " .. tostring(lib), "Error"); return end
            loadedLibs[id] = { meta = (type(lib) == "table" and lib) or { version = "1.0" }, api = lib, settings = {} }
            log("Library loaded: " .. id, "Success", true)
        end)
    end
end

local function readCustomList(dir, typ)
    ensureDir(dir)
    local out = {}
    if not (listfiles and isfile) then return out end
    local ok, files = pcall(listfiles, dir)
    if not ok or not files then return out end
    for _, f in ipairs(files) do
        if f:match("%.json$") then
            local ok2, raw = pcall(readfile, f)
            if ok2 and raw then
                local ok3, data = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok3 and data and data.name then
                    data.isCustom = true; data.type = typ; data._jsonPath = f; data._luaPath = f:gsub("%.json$", ".lua")
                    table.insert(out, data)
                end
            end
        end
    end
    return out
end

local function readCustomPlugins() return readCustomList(CUSTOM_PLUGINS_DIR, "plugin") end
local function readCustomLibs()    return readCustomList(CUSTOM_LIBS_DIR, "lib") end

local function saveCustomItem(typ, data, code, overwrite)
    local dir = (typ == "plugin") and CUSTOM_PLUGINS_DIR or CUSTOM_LIBS_DIR
    ensureDir(dir)
    local slug = slugify(data.name)
    if slug == "" then return false, "Empty name" end
    for _, item in ipairs(readCustomList(dir, typ)) do
        if normName(item.name) == normName(data.name) and not overwrite then log("Custom " .. typ .. " with this name already exists: " .. item.name, "Error"); return false end
    end
    if typ == "plugin" then
        for _, p in ipairs(WORKSHOP_PLUGINS) do if normName(p.name) == normName(data.name) then log("A built-in plugin with this name already exists: " .. p.name, "Error"); return false end end
    else
        for _, l in ipairs(WORKSHOP_LIBS) do if normName(l.name) == normName(data.name) then log("A built-in library with this name already exists: " .. l.name, "Error"); return false end end
    end
    local jsonPath = dir .. "/" .. slug .. ".json"; local luaPath = dir .. "/" .. slug .. ".lua"
    data.isCustom = true; data.type = typ
    if typ == "lib" then data.libId = slug end
    local ok1 = pcall(writefile, jsonPath, HttpService:JSONEncode(data))
    local ok2 = pcall(writefile, luaPath, code or "")
    if ok1 and ok2 then log("Custom " .. typ .. " saved: " .. data.name, "Success"); return true end
    log("Failed to save custom " .. typ, "Error"); return false
end

local function deleteCustomItem(typ, name)
    local dir = (typ == "plugin") and CUSTOM_PLUGINS_DIR or CUSTOM_LIBS_DIR
    local slug = slugify(name)
    local jsonPath = dir .. "/" .. slug .. ".json"; local luaPath = dir .. "/" .. slug .. ".lua"
    if isfile and isfile(jsonPath) then pcall(delfile, jsonPath) end
    if isfile and isfile(luaPath) then pcall(delfile, luaPath) end
    log("Custom " .. typ .. " deleted: " .. name, "Info")
end
-- ============ THEME APPLY ============
applyThemeToSettings = function(t)
    if not SettingsFrame then return end
    for _, obj in ipairs(SettingsFrame:GetDescendants()) do
        if obj:IsA("TextLabel") then obj.TextColor3 = t.text
        elseif obj:IsA("TextButton") then if obj ~= HideBtn then obj.TextColor3 = t.text; obj.BackgroundColor3 = t.input end
        elseif obj:IsA("TextBox") then obj.TextColor3 = t.text; obj.BackgroundColor3 = t.input end
    end
    for n, btn in pairs(themeButtons) do
        if currentTheme == n then btn.BackgroundColor3 = t.accent; btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else btn.BackgroundColor3 = t.input; btn.TextColor3 = t.text end
    end
    SettingsFrame.BackgroundColor3 = t.background; SettingsFrame.BackgroundTransparency = 0
    if WorkshopFrame then
        WorkshopFrame.BackgroundColor3 = t.background
        for _, obj in ipairs(WorkshopFrame:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                if obj.BackgroundColor3 ~= Color3.fromRGB(255,255,255) then obj.BackgroundColor3 = t.input end
            end
        end
    end
    applyFallback()
end

local function applyTheme(name)
    local t = THEMES[name]; if not t then return end
    currentTheme = name
    ConsoleFrame.BackgroundColor3 = t.background; Header.BackgroundColor3 = t.header; InputFrame.BackgroundColor3 = t.input
    LogFrame.BackgroundColor3 = t.log; LogBg.BackgroundColor3 = t.log; CommandBox.TextColor3 = t.accent
    stroke.Color = t.stroke; LogFrame.ScrollBarImageColor3 = t.accent
    SettingsFrame.BackgroundColor3 = t.background; SettingsFrame.BackgroundTransparency = 0
    if name == SECRET then
        bgImage.Image = getThumb("5456915026"); bgImage.Visible = true
        ConsoleFrame.BackgroundTransparency = 0.9; LogBg.BackgroundTransparency = 0.55
        InputFrame.BackgroundTransparency = 0.45; Header.BackgroundTransparency = 0.45
    elseif name == "win10" then
        bgImage.Image = getThumb(WIN10_THEME_ID); bgImage.Visible = true
        ConsoleFrame.BackgroundTransparency = 0.85; LogBg.BackgroundTransparency = 0.5
        InputFrame.BackgroundTransparency = 0.4; Header.BackgroundTransparency = 0.4
    elseif name == "custom" then
        bgImage.Image = getThumb(customBgId); bgImage.Visible = true
        ConsoleFrame.BackgroundTransparency = 0.85; LogBg.BackgroundTransparency = 0.5
        InputFrame.BackgroundTransparency = 0.4; Header.BackgroundTransparency = 0.4
    else
        bgImage.Visible = false; ConsoleFrame.BackgroundTransparency = 0; LogBg.BackgroundTransparency = 0
        InputFrame.BackgroundTransparency = 0; Header.BackgroundTransparency = 0
    end
    SettingsFrame.BackgroundTransparency = 0; applyThemeToSettings(t)
end

-- ============ SETTINGS FRAME ============
SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1,0,1,0); SettingsFrame.Position = UDim2.new(0,0,0,0)
SettingsFrame.BackgroundColor3 = THEMES.default.background; SettingsFrame.BackgroundTransparency = 0; SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false; SettingsFrame.ZIndex = 10; SettingsFrame.Parent = ConsoleFrame
Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0,6)

local function makeLabel(parent, text, y, size)
    local l = Instance.new("TextLabel")
    l.Size=UDim2.new(1,-20,0,size or 20); l.Position=UDim2.new(0,10,0,y)
    l.BackgroundTransparency=1; l.Text=text; l.TextColor3=THEMES.default.text
    l.Font=CONFIG.Font; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=11; l.Parent=parent
    return l
end
local function makeButton(parent, text, x, y, w, h, cb)
    local b = Instance.new("TextButton")
    b.Size=UDim2.new(0,w,0,h); b.Position=UDim2.new(0,x,0,y); b.BackgroundColor3=THEMES.default.input
    b.Text=text; b.TextColor3=THEMES.default.text; b.Font=CONFIG.Font; b.TextSize=13; b.BorderSizePixel=0; b.ZIndex=12; b.Parent=parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4); b.MouseButton1Click:Connect(cb); return b
end

SettingsScroll = Instance.new("ScrollingFrame")
SettingsScroll.Size=UDim2.new(1,-10,1,-50); SettingsScroll.Position=UDim2.new(0,5,0,40)
SettingsScroll.BackgroundTransparency=1; SettingsScroll.BorderSizePixel=0; SettingsScroll.ScrollBarThickness=4
SettingsScroll.CanvasSize=UDim2.new(0,0,0,0); SettingsScroll.ZIndex=11; SettingsScroll.Parent=SettingsFrame
local settingsLayout = Instance.new("UIListLayout")
settingsLayout.Padding=UDim.new(0,6); settingsLayout.SortOrder=Enum.SortOrder.LayoutOrder; settingsLayout.Parent=SettingsScroll

local function addSettingRow(widget)
    widget.LayoutOrder = #SettingsScroll:GetChildren(); widget.Parent = SettingsScroll
    SettingsScroll.CanvasSize = UDim2.new(0,0,0, settingsLayout.AbsoluteContentSize.Y + 20)
end

SettingsTitle = Instance.new("ImageButton")
SettingsTitle.Size = UDim2.new(0,26,0,26); SettingsTitle.Position = UDim2.new(0,8,0,7)
SettingsTitle.BackgroundTransparency = 1; SettingsTitle.Image = getIcon(9405931596); SettingsTitle.ScaleType = Enum.ScaleType.Fit
SettingsTitle.ZIndex = 12; SettingsTitle.Parent = SettingsFrame

BackBtn = Instance.new("ImageButton")
BackBtn.Size = UDim2.new(0,40,0,24); BackBtn.Position = UDim2.new(1,-52,0,8)
BackBtn.BackgroundTransparency = 1; BackBtn.Image = getIcon(8674072445); BackBtn.ScaleType = Enum.ScaleType.Fit
BackBtn.ZIndex = 12; BackBtn.Parent = SettingsFrame

local function openSettings()
    SettingsFrame.Visible = true; SettingsFrame.BackgroundTransparency = 1; SettingsFrame.Position = UDim2.new(0,0,0,20)
    HideBtn.Visible = false; CloseBtn.Visible = false; ExtraIcon.Visible = false; SettingsBtn.Visible = false; WorkshopBtn.Visible = false
    TweenService:Create(SettingsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { BackgroundTransparency = 0, Position = UDim2.new(0,0,0,0) }):Play()
end
local function closeSettings()
    local tw = TweenService:Create(SettingsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 1, Position = UDim2.new(0,0,0,20) })
    tw:Play(); tw.Completed:Once(function()
        SettingsFrame.Visible = false; HideBtn.Visible = true; CloseBtn.Visible = true
        ExtraIcon.Visible = true; SettingsBtn.Visible = true; WorkshopBtn.Visible = true
    end)
end
BackBtn.MouseButton1Click:Connect(closeSettings)

-- ============ WORKSHOP UI ============
local WorkshopFrame = Instance.new("Frame")
WorkshopFrame.Size = UDim2.new(1,0,1,0); WorkshopFrame.Position = UDim2.new(0,0,0,0)
WorkshopFrame.BackgroundColor3 = THEMES.default.background; WorkshopFrame.BackgroundTransparency = 0; WorkshopFrame.BorderSizePixel = 0
WorkshopFrame.Visible = false; WorkshopFrame.ZIndex = 15; WorkshopFrame.Parent = ConsoleFrame
Instance.new("UICorner", WorkshopFrame).CornerRadius = UDim.new(0,6)

local WorkshopTitle = Instance.new("TextLabel")
WorkshopTitle.Size = UDim2.new(1,-100,0,30); WorkshopTitle.Position = UDim2.new(0,10,0,5)
WorkshopTitle.BackgroundTransparency = 1; WorkshopTitle.Text = "WORKSHOP"
WorkshopTitle.TextColor3 = THEMES.default.text; WorkshopTitle.Font = CONFIG.Font
WorkshopTitle.TextSize = 18; WorkshopTitle.TextXAlignment = Enum.TextXAlignment.Left; WorkshopTitle.ZIndex = 16; WorkshopTitle.Parent = WorkshopFrame

WorkshopBackBtn = Instance.new("ImageButton")
WorkshopBackBtn.Size = UDim2.new(0,40,0,24); WorkshopBackBtn.Position = UDim2.new(1,-52,0,5)
WorkshopBackBtn.BackgroundTransparency = 1; WorkshopBackBtn.Image = getIcon(8674072445); WorkshopBackBtn.ScaleType = Enum.ScaleType.Fit
WorkshopBackBtn.ZIndex = 16; WorkshopBackBtn.Parent = WorkshopFrame

local WorkshopTabBar = Instance.new("Frame")
WorkshopTabBar.Size = UDim2.new(1,-20,0,24); WorkshopTabBar.Position = UDim2.new(0,10,0,35)
WorkshopTabBar.BackgroundTransparency = 1; WorkshopTabBar.ZIndex = 16; WorkshopTabBar.Parent = WorkshopFrame

local WorkshopTabMain = Instance.new("TextButton")
WorkshopTabMain.Size = UDim2.new(0,90,0,24); WorkshopTabMain.Position = UDim2.new(0,0,0,0); WorkshopTabMain.BackgroundColor3 = THEMES.default.accent
WorkshopTabMain.Text = "Plugins"; WorkshopTabMain.TextColor3 = Color3.fromRGB(0,0,0); WorkshopTabMain.Font = CONFIG.Font; WorkshopTabMain.TextSize = 13
WorkshopTabMain.BorderSizePixel = 0; WorkshopTabMain.ZIndex = 17; WorkshopTabMain.Parent = WorkshopTabBar
Instance.new("UICorner", WorkshopTabMain).CornerRadius = UDim.new(0,4)

local WorkshopTabPlugins = Instance.new("TextButton")
WorkshopTabPlugins.Size = UDim2.new(0,90,0,24); WorkshopTabPlugins.Position = UDim2.new(0,95,0,0); WorkshopTabPlugins.BackgroundColor3 = THEMES.default.input
WorkshopTabPlugins.Text = "Downloaded"; WorkshopTabPlugins.TextColor3 = THEMES.default.text; WorkshopTabPlugins.Font = CONFIG.Font; WorkshopTabPlugins.TextSize = 13
WorkshopTabPlugins.BorderSizePixel = 0; WorkshopTabPlugins.ZIndex = 17; WorkshopTabPlugins.Parent = WorkshopTabBar
Instance.new("UICorner", WorkshopTabPlugins).CornerRadius = UDim.new(0,4)

local WorkshopTabLibs = Instance.new("TextButton")
WorkshopTabLibs.Size = UDim2.new(0,90,0,24); WorkshopTabLibs.Position = UDim2.new(0,190,0,0); WorkshopTabLibs.BackgroundColor3 = THEMES.default.input
WorkshopTabLibs.Text = "Libraries"; WorkshopTabLibs.TextColor3 = THEMES.default.text; WorkshopTabLibs.Font = CONFIG.Font; WorkshopTabLibs.TextSize = 13
WorkshopTabLibs.BorderSizePixel = 0; WorkshopTabLibs.ZIndex = 17; WorkshopTabLibs.Parent = WorkshopTabBar
Instance.new("UICorner", WorkshopTabLibs).CornerRadius = UDim.new(0,4)

local WorkshopScroll = Instance.new("ScrollingFrame")
WorkshopScroll.Size = UDim2.new(1,-20,1,-65); WorkshopScroll.Position = UDim2.new(0,10,0,62)
WorkshopScroll.BackgroundTransparency = 1; WorkshopScroll.BorderSizePixel = 0; WorkshopScroll.ScrollBarThickness = 4
WorkshopScroll.CanvasSize = UDim2.new(0,0,0,0); WorkshopScroll.ZIndex = 16; WorkshopScroll.Parent = WorkshopFrame
local WorkshopListLayout = Instance.new("UIListLayout")
WorkshopListLayout.SortOrder = Enum.SortOrder.LayoutOrder; WorkshopListLayout.Padding = UDim.new(0,5); WorkshopListLayout.Parent = WorkshopScroll

local WorkshopPluginsScroll = Instance.new("ScrollingFrame")
WorkshopPluginsScroll.Size = UDim2.new(1,-20,1,-65); WorkshopPluginsScroll.Position = UDim2.new(0,10,0,62)
WorkshopPluginsScroll.BackgroundTransparency = 1; WorkshopPluginsScroll.BorderSizePixel = 0; WorkshopPluginsScroll.ScrollBarThickness = 4
WorkshopPluginsScroll.CanvasSize = UDim2.new(0,0,0,0); WorkshopPluginsScroll.ZIndex = 16; WorkshopPluginsScroll.Visible = false; WorkshopPluginsScroll.Parent = WorkshopFrame
local WorkshopPluginsLayout = Instance.new("UIListLayout")
WorkshopPluginsLayout.SortOrder = Enum.SortOrder.LayoutOrder; WorkshopPluginsLayout.Padding = UDim.new(0,5); WorkshopPluginsLayout.Parent = WorkshopPluginsScroll

local WorkshopLibsScroll = Instance.new("ScrollingFrame")
WorkshopLibsScroll.Size = UDim2.new(1,-20,1,-65); WorkshopLibsScroll.Position = UDim2.new(0,10,0,62)
WorkshopLibsScroll.BackgroundTransparency = 1; WorkshopLibsScroll.BorderSizePixel = 0; WorkshopLibsScroll.ScrollBarThickness = 4
WorkshopLibsScroll.CanvasSize = UDim2.new(0,0,0,0); WorkshopLibsScroll.ZIndex = 16; WorkshopLibsScroll.Visible = false; WorkshopLibsScroll.Parent = WorkshopFrame
local WorkshopLibsLayout = Instance.new("UIListLayout")
WorkshopLibsLayout.SortOrder = Enum.SortOrder.LayoutOrder; WorkshopLibsLayout.Padding = UDim.new(0,5); WorkshopLibsLayout.Parent = WorkshopLibsScroll

local refreshPluginsTab, refreshLibsTab

-- ============ UI BUILDER FOR WORKSHOP CARDS ============
local function buildWorkshopCard(parent, data, isLib)
    local item = Instance.new("Frame")
    item.Size = UDim2.new(1,-10,0,80); item.BackgroundColor3 = THEMES.default.input
    item.BackgroundTransparency = 0.5; item.BorderSizePixel = 0; item.ZIndex = 17; item.Parent = parent
    Instance.new("UICorner", item).CornerRadius = UDim.new(0,6)

    local img = Instance.new("ImageButton")
    img.Size = UDim2.new(0,60,0,60); img.Position = UDim2.new(0,10,0,10)
    img.BackgroundColor3 = Color3.fromRGB(30,30,30); img.BorderSizePixel = 0; img.ZIndex = 18; img.Parent = item
    Instance.new("UICorner", img).CornerRadius = UDim.new(0,4)

    local imgLbl = Instance.new("TextLabel")
    imgLbl.Name = "FallbackText"; imgLbl.Size = UDim2.new(1,0,1,0); imgLbl.BackgroundTransparency = 1
    imgLbl.Text = ""; imgLbl.TextColor3 = Color3.fromRGB(255,100,100); imgLbl.Font = Enum.Font.Code; imgLbl.TextSize = 12; imgLbl.ZIndex = 19; imgLbl.Parent = img

    if useFallbackText then
        img.Image = ""; imgLbl.Text = (data.name or "?"):sub(1,2)
    else
        img.Image = getIcon(data.imageId)
    end

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,-150,0,20); nameLbl.Position = UDim2.new(0,80,0,10)
    nameLbl.BackgroundTransparency = 1; nameLbl.Text = data.name; nameLbl.TextColor3 = THEMES.default.text
    nameLbl.Font = Enum.Font.Code; nameLbl.TextSize = 16; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 18; nameLbl.Parent = item

    local badges = {}
    if data.isSystem then table.insert(badges, "System") end
    if data.isVerified then table.insert(badges, "Verified ✓") end
    if data.isCustom then table.insert(badges, "Custom") end
    local authorText = data.author
    if #badges > 0 then authorText = "[" .. table.concat(badges, " • ") .. "] " .. authorText end

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1,-150,0,40); descLbl.Position = UDim2.new(0,80,0,30)
    descLbl.BackgroundTransparency = 1; descLbl.Text = (data.desc or "") .. " | by " .. authorText
    descLbl.TextColor3 = Color3.fromRGB(180,180,180); descLbl.Font = Enum.Font.Code
    descLbl.TextSize = 12; descLbl.TextWrapped = true; descLbl.TextXAlignment = Enum.TextXAlignment.Left; descLbl.ZIndex = 18; descLbl.Parent = item

    -- Кнопка Настроек (Шестеренка)
    local setBtn = Instance.new("ImageButton")
    setBtn.Size = UDim2.new(0,24,0,24); setBtn.Position = UDim2.new(1,-90,0,10)
    setBtn.BackgroundTransparency = 1; setBtn.ScaleType = Enum.ScaleType.Fit; setBtn.ZIndex = 18; setBtn.Parent = item
    local setLbl = Instance.new("TextLabel")
    setLbl.Name = "FallbackText"; setLbl.Size = UDim2.new(1,0,1,0); setLbl.BackgroundTransparency = 1
    setLbl.Text = ""; setLbl.TextColor3 = Color3.new(1,1,1); setLbl.Font = Enum.Font.Code; setLbl.TextSize = 12; setLbl.ZIndex = 19; setLbl.Parent = setBtn
    if useFallbackText then setBtn.Image = ""; setLbl.Text = "S"; setBtn.BackgroundTransparency = 0.5; setBtn.BackgroundColor3 = THEMES.default.input
    else setBtn.Image = getIcon(6953992694) end

    setBtn.MouseButton1Click:Connect(function()
        local existing = item:FindFirstChild("SettingsPanel")
        if existing then existing:Destroy(); item.Size = UDim2.new(1,-10,0,80); return end
        item.Size = UDim2.new(1,-10,0,200)
        local panel = Instance.new("Frame")
        panel.Name = "SettingsPanel"; panel.Size = UDim2.new(1,-20,0,110); panel.Position = UDim2.new(0,10,0,70)
        panel.BackgroundColor3 = Color3.fromRGB(20,20,20); panel.BackgroundTransparency = 0.25; panel.BorderSizePixel = 0; panel.ZIndex = 21; panel.Parent = item
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0,4)

        local helpText = "No settings."
        if data.name == "CustomCommand" then helpText = "Use this panel to create commands."
        elseif data.name == "ItemGiver" then helpText = "Commands:\npl.itemgiver\npl.itemgiver.search <text>\npl.itemgiver.give <id>"
        elseif data.name == "MacroRecorder" then helpText = "Commands:\npl.macro.start <name>\npl.macro.stop\npl.macro.play <name>\npl.macro.timer.start\npl.macro.timer.stop"
        elseif data.name == "AutoExecutor" then helpText = "Commands:\npl.auto.add <name> <cond> <code>\npl.auto.remove <name>\npl.auto.list"
        elseif data.name == "PlayerTracker" then helpText = "Commands:\npl.tracker.show\npl.tracker.hide\npl.tracker.clear\npl.tracker.filter <name>"
        elseif data.name == "KeybindManager" then helpText = "Commands:\npl.keybind.show\npl.keybind.hide"
        else helpText = "Settings for " .. data.name end

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,-20,0,100); lbl.Position = UDim2.new(0,10,0,5)
        lbl.BackgroundTransparency = 1; lbl.Text = helpText; lbl.TextColor3 = Color3.fromRGB(200,200,200)
        lbl.Font = Enum.Font.Code; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.TextWrapped = true; lbl.ZIndex = 22; lbl.Parent = panel
    end)

    -- Кнопка Play/Stop (Start)
    local stBtn = Instance.new("ImageButton")
    stBtn.Size = UDim2.new(0,24,0,24); stBtn.Position = UDim2.new(1,-60,0,10)
    stBtn.BackgroundTransparency = 1; stBtn.ScaleType = Enum.ScaleType.Fit; stBtn.ZIndex = 18; stBtn.Parent = item
    local stLbl = Instance.new("TextLabel")
    stLbl.Name = "FallbackText"; stLbl.Size = UDim2.new(1,0,1,0); stLbl.BackgroundTransparency = 1
    stLbl.Text = ""; stLbl.TextColor3 = Color3.new(1,1,1); stLbl.Font = Enum.Font.Code; stLbl.TextSize = 12; stLbl.ZIndex = 19; stLbl.Parent = stBtn

    local loadName = isLib and data.libId or data.name
    
    local function updateBtnState()
        local isLoaded = isLib and (loadedLibs[loadName] ~= nil) or (not isLib and loadedPlugins[data.name] ~= nil)
        if isLoaded then
            stBtn.Image = getIcon(14219414401) -- Stop/Пауза
            if useFallbackText then stBtn.Image = ""; stLbl.Text = "PA"; stBtn.BackgroundTransparency = 0.5; stBtn.BackgroundColor3 = THEMES.default.input end
        else
            stBtn.Image = getIcon(8517323802) -- Start/Плей
            if useFallbackText then stBtn.Image = ""; stLbl.Text = "PL"; stBtn.BackgroundTransparency = 0.5; stBtn.BackgroundColor3 = THEMES.default.input end
        end
    end
    updateBtnState()

    stBtn.MouseButton1Click:Connect(function()
        local isLoaded = isLib and (loadedLibs[loadName] ~= nil) or (not isLib and loadedPlugins[data.name] ~= nil)
        if isLoaded then
            if isLib then unloadLibrary(loadName) else unloadPlugin(data.name) end
        else
            if isLib then loadLibrary(loadName) else loadPlugin(data.name) end
        end
        if saveConfig then pcall(saveConfig) end
        updateBtnState()
        if isLib and refreshLibsTab then refreshLibsTab() end
        if not isLib and refreshPluginsTab then refreshPluginsTab() end
    end)

    if data.isCustom then
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0,40,0,20); delBtn.Position = UDim2.new(1,-50,1,-24)
        delBtn.BackgroundColor3 = Color3.fromRGB(200,50,50); delBtn.TextColor3 = Color3.fromRGB(255,255,255)
        delBtn.Text = "Del"; delBtn.Font = Enum.Font.Code; delBtn.TextSize = 11; delBtn.BorderSizePixel = 0; delBtn.ZIndex = 19; delBtn.Parent = item
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,3)
        delBtn.MouseButton1Click:Connect(function()
            deleteCustomItem(isLib and "lib" or "plugin", data.name)
            if saveConfig then pcall(saveConfig) end
            if isLib then refreshLibsTab() else refreshWorkshop() end
        end)
    end
    return item
end

-- ============ REFRESH LOGIC ============
local function refreshWorkshop()
    for _, child in ipairs(WorkshopScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local allPlugins = {}
    for _, p in ipairs(WORKSHOP_PLUGINS) do table.insert(allPlugins, p) end
    for _, p in ipairs(readCustomPlugins()) do table.insert(allPlugins, p) end
    
    table.sort(allPlugins, function(a, b)
        if a.isSystem and not b.isSystem then return true end
        if not a.isSystem and b.isSystem then return false end
        return a.name < b.name
    end)

    for _, p in ipairs(allPlugins) do buildWorkshopCard(WorkshopScroll, p, false) end
    WorkshopScroll.CanvasSize = UDim2.new(0,0,0, WorkshopListLayout.AbsoluteContentSize.Y + 10)
end

refreshPluginsTab = function()
    for _, child in ipairs(WorkshopPluginsScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local downloaded = {}
    if listfiles then
        local ok, files = pcall(listfiles, "workspace")
        if ok and files then for _, f in ipairs(files) do
            if f:match("%.xconr$") then local nm = f:match("([^/\\]+)%.xconr$"); if nm then table.insert(downloaded, nm) end end
        end end
    end
    for _, name in ipairs(downloaded) do
        local info
        for _, p in ipairs(WORKSHOP_PLUGINS) do if p.name == name then info = p; break end end
        if not info then for _, p in ipairs(readCustomPlugins()) do if p.name == name then info = p; break end end end
        buildWorkshopCard(WorkshopPluginsScroll, info or {name=name, author="unknown", desc="", isCustom=false}, false)
    end
    WorkshopPluginsScroll.CanvasSize = UDim2.new(0,0,0, WorkshopPluginsLayout.AbsoluteContentSize.Y + 10)
end

refreshLibsTab = function()
    for _, child in ipairs(WorkshopLibsScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local allLibs = {}
    for _, l in ipairs(WORKSHOP_LIBS) do table.insert(allLibs, l) end
    for _, l in ipairs(readCustomLibs()) do table.insert(allLibs, l) end
    
    table.sort(allLibs, function(a, b)
        if a.isSystem and not b.isSystem then return true end
        if not a.isSystem and b.isSystem then return false end
        return a.name < b.name
    end)
    
    for _, l in ipairs(allLibs) do buildWorkshopCard(WorkshopLibsScroll, l, true) end
    WorkshopLibsScroll.CanvasSize = UDim2.new(0,0,0, WorkshopLibsLayout.AbsoluteContentSize.Y + 10)
end

local function switchWorkshopTab(tab)
    WorkshopScroll.Visible = (tab == "main"); WorkshopPluginsScroll.Visible = (tab == "plugins"); WorkshopLibsScroll.Visible = (tab == "libs")
    local function setActive(btn, active)
        btn.BackgroundColor3 = active and THEMES.default.accent or THEMES.default.input
        btn.TextColor3 = active and Color3.fromRGB(0,0,0) or THEMES.default.text
    end
    setActive(WorkshopTabMain, tab == "main"); setActive(WorkshopTabPlugins, tab == "plugins"); setActive(WorkshopTabLibs, tab == "libs")
    if tab == "main" then refreshWorkshop() elseif tab == "plugins" then refreshPluginsTab() elseif tab == "libs" then refreshLibsTab() end
end

WorkshopTabMain.MouseButton1Click:Connect(function() switchWorkshopTab("main") end)
WorkshopTabPlugins.MouseButton1Click:Connect(function() switchWorkshopTab("plugins") end)
WorkshopTabLibs.MouseButton1Click:Connect(function() switchWorkshopTab("libs") end)
WorkshopBackBtn.MouseButton1Click:Connect(function()
    WorkshopFrame.Visible = false; HideBtn.Visible = true; CloseBtn.Visible = true
    ExtraIcon.Visible = true; SettingsBtn.Visible = true; WorkshopBtn.Visible = true
end)
local function openWorkshop()
    WorkshopFrame.Visible = true; HideBtn.Visible = false; CloseBtn.Visible = false
    ExtraIcon.Visible = false; SettingsBtn.Visible = false; WorkshopBtn.Visible = false
    switchWorkshopTab("main")
end
WorkshopBtn.MouseButton1Click:Connect(openWorkshop)

-- ============ SETTINGS UI ============
local themeRow = Instance.new("Frame")
themeRow.Size=UDim2.new(1,-20,0,60); themeRow.BackgroundTransparency=1; themeRow.ZIndex=11
themeLabel = makeLabel(themeRow, "Theme", 0, 18)
local tidx = 0
local themeNames = { default = "Default", winter = "Winter", halloween = "Halloween" }
for _, name in ipairs({"default","winter","halloween"}) do
    local b = makeButton(themeRow, themeNames[name], tidx*110, 22, 100, 26, function()
        applyTheme(name); refreshThemeButtons(); log("Theme set: "..name, "Success"); if saveConfig then pcall(saveConfig) end
    end)
    themeButtons[name] = b; tidx += 1
end
secretBtn = makeButton(themeRow, "Code", tidx*110, 22, 100, 26, function()
    if premiumEnabled then applyTheme(SECRET); refreshThemeButtons(); log("Theme set: Code", "Success"); if saveConfig then pcall(saveConfig) end end
end)
themeButtons[SECRET] = secretBtn; secretBtn.Visible = false
win10Btn = makeButton(themeRow, "Windows 10", (tidx+1)*110, 22, 100, 26, function()
    if premiumEnabled then applyTheme("win10"); refreshThemeButtons(); log("Theme set: Windows 10", "Success"); if saveConfig then pcall(saveConfig) end end
end)
themeButtons["win10"] = win10Btn; win10Btn.Visible = false
addSettingRow(themeRow)

refreshThemeButtons = function()
    local t = THEMES[currentTheme] or THEMES.default
    for n, btn in pairs(themeButtons) do
        if currentTheme == n then btn.BackgroundColor3 = t.accent; btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else btn.BackgroundColor3 = t.input; btn.TextColor3 = t.text end
    end
end
refreshThemeButtons()

local filterRow = Instance.new("Frame")
filterRow.Size = UDim2.new(1,-20,0,95); filterRow.BackgroundTransparency = 1; filterRow.ZIndex = 11
local filterLabel = makeLabel(filterRow, "Console Filter", 0, 18)
local function makeFilterBtn(imgId, x, toggleName)
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 34, 0, 34); btn.Position = UDim2.new(0, x, 0, 36)
    btn.BackgroundTransparency = 1; btn.Image = getIcon(imgId); btn.ScaleType = Enum.ScaleType.Fit; btn.ZIndex = 12; btn.Parent = filterRow
    if toggleName == "print" then btn.ImageColor3 = showPrint and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
    elseif toggleName == "warn" then btn.ImageColor3 = showWarn and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
    elseif toggleName == "error" then btn.ImageColor3 = showError and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
    elseif toggleName == "success" then btn.ImageColor3 = showSuccess and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
    elseif toggleName == "echo" then btn.ImageColor3 = showEcho and Color3.new(1,1,1) or Color3.fromRGB(100,100,100) end
    btn.MouseButton1Click:Connect(function()
        if toggleName == "print" then showPrint = not showPrint; btn.ImageColor3 = showPrint and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
        elseif toggleName == "warn" then showWarn = not showWarn; btn.ImageColor3 = showWarn and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
        elseif toggleName == "error" then showError = not showError; btn.ImageColor3 = showError and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
        elseif toggleName == "success" then showSuccess = not showSuccess; btn.ImageColor3 = showSuccess and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
        elseif toggleName == "echo" then showEcho = not showEcho; btn.ImageColor3 = showEcho and Color3.new(1,1,1) or Color3.fromRGB(100,100,100) end
        if saveConfig then pcall(saveConfig) end
    end)
    return btn
end
filterPrintBtn = makeFilterBtn(15000633149, 10, "print"); filterWarnBtn = makeFilterBtn(18797417835, 52, "warn")
filterErrorBtn = makeFilterBtn(8511577150, 94, "error"); filterSuccessBtn = makeFilterBtn(108191615793694, 136, "success")
filterEchoBtn = makeFilterBtn(124871982298256, 178, "echo"); addSettingRow(filterRow)

bgRow = Instance.new("Frame")
bgRow.Size = UDim2.new(1,-20,0,60); bgRow.BackgroundTransparency=1; bgRow.ZIndex=11; bgRow.Visible = false
bgLabel = makeLabel(bgRow, "Custom Background (Asset ID)", 0, 18)
bgBox = Instance.new("TextBox")
bgBox.Size = UDim2.new(0,200,0,26); bgBox.Position = UDim2.new(0,0,0,22); bgBox.BackgroundColor3 = THEMES.default.input
bgBox.TextColor3 = THEMES.default.text; bgBox.Font = CONFIG.Font; bgBox.TextSize = 13; bgBox.Text = ""; bgBox.PlaceholderText = "rbxassetid://..."
bgBox.ZIndex = 12; bgBox.Parent = bgRow
Instance.new("UICorner", bgBox).CornerRadius = UDim.new(0,4)
bgApplyBtn = makeButton(bgRow, "Apply", 210, 22, 80, 26, function()
    if premiumEnabled and bgBox.Text ~= "" then customBgId = bgBox.Text:match("%d+") or bgBox.Text; applyTheme("custom"); refreshThemeButtons(); log("Custom background applied", "Success"); if saveConfig then pcall(saveConfig) end end
end)
addSettingRow(bgRow)

local cfgRow = Instance.new("Frame")
cfgRow.Size=UDim2.new(1,-20,0,40); cfgRow.BackgroundTransparency=1; cfgRow.ZIndex=11

saveConfig = function()
    local ok, err = pcall(function()
        local pluginList, libList = {}, {}
        local pluginSettings, libSettings = {}, {}
        for name, data in pairs(loadedPlugins) do table.insert(pluginList, name); if data.settings and next(data.settings) then pluginSettings[name] = data.settings end end
        for id, data in pairs(loadedLibs) do table.insert(libList, id); if data.settings and next(data.settings) then libSettings[id] = data.settings end end
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            theme=currentTheme, binds=binds, device=currentDevice, events=STATES.events, premium=premiumEnabled, customBg=customBgId,
            showPrint=showPrint, showWarn=showWarn, showError=showError, showSuccess=showSuccess, showEcho=showEcho,
            plugins=pluginList, pluginBackups=backupPlugins, libs=libList, libBackups=backupLibs,
            pluginSettings=pluginSettings, libSettings=libSettings, customCommands=customCommands,
        }))
    end)
    if not ok then log("Config operation failed: "..tostring(err), "Error") end
end

local function applyConfig(cfg)
    if cfg.premium ~= nil then premiumEnabled = cfg.premium and true or false; if secretBtn then secretBtn.Visible = premiumEnabled end; if win10Btn then win10Btn.Visible = premiumEnabled end; if bgRow then bgRow.Visible = premiumEnabled end end
    if cfg.customBg then customBgId = tostring(cfg.customBg); if bgBox then bgBox.Text = customBgId end end
    if cfg.showPrint ~= nil then showPrint = cfg.showPrint; filterPrintBtn.ImageColor3 = showPrint and Color3.new(1,1,1) or Color3.fromRGB(100,100,100) end
    if cfg.showWarn ~= nil then showWarn = cfg.showWarn; filterWarnBtn.ImageColor3 = showWarn and Color3.new(1,1,1) or Color3.fromRGB(100,100,100) end
    if cfg.showError ~= nil then showError = cfg.showError; filterErrorBtn.ImageColor3 = showError and Color3.new(1,1,1) or Color3.fromRGB(100,100,100) end
    if cfg.showSuccess ~= nil then showSuccess = cfg.showSuccess; filterSuccessBtn.ImageColor3 = showSuccess and Color3.new(1,1,1) or Color3.fromRGB(100,100,100) end
    if cfg.showEcho ~= nil then showEcho = cfg.showEcho; filterEchoBtn.ImageColor3 = showEcho and Color3.new(1,1,1) or Color3.fromRGB(100,100,100) end
    if type(cfg.customCommands) == "table" then customCommands = {}; for k, v in pairs(cfg.customCommands) do customCommands[k] = v end end
    if type(cfg.pluginSettings) == "table" then for name, s in pairs(cfg.pluginSettings) do pendingPluginSettings[name] = s end end
    if type(cfg.libSettings) == "table" then for id, s in pairs(cfg.libSettings) do pendingLibSettings[id] = s end end
    if cfg.theme and THEMES[cfg.theme] then if (cfg.theme == SECRET or cfg.theme == "win10" or cfg.theme == "custom") and not premiumEnabled then else applyTheme(cfg.theme); if refreshThemeButtons then refreshThemeButtons() end end end
    if cfg.binds and setupBind then for k, v in pairs(cfg.binds) do setupBind(k, v) end end
    if cfg.events then for k, v in pairs(cfg.events) do if STATES.events[k] ~= nil then STATES.events[k]=v end; if eventBoxes[k] then eventBoxes[k].Text = v end end end
    if type(cfg.libBackups) == "table" then backupLibs = {}; for _, n in ipairs(cfg.libBackups) do table.insert(backupLibs, n) end end
    if type(cfg.pluginBackups) == "table" then backupPlugins = {}; for _, n in ipairs(cfg.pluginBackups) do table.insert(backupPlugins, n) end end
    if type(cfg.libs) == "table" then for _, id in ipairs(cfg.libs) do pcall(loadLibrary, id) end end
    if type(cfg.plugins) == "table" then for _, name in ipairs(cfg.plugins) do pcall(loadPlugin, name) end end
end

local function loadConfig()
    local ok, err = pcall(function()
        if isfile and isfile(CONFIG_FILE) then applyConfig(HttpService:JSONDecode(readfile(CONFIG_FILE))); log("Config loaded", "Success", true) end
    end)
    if not ok then log("Config operation failed: "..tostring(err), "Error") end
end

SaveBtn = makeButton(cfgRow, "Save config", 0, 0, 120, 26, saveConfig)
LoadBtn = makeButton(cfgRow, "Load config", 130, 0, 120, 26, loadConfig); addSettingRow(cfgRow)

local customRow = Instance.new("Frame")
customRow.Size = UDim2.new(1,-20,0,40); customRow.BackgroundTransparency = 1; customRow.ZIndex = 11
makeButton(customRow, "+ Custom Plugin", 0, 0, 140, 26, function() openCustomEditor("plugin") end)
makeButton(customRow, "+ Custom Library", 150, 0, 140, 26, function() openCustomEditor("lib") end)
addSettingRow(customRow)

eventsTitleLabel = makeLabel(SettingsScroll, "Events (command or Lua code)", 0, 20); addSettingRow(eventsTitleLabel)
for _, evName in ipairs({"onKilled","onDied","onSpawn","onExecute","onJoin","onDamage","onLeave"}) do
    local row = Instance.new("Frame"); row.Size=UDim2.new(1,-20,0,44); row.BackgroundTransparency=1; row.ZIndex=11
    eventLabels[evName] = makeLabel(row, evName, 0, 16)
    local box = Instance.new("TextBox"); box.Size=UDim2.new(1,0,0,22); box.Position=UDim2.new(0,0,0,18); box.BackgroundColor3=THEMES.default.input
    box.TextColor3=THEMES.default.text; box.Font=CONFIG.Font; box.TextSize=12; box.TextXAlignment=Enum.TextXAlignment.Left
    box.Text = STATES.events[evName] or ""; box.PlaceholderText = "command or lua code"; box.ClearTextOnFocus = false; box.ZIndex=12; box.Parent=row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,3)
    box.FocusLost:Connect(function() STATES.events[evName] = box.Text; if saveConfig then pcall(saveConfig) end end)
    eventBoxes[evName] = box; addSettingRow(row)
end

function openCustomEditor(typ)
    local Editor = Instance.new("Frame"); Editor.Size = UDim2.new(1,0,1,0); Editor.Position = UDim2.new(0,0,0,0)
    Editor.BackgroundColor3 = THEMES[currentTheme].background; Editor.BorderSizePixel = 0; Editor.ZIndex = 30; Editor.Parent = ConsoleFrame
    Instance.new("UICorner", Editor).CornerRadius = UDim.new(0,6)
    local title = Instance.new("TextLabel"); title.Size = UDim2.new(1,-20,0,30); title.Position = UDim2.new(0,10,0,5)
    title.BackgroundTransparency = 1; title.Text = "Create Custom " .. (typ == "plugin" and "Plugin" or "Library")
    title.TextColor3 = THEMES[currentTheme].text; title.Font = Enum.Font.Code; title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 31; title.Parent = Editor

    local function field(placeholder, y, height)
        local box = Instance.new("TextBox"); box.Size = UDim2.new(1,-20,0,height or 26); box.Position = UDim2.new(0,10,0,y)
        box.BackgroundColor3 = THEMES[currentTheme].input; box.TextColor3 = THEMES[currentTheme].text
        box.PlaceholderText = placeholder; box.PlaceholderColor3 = Color3.fromRGB(120,120,120)
        box.Font = Enum.Font.Code; box.TextSize = 13; box.Text = ""; box.ClearTextOnFocus = false; box.ZIndex = 31
        box.Parent = Editor; Instance.new("UICorner", box).CornerRadius = UDim.new(0,4); return box
    end
    local nameBox = field("Name", 40); local authorBox = field("Author", 70); local descBox = field("Description", 100)
    local imgBox = field("Image Asset ID (optional)", 130); local codeBox = field("Lua code", 160, 200)
    codeBox.TextYAlignment = Enum.TextYAlignment.Top; codeBox.MultiLine = true; authorBox.Text = LocalPlayer.Name

    local saveBtn = Instance.new("TextButton"); saveBtn.Size = UDim2.new(0,100,0,26); saveBtn.Position = UDim2.new(0,10,1,-36)
    saveBtn.BackgroundColor3 = THEMES[currentTheme].accent; saveBtn.TextColor3 = Color3.fromRGB(0,0,0); saveBtn.Text = "Save"
    saveBtn.Font = Enum.Font.Code; saveBtn.TextSize = 13; saveBtn.BorderSizePixel = 0; saveBtn.ZIndex = 31; saveBtn.Parent = Editor
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,4)

    local cancelBtn = Instance.new("TextButton"); cancelBtn.Size = UDim2.new(0,100,0,26); cancelBtn.Position = UDim2.new(0,120,1,-36)
    cancelBtn.BackgroundColor3 = THEMES[currentTheme].input; cancelBtn.TextColor3 = THEMES[currentTheme].text; cancelBtn.Text = "Cancel"
    cancelBtn.Font = Enum.Font.Code; cancelBtn.TextSize = 13; cancelBtn.BorderSizePixel = 0; cancelBtn.ZIndex = 31; cancelBtn.Parent = Editor
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0,4)

    cancelBtn.MouseButton1Click:Connect(function() Editor:Destroy() end)
    saveBtn.MouseButton1Click:Connect(function()
        local nm = nameBox.Text:match("^%s*(.-)%s*$"); if nm == "" or codeBox.Text:match("^%s*$") then log("Name and Code required", "Error"); return end
        local data = { name = nm, author = authorBox.Text:match("^%s*(.-)%s*$"), desc = descBox.Text, imageId = imgBox.Text:match("%d+") or "", isVerified = false, isSystem = false }
        if data.author == "" then data.author = LocalPlayer.Name end
        if saveCustomItem(typ, data, codeBox.Text) then
            Editor:Destroy()
            if typ == "plugin" then if WorkshopFrame and WorkshopFrame.Visible then refreshWorkshop() end
            else if WorkshopFrame and WorkshopFrame.Visible and refreshLibsTab then refreshLibsTab() end end
        end
    end)
end
-- ============ PLUGIN API ============
local function makePluginAPI(pluginName)
    local api = {}
    api.pluginName = pluginName
    api.version = "1.0"
    api._myHooks = {}

    api.log = function(text, colorType)
        log("[" .. pluginName .. "] " .. tostring(text), colorType or "Output")
    end

    api.registerCommand = function(name, fn, aliases)
        if type(name) ~= "string" or type(fn) ~= "function" then return false, "bad args" end
        if commands[name] then return false, "already exists" end
        commands[name] = function(args)
            local ok, e = pcall(fn, args or {})
            if not ok then log("[" .. pluginName .. "] error in " .. name .. ": " .. tostring(e), "Error") end
        end
        pluginCommands[name] = pluginName
        if aliases then for _, a in ipairs(aliases) do if not commands[a] then commands[a] = commands[name]; pluginCommands[a] = pluginName end end end
        return true
    end

    api.unregisterCommand = function(name)
        if pluginCommands[name] == pluginName then commands[name] = nil; pluginCommands[name] = nil; return true end
        return false
    end

    api.runCommand = function(name, args)
        local f = commands[name]
        if not f then return false, "no such command" end
        local ok, e = pcall(f, args or {})
        if not ok then api.log("runCommand error: " .. tostring(e), "Error") end
        return ok
    end

    api.executeLua = executeLua
    api.getChar = getChar
    api.getPlayer = function() return LocalPlayer end
    api.getSettings = function()
        return { theme = currentTheme, device = currentDevice, showPrint = showPrint, showWarn = showWarn, showError = showError, showSuccess = showSuccess, showEcho = showEcho, binds = binds }
    end
    api.setTheme = function(name) applyTheme(name); if saveConfig then pcall(saveConfig) end end
    api.resetTheme = function() currentTheme = "none"; if refreshThemeButtons then refreshThemeButtons() end end

    api.setSetting = function(key, value)
        local data = loadedPlugins[pluginName]; if not data then return false end
        if not data.settings then data.settings = {} end
        data.settings[tostring(key)] = value; if saveConfig then pcall(saveConfig) end; return true
    end
    api.getSetting = function(key, default)
        local data = loadedPlugins[pluginName]; if not data or not data.settings then return default end
        local v = data.settings[tostring(key)]; if v == nil then return default end; return v
    end
    api.getSettingsAll = function() local data = loadedPlugins[pluginName]; return data and data.settings or {} end
    api.requireLib = function(libId) if loadedLibs[libId] then return loadedLibs[libId].api or loadedLibs[libId] end; local ok = loadLibrary(libId); if ok and loadedLibs[libId] then return loadedLibs[libId].api or loadedLibs[libId] end; return nil end

    api.hookEvent = function(evName, fn)
        if type(fn) ~= "function" then return false end
        pluginEventHooks[evName] = pluginEventHooks[evName] or {}
        table.insert(pluginEventHooks[evName], fn); table.insert(api._myHooks, {evName = evName, fn = fn}); return true
    end

    api.ui = {
        screenGui = ScreenGui, consoleFrame = ConsoleFrame, consoleCorner = consoleCorner,
        header = Header, headerCorner = headerCorner, title = Title, logFrame = LogFrame,
        inputFrame = InputFrame, commandBox = CommandBox, settingsFrame = SettingsFrame, workshopFrame = WorkshopFrame,
        stroke = stroke, bgImage = bgImage, getIcon = getIcon, getThumb = getThumb,
    }
    return api
end

-- ============ LOAD / UNLOAD PLUGIN ============
local loadPlugin, unloadPlugin, listPlugins

loadPlugin = function(pluginName)
    pluginName = tostring(pluginName or ""):gsub("%.xconr$", ""):match("^%s*(.-)%s*$")
    if pluginName == "" then return false end
    local norm = normName(pluginName)
    for existing in pairs(loadedPlugins) do if normName(existing) == norm then log("Plugin already loaded: " .. existing, "Error"); return false end end

    local source = nil
    local customLua = CUSTOM_PLUGINS_DIR .. "/" .. slugify(pluginName) .. ".lua"
    if isfile and isfile(customLua) then local ok, raw = pcall(readfile, customLua); if ok and raw then source = raw end end
    if not source then
        local path = "workspace/" .. pluginName .. PLUGIN_EXT
        if isfile and isfile(path) then local ok, raw = pcall(readfile, path); if ok and raw then source = raw end end
    end
    if not source then
        local url = GITHUB_PLUGINS .. pluginName .. ".xconr"
        local ok, raw = pcall(game.HttpGet, game, url, true)
        if ok and raw and not raw:find("404: Not Found") and not raw:find("<!DOCTYPE") then source = raw end
    end

    if not source then log("Plugin not found: " .. pluginName, "Error"); return false end
    if source:find("<html") or source:find("404: Not Found") or source:find("<!DOCTYPE") then log("Compile error: File is not valid Lua (corrupted download).", "Error"); return false end

    local chunk, err = loadstring(source, "=" .. pluginName)
    if not chunk then log("Compile error in " .. pluginName .. ": " .. tostring(err), "Error"); return false end

    local api = makePluginAPI(pluginName)
    local ok2, result = pcall(chunk, api)
    if not ok2 then
        local errStr = tostring(result); if type(result) == "table" then errStr = result.message or result.error or "Unknown table error" end
        log("Runtime error in " .. pluginName .. ": " .. tostring(errStr), "Error"); return false
    end

    local meta = (type(result) == "table") and result or {}
    loadedPlugins[pluginName] = { meta = meta, api = api, settings = {} }
    if pendingPluginSettings[pluginName] then for k, v in pairs(pendingPluginSettings[pluginName]) do loadedPlugins[pluginName].settings[k] = v end; pendingPluginSettings[pluginName] = nil end

    if pluginName == "CustomCommand" then
        for name, code in pairs(customCommands) do
            if not commands[name] then
                local _code = code
                commands[name] = function(args) local okC, eC = pcall(executeLua, _code); if not okC then log("CustomCommand error: " .. tostring(eC), "Error") end end
                pluginCommands[name] = "CustomCommand"
            end
        end
    end
    for i = #backupPlugins, 1, -1 do if backupPlugins[i] == pluginName then table.remove(backupPlugins, i) end end
    log("Plugin loaded: " .. pluginName .. (meta.version and (" v" .. tostring(meta.version)) or ""), "Success")
    return true
end

unloadPlugin = function(pluginName, skipBackup)
    pluginName = tostring(pluginName or ""):gsub("%.xconr$", ""):match("^%s*(.-)%s*$")
    for _, p in ipairs(WORKSHOP_PLUGINS) do if normName(p.name) == normName(pluginName) and p.isSystem then log("System plugin cannot be unloaded: " .. p.name, "Error"); return false end end
    local data = loadedPlugins[pluginName]; if not data then log("Plugin not loaded: " .. pluginName, "Error"); return false end
    for cmdName, owner in pairs(pluginCommands) do if owner == pluginName then commands[cmdName] = nil; pluginCommands[cmdName] = nil end end
    if data.meta and type(data.meta.onUnload) == "function" then pcall(data.meta.onUnload, data.api) end
    for _, h in ipairs(data.api._myHooks or {}) do
        local list = pluginEventHooks[h.evName]
        if list then for i = #list, 1, -1 do if list[i] == h.fn then table.remove(list, i) end end end
    end
    loadedPlugins[pluginName] = nil
    if not skipBackup then local found = false; for _, n in ipairs(backupPlugins) do if n == pluginName then found = true; break end end; if not found then table.insert(backupPlugins, pluginName) end end
    log("Plugin unloaded: " .. pluginName, "Info"); return true
end

listPlugins = function()
    local lines = {}
    for name, data in pairs(loadedPlugins) do local v = (data.meta and data.meta.version) or "?"; table.insert(lines, "  " .. name .. " v" .. tostring(v)) end
    if #lines == 0 then return end
    log("Loaded plugins:", "Info"); for _, line in ipairs(lines) do log(line, "Default") end
end

local function runEvent(name, ...)
    if pluginEventHooks[name] then for _, fn in ipairs(pluginEventHooks[name]) do pcall(fn, name, ...) end end
    local code = STATES.events[name]; if not code or code == "" then return end
    local args = {}; for w in code:gmatch("%S+") do table.insert(args, w) end
    if #args > 0 then
        local cmdName = args[1]:lower(); table.remove(args, 1)
        local f = commands[cmdName]
        if f then local ok, e = pcall(f, args); if not ok then log("Event "..name.." error: "..tostring(e), "Error") end; return end
    end
    pcall(executeLua, code)
end

-- ============ SPEED / VELOCITY ============
local function captureOriginalSpeed()
    local _, hum = getChar()
    if hum and not speedCaptured then originalWalkSpeed = hum.WalkSpeed; speedCaptured = true; log(string.format("Original WalkSpeed captured: %.1f", originalWalkSpeed), "Info", true) end
end

local function setVelocityActive(active)
    if active then
        if STATES.velocityActive then return end
        local char, hum = getChar(); if not char or not hum then log("No character", "Error"); return end
        STATES.velocityActive = true; STATES.velocitySpeedBackup = hum.WalkSpeed; hum.WalkSpeed = 1; STATES.velocityCollideBackup = {}
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then STATES.velocityCollideBackup[p] = p.CanCollide; p.CanCollide = false end end
        if STATES.velocityConn then STATES.velocityConn:Disconnect() end
        STATES.velocityConn = RunService.Stepped:Connect(function()
            local c, h = getChar(); if not c or not h then return end
            h.WalkSpeed = 1; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end)
        log("velocity: on", "Success")
    else
        if not STATES.velocityActive then return end
        STATES.velocityActive = false
        if STATES.velocityConn then STATES.velocityConn:Disconnect(); STATES.velocityConn = nil end
        local char, hum = getChar()
        if hum and STATES.velocitySpeedBackup then hum.WalkSpeed = STATES.velocitySpeedBackup end
        STATES.velocitySpeedBackup = nil
        if char and STATES.velocityCollideBackup then for p, state in pairs(STATES.velocityCollideBackup) do if p and p.Parent then pcall(function() p.CanCollide = state end) end end; STATES.velocityCollideBackup = nil end
        log("velocity: off", "Info")
    end
end

-- ============ BIND ============
local function resolveKey(name) name = name:upper(); local ok, kc = pcall(function() return Enum.KeyCode[name] end); return ok and kc or nil end
local HOLD_COMMANDS = { velocity = true }

setupBind = function(keyName, cmdStr)
    local key = resolveKey(keyName); if not key then return false end
    binds[keyName] = cmdStr
    local parts = {}; for w in cmdStr:gmatch("%S+") do table.insert(parts, w) end
    local cmdName = parts[1] and parts[1]:lower(); local isHold = cmdName and HOLD_COMMANDS[cmdName]
    local old = bindConns[keyName]
    if old then if type(old) == "table" then for _, c in ipairs(old) do if c then c:Disconnect() end end else old:Disconnect() end end

    local beginConn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == key then
            log("> "..cmdStr, "Echo")
            if isHold and cmdName == "velocity" then setVelocityActive(true)
            else
                local aa = {}; for w in cmdStr:gmatch("%S+") do table.insert(aa, w) end
                local cmd = aa[1] and aa[1]:lower(); table.remove(aa, 1)
                runEvent("onExecute"); local f = cmd and commands[cmd]
                if f then pcall(f, aa) else executeLua(cmdStr) end
            end
        end
    end)
    local endConn = nil
    if isHold then endConn = UIS.InputEnded:Connect(function(input) if input.KeyCode == key then if cmdName == "velocity" then setVelocityActive(false) end end end) end
    bindConns[keyName] = {beginConn, endConn}; return true
end

SettingsBtn.MouseButton1Click:Connect(function()
    local text = "settings"; log("> "..text, "Echo"); runEvent("onExecute")
    local f = commands["settings"]; if f then local ok, e = pcall(f, {}); if not ok then log("Error: "..tostring(e), "Error") end end
end)

-- ============ BASIC COMMANDS ============
commands["help"] = function()
    log("Commands:", "Info")
    log("  pl.<name>.<load|unload|help|info> | pl.list", "Default")
    log("  lib.<id>.<load|unload|help|info> | lib.list", "Default")
    log("  settings, bind, unload/exit, premium, theme, device, filter, asset", "Default")
end
commands["settings"] = function() openSettings() end
commands["workshop"] = function() openWorkshop() end
commands["unload"] = function() log("Console unloaded", "Success"); if logConnection then logConnection:Disconnect(); logConnection = nil end; ScreenGui:Destroy() end
commands["exit"] = commands["unload"]

commands["asset"] = function(args)
    local sub = (args[1] or ""):lower()
    if sub == "image" then useFallbackText = false; applyFallback(); log("Asset mode: image", "Success")
    elseif sub == "default" then useFallbackText = true; applyFallback(); log("Asset mode: default", "Success")
    else log("Usage: asset <image|default>", "Error") end
end
commands["settings.save"] = function() saveConfig(); log("Config saved", "Success") end
commands["settings.load"] = function()
    if isfile and isfile(CONFIG_FILE) then local ok, err = pcall(function() applyConfig(HttpService:JSONDecode(readfile(CONFIG_FILE))) end); if ok then log("Config loaded", "Success", true) else log("Load error: "..tostring(err), "Error") end
    else log("No config file", "Error") end
end
commands["settings.reset"] = function() if isfile and isfile(CONFIG_FILE) then pcall(function() delfile(CONFIG_FILE) end); log("Config reset. Reload console to apply.", "Success") else log("No config file", "Error") end end
commands["settings.list"] = function()
    local plCount, lbCount = 0, 0; for _ in pairs(loadedPlugins) do plCount += 1 end; for _ in pairs(loadedLibs) do lbCount += 1 end
    log("=== Config ===", "Info"); log("  Theme: "..currentTheme, "Default"); log("  Device: "..currentDevice, "Default")
    log("  Plugins: "..plCount, "Default"); log("  Libs: "..lbCount, "Default")
    log("  Backups (plugins): "..#backupPlugins, "Default"); log("  Backups (libs): "..#backupLibs, "Default")
end
commands["custom.plugin.new"] = function() openCustomEditor("plugin") end
commands["custom.lib.new"]    = function() openCustomEditor("lib") end
commands["custom.plugin.delete"] = function(args) local name = table.concat(args, " "); if name == "" then log("Usage: custom.plugin.delete <name>", "Error"); return end; deleteCustomItem("plugin", name); if saveConfig then pcall(saveConfig) end; if WorkshopFrame and WorkshopFrame.Visible then refreshWorkshop() end end
commands["custom.lib.delete"] = function(args) local name = table.concat(args, " "); if name == "" then log("Usage: custom.lib.delete <name>", "Error"); return end; deleteCustomItem("lib", name); if saveConfig then pcall(saveConfig) end; if WorkshopFrame and WorkshopFrame.Visible and refreshLibsTab then refreshLibsTab() end end

commands["theme"] = function(args)
    local name = args[1]; if not name then log("Usage: theme <name>", "Error"); return end
    name = name:lower(); if name == "secret" or name == "code" then name = SECRET end
    if THEMES[name] then
        if (name == SECRET or name == "win10" or name == "custom") and not premiumEnabled then log("premium required", "Error"); return end
        applyTheme(name); if refreshThemeButtons then refreshThemeButtons() end; log("Theme set: " .. name, "Success"); if saveConfig then pcall(saveConfig) end
    else log("Unknown theme: " .. name, "Error") end
end
commands["device"] = function(args)
    local name = args[1]; if not name then log("Usage: device <pc|phone>", "Error"); return end
    name = name:lower(); if name == "pc" then currentDevice = "PC" elseif name == "phone" then currentDevice = "Phone" else log("Unknown", "Error"); return end
    if currentDevice == "PC" then PhoneIconBtn.Visible = false; consoleHidden = false; ConsoleFrame.Visible = true
    else if consoleHidden then ConsoleFrame.Visible = false; PhoneIconBtn.Visible = true end end
    log("Device set: " .. name, "Success"); if saveConfig then pcall(saveConfig) end
end
commands["filter"] = function(args)
    local ft = args[1] and args[1]:lower(); local state = args[2] and args[2]:lower()
    if not ft then log("Usage: filter <print|warn|error|success|echo> [on|off]", "Error"); return end
    local function setF(val)
        if val == nil then
            if ft == "print" then showPrint = not showPrint; val = showPrint elseif ft == "warn" then showWarn = not showWarn; val = showWarn
            elseif ft == "error" then showError = not showError; val = showError elseif ft == "success" then showSuccess = not showSuccess; val = showSuccess
            elseif ft == "echo" then showEcho = not showEcho; val = showEcho else log("Unknown", "Error"); return false end
        else
            val = (val == "on" or val == "1" or val == "true")
            if ft == "print" then showPrint = val elseif ft == "warn" then showWarn = val elseif ft == "error" then showError = val elseif ft == "success" then showSuccess = val elseif ft == "echo" then showEcho = val else log("Unknown", "Error"); return false end
        end
        local function ub(btn, isOn) if btn then btn.ImageColor3 = isOn and Color3.new(1,1,1) or Color3.fromRGB(100,100,100) end end
        ub(filterPrintBtn, showPrint); ub(filterWarnBtn, showWarn); ub(filterErrorBtn, showError); ub(filterSuccessBtn, showSuccess); ub(filterEchoBtn, showEcho)
        log(string.format("Filter %s: %s", ft, val and "on" or "off"), "Success"); if saveConfig then pcall(saveConfig) end; return true
    end
    setF(state)
end
commands["premium"] = function(args)
    local v = args[1]
    if v == "1" then premiumEnabled = true; secretBtn.Visible = true; win10Btn.Visible = true; bgRow.Visible = true; log("Premium enabled.", "Success"); if saveConfig then pcall(saveConfig) end
    elseif v == "0" then premiumEnabled = false; secretBtn.Visible = false; win10Btn.Visible = false; bgRow.Visible = false; log("Premium disabled", "Info"); if saveConfig then pcall(saveConfig) end
    else log("Usage: premium <0|1>", "Error") end
end

CMD_COLORS = CMD_COLORS or { R=Color3.fromRGB(255,0,0), G=Color3.fromRGB(0,255,0), B=Color3.fromRGB(0,0,255), Y=Color3.fromRGB(255,255,0), W=Color3.fromRGB(255,255,255), K=Color3.fromRGB(0,0,0), O=Color3.fromRGB(255,140,0), P=Color3.fromRGB(160,0,255), C=Color3.fromRGB(0,255,255), M=Color3.fromRGB(255,0,255), A=Color3.fromRGB(128,128,128), S=Color3.fromRGB(200,200,200) }

-- ============ FUNCTIONS (FLY, NOCLIP, ESP, etc) ============
local flyBV, flyBG
function toggleFly(on)
    if on == STATES.flying then return end; STATES.flying = on
    if STATES.flyConn then STATES.flyConn:Disconnect(); STATES.flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end; if flyBG then flyBG:Destroy(); flyBG = nil end
    if on then
        local _, hum, hrp = getChar(); if not hrp then log("No character","Error"); STATES.flying=false; return end
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e5,1e5,1e5); flyBV.Velocity = Vector3.zero; flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5); flyBG.P = 2000; flyBG.Parent = hrp
        STATES.flyConn = RunService.RenderStepped:Connect(function()
            local _, _, root = getChar(); if not root or not flyBV or not flyBV.Parent then return end
            local cam = Workspace.CurrentCamera; local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
            flyBV.Velocity = move * 50; flyBG.CFrame = cam.CFrame
        end)
    end
end

function toggleNoclip(on)
    STATES.noclip = on; if STATES.noclipConn then STATES.noclipConn:Disconnect(); STATES.noclipConn = nil end
    if on then
        STATES.noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end
        end)
    else
        local char = LocalPlayer.Character
        if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
    end
end

local espHighlights = {}
function toggleESP(on)
    STATES.esp = on; for _, h in pairs(espHighlights) do if h and h.Parent then h:Destroy() end end; espHighlights = {}
    if on then
        local function addESP(plr)
            if plr == LocalPlayer then return end
            local function bind(char)
                if espHighlights[plr] and espHighlights[plr].Parent then return end
                local hl = Instance.new("Highlight"); hl.FillColor = Color3.fromRGB(255,0,0); hl.OutlineColor = Color3.fromRGB(255,255,255)
                hl.FillTransparency = 0.5; hl.OutlineTransparency = 0; hl.Adornee = char; hl.Parent = char; espHighlights[plr] = hl
            end
            plr.CharacterAdded:Connect(bind); if plr.Character then bind(plr.Character) end
        end
        for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
        if not STATES.espConn then STATES.espConn = Players.PlayerAdded:Connect(addESP) end
    else
        if STATES.espConn then STATES.espConn:Disconnect(); STATES.espConn = nil end
    end
end

function toggleSwim(on)
    STATES.swim = on; if STATES.swimConn then STATES.swimConn:Disconnect(); STATES.swimConn = nil end
    if on then STATES.swimConn = RunService.Heartbeat:Connect(function() local _, hum = getChar(); if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Swimming) end) end end) end
end

function toggleFling(on)
    STATES.fling = on; if STATES.flingConn then STATES.flingConn:Disconnect(); STATES.flingConn = nil end
    if on then
        STATES.flingConn = RunService.Heartbeat:Connect(function()
            local _, _, myHrp = getChar(); if not myHrp then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - myHrp.Position).Magnitude < 10 then
                        pcall(function() hrp.AssemblyAngularVelocity = Vector3.new(9999,9999,9999); hrp.AssemblyLinearVelocity = Vector3.new(9999,9999,9999) end)
                    end
                end
            end
        end)
    end
end

function toggleInfJump(on)
    STATES.infjump = on; if STATES.infjumpConn then STATES.infjumpConn:Disconnect(); STATES.infjumpConn = nil end
    if on then STATES.infjumpConn = UIS.JumpRequest:Connect(function() local _, hum = getChar(); if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end end) end
end

function toggleSpasm(on)
    STATES.spasm = on; if STATES.spasmConn then STATES.spasmConn:Disconnect(); STATES.spasmConn = nil end
    if on then
        STATES.spasmConn = RunService.Heartbeat:Connect(function()
            local _, _, hrp = getChar(); if not hrp then return end
            pcall(function() hrp.CFrame = hrp.CFrame * CFrame.new((math.random()-0.5)*2, (math.random()-0.5)*2, (math.random()-0.5)*2) end)
        end)
    end
end

function toggleFullbright(on)
    if on then
        if not STATES.fbBackup then STATES.fbBackup = { Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows } end
        Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255); Lighting.Brightness = 3
        Lighting.ClockTime = 12; Lighting.GlobalShadows = false; Lighting.FogEnd = 1e6; STATES.fullbright = true
    else
        if STATES.fbBackup then
            Lighting.Ambient = STATES.fbBackup.Ambient; Lighting.OutdoorAmbient = STATES.fbBackup.OutdoorAmbient
            Lighting.Brightness = STATES.fbBackup.Brightness; Lighting.ClockTime = STATES.fbBackup.ClockTime
            Lighting.FogEnd = STATES.fbBackup.FogEnd; Lighting.GlobalShadows = STATES.fbBackup.GlobalShadows; STATES.fbBackup = nil
        end
        STATES.fullbright = false
    end
end

function toggleNofog(on)
    if on then
        if not STATES.fogBackup then STATES.fogBackup = { FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart } end
        Lighting.FogEnd = 1e6; Lighting.FogStart = 0; STATES.nofog = true
    else
        if STATES.fogBackup then Lighting.FogEnd = STATES.fogBackup.FogEnd; Lighting.FogStart = STATES.fogBackup.FogStart; STATES.fogBackup = nil end
        STATES.nofog = false
    end
end

function giveGun()
    local char = LocalPlayer.Character; if not char then log("No character","Error"); return end
    local bp = LocalPlayer:FindFirstChild("Backpack"); if not bp then log("No backpack","Error"); return end
    local tool = Instance.new("Tool"); tool.Name = "XConsoleGun"; tool.RequiresHandle = true; tool.CanBeDropped = false
    local handle = Instance.new("Part"); handle.Name = "Handle"; handle.Size = Vector3.new(1,1,2); handle.Color = Color3.fromRGB(40,40,40); handle.Material = Enum.Material.Metal; handle.Parent = tool
    local muzzle = Instance.new("Attachment"); muzzle.Position = Vector3.new(0,0,-1); muzzle.Parent = handle
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse(); local origin = handle.Position; local targetPos = mouse.Hit.Position; local dir = (targetPos - origin)
        if dir.Magnitude < 0.01 then return end; dir = dir.Unit
        local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {char}
        local result = Workspace:Raycast(origin, dir * 500, params); local hitPos = result and result.Position or (origin + dir * 500)
        local part = Instance.new("Part"); part.Size = Vector3.new(0.15,0.15,0.15); part.Color = Color3.fromRGB(255,255,0); part.Material = Enum.Material.Neon
        part.CanCollide = false; part.Anchored = true; part.CFrame = CFrame.new(origin + dir * 2); part.Parent = Workspace; Debris:AddItem(part, 0.1)
        local att1 = Instance.new("Attachment"); att1.Position = Vector3.zero; att1.Parent = part
        local tempBeam = Instance.new("Beam"); tempBeam.Attachment0 = muzzle; tempBeam.Attachment1 = att1; tempBeam.Width0 = 0.15; tempBeam.Width1 = 0.15
        tempBeam.Color = ColorSequence.new(Color3.fromRGB(255,255,0)); tempBeam.FaceCamera = true; tempBeam.Parent = handle; Debris:AddItem(tempBeam, 0.1)
        if result and result.Instance then local hum = result.Instance.Parent and result.Instance.Parent:FindFirstChildOfClass("Humanoid"); if hum and hum.Parent ~= char then pcall(function() hum:TakeDamage(20) end) end end
    end)
    tool.Parent = bp; log("Gun added to backpack (client-side). Equip and click.","Success")
end

-- ============ COMMANDS BINDINGS ============
commands["fly"]    = function() toggleFly(true); log("Fly enabled","Success") end
commands["unfly"]  = function() toggleFly(false); log("Fly disabled","Success") end
commands["noclip"] = function() toggleNoclip(true); log("Noclip enabled","Success") end
commands["clip"]   = function() toggleNoclip(false); log("Noclip disabled","Success") end
commands["esp"]    = function() toggleESP(true); log("ESP enabled","Success") end
commands["unesp"]  = function() toggleESP(false); log("ESP disabled","Success") end
commands["swim"]   = function() toggleSwim(true); log("Swim enabled","Success") end
commands["unswim"] = function() toggleSwim(false); log("Swim disabled","Success") end
commands["fling"]  = function() toggleFling(true); log("Fling enabled","Success") end
commands["unfling"]= function() toggleFling(false); log("Fling disabled","Success") end
commands["infjump"]= function() toggleInfJump(true); log("InfJump enabled","Success") end
commands["uninfjump"]=function() toggleInfJump(false); log("InfJump disabled","Success") end
commands["spasm"]  = function() toggleSpasm(true); log("Spasm enabled","Success") end
commands["unspasm"]= function() toggleSpasm(false); log("Spasm disabled","Success") end
commands["fb"]     = function() toggleFullbright(true); log("Fullbright enabled","Success") end
commands["unfb"]   = function() toggleFullbright(false); log("Fullbright disabled","Success") end
commands["nofog"]  = function() toggleNofog(true); log("NoFog enabled","Success") end

commands["sit"] = function() local _, hum = getChar(); if hum then hum.Sit = true; log("Sitting...","Success") end end
commands["ws"] = function(args) local v = tonumber(args[1]); if not v then log("Usage: ws <value>","Error"); return end; local _, hum = getChar(); if hum then hum.WalkSpeed=v; log("WalkSpeed set to "..v,"Success") end end
commands["jp"] = function(args) local v = tonumber(args[1]); if not v then log("Usage: jp <value>","Error"); return end; local _, hum = getChar(); if hum then hum.UseJumpPower=true; hum.JumpPower=v; log("JumpPower set to "..v,"Success") end end
commands["tppos"] = function(args) local x,y,z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3]); if not (x and y and z) then log("Usage: tppos x y z","Error"); return end; local _,_,hrp = getChar(); if hrp then hrp.CFrame = CFrame.new(x,y,z); log("Teleported to position","Success") end end
commands["copypos"] = function(args)
    local target = LocalPlayer; if args[1] then local q = args[1]:lower(); for _, p in ipairs(Players:GetPlayers()) do if p.Name:lower()==q or p.DisplayName:lower()==q then target=p; break end end end
    local char = target.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then log(string.format("Pos of %s: %.1f, %.1f, %.1f", target.Name, hrp.Position.X, hrp.Position.Y, hrp.Position.Z), "Success") else log("Player not found","Error") end
end
commands["bind"] = function(args)
    if currentDevice == "Phone" then log("no access", "Error"); return end
    if #args < 1 then log("Usage: bind <key> <cmd> | bind list | bind clear","Error"); return end
    local sub = args[1]:lower()
    if sub == "list" then log("Active binds:","Info"); local any=false; for k,v in pairs(binds) do log("  "..k.." -> "..v,"Default"); any=true end; if not any then log("No active binds","Info") end; return
    elseif sub == "clear" then for _, c in pairs(bindConns) do if type(c) == "table" then for _, cc in ipairs(c) do if cc then cc:Disconnect() end end else c:Disconnect() end end; binds = {}; bindConns = {}; log("All binds cleared","Success"); if saveConfig then pcall(saveConfig) end; return end
    if #args < 2 then log("Usage: bind <key> <cmd>","Error"); return end
    local cmdStr = table.concat(args, " ", 2); if not setupBind(args[1], cmdStr) then log("Unknown key: "..args[1],"Error"); return end
    log(string.format("Bound [%s] -> %s", args[1]:upper(), cmdStr), "Success"); if saveConfig then pcall(saveConfig) end
end
commands["velocity"] = function(args) if currentDevice == "PC" then log("no access. write bind {key} velocity", "Error"); return end; setVelocityActive(not STATES.velocityActive) end
commands["serverinfo"] = function()
    log("Server info:","Info"); log("  PlaceId: "..tostring(game.PlaceId),"Default"); log("  JobId: "..tostring(game.JobId),"Default")
    log("  Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers,"Default"); log("  Creator: "..game.CreatorId.." ("..tostring(game.CreatorType)..")","Default")
    local ok, prod = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end); if ok and prod then log("  Game: "..tostring(prod.Name),"Default") end
end
commands["info"] = commands["serverinfo"]
commands["vr"] = function() local ok, VRS = pcall(function() return game:GetService("VRService") end); if ok and VRS then log("VR available: "..tostring(VRS.VREnabled),"Info") else log("VR mode not available","Error") end end
commands["serverhop"] = function()
    log("Searching for another server...","Info")
    local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))) end)
    if not ok or not res or not res.data then log("Failed to get server list","Error"); return end
    local target; for _, s in ipairs(res.data) do if s.id ~= game.JobId and s.playing < s.maxPlayers then target=s.id; break end end
    if not target then log("No other servers found","Error"); return end
    log("Teleporting to server: "..target,"Success"); pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer) end)
end
commands["shop"] = commands["serverhop"]
commands["joinplayer"] = function(args)
    if #args < 1 then log("Usage: joinplayer <username/ID>","Error"); return end
    local query = args[1]; local userId = tonumber(query)
    if not userId then local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(query) end); if ok then userId = id end end
    if not userId then log("Player not found","Error"); return end
    local plr = Players:GetPlayerByUserId(userId); if not plr then log("Player not in server","Error"); return end
    log("Joining player: "..plr.Name,"Success"); pcall(function() TeleportService:TeleportToPlayer({plr}, LocalPlayer) end)
end
commands["creatorid"] = function() log("Creator ID: "..tostring(game.CreatorId).." ("..tostring(game.CreatorType)..")","Success") end
commands["creator"] = commands["creatorid"]
commands["tools"] = function()
    local bp = LocalPlayer:FindFirstChild("Backpack"); if not bp then log("No backpack","Error"); return end
    local n = 0; for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("Tool") and not obj:IsDescendantOf(LocalPlayer.Character) then obj:Clone().Parent = bp; n += 1; if n >= 100 then break end end end; log("Tools added: "..n,"Success")
end
commands["untools"] = function()
    local n = 0; local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then t:Destroy(); n+=1 end end end
    local char = LocalPlayer.Character; if char then for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then t:Destroy(); n+=1 end end end; log("Tools removed: "..n,"Success")
end
commands["xyz"] = function() local _,_,hrp = getChar(); if not hrp then return end; log(string.format("X=%.2f Y=%.2f Z=%.2f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z),"Success") end
commands["destroy"] = function()
    local mouse = LocalPlayer:GetMouse(); local target = mouse.Target
    if not target then log("Nothing under cursor","Error"); return end
    if target:IsA("Terrain") then log("Cannot destroy Terrain","Error"); return end
    local name = target:GetFullName(); target:Destroy(); log("Destroyed: "..name,"Success")
end
commands["destroytarget"] = commands["destroy"]
commands["summon"] = function(args)
    local shape = (args[1] or "part"):lower()
    local map = { part=Enum.PartType.Block, block=Enum.PartType.Block, sphere=Enum.PartType.Ball, ball=Enum.PartType.Ball, cylinder=Enum.PartType.Cylinder, wedge=Enum.PartType.Wedge, cornerwedge=Enum.PartType.CornerWedge }
    local pt = map[shape]; if not pt then log("Usage: summon <part|sphere|cylinder|wedge>","Error"); return end
    local p = Instance.new("Part"); p.Shape=pt; p.Size=Vector3.new(4,4,4); p.Position = LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,5,0); p.Parent = Workspace; log("Spawned "..shape,"Success")
end
commands["kickme"] = function(args) LocalPlayer:Kick(#args>0 and table.concat(args," ") or "No reason") end
commands["clear"] = function() for _,c in ipairs(LogFrame:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end; log("Log cleared","Info") end
commands["gun"] = giveGun
commands["code"] = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/dimoonsh195/xcode/main/xcode.lua", true))() end) end
commands["xcode"] = commands["code"]
commands["getf3x"] = function() pcall(function() local obj = game:GetObjects("rbxassetid://6695644299")[1]; if obj then loadstring(obj.Source)() end end) end
commands["tool"] = commands["getf3x"]; commands["f3x"] = commands["getf3x"]
commands["dex"] = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/Dex/master/out.lua", true))() end) end

local function tpToPlayer(args)
    if #args < 1 then log("Online players:","Info"); for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then log("  "..p.Name,"Default") end end; return end
    local q = table.concat(args," "):lower(); local target
    for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and (p.Name:lower()==q or p.DisplayName:lower()==q) then target=p; break end end
    if not target then for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and (p.Name:lower():find(q,1,true) or p.DisplayName:lower():find(q,1,true)) then target=p; break end end end
    if not target then log("Player not found","Error"); return end
    local char = target.Character; local thrp = char and char:FindFirstChild("HumanoidRootPart"); local _,_,myhrp = getChar()
    if thrp and myhrp then myhrp.CFrame = thrp.CFrame * CFrame.new(0,2,3); log("Teleported to "..target.Name,"Success") end
end
commands["tp"] = tpToPlayer; commands["to"] = tpToPlayer; commands["goto"] = tpToPlayer

-- ============ HIDE / SHOW ============
local function setConsoleHidden(hidden)
    consoleHidden = hidden
    if currentDevice == "Phone" then ConsoleFrame.Visible = false; PhoneIconBtn.Visible = hidden
    else ConsoleFrame.Visible = not hidden; PhoneIconBtn.Visible = false end
end
HideBtn.MouseButton1Click:Connect(function() setConsoleHidden(true) end)

UIS.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightControl then setConsoleHidden(not consoleHidden) end
    if UIS:GetFocusedTextBox() == CommandBox then
        if input.KeyCode == Enum.KeyCode.Up then
            if #commandHistory > 0 then historyIndex = math.max(1, historyIndex - 1); CommandBox.Text = commandHistory[historyIndex]; CommandBox.CursorPosition = #CommandBox.Text + 1 end
        elseif input.KeyCode == Enum.KeyCode.Down then
            if #commandHistory > 0 then historyIndex = math.min(#commandHistory + 1, historyIndex + 1); CommandBox.Text = historyIndex <= #commandHistory and commandHistory[historyIndex] or ""; CommandBox.CursorPosition = #CommandBox.Text + 1 end
        end
    end
end)

-- ============ COMMAND PARSER ============
local function handleCommand(text)
    local args = {}; for w in text:gmatch("%S+") do table.insert(args, w) end
    if #args == 0 then return end
    local cmdName = args[1]:lower(); table.remove(args, 1)
    log("> "..text, "Echo"); runEvent("onCommand", text); runEvent("onExecute")

    local handled = false
    local lc = cmdName

    -- pl.* / lib.* .info / .help
    if not handled and (lc:match("^pl%..+%.info$") or lc:match("^pl%..+%.help$")) then
        local name = lc:match("^pl%.(.+)%.[%a]+$")
        local p; for _, pl in ipairs(WORKSHOP_PLUGINS) do if normName(pl.name) == normName(name) then p = pl; break end end
        if p then
            log("=== " .. p.name .. " ===", "Info"); log("Author: " .. p.author .. (p.isSystem and " [System]" or ""), "Default")
            log("Desc: " .. p.desc, "Default"); log("Commands: pl."..normName(p.name)..".help", "Default")
        else log("Plugin info not found", "Error") end
        handled = true
    end
    if not handled and (lc:match("^lib%..+%.info$") or lc:match("^lib%..+%.help$")) then
        local name = lc:match("^lib%.(.+)%.[%a]+$")
        local l; for _, lib in ipairs(WORKSHOP_LIBS) do if normName(lib.libId or lib.name) == normName(name) then l = lib; break end end
        if l then
            log("=== " .. l.name .. " ===", "Info"); log("Author: " .. l.author .. (l.isSystem and " [System]" or ""), "Default")
            log("Version: 1.0", "Default"); log("Desc: " .. l.desc, "Default")
        else log("Library info not found", "Error") end
        handled = true
    end

    -- pl.* / lib.* .load/.unload/.reload
    if not handled and lc == "pl" or lc == "pl.list" then listPlugins(); handled = true
    elseif not handled and lc:sub(1,3) == "pl." and lc:sub(1,10) ~= "pl.backup." and not lc:match("%.help$") and not lc:match("%.info$") then
        local name, action = lc:match("^pl%.(.+)%.([%w_]+)$")
        if name and action then
            if action == "load" then loadPlugin(name) elseif action == "unload" then unloadPlugin(name) elseif action == "reload" then unloadPlugin(name, true); loadPlugin(name) else log("Unknown", "Error") end
            if saveConfig then pcall(saveConfig) end; handled = true
        end
    end
    if not handled and (lc == "lib" or lc == "lib.list") then listLibs(); handled = true
    elseif not handled and lc:sub(1,4) == "lib." and lc:sub(1,11) ~= "lib.backup." and not lc:match("%.help$") and not lc:match("%.info$") then
        local name, action = lc:match("^lib%.(.+)%.([%w_]+)$")
        if name and action then
            if action == "load" then loadLibrary(name) elseif action == "unload" then unloadLibrary(name) elseif action == "reload" then unloadLibrary(name, true); loadLibrary(name) else log("Unknown", "Error") end
            if saveConfig then pcall(saveConfig) end; handled = true
        end
    end

    -- Обычные команды
    if not handled then
        local f = commands[cmdName]
        if f then local ok, e = pcall(f, args); if not ok then log("Error: "..tostring(e), "Error") end
        else executeLua(text) end
    end
end

CommandBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local text = CommandBox.Text; if text == "" then return end
    CommandBox.Text = ""
    if #commandHistory == 0 or commandHistory[#commandHistory] ~= text then table.insert(commandHistory, text); if #commandHistory > CONFIG.MaxHistory then table.remove(commandHistory, 1) end end
    historyIndex = #commandHistory + 1
    handleCommand(text)
end)

-- ============ RESIZE ============
local resizing, startSize, startMouse = false, nil, nil
ResizeHandle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing=true; startSize=ConsoleFrame.AbsoluteSize; startMouse=input.Position end end)
UIS.InputChanged:Connect(function(input) if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then local d = input.Position - startMouse; ConsoleFrame.Size = UDim2.new(0, math.max(300, startSize.X+d.X), 0, math.max(150, startSize.Y+d.Y)) end end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)

CloseBtn.MouseButton1Click:Connect(function() if logConnection then logConnection:Disconnect(); logConnection = nil end; ScreenGui:Destroy() end)

-- ============ STARTUP ============
local LoadingCard = Instance.new("Frame")
LoadingCard.Size = UDim2.new(0, 320, 0, 190); LoadingCard.Position = UDim2.new(0.5, -160, 0.5, -95)
LoadingCard.BackgroundColor3 = Color3.fromRGB(18, 18, 18); LoadingCard.BackgroundTransparency = 0.08; LoadingCard.BorderSizePixel = 0; LoadingCard.ZIndex = 100; LoadingCard.Parent = ScreenGui
Instance.new("UICorner", LoadingCard).CornerRadius = UDim.new(0, 10)

local loadStroke = Instance.new("UIStroke")
loadStroke.Color = Color3.fromRGB(255, 255, 255); loadStroke.Thickness = 1.2; loadStroke.Transparency = 0.8; loadStroke.Parent = LoadingCard

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(1, 0, 0, 36); loadTitle.Position = UDim2.new(0, 0, 0, 22)
loadTitle.BackgroundTransparency = 1; loadTitle.Text = "XCONSOLE"; loadTitle.Font = Enum.Font.Code
loadTitle.TextSize = 28; loadTitle.TextColor3 = Color3.fromRGB(255, 255, 255); loadTitle.TextTransparency = 1; loadTitle.ZIndex = 101; loadTitle.Parent = LoadingCard

local loadSubtitle = Instance.new("TextLabel")
loadSubtitle.Size = UDim2.new(1, 0, 0, 20); loadSubtitle.Position = UDim2.new(0, 0, 0, 62)
loadSubtitle.BackgroundTransparency = 1; loadSubtitle.Text = "loaded"; loadSubtitle.Font = Enum.Font.Code
loadSubtitle.TextSize = 16; loadSubtitle.TextColor3 = Color3.fromRGB(180, 180, 180); loadSubtitle.TextTransparency = 1; loadSubtitle.ZIndex = 101; loadSubtitle.Parent = LoadingCard

local loadVersion = Instance.new("TextLabel")
loadVersion.Size = UDim2.new(1, 0, 0, 18); loadVersion.Position = UDim2.new(0, 0, 0, 86)
loadVersion.BackgroundTransparency = 1; loadVersion.Text = "v 3.0.0"; loadVersion.Font = Enum.Font.Code
loadVersion.TextSize = 13; loadVersion.TextColor3 = Color3.fromRGB(120, 120, 120); loadVersion.TextTransparency = 1; loadVersion.ZIndex = 101; loadVersion.Parent = LoadingCard

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0, 240, 0, 4); loadBarBg.Position = UDim2.new(0.5, -120, 0, 130)
loadBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); loadBarBg.BackgroundTransparency = 1; loadBarBg.BorderSizePixel = 0; loadBarBg.ZIndex = 101; loadBarBg.Parent = LoadingCard
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(1, 0)

local loadBarFill = Instance.new("Frame")
loadBarFill.Size = UDim2.new(0, 0, 1, 0); loadBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
loadBarFill.BackgroundTransparency = 1; loadBarFill.BorderSizePixel = 0; loadBarFill.ZIndex = 102; loadBarFill.Parent = loadBarBg
Instance.new("UICorner", loadBarFill).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    local tInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(loadTitle, tInfo, { TextTransparency = 0 }):Play(); task.wait(0.18)
    TweenService:Create(loadSubtitle, tInfo, { TextTransparency = 0 }):Play(); task.wait(0.12)
    TweenService:Create(loadVersion, tInfo, { TextTransparency = 0 }):Play(); task.wait(0.12)
    TweenService:Create(loadBarBg, tInfo, { BackgroundTransparency = 0.5 }):Play()
    TweenService:Create(loadBarFill, tInfo, { BackgroundTransparency = 0 }):Play()

    local function setProgress(pct, msg)
        if msg then loadSubtitle.Text = msg end
        TweenService:Create(loadBarFill, TweenInfo.new(0.22, Enum.EasingStyle.Quad), { Size = UDim2.new(pct, 0, 1, 0) }):Play()
    end

    setProgress(0.10, "waiting for game..."); local t0 = tick()
    while not game:IsLoaded() and tick() - t0 < 10 do task.wait(0.05) end
    setProgress(0.30, "waiting for player..."); local t1 = tick()
    while (not LocalPlayer or not LocalPlayer.Character) and tick() - t1 < 6 do pcall(function() if LocalPlayer and not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end end); task.wait(0.05) end
    setProgress(0.55, "loading libraries..."); task.wait(0.3)
    setProgress(0.80, "finalizing..."); if LocalPlayer.Character then pcall(function() LocalPlayer.Character:WaitForChild("Humanoid", 3) end) end
    setProgress(1.00, "ready"); task.wait(0.35)

    local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(LoadingCard, fadeInfo, { BackgroundTransparency = 1, Position = LoadingCard.Position - UDim2.new(0, 0, 0, 15) }):Play()
    TweenService:Create(loadStroke, fadeInfo, { Transparency = 1 }):Play()
    TweenService:Create(loadTitle, fadeInfo, { TextTransparency = 1 }):Play()
    TweenService:Create(loadSubtitle, fadeInfo, { TextTransparency = 1 }):Play()
    TweenService:Create(loadVersion, fadeInfo, { TextTransparency = 1 }):Play()
    TweenService:Create(loadBarBg, fadeInfo, { BackgroundTransparency = 1 }):Play()
    local lastFade = TweenService:Create(loadBarFill, fadeInfo, { BackgroundTransparency = 1 })
    lastFade:Play(); lastFade.Completed:Wait()
    LoadingCard:Destroy()

    if currentDevice == "Phone" and consoleHidden then PhoneIconBtn.Visible = true
    else ConsoleFrame.Visible = true end
end)

task.defer(function()
    local success, err = pcall(function()
        task.wait(0.1); if isfile then loadConfig() end; task.wait(0.2)
        for _, l in ipairs(WORKSHOP_LIBS) do if l.isSystem then pcall(loadLibrary, l.libId) end end
        task.wait(0.2); autoLoadLibsFromGitHub(); task.wait(0.5); captureOriginalSpeed()
    end)
    if not success then log("Startup error: "..tostring(err), "Error", true) end
    task.wait(1); log("=== XCONSOLE READY ===", "Success", true)
end)

game:BindToClose(function() if saveConfig then pcall(saveConfig) end end)
