local settingObj = script.Parent.Parent.setting.Value
local engine = require(settingObj)

local modules = script.Parent.Parent.modules
local Coefficidents = require(modules.Coefficients)
local BiVector = require(modules.BiVector)

local RUN_SERVICE = game:GetService("RunService")

local drive: VehicleSeat = settingObj.Parent:FindFirstChildWhichIsA("VehicleSeat")
local wings: Folder = settingObj.Parent.wings

local areoSurfaces = {}

local function init()
    for i: number, wing: BasePart in pairs(wings:GetChildren()) do
        if not wing:IsA("BasePart") then return end

        local span = wing:GetAttribute("span")
        local chord = wing:GetAttribute("chord")
        local aspectRatio = wing:GetAttribute("aspectRatio")
        if chord < 0.001 then chord = 0.001 end
        if engine.autoAspectRatio then aspectRatio = span / chord end

        local new = Coefficidents.new(wing, span, chord, aspectRatio)
        table.insert(areoSurfaces, new)
    end
end
init()

RUN_SERVICE.RenderStepped:Connect(function(deltaTime)
    if true then return end
    for i, v in pairs(areoSurfaces) do
        local alt = v.wing:GetAttribute("SurfaceType")
        if alt == "Pitch" then
            v:setFlapAngle(_G.set.pitch)
        elseif alt == "Roll" then
            v:setFlapAngle(_G.set.roll)
        elseif alt == "Yaw" then
            v:setFlapAngle(_G.set.yaw)
        elseif alt == "Flap" then
            v:setFlapAngle(_G.set.flap)
        end
    end
end)

RUN_SERVICE.Heartbeat:Connect(function(delta)
    for i: number, aeroSurface in pairs(areoSurfaces) do
        local velocity, angularVelocity, centerOfMass = drive.AssemblyLinearVelocity, drive.AssemblyAngularVelocity, drive.AssemblyCenterOfMass
        
        local relativePosition: Vector3 = aeroSurface.wing.Position - centerOfMass
        local forceAndTorque = aeroSurface:CalculateForces(-velocity - angularVelocity:Cross(relativePosition), relativePosition)

        aeroSurface.wing:ApplyImpulse(((forceAndTorque.force) + (drive.CFrame.LookVector * engine.thrust)) * delta)
        aeroSurface.wing:ApplyAngularImpulse((forceAndTorque.torque) * delta)
    end
end)