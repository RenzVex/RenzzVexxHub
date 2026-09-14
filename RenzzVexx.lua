-- =========================================================================
--  RENZZVEXX HUB - STEAL AN EGG GOD EDITION v3.5 (ULTIMATE REBUILT CORE)
-- =========================================================================

-- Multi-Link Fallback System untuk Bypass Total HttpError: DnsResolve
local OrionLib;
local success, err = pcall(function()
    OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

if not success or not OrionLib then
    success, err = pcall(function()
        OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
    end)
end

-- Membuat Jendela Utama Skrip
local Window = OrionLib:MakeWindow({
    Name = "RenzzVexx Hub • Ultimate v3.5 (God Mode)",
    HidePremium = true,
    SaveConfig = false,
    IntroText = "Initializing RenzzVexx Pro...",
    IntroIcon = "rbxassetid://4483345998"
})

-- State Global Skrip
_G.AutoSteal = false
_G.StealMethod = "Smart Lari/Tween Safe"
_G.AntiBoss = false
_G.GodMode = false
_G.TweenSpeed = 120 -- Diatur di angka aman agar tidak terdeteksi speed/anti-cheat
_G.SafeOffset = 3
_G.SelectedArea = "Forest"          
_G.SelectedRarity = "All Rarity"
_G.AutoTreadmill = false
_G.AutoRebirth = false
_G.AutoCollectRings = false
_G.PotatoGraphics = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =========================================================================
--  ENGINE 1: GODMODE & ANTI-BOSS / ANTI-TRAP BYPASS
-- =========================================================================
local function applyGodMode(enable)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if enable then
        -- Mematikan state kematian sementara agar kebal pukulan NPC/Boss
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid.BreakJointsOnDeath = false
    else
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        humanoid.BreakJointsOnDeath = true
    end
end

local function applyAntiBoss()
    local enemyFolder = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Guards") or workspace:FindFirstChild("Bosses")
    if not enemyFolder then return end

    -- Menghapus pemicu kematian instan/hitbox musuh di client
    for _, enemy in pairs(enemyFolder:GetDescendants()) do
        if enemy:IsA("TouchInterest") or enemy.Name == "DetectionArea" or enemy.Name == "Hitbox" then
            enemy:Destroy()
        end
    end

    -- Membekukan AI penjaga agar tidak mengejar
    for _, npc in pairs(enemyFolder:GetChildren()) do
        local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("PrimaryPart")
        local hum = npc:FindFirstChildOfClass("Humanoid")
        if root and _G.AntiBoss then
            root.Anchored = true
            if hum then hum.WalkSpeed = 0 end
        elseif root and not _G.AntiBoss then
            root.Anchored = false
        end
    end
end

local function applyPotatoGraphics(enable)
    _G.PotatoGraphics = enable
    if enable then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        workspace.Lighting.GlobalShadows = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
    end
end

-- =========================================================================
--  ENGINE 2: PRO STEAL & AUTO RETURN TO BASE
-- =========================================================================
local function executeSteal(targetEgg)
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return end

    local eggCFrame = targetEgg:IsA("Model") and targetEgg.PrimaryPart and targetEgg.PrimaryPart.CFrame or (targetEgg:IsA("BasePart") and targetEgg.CFrame)
    if not eggCFrame then return end

    -- Nyalakan Godmode otomatis saat mengambil telur
    if _G.GodMode then applyGodMode(true) end

    -- 1. Gerak lari/melayang mulus ke arah telur dengan kecepatan terkontrol
    local distance = (rootPart.Position - eggCFrame.Position).Magnitude
    local duration = distance / math.clamp(_G.TweenSpeed, 60, 160) -- Kecepatan aman anti-cheat
    
    local tween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = eggCFrame * CFrame.new(0, _G.SafeOffset, 0)
    })
    
    tween:Play()
    tween.Completed:Wait()
    task.wait(0.06)

    -- 2. Tembak Event Remote Game (Claim / Steal Egg)
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local claimRemote = eventsFolder and (eventsFolder:FindFirstChild("ClaimEgg") or eventsFolder:FindFirstChild("StealEgg"))
    if claimRemote then
        claimRemote:FireServer(targetEgg)
    end
    
    task.wait(0.1)

    -- 3. Otomatis Pulang ke Base (Auto Return) secara halus
    local baseFolder = workspace:FindFirstChild("Bases") or workspace:FindFirstChild("PlayerBases")
    local myBase = baseFolder and (baseFolder:FindFirstChild(LocalPlayer.Name) or baseFolder:FindFirstChild("Base"))
    local baseTargetCFrame = CFrame.new(0, 10, 0) -- Default fallback
    
    if myBase and myBase:FindFirstChild("PrimaryPart") then
        baseTargetCFrame = myBase.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
    elseif myBase and myBase:IsA("BasePart") then
        baseTargetCFrame = myBase.CFrame * CFrame.new(0, 3, 0)
    end

    local returnDist = (rootPart.Position - baseTargetCFrame.Position).Magnitude
    local returnDuration = returnDist / math.clamp(_G.TweenSpeed, 60, 160)
    
    local returnTween = TweenService:Create(rootPart, TweenInfo.new(returnDuration, Enum.EasingStyle.Linear), {
        CFrame = baseTargetCFrame
    })
    
    returnTween:Play()
    returnTween.Completed:Wait()

    if _G.GodMode then applyGodMode(false) end
end

-- =========================================================================
--  ENGINE 3: LOOPS AUTOMATION (BACKGROUND WORKERS)
-- =========================================================================

-- Loop Utama: Auto Steal dengan Filter Area & Rarity
task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.AutoSteal then
            local mapFolder = workspace:FindFirstChild("Eggs") or workspace:FindFirstChild("EggsFolder") or workspace:FindFirstChild("Map")
            if mapFolder then
                local targetBiome = mapFolder:FindFirstChild(_G.SelectedArea) or mapFolder
                for _, egg in pairs(targetBiome:GetDescendants()) do
                    if _G.AutoSteal and (egg:IsA("BasePart") or egg:IsA("Model")) and egg.Name:lower():find("egg") then
                        local eggName = egg.Name:lower()
                        local selectedFilter = _G.SelectedRarity:lower()
                        
                        local isRarityValid = (selectedFilter == "all rarity") or eggName:find(selectedFilter)
                        
                        if isRarityValid then 
                            executeSteal(egg)
                            task.wait(1) -- Jeda antar pengambilan agar stabil
                        end
                    end
                end
            end
        end
    end
end)

-- Loop Sekunder: Rutinitas Pendukung
task.spawn(function()
    while true do
        task.wait(0.1)
        
        if _G.AntiBoss then pcall(applyAntiBoss) end
        
        if _G.AutoTreadmill then
            local treadmillRemote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("TrainTreadmill")
            if treadmillRemote then treadmillRemote:FireServer() end
        end
        
        if _G.AutoRebirth then
            local rebirthRemote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Rebirth")
            if rebirthRemote then rebirthRemote:FireServer() end
        end
        
        if _G.AutoCollectRings then
            local ringsFolder = workspace:FindFirstChild("Rings") or workspace:FindFirstChild("EventRings")
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if ringsFolder and root then
                for _, ring in pairs(ringsFolder:GetChildren()) do
                    if ring:IsA("BasePart") then
                        root.CFrame = ring.CFrame
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end)

-- =========================================================================
--  USER INTERFACE (ORION HUB UI DESIGN)
-- =========================================================================

local TabMain = Window:MakeTab({Name = "Main Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SectionMain = TabMain:AddSection({Name = "Main Automation Control"})

SectionMain:AddToggle({
    Name = "Auto Steal Egg (Pro Mode)",
    Default = false,
    Callback = function(state) _G.AutoSteal = state end
})

SectionMain:AddToggle({
    Name = "God Mode (Anti-Death Bypass)",
    Default = false,
    Callback = function(state) 
        _G.GodMode = state 
        applyGodMode(state)
    end
})

SectionMain:AddToggle({
    Name = "Anti-Boss / Guard Freeze",
    Default = false,
    Callback = function(state) _G.AntiBoss = state end
})

SectionMain:AddToggle({
    Name = "Auto Collect Event Rings",
    Default = false,
    Callback = function(state) _G.AutoCollectRings = state end
})

local TabFilter = Window:MakeTab({Name = "Target Filters", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SectionFilter = TabFilter:AddSection({Name = "Biomes & Rarities Synced"})

SectionFilter:AddDropdown({
    Name = "Select Biome",
    Default = "Forest",
    Options = { "Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", "Abyss Ocean", "Prehistoric", "Cosmic", "Cherry Blossom", "Titan Temple", "Angels & Demons" },
    Callback = function(current) _G.SelectedArea = current end
})

SectionFilter:AddDropdown({
    Name = "Select Rarity",
    Default = "All Rarity",
    Options = { "All Rarity", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic", "Secret", "Divine", "Luminous", "Eternal" },
    Callback = function(current) _G.SelectedRarity = current end
})

local TabStats = Window:MakeTab({Name = "Auto Stats & Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SectionStats = TabStats:AddSection({Name = "Training & Performance Upgrades"})

SectionStats:AddToggle({
    Name = "Auto Treadmill (Train)",
    Default = false,
    Callback = function(state) _G.AutoTreadmill = state end
})

SectionStats:AddToggle({
    Name = "Auto Rebirth",
    Default = false,
    Callback = function(state) _G.AutoRebirth = state end
})

SectionStats:AddToggle({
    Name = "Potato Graphics (Boost FPS)",
    Default = false,
    Callback = function(state) applyPotatoGraphics(state) end
})

OrionLib:Init()
