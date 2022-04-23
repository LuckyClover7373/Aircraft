--!strict

local engine = require(script.Parent)

local modules = script.Parent.modules
local Coefficidents = require(modules.Coefficients)

local RUN_SERVICE = game:GetService("RunService")

local drive: VehicleSeat = script.Parent.Parent.drive
local wings: Folder = script.Parent.Parent.wings

drive:SetNetworkOwner(nil)

while true do
    local delta: number = RUN_SERVICE.Stepped:Wait()

    for i: number, wing: BasePart in pairs(wings:GetChildren()) do
        if not wing:IsA("BasePart") then return end
        local worldFlowVelocity: Vector3 = -wing.AssemblyLinearVelocity
        - workspace.Plane.wings.wing1.AssemblyAngularVelocity

        local localFlowVelocity: Vector3 = wing.CenterOfMass + worldFlowVelocity
        localFlowVelocity = Vector3.new(localFlowVelocity.X, localFlowVelocity.Y)

        local dynamicPressure: number = 0.5 * engine.airDensity * math.sqrt(localFlowVelocity.Magnitude)
        local angleOfAttack: number = math.atan2(localFlowVelocity.Y, -localFlowVelocity.X)

        local aerodynamicCoefficidents: Vector3 = Coefficidents.CalculateCoefficidents

        local dragDirection: Vector3 = wing.CenterOfMass + localFlowVelocity.Unit
        local liftDirection = dragDirection:Cross(wing.CFrame.LookVector)
    end
end