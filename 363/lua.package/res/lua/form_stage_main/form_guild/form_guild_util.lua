function guild_util_get_text(text_id, ...)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetFormatText(text_id, unpack(arg)))
  return text
end
function util_split_string(str, split)
  local result = {}
  if str == nil or split == nil or str == "" then
    return result
  end
  if split == "" then
    table.insert(result, str)
    return result
  end
  local i = 0
  while true do
    local temp = i + 1
    i = string.find(str, split, i + 1)
    if i == nil then
      table.insert(result, string.sub(str, temp))
      break
    end
    local sub_string = string.sub(str, temp, i - 1)
    if sub_string == nil then
      sub_string = ""
    end
    table.insert(result, sub_string)
  end
  return result
end
function transform_date(pdate)
  local text = nx_string(pdate)
  text = string.gsub(text, " ", "")
  text = string.gsub(text, "-", "/")
  text = string.gsub(text, "#", " ")
  return text
end
