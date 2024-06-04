--[[
    Universal aimbot and ESP made by DrkSlk
]]

--// Check if loaded

if DrkSlk then
    return
end

--// Load Modules

loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/Modules/Aimbot.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/Modules/Wall%20Hack.lua"))()

--// Environment

getgenv().DrkSlk = {}

--// Services

local Players = game:GetService("Players")

--// Variables

local LocalPlayer = Players.LocalPlayer

--// Library

local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Window = Library:CreateWindow({
    Name = "u/"..LocalPlayer.Name,
    Themeable = {
        Image = "7059346386",
        Info = "Made by DrkSlk",
        Credit = false
    },
    Background = "",
    Theme = [[{"__Designer.Colors.topGradient":"3F0C64","__Designer.Colors.section":"C259FB","__Designer.Colors.hoveredOptionBottom":"4819B4","__Designer.Background.ImageAssetID":"rbxassetid://4427304036","__Designer.Colors.selectedOption":"4E149C","__Designer.Colors.unselectedOption":"482271","__Designer.Files.WorkspaceFile":"AirHub","__Designer.Colors.unhoveredOptionTop":"310269","__Designer.Colors.outerBorder":"391D57","__Designer.Background.ImageColor":"69009C","__Designer.Colors.tabText":"B9B9B9","__Designer.Colors.elementBorder":"160B24","__Designer.Background.ImageTransparency":100,"__Designer.Colors.background":"1E1237","__Designer.Colors.innerBorder":"531E79","__Designer.Colors.bottomGradient":"361A60","__Designer.Colors.sectionBackground":"21002C","__Designer.Colors.hoveredOptionTop":"6B10F9","__Designer.Colors.otherElementText":"7B44A8","__Designer.Colors.main":"AB26FF","__Designer.Colors.elementText":"9F7DB5","__Designer.Colors.unhoveredOptionBottom":"3E0088","__Designer.Background.UseBackgroundImage":false}]]
})

--// Tabs

local AimbotTab = Window:CreateTab({Name = "Aimbot"})
local VisualTab = Window:CreateTab({Name = "Aimbot"})
local CrosshairTab = Window:CreateTab({Name = "Aimbot"})

--// Aimbot sections
local Values = AimbotTab:CreateSection({Name = "Values"})
local Checks = AimbotTab:CreateSection({Name = "Checks"})
local ThirdPerson = AimbotTab:CreateSection({Name = "Third Person"})
local FOV = AimbotTab:CreateSection({Name = "Field Of View", Side = "Right"})
local Appearance = AimbotTab:CreateSection({Name = "FOV Appearance", Side = "Right"})

--// Aimbot values
Values:AddSection({
    Name = "Enabled",
    Value = Aim
})