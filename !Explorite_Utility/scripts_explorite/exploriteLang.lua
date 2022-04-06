
local exploriteLang = Explorite.SimpleTranslate()

function ExploriteLang(str)
	return exploriteLang:_(str)
end

function AppendPeriodMark(str)
	local endMark = string.sub(str,-1)
	local endMark2 = string.sub(str,-3)
	if  endMark ~= "."
	and endMark ~= "?"
	and endMark ~= "!"
	and endMark2 ~= "。"
	and endMark2 ~= "？"
	and endMark2 ~= "！"
	then
		return str..ExploriteLang("explorite_endmark")
	end
	return str
end

exploriteLang.data.en["explorite_endmark"] = "."
exploriteLang.data.jp["explorite_endmark"] = "。"
exploriteLang.data.kr["explorite_endmark"] = "."
exploriteLang.data.zh["explorite_endmark"] = "。"
exploriteLang.data.ru["explorite_endmark"] = "."
exploriteLang.data.de["explorite_endmark"] = "."
exploriteLang.data.es["explorite_endmark"] = "."
