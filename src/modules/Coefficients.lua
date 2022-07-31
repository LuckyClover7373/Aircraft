local Coefficidents = {}
Coefficidents.__index = Coefficidents

local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local RUN_SERVICE = game:GetService("RunService")

local engine = require(script.Parent.Parent.setting.Value)
local gizmo = require(script.Parent.gizmo)
local BiVector = require(script.Parent.BiVector)

local function lerp(a: number, b: number, t: number): number
    return a + (b - a) * t
end

local function TorqCoefficientProportion(effectiveAngle: number): number
    return 0.25 - 0.175 * (1 - 2 * math.abs(effectiveAngle) / math.pi)
end

local function FrictionAt90Degrees(flapAngle: number): number
    return 1.98 - 4.26e-2 * flapAngle^2 + 2.1e-1 * flapAngle
end

local function FlapEffectivnessCorrection(flapAngle: number): number
    return lerp(0.8, 0.4, (math.deg(math.abs(flapAngle)) - 10) / 50)
end

local function LiftCoefficientMaxFraction(flapFraction: number): number
    return math.clamp(1 - 0.4 * (flapFraction - 0.1) / 0.3, 0, 1)
end

local function CalculateCoefficidentsAtLowAoA(angleOfAttack: number, correctedLiftSlope: number, zeroLiftAoA: number, aspectRatio: number): Vector3
    local liftCoefficient: number = correctedLiftSlope * (angleOfAttack - zeroLiftAoA)
    local inducedAngle: number = liftCoefficient / (math.pi * aspectRatio)
    local effectiveAngle: number = angleOfAttack - zeroLiftAoA - inducedAngle

    local tangentialCoefficient: number = engine.skinFriction * math.cos(effectiveAngle)

    local normalCoefficient = (liftCoefficient +
    math.sin(effectiveAngle) * tangentialCoefficient) / math.cos(effectiveAngle)
    local dragCoefficient = normalCoefficient * math.sin(effectiveAngle) + tangentialCoefficient * math.cos(effectiveAngle)
    local torqueCoefficient = -normalCoefficient * TorqCoefficientProportion(effectiveAngle)

    return Vector3.new(liftCoefficient, dragCoefficient, torqueCoefficient)
end

local function CalculateCoefficidentsAtStall(angleOfAttack: number, correctedLiftSlope: number, zeroLiftAoA: number, stallAngleHigh: number, stallAngleLow: number, flapAngle: number, aspectRatio: number): Vector3
    local liftCoefficientLowAoA: number
    if angleOfAttack > stallAngleHigh then
        liftCoefficientLowAoA = correctedLiftSlope * (stallAngleHigh - zeroLiftAoA)
    else
        liftCoefficientLowAoA = correctedLiftSlope * (stallAngleLow - zeroLiftAoA)
    end

    local inducedAngle: number = liftCoefficientLowAoA / (math.pi * aspectRatio)

    local lerpAlpha: number
    if angleOfAttack > stallAngleHigh then
        lerpAlpha = (math.pi / 2 - math.clamp(angleOfAttack, -math.pi / 2, math.pi / 2)) / (math.pi / 2 - stallAngleHigh)
    else
        lerpAlpha = (-math.pi / 2 - math.clamp(angleOfAttack, -math.pi / 2, math.pi / 2)) / (-math.pi / 2 - stallAngleLow)
    end
    inducedAngle = lerp(0, inducedAngle, lerpAlpha)
    local effectiveAngle: number = angleOfAttack - zeroLiftAoA - inducedAngle

    local normalCoefficient: number = FrictionAt90Degrees(flapAngle) * math.sin(effectiveAngle) *
    (1 / (0.56 + 0.44 * math.abs(math.sin(effectiveAngle))) -
    0.41 * (1 - math.exp(-17 / aspectRatio)))
    local tangentialCoefficient: number = 0.5 * engine.skinFriction * math.cos(effectiveAngle)

    local liftCoefficient: number = normalCoefficient * math.cos(effectiveAngle) - tangentialCoefficient * math.sin(effectiveAngle)
    local dragCoefficient: number = normalCoefficient * math.sin(effectiveAngle) + tangentialCoefficient * math.cos(effectiveAngle)
    local torqueCoefficient: number = -normalCoefficient * TorqCoefficientProportion(effectiveAngle)

    return Vector3.new(liftCoefficient, dragCoefficient, torqueCoefficient)
end

local function CalculateCoefficidents(angleOfAttack: number, correctedLiftSlope: number, zeroLiftAoA: number, stallAngleHigh: number, stallAngleLow: number, flapAngle: number, aspectRatio: number): Vector3
    local aerodynamicCoefficidents: Vector3

    local paddingAngleHigh: number = math.rad(lerp(15, 5, (math.deg(flapAngle) + 50) / 100))
    local paddingAngleLow: number = math.rad(lerp(15, 5, (-math.deg(flapAngle) + 50) / 100))
    local paddedStallAngleHigh: number = stallAngleHigh + paddingAngleHigh
    local paddedStallAngleLow: number = stallAngleLow - paddingAngleLow

    if angleOfAttack < stallAngleHigh and angleOfAttack > stallAngleLow then
        aerodynamicCoefficidents = CalculateCoefficidentsAtLowAoA(angleOfAttack, correctedLiftSlope, zeroLiftAoA, aspectRatio)
    elseif angleOfAttack > paddedStallAngleHigh or angleOfAttack < paddingAngleLow then
        aerodynamicCoefficidents = CalculateCoefficidentsAtStall(
            angleOfAttack, correctedLiftSlope, zeroLiftAoA, stallAngleHigh, stallAngleLow, flapAngle, aspectRatio
        )
    else
        local aerodynamicCoefficientsLow: Vector3
        local aerodynamicCoefficientsStall: Vector3
        local lerpAlpha: number

        if angleOfAttack > stallAngleHigh then
            aerodynamicCoefficientsLow = CalculateCoefficidentsAtLowAoA(
                stallAngleHigh, correctedLiftSlope, zeroLiftAoA, aspectRatio)
            aerodynamicCoefficientsStall = CalculateCoefficidentsAtStall(
                paddedStallAngleHigh, correctedLiftSlope, zeroLiftAoA, stallAngleHigh, stallAngleLow, flapAngle, aspectRatio
            )
            lerpAlpha = (angleOfAttack - stallAngleHigh) / (paddedStallAngleHigh - stallAngleHigh)
        else
            aerodynamicCoefficientsLow = CalculateCoefficidentsAtLowAoA(
                stallAngleLow, correctedLiftSlope, zeroLiftAoA, aspectRatio
            )
            aerodynamicCoefficientsStall = CalculateCoefficidentsAtStall(
                paddedStallAngleLow, correctedLiftSlope, zeroLiftAoA, stallAngleHigh, stallAngleLow, flapAngle, aspectRatio
            )
            lerpAlpha = (angleOfAttack - stallAngleLow) / (paddedStallAngleLow - stallAngleLow)
        end
        aerodynamicCoefficidents = aerodynamicCoefficientsLow:Lerp(aerodynamicCoefficientsStall, lerpAlpha)
    end
    return aerodynamicCoefficidents.Magnitude > 0 and aerodynamicCoefficidents or Vector3.zero
end

function Coefficidents.new(wing: BasePart, span: number, chord: number, aspectRatio: number)
    return setmetatable({
        ["flapAngle"] = 0,
        ["span"] = span,
        ["chord"] = chord,
        ["aspectRatio"] = aspectRatio,
        ["wing"] = wing
    }, Coefficidents)
end

function Coefficidents:setFlapAngle(angle: number)
    self.flapAngle = math.clamp(angle, -math.rad(50), math.rad(50))
end

function Coefficidents:CalculateForces(worldAirVelocity: Vector3, relativePosition: Vector3)
    local forceAndTorque = BiVector.new()
    
    local correctedLiftSlope: number = engine.liftSlope * self.aspectRatio /
    (self.aspectRatio + 2 * (self.aspectRatio + 4) / (self.aspectRatio + 2))

    local theta: number = math.acos(2 * engine.flapFraction - 1)
    local flapEffectivness: number = 1 - (theta - math.sin(theta)) / math.pi
    local deltaLift: number = correctedLiftSlope * flapEffectivness * FlapEffectivnessCorrection(self.flapAngle) * self.flapAngle

    local zeroLiftAoABase: number = math.rad(engine.zeroLiftAoA)
    local zeroLiftAoA: number = zeroLiftAoABase - deltaLift / correctedLiftSlope

    local stallAngleHighBase: number = math.rad(engine.stallAngleHigh)
    local stallAngleLowBase: number = math.rad(engine.stallAngleLow)

    local clMaxHigh: number = correctedLiftSlope * (stallAngleHighBase - zeroLiftAoABase) + deltaLift * LiftCoefficientMaxFraction(engine.flapFraction)
    local clMaxLow: number = correctedLiftSlope * (stallAngleLowBase - zeroLiftAoABase) + deltaLift * LiftCoefficientMaxFraction(engine.flapFraction)

    local stallAngleHigh: number = zeroLiftAoA + clMaxHigh / correctedLiftSlope
    local stallAngleLow: number = zeroLiftAoA + clMaxLow / correctedLiftSlope
    
    local airVelocity: Vector3 = Vector3.new(0, 0, -self.wing.AssemblyLinearVelocity.Magnitude) ---self.wing.CFrame.LookVector + worldAirVelocity
    ---airVelocity = Vector3.new(0, airVelocity.Y, airVelocity.Z)
    local dragDirection: Vector3 = -self.wing.CFrame.LookVector
    local liftDirection: Vector3 = self.wing.CFrame.UpVector

    local area: number = self.chord * self.span
    local dynamicPressure: number = 0.5 * engine.airDensity * math.sqrt(airVelocity.Magnitude)
    local angleOfAttack: number = math.atan2(airVelocity.Unit.Y, airVelocity.Unit.Z)
    local aerodynamicCoefficidents: Vector3 = CalculateCoefficidents(angleOfAttack, correctedLiftSlope, zeroLiftAoA, stallAngleHigh, stallAngleLow, self.flapAngle, self.aspectRatio)
    
    local lift: Vector3 = liftDirection * dynamicPressure * area
    local drag: Vector3 = dragDirection * dynamicPressure * area
    local torque: Vector3 = self.wing.CFrame.RightVector * dynamicPressure * area * self.chord

    forceAndTorque.force += lift + drag
    --forceAndTorque.torque += relativePosition:Cross(forceAndTorque.force)
    --forceAndTorque.torque += torque

    if RUN_SERVICE:IsStudio() then
        gizmo.setColor(Color3.fromRGB(199, 2, 2))
        gizmo.drawRay(self.wing.Position, lift)
        gizmo.setColor(Color3.fromRGB(13, 2, 167))
        gizmo.drawRay(self.wing.Position, drag)
    end

    return forceAndTorque
end

return Coefficidents