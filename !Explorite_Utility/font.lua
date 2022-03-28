
Explorite.font = {}
Explorite.font.cjk = Font()
Explorite.font.cjk:Load("font/cjk/lanapixel.fnt")
Explorite.font["PF Tempesta Seven Condensed"] = Font()
Explorite.font["PF Tempesta Seven Condensed"]:Load("font/pftempestasevencondensed.fnt")

function Explorite.GetTextWidth(str)
	return Explorite.font.cjk:GetStringWidthUTF8(str)
end

function Explorite.RenderScaledText(str, X, Y, ScaleX, ScaleY, R, G, B, A, boxWidth, center)
	local lines = BreakStringByLine(str)
	for i,line in ipairs(lines) do
		Explorite.font.cjk:DrawStringScaledUTF8(line, X, Y + 10 * (i - 1) * ScaleY, ScaleX, ScaleY, KColor(R, G, B, A), boxWidth, center)
	end
end

function Explorite.RenderText(str, X, Y, R, G, B, A, boxWidth, center)
	Explorite.RenderScaledText(str, X, Y, 1, 1, R, G, B, A, boxWidth, center)
end

function Explorite.RenderTextB(str, X, Y, R, G, B, A, boxWidth, center)
	Explorite.font["PF Tempesta Seven Condensed"]:DrawString(str, X, Y, KColor(R, G, B, A), boxWidth, center)
end
