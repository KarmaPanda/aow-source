require("const_define")
require("util_gui")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
local StallNotes_Rec = "StallNotes_Rec"
function main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  init_info(self)
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_clear_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(673))
  return 1
end
function init_info(form)
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local client_role = game_client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  if not client_role:FindRecord(StallNotes_Rec) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_notes:Clear()
  local item_row_num = client_role:GetRecordRows(StallNotes_Rec)
  if 0 < item_row_num then
    for i = item_row_num - 1, 0, -1 do
      local otherPlayerName = nx_widestr(client_role:QueryRecord(StallNotes_Rec, i, 0))
      local itemConfig = nx_string(client_role:QueryRecord(StallNotes_Rec, i, 1))
      local itemCount = nx_int(client_role:QueryRecord(StallNotes_Rec, i, 2))
      local gold = client_role:QueryRecord(StallNotes_Rec, i, 3)
      local shuijin = client_role:QueryRecord(StallNotes_Rec, i, 4)
      local time1 = client_role:QueryRecord(StallNotes_Rec, i, 5)
      local nType = nx_int(client_role:QueryRecord(StallNotes_Rec, i, 6))
      local str_date = nx_string(time1)
      local strGold = trans_capital_string(gold)
      local strShuiJin = trans_capital_string(shuijin)
      local info = ""
      local iteminfo = nx_widestr(gui.TextManager:GetText(itemConfig)) .. nx_widestr("X") .. nx_widestr(itemCount)
      iteminfo = iteminfo .. nx_widestr("    ")
      if nType == nx_int(0) then
        info = gui.TextManager:GetFormatText("ui_stall_goumai_notes_ex", str_date, iteminfo, strGold)
        form.mltbox_notes:AddHtmlText(nx_widestr(info), nx_int(-1))
      elseif nType == nx_int(1) then
        info = gui.TextManager:GetFormatText("ui_stall_chushou_notes_ex", str_date, iteminfo, strGold)
        form.mltbox_notes:AddHtmlText(nx_widestr(info), nx_int(-1))
      end
    end
  end
end
function trans_capital_string(capital)
  local gui = nx_value("gui")
  local ding_value = math.floor(capital / 1000000)
  local liang_value = math.floor(capital % 1000000 / 1000)
  local wen_value = math.floor(capital % 1000)
  local ding_text = nx_widestr("")
  local liang_text = nx_widestr("")
  local wen_text = nx_widestr("")
  if 0 < ding_value then
    ding_text = nx_widestr(ding_value) .. nx_widestr(gui.TextManager:GetText("ui_Ding"))
  else
    ding_text = nx_widestr("")
  end
  if 0 < liang_value then
    liang_text = nx_widestr(liang_value) .. nx_widestr(gui.TextManager:GetText("ui_Liang"))
  else
    liang_text = nx_widestr("")
  end
  if 0 < wen_value then
    wen_text = nx_widestr(wen_value) .. nx_widestr(gui.TextManager:GetText("ui_Wen"))
  else
    wen_text = nx_widestr("")
  end
  return nx_widestr(nx_widestr(ding_text) .. nx_widestr(liang_text) .. nx_widestr(wen_text))
end
function format_date_text(text)
  local len = nx_int(string.len(text))
  local month, day, hour, minute, formatText
  month = string.sub(nx_string(text), 1, string.find(nx_string(text), "-") - 1)
  if nx_number(month) < 10 then
    month = "0" .. month
  end
  day = string.sub(nx_string(text), string.find(nx_string(text), "-") + 1, string.find(nx_string(text), " ") - 1)
  if nx_number(day) < 10 then
    day = "0" .. day
  end
  hour = string.sub(nx_string(text), string.find(nx_string(text), " ") + 1, string.find(nx_string(text), ":") - 1)
  if nx_number(hour) < 10 then
    hour = "0" .. hour
  end
  minute = string.sub(nx_string(text), string.find(nx_string(text), ":") + 1, -1)
  if nx_number(minute) < 10 then
    minute = "0" .. minute
  end
  formatText = month .. "-" .. day .. " " .. hour .. ":" .. minute
  return formatText
end
