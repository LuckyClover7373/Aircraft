local engine = require(script.Parent)

local modules = script.Parent.modules
local Coefficidents = require(modules.Coefficients)
local BiVector = require(modules.BiVector)
local Quaternion = require(modules.Quaternion)

local RUN_SERVICE = game:GetService("RunService")

local drive: VehicleSeat = script.Parent.Parent:FindFirstChildWhichIsA("VehicleSeat")
local wings: Folder = script.Parent.Parent.wings

local PREDICTION_TIMESTEP_FRACTION: number = 0.5

drive:SetNetworkOwner(nil)
local per = 0

local function engineFix()
    if engine.flapFraction > 0.4 then engineFix.flapFraction = 0.4 end
    if engine.flapFraction < 0 then engine.flapFraction = 0 end
    if engine.stallAngleHigh < 0 then engine.stallAngleHigh = 0 end
    if engine.stallAngleLow > 0 then engine.stallAngleLow = 0 end
    if engine.chord < 0.001 then engine.chord = 0.001 end
    if engine.autoAspectRatio then engine.aspectRatio = engine.span / engine.chord end
end
engineFix()

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

while true do
    local delta: number = RUN_SERVICE.Heartbeat:Wait()

    local forceAndTorqueThisFrame = CalculateAerodynamicForces(drive.AssemblyLinearVelocity, drive.AssemblyAngularVelocity, drive.AssemblyCenterOfMass)

    local velocityPrediction: Vector3 = PredictVelocity(forceAndTorqueThisFrame.force + drive.CFrame.LookVector + Vector3.new(0, -workspace.Gravity / 10, 0) * drive.Mass, delta)
    local angularVelocityPrediction = PredictAnguVelocity(forceAndTorqueThisFrame.torque, delta)

    local forceAndTorquePrediction = CalculateAerodynamicForces(velocityPrediction, angularVelocityPrediction, drive.AssemblyCenterOfMass)

    local currentForceAndTorque = forceAndTorqueThisFrame + forceAndTorquePrediction * 0.5
	
    drive.AssemblyLinearVelocity = ((currentForceAndTorque.force + drive.CFrame.LookVector * engine.thrust * per) * 60 / delta).Magnitude > 0 and (currentForceAndTorque.force + drive.CFrame.LookVector * engine.thrust * per) * 60 / delta or Vector3.zero
    drive.AssemblyAngularVelocity = (currentForceAndTorque.torque * 60 / delta).Magnitude > 0 and currentForceAndTorque.torque * 60 / delta or Vector3.zero
end