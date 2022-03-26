
local exploriteTranslate = {}
exploriteTranslate.__index = exploriteFlags
function Explorite.SimpleTranslate()
	local cted = {}
	setmetatable(cted, exploriteTranslate)
	cted.data = {}
	cted.data.de = {}
	cted.data.en = {}
	cted.data.es = {}
	cted.data.jp = {}
	cted.data.kr = {}
	cted.data.ru = {}
	cted.data.zh = {}
	return cted
end

function exploriteTranslate:TranslatedString(str, ...)
	local language = Options.Language
	if self.data[language] == nil or self.data[language][str] == nil then
		language = "en"
	end
	local result = self.data[language][str]
	for i,value in ipairs(...) do
		result = string.gsub(result, "{"..i.."}", tostring(value))
		result = string.gsub(result, "{\\"..i.."}", "{"..i.."}")
	end
	return result
end