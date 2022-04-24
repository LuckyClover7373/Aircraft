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
engine.thrust = 3000

return engine