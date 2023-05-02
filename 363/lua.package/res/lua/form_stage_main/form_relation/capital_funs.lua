require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
function get_captial_text(capital)
  local gui = nx_value("gui")
  local ding = math.floor(capital / 1000000)
  local liang = math.floor(capital % 1000000 / 1000)
  local wen = math.floor(capital % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(text)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(liang)) .. nx_widestr(text)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(wen)) .. nx_widestr(text)
  end
  if capital == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(text)
  end
  return htmlTextYinZi
end
