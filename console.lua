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

local russianMap = {
    ["переменная"] = "local", ["функция"] = "function",
    ["если"] = "if", ["тогда"] = "then", ["иначе"] = "else",
    ["конец"] = "end", ["пока"] = "while", ["делать"] = "do",
    ["для"] = "for", ["в"] = "in", ["вернуть"] = "return",
    ["игра"] = "game", ["мир"] = "workspace", ["напечатать"] = "print"
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

-- === КАСТОМНЫЙ КУРСОР (X) ===
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

    -- Кнопки
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

    local btnExecute = makeBtn("Execute", -310, 60)
    local btnClear = makeBtn("Clear", -240, 50)
    local btnSelectAll = makeBtn("Select All", -180, 70)
    local btnSave = makeBtn("Save", -100, 50)
    local btnClose = makeBtn("X", -30, 22)
    btnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btnClose.TextColor3 = Color3.new(1, 1, 1)

    -- Редактор
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
    
    -- Гуттер для флажков
    local flagGutter = Instance.new("TextButton")
    flagGutter.Size = UDim2.new(0, 20, 1, 0)
    flagGutter.BackgroundTransparency = 1
    flagGutter.Text = ""
    flagGutter.Parent = editorScroll

    -- Номера строк
    local lineNumbers = Instance.new("TextLabel")
    lineNumbers.Size = UDim2.new(0, 30, 1, 0)
    lineNumbers.Position = UDim2.new(0, 20, 0, 0)
    lineNumbers.BackgroundTransparency = 1
    lineNumbers.Text = "1"
    lineNumbers.TextColor3 = Color3.fromRGB(100, 100, 100)
    lineNumbers.Font = Enum.Font.Code
    lineNumbers.TextSize = 14
    lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
    lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
    lineNumbers.Parent = editorScroll

    -- Контейнер для текста
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -100, 1, 0)
    textContainer.Position = UDim2.new(0, 55, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = editorScroll

    local richLabel = Instance.new("TextLabel")
    richLabel.Size = UDim2.new(1, 0, 1, 0)
    richLabel.BackgroundTransparency = 1
    richLabel.Font = Enum.Font.Code
    richLabel.TextSize = 14
    richLabel.TextXAlignment = Enum.TextXAlignment.Left
    richLabel.TextYAlignment = Enum.TextYAlignment.Top
    richLabel.RichText = true
    richLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    richLabel.TextWrapped = false
    richLabel.Parent = textContainer

    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1, 0, 1, 0)
    codeBox.BackgroundTransparency = 1
    codeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    codeBox.TextTransparency = 1
    codeBox.Font = Enum.Font.Code
    codeBox.TextSize = 14
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ClearTextOnFocus = false
    codeBox.MultiLine = true
    codeBox.TextWrapped = false
    codeBox.Parent = textContainer

    -- Мини-карта (справа)
    local minimapContainer = Instance.new("Frame")
    minimapContainer.Size = UDim2.new(0, 60, 1, 0)
    minimapContainer.Position = UDim2.new(1, -65, 0, 0)
    minimapContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    minimapContainer.BorderSizePixel = 0
    minimapContainer.ClipsDescendants = true
    minimapContainer.Parent = editorScroll
    Instance.new("UICorner", minimapContainer).CornerRadius = UDim.new(0, 2)
    
    local minimapText = Instance.new("TextLabel")
    minimapText.Size = UDim2.new(1, 0, 1, 0)
    minimapText.BackgroundTransparency = 1
    minimapText.Font = Enum.Font.Code
    minimapText.TextSize = 2
    minimapText.TextColor3 = Color3.fromRGB(150, 150, 150)
    minimapText.TextXAlignment = Enum.TextXAlignment.Left
    minimapText.TextYAlignment = Enum.TextYAlignment.Top
    minimapText.TextWrapped = false
    minimapText.Parent = minimapContainer

    -- Кастомный курсор
    local customCursor = Instance.new("Frame")
    customCursor.Size = UDim2.new(0, 2, 0, 18)
    customCursor.BackgroundColor3 = Color3.new(1,1,1)
    customCursor.BorderSizePixel = 0
    customCursor.Visible = false
    customCursor.ZIndex = 5
    customCursor.Parent = textContainer

    -- Индикатор ошибки
    local errorMarker = Instance.new("Frame")
    errorMarker.Size = UDim2.new(0, 8, 0, 8)
    errorMarker.Position = UDim2.new(0, 6, 0, 5)
    errorMarker.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    errorMarker.BorderSizePixel = 0
    errorMarker.Visible = false
    errorMarker.ZIndex = 6
    errorMarker.Parent = editorScroll
    Instance.new("UICorner", errorMarker).CornerRadius = UDim.new(1, 0)
    
    -- Таблица флажков
    local flags = {}

    -- Панель подсказок
    local hintsLabel = Instance.new("TextLabel")
    hintsLabel.Size = UDim2.new(1, -20, 0, 20)
    hintsLabel.Position = UDim2.new(0, 10, 1, -22)
    hintsLabel.BackgroundTransparency = 1
    hintsLabel.Text = "Подсказка: local = переменная, game = игра, print = напечатать"
    hintsLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    hintsLabel.Font = Enum.Font.Code
    hintsLabel.TextSize = 11
    hintsLabel.TextXAlignment = Enum.TextXAlignment.Left
    hintsLabel.Parent = xWin

    -- === ПОДСВЕТКА СИНТАКСИСА ===
    local function applyHighlighting()
        local text = codeBox.Text
        text = text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")

        local strings = {}
        local stringIndex = 0

        text = text:gsub('"([^"]*)"', function(match)
            stringIndex = stringIndex + 1
            strings[stringIndex] = '"' .. match .. '"'
            return "___STR" .. stringIndex .. "___"
        end)
        text = text:gsub("'([^']*)'", function(match)
            stringIndex = stringIndex + 1
            strings[stringIndex] = "'" .. match .. "'"
            return "___STR" .. stringIndex .. "___"
        end)

        local keywords = {
            "local", "переменная", "function", "функция", "if", "если", "then", "тогда",
            "else", "иначе", "elseif", "end", "конец", "for", "для", "while", "пока",
            "do", "делать", "in", "в", "return", "вернуть", "break", "nil", "true", "false"
        }
        for _, kw in ipairs(keywords) do
            text = text:gsub("%f[%a]" .. kw .. "%f[%A]", '<font color="#C678DD">' .. kw .. '</font>')
        end

        local globals = {"game", "игра", "workspace", "мир", "script", "print", "напечатать", "warn"}
        for _, gl in ipairs(globals) do
            text = text:gsub("%f[%a]" .. gl .. "%f[%A]", '<font color="#61AFEF">' .. gl .. '</font>')
        end

        text = text:gsub("%f[%d](%d+)%f[%D]", '<font color="#D19A66">%1</font>')

        for i, str in ipairs(strings) do
            text = text:gsub("___STR" .. i .. "___", '<font color="#98C379">' .. str .. '</font>')
        end

        richLabel.Text = text
        minimapText.Text = codeBox.Text
    end

    -- === ОБНОВЛЕНИЕ ВИЗУАЛА ===
    local function updateEditorVisuals()
        local text = codeBox.Text
        local count = 1
        for _ in text:gmatch("\n") do count = count + 1 end
        local str = ""
        for i = 1, count do str = str .. i .. "\n" end
        lineNumbers.Text = str

        local textHeight = codeBox.TextBounds.Y + 30
        editorScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(textHeight, editorScroll.AbsoluteSize.Y))
        lineNumbers.Size = UDim2.new(0, 30, 0, math.max(textHeight, editorScroll.AbsoluteSize.Y))
        
        applyHighlighting()
        updateCursor()
        drawFlags()
    end

    local function updateCursor()
        if not codeBox:IsFocused() then
            customCursor.Visible = false
            return
        end
        customCursor.Visible = true
        
        local textBefore = codeBox.Text:sub(1, codeBox.CursorPosition - 1)
        local lines = {}
        local currentLine = ""
        for i = 1, #textBefore do
            local char = textBefore:sub(i, i)
            if char == "\n" then
                table.insert(lines, currentLine)
                currentLine = ""
            else
                currentLine = currentLine .. char
            end
        end
        
        local lineNum = #lines + 1
        local col = #currentLine
        
        local charWidth = 8.4
        local xPos = col * charWidth
        local yPos = (lineNum - 1) * 18
        
        customCursor.Position = UDim2.new(0, xPos, 0, yPos)
    end

    -- === ОТРИСОВКА ФЛАЖКОВ ===
    local function drawFlags()
        for _, child in ipairs(editorScroll:GetChildren()) do
            if child.Name == "FlagMarker" then child:Destroy() end
        end
        for line, _ in pairs(flags) do
            local flag = Instance.new("TextLabel")
            flag.Name = "FlagMarker"
            flag.Size = UDim2.new(0, 14, 0, 14)
            flag.Position = UDim2.new(0, 3, 0, (line - 1) * 18 + 2)
            flag.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
            flag.Text = "🚩"
            flag.TextSize = 10
            flag.TextColor3 = Color3.new(0,0,0)
            flag.BorderSizePixel = 0
            flag.ZIndex = 5
            flag.Parent = editorScroll
            Instance.new("UICorner", flag).CornerRadius = UDim.new(1, 0)
        end
    end

    -- Клик по гуттеру (установка флажка)
    flagGutter.MouseButton1Click:Connect(function()
        local mouseY = UIS:GetMouseLocation().Y
        local relativeY = mouseY - flagGutter.AbsolutePosition.Y
        local line = math.floor(relativeY / 18) + 1
        
        if line > 0 then
            if flags[line] then
                flags[line] = nil
            else
                flags[line] = true
            end
            drawFlags()
        end
    end)

    codeBox:GetPropertyChangedSignal("Text"):Connect(updateEditorVisuals)
    codeBox:GetPropertyChangedSignal("CursorPosition"):Connect(updateCursor)
    codeBox.Focused:Connect(updateCursor)
    codeBox.FocusLost:Connect(function() customCursor.Visible = false end)

    editorScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        lineNumbers.Position = UDim2.new(0, 20, 0, -editorScroll.CanvasPosition.Y)
        textContainer.Position = UDim2.new(0, 55, 0, -editorScroll.CanvasPosition.Y)
        minimapContainer.Position = UDim2.new(1, -65, 0, -editorScroll.CanvasPosition.Y)
        for _, child in ipairs(editorScroll:GetChildren()) do
            if child.Name == "FlagMarker" then
                local line = math.floor(child.Position.Y.Offset / 18) + 1
                child.Position = UDim2.new(0, 3, 0, (line - 1) * 18 + 2 - editorScroll.CanvasPosition.Y)
            end
        end
        if errorMarker.Visible then
            local line = math.floor(errorMarker.Position.Y.Offset / 18) + 1
            errorMarker.Position = UDim2.new(0, 6, 0, (line - 1) * 18 + 5 - editorScroll.CanvasPosition.Y)
        end
    end)

    -- === TAB AUTOCOMPLETE ===
    codeBox.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Tab then
            local text = codeBox.Text
            local cursor = codeBox.CursorPosition
            local beforeCursor = text:sub(1, cursor - 1)
            local word = beforeCursor:match("([%a_]+)$")
            
            if word then
                local suggestions = {
                    ["loc"] = "local", ["перем"] = "переменная",
                    ["fun"] = "function", ["функ"] = "функция",
                    ["gam"] = "game", ["игр"] = "игра",
                    ["pri"] = "print", ["напе"] = "напечатать",
                    ["wor"] = "workspace", ["ми"] = "мир",
                    ["ret"] = "return", ["вер"] = "вернуть"
                }
                local suggestion = suggestions[word:lower()]
                if suggestion then
                    local newText = text:sub(1, cursor - 1 - #word) .. suggestion .. text:sub(cursor)
                    codeBox.Text = newText
                    codeBox.CursorPosition = cursor - #word + #suggestion
                end
            end
        end
    end)

    -- === КНОПКИ ===
    btnExecute.MouseButton1Click:Connect(function()
        errorMarker.Visible = false
        local finalCode = codeBox.Text
        for ru, en in pairs(russianMap) do
            finalCode = finalCode:gsub("%f[%a]" .. ru .. "%f[%A]", en)
        end
        
        local success, err = pcall(function()
            local func = loadstring(finalCode)
            if func then func() else error("Ошибка компиляции (пустой код)") end
        end)
        
        if success then
            log("Xcode: Скрипт выполнен успешно", "Success")
        else
            log("Xcode Error: " .. tostring(err), "Error")
            warn("[Xcode Error] " .. tostring(err))
            
            local line = tostring(err):match(":(%d+):")
            if line then
                errorMarker.Position = UDim2.new(0, 6, 0, (tonumber(line) - 1) * 18 + 5 - editorScroll.CanvasPosition.Y)
                errorMarker.Visible = true
            end
        end
    end)

    btnClear.MouseButton1Click:Connect(function() codeBox.Text = ""; flags = {}; drawFlags(); errorMarker.Visible = false end)
    
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

    btnClose.MouseButton1Click:Connect(function() xGui:Destroy() end)

    -- Изменение размера
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
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then xResizing = false end
    end)

    codeBox.Text = "-- Напиши код на англ или русском:\nlocal x = 10\nнапечатать(\"Привет, мир!\")\n"
    updateEditorVisuals()
end

-- === КОМАНДЫ ===
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
