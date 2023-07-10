require("util_gui")
require("custom_sender")
require("share\\chat_define")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
s_zq_table = {}
s_hq_table = {}
ZQ_PLAYER_REC = "ZhengqiPlayerRecord"
HQ_PLAYER_REC = "HaoqiPlayerRecord"
PI_DEFEND = 1
PI_ATTACK = 2
local ST_FUNCTION_SCHOOL_FIGHT = 925
local ST_FUNCTION_CROSS_SCHOOL_FIGHT = 926
CTS_LEAVE_WAR = 1
CTS_REQUEST_DATA = 2
CTS_REQUEST_SGUILD_DATA = 4
PIRC_PLAYER_UID = 0
PIRC_SERVER_NAME = 1
PIRC_GUILD_NAME = 2
PIRC_SCHOOL_ID = 3
PIRC_PLAYER_NAME = 4
PIRC_KILL_NUM = 5
PIRC_BE_KILL_NUM = 6
PIRC_HELP_KILL_NUM = 7
PIRC_DAMAGE = 8
PIRC_INTEGRAL = 9
single_col_count = 9
interval_time = 10000
local CS_REQUEST_QUIT_WAR = 2
local CTS_REQUEST_GAME_DATA = 3
local FORM_NAME = "form_stage_main\\form_new_war_rule\\form_new_war_rule_score_school_fight"
function main_form_init(form)
  form.Fixed = false
end
function open_form()
  util_auto_show_hide_form(FORM_NAME)
end
function on_main_form_open(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width * 2 + form.lbl_11.Width) / 2
    form.Top = (gui.Height - form.Height * 2 + form.lbl_11.Height) / 2
  end
  s_hq_table = {}
  s_zq_table = {}
  form.s_hq_last_time = 0
  form.s_zq_last_time = 0
  form.select_type = SINGLE_TYPE
  refresh_rbtn(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_quit_click(btn)
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText("ui_smzb_sj025")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), -1)
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog.relogin_btn.Visible = false
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule", "send_server_msg", nx_int(CS_REQUEST_QUIT_WAR))
    form:Close()
  end
end
function on_rbtn_hq_click(btn)
  form = btn.ParentForm
  local grid = form.grid_single
  grid:ClearRow()
  hq_logic(form)
end
function on_rbtn_zq_click(btn)
  form = btn.ParentForm
  local grid = form.grid_single
  grid:ClearRow()
  zq_logic(form)
end
function hq_logic(form)
  local cur_time = get_server_time()
  form.lbl_count.Visible = true
  if form.select_type == SINGLE_TYPE then
    form.lbl_12.Visible = true
    form.single_box.Visible = true
    local sur_time = cur_time - form.s_hq_last_time
    if sur_time > interval_time then
      nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule", "send_server_msg", nx_int(CTS_REQUEST_GAME_DATA), nx_int(form.select_type), nx_int(PI_DEFEND))
      form.s_hq_last_time = cur_time
    else
      refresh_single_data(unpack(s_hq_table))
    end
  end
end
function zq_logic(form)
  local cur_time = get_server_time()
  form.lbl_count.Visible = true
  if form.select_type == SINGLE_TYPE then
    form.lbl_12.Visible = true
    form.single_box.Visible = true
    local sur_time = cur_time - form.s_zq_last_time
    if sur_time > interval_time then
      nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule", "send_server_msg", nx_int(CTS_REQUEST_GAME_DATA), nx_int(form.select_type), nx_int(PI_ATTACK))
      form.s_zq_last_time = cur_time
    else
      refresh_single_data(unpack(s_zq_table))
    end
  end
end
function refresh_single_data(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_hq.Checked == true then
    s_hq_table = arg
    refresh_single_rec(unpack(arg))
  elseif form.rbtn_zq.Checked == true then
    s_zq_table = arg
    refresh_single_rec(unpack(arg))
  end
end
function refresh_single_rec(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  local is_open = switch_manager:CheckSwitchEnable(ST_FUNCTION_SCHOOL_FIGHT) or switch_manager:CheckSwitchEnable(ST_FUNCTION_CROSS_SCHOOL_FIGHT)
  local temp_table = arg
  if nx_number(table.getn(temp_table)) < nx_number(2) then
    return
  end
  local rows = temp_table[1]
  local row = temp_table[2]
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  local gui = nx_value("gui")
  local grid = form.grid_single
  grid:ClearRow()
  local size = nx_number(table.getn(temp_table)) / nx_number(single_col_count)
  local index = 1
  if nx_number(row) ~= nx_number(-1) then
    if is_open == true then
      form.s_serial.Text = nx_widestr("--")
    else
      form.s_serial.Text = nx_widestr(row + 1)
    end
    form.s_server_name.Text = nx_widestr(temp_table[PIRC_SERVER_NAME])
    if nx_widestr("") == temp_table[PIRC_GUILD_NAME] then
      form.s_guild_name.Text = nx_widestr("--")
    else
      form.s_guild_name.Text = nx_widestr(temp_table[PIRC_GUILD_NAME])
    end
    form.s_player_name.Text = nx_widestr(temp_table[PIRC_PLAYER_NAME])
    form.s_school_name.Text = nx_widestr(gui.TextManager:GetText(temp_table[PIRC_SCHOOL_ID]))
    form.s_kill_num.Text = nx_widestr(temp_table[PIRC_KILL_NUM])
    form.s_be_kill_num.Text = nx_widestr(temp_table[PIRC_BE_KILL_NUM])
    form.s_help_kill_num.Text = nx_widestr(temp_table[PIRC_HELP_KILL_NUM])
    form.s_damage.Text = nx_widestr(temp_table[PIRC_DAMAGE])
    local integral = temp_table[PIRC_INTEGRAL]
    if nx_number(integral) == nx_number(0) then
      integral = "--"
    end
    form.s_integral.Text = nx_widestr(integral)
    index = index + 1
  else
    form.s_serial.Text = nx_widestr("--")
    form.s_server_name.Text = nx_widestr("--")
    form.s_guild_name.Text = nx_widestr("--")
    form.s_player_name.Text = nx_widestr("--")
    form.s_school_name.Text = nx_widestr("--")
    form.s_kill_num.Text = nx_widestr("--")
    form.s_be_kill_num.Text = nx_widestr("--")
    form.s_help_kill_num.Text = nx_widestr("--")
    form.s_damage.Text = nx_widestr("--")
    form.s_integral.Text = nx_widestr("--")
  end
  form.lbl_12.Visible = true
  form.lbl_count.Visible = true
  form.lbl_count.Text = nx_widestr(rows)
  for i = index, size do
    local server_name = nx_widestr(temp_table[(i - 1) * single_col_count + PIRC_SERVER_NAME])
    local guild_name = nx_widestr(temp_table[(i - 1) * single_col_count + PIRC_GUILD_NAME])
    if nx_widestr(guild_name) == nx_widestr("") then
      guild_name = nx_widestr("--")
    end
    local player_name = nx_widestr(temp_table[(i - 1) * single_col_count + PIRC_PLAYER_NAME])
    local school_name = nx_widestr(gui.TextManager:GetText(temp_table[(i - 1) * single_col_count + PIRC_SCHOOL_ID]))
    local kill_num = nx_widestr(temp_table[(i - 1) * single_col_count + PIRC_KILL_NUM])
    local be_kill_num = nx_widestr(temp_table[(i - 1) * single_col_count + PIRC_BE_KILL_NUM])
    local help_kill_num = nx_widestr(temp_table[(i - 1) * single_col_count + PIRC_HELP_KILL_NUM])
    local damage = nx_widestr(temp_table[(i - 1) * single_col_count + PIRC_DAMAGE])
    local integral = nx_widestr(temp_table[(i - 1) * single_col_count + PIRC_INTEGRAL])
    if nx_number(integral) == nx_number(0) then
      integral = "--"
    end
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(row + 1))
    grid:SetGridText(row, 1, nx_widestr(server_name))
    grid:SetGridText(row, 2, nx_widestr(guild_name))
    grid:SetGridText(row, 3, nx_widestr(school_name))
    grid:SetGridText(row, 4, nx_widestr(player_name))
    grid:SetGridText(row, 5, nx_widestr(kill_num))
    grid:SetGridText(row, 6, nx_widestr(be_kill_num))
    grid:SetGridText(row, 7, nx_widestr(help_kill_num))
    grid:SetGridText(row, 8, nx_widestr(damage))
    grid:SetGridText(row, 9, nx_widestr(integral))
  end
end
function get_server_time()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return 0
  end
  return msg_delay:GetServerNowTime()
end
function get_join_power()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  return client_player:QueryProp("JoinPower")
end
function refresh_rbtn(form)
  if get_join_power() == PI_DEFEND then
    form.rbtn_hq.Checked = true
    on_rbtn_hq_click(form.rbtn_hq)
  elseif get_join_power() == PI_ATTACK then
    form.rbtn_zq.Checked = true
    on_rbtn_zq_click(form.rbtn_zq)
  end
end
