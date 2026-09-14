-- =======================================================================
--  RenzVex Steal An Egg - Fluent UI Edition (Bypass Anti-Cheat)
-- =======================================================================

-- 1. LOAD FLUENT UI LIBRARY
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- 2. CREATE WINDOW UTAMA
local Window = Fluent:CreateWindow({
    Title = "RenzVex Steal An Egg",
    SubTitle = "by RenzVex",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- Nonaktifkan blur jika mengalami lag/crash
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "home" }),
    Filters = Window:AddTab({ Title = "Filter & Areas", Icon = "settings" })
}

-- =======================================================================
-- INITIALIZATION GAME SYSTEMS
-- =======================================================================
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages", 5)
local Networking = Packages and Packages:WaitForChild("Networking", 5)

-- Global Status & Settings
_G.AutoFarmTelur = false
_G.AutoTreadmillPintar = false
_G.TweenSpeed = 135

-- 10 TIER RARITY RESMI LENGKAP
local RarityPilihan = {
    ["Common"]      = false,
    ["Uncommon"]    = false,
    ["Rare"]        = false,
    ["Epic"]        = false,
    ["Legendary"]   = true,
    ["Mythic"]      = true,
    ["Cosmic"]      = true,
    ["Secret"]      = true,
    ["Eternal"]     = true,
    ["Divine"]      = true
}

-- 12 BIOME LENGKAP
local MapPilihan = {
    ["Forest"]          = true,
    ["Lake"]            = true,
    ["Desert"]          = true,
    ["Jungle"]          = true,
    ["Snow"]            = true,
    ["Volcano"]         = true,
    ["Abyss Ocean"]     = true,
    ["Prehistoric"]     = true,
    ["Cosmic"]          = true,
    ["Cherry Blossom"]  = true,
    ["Titan Temple"]    = true,
    ["AngelDemonZone"]  = true
}

-- Fungsi Deteksi Base Player
local function DapatkanBaseSaya()
    local WorkspaceBases = game.Workspace:FindFirstChild("Bases")
    if WorkspaceBases then
        local BaseSaya = WorkspaceBases:FindFirstChild(Player.Name)
        if BaseSaya then
            return BaseSaya:FindFirstChild("DepositPart") or BaseSaya:FindFirstChild("EggPen") or BaseSaya:FindFirstChild("Part") or BaseSaya
        end
    end
    return nil
end

-- Fungsi Lari Cepat Smooth Tween
local function PindahHalus(TargetCFrame)
    if not RootPart then return end
    local Jarak = (RootPart.Position - TargetCFrame.Position).Magnitude
    local Durasi = Jarak / _G.TweenSpeed
    local InfoTween = TweenInfo.new(Durasi, Enum.EasingStyle.Linear)
    local Animasi = TweenService:Create(RootPart, InfoTween, {CFrame = TargetCFrame})
    Animasi:Play()
    Animasi.Completed:Wait()
end

-- =======================================================================
-- CONTROLS (MAIN TAB)
-- =======================================================================
Tabs.Main:AddParagraph({ 
    Title = "🌌 RenzVex Perfect V4", 
    Content = "Bypass Anti-Cheat & Perbaikan Error FetchWearBestStatus." 
})

local ToggleFarm = Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "Auto Steal & Deposit", 
    Description = "Mencari telur pilihan, lari via Tween, lalu amankan ke base.",
    Default = false 
})
ToggleFarm:OnChanged(function(Value)
    _G.AutoFarmTelur = Value
end)

local ToggleTreadmill = Tabs.Main:AddToggle("AutoTreadmillToggle", {
    Title = "Auto Treadmill (Smart Grind)", 
    Description = "Otomatis latihan Speed di base jika tidak sedang membawa telur target.",
    Default = false 
})
ToggleTreadmill:OnChanged(function(Value)
    _G.AutoTreadmillPintar = Value
end)

local SpeedSlider = Tabs.Main:AddSlider("TweenSpeedSlider", {
    Title = "⚡ Tween Movement Speed",
    Description = "Atur kecepatan lari karakter",
    Default = _G.TweenSpeed,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        _G.TweenSpeed = Value
    end
})

-- =======================================================================
-- CONTROLS (FILTER TAB)
-- =======================================================================
Tabs.Filters:AddParagraph({ 
    Title = "✨ Filter Kelangkaan Telur", 
    Content = "Centang kelangkaan telur yang ingin dicuri." 
})

for RarityName, DefaultState in pairs(RarityPilihan) do
    local RarityToggle = Tabs.Filters:AddToggle("Rarity_" .. RarityName, {
        Title = "Ambil " .. RarityName,
        Default = DefaultState
    })
    RarityToggle:OnChanged(function(Value)
        RarityPilihan[RarityName] = Value
    end)
end

Tabs.Filters:AddParagraph({ 
    Title = "🗺️ Filter Pemindaian Map", 
    Content = "Aktifkan map berburu telur yang kamu inginkan." 
})

for MapName, DefaultState in pairs(MapPilihan) do
    local LabelMenu = (MapName == "AngelDemonZone") and "Scan di Map: Angels & Demons" or "Scan di Map: " .. MapName
    local MapToggle = Tabs.Filters:AddToggle("Map_" .. MapName, {
        Title = LabelMenu,
        Default = DefaultState
    })
    MapToggle:OnChanged(function(Value)
        MapPilihan[MapName] = Value
    end)
end

-- =======================================================================
-- BACKGROUND PROCESS
-- =======================================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoFarmTelur and Networking then
            local AskCarryEvent = Networking:FindFirstChild("RF/EggWorld/AskFieldEggCarry")
            local AskDoffTreadmill = Networking:FindFirstChild("RF/Treadmill/AskDoff")

            local TargetBase = DapatkanBaseSaya()  
            local FolderMap = game.Workspace:FindFirstChild("EggWorld") or game.Workspace  
              
            if AskCarryEvent then  
                for _, ObjekTelur in pairs(FolderMap:GetDescendants()) do  
                    if not _G.AutoFarmTelur then break end  
                      
                    local AreaTelur = ObjekTelur:GetAttribute("AreaId") or ObjekTelur.Name  
                    local RarityTelur = ObjekTelur:GetAttribute("Rarity") or "Unknown"  
                    local EggUid = ObjekTelur:GetAttribute("Uid")  
                    local SlotKey = ObjekTelur:GetAttribute("FirstAreaSlotKey")  

                    local MapDiizinkan = false  
                    if MapPilihan[AreaTelur] then  
                        MapDiizinkan = true  
                    elseif MapPilihan["AngelDemonZone"] and (string.match(AreaTelur, "Angel") or string.match(AreaTelur, "Demon")) then  
                        MapDiizinkan = true  
                    end  

                    if MapDiizinkan and RarityPilihan[RarityTelur] and EggUid and ObjekTelur:IsA("BasePart") then  
                        if AskDoffTreadmill then pcall(function() AskDoffTreadmill:InvokeServer() end) end  
                          
                        PindahHalus(ObjekTelur.CFrame)  
                        task.wait(0.2)  
                          
                        local SuksesAmbil = nil  
                        pcall(function()  
                            SuksesAmbil = AskCarryEvent:InvokeServer({ FirstAreaSlotKey = SlotKey, Uid = EggUid })  
                        end)  
                          
                        if SuksesAmbil and TargetBase then  
                            print("🚨 Telur Didapat! Berlari mengamankan ke Base...")  
                            PindahHalus(TargetBase.CFrame)  
                            task.wait(0.4)   
                            break  
                        end  
                    end  
                end  
            end  
        end  
    end
end)

-- Loop Treadmill
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoTreadmillPintar and Networking then
            local AskWearTreadmill = Networking:FindFirstChild("RF/Treadmill/AskWearStill")
            local AskDoffTreadmill = Networking:FindFirstChild("RF/Treadmill/AskDoff")

            if AskWearTreadmill and AskDoffTreadmill then  
                if _G.AutoFarmTelur == false or (not Character:FindFirstChild("EggCarried")) then   
                    pcall(function() AskWearTreadmill:InvokeServer() end)  
                    task.wait(5)  
                    pcall(function() AskDoffTreadmill:InvokeServer() end)  
                    task.wait(1)  
                end
            end  
        end  
    end
end)

Fluent:Notify({
    Title = "RenzVex Script",
    Content = "Berhasil dimuat dengan Fluent UI!",
    Duration = 5
})
