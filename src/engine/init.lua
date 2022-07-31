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
Made by LuckyClover7373 (A huge help by wjoh0315, I'm so appreciate to him)

]]--

local engine = {}

engine.airDensity = 1.3

engine.liftSlope = 6.28
engine.skinFriction = 0.02
engine.zeroLiftAoA = 0
engine.stallAngleHigh = 15
engine.stallAngleLow = -15
engine.flapFraction = 0.2
engine.autoAspectRatio = true
engine.thrust = 3000

local function engineFix()
    if engine.flapFraction > 0.4 then engine.flapFraction = 0.4 end
    if engine.flapFraction < 0 then engine.flapFraction = 0 end
    if engine.stallAngleHigh < 0 then engine.stallAngleHigh = 0 end
    if engine.stallAngleLow > 0 then engine.stallAngleLow = 0 end
end
engineFix()

return engine