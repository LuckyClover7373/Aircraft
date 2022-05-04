--[[                        
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢠⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⡆⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⣼⡿⣿⣿⡏⠉⠉⠉⠉⠉⠉⠉⠁⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣠⣿⠟⠁⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣼⣿⠋⠄⠄⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⣠⣿⠟⠁⠄⠄⠄⣿⣿⡿⠿⠿⠿⠿⠿⠿⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⢀⣼⣿⣯⣤⣤⣤⣤⣤⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⢠⣿⡟⠛⠛⠛⠛⠛⠛⠛⣿⣿⡇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⢀⣼⣿⠋⠄⠄⠄⠄⠄⠄⠄⠄⣿⣿⣇⣀⣀⣀⣀⣀⣀⣀⡀⠄⠄⠄
⠄⠄⠄⠄⠛⠛⠃⠄⠄⠄⠄⠄⠄⠄⠄⠄⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠇⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄

Aircraft Engine
Made by LuckyClover7373 (Thanks for wjoh0315)

]]--

local engine = {}

engine.airDensity = 1.3

engine.liftSlope = 6.28
engine.skinFriction = 0.02
engine.zeroLiftAoA = 0
engine.stallAngleHigh = 15
engine.stallAngleLow = -15
engine.chord = 1
engine.flapFraction = 0.2
engine.span = 1
engine.autoAspectRatio = true
engine.aspectRatio = 2
engine.thrust = 10

local function engineFix()
    if engine.flapFraction > 0.4 then engine.flapFraction = 0.4 end
    if engine.flapFraction < 0 then engine.flapFraction = 0 end
    if engine.stallAngleHigh < 0 then engine.stallAngleHigh = 0 end
    if engine.stallAngleLow > 0 then engine.stallAngleLow = 0 end
    if engine.chord < 0.001 then engine.chord = 0.001 end
    if engine.autoAspectRatio then engine.aspectRatio = engine.span / engine.chord end
end
engineFix()

return engine