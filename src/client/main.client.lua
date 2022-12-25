local settingObj = script.Parent.Parent.setting.Value
local engine = require(settingObj)

local modules = script.Parent.Parent.modules
local Coefficidents = require(modules.Coefficients)
local BiVector = require(modules.BiVector)

local RUN_SERVICE = game:GetService("RunService")
local FIXED_CORRECTION = 0.1

local drive: VehicleSeat = settingObj.Parent:FindFirstChildWhichIsA("VehicleSeat")
local wings: Folder = settingObj.Parent.wings

local areoSurfaces = {}

local function init()
    for i: number, wing: BasePart in pairs(wings:GetChildren()) do
        if not wing:IsA("BasePart") then return end

        local span = wing:GetAttribute("span")
        local chord = wing:GetAttribute("chord")
        local aspectRatio = wing:GetAttribute("aspectRatio")
        local surfaceType = wing:GetAttribute("surfaceType")
        if chord < 0.001 then chord = 0.001 end
        if engine.autoAspectRatio then aspectRatio = span / chord end

        print(surfaceType)

        local new = Coefficidents.new(wing, span, chord, aspectRatio, surfaceType)
        table.insert(areoSurfaces, new)
    end
end
init()

RUN_SERVICE.RenderStepped:Connect(function(deltaTime)
    --if true then return end
    --print(_G.set.pitch)
    --print(_G.set.roll)
    for i, v in pairs(areoSurfaces) do
        if v.surfaceType == "Elevator" then
            v:setFlapAngle(_G.set.pitch)
        elseif v.surfaceType == "AileronL" then
            v:setFlapAngle(-_G.set.roll)
        elseif v.surfaceType == "AileronR" then
            v:setFlapAngle(_G.set.roll)
        elseif v.surfaceType == "Rudder" then
            v:setFlapAngle(_G.set.yaw)
        elseif v.surfaceType == "Flap" then
            v:setFlapAngle(_G.set.flap)
        end
    end
end)

RUN_SERVICE.Heartbeat:Connect(function(delta)
    local torque = Vector3.zero
    for i: number, aeroSurface in pairs(areoSurfaces) do
        local velocity, angularVelocity = aeroSurface.wing.AssemblyLinearVelocity, aeroSurface.wing.AssemblyAngularVelocity
        
        local forceAndTorque = aeroSurface:CalculateForces(-velocity -angularVelocity)
        
        aeroSurface.wing:ApplyImpulse(((forceAndTorque.force) + (aeroSurface.wing.CFrame.LookVector * engine.thrust)) * delta)
        torque += aeroSurface:forceToTorque(drive.Position, forceAndTorque.force) * delta * FIXED_CORRECTION
    end
    drive:ApplyAngularImpulse(torque)
end)