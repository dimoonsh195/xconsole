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

-- ============ FORWARD DECLS ============
local SaveBtn, LoadBtn, eventsTitleLabel, eventBoxes, eventLabels
local SettingsFrame, SettingsScroll, SettingsTitle, BackBtn, LangPopup
local themeButtons, langButtons, themeLabel, langLabel, secretBtn, win10Btn, langOpenBtn
local bgRow, bgBox, bgApplyBtn, bgLabel
local HideBtn, ExtraIcon, SettingsBtn, PhoneIconBtn
local devicePCStroke, devicePhoneStroke
local premiumEnabled = false
local customBgId = ""
local currentDevice = "PC"
local commands = {}
local applyThemeToSettings, saveConfig, refreshThemeButtons, refreshUILabels, setupBind
local SECRET = "100110101011000101"
local WIN10_THEME_ID = "13932338252"
eventBoxes = {}; eventLabels = {}
themeButtons = {}; langButtons = {}

-- ===================== ЛОКАЛИЗАЦИЯ =====================
local LANG = "en"
local LOC = {
    en = { title="CONSOLE", placeholder="Enter command or Lua code...", settings_title="SETTINGS", theme="Theme",
        theme_default="Default", theme_winter="Winter", theme_halloween="Halloween",
        language="Language", back="Back", save_cfg="Save config", load_cfg="Load config",
        select_device="Select device",
        events_title="Events (command or Lua code)", ev_onkilled="onKilled", ev_ondied="onDied",
        ev_onspawn="onSpawn", ev_onexecute="onExecute", ev_onjoin="onJoin", ev_ondamage="onDamage", ev_onleave="onLeave",
        cfg_saved="Config saved", cfg_loaded="Config loaded", cfg_fail="Config operation failed",
        theme_set="Theme set: ", lang_set="Language set: ", corner_set="Corner set: ", corner_reset="Corner reset to default",
        unloaded="Console unloaded", settings_hint="Type 'settings' to open the panel", loaded="CONSOLE loaded. Type help.",
        lua_compile="Lua compile error: ", lua_runtime="Lua runtime error: ", no_char="No character",
        select_lang="Select Language", custom_bg="Custom Background (Asset ID)", apply="Apply", premium_req="Premium required" },
    ru = { title="КОНСОЛЬ", placeholder="Введите команду или Lua-код...", settings_title="НАСТРОЙКИ", theme="Тема",
        theme_default="Обычная", theme_winter="Зимняя", theme_halloween="Хэллоуин",
        language="Язык", back="Назад", save_cfg="Сохранить конфиг", load_cfg="Загрузить конфиг",
        select_device="Выбор устройства",
        events_title="События (команда или Lua-код)", ev_onkilled="onKilled", ev_ondied="onDied",
        ev_onspawn="onSpawn", ev_onexecute="onExecute", ev_onjoin="onJoin", ev_ondamage="onDamage", ev_onleave="onLeave",
        cfg_saved="Конфиг сохранён", cfg_loaded="Конфиг загружен", cfg_fail="Ошибка операции с конфигом",
        theme_set="Тема установлена: ", lang_set="Язык установлен: ", corner_set="Скругление установлено: ", corner_reset="Скругление сброшено",
        unloaded="Консоль выгружена", settings_hint="Введите 'settings' чтобы открыть панель", loaded="КОНСОЛЬ загружена. Введите help.",
        lua_compile="Ошибка компиляции Lua: ", lua_runtime="Ошибка выполнения Lua: ", no_char="Нет персонажа",
        select_lang="Выбор языка", custom_bg="Свой фон (Asset ID)", apply="Применить", premium_req="Требуется Premium" },
    zh = { title="控制台", placeholder="输入命令或 Lua 代码...", settings_title="设置", theme="主题",
        theme_default="默认", theme_winter="冬季", theme_halloween="万圣节", language="语言", back="返回",
        save_cfg="保存配置", load_cfg="加载配置", events_title="事件（命令或 Lua 代码）", select_device="选择设备",
        cfg_saved="配置已保存", cfg_loaded="配置已加载", cfg_fail="配置操作失败",
        theme_set="主题已设置：", lang_set="语言已设置：", corner_set="圆角已设置：", corner_reset="圆角已重置为默认",
        unloaded="控制台已卸载", settings_hint="输入 'settings' 打开面板", loaded="控制台已加载。输入 help。",
        lua_compile="Lua 编译错误：", lua_runtime="Lua 运行时错误：", no_char="没有角色",
        select_lang="选择语言", custom_bg="自定义背景 (Asset ID)", apply="应用", premium_req="需要高级版" },
    ja = { title="コンソール", placeholder="コマンドまたは Lua コードを入力...", settings_title="設定", theme="テーマ",
        theme_default="デフォルト", theme_winter="冬", theme_halloween="ハロウィン", language="言語", back="戻る",
        save_cfg="設定を保存", load_cfg="設定を読み込む", events_title="イベント（コマンドまたは Lua コード）", select_device="デバイスを選択",
        cfg_saved="設定を保存しました", cfg_loaded="設定を読み込みました", cfg_fail="設定操作に失敗しました",
        theme_set="テーマ設定：", lang_set="言語設定：", corner_set="角丸設定：", corner_reset="角丸をデフォルトに戻しました",
        unloaded="コンソールをアンロードしました", settings_hint="'settings' でパネルを開く", loaded="コンソール読み込み完了。help を入力。",
        lua_compile="Lua コンパイルエラー：", lua_runtime="Lua 実行時エラー：", no_char="キャラクターがいません",
        select_lang="言語を選択", custom_bg="カスタム背景 (Asset ID)", apply="適用", premium_req="プレミアムが必要" },
    uk = { title="КОНСОЛЬ", placeholder="Введіть команду або Lua-код...", settings_title="НАЛАШТУВАННЯ", theme="Тема",
        theme_default="Звичайна", theme_winter="Зимова", theme_halloween="Хелловін", language="Мова", back="Назад",
        save_cfg="Зберегти конфіг", load_cfg="Завантажити конфіг", events_title="Події (команда або Lua-код)", select_device="Обрати пристрій",
        cfg_saved="Конфіг збережено", cfg_loaded="Конфіг завантажено", cfg_fail="Помилка операції з конфігом",
        theme_set="Тему встановлено: ", lang_set="Мову встановлено: ", corner_set="Заокруглення встановлено: ", corner_reset="Заокруглення скинуто",
        unloaded="Консоль вивантажено", settings_hint="Введіть 'settings' щоб відкрити панель", loaded="КОНСОЛЬ завантажена. Введіть help.",
        lua_compile="Помилка компіляції Lua: ", lua_runtime="Помилка виконання Lua: ", no_char="Немає персонажа",
        select_lang="Обрати мову", custom_bg="Свій фон (Asset ID)", apply="Застосувати", premium_req="Потрібен Premium" },
    ko = { title="콘솔", placeholder="명령어 또는 Lua 코드 입력...", settings_title="설정", theme="테마",
        theme_default="기본", theme_winter="겨울", theme_halloween="할로윈", language="언어", back="뒤로",
        save_cfg="설정 저장", load_cfg="설정 불러오기", events_title="이벤트 (명령어 또는 Lua 코드)", select_device="기기 선택",
        cfg_saved="설정이 저장되었습니다", cfg_loaded="설정이 로드되었습니다", cfg_fail="설정 작업 실패",
        theme_set="테마 설정: ", lang_set="언어 설정: ", corner_set="모서리 설정: ", corner_reset="모서리가 기본값으로 재설정됨",
        unloaded="콘솔이 언로드되었습니다", settings_hint="'settings'를 입력하여 패널 열기", loaded="콘솔 로드 완료. help 입력.",
        lua_compile="Lua 컴파일 오류: ", lua_runtime="Lua 런타임 오류: ", no_char="캐릭터가 없습니다",
        select_lang="언어 선택", custom_bg="사용자 지정 배경 (Asset ID)", apply="적용", premium_req="프리미엄 필요" },
    de = { title="KONSOLE", placeholder="Befehl oder Lua-Code eingeben...", settings_title="EINSTELLUNGEN", theme="Thema",
        theme_default="Standard", theme_winter="Winter", theme_halloween="Halloween", language="Sprache", back="Zurück",
        save_cfg="Konfiguration speichern", load_cfg="Konfiguration laden", events_title="Ereignisse (Befehl oder Lua-Code)", select_device="Gerät auswählen",
        cfg_saved="Konfiguration gespeichert", cfg_loaded="Konfiguration geladen", cfg_fail="Konfigurationsvorgang fehlgeschlagen",
        theme_set="Thema gesetzt: ", lang_set="Sprache gesetzt: ", corner_set="Ecke gesetzt: ", corner_reset="Ecke auf Standard zurückgesetzt",
        unloaded="Konsole entladen", settings_hint="Geben Sie 'settings' ein, um das Panel zu öffnen", loaded="KONSOLE geladen. Geben Sie help ein.",
        lua_compile="Lua-Kompilierungsfehler: ", lua_runtime="Lua-Laufzeitfehler: ", no_char="Kein Charakter",
        select_lang="Sprache auswählen", custom_bg="Benutzerdefinierter Hintergrund (Asset ID)", apply="Anwenden", premium_req="Premium erforderlich" },
    it = { title="CONSOLE", placeholder="Inserisci comando o codice Lua...", settings_title="IMPOSTAZIONI", theme="Tema",
        theme_default="Predefinito", theme_winter="Inverno", theme_halloween="Halloween", language="Lingua", back="Indietro",
        save_cfg="Salva configurazione", load_cfg="Carica configurazione", events_title="Eventi (comando o codice Lua)", select_device="Seleziona dispositivo",
        cfg_saved="Configurazione salvata", cfg_loaded="Configurazione caricata", cfg_fail="Operazione di configurazione fallita",
        theme_set="Tema impostato: ", lang_set="Lingua impostata: ", corner_set="Angolo impostato: ", corner_reset="Angolo ripristinato",
        unloaded="Console scaricata", settings_hint="Digita 'settings' per aprire il pannello", loaded="CONSOLE caricata. Digita help.",
        lua_compile="Errore di compilazione Lua: ", lua_runtime="Errore di runtime Lua: ", no_char="Nessun personaggio",
        select_lang="Seleziona lingua", custom_bg="Sfondo personalizzato (Asset ID)", apply="Applica", premium_req="Premium richiesto" },
    es = { title="CONSOLA", placeholder="Ingresa comando o código Lua...", settings_title="AJUSTES", theme="Tema",
        theme_default="Predeterminado", theme_winter="Invierno", theme_halloween="Halloween", language="Idioma", back="Atrás",
        save_cfg="Guardar configuración", load_cfg="Cargar configuración", events_title="Eventos (comando o código Lua)", select_device="Seleccionar dispositivo",
        cfg_saved="Configuración guardada", cfg_loaded="Configuración cargada", cfg_fail="Operación de configuración fallida",
        theme_set="Tema establecido: ", lang_set="Idioma establecido: ", corner_set="Esquina establecida: ", corner_reset="Esquina restablecida",
        unloaded="Consola descargada", settings_hint="Escribe 'settings' para abrir el panel", loaded="CONSOLA cargada. Escribe help.",
        lua_compile="Error de compilación Lua: ", lua_runtime="Error de tiempo de ejecución Lua: ", no_char="Sin personaje",
        select_lang="Seleccionar idioma", custom_bg="Fondo personalizado (Asset ID)", apply="Aplicar", premium_req="Se requiere Premium" },
}
local function T(key, ...)
    local s = (LOC[LANG] and LOC[LANG][key]) or LOC.en[key] or key
    if select("#", ...) > 0 then return string.format(s, ...) end
    return s
end

-- ===================== ТЕМЫ =====================
local THEMES = {
    default = { background=Color3.fromRGB(15,15,15), header=Color3.fromRGB(25,25,25), input=Color3.fromRGB(30,30,30),
                log=Color3.fromRGB(10,10,10), accent=Color3.fromRGB(255,255,255), text=Color3.fromRGB(255,255,255),
                stroke=Color3.fromRGB(255,255,255) },
    winter = { background=Color3.fromRGB(80,140,200), header=Color3.fromRGB(60,120,180), input=Color3.fromRGB(100,160,215),
               log=Color3.fromRGB(50,110,170), accent=Color3.fromRGB(220,240,255), text=Color3.fromRGB(240,250,255),
               stroke=Color3.fromRGB(180,220,255) },
    halloween = { background=Color3.fromRGB(45,28,15), header=Color3.fromRGB(60,38,20), input=Color3.fromRGB(55,35,18),
                  log=Color3.fromRGB(35,20,10), accent=Color3.fromRGB(255,140,0), text=Color3.fromRGB(255,160,40),
                  stroke=Color3.fromRGB(255,140,0) },
    [SECRET] = { background=Color3.fromRGB(60,60,60), header=Color3.fromRGB(40,40,40), input=Color3.fromRGB(50,50,50),
                 log=Color3.fromRGB(30,30,30), accent=Color3.fromRGB(220,220,220), text=Color3.fromRGB(235,235,235),
                 stroke=Color3.fromRGB(140,140,140) },
    win10 = { background=Color3.fromRGB(20,20,20), header=Color3.fromRGB(35,35,35), input=Color3.fromRGB(45,45,45),
              log=Color3.fromRGB(15,15,15), accent=Color3.fromRGB(0,120,215), text=Color3.fromRGB(240,240,240),
              stroke=Color3.fromRGB(0,120,215) },
    custom = { background=Color3.fromRGB(20,20,20), header=Color3.fromRGB(35,35,35), input=Color3.fromRGB(45,45,45),
               log=Color3.fromRGB(15,15,15), accent=Color3.fromRGB(255,255,255), text=Color3.fromRGB(240,240,240),
               stroke=Color3.fromRGB(255,255,255) },
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
local COLORS = {
    Error=Color3.fromRGB(255,100,100), Success=Color3.fromRGB(100,255,100),
    Info=Color3.fromRGB(255,200,100), Echo=Color3.fromRGB(150,150,150),
    Default=Color3.fromRGB(255,255,255), Output=Color3.fromRGB(200,200,255),
}
local CMD_COLORS = {
    ["0"]=Color3.fromRGB(0,0,0),["1"]=Color3.fromRGB(0,0,128),["2"]=Color3.fromRGB(0,128,0),
    ["3"]=Color3.fromRGB(0,128,128),["4"]=Color3.fromRGB(128,0,0),["5"]=Color3.fromRGB(128,0,128),
    ["6"]=Color3.fromRGB(128,128,0),["7"]=Color3.fromRGB(192,192,192),["8"]=Color3.fromRGB(128,128,128),
    ["9"]=Color3.fromRGB(0,0,255),["A"]=Color3.fromRGB(0,255,0),["B"]=Color3.fromRGB(0,255,255),
    ["C"]=Color3.fromRGB(255,0,0),["D"]=Color3.fromRGB(255,0,255),["E"]=Color3.fromRGB(255,255,0),
    ["F"]=Color3.fromRGB(255,255,255),
}

-- ===================== СОСТОЯНИЕ =====================
local commandHistory, historyIndex = {}, 0
local logConnection = nil
local binds, bindConns = {}, {}
local STATES = {
    flying=false, flyConn=nil, noclip=false, noclipConn=nil,
    esp=false, espFolder=nil, espConn=nil, swim=false, swimConn=nil,
    fling=false, flingConn=nil, infjump=false, infjumpConn=nil,
    spasm=false, spasmConn=nil, fullbright=false, fbBackup=nil,
    nofog=false, fogBackup=nil,
    enableDrop=false, dropConn=nil,
    enableJump=false, jumpConn=nil, jumpBackup=nil, jumpRequestConn=nil,
    enableSit=false, sitInputConn=nil,
    enableZoom=false, zoomConn=nil, zoomBackup=nil,
    velocityActive=false, velocityConn=nil, velocityCollideBackup=nil, velocitySpeedBackup=nil,
    events = { onKilled="", onDied="", onSpawn="", onExecute="", onJoin="", onDamage="", onLeave="" },
}

local originalWalkSpeed = nil
local speedCaptured = false
local consoleHidden = false

local CONFIG_FILE = "xconsole_config.json"

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui); if ok and hui then return hui end
    end
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

-- ===================== UI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleConsole"; ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true; ScreenGui.DisplayOrder = 5000; ScreenGui.Parent = guiParent

local ConsoleFrame = Instance.new("Frame")
ConsoleFrame.Size = UDim2.new(0,600,0,350); ConsoleFrame.Position = UDim2.new(0,20,0,20)
ConsoleFrame.BackgroundColor3 = THEMES.default.background; ConsoleFrame.BackgroundTransparency = 0.1
ConsoleFrame.BorderSizePixel = 0; ConsoleFrame.Active = true; ConsoleFrame.Draggable = true
ConsoleFrame.Parent = ScreenGui
local consoleCorner = Instance.new("UICorner", ConsoleFrame); consoleCorner.CornerRadius = UDim.new(0,6)

local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1,0,1,0); bgImage.Position = UDim2.new(0,0,0,0)
bgImage.BackgroundTransparency = 1
bgImage.ImageTransparency = 0
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 1; bgImage.Visible = false
bgImage.Parent = ConsoleFrame
Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0,6)

local stroke = Instance.new("UIStroke")
stroke.Color = THEMES.default.stroke; stroke.Thickness = 1; stroke.Transparency = 0.5; stroke.Parent = ConsoleFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,30); Header.BackgroundColor3 = THEMES.default.header
Header.BackgroundTransparency = 0.2; Header.BorderSizePixel = 0; Header.ZIndex = 2; Header.Parent = ConsoleFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,6)

-- Логотип
local Title = Instance.new("ImageLabel")
Title.Size = UDim2.new(0,26,0,26); Title.Position = UDim2.new(0,4,0,2)
Title.BackgroundTransparency = 1
Title.Image = getIcon(54479712)
Title.ScaleType = Enum.ScaleType.Fit
Title.ZIndex = 3; Title.Parent = Header

-- ExtraIcon (левее настроек)
ExtraIcon = Instance.new("ImageLabel")
ExtraIcon.Size = UDim2.new(0,24,0,24); ExtraIcon.Position = UDim2.new(1,-110,0,3)
ExtraIcon.BackgroundTransparency = 1
ExtraIcon.Image = getIcon(2484276650)
ExtraIcon.ScaleType = Enum.ScaleType.Fit
ExtraIcon.ZIndex = 3; ExtraIcon.Parent = Header

-- Кнопка настроек (9405931596) — вызывает команду settings с логированием
SettingsBtn = Instance.new("ImageButton")
SettingsBtn.Size = UDim2.new(0,24,0,24); SettingsBtn.Position = UDim2.new(1,-84,0,3)
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Image = getIcon(9405931596)
SettingsBtn.ScaleType = Enum.ScaleType.Fit
SettingsBtn.ZIndex = 3; SettingsBtn.Parent = Header

-- Кнопка скрытия (толстая белая черта)
HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0,28,0,28); HideBtn.Position = UDim2.new(1,-58,0,1)
HideBtn.BackgroundTransparency = 1
HideBtn.Text = ""
HideBtn.BorderSizePixel = 0; HideBtn.ZIndex = 3; HideBtn.Parent = Header

local HideDash = Instance.new("Frame")
HideDash.Size = UDim2.new(0,16,0,3); HideDash.Position = UDim2.new(0.5,-8,0.5,-1.5)
HideDash.BackgroundColor3 = Color3.fromRGB(255,255,255)
HideDash.BorderSizePixel = 0; HideDash.ZIndex = 4; HideDash.Parent = HideBtn
Instance.new("UICorner", HideDash).CornerRadius = UDim.new(1,0)

-- Кнопка закрытия
local CloseBtn = Instance.new("ImageButton")
CloseBtn.Size = UDim2.new(0,24,0,24); CloseBtn.Position = UDim2.new(1,-28,0,3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = getIcon(111716979356360)
CloseBtn.ScaleType = Enum.ScaleType.Fit
CloseBtn.ZIndex = 3; CloseBtn.Parent = Header

-- Иконка телефона (появляется при скрытии на телефоне)
PhoneIconBtn = Instance.new("ImageButton")
PhoneIconBtn.Size = UDim2.new(0, 40, 0, 40)
PhoneIconBtn.Position = UDim2.new(0, 20, 0, 20)
PhoneIconBtn.BackgroundTransparency = 1
PhoneIconBtn.Image = getIcon(54479712)
PhoneIconBtn.ScaleType = Enum.ScaleType.Fit
PhoneIconBtn.Visible = false
PhoneIconBtn.ZIndex = 10
PhoneIconBtn.Parent = ScreenGui

PhoneIconBtn.MouseButton1Click:Connect(function()
    consoleHidden = false
    ConsoleFrame.Visible = true
    PhoneIconBtn.Visible = false
end)

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1,-10,1,-75); LogFrame.Position = UDim2.new(0,5,0,35)
LogFrame.BackgroundColor3 = THEMES.default.log; LogFrame.BackgroundTransparency = 0.3
LogFrame.BorderSizePixel = 0; LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = THEMES.default.accent; LogFrame.CanvasSize = UDim2.new(0,0,0,0)
LogFrame.ZIndex = 2; LogFrame.Parent = ConsoleFrame
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0,4)

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder; logLayout.Padding = UDim.new(0,2); logLayout.Parent = LogFrame

local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1,-10,0,30); InputFrame.Position = UDim2.new(0,5,1,-35)
InputFrame.BackgroundColor3 = THEMES.default.input; InputFrame.BackgroundTransparency = 0.2
InputFrame.BorderSizePixel = 0; InputFrame.ZIndex = 2; InputFrame.Parent = ConsoleFrame
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0,4)

local CommandBox = Instance.new("TextBox")
CommandBox.Size = UDim2.new(1,-10,1,-6); CommandBox.Position = UDim2.new(0,5,0,3)
CommandBox.BackgroundTransparency = 1; CommandBox.Text = ""
CommandBox.PlaceholderText = T("placeholder"); CommandBox.PlaceholderColor3 = Color3.fromRGB(100,100,100)
CommandBox.TextColor3 = THEMES.default.accent; CommandBox.Font = CONFIG.Font; CommandBox.TextSize = 16
CommandBox.TextXAlignment = Enum.TextXAlignment.Left; CommandBox.ClearTextOnFocus = false
CommandBox.ZIndex = 3; CommandBox.Parent = InputFrame

local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.new(0,16,0,16); ResizeHandle.Position = UDim2.new(1,-16,1,-16)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(50,50,50); ResizeHandle.Text = "◢"
ResizeHandle.TextColor3 = Color3.fromRGB(150,150,150); ResizeHandle.Font = CONFIG.Font
ResizeHandle.TextSize = 12; ResizeHandle.BorderSizePixel = 0; ResizeHandle.ZIndex = 5
ResizeHandle.Parent = ConsoleFrame
Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0,4)

-- ===================== ЛОГ =====================
local function log(text, colorType)
    local color = COLORS[colorType] or COLORS.Default
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-5,0,18); label.BackgroundTransparency = 1
    label.Text = "> " .. tostring(text); label.TextColor3 = color
    label.Font = CONFIG.Font; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = LogFrame
    LogFrame.CanvasSize = UDim2.new(0,0,0, logLayout.AbsoluteContentSize.Y + 10)
    task.wait()
    LogFrame.CanvasPosition = Vector2.new(0, LogFrame.CanvasSize.Y.Offset)
end

local function getSystemLogData(mt)
    if mt == Enum.MessageType.MessageError then return "[ERROR]", COLORS.Error
    elseif mt == Enum.MessageType.MessageWarning then return "[WARN]", COLORS.Info
    elseif mt == Enum.MessageType.MessageInfo then return "[INFO]", COLORS.Output
    else return "[OUTPUT]", COLORS.Output end
end

if logConnection then logConnection:Disconnect() end
logConnection = LogService.MessageOut:Connect(function(message, messageType)
    if not ConsoleFrame or not ConsoleFrame.Parent then
        if logConnection then logConnection:Disconnect() end; return
    end
    local prefix, color = getSystemLogData(messageType)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-5,0,18); label.BackgroundTransparency = 1
    label.Text = string.format("%s %s", prefix, tostring(message))
    label.TextColor3 = color; label.Font = CONFIG.Font; label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = LogFrame
    LogFrame.CanvasSize = UDim2.new(0,0,0, logLayout.AbsoluteContentSize.Y + 10)
    task.wait()
    LogFrame.CanvasPosition = Vector2.new(0, LogFrame.CanvasSize.Y.Offset)
end)

-- ===================== LUA EXEC =====================
local function executeLua(code)
    local fn, err = loadstring(code)
    if not fn then log(T("lua_compile") .. tostring(err), "Error"); return end
    local ok, e = pcall(fn)
    if not ok then log(T("lua_runtime") .. tostring(e), "Error") end
end

-- ===================== ФИЧИ =====================
local function getChar()
    local char = LocalPlayer.Character; if not char then return end
    return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

-- ===================== M249 =====================
local function giveGun()
    log("Creating M249...", "Info")
    local success, err = pcall(function()
        local char = LocalPlayer.Character
        if not char then error("No character") end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then error("No humanoid") end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not bp then error("No backpack") end
        if bp:FindFirstChild("M249") then bp.M249:Destroy() end
        if char:FindFirstChild("M249") then char.M249:Destroy() end

        local tool = Instance.new("Tool")
        tool.Name = "M249"; tool.RequiresHandle = true; tool.CanBeDropped = false; tool.ToolTip = "M249 SAW"

        local handle = Instance.new("Part")
        handle.Name = "Handle"; handle.Size = Vector3.new(0.5, 0.7, 3); handle.Color = Color3.fromRGB(35, 35, 35)
        handle.Material = Enum.Material.Metal; handle.TopSurface = Enum.SurfaceType.Smooth; handle.BottomSurface = Enum.SurfaceType.Smooth; handle.Parent = tool

        local barrel = Instance.new("Part")
        barrel.Size = Vector3.new(0.2, 0.2, 2.2); barrel.Color = Color3.fromRGB(20, 20, 20); barrel.Material = Enum.Material.Metal
        barrel.CanCollide = false; barrel.Massless = true; barrel.Parent = tool
        local weld = Instance.new("Weld"); weld.Part0 = handle; weld.Part1 = barrel; weld.C0 = CFrame.new(0, 0.1, -2.4); weld.Parent = handle

        local mag = Instance.new("Part")
        mag.Size = Vector3.new(0.35, 0.9, 0.4); mag.Color = Color3.fromRGB(25, 25, 25); mag.Material = Enum.Material.Metal
        mag.CanCollide = false; mag.Massless = true; mag.Parent = tool
        local magWeld = Instance.new("Weld"); magWeld.Part0 = handle; magWeld.Part1 = mag; magWeld.C0 = CFrame.new(0, -0.7, -0.6); magWeld.Parent = handle

        local muzzleFlash = Instance.new("ParticleEmitter")
        muzzleFlash.Texture = "rbxassetid://296874871"; muzzleFlash.LightEmission = 1; muzzleFlash.LightInfluence = 0
        muzzleFlash.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 0)})
        muzzleFlash.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
        muzzleFlash.Lifetime = NumberRange.new(0.05, 0.1); muzzleFlash.Rate = 0; muzzleFlash.Speed = NumberRange.new(0)
        muzzleFlash.Color = ColorSequence.new(Color3.fromRGB(255, 220, 100)); muzzleFlash.Parent = barrel

        local shootSound = Instance.new("Sound")
        shootSound.Name = "ShootSound"; shootSound.SoundId = "rbxassetid://131886985"; shootSound.Volume = 0.4; shootSound.Parent = handle

        local ammo = 200; local fireRate = 0.08; local firing = false; local fireDebounce = false

        local function fire()
            if fireDebounce then return end
            fireDebounce = true
            task.delay(fireRate, function() fireDebounce = false end)

            if ammo <= 0 then
                local clickSnd = Instance.new("Sound")
                clickSnd.SoundId = "rbxassetid://3531185870"; clickSnd.Volume = 0.3; clickSnd.Parent = handle
                clickSnd:Play(); Debris:AddItem(clickSnd, 1); return
            end
            ammo -= 1

            local s = shootSound:Clone(); s.Parent = handle; s.PlayOnRemove = true; s:Destroy()
            pcall(function() s:Play() end)

            muzzleFlash:Emit(8)

            local mouse = LocalPlayer:GetMouse()
            local camPos = Workspace.CurrentCamera.CFrame.Position
            local targetPos = mouse.Hit.Position
            local direction = (targetPos - camPos).Unit

            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = { char, tool }
            rayParams.IgnoreWater = true

            local result = Workspace:Raycast(camPos, direction * 1000, rayParams)
            local hitPos = result and result.Position or (camPos + direction * 1000)

            local origin = barrel.Position
            local tracer = Instance.new("Part")
            tracer.Size = Vector3.new(0.05, 0.05, (hitPos - origin).Magnitude)
            tracer.CFrame = CFrame.lookAt(origin, hitPos) * CFrame.new(0, 0, -tracer.Size.Z / 2)
            tracer.Anchored = true; tracer.CanCollide = false; tracer.Color = Color3.fromRGB(255, 200, 50)
            tracer.Material = Enum.Material.Neon; tracer.Transparency = 0.3; tracer.Parent = Workspace
            TweenService:Create(tracer, TweenInfo.new(0.1), { Transparency = 1 }):Play()
            Debris:AddItem(tracer, 0.15)

            if result and result.Instance then
                local hit = result.Instance
                if not hit:IsA("Terrain") then hit:Destroy() end
                local spark = Instance.new("Part")
                spark.Size = Vector3.new(0.1, 0.1, 0.1); spark.CFrame = CFrame.new(hitPos)
                spark.Anchored = true; spark.CanCollide = false; spark.Color = Color3.fromRGB(255, 150, 50)
                spark.Material = Enum.Material.Neon; spark.Parent = Workspace; Debris:AddItem(spark, 0.2)
            end
        end

        tool.Activated:Connect(function()
            firing = true
            while firing and tool.Parent and tool.Parent:IsA("Model") do fire(); task.wait(fireRate) end
        end)
        tool.Deactivated:Connect(function() firing = false end)
        tool.Unequipped:Connect(function() firing = false end)

        tool.Parent = bp; hum:EquipTool(tool)
        log("M249 given! Shoots exactly where you aim.", "Success")
    end)
    if not success then log("Failed to create M249: " .. tostring(err), "Error") end
end

local function toggleFly(on)
    local _, _, hrp = getChar()
    if not hrp then log(T("no_char"), "Error"); return end
    if on then
        if STATES.flying then return end
        STATES.flying = true
        local bv = Instance.new("BodyVelocity"); bv.Name="ConsoleFlyBV"
        bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.zero; bv.Parent=hrp
        local bg = Instance.new("BodyGyro"); bg.Name="ConsoleFlyBG"
        bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.P=1000; bg.D=50; bg.CFrame=hrp.CFrame; bg.Parent=hrp
        STATES.flyConn = RunService.RenderStepped:Connect(function()
            local _,_,root = getChar(); if not root then return end
            local cam = Workspace.CurrentCamera; local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
            if move.Magnitude > 0 then move = move.Unit * 50 end
            local b = root:FindFirstChild("ConsoleFlyBV"); if b then b.Velocity = move end
            local g = root:FindFirstChild("ConsoleFlyBG"); if g then g.CFrame = cam.CFrame end
        end)
    else
        if not STATES.flying then return end
        STATES.flying = false
        if STATES.flyConn then STATES.flyConn:Disconnect(); STATES.flyConn = nil end
        local _,_,hrp2 = getChar()
        if hrp2 then
            local b=hrp2:FindFirstChild("ConsoleFlyBV"); if b then b:Destroy() end
            local g=hrp2:FindFirstChild("ConsoleFlyBG"); if g then g:Destroy() end
        end
    end
end

local function toggleNoclip(on)
    STATES.noclip = on
    if on then
        if STATES.noclipConn then STATES.noclipConn:Disconnect() end
        STATES.noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if STATES.noclipConn then STATES.noclipConn:Disconnect(); STATES.noclipConn=nil end
    end
end

local function toggleESP(on)
    STATES.esp = on
    if on then
        if STATES.espFolder then STATES.espFolder:Destroy() end
        local folder = Instance.new("Folder"); folder.Name="ConsoleESP"; folder.Parent=guiParent
        STATES.espFolder = folder
        local function add(plr)
            if plr == LocalPlayer then return end
            local function setup(char)
                local hrp = char:WaitForChild("HumanoidRootPart", 5); if not hrp then return end
                local hl = Instance.new("Highlight"); hl.Adornee=char
                hl.FillColor=Color3.fromRGB(255,0,0); hl.OutlineColor=Color3.fromRGB(255,255,255)
                hl.FillTransparency=0.5; hl.Parent=folder
            end
            if plr.Character then setup(plr.Character) end
            plr.CharacterAdded:Connect(setup)
        end
        for _, p in ipairs(Players:GetPlayers()) do add(p) end
        STATES.espConn = Players.PlayerAdded:Connect(add)
    else
        if STATES.espFolder then STATES.espFolder:Destroy(); STATES.espFolder=nil end
        if STATES.espConn then STATES.espConn:Disconnect(); STATES.espConn=nil end
    end
end

local function toggleSwim(on)
    STATES.swim = on
    if on then
        if STATES.swimConn then STATES.swimConn:Disconnect() end
        STATES.swimConn = RunService.Heartbeat:Connect(function()
            local _,hum = getChar(); if hum then hum:ChangeState(Enum.HumanoidStateType.Swimming) end
        end)
    else
        if STATES.swimConn then STATES.swimConn:Disconnect(); STATES.swimConn=nil end
    end
end

local function toggleFling(on)
    STATES.fling = on
    if on then
        if STATES.flingConn then STATES.flingConn:Disconnect() end
        STATES.flingConn = RunService.Heartbeat:Connect(function()
            local _,_,hrp = getChar(); if not hrp then return end
            hrp.Velocity = Vector3.new(math.random(-5000,5000), math.random(-5000,5000), math.random(-5000,5000))
        end)
    else
        if STATES.flingConn then STATES.flingConn:Disconnect(); STATES.flingConn=nil end
    end
end

local function toggleInfJump(on)
    STATES.infjump = on
    if on then
        if STATES.infjumpConn then STATES.infjumpConn:Disconnect() end
        STATES.infjumpConn = UIS.JumpRequest:Connect(function()
            local _,hum = getChar(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if STATES.infjumpConn then STATES.infjumpConn:Disconnect(); STATES.infjumpConn=nil end
    end
end

local function toggleSpasm(on)
    STATES.spasm = on
    if on then
        if STATES.spasmConn then STATES.spasmConn:Disconnect() end
        STATES.spasmConn = RunService.Heartbeat:Connect(function()
            local _,_,hrp = getChar(); if not hrp then return end
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.random()*2, math.random()*2, math.random()*2)
        end)
    else
        if STATES.spasmConn then STATES.spasmConn:Disconnect(); STATES.spasmConn=nil end
    end
end

local function toggleFullbright(on)
    if on then
        if STATES.fullbright then return end
        STATES.fullbright = true
        STATES.fbBackup = { Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient,
            Brightness=Lighting.Brightness, FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart }
        Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        Lighting.Brightness=3; Lighting.FogEnd=1e6; Lighting.FogStart=1e6
    else
        if not STATES.fullbright then return end
        STATES.fullbright = false
        local b = STATES.fbBackup
        if b then
            Lighting.Ambient=b.Ambient; Lighting.OutdoorAmbient=b.OutdoorAmbient
            Lighting.Brightness=b.Brightness; Lighting.FogEnd=b.FogEnd; Lighting.FogStart=b.FogStart
            STATES.fbBackup = nil
        end
    end
end

local function toggleNofog(on)
    if on then
        if STATES.nofog then return end
        STATES.nofog = true
        STATES.fogBackup = { FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart }
        Lighting.FogEnd=1e6; Lighting.FogStart=1e6
    else
        if not STATES.nofog then return end
        STATES.nofog = false
        local b = STATES.fogBackup
        if b then Lighting.FogEnd=b.FogEnd; Lighting.FogStart=b.FogStart; STATES.fogBackup=nil end
    end
end

-- ===================== ТЕМА =====================
applyThemeToSettings = function(t)
    if not SettingsFrame then return end
    for _, obj in ipairs(SettingsFrame:GetDescendants()) do
        if obj:IsA("TextLabel") then obj.TextColor3 = t.text
        elseif obj:IsA("TextButton") then
            if obj ~= HideBtn then
                obj.TextColor3 = t.text; obj.BackgroundColor3 = t.input
            end
        elseif obj:IsA("TextBox") then obj.TextColor3 = t.text; obj.BackgroundColor3 = t.input end
    end
    for n, btn in pairs(themeButtons) do
        btn.BackgroundColor3 = (currentTheme == n) and t.accent or t.input
    end
    SettingsFrame.BackgroundColor3 = t.background
end

local function applyTheme(name)
    local t = THEMES[name]; if not t then return end
    currentTheme = name
    ConsoleFrame.BackgroundColor3 = t.background
    Header.BackgroundColor3 = t.header
    InputFrame.BackgroundColor3 = t.input
    LogFrame.BackgroundColor3 = t.log
    CommandBox.TextColor3 = t.accent
    stroke.Color = t.stroke; LogFrame.ScrollBarImageColor3 = t.accent
    
    if name == SECRET then
        bgImage.Image = getThumb("5456915026")
        bgImage.Visible = true
        ConsoleFrame.BackgroundTransparency = 0.9
        LogFrame.BackgroundTransparency = 0.55
        InputFrame.BackgroundTransparency = 0.45
        Header.BackgroundTransparency = 0.45
    elseif name == "win10" then
        bgImage.Image = getThumb(WIN10_THEME_ID)
        bgImage.Visible = true
        ConsoleFrame.BackgroundTransparency = 0.85
        LogFrame.BackgroundTransparency = 0.5
        InputFrame.BackgroundTransparency = 0.4
        Header.BackgroundTransparency = 0.4
    elseif name == "custom" then
        bgImage.Image = getThumb(customBgId)
        bgImage.Visible = true
        ConsoleFrame.BackgroundTransparency = 0.85
        LogFrame.BackgroundTransparency = 0.5
        InputFrame.BackgroundTransparency = 0.4
        Header.BackgroundTransparency = 0.4
    else
        bgImage.Visible = false
        ConsoleFrame.BackgroundTransparency = 0.1
        LogFrame.BackgroundTransparency = 0.3
        InputFrame.BackgroundTransparency = 0.2
        Header.BackgroundTransparency = 0.2
    end
    applyThemeToSettings(t)
end

-- ===================== НАСТРОЙКИ =====================
SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1,0,1,0); SettingsFrame.Position = UDim2.new(0,0,0,0)
SettingsFrame.BackgroundColor3 = THEMES.default.background
SettingsFrame.BackgroundTransparency = 0.05; SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false; SettingsFrame.ZIndex = 10; SettingsFrame.Parent = ConsoleFrame
Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0,6)

local function makeLabel(parent, text, y, size)
    local l = Instance.new("TextLabel")
    l.Size=UDim2.new(1,-20,0,size or 20); l.Position=UDim2.new(0,10,0,y)
    l.BackgroundTransparency=1; l.Text=text; l.TextColor3=THEMES.default.text
    l.Font=CONFIG.Font; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=11; l.Parent=parent
    return l
end
local function makeButton(parent, text, x, y, w, h, cb)
    local b = Instance.new("TextButton")
    b.Size=UDim2.new(0,w,0,h); b.Position=UDim2.new(0,x,0,y)
    b.BackgroundColor3=THEMES.default.input; b.Text=text; b.TextColor3=THEMES.default.text
    b.Font=CONFIG.Font; b.TextSize=13; b.BorderSizePixel=0; b.ZIndex=12; b.Parent=parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    b.MouseButton1Click:Connect(cb)
    return b
end

SettingsScroll = Instance.new("ScrollingFrame")
SettingsScroll.Size=UDim2.new(1,-10,1,-50); SettingsScroll.Position=UDim2.new(0,5,0,40)
SettingsScroll.BackgroundTransparency=1; SettingsScroll.BorderSizePixel=0
SettingsScroll.ScrollBarThickness=4; SettingsScroll.CanvasSize=UDim2.new(0,0,0,0)
SettingsScroll.ZIndex=11; SettingsScroll.Parent=SettingsFrame
local settingsLayout = Instance.new("UIListLayout")
settingsLayout.Padding=UDim.new(0,6); settingsLayout.SortOrder=Enum.SortOrder.LayoutOrder; settingsLayout.Parent=SettingsScroll

local function addSettingRow(widget)
    widget.LayoutOrder = #SettingsScroll:GetChildren()
    widget.Parent = SettingsScroll
    SettingsScroll.CanvasSize = UDim2.new(0,0,0, settingsLayout.AbsoluteContentSize.Y + 20)
end

-- Заголовок настроек — иконка
SettingsTitle = Instance.new("ImageLabel")
SettingsTitle.Size = UDim2.new(0,26,0,26); SettingsTitle.Position = UDim2.new(0,8,0,7)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Image = getIcon(9405931596)
SettingsTitle.ScaleType = Enum.ScaleType.Fit
SettingsTitle.ZIndex = 12; SettingsTitle.Parent = SettingsFrame

-- BackBtn — картинка, сдвинут правее
BackBtn = Instance.new("ImageButton")
BackBtn.Size = UDim2.new(0,40,0,24); BackBtn.Position = UDim2.new(1,-52,0,8)
BackBtn.BackgroundTransparency = 1
BackBtn.Image = getIcon(8674072445)
BackBtn.ScaleType = Enum.ScaleType.Fit
BackBtn.ZIndex = 12; BackBtn.Parent = SettingsFrame

-- Окно выбора языка
LangPopup = Instance.new("Frame")
LangPopup.Size = UDim2.new(1,0,1,0); LangPopup.Position = UDim2.new(0,0,0,0)
LangPopup.BackgroundColor3 = THEMES.default.background
LangPopup.BackgroundTransparency = 0.05; LangPopup.BorderSizePixel = 0
LangPopup.Visible = false; LangPopup.ZIndex = 15; LangPopup.Parent = ConsoleFrame
Instance.new("UICorner", LangPopup).CornerRadius = UDim.new(0,6)

local langTitle = makeLabel(LangPopup, T("select_lang"), 10, 30)
langTitle.ZIndex = 16

local langBack = makeButton(LangPopup, T("back"), 10, 10, 60, 24, function()
    LangPopup.Visible = false
    SettingsFrame.Visible = true
end)
langBack.Position = UDim2.new(1,-70,0,10)

local LANG_NAMES = { en="English", ru="Русский", zh="中文", ja="日本語", uk="Українська", ko="한국어", de="Deutsch", it="Italiano", es="Español" }
local langIdx = 0
for _, code in ipairs({"en","ru","zh","ja","uk","ko","de","it","es"}) do
    local b = makeButton(LangPopup, LANG_NAMES[code], 10 + (langIdx%3)*130, 50 + math.floor(langIdx/3)*40, 120, 30, function()
        LANG = code
        refreshUILabels()
        LangPopup.Visible = false
        SettingsFrame.Visible = true
        log(T("lang_set")..LANG_NAMES[code], "Success")
        if saveConfig then pcall(saveConfig) end
    end)
    b.ZIndex = 16
    langButtons[code] = b
    langIdx += 1
end

local function openSettings()
    SettingsFrame.Visible = true; SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.Position = UDim2.new(0,0,0,20)
    HideBtn.Visible = false
    CloseBtn.Visible = false
    ExtraIcon.Visible = false
    SettingsBtn.Visible = false
    TweenService:Create(SettingsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.05, Position = UDim2.new(0,0,0,0),
    }):Play()
end
local function closeSettings()
    local tw = TweenService:Create(SettingsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1, Position = UDim2.new(0,0,0,20),
    })
    tw:Play(); tw.Completed:Once(function()
        SettingsFrame.Visible = false
        HideBtn.Visible = true
        CloseBtn.Visible = true
        ExtraIcon.Visible = true
        SettingsBtn.Visible = true
    end)
end
BackBtn.MouseButton1Click:Connect(closeSettings)

-- ТЕМЫ
local themeRow = Instance.new("Frame")
themeRow.Size=UDim2.new(1,-20,0,60); themeRow.BackgroundTransparency=1; themeRow.ZIndex=11
themeLabel = makeLabel(themeRow, T("theme"), 0, 18)

local tidx = 0
for _, name in ipairs({"default","winter","halloween"}) do
    local b = makeButton(themeRow, T("theme_"..name), tidx*110, 22, 100, 26, function()
        applyTheme(name); refreshThemeButtons(); log(T("theme_set")..name, "Success")
        if saveConfig then pcall(saveConfig) end
    end)
    themeButtons[name] = b; tidx += 1
end

secretBtn = makeButton(themeRow, "Code", tidx*110, 22, 100, 26, function()
    if premiumEnabled then
        applyTheme(SECRET); refreshThemeButtons(); log("Theme set: Code", "Success")
        if saveConfig then pcall(saveConfig) end
    end
end)
themeButtons[SECRET] = secretBtn; secretBtn.Visible = false

win10Btn = makeButton(themeRow, "Windows 10", (tidx+1)*110, 22, 100, 26, function()
    if premiumEnabled then
        applyTheme("win10"); refreshThemeButtons(); log("Theme set: Windows 10", "Success")
        if saveConfig then pcall(saveConfig) end
    end
end)
themeButtons["win10"] = win10Btn; win10Btn.Visible = false
addSettingRow(themeRow)

refreshThemeButtons = function()
    local t = THEMES[currentTheme] or THEMES.default
    for n, btn in pairs(themeButtons) do
        btn.BackgroundColor3 = (currentTheme==n) and t.accent or t.input
    end
end
refreshThemeButtons()

-- ЯЗЫКИ
local langRow = Instance.new("Frame")
langRow.Size=UDim2.new(1,-20,0,60); langRow.BackgroundTransparency=1; langRow.ZIndex=11
langLabel = makeLabel(langRow, T("language"), 0, 18)

langOpenBtn = makeButton(langRow, "English", 0, 22, 100, 26, function()
    SettingsFrame.Visible = false
    LangPopup.Visible = true
end)
addSettingRow(langRow)

-- ВЫБОР УСТРОЙСТВА (ПК / Телефон)
local deviceRow = Instance.new("Frame")
deviceRow.Size = UDim2.new(1,-20,0,75); deviceRow.BackgroundTransparency = 1; deviceRow.ZIndex = 11
local deviceLabel = makeLabel(deviceRow, T("select_device"), 0, 18)

local function makeDeviceBtn(imgId, x, name)
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(0, x, 0, 22)
    btn.BackgroundTransparency = 1
    btn.Image = getIcon(imgId)
    btn.ScaleType = Enum.ScaleType.Fit
    btn.ZIndex = 12
    btn.Parent = deviceRow

    local strk = Instance.new("UIStroke")
    strk.Color = Color3.fromRGB(255,255,255)
    strk.Thickness = 2
    strk.Transparency = 1
    strk.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentDevice = name
        if name == "PC" then
            devicePCStroke.Transparency = 0
            devicePhoneStroke.Transparency = 1
            PhoneIconBtn.Visible = false
            consoleHidden = false
            ConsoleFrame.Visible = true
        else
            devicePCStroke.Transparency = 1
            devicePhoneStroke.Transparency = 0
            if consoleHidden then
                ConsoleFrame.Visible = false
                PhoneIconBtn.Visible = true
            end
        end
        if saveConfig then pcall(saveConfig) end
    end)
    return btn, strk
end

local pcBtn, pcs = makeDeviceBtn(12684119292, 0, "PC")
local phoneBtn, phones = makeDeviceBtn(134410350720078, 50, "Phone")
devicePCStroke = pcs
devicePhoneStroke = phones

addSettingRow(deviceRow)

-- КАСТОМНЫЙ ФОН
bgRow = Instance.new("Frame")
bgRow.Size = UDim2.new(1,-20,0,60); bgRow.BackgroundTransparency=1; bgRow.ZIndex=11
bgRow.Visible = false
bgLabel = makeLabel(bgRow, T("custom_bg"), 0, 18)
bgBox = Instance.new("TextBox")
bgBox.Size = UDim2.new(0,200,0,26); bgBox.Position = UDim2.new(0,0,0,22)
bgBox.BackgroundColor3 = THEMES.default.input; bgBox.TextColor3 = THEMES.default.text
bgBox.Font = CONFIG.Font; bgBox.TextSize = 13; bgBox.Text = ""; bgBox.PlaceholderText = "rbxassetid://..."
bgBox.ZIndex = 12; bgBox.Parent = bgRow
Instance.new("UICorner", bgBox).CornerRadius = UDim.new(0,4)

bgApplyBtn = makeButton(bgRow, T("apply"), 210, 22, 80, 26, function()
    if premiumEnabled and bgBox.Text ~= "" then
        customBgId = bgBox.Text:match("%d+") or bgBox.Text
        applyTheme("custom")
        refreshThemeButtons()
        log("Custom background applied", "Success")
        if saveConfig then pcall(saveConfig) end
    end
end)
addSettingRow(bgRow)

refreshUILabels = function()
    CommandBox.PlaceholderText = T("placeholder")
    for name, btn in pairs(themeButtons) do
        if name ~= SECRET and name ~= "win10" then btn.Text = T("theme_"..name) end
    end
    themeLabel.Text = T("theme"); langLabel.Text = T("language")
    deviceLabel.Text = T("select_device")
    if langOpenBtn then langOpenBtn.Text = LANG_NAMES[LANG] or "English" end
    langTitle.Text = T("select_lang")
    if bgLabel then bgLabel.Text = T("custom_bg") end
    if bgApplyBtn then bgApplyBtn.Text = T("apply") end
    if SaveBtn then SaveBtn.Text = T("save_cfg") end
    if LoadBtn then LoadBtn.Text = T("load_cfg") end
    if eventsTitleLabel then eventsTitleLabel.Text = T("events_title") end
    for evName, lbl in pairs(eventLabels) do lbl.Text = T("ev_"..evName:lower()) end
    local t = THEMES[currentTheme] or THEMES.default
    for c, bb in pairs(langButtons) do
        bb.BackgroundColor3 = (LANG==c) and t.accent or t.input
    end
end

-- КОНФИГ
local cfgRow = Instance.new("Frame")
cfgRow.Size=UDim2.new(1,-20,0,40); cfgRow.BackgroundTransparency=1; cfgRow.ZIndex=11

saveConfig = function()
    local ok, err = pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            theme=currentTheme, lang=LANG, binds=binds, device=currentDevice,
            events=STATES.events, premium=premiumEnabled, customBg=customBgId
        }))
    end)
    if not ok then log(T("cfg_fail")..": "..tostring(err), "Error") end
end

local function applyConfig(cfg)
    if cfg.premium ~= nil then
        premiumEnabled = cfg.premium and true or false
        if secretBtn then secretBtn.Visible = premiumEnabled end
        if win10Btn then win10Btn.Visible = premiumEnabled end
        if bgRow then bgRow.Visible = premiumEnabled end
    end
    if cfg.customBg then
        customBgId = tostring(cfg.customBg)
        if bgBox then bgBox.Text = customBgId end
    end
    if cfg.device then
        currentDevice = cfg.device
        if currentDevice == "PC" then
            if devicePCStroke then devicePCStroke.Transparency = 0 end
            if devicePhoneStroke then devicePhoneStroke.Transparency = 1 end
            PhoneIconBtn.Visible = false
            consoleHidden = false
            ConsoleFrame.Visible = true
        else
            if devicePCStroke then devicePCStroke.Transparency = 1 end
            if devicePhoneStroke then devicePhoneStroke.Transparency = 0 end
            if consoleHidden then
                ConsoleFrame.Visible = false
                PhoneIconBtn.Visible = true
            end
        end
    end
    if cfg.theme and THEMES[cfg.theme] then
        if (cfg.theme == SECRET or cfg.theme == "win10" or cfg.theme == "custom") and not premiumEnabled then
            -- skip
        else
            applyTheme(cfg.theme); if refreshThemeButtons then refreshThemeButtons() end
        end
    end
    if cfg.lang and LOC[cfg.lang] then LANG = cfg.lang; if refreshUILabels then refreshUILabels() end end
    if cfg.binds and setupBind and currentDevice ~= "Phone" then
        for k, v in pairs(cfg.binds) do setupBind(k, v) end
    end
    if cfg.events then
        for k, v in pairs(cfg.events) do
            if STATES.events[k] ~= nil then STATES.events[k]=v end
            if eventBoxes[k] then eventBoxes[k].Text = v end
        end
    end
end

local function loadConfig()
    local ok, err = pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            applyConfig(HttpService:JSONDecode(readfile(CONFIG_FILE)))
            log(T("cfg_loaded"), "Success")
        end
    end)
    if not ok then log(T("cfg_fail")..": "..tostring(err), "Error") end
end

SaveBtn = makeButton(cfgRow, T("save_cfg"), 0, 0, 120, 26, saveConfig)
LoadBtn = makeButton(cfgRow, T("load_cfg"), 130, 0, 120, 26, loadConfig)
addSettingRow(cfgRow)

-- СОБЫТИЯ
eventsTitleLabel = makeLabel(SettingsScroll, T("events_title"), 0, 20)
addSettingRow(eventsTitleLabel)

for _, evName in ipairs({"onKilled","onDied","onSpawn","onExecute","onJoin","onDamage","onLeave"}) do
    local row = Instance.new("Frame")
    row.Size=UDim2.new(1,-20,0,44); row.BackgroundTransparency=1; row.ZIndex=11
    local lbl = makeLabel(row, T("ev_"..evName:lower()), 0, 16)
    eventLabels[evName] = lbl
    local box = Instance.new("TextBox")
    box.Size=UDim2.new(1,0,0,22); box.Position=UDim2.new(0,0,0,18)
    box.BackgroundColor3=THEMES.default.input; box.TextColor3=THEMES.default.text
    box.Font=CONFIG.Font; box.TextSize=12; box.TextXAlignment=Enum.TextXAlignment.Left
    box.Text = STATES.events[evName] or ""; box.PlaceholderText = "command or lua code"
    box.ClearTextOnFocus = false; box.ZIndex=12; box.Parent=row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,3)
    box.FocusLost:Connect(function()
        STATES.events[evName] = box.Text
        if saveConfig then pcall(saveConfig) end
    end)
    eventBoxes[evName] = box
    addSettingRow(row)
end

refreshUILabels()

local function runEvent(name)
    local code = STATES.events[name]
    if not code or code == "" then return end
    local args = {}
    for w in code:gmatch("%S+") do table.insert(args, w) end
    if #args > 0 then
        local cmdName = args[1]:lower(); table.remove(args, 1)
        local f = commands[cmdName]
        if f then
            local ok, e = pcall(f, args)
            if not ok then log("Event "..name.." error: "..tostring(e), "Error") end
            return
        end
    end
    pcall(executeLua, code)
end

-- ===================== ЗАПОМИНАНИЕ СКОРОСТИ =====================
local function captureOriginalSpeed()
    local _, hum = getChar()
    if hum and not speedCaptured then
        originalWalkSpeed = hum.WalkSpeed
        speedCaptured = true
        log(string.format("Original WalkSpeed captured: %.1f", originalWalkSpeed), "Info")
    end
end

local function watchCharacter(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        if not speedCaptured then
            originalWalkSpeed = hum.WalkSpeed
            speedCaptured = true
            log(string.format("Original WalkSpeed captured: %.1f", originalWalkSpeed), "Info")
        end
        local lastHealth = hum.Health
        hum.Died:Connect(function() runEvent("onDied") end)
        hum.HealthChanged:Connect(function(newH)
            if newH < lastHealth then runEvent("onDamage") end
            lastHealth = newH
        end)
    end

    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child:GetAttribute("XConsoleDuplicate") then
            log("Duplicated item taken in hand: "..child.Name, "Info")
        end
    end)

    runEvent("onSpawn")
end
if LocalPlayer.Character then watchCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(watchCharacter)
Players.PlayerAdded:Connect(function() runEvent("onJoin") end)
Players.PlayerRemoving:Connect(function() runEvent("onLeave") end)

local function trackKilled(plr)
    if plr == LocalPlayer then return end
    local function bind(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then hum.Died:Connect(function() runEvent("onKilled") end) end
    end
    plr.CharacterAdded:Connect(bind)
    if plr.Character then bind(plr.Character) end
end
for _, p in ipairs(Players:GetPlayers()) do trackKilled(p) end
Players.PlayerAdded:Connect(trackKilled)

-- ===================== VELOCITY (ТОЧНО WS 1 + NOCLIP) =====================
local function setVelocityActive(active)
    if active then
        if STATES.velocityActive then return end
        local char, hum = getChar()
        if not char or not hum then
            log(T("no_char"), "Error")
            return
        end
        STATES.velocityActive = true
        
        STATES.velocitySpeedBackup = hum.WalkSpeed
        hum.WalkSpeed = 1
        
        STATES.velocityCollideBackup = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                STATES.velocityCollideBackup[p] = p.CanCollide
                p.CanCollide = false
            end
        end
        
        if STATES.velocityConn then STATES.velocityConn:Disconnect() end
        STATES.velocityConn = RunService.Stepped:Connect(function()
            local c, h = getChar()
            if not c or not h then return end
            h.WalkSpeed = 1
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
        
        log("velocity: on", "Success")
    else
        if not STATES.velocityActive then return end
        STATES.velocityActive = false
        
        if STATES.velocityConn then
            STATES.velocityConn:Disconnect()
            STATES.velocityConn = nil
        end
        
        local char, hum = getChar()
        if hum and STATES.velocitySpeedBackup then
            hum.WalkSpeed = STATES.velocitySpeedBackup
        end
        STATES.velocitySpeedBackup = nil
        
        if char and STATES.velocityCollideBackup then
            for p, state in pairs(STATES.velocityCollideBackup) do
                if p and p.Parent then
                    pcall(function() p.CanCollide = state end)
                end
            end
            STATES.velocityCollideBackup = nil
        end
        
        log("velocity: off", "Info")
    end
end

-- ===================== КОМАНДЫ =====================
local function applyCorner(scale) consoleCorner.CornerRadius = UDim.new(scale, 0) end
local function resolveKey(name)
    name = name:upper()
    local ok, kc = pcall(function() return Enum.KeyCode[name] end)
    return ok and kc or nil
end

-- Список hold-команд (зажимаемых)
local HOLD_COMMANDS = { velocity = true }

setupBind = function(keyName, cmdStr)
    local key = resolveKey(keyName)
    if not key then return false end
    binds[keyName] = cmdStr

    local parts = {}
    for w in cmdStr:gmatch("%S+") do table.insert(parts, w) end
    local cmdName = parts[1] and parts[1]:lower()
    local isHold = cmdName and HOLD_COMMANDS[cmdName]

    local old = bindConns[keyName]
    if old then
        if type(old) == "table" then
            for _, c in ipairs(old) do if c then c:Disconnect() end end
        else
            old:Disconnect()
        end
    end

    local beginConn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == key then
            log("> "..cmdStr, "Echo")
            if isHold and cmdName == "velocity" then
                setVelocityActive(true)
            else
                local aa = {}
                for w in cmdStr:gmatch("%S+") do table.insert(aa, w) end
                local cmd = aa[1] and aa[1]:lower(); table.remove(aa, 1)
                runEvent("onExecute")
                local f = cmd and commands[cmd]
                if f then pcall(f, aa) else executeLua(cmdStr) end
            end
        end
    end)

    local endConn = nil
    if isHold then
        endConn = UIS.InputEnded:Connect(function(input)
            if input.KeyCode == key then
                if cmdName == "velocity" then
                    setVelocityActive(false)
                end
            end
        end)
    end

    bindConns[keyName] = {beginConn, endConn}
    return true
end

-- Привязка кнопки настроек — вызывает команду settings с логированием
SettingsBtn.MouseButton1Click:Connect(function()
    local text = "settings"
    log("> "..text, "Echo")
    runEvent("onExecute")
    local f = commands["settings"]
    if f then
        local ok, e = pcall(f, {})
        if not ok then log("Error: "..tostring(e), "Error") end
    end
end)

commands["help"] = function()
    log("Commands:", "Info")
    log("  settings, bind <key> <cmd>, unload/exit, premium <1|0>", "Default")
    log("  fly/unfly, noclip/clip, esp/unesp, swim/unswim", "Default")
    log("  fling/unfling, infjump/uninfjump, spasm/unspasm, sit", "Default")
    log("  fb/unfb, nofog, tppos x y z, ws, jp, copypos", "Default")
    log("  serverinfo/info, vr, serverhop/shop, joinplayer", "Default")
    log("  creatorid/creator, tools/untools, equipalltools/unequipalltools", "Default")
    log("  uicorner <scale>, defaultcorner", "Default")
    log("  code/xcode, getf3x, gun/m249, dex, tp <name>", "Default")
    log("  duplicateitem/ditem, destroy/destroytarget", "Default")
    log("  speed/speedhack <n>, defaultspeed/dspeed", "Default")
    log("  enabledrop/edrop, disabledrop", "Default")
    log("  equipitems (all at once), deleteduplicate/dduplicate/dd", "Default")
    log("  ejump/djump, esit/dsit, ezoom/dzoom", "Default")
    log("  velocity (BIND ONLY for PC; toggle command for Phone)", "Default")
end
commands["settings"] = function() openSettings() end
commands["unload"] = function()
    log(T("unloaded"), "Success")
    if logConnection then logConnection:Disconnect(); logConnection = nil end
    ScreenGui:Destroy()
end
commands["exit"] = commands["unload"]

commands["premium"] = function(args)
    local v = args[1]
    if v == "1" then
        premiumEnabled = true
        secretBtn.Visible = true
        win10Btn.Visible = true
        bgRow.Visible = true
        log("Premium enabled. Code, Windows 10 and Custom background unlocked.", "Success")
        if saveConfig then pcall(saveConfig) end
    elseif v == "0" then
        premiumEnabled = false
        secretBtn.Visible = false
        win10Btn.Visible = false
        bgRow.Visible = false
        log("Premium disabled", "Info")
        if saveConfig then pcall(saveConfig) end
    else log("Usage: premium <0|1>", "Error") end
end

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

commands["sit"] = function()
    local _, hum = getChar()
    if hum then hum.Sit = true; log("Sitting...","Success") end
end
commands["ws"] = function(args)
    local v = tonumber(args[1]); if not v then log("Usage: ws <value>","Error"); return end
    local _, hum = getChar(); if hum then hum.WalkSpeed=v; log("WalkSpeed set to "..v,"Success") end
end
commands["jp"] = function(args)
    local v = tonumber(args[1]); if not v then log("Usage: jp <value>","Error"); return end
    local _, hum = getChar()
    if hum then hum.UseJumpPower=true; hum.JumpPower=v; log("JumpPower set to "..v,"Success") end
end
commands["tppos"] = function(args)
    local x,y,z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
    if not (x and y and z) then log("Usage: tppos x y z","Error"); return end
    local _,_,hrp = getChar(); if hrp then hrp.CFrame = CFrame.new(x,y,z); log("Teleported to position","Success") end
end
commands["copypos"] = function(args)
    local target = LocalPlayer
    if args[1] then
        local q = args[1]:lower()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower()==q or p.DisplayName:lower()==q then target=p; break end
        end
    end
    local char = target.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then log(string.format("Pos of %s: %.1f, %.1f, %.1f", target.Name, hrp.Position.X, hrp.Position.Y, hrp.Position.Z), "Success")
    else log("Player not found","Error") end
end

commands["uicorner"] = function(args)
    local v = tonumber(args[1]); if not v then log("Usage: uicorner <scale>","Error"); return end
    applyCorner(v); log(T("corner_set")..v, "Success")
end
commands["defaultcorner"] = function() consoleCorner.CornerRadius = UDim.new(0,6); log(T("corner_reset"),"Success") end

commands["bind"] = function(args)
    if currentDevice == "Phone" then
        log("no access. device is phone", "Error")
        return
    end
    if #args < 1 then log("Usage: bind <key> <command> | bind list | bind clear","Error"); return end
    local sub = args[1]:lower()
    if sub == "list" then
        log("Active binds:","Info"); local any=false
        for k,v in pairs(binds) do log("  "..k.." -> "..v,"Default"); any=true end
        if not any then log("No active binds","Info") end; return
    elseif sub == "clear" then
        for _, c in pairs(bindConns) do
            if type(c) == "table" then
                for _, cc in ipairs(c) do if cc then cc:Disconnect() end end
            else
                c:Disconnect()
            end
        end
        binds = {}; bindConns = {}; log("All binds cleared","Success")
        if saveConfig then pcall(saveConfig) end
        return
    end
    if #args < 2 then log("Usage: bind <key> <command>","Error"); return end
    local cmdStr = table.concat(args, " ", 2)
    if not setupBind(args[1], cmdStr) then log("Unknown key: "..args[1],"Error"); return end
    log(string.format("Bound [%s] -> %s", args[1]:upper(), cmdStr), "Success")
    if saveConfig then pcall(saveConfig) end
end

commands["velocity"] = function(args)
    if currentDevice == "PC" then
        log("no access. write bind {key} velocity", "Error")
        return
    end
    setVelocityActive(not STATES.velocityActive)
end

commands["serverinfo"] = function()
    log("Server info:","Info")
    log("  PlaceId: "..tostring(game.PlaceId),"Default")
    log("  JobId: "..tostring(game.JobId),"Default")
    log("  Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers,"Default")
    log("  Creator: "..game.CreatorId.." ("..tostring(game.CreatorType)..")","Default")
    local ok, prod = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
    if ok and prod then log("  Game: "..tostring(prod.Name),"Default") end
end
commands["info"] = commands["serverinfo"]

commands["vr"] = function()
    local ok, VRS = pcall(function() return game:GetService("VRService") end)
    if ok and VRS then log("VR available: "..tostring(VRS.VREnabled),"Info")
    else log("VR mode not available","Error") end
end

commands["serverhop"] = function()
    log("Searching for another server...","Info")
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)))
    end)
    if not ok or not res or not res.data then log("Failed to get server list","Error"); return end
    local target
    for _, s in ipairs(res.data) do
        if s.id ~= game.JobId and s.playing < s.maxPlayers then target=s.id; break end
    end
    if not target then log("No other servers found","Error"); return end
    log("Teleporting to server: "..target,"Success")
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer) end)
end
commands["shop"] = commands["serverhop"]

commands["joinplayer"] = function(args)
    if #args < 1 then log("Usage: joinplayer <username/ID> [placeId]","Error"); return end
    local query = args[1]; local userId = tonumber(query)
    if not userId then
        local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(query) end)
        if ok then userId = id end
    end
    if not userId then log("Player not found","Error"); return end
    local plr = Players:GetPlayerByUserId(userId)
    if not plr then log("Player not in current server — cannot join","Error"); return end
    log("Joining player: "..plr.Name,"Success")
    pcall(function() TeleportService:TeleportToPlayer({plr}, LocalPlayer) end)
end

commands["creatorid"] = function() log("Creator ID: "..tostring(game.CreatorId).." ("..tostring(game.CreatorType)..")","Success") end
commands["creator"] = commands["creatorid"]

commands["tools"] = function()
    local bp = LocalPlayer:FindFirstChild("Backpack"); if not bp then log("No backpack","Error"); return end
    local n = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and not obj:IsDescendantOf(LocalPlayer.Character) then
            obj:Clone().Parent = bp; n += 1; if n >= 100 then break end
        end
    end
    log("Tools added: "..n,"Success")
end
commands["untools"] = function()
    local n = 0
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then t:Destroy(); n+=1 end end end
    local char = LocalPlayer.Character
    if char then for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then t:Destroy(); n+=1 end end end
    log("Tools removed: "..n,"Success")
end

-- ===================== EQUIP ITEMS (все сразу) =====================
local function equipAllSimultaneous()
    local char = LocalPlayer.Character
    if not char then log("No character","Error"); return end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then log("No backpack","Error"); return end

    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then pcall(function() child.Parent = bp end) end
    end
    task.wait(0.05)

    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Weld") and d.Name == "XConsoleEquipWeld" then d:Destroy() end
    end

    local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local head = char:FindFirstChild("Head")
    local limbs = {}
    if rightHand then table.insert(limbs, rightHand) end
    if leftHand then table.insert(limbs, leftHand) end
    if torso then table.insert(limbs, torso) end
    if head then table.insert(limbs, head) end
    if #limbs == 0 then log("No limbs found on character","Error"); return end

    local tools = {}
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then table.insert(tools, t) end
    end
    if #tools == 0 then log("No tools in Backpack","Info"); return end

    for _, tool in ipairs(tools) do
        pcall(function() tool.Parent = char end)
    end
    task.wait(0.1)

    local count = 0
    for i, tool in ipairs(tools) do
        local handle = tool:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            for _, w in ipairs(handle:GetChildren()) do
                if w:IsA("JointInstance") and w.Name ~= "XConsoleEquipWeld" then
                    local p0, p1 = w.Part0, w.Part1
                    if (p0 and p0:IsDescendantOf(char)) or (p1 and p1:IsDescendantOf(char)) then
                        pcall(function() w:Destroy() end)
                    end
                end
            end

            local limb = limbs[(i - 1) % #limbs + 1]
            local weld = Instance.new("Weld")
            weld.Name = "XConsoleEquipWeld"
            weld.Part0 = limb
            weld.Part1 = handle
            local angle = math.rad((i - 1) * 35)
            weld.C0 = CFrame.new(0, -0.2, -0.6 - (i * 0.15)) * CFrame.Angles(angle, 0, 0)
            weld.Parent = limb
            count += 1
        else
            count += 1
        end
    end
    log("Simultaneously equipped: "..count.." tools (visual — clicking may not use them)", "Success")
end
commands["equipitems"] = equipAllSimultaneous
commands["equipalltools"] = equipAllSimultaneous

commands["unequipalltools"] = function()
    local char = LocalPlayer.Character
    if not char then log("No character","Error"); return end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local n = 0
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Weld") and d.Name == "XConsoleEquipWeld" then d:Destroy() end
    end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and bp then t.Parent = bp; n += 1 end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:UnequipTools() end) end
    log("Unequipped tools: "..n, "Success")
end

commands["xyz"] = function()
    local _,_,hrp = getChar(); if not hrp then return end
    log(string.format("X=%.2f Y=%.2f Z=%.2f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z),"Success")
end

-- ===================== DESTROY TARGET =====================
local function destroyTarget()
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    if not target then log("Nothing under cursor","Error"); return end
    if target:IsA("Terrain") then log("Cannot destroy Terrain","Error"); return end
    local name = target:GetFullName()
    target:Destroy()
    log("Destroyed: "..name,"Success")
end
commands["destroy"] = destroyTarget
commands["destroytarget"] = destroyTarget

commands["summon"] = function(args)
    local shape = (args[1] or "part"):lower()
    local map = { part=Enum.PartType.Block, block=Enum.PartType.Block, sphere=Enum.PartType.Ball,
        ball=Enum.PartType.Ball, cylinder=Enum.PartType.Cylinder, wedge=Enum.PartType.Wedge,
        cornerwedge=Enum.PartType.CornerWedge }
    local pt = map[shape]; if not pt then log("Usage: summon <part|sphere|cylinder|wedge>","Error"); return end
    local p = Instance.new("Part"); p.Shape=pt; p.Size=Vector3.new(4,4,4)
    p.Position = LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,5,0); p.Parent = Workspace
    log("Spawned "..shape,"Success")
end
commands["kickme"] = function(args) LocalPlayer:Kick(#args>0 and table.concat(args," ") or "No reason") end
commands["color"] = function(args)
    if #args < 1 then log("Usage: color <bg><fg>","Error"); return end
    local code = args[1]:upper(); if #code ~= 2 then log("Bad code","Error"); return end
    local bg, fg = CMD_COLORS[code:sub(1,1)], CMD_COLORS[code:sub(2,2)]
    if bg and fg then ConsoleFrame.BackgroundColor3=bg; CommandBox.TextColor3=fg; log("Color changed: "..code,"Success")
    else log("Bad code","Error") end
end
commands["clear"] = function()
    for _,c in ipairs(LogFrame:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
    log("Log cleared","Info")
end
commands["code"] = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/dimoonsh195/xcode/main/xcode.lua", true))() end)
end
commands["xcode"] = commands["code"]
commands["getf3x"] = function()
    pcall(function() local obj = game:GetObjects("rbxassetid://6695644299")[1]; if obj then loadstring(obj.Source)() end end)
end
commands["tool"] = commands["getf3x"]; commands["f3x"] = commands["getf3x"]
commands["gun"] = giveGun; commands["m249"] = giveGun
commands["dex"] = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/Dex/master/out.lua", true))() end)
end

-- ===================== DUPLICATE ITEM =====================
local function duplicateHeldItem()
    local char = LocalPlayer.Character
    if not char then log("No character","Error"); return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then log("No tool in hand","Error"); return end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then log("No backpack","Error"); return end

    local clone = tool:Clone()
    clone.Name = tool.Name .. "_Copy"
    clone:SetAttribute("XConsoleDuplicate", true)
    clone.Enabled = true

    for k, v in pairs(tool:GetAttributes()) do
        if k ~= "XConsoleDuplicate" then
            pcall(function() clone:SetAttribute(k, v) end)
        end
    end

    pcall(function()
        for _, tag in ipairs(CollectionService:GetTags(tool)) do
            CollectionService:AddTag(clone, tag)
        end
    end)

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BaseScript") then
            pcall(function() d.Enabled = true end)
        end
    end

    local handle = clone:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        local charParts = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then charParts[p] = true end
        end
        for _, w in ipairs(handle:GetChildren()) do
            if w:IsA("JointInstance") then
                if (w.Part0 and charParts[w.Part0]) or (w.Part1 and charParts[w.Part1]) then
                    pcall(function() w:Destroy() end)
                end
            end
        end
        handle.Anchored = false
        handle.CanCollide = false
    end

    clone.Parent = bp
    log("Duplicated: "..tool.Name.." (client-side copy)","Success")
end
commands["duplicateitem"] = duplicateHeldItem
commands["ditem"] = duplicateHeldItem

-- ===================== DELETE DUPLICATES =====================
local function deleteDuplicates()
    local n = 0
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("XConsoleDuplicate") then
                t:Destroy(); n += 1
            end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("XConsoleDuplicate") then
                t:Destroy(); n += 1
            end
        end
    end
    log("Deleted duplicated items: "..n, "Success")
end
commands["deleteduplicate"] = deleteDuplicates
commands["dduplicate"] = deleteDuplicates
commands["dd"] = deleteDuplicates

-- ===================== ENABLE DROP =====================
local function forceDroppable()
    if not STATES.enableDrop then return end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and not t.CanBeDropped then t.CanBeDropped = true end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and not t.CanBeDropped then t.CanBeDropped = true end
        end
    end
end
local function toggleEnableDrop(on)
    STATES.enableDrop = on
    if STATES.dropConn then STATES.dropConn:Disconnect(); STATES.dropConn = nil end
    if on then
        STATES.dropConn = RunService.Heartbeat:Connect(forceDroppable)
        log("Dropping of all items enabled","Success")
    else
        log("Dropping of all items disabled","Info")
    end
end
commands["enabledrop"] = function() toggleEnableDrop(true) end
commands["edrop"] = commands["enabledrop"]
commands["disabledrop"] = function() toggleEnableDrop(false) end

-- ===================== SPEEDHACK =====================
local function setSpeed(val)
    local _, hum = getChar()
    if not hum then log(T("no_char"),"Error"); return end
    hum.WalkSpeed = val
    log("WalkSpeed set to "..tostring(val),"Success")
end

commands["speed"] = function(args)
    local v = tonumber(args[1])
    if not v then log("Usage: speed <value>","Error"); return end
    setSpeed(v)
end
commands["speedhack"] = commands["speed"]

commands["defaultspeed"] = function()
    if not speedCaptured or not originalWalkSpeed then
        captureOriginalSpeed()
    end
    if not originalWalkSpeed then
        log("Original speed unknown, using 16","Info")
        setSpeed(16)
    else
        setSpeed(originalWalkSpeed)
        log(string.format("Speed reset to original (%.1f)", originalWalkSpeed),"Success")
    end
end
commands["dspeed"] = commands["defaultspeed"]

-- ===================== EJUMP / DJUMP =====================
local function toggleEnableJump(on)
    STATES.enableJump = on
    if STATES.jumpConn then STATES.jumpConn:Disconnect(); STATES.jumpConn = nil end
    if STATES.jumpRequestConn then STATES.jumpRequestConn:Disconnect(); STATES.jumpRequestConn = nil end
    if on then
        local _, hum = getChar()
        if hum and not STATES.jumpBackup then
            STATES.jumpBackup = {
                JumpPower = hum.JumpPower,
                JumpHeight = hum.JumpHeight,
                UseJumpPower = hum.UseJumpPower,
            }
        end
        STATES.jumpConn = RunService.Heartbeat:Connect(function()
            local _, h = getChar()
            if h then
                if not STATES.jumpBackup then
                    STATES.jumpBackup = {
                        JumpPower = h.JumpPower,
                        JumpHeight = h.JumpHeight,
                        UseJumpPower = h.UseJumpPower,
                    }
                end
                pcall(function()
                    if h.UseJumpPower then
                        if h.JumpPower < 50 then h.JumpPower = 50 end
                    else
                        if h.JumpHeight < 7.2 then h.JumpHeight = 7.2 end
                    end
                    if h.JumpPower <= 0 and h.JumpHeight <= 0 then
                        h.UseJumpPower = true
                        h.JumpPower = 50
                    end
                end)
            end
        end)
        STATES.jumpRequestConn = UIS.JumpRequest:Connect(function()
            local char, h = getChar()
            if not char or not h then return end
            pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and h.FloorMaterial ~= Enum.Material.Air then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end)
        log("Jump enabled","Success")
    else
        if STATES.jumpBackup then
            local _, h = getChar()
            if h then
                pcall(function()
                    h.JumpPower = STATES.jumpBackup.JumpPower
                    h.JumpHeight = STATES.jumpBackup.JumpHeight
                    h.UseJumpPower = STATES.jumpBackup.UseJumpPower
                end)
            end
            STATES.jumpBackup = nil
        end
        log("Jump disabled","Info")
    end
end
commands["ejump"] = function() toggleEnableJump(true) end
commands["djump"] = function() toggleEnableJump(false) end

-- ===================== ESIT / DSIT =====================
local function toggleEnableSit(on)
    STATES.enableSit = on
    if STATES.sitInputConn then STATES.sitInputConn:Disconnect(); STATES.sitInputConn = nil end
    if on then
        STATES.sitInputConn = UIS.InputBegan:Connect(function(input, gp)
            if input.KeyCode == Enum.KeyCode.X then
                if UIS:GetFocusedTextBox() then return end
                local _, h = getChar()
                if h then
                    pcall(function() h.Sit = not h.Sit end)
                    log("Sit toggled: "..tostring(h.Sit), "Info")
                end
            end
        end)
        log("Sit enabled (press X)","Success")
    else
        local _, h = getChar()
        if h then pcall(function() h.Sit = false end) end
        log("Sit disabled","Info")
    end
end
commands["esit"] = function() toggleEnableSit(true) end
commands["dsit"] = function() toggleEnableSit(false) end

-- ===================== EZOOM / DZOOM =====================
local function toggleEnableZoom(on)
    STATES.enableZoom = on
    if STATES.zoomConn then STATES.zoomConn:Disconnect(); STATES.zoomConn = nil end
    if on then
        if not STATES.zoomBackup then
            STATES.zoomBackup = {
                CameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance,
                CameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance,
            }
        end
        STATES.zoomConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                LocalPlayer.CameraMaxZoomDistance = 128
                LocalPlayer.CameraMinZoomDistance = 0.5
                local cam = Workspace.CurrentCamera
                if cam.CameraType == Enum.CameraType.LockFirstPerson then
                    cam.CameraType = Enum.CameraType.Custom
                end
            end)
        end)
        log("Zoom enabled","Success")
    else
        if STATES.zoomBackup then
            pcall(function()
                LocalPlayer.CameraMaxZoomDistance = STATES.zoomBackup.CameraMaxZoomDistance
                LocalPlayer.CameraMinZoomDistance = STATES.zoomBackup.CameraMinZoomDistance
            end)
            STATES.zoomBackup = nil
        end
        log("Zoom disabled","Info")
    end
end
commands["ezoom"] = function() toggleEnableZoom(true) end
commands["dzoom"] = function() toggleEnableZoom(false) end

-- ===================== TP =====================
local function tpToPlayer(args)
    if #args < 1 then
        log("Online players:","Info")
        for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then log("  "..p.Name,"Default") end end
        return
    end
    local q = table.concat(args," "):lower(); local target
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Name:lower()==q or p.DisplayName:lower()==q) then target=p; break end
    end
    if not target then for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Name:lower():find(q,1,true) or p.DisplayName:lower():find(q,1,true)) then target=p; break end
    end end
    if not target then log("Player not found","Error"); return end
    local char = target.Character; local thrp = char and char:FindFirstChild("HumanoidRootPart")
    local _,_,myhrp = getChar()
    if thrp and myhrp then myhrp.CFrame = thrp.CFrame * CFrame.new(0,2,3); log("Teleported to "..target.Name,"Success") end
end
commands["tp"] = tpToPlayer; commands["to"] = tpToPlayer; commands["goto"] = tpToPlayer

-- ===================== СКРЫТИЕ / РАСКРЫТИЕ =====================
local function setConsoleHidden(hidden)
    consoleHidden = hidden
    if currentDevice == "Phone" then
        ConsoleFrame.Visible = false
        PhoneIconBtn.Visible = hidden
    else
        ConsoleFrame.Visible = not hidden
        PhoneIconBtn.Visible = false
    end
end

HideBtn.MouseButton1Click:Connect(function()
    setConsoleHidden(true)
end)

UIS.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightControl then
        setConsoleHidden(not consoleHidden)
    end
end)

-- ===================== ВВОД =====================
CommandBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local text = CommandBox.Text; if text == "" then return end
    CommandBox.Text = ""
    if #commandHistory == 0 or commandHistory[#commandHistory] ~= text then
        table.insert(commandHistory, text)
        if #commandHistory > CONFIG.MaxHistory then table.remove(commandHistory, 1) end
    end
    historyIndex = #commandHistory + 1
    local args = {}; for w in text:gmatch("%S+") do table.insert(args, w) end
    if #args == 0 then return end
    local cmdName = args[1]:lower(); table.remove(args, 1)
    log("> "..text,"Echo")
    runEvent("onExecute")
    local f = commands[cmdName]
    if f then
        local ok, e = pcall(f, args)
        if not ok then log("Error: "..tostring(e),"Error") end
    else executeLua(text) end
end)

CommandBox.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Up then
        if #commandHistory > 0 then historyIndex = math.max(1, historyIndex-1); CommandBox.Text = commandHistory[historyIndex] end
    elseif input.KeyCode == Enum.KeyCode.Down then
        if #commandHistory > 0 then
            historyIndex = math.min(#commandHistory+1, historyIndex+1)
            CommandBox.Text = historyIndex <= #commandHistory and commandHistory[historyIndex] or ""
        end
    end
end)

-- ===================== РЕСАЙЗ =====================
local resizing, startSize, startMouse = false, nil, nil
ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing=true; startSize=ConsoleFrame.AbsoluteSize; startMouse=input.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - startMouse
        ConsoleFrame.Size = UDim2.new(0, math.max(300, startSize.X+d.X), 0, math.max(150, startSize.Y+d.Y))
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end)

CloseBtn.MouseButton1Click:Connect(function()
    if logConnection then logConnection:Disconnect(); logConnection = nil end
    ScreenGui:Destroy()
end)

log(T("loaded"), "Success")
log(T("settings_hint"), "Info")
log("hide/show Rctrl", "Info")

-- ===================== АВТОЗАГРУЗКА КОНФИГА =====================
task.defer(function()
    task.wait(0.1)
    if isfile then
        pcall(loadConfig)
    end
    task.wait(0.5)
    captureOriginalSpeed()
end)
