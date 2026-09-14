-- =======================================================================
--  RenzVex Steal An Egg - WindUI Ultra Safe Edition (Anti-Fetch Fix)
-- =======================================================================

-- 1. LOAD STABLE UNIVERSAL UI LIBRARY
local WindUI = nil
local SuksesLoadUI = pcall(function()
    return loadstring(game:HttpGet("https://tree-hub.xyz"))()
end)

if not SuksesLoadUI or not WindUI then
    -- Link alternatif jika domain di atas terblokir
    WindUI = loadstring(game:HttpGet("https://githubusercontent.com"))()
end

-- 2. CREATE WINDOW UTAMA (TEMA UNGU GALAXY)
local Window = WindUI:CreateWindow({
    Title = "RenzVex Steal An Egg",
    Icon = "rbxassetid://107778070777162",
    Author = "by RenzVex",
    Folder = "RenzVexStealAnEgg",
    Theme = "Dark", 
    Accent = Color3.fromRGB(138, 43, 226), -- Ungu Galaxy Cerah
})

if Window.Main then
    Window.Main.BackgroundColor3 = Color3.fromRGB(14, 8, 28) -- Deep Space Background
end

local TabMain = Window:CreateTab({ Title = "Main Farm", Icon = "home" })
local TabFilters = Window:CreateTab({ Title = "Filter & Areas", Icon = "settings" })

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
            -- MENCARI GERBANG FISIK DEPOSIT (Bukan menembak Remote)
            return BaseSaya:FindFirstChild("DepositPart") or BaseSaya:FindFirstChild("EggPen") or BaseSaya:FindFirstChild("Part") or BaseSaya
        end
    end
    return nil
end

-- Fungsi Lari Cepat Smooth Tween (Aman Dari Deteksi Jarak)
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
-- VISUAL UI CONTROLS
-- =======================================================================
TabMain:CreateParagraph({ Title = "🌌 RenzVex Perfect V4", Desc = "Bypass Anti-Cheat & Perbaikan Error FetchWearBestStatus." })

TabMain:CreateToggle({
    Title = "Auto Steal & Deposit",
    Desc = "Mencari telur pilihan, lari via Tween, lalu amankan ke base sebelum dikejar Bos.",
    Default = false,
    Callback = function(Value) _G.AutoFarmTelur = Value end
})

TabMain:CreateToggle({
    Title = "Auto Treadmill (Smart Grind)",
    Desc = "Otomatis latihan Speed di base jika tidak sedang membawa telur target.",
    Default = false,
    Callback = function(Value) _G.AutoTreadmillPintar = Value end
})

TabMain:CreateSlider({
    Title = "⚡ Tween Movement Speed",
    Min = 50, Max = 300, Default = _G.TweenSpeed,
    Callback = function(Value) _G.TweenSpeed = Value end
})

-- Menghasilkan Filter Toggles secara Berurutan
TabFilters:CreateParagraph({ Title = "✨ Filter Kelangkaan Telur (10 Tier)", Desc = "Centang kelangkaan telur yang ingin dicuri karaktermu." })
for RarityName, _ in pairs(RarityPilihan) do
    TabFilters:CreateToggle({ Title = "Ambil " .. RarityName, Default = RarityPilihan[RarityName], Callback = function(Value) RarityPilihan[RarityName] = Value end })
end

TabFilters:CreateParagraph({ Title = "🗺️ Filter Pemindaian Map (12 Biome)", Desc = "Aktifkan map berburu telur yang kamu inginkan." })
for MapName, _ in pairs(MapPilihan) do
    local LabelMenu = (MapName == "AngelDemonZone") and "Scan di Map: Angels & Demons" or "Scan di Map: " .. MapName
    TabFilters:CreateToggle({ Title = LabelMenu, Default = MapPilihan[MapName], Callback = function(Value) MapPilihan[MapName] = Value end })
end

-- =======================================================================
-- BACKGROUND PROCESS (METODE BYPASS SENTUHAN FISIK)
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

                    -- Deteksi Dinamis Biome ke-12 (Angels / Demons)
                    local MapDiizinkan = false
                    if MapPilihan[AreaTelur] then
                        MapDiizinkan = true
                    elseif MapPilihan["AngelDemonZone"] and (string.match(AreaTelur, "Angel") or string.match(AreaTelur, "Demon")) then
                        MapDiizinkan = true
                    end

                    -- Validasi Kelayakan Objek
                    if MapDiizinkan and RarityPilihan[RarityTelur] and EggUid and ObjekTelur:IsA("BasePart") then
                        if AskDoffTreadmill then pcall(function() AskDoffTreadmill:InvokeServer() end) end
                        
                        -- Lari ke tempat telur
                        PindahHalus(ObjekTelur.CFrame)
                        task.wait(0.2)
                        
                        local SuksesAmbil = nil
                        pcall(function()
                            SuksesAmbil = AskCarryEvent:InvokeServer({ FirstAreaSlotKey = SlotKey, Uid = EggUid })
                        end)
                        
                        -- JIKA SUKSES MENGGENGGAM TELUR:
                        if SuksesAmbil and TargetBase then
                            print("🚨 Telur Didapat! Berlari mengamankan ke Base...")
                            
                            -- Langkah Aman: Lari ke Base secara fisik agar menyentuh area deposit
                            PindahHalus(TargetBase.CFrame)
                            
                            -- Jeda 0.4 detik agar sistem game memproses masuknya telur secara natural via sentuhan fisik karakter
                            task.wait(0.4) 
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Loop Latihan Speed Bawaan Base
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

WindUI:Notify({ Title = "RenzVex Perfect Loaded!", Content = "Menggunakan metode Bypass Sentuhan Fisik Baru.", Duration = 5 })
