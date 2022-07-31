local PLAYERS = game:GetService("Players")

local drive: VehicleSeat = script.Parent.Parent:FindFirstChildWhichIsA("VehicleSeat")
local client: ScreenGui = script.Parent.Aircraft_Engine_Client

if drive:CanSetNetworkOwnership() then drive:SetNetworkOwner(nil) end
client.setting.Value = script.Parent

local prev = nil
drive:GetPropertyChangedSignal("Occupant"):Connect(function()
    if prev then
        prev:Destroy()
        prev = nil
    end

    local player = drive.Occupant and PLAYERS:GetPlayerFromCharacter(drive.Occupant.Parent)
    if player then
        if drive:CanSetNetworkOwnership() then drive:SetNetworkOwner(player) end

        local newClient = client:Clone()
        newClient.Parent = player.PlayerGui
        prev = newClient
    end
end)