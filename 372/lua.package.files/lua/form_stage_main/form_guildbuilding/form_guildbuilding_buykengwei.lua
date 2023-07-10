require("share\\client_custom_define")
require("util_gui")
require("form_stage_main\\form_guildbuilding\\guildbuilding_getinfo")
require("share\\view_define")
require("game_object")
require("util_static_data")
require("define\\tip_define")
local REMOVE_FROM_PLAYER_ALL = 0
local REMOVE_FROM_PLAYER_NONE = 1
local REMOVE_FROM_PLAYER_CAPITALTYPE = 2
local REMOVE_FROM_PLAYER_GOODS = 3
function main_form_init(self)
  self.Fixed = false
  self.type = 0
  self.npcid = nil
  self.kengweiNum = 0
  self.level = 0
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  show_buy_kengwei_condition(form, form.type, form.level, form.kengweiNum)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_buykengwei", nx_null())
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(2), form.npcid)
  form:Close()
  return 1
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function show_buy_kengwei_condition(form, building_type, level, kengwei_num)
  local gb_manager = nx_value("GuildbuildingManager")
  local gui = nx_value("gui")
  form.mltbox_info:Clear()
  local condition = nx_widestr(gui.TextManager:GetText("ui_shenghuo0005")) .. nx_widestr(" ") .. nx_widestr("<BR>")
  local infos = gb_manager:GetBuyKengWeiItemsInfo(building_type, level, kengwei_num)
  local remove_type = infos[1]
  local gold = infos[2]
  if nx_int(gold) > nx_int(0) then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    local ui_gold = nx_widestr(gui.TextManager:GetText("ui_offline_form_jinbi"))
    condition = condition .. head_str .. ui_gold .. " : "
    local gold_text = nx_execute("util_functions", "trans_capital_string", gold)
    condition = condition .. nx_string(gold_text) .. "<img src=\"gui\\common\\money\\jyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
  end
  local silver = infos[3]
  if nx_int(silver) > nx_int(0) then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    if remove_type == REMOVE_FROM_PLAYER_NONE or remove_type == REMOVE_FROM_PLAYER_GOODS then
      head_str = nx_widestr(gui.TextManager:GetText("19307")) .. nx_widestr("-")
    end
    local ui_silver = nx_widestr(gui.TextManager:GetText("ui_silvermoney"))
    condition = nx_widestr(condition) .. nx_widestr(head_str) .. nx_widestr(ui_silver) .. nx_widestr(":")
    local silver_text = nx_execute("util_functions", "trans_capital_string", silver)
    condition = nx_widestr(condition) .. nx_widestr(silver_text) .. nx_widestr("<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" only=\"line\" data=\"\" />")
  end
  local size = table.getn(infos)
  local item_count = (size - 3) / 2
  if 0 < item_count then
    local head_str = nx_widestr(gui.TextManager:GetText("19309")) .. nx_widestr("-")
    if remove_type == REMOVE_FROM_PLAYER_NONE or remove_type == REMOVE_FROM_PLAYER_CAPITALTYPE then
      head_str = nx_widestr(gui.TextManager:GetText("19306")) .. nx_widestr("-")
    end
    condition = condition .. head_str
    for i = 1, item_count do
      local config = infos[4 + (i - 1) * 2]
      local count = infos[4 + (i - 1) * 2 + 1]
      local str_config = nx_widestr(gui.TextManager:GetText(config))
      condition = condition .. nx_string(str_config) .. "x" .. nx_string(count) .. " "
    end
  end
  form.mltbox_info.HtmlText = nx_widestr(condition)
end
