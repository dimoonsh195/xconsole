local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Font = Enum.Font.Code,
    Accent = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(15, 15, 15),
    MaxHistory = 50,
}

local COLORS = {
    Error = Color3.fromRGB(255, 100, 100),
    Success = Color3.fromRGB(100, 255, 100),
    Info = Color3.fromRGB(255, 200, 100),
    Echo = Color3.fromRGB(150, 150, 150),
    Default = Color3.fromRGB(255, 255, 255)
}

local CMD_COLORS = {
    ["0"] = Color3.fromRGB(0, 0, 0), ["1"] = Color3.fromRGB(0, 0, 128),
    ["2"] = Color3.fromRGB(0, 128, 0), ["3"] = Color3.fromRGB(0, 128, 128),
    ["4"] = Color3.fromRGB(128, 0, 0), ["5"] = Color3.fromRGB(128, 0, 128),
    ["6"] = Color3.fromRGB(128, 128, 0), ["7"] = Color3.fromRGB(192, 192, 192),
    ["8"] = Color3.fromRGB(128, 128, 128), ["9"] = Color3.fromRGB(0, 0, 255),
    ["A"] = Color3.fromRGB(0, 255, 0), ["B"] = Color3.fromRGB(0, 255, 255),
    ["C"] = Color3.fromRGB(255, 0, 0), ["D"] = Color3.fromRGB(255, 0, 255),
    ["E"] = Color3.fromRGB(255, 255, 0), ["F"] = Color3.fromRGB(255, 255, 255),
}

local commandHistory = {}
local historyIndex = 0
local closed = false

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    local ok2, pg = pcall(function() return LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if ok2 and pg then return pg end
    return nil
end

local guiParent = getGuiParent()
if not guiParent then return end

if guiParent:FindFirstChild("SimpleConsole") then guiParent.SimpleConsole:Destroy() end
if guiParent:FindFirstChild("XConsole_Cursor") then guiParent.XConsole_Cursor:Destroy() end
if guiParent:FindFirstChild("XcodeGui") then guiParent.XcodeGui:Destroy() end
if guiParent:FindFirstChild("MainMenu") then guiParent.MainMenu:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleConsole"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 5000
ScreenGui.Parent = guiParent

local ConsoleFrame = Instance.new("Frame")
ConsoleFrame.Name = "Console"
ConsoleFrame.Size = UDim2.new(0, 600, 0, 350)
ConsoleFrame.Position = UDim2.new(0, 20, 0, 20)
ConsoleFrame.BackgroundColor3 = CONFIG.Background
ConsoleFrame.BackgroundTransparency = 0.1
ConsoleFrame.BorderSizePixel = 0
ConsoleFrame.Active = true
ConsoleFrame.Draggable = true
ConsoleFrame.Parent = ScreenGui
Instance.new("UICorner", ConsoleFrame).CornerRadius = UDim.new(0, 6)

local stroke = Instance.new("UIStroke")
stroke.Color = CONFIG.Accent
stroke.Thickness = 1
stroke.Transparency = 0.5
stroke.Parent = ConsoleFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Header.BackgroundTransparency = 0.2
Header.BorderSizePixel = 0
Header.Parent = ConsoleFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CONSOLE"
Title.TextColor3 = CONFIG.Accent
Title.Font = CONFIG.Font
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = CONFIG.Font
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Name = "Log"
LogFrame.Size = UDim2.new(1, -10, 1, -75)
LogFrame.Position = UDim2.new(0, 5, 0, 35)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LogFrame.BackgroundTransparency = 0.3
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = CONFIG.Accent
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.Parent = ConsoleFrame
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 4)

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = LogFrame

local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -10, 0, 30)
InputFrame.Position = UDim2.new(0, 5, 1, -35)
InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InputFrame.BackgroundTransparency = 0.2
InputFrame.BorderSizePixel = 0
InputFrame.Parent = ConsoleFrame
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 4)

local CommandBox = Instance.new("TextBox")
CommandBox.Size = UDim2.new(1, -10, 1, -6)
CommandBox.Position = UDim2.new(0, 5, 0, 3)
CommandBox.BackgroundTransparency = 1
CommandBox.Text = ""
CommandBox.PlaceholderText = "Enter command..."
CommandBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
CommandBox.TextColor3 = CONFIG.Accent
CommandBox.Font = CONFIG.Font
CommandBox.TextSize = 16
CommandBox.TextXAlignment = Enum.TextXAlignment.Left
CommandBox.ClearTextOnFocus = false
CommandBox.Parent = InputFrame

local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ResizeHandle.Text = "◢"
ResizeHandle.TextColor3 = Color3.fromRGB(150, 150, 150)
ResizeHandle.Font = CONFIG.Font
ResizeHandle.TextSize = 12
ResizeHandle.BorderSizePixel = 0
ResizeHandle.ZIndex = 5
ResizeHandle.Parent = ConsoleFrame
Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0, 4)

local cursorGui = Instance.new("ScreenGui")
cursorGui.Name = "XConsole_Cursor"
cursorGui.ResetOnSpawn = false
cursorGui.DisplayOrder = 9999
cursorGui.IgnoreGuiInset = true
cursorGui.Enabled = false
cursorGui.Parent = guiParent

local cursorFrame = Instance.new("Frame")
cursorFrame.Size = UDim2.new(0, 18, 0, 18)
cursorFrame.BackgroundTransparency = 1
cursorFrame.BorderSizePixel = 0
cursorFrame.Parent = cursorGui

local line1 = Instance.new("Frame")
line1.Size = UDim2.new(1, 0, 0, 2)
line1.Position = UDim2.new(0, 0, 0.5, -1)
line1.BackgroundColor3 = Color3.new(1, 1, 1)
line1.BorderSizePixel = 0
line1.Rotation = 45
line1.Parent = cursorFrame
Instance.new("UIStroke", line1).Color = Color3.new(0, 0, 0)

local line2 = Instance.new("Frame")
line2.Size = UDim2.new(1, 0, 0, 2)
line2.Position = UDim2.new(0, 0, 0.5, -1)
line2.BackgroundColor3 = Color3.new(1, 1, 1)
line2.BorderSizePixel = 0
line2.Rotation = -45
line2.Parent = cursorFrame
Instance.new("UIStroke", line2).Color = Color3.new(0, 0, 0)

local function log(text, colorType)
    local color = COLORS[colorType] or COLORS.Default
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -5, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = "> " .. text
    label.TextColor3 = color
    label.Font = CONFIG.Font
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = LogFrame
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 10)
    task.wait()
    LogFrame.CanvasPosition = Vector2.new(0, LogFrame.CanvasSize.Y.Offset)
end

local function getChar()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

local commands = {
    ["help"] = function()
        log("Commands:", "Info")
        log("  xyz, destroy, summon, kickme, color, codegui, dex, clear", "Default")
    end,
    ["xyz"] = function()
        local _, _, hrp = getChar()
        if not hrp then log("Character not found", "Error") return end
        local p = hrp.Position
        local msg = string.format("X=%.2f  Y=%.2f  Z=%.2f", p.X, p.Y, p.Z)
        log(msg, "Success"); print("[CONSOLE] XYZ: " .. msg)
    end,
    ["destroy"] = function()
        local target = LocalPlayer:GetMouse().Target
        if not target then log("Nothing under cursor", "Error") return end
        if target:IsA("Terrain") then log("Cannot destroy Terrain", "Error") return end
        log("Destroyed: " .. target:GetFullName(), "Info"); target:Destroy()
    end,
    ["summon"] = function(args)
        local shape = (args[1] or ""):lower()
        local validShapes = {
            ["part"] = Enum.PartType.Block, ["block"] = Enum.PartType.Block,
            ["sphere"] = Enum.PartType.Ball, ["ball"] = Enum.PartType.Ball,
            ["cylinder"] = Enum.PartType.Cylinder, ["wedge"] = Enum.PartType.Wedge,
            ["cornerwedge"] = Enum.PartType.CornerWedge
        }
        local partType = validShapes[shape]
        if not partType then log("Usage: summon <part|sphere|cylinder|wedge|cornerwedge>", "Error") return end
        local spawnPos = LocalPlayer:GetMouse().Hit.Position + Vector3.new(0, 5, 0)
        local part = Instance.new("Part")
        part.Anchored = false; part.CanCollide = true
        part.Material = Enum.Material.SmoothPlastic; part.Color = Color3.fromRGB(255, 255, 255)
        part.Position = spawnPos; part.Size = Vector3.new(4, 4, 4)
        part.Name = "SummonedPart"; part.Shape = partType; part.Parent = workspace
        log("Spawned " .. shape, "Success")
    end,
    ["kickme"] = function(args)
        local reason = #args > 0 and table.concat(args, " ") or "No reason provided"
        log("Kicking self: " .. reason, "Error"); task.wait(0.2)
        pcall(function() LocalPlayer:Kick(reason) end)
    end,
    ["color"] = function(args)
        if #args < 1 then log("Usage: color <bg_code><text_code>", "Error") return end
        local code = args[1]:upper()
        if #code ~= 2 then log("Color code must be 2 characters", "Error") return end
        local bg, fg = CMD_COLORS[code:sub(1, 1)], CMD_COLORS[code:sub(2, 2)]
        if bg and fg then
            ConsoleFrame.BackgroundColor3 = bg; LogFrame.BackgroundColor3 = bg
            COLORS.Default = fg; CommandBox.TextColor3 = fg; Title.TextColor3 = fg; stroke.Color = fg
            log("Color changed to " .. code, "Success")
        else log("Invalid color code", "Error") end
    end,
    ["codegui"] = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/dimoonsh195/xcode/main/xcode.lua", true))()
        end)
        if success then log("Xcode opened", "Success")
        else log("Failed to open Xcode: " .. tostring(err), "Error") end
    end,
    ["dex"] = function()
        log("Loading DEX...", "Info")
        local success, err = pcall(function()
            -- Ссылка на оригинальный DEX (репозиторий luau/Dex)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/Dex/master/out.lua", true))()
        end)
        if success then log("DEX loaded successfully", "Success")
        else log("Failed to load DEX: " .. tostring(err), "Error") end
    end,
    ["clear"] = function()
        for _, child in ipairs(LogFrame:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        log("Log cleared", "Info")
    end,
}

CommandBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local text = CommandBox.Text
    if text == "" then return end
    CommandBox.Text = ""
    if #commandHistory == 0 or commandHistory[#commandHistory] ~= text then
        table.insert(commandHistory, text)
        if #commandHistory > CONFIG.MaxHistory then table.remove(commandHistory, 1) end
    end
    historyIndex = #commandHistory + 1
    local args = {}
    for word in text:gmatch("%S+") do table.insert(args, word) end
    if #args == 0 then return end
    local cmdName = args[1]:lower()
    table.remove(args, 1)
    log("> " .. text, "Echo")
    local commandFunc = commands[cmdName]
    if commandFunc then
        local success, e = pcall(commandFunc, args)
        if not success then log("Error: " .. tostring(e), "Error") end
    else log("Unknown command: " .. cmdName, "Error") end
end)

CommandBox.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Up then
        if #commandHistory > 0 then
            historyIndex = math.max(1, historyIndex - 1)
            CommandBox.Text = commandHistory[historyIndex]
        end
    elseif input.KeyCode == Enum.KeyCode.Down then
        if #commandHistory > 0 then
            historyIndex = math.min(#commandHistory + 1, historyIndex + 1)
            CommandBox.Text = historyIndex <= #commandHistory and commandHistory[historyIndex] or ""
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if closed or not ConsoleFrame.Parent then
        if cursorGui and cursorGui.Parent and cursorGui.Enabled then cursorGui.Enabled = false end
        return
    end
    local mp = UIS:GetMouseLocation()
    local ap = ConsoleFrame.AbsolutePosition
    local as = ConsoleFrame.AbsoluteSize
    local inside = mp.X >= ap.X and mp.X <= ap.X + as.X and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y
    local xcodeOpen = false
    if guiParent:FindFirstChild("XcodeGui") then
        local xwin = guiParent.XcodeGui:FindFirstChildOfClass("Frame")
        if xwin then
            local xap = xwin.AbsolutePosition
            local xas = xwin.AbsoluteSize
            if mp.X >= xap.X and mp.X <= xap.X + xas.X and mp.Y >= xap.Y and mp.Y <= xap.Y + xas.Y then xcodeOpen = true end
        end
    end
    if (inside or xcodeOpen) and ConsoleFrame.Visible then
        pcall(function()
            local cg = game:GetService("CoreGui")
            local xboatCursor = cg:FindFirstChild("XboatCursor")
            if xboatCursor then xboatCursor.Enabled = false end
        end)
        if not cursorGui.Enabled then cursorGui.Enabled = true; UIS.MouseIconEnabled = false end
        cursorFrame.Position = UDim2.new(0, mp.X - 9, 0, mp.Y - 9)
    else
        if cursorGui.Enabled then cursorGui.Enabled = false; UIS.MouseIconEnabled = true end
    end
end)

log("CONSOLE loaded. Type help.", "Success")
