local Coefficidents = {}

local engine = require(script.Parent.Parent)

local flapAngle: number = 0;

local function lerp(a: number, b: number, t: number): number
    return a + (b - a) * t
end

local function TorqCoefficientProportion(effectiveAngle: number): number
    return 0.25 - 0.175 * (1 - 2 * math.abs(effectiveAngle) / math.pi)
end

local function FrictionAt90Degrees(flapAngle: number): number
    return 1.98 - 4.26e-2 * flapAngle^2 + 2.1e-1 * flapAngle
end

local function CalculateCoefficidentsAtLowAoA(angleOfAttack: number, correctedLiftSlope: number, zeroLiftAoA: number): Vector3
    local liftCoefficient: number = correctedLiftSlope * (angleOfAttack - zeroLiftAoA)
    local inducedAngle: number = liftCoefficient / (math.pi * engine.aspectRatio)
    local effectiveAngle: number = angleOfAttack - zeroLiftAoA - inducedAngle

    local tangentialCoefficient: number = engine.skinFriction * math.cos(effectiveAngle)

    local normalCoefficient = (liftCoefficient +
    math.sin(effectiveAngle) * tangentialCoefficient) / math.cos(effectiveAngle)
    local dragCoefficient = normalCoefficient * math.sin(effectiveAngle) + tangentialCoefficient * math.cos(effectiveAngle)
    local torqueCoefficient = -normalCoefficient * TorqCoefficientProportion(effectiveAngle)

    return Vector3.new(liftCoefficient, dragCoefficient, torqueCoefficient)
end

local function CalculateCoefficidentsAtStall(angleOfAttack: number, correctedLiftSlope: number, zeroLiftAoA: number, stallAngleHigh: number, stallAngleLow: number): Vector3
    local liftCoefficientLowAoA: number
    if angleOfAttack > stallAngleHigh then
        liftCoefficientLowAoA = correctedLiftSlope * (stallAngleHigh - zeroLiftAoA)
    else
        liftCoefficientLowAoA = correctedLiftSlope * (stallAngleLow - zeroLiftAoA)
    end

    local inducedAngle: number = liftCoefficientLowAoA / (math.pi * engine.aspectRatio)

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
    0.41 * (1 - math.exp(-17 / engine.aspectRatio)))
    local tangentialCoefficient: number = 0.5 * engine.skinFriction * math.cos(effectiveAngle)

    local liftCoefficient: number = normalCoefficient * math.cos(effectiveAngle) - tangentialCoefficient * math.sin(effectiveAngle)
    local dragCoefficient: number = normalCoefficient * math.sin(effectiveAngle) + tangentialCoefficient * math.cos(effectiveAngle)
    local torqueCoefficient: number = -normalCoefficient * TorqCoefficientProportion(effectiveAngle)

    return Vector3.new(liftCoefficient, dragCoefficient, torqueCoefficient)
end

function Coefficidents.setFlapAngle(angle: number)
    flapAngle = math.clamp(angle, -math.rad(50), math.rad(50))
end

function Coefficidents.CalculateCoefficidents(angleOfAttack: number, correctedLiftSlope: number, zeroLiftAoA: number, stallAngleHigh: number, stallAngleLow: number): Vector3
    local aerodynamicCoefficidents: Vector3

    local paddingAngleHigh: number = math.rad(lerp(15, 5, (math.deg(flapAngle) + 50) / 100))
    local paddingAngleLow: number = math.rad(lerp(15, 5, (-math.deg(flapAngle) + 50) / 100))
    local paddedStallAngleHigh: number = stallAngleHigh + paddingAngleHigh
    local paddedStallAngleLow: number = stallAngleLow - paddingAngleLow

    if angleOfAttack < stallAngleHigh and angleOfAttack > stallAngleLow then
        aerodynamicCoefficidents = CalculateCoefficidentsAtLowAoA(angleOfAttack, correctedLiftSlope, zeroLiftAoA)
    elseif angleOfAttack > paddedStallAngleHigh or angleOfAttack < paddingAngleLow then
        aerodynamicCoefficidents = CalculateCoefficidentsAtStall(
            angleOfAttack, correctedLiftSlope, zeroLiftAoA, stallAngleHigh, stallAngleLow
        )
    else
        local aerodynamicCoefficientsLow: Vector3
        local aerodynamicCoefficientsStall: Vector3
        local lerpAlpha: number

        if angleOfAttack > stallAngleHigh then
            aerodynamicCoefficientsLow = CalculateCoefficidentsAtLowAoA(
                stallAngleHigh, correctedLiftSlope, zeroLiftAoA)
            aerodynamicCoefficientsStall = CalculateCoefficidentsAtStall(
                paddedStallAngleHigh, correctedLiftSlope, zeroLiftAoA, stallAngleHigh, stallAngleLow
            )
            lerpAlpha = (angleOfAttack - stallAngleHigh) / (paddedStallAngleHigh - stallAngleHigh)
        else
            aerodynamicCoefficientsLow = CalculateCoefficidentsAtLowAoA(
                stallAngleLow, correctedLiftSlope, zeroLiftAoA
            )
            aerodynamicCoefficientsStall = CalculateCoefficidentsAtStall(
                paddedStallAngleLow, correctedLiftSlope, zeroLiftAoA, stallAngleHigh, stallAngleLow
            )
            lerpAlpha = (angleOfAttack - stallAngleLow) / (paddedStallAngleLow - stallAngleLow)
        end
        aerodynamicCoefficidents = aerodynamicCoefficientsLow:Lerp(aerodynamicCoefficientsStall, lerpAlpha)
    end
    return aerodynamicCoefficidents
end

return Coefficidents