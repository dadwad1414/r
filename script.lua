-- =============================================
-- 🔒 نظام المفتاح اليومي المربوط بـ GitHub & Work.ink
-- =============================================

-- 1. رابط ملف key.txt الخاص بك على GitHub لجلب المفتاح اليومي منه تلقائياً
local KeyURL = "https://raw.githubusercontent.com/dadwad1414/r/main/key.txt"

-- 2. رابط إعلان Work.ink الجديد الخاص بك
local AdLink = "https://work.ink/35Hk/721c0f36" 

-- جلب المفتاح تلقائياً من GitHub
local CorrectKey = ""
local success, result = pcall(function()
    return game:HttpGet(KeyURL)
end)

if success then
    CorrectKey = result:gsub("%s+", "") -- تنظيف النص من المسافات
else
    -- مفتاح احتياطي في حال فشل جلب الرابط
    local date = os.date("!*t")
    CorrectKey = string.format("Key-%d-%d-%d-WT", date.year, date.month, date.day)
end

-- =============================================
-- ⚙️ إعدادات سكربت الهيدبوكس الخاص بك
-- =============================================
local TOGGLE_KEY = Enum.KeyCode.B    -- زر التشغيل/الإيقاف (B)
local HITBOX_SIZE = 2.5             -- حجم الهيدبوكس
local KEEP_HEAD_NORMAL = true        -- الحفاظ على شكل الرأس طبيعي

local Enabled = false
local KeyVerified = false
local Original = {}

-- =============================================
-- 🖥️ واجهة إدخال المفتاح (Key System GUI)
-- =============================================
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("HitboxKeySystemGui") then
    CoreGui.HitboxKeySystemGui:Destroy()
end

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "HitboxKeySystemGui"
KeyGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = KeyGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "نظام التحقق - Hitbox Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.85, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.075, 0, 0, 55)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(220, 100, 30)
GetKeyBtn.Text = "نسخ رابط الإعلان ( Work.ink )"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.SourceSansBold
GetKeyBtn.TextSize = 13
GetKeyBtn.Parent = MainFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.85, 0, 0, 35)
KeyInput.Position = UDim2.new(0.075, 0, 0, 100)
KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
KeyInput.PlaceholderText = "أدخل المفتاح هنا..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.SourceSans
KeyInput.TextSize = 14
KeyInput.Parent = MainFrame

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.85, 0, 0, 35)
SubmitBtn.Position = UDim2.new(0.075, 0, 0, 145)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
SubmitBtn.Text = "تأكيد المفتاح"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.TextSize = 15
SubmitBtn.Parent = MainFrame

-- نسخ رابط الإعلان
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(AdLink)
    GetKeyBtn.Text = "تم نسخ الرابط! افتحه بالمتصفح"
    task.wait(2)
    GetKeyBtn.Text = "نسخ رابط الإعلان ( Work.ink )"
end)

-- =============================================
-- 🚀 منطق السكربت الأصلي للهيدبوكس
-- =============================================

function RestoreAll()
    for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") and Original[v.UserId] then
            local Head = v.Character.Head
            Head.Size = Original[v.UserId].Size
            Head.Transparency = Original[v.UserId].Transparency
            Head.CanCollide = Original[v.UserId].CanCollide
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not KeyVerified or not Enabled then return end
    
    for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
        if v == game.Players.LocalPlayer or not v.Character or not v.Character:FindFirstChild("Head") then continue end
        local Head = v.Character.Head
        if not Original[v.UserId] then
            Original[v.UserId] = {Size=Head.Size, Transparency=Head.Transparency, CanCollide=Head.CanCollide}
        end
        
        Head.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
        Head.Transparency = Original[v.UserId].Transparency
        Head.CanCollide = false
        
        local Mesh = Head:FindFirstChildWhichIsA("SpecialMesh")
        if Mesh then Mesh.Scale = Vector3.one end
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(Input, GP)
    if not KeyVerified or GP or Input.KeyCode ~= TOGGLE_KEY then return end
    Enabled = not Enabled
    if not Enabled then RestoreAll() end
end)

-- التحقق من إدخال المفتاح
SubmitBtn.MouseButton1Click:Connect(function()
    local userKey = KeyInput.Text:gsub("%s+", "")
    
    if userKey == CorrectKey then
        SubmitBtn.Text = "مفتاح صحيح! اضغط B للتشغيل"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
        KeyVerified = true
        task.wait(1.5)
        KeyGui:Destroy()
    else
        SubmitBtn.Text = "مفتاح خاطئ!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(178, 34, 34)
        task.wait(1.5)
        SubmitBtn.Text = "تأكيد المفتاح"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
    end
end)
