--// Cache
local pcall, getgenv, next, setmetatable, Vector2new, CFramenew, Color3fromRGB, Drawingnew, TweenInfonew, stringupper, mousemoverel = pcall, getgenv, next, setmetatable, Vector2.new, CFrame.new, Color3.fromRGB, Drawing.new, TweenInfo.new, string.upper, mousemoverel or (Input and Input.MouseMove)

--// Launching checks
if not getgenv().DrkSlk or getgenv().DrkSlk.Aimbot then return end

--// Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Variables
local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}

--// Environment
getgenv().DrkSlk.Aimbot = {
    Settings = {
        Enabled = false,
        TeamCheck = false,
        AliveCheck = true,
        WallCheck = false,
        Sensitivity = 0,
        ThirdPerson = false,
        ThirdPersonSensitivity = 3,
        TriggerKey = "MouseButton2",
        Toggle = false,
        LockPart = "Head"
    },

    FOVSettings = {
        Enabled = true,
        Visible = true,
        Amount = 90,
        Color = Color3fromRGB(255, 255, 255),
        LockedColor = Color3fromRGB(255, 70, 70),
        Transparency = 0.5,
        Sides = 60,
        Thickness = 1,
        Filled = false
    },

    FOVCircle = Drawingnew("Circle")
}

local Environment = getgenv().DrkSlk.Aimbot

--// Core Functions
local function ConvertVector(Vector)
    return Vector2new(Vector.X, Vector.Y)
end

local function CancelLock()
    Environment.Locked = nil
    Environment.FOVCircle.Color = Environment.FOVSettings.Color
    UserInputService.MouseDeltaSensitivity = OriginalSensitivity

    if Animation then
        Animation:Cancel()
    end
end

local function GetClosestPlayer()
    if Environment.Locked then
        local mouseLocation = UserInputService:GetMouseLocation()
        local lockPartPosition = ConvertVector(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position))
        if (mouseLocation - lockPartPosition).Magnitude > RequiredDistance then
            CancelLock()
        end
        return
    end

    RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000

    for _, v in next, Players:GetPlayers() do
        if v == LocalPlayer then continue end

        local character = v.Character
        if not character then continue end

        local lockPart = character:FindFirstChild(Environment.Settings.LockPart)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not lockPart or not humanoid then continue end

        if Environment.Settings.TeamCheck and v.TeamColor == LocalPlayer.TeamColor then continue end
        if Environment.Settings.AliveCheck and humanoid.Health <= 0 then continue end
        if Environment.Settings.WallCheck and #Camera:GetPartsObscuringTarget({lockPart.Position}, character:GetDescendants()) > 0 then continue end

        local Vector, OnScreen = Camera:WorldToViewportPoint(lockPart.Position)
        Vector = ConvertVector(Vector)
        local Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude

        if Distance < RequiredDistance and OnScreen then
            RequiredDistance = Distance
            Environment.Locked = v
        end
    end
end

local function Load()
    OriginalSensitivity = UserInputService.MouseDeltaSensitivity

    ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        local settings = Environment.Settings
        local fovSettings = Environment.FOVSettings

        if fovSettings.Enabled and settings.Enabled then
            local fovCircle = Environment.FOVCircle
            fovCircle.Radius = fovSettings.Amount
            fovCircle.Thickness = fovSettings.Thickness
            fovCircle.Filled = fovSettings.Filled
            fovCircle.NumSides = fovSettings.Sides
            fovCircle.Color = fovSettings.Color
            fovCircle.Transparency = fovSettings.Transparency
            fovCircle.Visible = fovSettings.Visible
            fovCircle.Position = Vector2new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        else
            Environment.FOVCircle.Visible = false
        end

        if Running and settings.Enabled then
            GetClosestPlayer()

            if Environment.Locked then
                local lockPartPosition = Environment.Locked.Character[settings.LockPart].Position
                if settings.ThirdPerson then
                    local Vector = Camera:WorldToViewportPoint(lockPartPosition)
                    mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * settings.ThirdPersonSensitivity, 
                                 (Vector.Y - UserInputService:GetMouseLocation().Y) * settings.ThirdPersonSensitivity)
                else
                    if settings.Sensitivity > 0 then
                        Animation = TweenService:Create(Camera, TweenInfonew(settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), 
                                                        {CFrame = CFramenew(Camera.CFrame.Position, lockPartPosition)})
                        Animation:Play()
                    else
                        Camera.CFrame = CFramenew(Camera.CFrame.Position, lockPartPosition)
                    end
                    UserInputService.MouseDeltaSensitivity = 0
                end

                Environment.FOVCircle.Color = fovSettings.LockedColor
            end
        end
    end)

    ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
        if not Typing then
            pcall(function()
                local triggerKey = Environment.Settings.TriggerKey
                if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[stringupper(triggerKey)] or 
                   Input.UserInputType == Enum.UserInputType[triggerKey] then
                    if Environment.Settings.Toggle then
                        Running = not Running
                        if not Running then
                            CancelLock()
                        end
                    else
                        Running = true
                    end
                end
            end)
        end
    end)

    ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
        if not Typing then
            local triggerKey = Environment.Settings.TriggerKey
            if not Environment.Settings.Toggle and 
               (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[stringupper(triggerKey)] or 
               Input.UserInputType == Enum.UserInputType[triggerKey]) then
                Running = false
                CancelLock()
            end
        end
    end)
end

--// Typing Check
ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

--// Functions
Environment.Functions = {}

function Environment.Functions:Exit()
    for _, v in next, ServiceConnections do
        v:Disconnect()
    end
    Environment.FOVCircle:Remove()
    getgenv().DrkSlk.Aimbot.Functions = nil
    getgenv().DrkSlk.Aimbot = nil
end

function Environment.Functions:Restart()
    for _, v in next, ServiceConnections do
        v:Disconnect()
    end
    Load()
end

function Environment.Functions:ResetSettings()
    Environment.Settings = {
        Enabled = false,
        TeamCheck = false,
        AliveCheck = true,
        WallCheck = false,
        Sensitivity = 0,
        ThirdPerson = false,
        ThirdPersonSensitivity = 3,
        TriggerKey = "MouseButton2",
        Toggle = false,
        LockPart = "Head"
    }

    Environment.FOVSettings = {
        Enabled = true,
        Visible = true,
        Amount = 90,
        Color = Color3fromRGB(255, 255, 255),
        LockedColor = Color3fromRGB(255, 70, 70),
        Transparency = 0.5,
        Sides = 60,
        Thickness = 1,
        Filled = false
    }
end

setmetatable(Environment.Functions, {
    __newindex = warn
})

--// Load
Load()