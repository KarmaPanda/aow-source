require("util_functions")
require("util_gui")
require("custom_sender")
require("util_static_data")
local FORM_MAIN_NAME = "form_stage_main\\form_universal_school_fight\\form_universal_school_fight_main"
local image_path = "gui\\special\\guj_newmpz\\gujmptbxx_"
local back_image_path = "gui\\special\\guj_newmpz\\gujmpzdzt_"
local postfix_name = ".png"
local ST_FUNCTION_SCHOOL_FIGHT = 925
local ST_FUNCTION_CROSS_SCHOOL_FIGHT = 926
local REWARD_TYPE_COUNT = 4
local DEFEND_INDEX = 1
local ATTACK_INDEX = 2
local STC_ANSWER_FIGHT_INFO_SCHOOL_FIGHT = 20
local STC_SEND_WAR_POINT_INFO = 21
local CS_REQUEST_FIGHT_INFO = 0
local CS_REQUEST_ENTER_WAR = 1
local CS_REQUEST_QUIT_WAR = 2
local CS_REQUEST_GAME_DATA = 3
local UBST_SCHOOL_FIGHT = 3
local UBST_CROSS_SCHOOL_FIGHT = 4
function main_form_init(self)
  self.Fixed = false
  self.refresh_time = -1
  self.refresh_reward = false
  return 1
end
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_SCHOOL_FIGHT) and not switch_manager:CheckSwitchEnable(ST_FUNCTION_CROSS_SCHOOL_FIGHT) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_smzb_012"))
    return
  end
  util_auto_show_hide_form(FORM_MAIN_NAME)
end
function open_form_guide()
  local form = nx_execute("util_gui", "util_show_form", FORM_MAIN_NAME, true)
  if nx_is_valid(form) then
    form:Show()
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.game_type = 0
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_SCHOOL_FIGHT) then
    self.game_type = UBST_SCHOOL_FIGHT
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_CROSS_SCHOOL_FIGHT) then
    self.game_type = UBST_CROSS_SCHOOL_FIGHT
  end
  self.rbtn_join.Checked = true
  on_rbtn_join_checked_changed(self.rbtn_join)
  nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule", "send_server_msg", nx_int(CS_REQUEST_FIGHT_INFO), nx_int(self.game_type))
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_join_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule", "send_server_msg", nx_int(CS_REQUEST_ENTER_WAR), nx_int(form.game_type))
end
function close_form()
  if util_is_lockform_visible(FORM_MAIN_NAME) then
    util_auto_show_hide_form_lock(FORM_MAIN_NAME)
  end
end
function on_rbtn_join_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_join.Visible = true
  form.groupbox_war_info.Visible = false
  form.groupbox_price.Visible = false
end
function on_rbtn_war_info_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_join.Visible = false
  form.groupbox_war_info.Visible = true
  form.groupbox_price.Visible = false
end
function on_rbtn_price_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_join.Visible = false
  form.groupbox_war_info.Visible = false
  form.groupbox_price.Visible = true
  refresh_subform_reward()
end
function on_btn_quit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule", "send_server_msg", nx_int(CS_REQUEST_QUIT_WAR))
end
function on_imagegrid_item_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local item_id = grid.DataSource
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_imagegrid_item_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_server_msg(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(STC_ANSWER_FIGHT_INFO_SCHOOL_FIGHT) then
    Update_War_Info(unpack(arg))
  elseif nx_int(sub_msg) == nx_int(STC_SEND_WAR_POINT_INFO) then
    nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_timer_school_fight", "Update_Trace_Info", unpack(arg))
  end
end
function Update_War_Info(...)
  if table.getn(arg) == 0 then
    return
  end
  local gui = nx_value("gui")
  local form = nx_value(FORM_MAIN_NAME)
  if not nx_is_valid(form) then
    return
  end
  local defend_school = arg[1]
  local attack_school = arg[2]
  local defend_player_num = arg[3]
  local attack_player_num = arg[4]
  local fight_result = arg[5]
  local war_time = arg[6]
  form.lbl_26.Text = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(attack_school)))
  form.lbl_25.Text = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(defend_school)))
  form.lbl_24.Text = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(defend_school)))
  form.lbl_fight_school.Text = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(attack_school)))
  form.lbl_defend_school.Text = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(defend_school)))
  form.lbl_fight_players.Text = nx_widestr(attack_player_num)
  form.lbl_defend_players.Text = nx_widestr(defend_player_num)
  form.lbl_fight_address.Text = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(defend_school)))
  local hour, minite = parse_time(war_time)
  form.lbl_fight_time.Text = gui.TextManager:GetFormatText("ui_cross_schoolfight_61", nx_int(hour), nx_int(minite))
  form.lbl_fight_result.Text = nx_widestr(gui.TextManager:GetText("ui_cross_newschool_fight_guj_" .. nx_string(fight_result)))
  local attack_image = image_path .. nx_string(attack_school) .. postfix_name
  local defend_image = image_path .. nx_string(defend_school) .. postfix_name
  local defend_back_image = back_image_path .. nx_string(defend_school) .. postfix_name
  form.lbl_5.BackImage = defend_back_image
  form.lbl_30.BackImage = attack_image
  form.lbl_31.BackImage = defend_image
end
function parse_time(second)
  local hour = nx_int(second / 3600)
  local minite = nx_int((second - hour * 3600) / 60)
  return hour, minite
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function refresh_subform_reward(...)
  local form = nx_value(FORM_MAIN_NAME)
  if not nx_is_valid(form) then
    return false
  end
  for i = 1, 4 do
    for j = 1, 3 do
      local grid_index = (i - 1) * 3 + j
      local grid = nx_custom(form, "imagegrid_" .. nx_string(grid_index))
      local item_id = nx_string(grid.DataSource)
      if nx_is_valid(grid) and item_id ~= "" then
        grid:Clear()
        local photo = item_query_ArtPack_by_id(item_id, "Photo")
        grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
        grid:CoverItem(0, true)
      end
    end
  end
end
