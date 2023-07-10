require("util_gui")
require("custom_sender")
require("share\\chat_define")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
s_yq_table = {}
s_zq_table = {}
s_hq_table = {}
g_yq_table = {}
g_zq_table = {}
g_hq_table = {}
sg_table = {}
ZQ_PLAYER_REC = "ZhengqiPlayerRecord"
HQ_PLAYER_REC = "HaoqiPlayerRecord"
YQ_PLAYER_REC = "YiqiPlayerRecord"
ZQ_GUILD_REC = "ZhengqiGuildRecord"
HQ_GUILD_REC = "HaoqiGuildRecord"
YQ_GUILD_REC = "YiqiGuildRecord"
PI_YQ = 3
PI_ZQ = 1
PI_HQ = 2
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
GIRC_OLD_SERVER_ID = 0
GIRC_SERVER_NAME = 1
GIRC_GUILD_NAME = 2
GIRC_TOTAL_KILL_NUM = 3
GIRC_INTEGRAL = 4
SGIRC_SERVER_NAME = 1
SGIRC_GUILD_NAME = 2
SGIRC_KILL_NUM = 3
SGIRC_BEKILL_NUM = 4
single_col_count = 9
guild_col_count = 4
sguild_col_count = 4
SINGLE_TYPE = 0
GUILD_TYPE = 1
interval_time = 10000
local CROSS_DATA_DEFAULT = -1
local CROSS_DATA_MAIN_TYPE_SINGLE = 1
local CROSS_DATA_MAIN_TYPE_GUILD = 2
local CROSS_DATA_MAIN_TYPE_MY_GUILD = 3
local CROSS_DATA_MAIN_TYPE_MAX = 4
local CROSS_DATA_SUB_TYPE_TIAN_QI = 3
local CROSS_DATA_SUB_TYPE_TIAN_WEI = 1
local CROSS_DATA_SUB_TYPE_TIAN_WU = 2
local CROSS_DATA_SUB_TYPE_MY_GUILD = 3
local CROSS_DATA_SUB_TYPE_MAX = 4
local TRUMPET_COMMON_TEXT = {
  "system_cross_trumpet_item_5",
  "ui_cross_trumpet_confirm"
}
local BST_SANMENG = 1
local BST_GUILD_UNION = 2
local FORM_NAME = "form_stage_main\\form_match\\form_sanmeng_score"
function main_form_init(form)
  form.Fixed = false
  form.trumpet_main_type = CROSS_DATA_DEFAULT
  form.trumpet_sub_type = CROSS_DATA_DEFAULT
  form.trumpet_data_1 = ""
  form.trumpet_data_2 = ""
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
  s_yq_table = {}
  s_zq_table = {}
  s_hq_table = {}
  g_yq_table = {}
  g_zq_table = {}
  g_hq_table = {}
  sg_table = {}
  form.s_yq_last_time = 0
  form.s_zq_last_time = 0
  form.s_hq_last_time = 0
  form.g_yq_last_time = 0
  form.g_zq_last_time = 0
  form.g_hq_last_time = 0
  form.sg_last_time = 0
  form.select_type = SINGLE_TYPE
  form.btn_single.Visible = false
  form.btn_guild.Visible = true
  form.rbtn_sguild.Visible = false
  local sub_type = client_player:QueryProp("BattleSubType")
  if sub_type == BST_GUILD_UNION then
    form.rbtn_yq.Visible = false
  end
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
    custom_match_sanmeng(CTS_LEAVE_WAR)
    form:Close()
  end
end
function on_btn_single_click(btn)
  form = btn.ParentForm
  form.select_type = SINGLE_TYPE
  form.btn_single.Visible = false
  form.btn_guild.Visible = true
  form.rbtn_sguild.Visible = false
  refresh_rbtn(form)
end
function on_btn_guild_click(btn)
  form = btn.ParentForm
  form.select_type = GUILD_TYPE
  form.btn_single.Visible = true
  form.btn_guild.Visible = false
  form.rbtn_sguild.Visible = true
  refresh_rbtn(form)
end
function on_rbtn_hq_click(btn)
  form = btn.ParentForm
  local grid = form.grid_single
  grid:ClearRow()
  grid = form.grid_guild
  grid:ClearRow()
  grid = form.grid_sguild
  grid:ClearRow()
  hq_logic(form)
  form.trumpet_sub_type = CROSS_DATA_SUB_TYPE_TIAN_WU
end
function on_rbtn_zq_click(btn)
  form = btn.ParentForm
  local grid = form.grid_single
  grid:ClearRow()
  grid = form.grid_guild
  grid:ClearRow()
  grid = form.grid_sguild
  grid:ClearRow()
  zq_logic(form)
  form.trumpet_sub_type = CROSS_DATA_SUB_TYPE_TIAN_WEI
end
function on_rbtn_yq_click(btn)
  form = btn.ParentForm
  local grid = form.grid_single
  grid:ClearRow()
  grid = form.grid_guild
  grid:ClearRow()
  grid = form.grid_sguild
  grid:ClearRow()
  yq_logic(form)
  form.trumpet_sub_type = CROSS_DATA_SUB_TYPE_TIAN_QI
end
function on_rbtn_sguild_click(btn)
  local form = btn.ParentForm
  local grid = form.grid_single
  grid:ClearRow()
  grid = form.grid_guild
  grid:ClearRow()
  grid = form.grid_sguild
  grid:ClearRow()
  local cur_time = get_server_time()
  form.lbl_12.Visible = false
  form.lbl_16.Visible = false
  form.lbl_count.Visible = false
  form.single_box.Visible = false
  form.guild_box.Visible = false
  form.sguild_box.Visible = true
  local sur_time = cur_time - form.sg_last_time
  if sur_time > interval_time then
    custom_match_sanmeng(CTS_REQUEST_SGUILD_DATA)
    form.sg_last_time = cur_time
  else
    refresh_sguild_data(unpack(sg_table))
  end
end
function hq_logic(form)
  local cur_time = get_server_time()
  form.lbl_count.Visible = true
  if form.select_type == SINGLE_TYPE then
    form.lbl_12.Visible = true
    form.lbl_16.Visible = false
    form.single_box.Visible = true
    form.guild_box.Visible = false
    form.sguild_box.Visible = false
    local sur_time = cur_time - form.s_hq_last_time
    if sur_time > interval_time then
      custom_match_sanmeng(CTS_REQUEST_DATA, form.select_type, PI_HQ)
      form.s_hq_last_time = cur_time
    else
      refresh_single_data(unpack(s_hq_table))
    end
  elseif form.select_type == GUILD_TYPE then
    form.lbl_12.Visible = false
    form.lbl_16.Visible = true
    form.single_box.Visible = false
    form.guild_box.Visible = true
    form.sguild_box.Visible = false
    local sur_time = cur_time - form.g_hq_last_time
    if sur_time > interval_time then
      custom_match_sanmeng(CTS_REQUEST_DATA, form.select_type, PI_HQ)
      form.g_hq_last_time = cur_time
    else
      refresh_guild_data(unpack(g_hq_table))
    end
  end
end
function zq_logic(form)
  local cur_time = get_server_time()
  form.lbl_count.Visible = true
  if form.select_type == SINGLE_TYPE then
    form.lbl_12.Visible = true
    form.lbl_16.Visible = false
    form.single_box.Visible = true
    form.guild_box.Visible = false
    form.sguild_box.Visible = false
    local sur_time = cur_time - form.s_zq_last_time
    if sur_time > interval_time then
      custom_match_sanmeng(CTS_REQUEST_DATA, form.select_type, PI_ZQ)
      form.s_zq_last_time = cur_time
    else
      refresh_single_data(unpack(s_zq_table))
    end
  elseif form.select_type == GUILD_TYPE then
    form.lbl_12.Visible = false
    form.lbl_16.Visible = true
    form.single_box.Visible = false
    form.guild_box.Visible = true
    form.sguild_box.Visible = false
    local sur_time = cur_time - form.g_zq_last_time
    if sur_time > interval_time then
      custom_match_sanmeng(CTS_REQUEST_DATA, form.select_type, PI_ZQ)
      form.g_zq_last_time = cur_time
    else
      refresh_guild_data(unpack(g_zq_table))
    end
  end
end
function yq_logic(form)
  local cur_time = get_server_time()
  form.lbl_count.Visible = true
  if form.select_type == SINGLE_TYPE then
    form.lbl_12.Visible = true
    form.lbl_16.Visible = false
    form.single_box.Visible = true
    form.guild_box.Visible = false
    form.sguild_box.Visible = false
    local sur_time = cur_time - form.s_yq_last_time
    if sur_time > interval_time then
      custom_match_sanmeng(CTS_REQUEST_DATA, form.select_type, PI_YQ)
      form.s_yq_last_time = cur_time
    else
      refresh_single_data(unpack(s_yq_table))
    end
  elseif form.select_type == GUILD_TYPE then
    form.lbl_12.Visible = false
    form.lbl_16.Visible = true
    form.single_box.Visible = false
    form.guild_box.Visible = true
    form.sguild_box.Visible = false
    local sur_time = cur_time - form.g_yq_last_time
    if sur_time > interval_time then
      custom_match_sanmeng(CTS_REQUEST_DATA, form.select_type, PI_YQ)
      form.g_yq_last_time = cur_time
    else
      refresh_guild_data(unpack(g_yq_table))
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
  elseif form.rbtn_yq.Checked == true then
    s_yq_table = arg
    refresh_single_rec(unpack(arg))
  end
end
function refresh_guild_data(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_hq.Checked == true then
    g_hq_table = arg
    refresh_guild_rec(unpack(arg))
  elseif form.rbtn_zq.Checked == true then
    g_zq_table = arg
    refresh_guild_rec(unpack(arg))
  elseif form.rbtn_yq.Checked == true then
    g_yq_table = arg
    refresh_guild_rec(unpack(arg))
  end
end
function refresh_selfguild_data(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  sg_table = arg
  refresh_sguild_data(unpack(arg))
end
function refresh_single_rec(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  local is_open = switch_manager:CheckSwitchEnable(ST_FUNCTION_SANMENG_REQUEST_DATA)
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
function refresh_guild_rec(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  local is_open = switch_manager:CheckSwitchEnable(ST_FUNCTION_SANMENG_REQUEST_DATA)
  local temp_table = arg
  if nx_number(table.getn(temp_table)) < nx_number(2) then
    return
  end
  local rows = temp_table[1]
  local row = temp_table[2]
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  local grid = form.grid_guild
  grid:ClearRow()
  local size = nx_number(table.getn(temp_table)) / nx_number(guild_col_count)
  local index = 1
  if nx_number(row) ~= nx_number(-1) then
    if is_open == true then
      form.g_serial.Text = nx_widestr("--")
    else
      form.g_serial.Text = nx_widestr(row + 1)
    end
    if nx_widestr("") == temp_table[GIRC_GUILD_NAME] then
      form.g_guild_name.Text = nx_widestr("--")
    else
      form.g_guild_name.Text = nx_widestr(temp_table[GIRC_GUILD_NAME])
    end
    form.g_kill_num.Text = nx_widestr(temp_table[GIRC_TOTAL_KILL_NUM])
    local integral = temp_table[GIRC_INTEGRAL]
    if nx_number(integral) == nx_number(0) then
      integral = "--"
    end
    form.g_integral.Text = nx_widestr(integral)
    index = index + 1
  else
    form.g_serial.Text = nx_widestr("--")
    form.g_server_name.Text = nx_widestr("--")
    form.g_guild_name.Text = nx_widestr("--")
    form.g_kill_num.Text = nx_widestr("--")
    form.g_integral.Text = nx_widestr("--")
  end
  form.lbl_count.Text = nx_widestr(rows)
  for i = index, size do
    local server_name = nx_widestr(temp_table[(i - 1) * guild_col_count + GIRC_SERVER_NAME])
    local guild_name = nx_widestr(temp_table[(i - 1) * guild_col_count + GIRC_GUILD_NAME])
    if nx_widestr(guild_name) == nx_widestr("") then
      guild_name = nx_widestr("--")
    end
    local kill_num = nx_widestr(temp_table[(i - 1) * guild_col_count + GIRC_TOTAL_KILL_NUM])
    local integral = nx_widestr(temp_table[(i - 1) * guild_col_count + GIRC_INTEGRAL])
    if nx_number(integral) == nx_number(0) then
      integral = "--"
    end
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(row + 1))
    grid:SetGridText(row, 1, nx_widestr(server_name))
    grid:SetGridText(row, 2, nx_widestr(guild_name))
    grid:SetGridText(row, 3, nx_widestr(kill_num))
    grid:SetGridText(row, 4, nx_widestr(integral))
  end
end
function refresh_sguild_data(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local temp_table = arg
  if nx_number(table.getn(temp_table)) == nx_number(0) then
    return
  end
  local grid = form.grid_sguild
  grid:ClearRow()
  local size = nx_number(table.getn(temp_table)) / nx_number(sguild_col_count)
  for i = 1, size do
    local server_name = nx_widestr(temp_table[(i - 1) * sguild_col_count + SGIRC_SERVER_NAME])
    local guild_name = nx_widestr(temp_table[(i - 1) * sguild_col_count + SGIRC_GUILD_NAME])
    local kill_num = nx_widestr(temp_table[(i - 1) * sguild_col_count + SGIRC_KILL_NUM])
    local be_kill_num = nx_widestr(temp_table[(i - 1) * sguild_col_count + SGIRC_BEKILL_NUM])
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(row + 1))
    grid:SetGridText(row, 1, nx_widestr(server_name))
    grid:SetGridText(row, 2, nx_widestr(guild_name))
    grid:SetGridText(row, 3, nx_widestr(kill_num))
    grid:SetGridText(row, 4, nx_widestr(be_kill_num))
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
  if get_join_power() == PI_YQ then
    form.rbtn_yq.Checked = true
    on_rbtn_yq_click(form.rbtn_yq)
  elseif get_join_power() == PI_ZQ then
    form.rbtn_zq.Checked = true
    on_rbtn_zq_click(form.rbtn_zq)
  elseif get_join_power() == PI_HQ then
    form.rbtn_hq.Checked = true
    on_rbtn_hq_click(form.rbtn_hq)
  end
end
function on_grid_sanmeng_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local cur_row = -1
  cur_row = row
  if cur_row < 0 then
    return
  end
  if nx_string(grid.Name) == nx_string("grid_single") then
    form.trumpet_main_type = CROSS_DATA_MAIN_TYPE_SINGLE
    form.trumpet_data_1 = form.grid_single:GetGridText(cur_row, 1)
    form.trumpet_data_2 = form.grid_single:GetGridText(cur_row, 4)
    form.grid_guild:ClearSelect()
    form.grid_sguild:ClearSelect()
  elseif nx_string(grid.Name) == nx_string("grid_guild") then
    form.trumpet_main_type = CROSS_DATA_MAIN_TYPE_GUILD
    form.trumpet_data_1 = form.grid_guild:GetGridText(cur_row, 1)
    form.trumpet_data_2 = form.grid_guild:GetGridText(cur_row, 2)
    form.grid_single:ClearSelect()
    form.grid_sguild:ClearSelect()
  elseif nx_string(grid.Name) == nx_string("grid_sguild") then
    form.trumpet_main_type = CROSS_DATA_MAIN_TYPE_MY_GUILD
    form.trumpet_sub_type = CROSS_DATA_SUB_TYPE_MY_GUILD
    form.trumpet_data_1 = form.grid_sguild:GetGridText(cur_row, 1)
    form.trumpet_data_2 = form.grid_sguild:GetGridText(cur_row, 2)
    form.grid_single:ClearSelect()
    form.grid_guild:ClearSelect()
  else
    form.trumpet_main_type = CROSS_DATA_DEFAULT
    form.trumpet_sub_type = CROSS_DATA_DEFAULT
    form.trumpet_data_1 = ""
    form.trumpet_data_2 = ""
    form.grid_single:ClearSelect()
    form.grid_guild:ClearSelect()
    form.grid_sguild:ClearSelect()
  end
end
function on_btn_cross_speaker_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "trumpet_main_type") or not nx_find_custom(form, "trumpet_sub_type") then
    return
  end
  local main_type = nx_int(form.trumpet_main_type)
  local sub_type = nx_int(form.trumpet_sub_type)
  if main_type <= nx_int(0) or main_type >= nx_int(CROSS_DATA_MAIN_TYPE_MAX) or sub_type < nx_int(0) or sub_type >= nx_int(CROSS_DATA_SUB_TYPE_MAX) then
    return
  end
  if not nx_find_custom(form, "trumpet_data_1") or not nx_find_custom(form, "trumpet_data_2") then
    return
  end
  local data1 = nx_widestr(form.trumpet_data_1)
  local data2 = nx_widestr(form.trumpet_data_2)
  if data1 == "" or data2 == "" then
    return
  end
  if main_type == nx_int(CROSS_DATA_MAIN_TYPE_MY_GUILD) then
    nx_execute("custom_sender", "custom_get_cross_speaker_data", main_type, data1, data2)
    return
  end
  nx_execute("custom_sender", "custom_get_cross_speaker_data", main_type, sub_type, data1, data2)
end
function on_cross_trumpet_server_msg(...)
  local msg_count = nx_int(table.getn(arg))
  if msg_count ~= nx_int(6) and msg_count ~= nx_int(7) and msg_count ~= nx_int(8) then
    return
  end
  local main_type = nx_int(arg[1])
  local chat_str = ""
  local repeat_cnt = 1
  if main_type == nx_int(CROSS_DATA_MAIN_TYPE_SINGLE) and msg_count == nx_int(7) then
    local damage = get_damage(arg[7])
    chat_str = util_format_string("ui_fuzhan_001_a", nx_widestr(arg[2]), nx_widestr(arg[3]), nx_int(arg[4]), nx_int(arg[5]), nx_int(arg[6]), nx_widestr(damage))
  elseif main_type == nx_int(CROSS_DATA_MAIN_TYPE_SINGLE) and msg_count == nx_int(8) then
    local damage = get_damage(arg[8])
    chat_str = util_format_string("ui_fuzhan_001", nx_widestr(arg[2]), nx_widestr(arg[3]), nx_widestr(arg[4]), nx_int(arg[5]), nx_int(arg[6]), nx_int(arg[7]), nx_widestr(damage))
  elseif main_type == nx_int(CROSS_DATA_MAIN_TYPE_GUILD) and msg_count == nx_int(6) then
    local sanmeng_name = get_sanmeng_name(arg[2])
    chat_str = util_format_string("ui_fuzhan_002", nx_widestr(sanmeng_name), nx_widestr(arg[3]), nx_widestr(arg[4]), nx_int(arg[5]), nx_int(arg[6]))
  elseif main_type == nx_int(CROSS_DATA_MAIN_TYPE_MY_GUILD) and msg_count == nx_int(7) then
    chat_str = util_format_string("ui_fuzhan_003", nx_widestr(arg[2]), nx_widestr(arg[3]), nx_widestr(arg[4]), nx_widestr(arg[5]), nx_widestr(arg[4]), nx_int(arg[6]), nx_int(arg[7]))
  else
    return
  end
  local res = confirm_send_cross_server_trumpet(repeat_cnt)
  if res then
    nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, chat_str, repeat_cnt, "", 2)
  end
end
function get_sanmeng_name(index)
  local sanmeng_index = nx_int(index)
  if sanmeng_index == nx_int(CROSS_DATA_SUB_TYPE_TIAN_QI) then
    return util_text("ui_sanmeng_tianqi")
  elseif sanmeng_index == nx_int(CROSS_DATA_SUB_TYPE_TIAN_WEI) then
    return util_text("ui_sanmeng_tianwei")
  elseif sanmeng_index == nx_int(CROSS_DATA_SUB_TYPE_TIAN_WU) then
    return util_text("ui_sanmeng_tianwu")
  else
    return ""
  end
end
function get_damage(num)
  local damage = nx_int(num)
  if damage >= nx_int(0) and damage < nx_int(10000) then
    return nx_widestr(damage)
  elseif damage == nx_int(10000) then
    local temp_text = util_text("ui_wan")
    return nx_widestr("1") .. temp_text
  elseif damage > nx_int(10000) then
    local wan_num = nx_int(damage / 10000)
    local temp_num = nx_int(math.mod(nx_number(damage), 10000))
    local temp_num2 = nx_int((temp_num + 50) / 100)
    local temp_text = util_text("ui_wan")
    return nx_widestr(wan_num) .. nx_widestr(".") .. nx_widestr(temp_num2) .. temp_text
  else
    return nx_widestr("")
  end
end
function confirm_send_cross_server_trumpet(repeat_cnt)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return false
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return false
  end
  local count_1 = goods_grid:GetItemCount("item_laba_battlefield_bind")
  local count_2 = goods_grid:GetItemCount("item_laba_battlefield")
  if count_1 + count_2 == 0 then
    SystemCenterInfo:ShowSystemCenterInfo(util_text(TRUMPET_COMMON_TEXT[1]), 2)
    return false
  end
  if 0 < count_1 + count_2 then
    local dialog = util_get_form("form_common\\form_confirm", true, false, "sanmeng_data_cross_item")
    if nx_is_valid(dialog) then
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_format_string(TRUMPET_COMMON_TEXT[2], nx_int(repeat_cnt)))
      dialog:ShowModal()
      local rv = nx_wait_event(100000000, dialog, "confirm_return")
      if "ok" == rv then
        return true
      end
    end
  end
  return false
end
