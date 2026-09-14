-- =======================================================================
--  RenzVex Steal An Egg - WindUI Galaxy Theme (Slider Speed Update)
-- =======================================================================

-- 1. LOAD WINDUI LIBRARY
local WindUI = loadstring(game:HttpGet("https://tree-hub.xyz"))()

-- 2. CREATE WINDOW UTAMA (TEMA UNGU GALAXY)
local Window = WindUI:CreateWindow({
    Title = "RenzVex Steal An Egg",
    Icon = "rbxassetid://107778070777162", -- Icon Resmi Steal An Egg
    Author = "by RenzVex",
    Folder = "RenzVexStealAnEgg",
    Theme = "Dark", 
    Accent = Color3.fromRGB(138, 43, 226), -- Ungu Galaxy Neon
})

-- Kustomisasi Background Galaxy Deep Purple
if Window.Main then
    Window.Main.BackgroundColor3 = Color3.fromRGB(14, 8, 28)
end

-- Membuat Tab Menu
local TabMain = Window:CreateTab({ Title = "Main Farm", Icon = "home" })
local TabFilters = Window:CreateTab({ Title = "Filter & Areas", Icon = "settings" })

-- =======================================================================
-- INISIALISASI SISTEM GAME & VALIABEL GLOBAL
-- =======================================================================
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

local Networking = game:GetService("ReplicatedStorage").Packages.Networking
local AskCarryEvent = Networking["RF/EggWorld/AskFieldEggCarry"]
local HaulStatusEvent = Networking["RF/Haul/FetchWearBestStatus"]
local AskWearTreadmill = Networking["RF/Treadmill/AskWearStill"]
local AskDoffTreadmill = Networking["RF/Treadmill/AskDoff"]

-- Status Variabel Utama
_G.AutoFarmTelur = false
_G.AutoTreadmillPintar = false
_G.TweenSpeed = 135 -- Kecepatan bawaan awal (Default)

-- Tabel Pengaturan Filter Kelangkaan Telur
local RarityPilihan = {
    ["Common"]      = false,
    ["Rare"]        = false,
    ["Legendary"]   = true,
    ["Mythic"]      = true,
    ["Cosmic"]      = true,
    ["Secret"]      = true,
    ["Eternal"]     = true,
    ["Divine"]      = true  -- Kelangkaan Biome Angels & Demons
}

-- Daftar 12 Biome Lengkap
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
    ["Angels"]          = true,
    ["Demons"]          = true,
    ["AngelsDemons"]    = true
}

-- Fungsi Deteksi Tempat Taruh Telur di Base Sendiri
local function DapatkanBaseSaya()
    local BaseSaya = game.Workspace.Bases:FindFirstChild(Player.Name)
    if BaseSaya then
        return BaseSaya:FindFirstChild("DepositPart") or BaseSaya:FindFirstChild("EggPen") or BaseSaya
    end
    return nil
end

-- Fungsi Gerakan Lari Cepat Menggunakan Variabel Dinamis _G.TweenSpeed
local function PindahHalus(TargetCFrame)
    local Jarak = (RootPart.Position - TargetCFrame.Position).Magnitude
    local Durasi = Jarak / _G.TweenSpeed -- Otomatis berubah mengikuti Slider UI
    local InfoTween = TweenInfo.new(Durasi, Enum.EasingStyle.Linear)
    local Animasi = TweenService:Create(RootPart, InfoTween, {CFrame = TargetCFrame})
    Animasi:Play()
    Animasi.Completed:Wait()
end

-- =======================================================================
-- TAB 1: MAIN FARM (KONTROL UTAMA & SLIDER SPEED)
-- =======================================================================
TabMain:CreateParagraph({ Title = "🌌 Welcome to RenzVex Hub", Desc = "Otomatisasi penuh untuk game Steal An Egg versi Mobile." })

TabMain:CreateToggle({
    Title = "Auto Steal & Deposit",
    Desc = "Mencari telur pilihan, lari via Tween, lalu drop otomatis di base.",
    Default = false,
    Callback = function(Value)
        _G.AutoFarmTelur = Value
        if Value then
            print("[RenzVex] Auto Steal Dinyalakan!")
        end
    end
})

TabMain:CreateToggle({
    Title = "Auto Treadmill (Smart Grind)",
    Desc = "Berlatih menambah Speed otomatis jika sedang tidak membawa telur.",
    Default = false,
    Callback = function(Value)
        _G.AutoTreadmillPintar = Value
    end
})

-- FITUR BARU: Slider untuk Mengatur Kecepatan Gerakan Tween Lari
TabMain:CreateSlider({
    Title = "⚡ Tween Movement Speed",
    Desc = "Sesuaikan kecepatan lari karakter untuk menghindari Bos atau Anti-Cheat.",
    Min = 50,
    Max = 300,
    Default = _G.TweenSpeed,
    Callback = function(Value)
        _G.TweenSpeed = Value
        print("[RenzVex] Kecepatan Tween diatur ke: " .. Value)
    end
})

-- =======================================================================
-- TAB 2: FILTER & AREAS (PILIHAN CUSTOM)
-- =======================================================================
TabFilters:CreateParagraph({ Title = "✨ Filter Kelangkaan Telur", Desc = "Aktifkan kelangkaan telur yang ingin kamu incar." })

for RarityName, _ in pairs(RarityPilihan) do
    TabFilters:CreateToggle({
        Title = "Ambil " .. RarityName,
        Default = RarityPilihan[RarityName],
        Callback = function(Value)
            RarityPilihan[RarityName] = Value
        end
    })
end

TabFilters:CreateParagraph({ Title = "🗺️ Filter Pemindaian Map (12 Biome)", Desc = "Pilih area mana saja yang ingin dipindai oleh karaktermu." })

for MapName, _ in pairs(MapPilihan) do
    TabFilters:CreateToggle({
        Title = "Scan di Map: " .. MapName,
        Default = MapPilihan[MapName],
        Callback = function(Value)
            MapPilihan[MapName] = Value
        end
    })
end

-- =======================================================================
-- SISTEM UTAMA BACKEND BACKGROUND PROCESSES
-- =======================================================================
-- Thread Loop 1: Proses Auto Steal & Bawa ke Base
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoFarmTelur then
            local TargetBase = DapatkanBaseSaya()
            local FolderMap = game.Workspace:FindFirstChild("EggWorld") or game.Workspace
            
            for _, ObjekTelur in pairs(FolderMap:GetDescendants()) do
                if not _G.AutoFarmTelur then break end
                
                local AreaTelur = ObjekTelur:GetAttribute("AreaId") or ObjekTelur.Name
                local RarityTelur = ObjekTelur:GetAttribute("Rarity") or "Unknown"
                local EggUid = ObjekTelur:GetAttribute("Uid")
                local SlotKey = ObjekTelur:GetAttribute("FirstAreaSlotKey")

                if MapPilihan[AreaTelur] and RarityPilihan[RarityTelur] and EggUid and ObjekTelur:IsA("BasePart") then
                    AskDoffTreadmill:InvokeServer()
                    
                    -- Langkah 1: Otw lari ke Sarang Telur
                    PindahHalus(ObjekTelur.CFrame)
                    task.wait(0.2)
                    
                    -- Langkah 2: Mengirim Sinyal Ambil
                    local SuksesAmbil = AskCarryEvent:InvokeServer({
                        FirstAreaSlotKey = SlotKey,
                        Uid = EggUid
                    })
                    
                    -- Langkah 3: Jika Berhasil, Lari ke Base untuk Menaruh Telur
                    if SuksesAmbil and TargetBase then
                        PindahHalus(TargetBase.CFrame)
                        task.wait(0.2)
                        
                        -- Mengirim Sinyal Taruh Barang Bawaan
                        HaulStatusEvent:InvokeServer()
                        break
                    end
                end
            end
        end
    end
end)

-- Thread Loop 2: Proses Auto Treadmill
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoTreadmillPintar then
            if _G.AutoFarmTelur == false then 
                AskWearTreadmill:InvokeServer()
                task.wait(5)
                AskDoffTreadmill:InvokeServer()
                task.wait(1)
            elseif _G.AutoFarmTelur and not Character:FindFirstChild("EggCarried") then
                AskWearTreadmill:InvokeServer()
                task.wait(5)
                AskDoffTreadmill:InvokeServer()
                task.wait(1)
            end
        end
    end
end)

-- NOTIFIKASI TANDA SUKSES LOAD DI HP
WindUI:Notify({
    Title = "RenzVex Script Loaded!",
    Content = "Slider Speed & Tema Galaxy Siap Digunakan.",
    Duration = 5
})
