local engine = require(script.Parent)

local modules = script.Parent.modules
local Coefficidents = require(modules.Coefficients)
local BiVector = require(modules.BiVector)

local RUN_SERVICE = game:GetService("RunService")

local drive: VehicleSeat = script.Parent.Parent:FindFirstChildWhichIsA("VehicleSeat")
local wings: Folder = script.Parent.Parent.wings

local areoSurfaces = {}

local PREDICTION_TIMESTEP_FRACTION: number = 0.5
local FIXED_DELTA_TIME: number = 0.02

local function CalculateAerodynamicForces(velocity: Vector3, angularVelocity: Vector3, centerOfMass: Vector3): any
    local forceAndTorque = BiVector.new()
    for i: number, aeroSurface in pairs(areoSurfaces) do
        local relativePosition: Vector3 = aeroSurface.wing.Position - centerOfMass
        forceAndTorque += aeroSurface:CalculateForces(-velocity - angularVelocity:Cross(relativePosition), relativePosition)
    end
    return forceAndTorque
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

local vectorForce: VectorForce
local torque: Torque

local function init()
    if drive:CanSetNetworkOwnership() then drive:SetNetworkOwner(nil) end

    for i: number, wing: BasePart in pairs(wings:GetChildren()) do
        if not wing:IsA("BasePart") then return end

        table.insert(areoSurfaces, Coefficidents.new(wing))
    end

    local att = Instance.new("Attachment")
    att.Parent = drive

    vectorForce = Instance.new("VectorForce")
    vectorForce.Force = Vector3.zero
    vectorForce.ApplyAtCenterOfMass = true
    vectorForce.Attachment0 = att
    vectorForce.Parent = drive

    torque = Instance.new("Torque")
    torque.Torque = Vector3.zero
    torque.Attachment0 = att
    torque.Parent = drive
end
init()

game.ReplicatedStorage.s.OnServerEvent:Connect(function(player, setting)
    for i: number, aeroSurface in pairs(areoSurfaces) do
        if aeroSurface.wing:GetAttribute("SurfaceType") == "Pitch" then
            aeroSurface:setFlapAngle(setting.pitch or 0)
        elseif aeroSurface.wing:GetAttribute("SurfaceType") == "Roll" then
            aeroSurface:setFlapAngle(setting.roll or 0)
        elseif aeroSurface.wing:GetAttribute("SurfaceType") == "Yaw" then
            aeroSurface:setFlapAngle(setting.surface or 0)
        elseif aeroSurface.wing:GetAttribute("SurfaceType") == "Flap" then
            aeroSurface:setFlapAngle(setting.yaw or 0)
        end
    end
end)

task.wait(5)

while true do
    local delta: number = RUN_SERVICE.Stepped:Wait()

    local forceAndTorqueThisFrame: Vector3 = CalculateAerodynamicForces(drive.AssemblyLinearVelocity, drive.AssemblyAngularVelocity, drive.AssemblyCenterOfMass)

    local velocityPrediction: Vector3 = PredictVelocity(forceAndTorqueThisFrame.force + drive.CFrame.LookVector + Vector3.new(0, -workspace.Gravity / 10, 0) * drive.Mass, delta)
    local angularVelocityPrediction: Vector3 = PredictAnguVelocity(forceAndTorqueThisFrame.torque, delta)
    
    --local forceAndTorquePrediction = CalculateAerodynamicForces(velocityPrediction, angularVelocityPrediction, drive.AssemblyCenterOfMass)
    
    local currentForceAndTorque: any = forceAndTorqueThisFrame --+ forceAndTorquePrediction * 0.5
    currentForceAndTorque.force = currentForceAndTorque.force.Magnitude > 0 and currentForceAndTorque.force or Vector3.zero
    currentForceAndTorque.torque = currentForceAndTorque.torque.Magnitude > 0 and currentForceAndTorque.torque or Vector3.zero

    vectorForce.Force = drive.AssemblyLinearVelocity
    torque.Torque = drive.AssemblyAngularVelocity

    vectorForce.Force += (currentForceAndTorque.force)
    torque.Torque += (currentForceAndTorque.torque)

    vectorForce.Force += (drive.CFrame.LookVector * engine.thrust)
end