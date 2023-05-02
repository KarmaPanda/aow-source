require("share\\client_custom_define")
require("form_stage_main\\form_guildbuilding\\guildbuilding_getinfo")
local REMOVE_FROM_PLAYER_ALL = 0
local REMOVE_FROM_PLAYER_NONE = 1
local REMOVE_FROM_PLAYER_CAPITALTYPE = 2
local REMOVE_FROM_PLAYER_GOODS = 3
function main_form_init(self)
  self.Fixed = false
  self.type = 1
  self.npcid = nil
  self.main_type = 0
  self.sub_type = 0
  self.stopLeftTime = 0
  self.coolLeftTime = 0
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_upgrade_2", nx_null())
end
function on_btn_upgrade_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if nx_int(form.stopLeftTime) <= nx_int(0) and nx_int(form.coolLeftTime) <= nx_int(0) then
    game_visual:CustomSend(nx_int(1016), nx_int(1), form.npcid)
  end
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
function on_recv_houseinfo(...)
  local size = table.getn(arg)
  if size < 7 then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_upgrade_2")
  if not nx_is_valid(form) then
    if nx_int(arg[2]) > nx_int(0) then
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guildbuilding_upgrade_2", true, false)
      nx_set_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_upgrade_2", form)
      form:Show()
      form.Visible = true
    else
      return 0
    end
  end
  form.main_type = nx_int(arg[1])
  form.sub_type = nx_int(arg[3])
  form.npcid = arg[4]
  local level = nx_int(arg[5])
  form.stopLeftTime = nx_int(arg[6])
  form.coolLeftTime = nx_int(arg[7])
  local guildbuilding_Manager = nx_value("GuildbuildingManager")
  local buildinginfo_1 = guildbuilding_Manager:GetGuildBuildingLevelInfo(form.main_type, form.sub_type, level)
  local buildinginfo_2 = guildbuilding_Manager:GetGuildBuildingLevelInfo(form.main_type, form.sub_type, level + 1)
  form.lbl_1.Text = get_building_name(form.main_type, form.sub_type)
  form.mltbox_1.HtmlText = get_building_content(form.main_type, form.sub_type)
  form.lbl_2.Text = get_building_level(level)
  form.lbl_3.Text = get_building_zengyi(form.main_type, form.sub_type, level)
  form.lbl_5.Text = get_building_leftTime(form.stopLeftTime, form.coolLeftTime)
  form.mltbox_3.HtmlText = add_condition_info(form.main_type, form.sub_type, level)
  form.btn_1.Text = get_building_btn(level)
  form.btn_1.Enabled = true
  form.btn_2.Enabled = true
  if 0 < form.stopLeftTime or 0 < form.coolLeftTime then
    form.btn_1.Enabled = false
  end
  return 1
end
function add_condition_info(main_type, sub_type, level)
  local gui = nx_value("gui")
  local guildbuilding_manager = nx_value("GuildbuildingManager")
  local condition = nx_widestr(gui.TextManager:GetText("ui_shenghuo0005")) .. nx_widestr(" ") .. nx_widestr("<BR>")
  local upgrade_info = guildbuilding_manager:GetGuildBuildingLevelInfo(main_type, sub_type, level)
  local remove_type = upgrade_info[7]
  local gold = upgrade_info[8]
  if nx_int(gold) > nx_int(0) then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    local ui_gold = nx_widestr(gui.TextManager:GetText("ui_offline_form_jinbi"))
    condition = condition .. head_str .. ui_gold .. " : "
    local gold_text = nx_execute("util_functions", "trans_capital_string", gold)
    condition = condition .. nx_string(gold_text) .. " "
  end
  local silver = upgrade_info[9]
  if nx_int(silver) > nx_int(0) then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    if remove_type == REMOVE_FROM_PLAYER_NONE or remove_type == REMOVE_FROM_PLAYER_GOODS then
      head_str = nx_widestr(gui.TextManager:GetText("19307")) .. nx_widestr("-")
    end
    local ui_silver = nx_widestr(gui.TextManager:GetText("ui_silvermoney"))
    condition = condition .. head_str .. ui_silver .. ":"
    local silver_text = nx_execute("util_functions", "trans_capital_string", silver)
    condition = condition .. nx_string(silver_text) .. " "
  end
  local item_list = guildbuilding_manager:GetGuildBuildingItemsInfo(main_type, sub_type, level)
  local size = table.getn(item_list)
  local count = size / 2
  if 0 < count then
    local head_str = nx_widestr(gui.TextManager:GetText("19309")) .. nx_widestr("-")
    if remove_type == REMOVE_FROM_PLAYER_NONE or remove_type == REMOVE_FROM_PLAYER_CAPITALTYPE then
      head_str = nx_widestr(gui.TextManager:GetText("19306")) .. nx_widestr("-")
    end
    condition = condition .. head_str
    for i = 1, count do
      local config = item_list[i * 2 - 1]
      local num = item_list[i * 2]
      local str_config = nx_widestr(gui.TextManager:GetText(config))
      condition = condition .. nx_string(str_config) .. "x" .. nx_string(num) .. " "
    end
  end
  return nx_widestr(condition)
end
