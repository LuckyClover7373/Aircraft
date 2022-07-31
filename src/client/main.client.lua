local settingObj = script.Parent.Parent.setting.Value
local engine = require(settingObj)

local modules = script.Parent.Parent.modules
local Coefficidents = require(modules.Coefficients)
local BiVector = require(modules.BiVector)

local RUN_SERVICE = game:GetService("RunService")

local drive: VehicleSeat = settingObj.Parent:FindFirstChildWhichIsA("VehicleSeat")
local wings: Folder = settingObj.Parent.wings

local areoSurfaces = {}

local PREDICTION_TIMESTEP_FRACTION: number = 0.5
local FIXED_DELTA_TIME: number = 0.02

local function CalculateAerodynamicForces(velocity: Vector3, angularVelocity: Vector3, centerOfMass: Vector3): any
    for i: number, aeroSurface in pairs(areoSurfaces) do
        local relativePosition: Vector3 = aeroSurface.wing.Position - centerOfMass
        local forceAndTorque = aeroSurface:CalculateForces(-velocity - angularVelocity:Cross(relativePosition), relativePosition)

        aeroSurface.wing:ApplyImpulse(((forceAndTorque.force) + (drive.CFrame.LookVector * engine.thrust)) * FIXED_DELTA_TIME)
        aeroSurface.wing:ApplyAngularImpulse((forceAndTorque.torque) * FIXED_DELTA_TIME)
    end
    --return forceAndTorque
end

local function PredictVelocity(force: Vector3, delta: number): Vector3
    return drive.AssemblyLinearVelocity + delta * PREDICTION_TIMESTEP_FRACTION * force / drive.Mass
end

local function PredictAnguVelocity(torque: Vector3, delta: number) : Vector3
    local inertiaTensorWorldRotation = drive.CFrame * drive.AssemblyAngularVelocity
    local torqueInDiagonalSpace: Vector3 = inertiaTensorWorldRotation - torque
	local angularVelocityChangeInDiagonalSpace: Vector3 = Vector3.new(torqueInDiagonalSpace.X / drive.AssemblyLinearVelocity.X, torqueInDiagonalSpace.Y / drive.AssemblyLinearVelocity.Y, torqueInDiagonalSpace.Z / drive.AssemblyLinearVelocity.Z)

    return drive.AssemblyAngularVelocity + delta * PREDICTION_TIMESTEP_FRACTION * (inertiaTensorWorldRotation * angularVelocityChangeInDiagonalSpace)
end

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

RUN_SERVICE.Stepped:Connect(function(delta)
    --if true then return end
	local forceAndTorqueThisFrame: Vector3 = CalculateAerodynamicForces(drive.AssemblyLinearVelocity, drive.AssemblyAngularVelocity, drive.AssemblyCenterOfMass)

	--local velocityPrediction: Vector3 = PredictVelocity(forceAndTorqueThisFrame.force + drive.CFrame.LookVector + Vector3.new(0, -workspace.Gravity / 10, 0) * drive.Mass, delta)
	--local angularVelocityPrediction: Vector3 = PredictAnguVelocity(forceAndTorqueThisFrame.torque, delta)

	--local forceAndTorquePrediction = CalculateAerodynamicForces(velocityPrediction, angularVelocityPrediction, drive.AssemblyCenterOfMass)

	--local currentForceAndTorque: any = forceAndTorqueThisFrame --+ forceAndTorquePrediction * 0.5
	--currentForceAndTorque.force = currentForceAndTorque.force.Magnitude > 0 and currentForceAndTorque.force or Vector3.zero
	--currentForceAndTorque.torque = currentForceAndTorque.torque.Magnitude > 0 and currentForceAndTorque.torque or Vector3.zero

    --drive:ApplyImpulse(((currentForceAndTorque.force) + (drive.CFrame.LookVector * engine.thrust)) * FIXED_DELTA_TIME)
    --drive:ApplyAngularImpulse((currentForceAndTorque.torque) * FIXED_DELTA_TIME)
end)