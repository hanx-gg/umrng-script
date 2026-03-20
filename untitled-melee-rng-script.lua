if game.PlaceId ~= 99248392277037 then
    return
end
queue_on_teleport("loadstring(game:HttpGet(\"https://raw.githubusercontent.com/lolwtfpro/booyah/refs/heads/main/untitledmelee.lua\", true))()")

local windUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local cloneref = (cloneref or clonereference or function(instance) return instance end)


local runService = cloneref(game:GetService("RunService"))
local httpService = cloneref(game:GetService("HttpService"))
-- placeid 99248392277037

local window = windUI:CreateWindow({
    Title = "Untitled Melee RNG Script",
    Icon = "circle-off",
    Author = "by voidexhub",
    Folder = "voidexhub",
    
    Size = UDim2.fromOffset(580, 360),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    
    KeySystem = { 
        Key = { "voidexhub" },
        Note = "Join the discord for the key and more scripts!",
        URL = "https://discord.gg/auAjb9UEWa",
        SaveKey = true
    },
})



window:EditOpenButton({
    Title = "Open UI",
    Icon = "send-to-back",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = Color3.fromHex("#8a4cec"),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
    Position = UDim2.new(0.1, 0, 0.6, 0)
})

window:Tag({
    Title = "v0.1.2",
    Color = Color3.fromHex("#8a4cec"),
    Radius = 13
})

local settings = {
    rarities = {},
    autoSacrifice = false,
    autoSacrificeWhitelist = true,
    autoAscend = false,
    unload = false,
    killDelay = 0.1
}

local data = {
    weapons = {},
    oddsList = {}
}

local utils = {
    ["updateWeapons"] = function()
        data.oddsList = {}
        for i, v in pairs(game:GetService("ReplicatedStorage").Assets.Weapons:GetChildren()) do
    	    data.weapons[v.Name] = v:GetAttributes()
        end

        local rarities = require(game:GetService("ReplicatedStorage").SharedConstants.Rarities)
        local weaponOdds = {}
        for i, v in pairs(rarities.Rarities) do
        	data.oddsList[#data.oddsList + 1] = {v["OneInMax"], i}
        end
        table.sort(data.oddsList, function(a, b) return a[1] > b[1] end)
        for i, v in ipairs(data.oddsList) do
        	for a, b in pairs(data.weapons) do
        		if b["OneIn"] <= v[1] then
        			b["Rarity"] = v[2]
        		end
        	end
        end
    end,
    ["fixConfigs"] = function(configManager)
        local files = configManager:AllConfigs()
        local configs = {}
        for _, f in next, files do
            local file = configManager.Path .. f .. ".json"
            if isfile and readfile and isfile(file) then
                configManager.Configs[f] = configManager:CreateConfig(f, false)
            end
        end
    end,
    ["configSetAutoload"] = function(config, autoload)
            if config then
                if isfile and not isfile(config.Path) then 
                    return
                end

                local success, loadData = pcall(function()
                    local readfile = readfile or function() 
                        return nil 
                    end
                    return httpService:JSONDecode(readfile(config.Path))
                end)
                if not success then
                    return
                end

                loadData.__autoload = autoload
                local jsonData = httpService:JSONEncode(loadData)
                if writefile then 
                    writefile(config.Path, jsonData)
                end
            end
    end
}
utils.updateWeapons()

local cheat = {
    ["autoKill"] = function(state) end,
    ["autoSacrifice"] = function(state) end,
    ["autoAscend"] = function(state) end,
    ["enableTeleporter"] = function() end,
    ["spoofKills"] = function(state) end,
    ["enableAutoRaid"] = function() end,
    ["enableAutoRoll"] = function() end
}

window:OnDestroy(function() settings.unload = true end)

local mainTab = window:Tab({
    Title = "main",
    Icon = "lucide:cpu"
})

local miscTab = window:Tab({
    Title = "misc",
    Icon = "lucide:rows-3"
})

local configTab = window:Tab({
    Title = "config",
    Icon = "lucide:braces"
})

local mainSection = mainTab:Section({
    Title = "Main - auto kill",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
    Opened = true
})

local sacrificeSection = mainTab:Section({
    Title = "Sacrifice - auto sacrifice",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
    Opened = true
})

local ascendSection = mainTab:Section({
    Title = "Ascend",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
    Opened = true
})

local gamepassSection = miscTab:Section({ 
    Title = "Unlock Gamepasses",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
    Opened = true
})

local spoofSection = miscTab:Section({
    Title = "Spoof [Client-side]",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
    Opened = true
})

local configSection = configTab:Section({
    Title = "Config",
    Box = true,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
    Opened = true
})

local autoKillToggle = mainSection:Toggle({
    Title = "Auto Kill",
    Desc = "Hits every mob on a period of 0.1 seconds",
    Flag = "autoKillToggleElement",
    Type = "Checkbox",
    Callback = function(state) cheat["autoKill"](state) end
})

local killDelaySlider = mainSection:Slider({
    Title = "Kill Delay",
    Desc = "Delay between kill attempts (seconds)",
    Flag = "killDelaySliderElement",
    Step = 0.01,
    Value = {
        Min = 0.01,
        Default = 0.1,
        Max = 1
    },
    Callback = function(value)
        settings.killDelay = value
    end
})

local autoSacrificeToggle = sacrificeSection:Toggle({
    Title = "Auto Sacrifice",
    Desc = "Automatically sacrifice weapons (highest available rarity)",
    Flag = "autoSacrificeToggleElement",
    Type = "Checkbox",
    Callback = function(state) cheat["autoSacrifice"](state) end
})

local autoSacrificeWhitelistToggle = sacrificeSection:Toggle({
    Title = "Whitelist rarities",
    Desc = "sacrifice only selected, otherwise blacklist selected",
    Flag = "autoSacrificeWhitelistToggleElement",
    Type = "Checkbox",
    Value = settings.autoSacrificeWhitelist,
    Callback = function(state) settings.autoSacrificeWhitelist = state end
})

local rarityDropdown = sacrificeSection:Dropdown({
    Title = "Rarities",
    Desc = "rarities to (not) sacrifice",
    Flag = "autoSacrificeRarityDropdownElement",
    Values = (function() local values = {} for i, v in ipairs(data.oddsList) do values[#values + 1] = v[2] end return values end)(),
    Value = settings.rarities,
    Multi = true,
    AllowNone = true,
    Callback = function(options) settings.rarities = options end
})

local autoAscendToggle = ascendSection:Toggle({
    Title = "Auto ascension",
    Desc = "automatically ascend",
    Flag = "autoAscendToggleElement",
    Type = "Checkbox",
    Value = settings.autoAscend,
    Callback = function(state) cheat["autoAscend"](state) end
})

local spoofKillCount = 676767
local gamepassSpoofKillCountInput = spoofSection:Input({
    Title = "Kills",
    Desc = "kill count to spoof to",
    Flag = "spoofKillCountInputElement",
    Value = "676767",
    Callback = function(input) spoofKillCount = tonumber(input) end
})

local spoofAscendCount = 676767
local gamepassSpoofAscendCountInput = spoofSection:Input({
    Title = "ascensions",
    Desc = "ascend count to spoof to",
    Flag = "spoofAscendCountInputElement",
    Value = "676767",
    Callback = function(input) spoofAscendCount = tonumber(input) end
})

local gamepassSpoofKillsToggle = spoofSection:Toggle({
    Title = "Spoof stats for teleport",
    Desc = "spoof to unlock all regions",
    Flag = "gamepassSpoofKillsToggleElement",
    Type = "Checkbox",
    Callback = function(state) cheat["spoofKills"](state) end
})

local gamepassTeleporterButton = gamepassSection:Button({
    Title = "Unlock teleporter",
    Desc = "Unlocks the teleporter gamepass",
    Callback = function() cheat["enableTeleporter"]() end
})

local gamepassTeleporterButton = gamepassSection:Button({
    Title = "Unlock auto raid",
    Desc = "Unlocks the auto raid gamepass",
    Callback = function() cheat["enableAutoRaid"]() end
})

local gamepassTeleporterButton = gamepassSection:Button({
    Title = "Unlock auto roll",
    Desc = "Unlocks the auto roll gamepass",
    Callback = function() cheat["enableAutoRoll"]() end
})

local configManager = window.ConfigManager

local configNameInputValue = ""
local configNameInput = configSection:Input({
    Title = "Config name",
    Callback = function(input) configNameInputValue = input end
})

local configCreateButton = configSection:Button({
    Title = "Create and save config",
    Callback = function() if configNameInputValue ~= "" and configNameInputValue ~= " " then local config = configManager:CreateConfig(configNameInputValue) if config then config:Save() end end end
})

local configDropdownSelection = ""
local configList = {}
local configDropdown = configSection:Dropdown({
    Title = "Configs",
    Desc = "Selected config",
    Values = configList,
    Value = "",
    AllowNone = true,
    Callback = function(options) configDropdownSelection = options end
})

task.spawn(function() while not settings.unload do configList = configManager:AllConfigs() configDropdown:Refresh(configList) if not table.find(configList, configDropdownSelection) then configDropdown:Select("") end wait(5) end end)

local configLoadButton = configSection:Button({
    Title = "Load config",
    Callback = function() if configDropdownSelection ~= "" and configDropdownSelection ~= " " then local config = configManager:GetConfig(configDropdownSelection)  if config then config:Load() end end end
})

local configSaveButton = configSection:Button({
    Title = "Save config",
    Callback = function() if configDropdownSelection ~= "" and configDropdownSelection ~= " " then local config = configManager:GetConfig(configDropdownSelection)  if config then config:Save() end end end
})

local configDeleteButton = configSection:Button({
    Title = "Delete config",
    Callback = function() if configDropdownSelection ~= "" and configDropdownSelection ~= " " then local config = configManager:GetConfig(configDropdownSelection) if config then config:Delete() end end end
})

local configSetAutoLoadButton = configSection:Button({
    Title = "Set the config to autoload",
    Callback = function()
        if configDropdownSelection ~= "" and configDropdownSelection ~= " " then
            local config = configManager:GetConfig(configDropdownSelection)
            utils["configSetAutoload"](config, true)
        end
    end
})

local configStopAutoLoadButton = configSection:Button({
    Title = "Stop all autoloads",
    Callback = function() for i, v in pairs(configManager:GetAutoLoadConfigs()) do utils["configSetAutoload"](configManager:GetConfig(v), false) end end
})

utils["fixConfigs"](configManager)

for i, v in pairs(configManager:GetAutoLoadConfigs()) do
    local config = configManager:GetConfig(v)
    if config then
        config:Load()
    end
end

mainTab:Select()

local autoKillToggleState = false
function autoKillFunc()
    local weapon = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Weapons"):WaitForChild("Hellscape Greatsword")
    local dmgMult = 1 + game:GetService("ReplicatedStorage").Remotes.GetUpgradeValue:InvokeServer("Damage Multiplier") / 100
    print(dmgMult, weapon:GetAttribute("Damage"), dmgMult * weapon:GetAttribute("Damage") * 4)

    task.spawn(function()
        while not autoKillToggleState do
            for i, v in pairs(game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetEquippedWeapons"):InvokeServer(game:GetService("Players").LocalPlayer)) do
    	        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UnequipOneWeapon"):InvokeServer(v)
            end
            wait(5)
        end
    end)

    local args = {}
    local mobsLocation = nil
    local enemyTable = {}
    local currEnemies = {}

    local spawnMobConnection
    spawnMobConnection = game:GetService("ReplicatedStorage").Remotes.SpawnMob.OnClientEvent:Connect(function(mob)
        enemyTable[mob.ID] = mob.Health
        currEnemies[mob.ID] = true
    end)

    wait(2)

    while not autoKillToggleState do
        if game.workspace:FindFirstChild("Mobs") then
            mobsLocation = game.Workspace.Mobs
        elseif game:GetService("ReplicatedStorage"):FindFirstChild("Mobs") then
            mobsLocation = game:GetService("ReplicatedStorage").Mobs
        else
            print("No mobs found in workspace or ReplicatedStorage.")
            wait(0.1)
            continue
        end
        local damage = dmgMult * weapon:GetAttribute("Damage") * 4
        for i, v in pairs(mobsLocation:GetChildren()) do
            if v then
                if v.ClassName == "Model" and v:FindFirstChild("HumanoidRootPart") then
                    local mobID = v:GetAttribute("ID")
                    table.insert(args, { mobID, damage, weapon})
                    currEnemies[mobID] = true
                    local enemy = enemyTable[mobID]
                    if enemy then
                        enemyTable[mobID] = enemy - damage
                    else
                        enemyTable[mobID] = 10000000 - damage
                    end
                    if enemy and enemy <= 0 then
                        --print("Mob with ID " .. mobID .. " has been killed.")
                        v:Destroy()
                        enemyTable[mobID] = nil
                    end
                end
            end
        end
    
        for i, v in pairs(enemyTable) do
            if not currEnemies[i] then
                --print("Mob with ID " .. i .. " is no longer in the mob list, removing from enemyTable.")
                enemyTable[i] = nil
            end
        end
        --print("running")
        currEnemies = {}
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("HitMob"):FireServer(args)
        args = {}
        wait(settings.killDelay)
        if settings.unload then
            autoKillToggleState = true
        end
    end
    spawnMobConnection:Disconnect()
end
local autoKillThread = nil
cheat["autoKill"] = function(state)
    if autoKillThread == nil and state then
        autoKillThread = task.spawn(autoKillFunc)
    elseif autoKillThread and state then
        if coroutine.status(autoKillThread) == "dead" then
            autoKillThread = task.spawn(autoKillFunc)
        end
    end
    autoKillToggleState = not state
end

local autoSacrificeThread = task.spawn(function()
    local lastSacrificeTime = -900
    wait(20)
    while not settings.unload do
        --print(autoSacrificeToggleState, (#settings.rarities == 0 and settings.autoSacrificeWhitelist), time() - lastSacrificeTime <= 900)
        if not settings.autoSacrifice or (#settings.rarities == 0 and settings.autoSacrificeWhitelist) or time() - lastSacrificeTime <= 900 then
            wait(5)
            continue
        end

        local weapons = game.ReplicatedStorage.Remotes.GetWeaponsInv:InvokeServer()
        table.sort(weapons, function(a, b) 
            local rarityA = 0
            local rarityB = 0
            for i, v in ipairs(data.oddsList) do
                if data.weapons[a.Name] then
                    if data.weapons[a.Name].Rarity == v[2] then
                        rarityA = v[1]
                    end
                end

                if data.weapons[b.Name] then
                    if data.weapons[b.Name].Rarity == v[2] then
                        rarityB = v[1]
                    end
                end
            end
            return rarityA > rarityB
        end)
        local sacrificesLeft = 25
        if settings.autoSacrificeWhitelist then
            for i, v in pairs(weapons) do
                if table.find(settings.rarities, data.weapons[v.Name].Rarity) then
                    for a = 1, v.Qty do
                        if sacrificesLeft <= 0 then
                            lastSacrificeTime = time()
                            break
                        end
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TotemConfirm"):InvokeServer(v.Name)
                        sacrificesLeft = sacrificesLeft - 1
                        wait(0.1)
                    end
                end
            end
        else
            for i, v in pairs(weapons) do
                if not table.find(settings.rarities, data.weapons[v.Name].Rarity) then
                    for a = 1, v.Qty do
                        if sacrificesLeft <= 0 then
                            lastSacrificeTime = time()
                            break
                        end
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TotemConfirm"):InvokeServer(v.Name)
                        print("sacrificed", v.Name)
                        sacrificesLeft = sacrificesLeft - 1
                        wait(0.1)
                    end
                end
            end
        end

        wait(5)
    end
end)
cheat["autoSacrifice"] = function(state)
    settings.autoSacrifice = state
end

local autoAscendThread = task.spawn(function()
    while not settings.unload do
        if settings.autoAscend then
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ConfirmAscend"):InvokeServer()
        end
        wait(5)
    end
end)

cheat["autoAscend"] = function(state)
    settings.autoAscend = state
end

local origKills = 0
local origAscends = 0
local killsConn, ascendConn
cheat["spoofKills"] = function(state)
    local leaderstats = game.Players.LocalPlayer:WaitForChild("leaderstats")
    local kills = leaderstats:WaitForChild("\240\159\142\175 Kills")
    local ascensions = leaderstats:WaitForChild("\240\159\140\159 Ascends")
    if state then
        origKills = kills.Value
        origAscends = ascensions.Value
        kills.Value = spoofKillCount
        ascensions.Value = spoofAscendCount
        killsConn = kills.Changed:Connect(function(newVal)
            if newVal ~= spoofKillCount then
                origKills = newVal
                kills.Value = spoofKillCount
            end
        end)
        ascendConn = ascensions.Changed:Connect(function(newVal)
            if newVal ~= spoofAscendCount then
                origAscends = newVal
                ascensions.Value = spoofAscendCount
            end
        end)
    else
        kills.Value = origKills
        ascensions.Value = origAscends
        killsConn:Disconnect()
        ascendConn:Disconnect()
    end
end

cheat["enableTeleporter"] = function()
    for i, v in pairs(getconnections(game.ReplicatedStorage.Remotes:WaitForChild("UnlockTeleporter").OnClientEvent)) do
        v.Function()
    end
end

cheat["enableAutoRaid"] = function()
    for i, v in pairs(getconnections(game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EnableAutoRaid").OnClientEvent)) do
        v.Function()
    end
end

local hook
cheat["enableAutoRoll"] = function()
    hook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if self.Name == "AutoRollUnlocked" and method == "InvokeServer" then
            --print("AutoRollUnlocked called via __namecall")
            return true
        end
        return hook(self, ...)
    end))
end
