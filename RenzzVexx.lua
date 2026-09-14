-- =========================================================================
--  RENZZVEXX HUB • ULTIMATE v4.3 (FULL ERROR CHECK & COMPLETE DATA)
-- =========================================================================

local successUI, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist.lua"))()
end)

if not successUI or not WindUI then
    warn("Gagal memuat WindUI! Periksa koneksi internet atau executor.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "RenzzVexx Hub • Steal an Egg",
    Icon = "rbxassetid://4483345998",
    Author = "Created by RenzzVexx | v4.3 Ultimate",
    Folder = "RenzzVexxHub",
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",
    Transparent = true,
    Acrylic = true,
})

-- Global State & Configurations
_G.AutoSteal = false
_G.StealMethod = "Tween Smooth"
_G.GodMode = false
_G.AntiBoss = false
_G.TweenSpeed = 100
_G.SafeOffset = 3

-- Daftar Lengkap Semua Area / Biome (12 Tempat)
local AllBiomes = { 
    "Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", 
    "Abyss Ocean", "Prehistoric", "Cosmic", "Cherry Blossom", "Titan Temple", "Angels & Demons" 
}

_G.SelectedAreas = {}
for _, area in ipairs(AllBiomes) do
    _G.SelectedAreas[area] = false
end

-- Daftar Lengkap Semua Rarity Telur
local AllRarities = { 
    "All Rarity", "Common", "Uncommon", "Rare", "Epic", "Legendary", 
    "Mythic", "Cosmic", "Secret", "Divine", "Luminous", "Eternal" 
}
_G.SelectedRarity = "All Rarity"

_G.AutoTreadmill = false
_G.AutoRebirth = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =========================================================================
--  ENGINE: GODMODE & BYPASS (SAFEGUARDED)
-- =========================================================================
local function applyGodMode(enable)
    pcall(function()
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, not enable)
        humanoid.BreakJointsOnDeath = not enable
    end)
end

local function applyAntiBoss()
    pcall(function()
        local enemyFolder = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Guards") or workspace:FindFirstChild("Bosses")
        if not enemyFolder then return end
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
    end)
end

-- =========================================================================
--  ENGINE: MULTI-METHOD STEAL SYSTEM (ERROR-RESISTANT)
-- =========================================================================
local function executeSteal(targetEgg)
    if not targetEgg or not targetEgg.Parent then return end
    
    pcall(function()
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not rootPart or not humanoid then return end

        local eggCFrame = targetEgg:IsA("Model") and targetEgg.PrimaryPart and targetEgg.PrimaryPart.CFrame or (targetEgg:IsA("BasePart") and targetEgg.CFrame)
        if not eggCFrame then return end

        local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
        local claimRemote = eventsFolder and (eventsFolder:FindFirstChild("ClaimEgg") or eventsFolder:FindFirstChild("StealEgg"))

        -- 1. Metode Tween Smooth
        if _G.StealMethod == "Tween Smooth" then
            local distance = (rootPart.Position - eggCFrame.Position).Magnitude
            local duration = distance / math.clamp(_G.TweenSpeed, 40, 160)
            
            local tween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                CFrame = eggCFrame * CFrame.new(0, _G.SafeOffset, 0)
            })
            tween:Play()
            tween.Completed:Wait()
            task.wait(0.05)

            if claimRemote then claimRemote:FireServer(targetEgg) end
            task.wait(0.08)

            local baseFolder = workspace:FindFirstChild("Bases") or workspace:FindFirstChild("PlayerBases")
            local myBase = baseFolder and (baseFolder:FindFirstChild(LocalPlayer.Name) or baseFolder:FindFirstChild("Base"))
            local baseTarget = myBase and (myBase.PrimaryPart and myBase.PrimaryPart.CFrame or myBase.CFrame) or CFrame.new(0, 10, 0)

            local retDist = (rootPart.Position - baseTarget.Position).Magnitude
            local retTween = TweenService:Create(rootPart, TweenInfo.new(retDist / _G.TweenSpeed, Enum.EasingStyle.Linear), {
                CFrame = baseTarget * CFrame.new(0, 3, 0)
            })
            retTween:Play()
            retTween.Completed:Wait()

        -- 2. Metode Chicken Knockback
        elseif _G.StealMethod == "Chicken Knockback" then
            local enemyFolder = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Guards")
            local nearestGuard, shortest = nil, math.huge
            if enemyFolder then
                for _, guard in pairs(enemyFolder:GetChildren()) do
                    local gRoot = guard:FindFirstChild("HumanoidRootPart") or guard:FindFirstChild("PrimaryPart")
                    if gRoot then
                        local d = (rootPart.Position - gRoot.Position).Magnitude
                        if d < shortest then shortest = d; nearestGuard = gRoot end
                    end
                end
            end

            if nearestGuard and shortest < 35 then
                rootPart.CFrame = nearestGuard.CFrame * CFrame.new(0, 0, 2)
                task.wait(0.1)
            end

            rootPart.AssemblyLinearVelocity = Vector3.new(0, 50, 0)
            rootPart.CFrame = eggCFrame * CFrame.new(0, _G.SafeOffset, 0)
            task.wait(0.05)

            if claimRemote then claimRemote:FireServer(targetEgg) end
            task.wait(0.1)

        -- 3. Metode Direct Remote Only
        elseif _G.StealMethod == "Direct Remote Only" then
            if claimRemote then claimRemote:FireServer(targetEgg) end
            task.wait(0.2)
        end
    end)
end

-- =========================================================================
--  BACKGROUND AUTOMATION LOOPS
-- =========================================================================
task.spawn(function()
    while true do
        task.wait(0.3)
        if _G.AutoSteal then
            pcall(function()
                local mapFolder = workspace:FindFirstChild("Eggs") or workspace:FindFirstChild("Map")
                if mapFolder then
                    for areaName, isEnabled in pairs(_G.SelectedAreas) do
                        if isEnabled and _G.AutoSteal then
                            local targetBiome = mapFolder:FindFirstChild(areaName) or mapFolder
                            for _, egg in pairs(targetBiome:GetDescendants()) do
                                if not _G.AutoSteal then break end
                                if egg and (egg:IsA("BasePart") or egg:IsA("Model")) and egg.Name:lower():find("egg") then
                                    local eggName = egg.Name:lower()
                                    local filter = _G.SelectedRarity:lower()
                                    local isValidRarity = (filter == "all rarity") or eggName:find(filter)
                                    
                                    if isValidRarity then
                                        executeSteal(egg)
                                        task.wait(1.0)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.AntiBoss then pcall(applyAntiBoss) end
        if _G.AutoTreadmill then
            pcall(function()
                local rem = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("TrainTreadmill")
                if rem then rem:FireServer() end
            end)
        end
        if _G.AutoRebirth then
            pcall(function()
                local rem = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Rebirth")
                if rem then rem:FireServer() end
            end)
        end
    end
end)

-- =========================================================================
--  WIND UI TABS & COMPONENTS SETUP
-- =========================================================================

local TabMain = Window:Tab({ Title = "Main Farm", Icon = "home" })
local TabFilter = Window:Tab({ Title = "Multi-Area & Filters", Icon = "filter" })
local TabMisc = Window:Tab({ Title = "Misc & Stats", Icon = "settings" })

-- Main Farm Tab
TabMain:Toggle({
    Title = "Auto Steal Egg",
    Desc = "Aktifkan otomatisasi pencurian telur dari semua area terpilih",
    Value = false,
    Callback = function(state) _G.AutoSteal = state end
})

TabMain:Toggle({
    Title = "God Mode (Anti-Death)",
    Desc = "Mencegah karakter mati saat mengambil telur",
    Value = false,
    Callback = function(state) 
        _G.GodMode = state
        applyGodMode(state)
    end
})

TabMain:Toggle({
    Title = "Anti-Boss / Guard Freeze",
    Desc = "Membekukan pergerakan NPC/Ayam penjaga",
    Value = false,
    Callback = function(state) _G.AntiBoss = state end
})

-- Multi-Area & Filters Tab
TabFilter:Dropdown({
    Title = "Pilih Metode Steal",
    Desc = "Pilih cara kerja pergerakan saat mengambil telur",
    Values = { "Tween Smooth", "Chicken Knockback", "Direct Remote Only" },
    Default = "Tween Smooth",
    Callback = function(selected) _G.StealMethod = selected end
})

TabFilter:Dropdown({
    Title = "Filter Rarity Telur",
    Desc = "Pilih kelangkaan telur yang ingin dicuri",
    Values = AllRarities,
    Default = "All Rarity",
    Callback = function(selected) _G.SelectedRarity = selected end
})

-- Render Toggle Otomatis untuk Seluruh 12 Area / Biome
for _, areaName in ipairs(AllBiomes) do
    TabFilter:Toggle({
        Title = "Farm Area: " .. areaName,
        Desc = "Centang untuk mengaktifkan pencurian di " .. areaName,
        Value = false,
        Callback = function(state)
            _G.SelectedAreas[areaName] = state
        end
    })
end

-- Misc & Stats Tab
TabMisc:Toggle({
    Title = "Auto Treadmill (Train)",
    Value = false,
    Callback = function(state) _G.AutoTreadmill = state end
})

TabMisc:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(state) _G.AutoRebirth = state end
})

Window:SelectTab(1)
