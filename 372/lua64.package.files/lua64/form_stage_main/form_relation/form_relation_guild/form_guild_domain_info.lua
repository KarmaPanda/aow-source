require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local SUB_CUSTOMMSG_REQUEST_GUILD_DOMAIN_INFO = 63
local SUB_CUSTOMMSG_REQUEST_CANCEL_CD = 71
local SUB_CUSTOMMSG_REQUEST_DOMAIN_OCCUPY_MULTIPLE = 79
local MAX_DRAWING_LEVEL = 5
local GUILDWAR_STAGE_NORMAL = 0
local GUILDWAR_STAGE_READY = 1
local GUILDWAR_STAGE_FIGHTING = 2
local GUILDWAR_STAGE_DECLARED = 3
local ST_FUNCTION_NEW_GUILDWAR = 219
function main_form_init(self)
  self.Fixed = true
  self.check = false
  local building_control = self:Find("groupbox_buildings")
  if nx_is_valid(building_control) then
    local btn_show = building_control:Find("btn_9")
    if nx_is_valid(building_control) then
      btn_show.Visible = false
    end
  end
  self.domainID = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  custom_request_own_domian()
  self.btn_baoming.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    self.btn_baoming.Visible = true
  end
end
function on_main_form_close(self)
  local preview = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain_preview")
  if nx_is_valid(preview) then
    preview:Close()
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain_preview", nil)
  end
  nx_destroy(self)
end
function close_preview(self)
  local preview = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain_preview")
  if nx_is_valid(preview) then
    preview:Close()
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain_preview", nil)
  end
end
function on_btn_close_click(self)
  nx_destroy(self.ParentForm)
end
function on_btn_show_domain_click(self)
  local form = self.ParentForm
  if nx_int(form.domainID) == nx_int(0) then
    return
  end
  local scene_id = string.sub(nx_string(form.domainID), 1, -3)
  if nx_int(scene_id) < nx_int(0) then
    return
  end
  nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_domain_preview", "refresh_scene_map", nx_int(scene_id), nx_int(form.domainID))
end
function on_combobox_domain_selected(combobox)
  local form = combobox.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local select_index = combobox.DropListBox.SelectIndex
  local obj_id = combobox.DropListBox:GetTag(select_index)
  local id = nx_string(obj_id)
  local domian_id = nx_int(id)
  form.lbl_guild_location.Text = nx_widestr(guild_util_get_text("ui_dipanmiaoshu_" .. nx_string(domian_id)))
  form.domainID = domian_id
  custom_request_domian(domian_id)
  custom_request_occupy_multiple(domian_id)
end
function on_btn_tips_get_capture(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local text = nx_widestr(gui.TextManager:GetText("ui_guild_domain_tips"))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_btn_tips_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_btn_cancel_cd_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local is_captain = is_guild_captain()
  if is_captain == false then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("90356"), 0, 0)
    end
  end
  if nx_int(form.lbl_hour.Text) == nx_int(0) then
    return
  end
  if nx_int(form.domainID) == nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetText("90357", name))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_CANCEL_CD), nx_int(form.domainID))
  local main_form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(main_form) then
    return
  end
  main_form:Close()
end
function custom_request_own_domian()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_OWN_DOMAIN))
end
function custom_request_domian(domian_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_DOMAIN_INFO), nx_int(domian_id))
end
function custom_request_occupy_multiple(domian_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DOMAIN_OCCUPY_MULTIPLE), nx_int(domian_id))
end
function recv_guild_own_domain(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_domain_info", false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local domain_count = table.getn(arg)
  if nx_int(domain_count) == nx_int(0) then
    form.lbl_guild_location.Text = nx_widestr(guild_util_get_text("ui_guild_domain_none"))
    return
  end
  form.combobox_domain.DropListBox:ClearString()
  for i = 1, domain_count do
    local domain_id = arg[i]
    form.combobox_domain.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_dipan_" .. nx_string(domain_id))))
    local id = nx_string(domain_id) .. "-0"
    form.combobox_domain.DropListBox:SetTag(i - 1, nx_object(id))
  end
  form.combobox_domain.DropListBox.SelectIndex = 0
  form.combobox_domain.Text = form.combobox_domain.DropListBox:GetString(0)
  on_combobox_domain_selected(form.combobox_domain)
  local building_control = form:Find("groupbox_buildings")
  if nx_is_valid(building_control) then
    local btn_show = building_control:Find("btn_9")
    if nx_is_valid(building_control) then
      btn_show.Visible = true
    end
  end
end
function recv_guild_domain_data(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_domain_info", false)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 5 then
    return
  end
  local gui = nx_value("gui")
  local arg_index = 1
  field_num = nx_int(arg[arg_index])
  arg_index = arg_index + 1
  occ_value = nx_int(arg[arg_index])
  arg_index = arg_index + 1
  occ_state = nx_int(arg[arg_index])
  arg_index = arg_index + 1
  enemy_name = nx_widestr(arg[arg_index])
  arg_index = arg_index + 1
  diff_day = nx_int(arg[arg_index])
  arg_index = arg_index + 1
  local limit_occ_value = nx_int(arg[arg_index])
  arg_index = arg_index + 1
  local protect_hour = nx_int(arg[arg_index])
  arg_index = arg_index + 1
  local fight_week = nx_int(arg[arg_index])
  arg_index = arg_index + 1
  local count = table.getn(arg) - 8
  local arg_group_num = 2
  local building_control = form:Find("groupbox_buildings")
  if not nx_is_valid(building_control) then
    return
  end
  local total_level = 0
  count = count / arg_group_num
  for i = 1, count do
    local id = arg[arg_index]
    arg_index = arg_index + 1
    local level = arg[arg_index]
    arg_index = arg_index + 1
    local pic_level = building_control:Find("pic_" .. nx_string(id))
    if nx_is_valid(pic_level) then
      pic_level.Image = "gui\\guild\\guildpaper\\guildbuilding_" .. nx_string(level) .. ".png"
    end
    total_level = nx_int(total_level) + nx_int(level)
  end
  local guilddomain_Manager = nx_value("GuildDomainManager")
  form.lbl_occvalue.Text = nx_widestr(occ_value) .. nx_widestr("/") .. nx_widestr(limit_occ_value)
  form.show_lbl.Text = nx_widestr(nx_int(total_level / MAX_DRAWING_LEVEL * 100))
  local domain_state = guilddomain_Manager:GetDomainState(nx_int(field_num), nx_int(occ_value))
  form.lbl_domainstate.Text = nx_widestr(gui.TextManager:GetText("ui_guild_domain_state_" .. nx_string(domain_state)))
  local remain = get_format_time_text(nx_number(protect_hour))
  form.lbl_hour.Text = nx_widestr(remain)
  if nx_number(remain) == nx_number(0) then
    form.btn_cancel_cd.Visible = false
    form.lbl_hour.Visible = false
  else
    form.btn_cancel_cd.Visible = true
    form.lbl_hour.Visible = true
  end
  if nx_int(occ_state) == nx_int(GUILDWAR_STAGE_NORMAL) then
    form.mltbox_guildwarstate.HtmlText = nx_widestr(gui.TextManager:GetText("ui_guild_domain_peace"))
  elseif nx_int(occ_state) == nx_int(GUILDWAR_STAGE_DECLARED) then
    if nx_int(diff_day) == nx_int(0) then
      form.mltbox_guildwarstate.HtmlText = nx_widestr(gui.TextManager:GetFormatText("newguildwar_domainwar_" .. nx_string(fight_week), nx_widestr(enemy_name)))
    elseif nx_int(diff_day) == nx_int(1) then
      form.mltbox_guildwarstate.HtmlText = nx_widestr(gui.TextManager:GetFormatText("newguildwar_domainwar_" .. nx_string(fight_week), nx_widestr(enemy_name)))
    end
  else
    form.mltbox_guildwarstate.HtmlText = nx_widestr(gui.TextManager:GetText("ui_guild_domain_war_now"))
  end
end
function on_rec_occupy_del_multiple(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_domain_info", false)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 1 then
    return
  end
  local cur_value = nx_int(arg[1])
  local multi_str = nx_widestr("ui_multiple_1")
  if nx_int(cur_value) == nx_int(100) then
    multi_str = nx_widestr(util_text("ui_multiple_1"))
  elseif nx_int(cur_value) == nx_int(150) then
    multi_str = nx_widestr(util_text("ui_multiple_2"))
  elseif nx_int(cur_value) == nx_int(200) then
    multi_str = nx_widestr(util_text("ui_multiple_3"))
  end
  form.lbl_occupy_multi.Text = nx_widestr(multi_str)
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    if min >= nx_int(0) or sce >= nx_int(0) then
      hour = hour + 1
    end
    format_time = string.format("%d", nx_number(hour))
  elseif nx_number(time) > 0 then
    format_time = string.format("%d", nx_number(1))
  else
    format_time = string.format("%d", nx_number(0))
  end
  return nx_string(format_time)
end
function is_guild_captain()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_captain = client_player:QueryProp("IsGuildCaptain")
  if is_captain ~= nx_int(2) then
    return false
  end
  return true
end
function on_btn_baoming_click(btn)
  local form = btn.ParentForm
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    form.btn_baoming.Visible = false
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_baoming", true, false)
    dialog:Show()
    form.btn_baoming.Visible = true
  else
    form.btn_baoming.Visible = false
  end
end
