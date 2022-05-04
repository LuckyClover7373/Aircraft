local engine = require(script.Parent)

local modules = script.Parent.modules
local Coefficidents = require(modules.Coefficients)
local BiVector = require(modules.BiVector)
local Quaternion = require(modules.Quaternion)

local RUN_SERVICE = game:GetService("RunService")

local drive: VehicleSeat = script.Parent.Parent:FindFirstChildWhichIsA("VehicleSeat")
local wings: Folder = script.Parent.Parent.wings

local PREDICTION_TIMESTEP_FRACTION: number = 0.5

local per = 0

local function CalculateAerodynamicForces(velocity: Vector3, angularVelocity: Vector3, centerOfMass: Vector3)
    local forceAndTorque = BiVector.new()
    for i: number, wing: BasePart in pairs(wings:GetChildren()) do
        if not wing:IsA("BasePart") then return end

        local relativePosition: Vector3 = wing.Position - centerOfMass
        forceAndTorque += Coefficidents.CalculateForces(-velocity - angularVelocity:Cross(relativePosition), relativePosition, wing)
    end
    return forceAndTorque
end

local function PredictVelocity(force: Vector3, delta: number)
    return drive.AssemblyLinearVelocity + delta * PREDICTION_TIMESTEP_FRACTION * force / drive.Mass
end

local function PredictAnguVelocity(torque: Vector3, delta: number)
    local inertiaTensorWorldRotation = Quaternion.fromCFrame(drive.CFrame) * drive.AssemblyAngularVelocity
    local torqueInDiagonalSpace: Vector3 = inertiaTensorWorldRotation - torque
	local angularVelocityChangeInDiagonalSpace: Vector3 = Vector3.new(torqueInDiagonalSpace.X / drive.AssemblyLinearVelocity.X, torqueInDiagonalSpace.Y / drive.AssemblyLinearVelocity.Y, torqueInDiagonalSpace.Z / drive.AssemblyLinearVelocity.Z)

    return drive.AssemblyAngularVelocity + delta * PREDICTION_TIMESTEP_FRACTION * (inertiaTensorWorldRotation * angularVelocityChangeInDiagonalSpace)
end

game.ReplicatedStorage.t.OnServerEvent:Connect(function(plr, rper)
	per = rper / 100
end)

local vectorForce: VectorForce
local torqueForce: AngularVelocity

local function init()
    drive:SetNetworkOwner(nil)

    local att = Instance.new("Attachment")
    att.Parent = drive

    vectorForce = Instance.new("VectorForce")
    vectorForce.ApplyAtCenterOfMass = true
    vectorForce.Attachment0 = att
    vectorForce.Parent = drive

    torqueForce = Instance.new("AngularVelocity")
    torqueForce.MaxTorque = 10000
    torqueForce.Attachment0 = att
    torqueForce.Parent = drive
end
init()

while true do
    local delta: number = RUN_SERVICE.Stepped:Wait()

    local forceAndTorqueThisFrame = CalculateAerodynamicForces(drive.AssemblyLinearVelocity, drive.AssemblyAngularVelocity, drive.AssemblyCenterOfMass)

    local velocityPrediction: Vector3 = PredictVelocity(forceAndTorqueThisFrame.force + drive.CFrame.LookVector + Vector3.new(0, -workspace.Gravity / 10, 0) * drive.Mass, delta)
    local angularVelocityPrediction = PredictAnguVelocity(forceAndTorqueThisFrame.torque, delta)

    local forceAndTorquePrediction = CalculateAerodynamicForces(velocityPrediction, angularVelocityPrediction, drive.AssemblyCenterOfMass)

    local currentForceAndTorque = forceAndTorqueThisFrame + forceAndTorquePrediction * 0.5
    
    vectorForce.Force += (currentForceAndTorque.force + drive.CFrame.LookVector * engine.thrust * per).Magnitude > 0 and currentForceAndTorque.force + drive.CFrame.LookVector * engine.thrust * per or Vector3.zero
    torqueForce.AngularVelocity += currentForceAndTorque.torque.Magnitude / drive.AssemblyMass > 0 and currentForceAndTorque.torque / drive.AssemblyMass or Vector3.zero
end