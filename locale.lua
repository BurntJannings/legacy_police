Locales = {}

function _(str, ...) -- Translate string
	if Locales[Locale] ~= nil then
		if Locales[Locale][str] ~= nil then
			return string.format(Locales[Locale][str], ...)
		else
			return 'Translation [' .. Locale .. '][' .. str .. '] does not exist'
		end
	else
		return 'Locale [' .. Locale .. '] does not exist'
	end
end

function _U(str, ...) -- Translate string first char uppercase
	return tostring(_(str, ...):gsub("^%l", string.upper))
end
