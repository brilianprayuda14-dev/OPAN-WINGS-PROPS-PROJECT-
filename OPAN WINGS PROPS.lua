local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "OPAN WINGS PROPS",
    LoadingTitle = "Loading OPAN Script...",
    LoadingSubtitle = "by OPAN",
    ConfigurationSaving = {
        Enabled = false, -- Dimatikan agar tidak menyimpan konfigurasi
        FolderName = "OpanWings",
        FileName = "Config"
    },
    KeySystem = true,
    KeySettings = {
        Title = "Key System",
        Subtitle = "Masukkan Key Untuk Masuk",
        Note = "Key adalah: YUDAPPK",
        FileName = "OpanKey",
        SaveKey = false, -- Diubah ke false agar key selalu mereset setiap execute
        GrabKeyFromSite = false,
        Key = {"YUDAPPK"}
    }
})

-- Services
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")

-- Variables
local wingRemoteCache = {}
local currentCFrames = {}
local activeMode = 1
local wingSize = 1
local isEnabled = false
local rainbowEnabled = true

-- Rainbow
local function getRainbowColor()
    return Color3.fromHSV(tick() % 5 / 5, 1, 1)
end

-- Get Props
local function getProps()
    local p = workspace:WaitForChild("WorkspaceCom"):WaitForChild("001_TrafficCones")
    wingRemoteCache = {}
    
    for _, v in ipairs(p:GetChildren()) do  
        if v.Name:find("Prop" .. LP.Name) then  
            table.insert(wingRemoteCache, v)  
        end  
    end
end

-- Move Prop
local function moveProp(index, targetCF, color)
    local prop = wingRemoteCache[index]
    if not prop or not prop.Parent then return end
    
    currentCFrames[index] = (currentCFrames[index] or targetCF):Lerp(targetCF, 0.3)  
    
    task.spawn(function()  
        local cfR = prop:FindFirstChild("SetCurrentCFrame")  
        if cfR then cfR:InvokeServer(currentCFrames[index]) end  

        local cr = prop:FindFirstChild("ChangePropColor")  
        if cr then cr:InvokeServer(color or getRainbowColor()) end  
    end)
end

-- MODES
local function getModePosition(index, total, rootCF)
    local t = tick()
    
    -- MODE 1: ORBIT  
    if activeMode == 1 then  
        local angle = (index / total) * math.pi * 2 + t  
        local offset = Vector3.new(math.cos(angle) * 6, math.sin(t * 2) * 0.5, math.sin(angle) * 6)  
        return rootCF * CFrame.new(offset) * CFrame.Angles(0, -angle, 0)  

    -- MODE 2: HALO  
    elseif activeMode == 2 then  
        local angle = (index / total) * math.pi * 2 + (t * 3)  
        local offset = Vector3.new(math.cos(angle) * 3, 4 + math.sin(t * 4) * 0.2, math.sin(angle) * 3)  
        return rootCF * CFrame.new(offset) * CFrame.Angles(math.pi/2, 0, 0)  

    -- 🔥 MODE 3: BAT WINGS PRO (Buka Tutup + Naik Turun)  
    elseif activeMode == 3 then  
        local side = (index > total/2) and 1 or -1  
        local posIndex = (index > total/2) and (index - total/2) or index  

        -- buka tutup  
        local openClose = math.sin(t * 2) * 2.5  

        -- naik turun ±5 stud  
        local upDown = math.sin(t * 2) * 5  

        local x = (3 + posIndex * 1.2 + openClose) * side  
        local y = (posIndex * 0.8) + upDown  
        local z = 3 + (posIndex * 0.5)  

        return rootCF * CFrame.new(x, y, z)  
            * CFrame.Angles(0, math.rad(25 * side), math.rad(20 * side))  

    -- MODE 4: SIMPLE FLOAT  
    elseif activeMode == 4 then  
        local side = (index > total/2) and 1 or -1  
        local x = math.sin(t * 2) * 5 * side  
        local y = 5 + math.cos(t * 2)  
        return rootCF * CFrame.new(x, y, 1)  

    -- MODE 5: SPIN  
    elseif activeMode == 5 then  
        return rootCF * CFrame.Angles(0, t * 5, 0)  
    end
end

-- UI
local MainTab = Window:CreateTab("Main Wings", 4483362458)
local ConfigTab = Window:CreateTab("Settings", 4483362458)
local CreditsTab = Window:CreateTab("Credits", 4483362458)

MainTab:CreateToggle({
    Name = "Enable Wings",
    CurrentValue = false,
    Callback = function(Value)
        isEnabled = Value
        if Value then getProps() end
    end,
})

MainTab:CreateDropdown({
    Name = "Select Wing Mode",
    Options = {
        "Mode 1: Orbit",
        "Mode 2: Halo",
        "Mode 3: Bat Wings PRO",
        "Mode 4: Float",
        "Mode 5: Spin"
    },
    CurrentOption = {"Mode 1: Orbit"},
    MultipleOptions = false,
    Callback = function(Option)
        local opt = Option[1]
        if opt:find("1") then activeMode = 1
        elseif opt:find("2") then activeMode = 2
        elseif opt:find("3") then activeMode = 3
        elseif opt:find("4") then activeMode = 4
        elseif opt:find("5") then activeMode = 5
        end
    end,
})

MainTab:CreateSlider({
    Name = "Wings Size",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 1,
    Callback = function(Value)
        wingSize = Value
    end,
})

ConfigTab:CreateToggle({
    Name = "RGB Rainbow Effect",
    CurrentValue = true,
    Callback = function(Value)
        rainbowEnabled = Value
    end,
})

ConfigTab:CreateButton({
    Name = "Refresh Props",
    Callback = function()
        getProps()
    end,
})

-- Bagian Credits
CreditsTab:CreateSection("OWNER INFO")
CreditsTab:CreateLabel("OWNER BY YUDA")
CreditsTab:CreateLabel("USN ROBLOX: Blackholerwarr")
CreditsTab:CreateLabel("YANAHOLIC")

-- LOOP
RS.Heartbeat:Connect(function()
    if not isEnabled or #wingRemoteCache == 0 then return end
    
    local char = LP.Character  
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end  
    
    local rootCF = char.HumanoidRootPart.CFrame  
    
    for i, _ in ipairs(wingRemoteCache) do  
        local targetPos = getModePosition(i, #wingRemoteCache, rootCF)  

        local color  
        if activeMode == 3 then  
            color = Color3.fromRGB(255, 0, 0)  
        elseif rainbowEnabled then  
            color = getRainbowColor()  
        else  
            color = Color3.fromRGB(255, 255, 255)  
        end  

        moveProp(i, targetPos, color)  
    end
end)

Rayfield:Notify({
    Title = "OPAN WINGS PROPS Loaded!",
    Content = "Key: YUDAPPK",
    Duration = 5,
    Image = 4483362458,
})
