
local debugwriter = RegisterMod("debugwriter", 1);

function Explorite.Debugwriter(str)
	Isaac.SaveModData(debugwriter, tostring(str))
end