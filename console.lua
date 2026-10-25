local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
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

-- === ОСНОВНОЕ ОКНО КОНСОЛИ ===
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

-- === КАСТОМНЫЙ КУРСОР ДЛЯ КОНСОЛИ (X) ===
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

-- === ФУНКЦИЯ ЛОГА ===
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

-- === СЛОВАРЬ АВТОДОПОЛНЕНИЯ ===
local suggestionsList = {
    "local", "function", "if", "then", "else", "elseif", "end", "for", "while", "do", "in", "return", "break", "nil", "true", "false",
    "game", "workspace", "script", "print", "warn", "Instance", "Vector3", "CFrame", "Color3", "Enum", "Lighting", "Players", "RunService",
    "GetService", "Wait", "FindFirstChild", "Parent", "Name", "Position", "Size", "CFrame"
}

-- === ФУНКЦИЯ XCODE GUI ===
local function open_xcode_gui()
    if guiParent:FindFirstChild("XcodeGui") then guiParent.XcodeGui:Destroy() end

    local xGui = Instance.new("ScreenGui")
    xGui.Name = "XcodeGui"
    xGui.ResetOnSpawn = false
    xGui.IgnoreGuiInset = true
    xGui.DisplayOrder = 6000
    xGui.Parent = guiParent

    local xWin = Instance.new("Frame")
    xWin.Size = UDim2.new(0, 700, 0, 450)
    xWin.Position = UDim2.new(0.5, -350, 0.5, -225)
    xWin.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    xWin.BorderSizePixel = 0
    xWin.Active = true
    xWin.Draggable = true
    xWin.Parent = xGui
    Instance.new("UICorner", xWin).CornerRadius = UDim.new(0, 6)

    local xHeader = Instance.new("Frame")
    xHeader.Size = UDim2.new(1, 0, 0, 30)
    xHeader.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    xHeader.Parent = xWin
    Instance.new("UICorner", xHeader).CornerRadius = UDim.new(0, 6)

    local xTitle = Instance.new("TextLabel")
    xTitle.Size = UDim2.new(0, 100, 1, 0)
    xTitle.Position = UDim2.new(0, 10, 0, 0)
    xTitle.BackgroundTransparency = 1
    xTitle.Text = "Xcode"
    xTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    xTitle.Font = Enum.Font.Code
    xTitle.TextSize = 14
    xTitle.TextXAlignment = Enum.TextXAlignment.Left
    xTitle.Parent = xHeader

    local function makeBtn(text, xOffset, width)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, width, 0, 22)
        btn.Position = UDim2.new(1, xOffset, 0, 4)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Code
        btn.TextSize = 12
        btn.Parent = xHeader
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        return btn
    end

    local btnExecute = makeBtn("Execute", -340, 60)
    local btnClear = makeBtn("Clear", -270, 50)
    local btnSelectAll = makeBtn("Select All", -210, 70)
    local btnSave = makeBtn("Save", -130, 50)

    local editorScroll = Instance.new("ScrollingFrame")
    editorScroll.Size = UDim2.new(1, -20, 1, -60)
    editorScroll.Position = UDim2.new(0, 10, 0, 35)
    editorScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    editorScroll.BorderSizePixel = 0
    editorScroll.ScrollBarThickness = 8
    editorScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    editorScroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
    editorScroll.Parent = xWin
    Instance.new("UICorner", editorScroll).CornerRadius = UDim.new(0, 4)

    local lineNumbers = Instance.new("TextLabel")
    lineNumbers.Size = UDim2.new(0, 30, 1, 0)
    lineNumbers.Position = UDim2.new(0, 5, 0, 0)
    lineNumbers.BackgroundTransparency = 1
    lineNumbers.Text = "1"
    lineNumbers.TextColor3 = Color3.fromRGB(100, 100, 100)
    lineNumbers.Font = Enum.Font.Code
    lineNumbers.TextSize = 14
    lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
    lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
    lineNumbers.Parent = editorScroll

    -- Текстовое поле теперь единственное и видимое
    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1, -40, 1, 0)
    codeBox.Position = UDim2.new(0, 40, 0, 0)
    codeBox.BackgroundTransparency = 1
    codeBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    codeBox.Font = Enum.Font.Code
    codeBox.TextSize = 14
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ClearTextOnFocus = false
    codeBox.MultiLine = true
    codeBox.TextWrapped = true
    codeBox.Parent = editorScroll

    -- === МЕНЮ ПОДСКАЗОК (АВТОДОПОЛНЕНИЕ) ===
    local suggestionsFrame = Instance.new("Frame")
    suggestionsFrame.Size = UDim2.new(0, 150, 0, 150)
    suggestionsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    suggestionsFrame.BorderSizePixel = 1
    suggestionsFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    suggestionsFrame.Visible = false
    suggestionsFrame.ZIndex = 10
    suggestionsFrame.Parent = xWin
    
    local uiList = Instance.new("UIListLayout")
    uiList.Parent = suggestionsFrame
    
    local suggestionButtons = {}
    local selectedIndex = 1
    local currentFiltered = {}

    local function hideSuggestions()
        suggestionsFrame.Visible = false
        currentFiltered = {}
    end

    local function updateSuggestionSelection()
        for i, btn in ipairs(suggestionButtons) do
            if i == selectedIndex then
                btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            else
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            end
        end
    end

    local function showSuggestions(prefix)
        for _, btn in ipairs(suggestionButtons) do btn:Destroy() end
        table.clear(suggestionButtons)
        currentFiltered = {}
        
        if prefix == "" then
            hideSuggestions()
            return
        end
        
        for _, word in ipairs(suggestionsList) do
            if word:lower():sub(1, #prefix) == prefix:lower() then
                table.insert(currentFiltered, word)
            end
        end
        
        if #currentFiltered == 0 then
            hideSuggestions()
            return
        end
        
        suggestionsFrame.Visible = true
        selectedIndex = 1
        
        for i, word in ipairs(currentFiltered) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.BorderSizePixel = 0
            btn.Text = word
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Font = Enum.Font.Code
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = suggestionsFrame
            
            btn.MouseButton1Click:Connect(function()
                local text = codeBox.Text
                local cursor = codeBox.CursorPosition
                local beforeCursor = text:sub(1, cursor - 1)
                local afterCursor = text:sub(cursor)
                local wordPrefix = beforeCursor:match("([%a_]+)$") or ""
                
                codeBox.Text = beforeCursor:sub(1, -#wordPrefix - 1) .. word .. afterCursor
                codeBox.CursorPosition = cursor - #wordPrefix + #word
                hideSuggestions()
                codeBox:CaptureFocus()
            end)
            
            table.insert(suggestionButtons, btn)
        end
        
        updateSuggestionSelection()
        
        local text = codeBox.Text
        local cursor = codeBox.CursorPosition
        local beforeCursor = text:sub(1, cursor - 1)
        local size = TextService:GetTextSize(beforeCursor, 14, Enum.Font.Code, Vector2.new(codeBox.AbsoluteSize.X, math.huge))
        
        local yPos = size.Y + 10
        local xPos = size.X + 10
        
        if yPos + 150 > xWin.AbsoluteSize.Y then
            yPos = yPos - 160
        end
        
        suggestionsFrame.Position = UDim2.new(0, xPos, 0, yPos)
    end

    -- === ОБНОВЛЕНИЕ ВИЗУАЛА (ТОЛЬКО НОМЕРА СТРОК) ===
    local function updateEditorVisuals()
        local text = codeBox.Text
        local lines = {}
        for line in text:gmatch("([^\n]*)\n?") do table.insert(lines, line) end
        if text:sub(-1) == "\n" then table.insert(lines, "") end
        
        local numStr = ""
        for i, line in ipairs(lines) do
            numStr = numStr .. i .. "\n"
            local lineSize = TextService:GetTextSize(line, 14, Enum.Font.Code, Vector2.new(codeBox.AbsoluteSize.X, math.huge))
            local extraLines = math.floor((lineSize.Y - 18) / 18)
            for j = 1, extraLines do
                numStr = numStr .. "\n"
            end
        end
        lineNumbers.Text = numStr

        local totalSize = TextService:GetTextSize(text, 14, Enum.Font.Code, Vector2.new(codeBox.AbsoluteSize.X, math.huge))
        local textHeight = totalSize.Y + 30
        editorScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(textHeight, editorScroll.AbsoluteSize.Y))
        lineNumbers.Size = UDim2.new(0, 30, 0, math.max(textHeight, editorScroll.AbsoluteSize.Y))
    end

    codeBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateEditorVisuals()
        local text = codeBox.Text
        local cursor = codeBox.CursorPosition
        local beforeCursor = text:sub(1, cursor - 1)
        local word = beforeCursor:match("([%a_]+)$")
        showSuggestions(word or "")
    end)
    
    codeBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
        if suggestionsFrame.Visible then
            hideSuggestions()
        end
    end)

    editorScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        lineNumbers.Position = UDim2.new(0, 5, 0, -editorScroll.CanvasPosition.Y)
        hideSuggestions()
    end)

    -- Обработка клавиш для меню автодополнения
    codeBox.InputBegan:Connect(function(input, processed)
        if processed then return end
        if suggestionsFrame.Visible then
            if input.KeyCode == Enum.KeyCode.Down then
                selectedIndex = math.min(#suggestionButtons, selectedIndex + 1)
                updateSuggestionSelection()
            elseif input.KeyCode == Enum.KeyCode.Up then
                selectedIndex = math.max(1, selectedIndex - 1)
                updateSuggestionSelection()
            elseif input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.Return then
                if currentFiltered[selectedIndex] then
                    local word = currentFiltered[selectedIndex]
                    local text = codeBox.Text
                    local cursor = codeBox.CursorPosition
                    local beforeCursor = text:sub(1, cursor - 1)
                    local afterCursor = text:sub(cursor)
                    local wordPrefix = beforeCursor:match("([%a_]+)$") or ""
                    
                    codeBox.Text = beforeCursor:sub(1, -#wordPrefix - 1) .. word .. afterCursor
                    codeBox.CursorPosition = cursor - #wordPrefix + #word
                    hideSuggestions()
                end
            end
        end
    end)

    -- === КНОПКИ ===
    btnExecute.MouseButton1Click:Connect(function()
        local success, err = pcall(function()
            local func = loadstring(codeBox.Text)
            if func then func() else error("Ошибка компиляции (пустой код)") end
        end)
        
        if success then
            log("Xcode: Скрипт выполнен успешно", "Success")
        else
            log("Xcode Error: " .. tostring(err), "Error")
            warn("[Xcode Error] " .. tostring(err))
        end
    end)

    btnClear.MouseButton1Click:Connect(function() 
        codeBox.Text = ""
    end)
    
    btnSelectAll.MouseButton1Click:Connect(function()
        codeBox.CursorPosition = 1
        codeBox.SelectionStart = #codeBox.Text + 1
        codeBox:CaptureFocus()
    end)

    btnSave.MouseButton1Click:Connect(function()
        if type(writefile) == "function" then
            local ok, err = pcall(function() writefile("Xcode_Script.lua", codeBox.Text) end)
            if ok then log("Xcode: Скрипт сохранен в Xcode_Script.lua", "Success")
            else log("Xcode Save Error: " .. tostring(err), "Error") end
        else
            log("Xcode: Функция writefile недоступна", "Error")
        end
    end)

    local xResize = Instance.new("TextButton")
    xResize.Size = UDim2.new(0, 16, 0, 16)
    xResize.Position = UDim2.new(1, -16, 1, -16)
    xResize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    xResize.Text = "◢"
    xResize.TextColor3 = Color3.fromRGB(150, 150, 150)
    xResize.Font = Enum.Font.Code
    xResize.TextSize = 12
    xResize.BorderSizePixel = 0
    xResize.ZIndex = 5
    xResize.Parent = xWin
    Instance.new("UICorner", xResize).CornerRadius = UDim.new(0, 4)

    local xResizing = false
    local xStartSize, xStartMouse
    xResize.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            xResizing = true
            xStartSize = xWin.AbsoluteSize
            xStartMouse = input.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if xResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - xStartMouse
            local newWidth = math.max(400, xStartSize.X + delta.X)
            local newHeight = math.max(200, xStartSize.Y + delta.Y)
            xWin.Size = UDim2.new(0, newWidth, 0, newHeight)
            updateEditorVisuals()
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then xResizing = false end
    end)

    codeBox.Text = "-- Напиши код на английском:\nlocal x = 10\nprint(\"Hello, world!\")\n"
    updateEditorVisuals()
end

-- === КОМАНДЫ КОНСОЛИ ===
local commands = {
    ["help"] = function()
        log("Commands:", "Info")
        log("  xyz, destroy, summon, kickme, color, codegui, clear", "Default")
    end,
    ["xyz"] = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
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
        open_xcode_gui()
        log("Xcode editor opened", "Success")
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
