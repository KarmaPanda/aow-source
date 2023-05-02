require("form_stage_main\\form_die_util")
local ST_FUNCTION_NEW_GUILDWAR = 219
local ST_FUNCTION_GUILD_RELIVE = 241
local GUILDWAR_SIDE_DEFEND = 1
local GUILDWAR_SIDE_ATTACK = 2
local relive_point_table = {
  [1] = {index = 5, warside = 2},
  [2] = {index = 6, warside = 1},
  [3] = {index = 7, warside = 1}
}
function main_form_init(form)
  form.Fixed = false
  form.no_need_motion_alpha = true
  form.received = false
  form.relive_index = -1
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.select_type = RELIVE_TYPE_GUILD
  fresh_relive_form(form)
  init_form(form)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) and switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_RELIVE) then
      form.btn_relive_local.Visible = true
      form.btn_relive_local.Enabled = true
      form.btn_relive_strong.Visible = true
      form.btn_relive_strong.Enabled = true
    else
      form.btn_relive_local.Visible = false
      form.btn_relive_local.Enabled = false
      form.btn_relive_strong.Visible = false
      form.btn_relive_strong.Enabled = false
      form.lbl_ui_revive_choose3.Visible = false
      form.lbl_count.Visible = false
    end
  else
    form.btn_relive_local.Visible = false
    form.btn_relive_local.Enabled = false
    form.btn_relive_strong.Visible = false
    form.btn_relive_strong.Enabled = false
    form.lbl_ui_revive_choose3.Visible = false
    form.lbl_count.Visible = false
  end
  return 1
end
function init_form(form)
  if form.received == true then
    return true
  end
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  for i = 1, UNDERCITY_RELIVE_POINT_COUNT do
    local btn_relive = form.gbox_guild_map:Find("rbtn_relive_" .. i + RELIVE_POINT_COUNT)
    if nx_is_valid(btn_relive) then
      btn_relive.Visible = false
    end
  end
  local player_side = client_player:QueryProp("GuildWarSide")
  for i = 1, UNDERCITY_RELIVE_POINT_COUNT do
    local sub_table = relive_point_table[i]
    local temp_index = sub_table.index
    local temp_warside = sub_table.warside
    if player_side == temp_warside then
      local temp_rbtn = form.gbox_guild_map:Find(nx_string("rbtn_relive_") .. nx_string(i + RELIVE_POINT_COUNT))
      if nx_is_valid(temp_rbtn) then
        temp_rbtn.relive_index = temp_index
        temp_rbtn.Visible = true
        temp_rbtn.Enabled = true
      end
    end
  end
  local rbtn_index = -1
  if player_side == GUILDWAR_SIDE_DEFEND then
    rbtn_index = 6
  else
    rbtn_index = 5
  end
  local btn_relive = form.gbox_guild_map:Find(nx_string("rbtn_relive_") .. nx_string(rbtn_index))
  if not nx_is_valid(btn_relive) then
    return false
  end
  btn_relive.Enabled = true
  btn_relive.Checked = true
  btn_relive.relive_index = nx_int(rbtn_index)
  form.relive_index = nx_int(rbtn_index)
  on_rbtn_relive_get_capture(btn_relive)
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "select_nearest_relivepoint", form)
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("ShowGuildReliveTime", form)
  local ok_dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(ok_dialog) then
    ok_dialog:Close()
  end
  nx_destroy(form)
end
function on_btn_relive_point_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_type = RELIVE_TYPE_GUILD
  fresh_relive_form(form)
end
function on_btn_relive_point_lost_capture(btn)
  local ok_dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(ok_dialog) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_type = RELIVE_TYPE_GUILD
  fresh_relive_form(form)
end
function on_btn_relive_local_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_type = RELIVE_TYPE_LOCAL
  fresh_relive_form(form)
end
function on_btn_relive_local_lost_capture(btn)
  local ok_dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(ok_dialog) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_type = RELIVE_TYPE_GUILD
  fresh_relive_form(form)
end
function on_rbtn_relive_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if self.Checked then
    form.relive_index = self.relive_index
  end
end
function on_rbtn_relive_left_double_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if not nx_is_valid(form) then
    return 0
  end
  form.relive_index = self.relive_index
  if 0 > nx_number(self.relive_index) then
    form.lbl_relive_name.Text = gui.TextManager:GetText("ui_guild_war_map_fuhuodian_nochoose")
    return 0
  end
  if not show_ok_dialog(RELIVE_TYPE_GUILD, nx_int(0), nx_number(self.relive_index)) then
    return 0
  end
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_GUILD, nx_int(0), nx_number(self.relive_index))
end
function on_btn_relive_point_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if not nx_is_valid(form) then
    return 0
  end
  local cur_relive_index = form.relive_index
  if 0 > nx_number(cur_relive_index) then
    form.lbl_relive_name.Text = gui.TextManager:GetText("ui_guild_war_map_fuhuodian_nochoose")
    return 0
  end
  if not show_ok_dialog(RELIVE_TYPE_GUILD, nx_int(0), nx_number(cur_relive_index)) then
    return 0
  end
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_GUILD, nx_int(0), nx_number(cur_relive_index))
end
function on_btn_relive_local_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local relive_type = RELIVE_TYPE_LOCAL
  if not show_ok_dialog(relive_type, nx_int(0)) then
    return 0
  end
  nx_execute("custom_sender", "custom_relive", relive_type, nx_int(0))
end
function on_btn_relive_strong_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local relive_type = RELIVE_TYPE_LOCAL_STRONG
  if not show_ok_dialog(relive_type, nx_int(0)) then
    return 0
  end
  nx_execute("custom_sender", "custom_relive", relive_type, nx_int(0))
end
function select_nearest_relivepoint(form)
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_GUILD, nx_int(0), nx_int(-1))
end
function on_rbtn_relive_get_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
end
function on_rbtn_relive_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  if nx_number(form.relive_index) ~= -1 then
    form.lbl_relive_name.Text = gui.TextManager:GetText("ui_guild_war_relivepoint_name_10")
    form.lbl_relive_state.Text = gui.TextManager:GetText("ui_guild_war_relivepoint_state_1")
  else
    form.lbl_relive_name.Text = nx_widestr("")
    form.lbl_relive_state.Text = nx_widestr("")
  end
end
function show_guild_war_relive_form(relivepoints)
  local gui = nx_value("gui")
  local form = nx_execute("util_gui", "util_get_form", FORM_DIE_UNDERCITY_GUILDWAR, true)
  if not nx_is_valid(form) then
    return 0
  end
  form.relive_index = -1
  form.received = true
  for i = 1, UNDERCITY_RELIVE_POINT_COUNT do
    local btn_relive = form.gbox_guild_map:Find("rbtn_relive_" .. i + RELIVE_POINT_COUNT)
    if nx_is_valid(btn_relive) then
      btn_relive.Visible = false
    end
  end
  local relivepoint_tab = util_split_string(relivepoints, "/")
  local length = table.getn(relivepoint_tab)
  local click_first = true
  for i = 1, length do
    local data_tab = util_split_string(relivepoint_tab[i], ",")
    if table.getn(data_tab) == 2 then
      local relive_index = data_tab[1]
      local btn_relive = form.gbox_guild_map:Find("rbtn_relive_" .. nx_string(relive_index))
      if nx_is_valid(btn_relive) then
        btn_relive.relive_index = nx_int(relive_index)
        btn_relive.Visible = true
        btn_relive.Enabled = true
        if click_first == true and btn_relive.Enabled == true then
          btn_relive.Checked = true
          click_first = false
          form.relive_index = btn_relive.relive_index
          on_rbtn_relive_lost_capture(btn_relive)
        end
      end
    end
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if nx_is_valid(player) then
    local relive_count = player:QueryProp("ReliveCount")
    form.lbl_count.Text = gui.TextManager:GetFormatText("ui_fuhuo_already", nx_int(relive_count))
  end
  nx_execute("util_gui", "util_show_form", FORM_DIE_UNDERCITY_GUILDWAR, true)
  local common_execute = nx_value("common_execute")
  common_execute:AddExecute("ShowGuildReliveTime", form, nx_float(1), "ui_fuhuo_time_near", nx_float(AUTO_RELIVE_TIME))
  local timer = nx_value("timer_game")
  timer:Register(AUTO_RELIVE_TIME * 1000, 1, nx_current(), "select_nearest_relivepoint", form, -1, -1)
end
function show_ok_dialog(relive_type, is_fight, relive_index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relive_ok", true, false)
  dialog.mltbox_info:Clear()
  dialog.mltbox_money_info:Clear()
  local relive_name = ""
  if nx_int(relive_type) == nx_int(RELIVE_TYPE_GUILD) then
    relive_name = gui.TextManager:GetText("ui_guild_war_relivepoint_name_" .. nx_string(relive_index))
  end
  is_fight = 0
  dialog.mltbox_info:AddHtmlText(nx_widestr(get_confirm_info(relive_type, is_fight, relive_name)), -1)
  local capital_type, capital_num = get_confirm_menoy(relive_type)
  if capital_type == nil or capital_num == nil then
    dialog.mltbox_money_info.Text = ""
  elseif nx_int(capital_type) == nx_int(1) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_suiyin", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  elseif nx_int(capital_type) == nx_int(2) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_yb", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  end
  if relive_type == RELIVE_TYPE_LOCAL or relive_type == RELIVE_TYPE_LOCAL_STRONG then
    local relive_count = player:QueryProp("ReliveCount")
    dialog.lbl_remain_count.Text = nx_widestr(gui.TextManager:GetFormatText("ui_fuhuo_already", nx_int(relive_count)))
  else
    dialog.lbl_remain_count.Visible = false
  end
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return false
  end
  return true
end
function fresh_relive_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_load = nx_value("form_common\\form_loading")
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(form)
  else
    gui.Desktop:ToFront(form)
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local capital_type = 0
  local money = 0
  capital_type, money = nx_execute("form_stage_main\\form_die_util", "get_confirm_menoy", RELIVE_TYPE_LOCAL)
  if nx_int(capital_type) ~= nx_int(0) and nx_int(money) > nx_int(0) then
    if check_is_enough_money(capital_type, money) or check_is_enough_money(CAPITAL_TYPE_SILVER_CARD, money) then
      form.btn_relive_local.Enabled = true
    else
      form.btn_relive_local.Enabled = false
    end
  end
  capital_type, money = nx_execute("form_stage_main\\form_die_util", "get_confirm_menoy", RELIVE_TYPE_LOCAL_STRONG)
  if nx_int(capital_type) ~= nx_int(0) and nx_int(money) > nx_int(0) then
    if check_is_enough_money(capital_type, money) then
      form.btn_relive_strong.Enabled = true
    else
      form.btn_relive_strong.Enabled = false
    end
  end
  local relive_count = player:QueryProp("DailyReliveCount")
  if nx_int(relive_count) >= nx_int(MAX_RELIVE_COUNT_DAILY) then
    form.btn_relive_strong.Enabled = false
    form.btn_relive_local.Enabled = false
    local count_str = gui.TextManager:GetFormatText("ui_revive_max", nx_int(relive_count))
    form.lbl_count.Text = nx_widestr(count_str)
  else
    local left_count = nx_int(MAX_RELIVE_COUNT_DAILY) - nx_int(relive_count)
    local count_str = gui.TextManager:GetFormatText("ui_revive_count", nx_int(left_count))
    form.lbl_count.Text = nx_widestr(count_str)
  end
end
function image_moving(obj, end_Left, end_Top)
  if not nx_is_valid(obj) then
    return
  end
  if false == obj.Visible then
    return
  end
  if nx_number(obj.Left) == nx_number(end_Left) and nx_number(obj.Top) == nx_number(end_Top) then
    return
  end
  local obj_x = obj.Left
  local obj_y = obj.Top
  local dis_x = end_Left - obj.Left
  local dis_y = end_Top - obj.Top
  for i = 1, MOV_FPS do
    nx_pause(0.01)
    if not nx_is_valid(obj) then
      return
    end
    local move_x = nx_int(nx_float(dis_x / MOV_FPS) * i)
    local move_y = nx_int(nx_float(dis_y / MOV_FPS) * i)
    obj.Left = obj_x + move_x
    obj.Top = obj_y + move_y
  end
  obj.Left = nx_number(end_Left)
  obj.Top = nx_number(end_Top)
end
function syn_image_moving(obj, end_Left, end_Top)
  nx_execute(nx_current(), "image_moving", obj, end_Left, end_Top)
end
function get_buff_photo(buff_id)
  if buff_id == "" or buff_id == nil then
    return ""
  end
  local buff_data_ini = nx_execute("util_functions", "get_ini", "share\\Skill\\buff_new.ini")
  if not nx_is_valid(buff_data_ini) then
    return ""
  end
  local sec_index = buff_data_ini:FindSectionIndex(buff_id)
  if sec_index < 0 then
    return
  end
  local buffer_num = buff_data_ini:ReadString(sec_index, "StaticData", "")
  if buffer_num == "" then
    return
  end
  local buff_static_ini = nx_execute("util_functions", "get_ini", "share\\Skill\\buff_static.ini")
  if not nx_is_valid(buff_static_ini) then
    return ""
  end
  local sec_index_num = buff_static_ini:FindSectionIndex(buffer_num)
  if sec_index_num < 0 then
    return ""
  end
  local buff_photo = buff_static_ini:ReadString(sec_index_num, "Photo", "")
  return buff_photo
end
