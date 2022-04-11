--Isaac.ConsoleOutput("Init mod Explorite\n")

Explorite = Explorite or {}
Explorite.ExploriteMod = RegisterMod("Explorite", 1);

Explorite.Core = {}
Explorite.gameInited = false

require("scripts_explorite/misc")
require("scripts_explorite/exploriteFlags")
require("scripts_explorite/exploriteObjectives")
require("scripts_explorite/completionMarksUtility")
require("scripts_explorite/simpleTranslate")
require("scripts_explorite/font")
require("scripts_explorite/sidebarbox")
require("scripts_explorite/isaacTranslate")
require("scripts_explorite/exploriteLang")
require("scripts_explorite/debugwriter")

--Isaac.ConsoleOutput("Init mod Explorite end\n")

-- 在游戏被初始化后运行
function Explorite.Core:PostGameStarted(loadedFromSaves)
	Explorite.gameInited = true
end
Explorite.ExploriteMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Explorite.Core.PostGameStarted)

-- 在游戏退出前运行
function Explorite.Core:PreGameExit(shouldSave)
	Explorite.gameInited = false
end
Explorite.ExploriteMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Explorite.Core.PreGameExit)
