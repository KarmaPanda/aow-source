require("util_gui")
local FRIEND_REC = "rec_friend"
local BUDDY_REC = "rec_buddy"
local FRIEND_REC_NAME = 1
local FRIEND_REC_ONLINE = 8
local OFFLINE_STATE_ONLINE = 0
local OFFLINE_STATE_NONE = -1
local BATTLEFIELD_RESULT_ARRAY_INFO = "battlefield_result_array"
local BATTLEFIELD_RESULT_INFO_COUNT = 10
local FORM_BATTLEFIELD_RESULT = "form_stage_main\\form_battlefield\\form_battlefield_result"
local BATTLEFIELD_RESULT_TYPE_SIDE = 0
local BATTLEFIELD_RESULT_TYPE_DEAD = 1
local BATTLEFIELD_RESULT_TYPE_WRESTLE = 2
local CLIENT_SUBMSG_REQUEST_LOOK = 3
local BATTLEFIELD_INI_PATH = "ini\\ui\\battlefield\\tvt_battlefield.ini"
local KARMA_GROUP_INI_PATH = "share\\Karma\\Groupkarma_pack.ini"
local BATTLEFIELD_RULE_INI_PATH = "share\\War\\battlefield_rule.ini"
local weapon_type_table = {
  "weapontype100",
  "weapontype101",
  "weapontype102",
  "weapontype103",
  "weapontype104",
  "weapontype105",
  "weapontype106",
  "weapontype108",
  "weapontype107",
  "weapontype109",
  "weapontype110"
}
local GRID_TEXT_COLOR = "255,179,139,114"
function main_form_init(form)
  form.Fixed = false
  form.ini = nx_execute("util_functions", "get_ini", BATTLEFIELD_INI_PATH)
  if not nx_is_valid(form.ini) then
    return
  end
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return 1
  end
  if not client_role:FindProp("Name") then
    return 1
  end
  local player_name = nx_widestr(client_role:QueryProp("Name"))
  form.combobox_friend.InputEdit.Text = nx_widestr(player_name)
  local grid = form.textgrid_battle_info
  grid:ClearRow()
  grid.ColCount = 9
  grid:SetColWidth(0, 92)
  grid:SetColWidth(1, 26)
  grid:SetColWidth(2, 42)
  grid:SetColWidth(3, 22)
  grid:SetColWidth(4, 42)
  grid:SetColWidth(5, 22)
  grid:SetColWidth(6, 42)
  grid:SetColWidth(7, 22)
  grid:SetColWidth(8, 96)
  grid.RowHeight = 23
  form.rbtn_two_side.Checked = true
  form.lbl_kill_mizong.Visible = false
  form.lbl_desc_kill_mizong.Visible = false
  form.pbar_side.Maximum = 3000
  form.pbar_side.Value = 0
  form.pbar_dead.Maximum = 3000
  form.pbar_dead.Value = 0
  form.pbar_wrestle.Maximum = 3000
  form.pbar_wrestle.Value = 0
  form.ani_connect.Visible = true
  form.ani_connect.PlayMode = 2
  form.lbl_connect.Visible = true
  form.groupbox_dead.Visible = false
  form.groupbox_wrestle.Visible = false
  form.lbl_battle_all_score.Visible = false
  form.lbl_score_all.Visible = false
  form.rbtn_wrestle_mode.Visible = false
  form.rbtn_dead_mode.Visible = false
end
function main_form_close(form)
  nx_destroy(form)
end
function on_btn_query_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local player_name = form.combobox_friend.InputEdit.Text
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_LOOK, player_name)
  form.ani_connect.Visible = true
  form.ani_connect.PlayMode = 2
  form.lbl_connect.Visible = true
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function on_btn_battle_ranging_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if nx_is_valid(rang_form) then
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_7_BatType1")
  end
end
function on_btn_help_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "jhqb,jianghuzd02,wodezhanchang03,zhanchangjl04")
end
function on_pbar_side_get_capture(pbr)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("tips_battle_MaxScore")
  gui.TextManager:Format_AddParam(nx_int(pbr.Value))
  local text = nx_widestr(gui.TextManager:Format_GetText())
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, pbr.ParentForm)
end
function on_pbar_side_lost_capture(pbr)
  nx_execute("tips_game", "hide_tip", pbr.ParentForm)
end
function on_pbar_dead_get_capture(pbr)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("tips_battle_MaxScore")
  gui.TextManager:Format_AddParam(nx_int(pbr.Value))
  local text = nx_widestr(gui.TextManager:Format_GetText())
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, pbr.ParentForm)
end
function on_pbar_dead_lost_capture(pbr)
  nx_execute("tips_game", "hide_tip", pbr.ParentForm)
end
function on_pbar_wrestle_get_capture(pbr)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("tips_battle_MaxScore")
  gui.TextManager:Format_AddParam(nx_int(pbr.Value))
  local text = nx_widestr(gui.TextManager:Format_GetText())
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, pbr.ParentForm)
end
function on_pbar_wrestle_lost_capture(pbr)
  nx_execute("tips_game", "hide_tip", pbr.ParentForm)
end
function update_battlefield_result(...)
  local form = util_get_form(FORM_BATTLEFIELD_RESULT, true)
  if not nx_is_valid(form) then
    return
  end
  local param_count = table.getn(arg)
  if param_count < 8 then
    return 0
  end
  local score_all = nx_int(arg[1]) + nx_int(arg[2]) + nx_int(arg[3])
  form.lbl_score_all.Text = nx_widestr(nx_int(score_all))
  form.lbl_score_side.Text = nx_widestr(nx_int(arg[1]))
  form.lbl_score_dead.Text = nx_widestr(nx_int(arg[2]))
  form.lbl_score_wrestle.Text = nx_widestr(nx_int(arg[3]))
  form.lbl_count_kill.Text = nx_widestr(nx_int(arg[4]))
  form.lbl_count_win.Text = nx_widestr(nx_int(arg[5]))
  form.lbl_count_join.Text = nx_widestr(nx_int(arg[6]))
  form.lbl_count_succeed_wrestle.Text = nx_widestr(nx_int(arg[7]))
  form.rbtn_two_side.Checked = true
  refresh_pbar(form, arg[8], arg[1], arg[2], arg[3])
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_battle_result")
  gui.TextManager:Format_AddParam(form.combobox_friend.InputEdit.Text)
  form.lbl_result.Text = gui.TextManager:Format_GetText()
  refresh_friend_combobox(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  for i = 1, BATTLEFIELD_RESULT_INFO_COUNT do
    local array_name = BATTLEFIELD_RESULT_ARRAY_INFO .. nx_string(i)
    common_array:RemoveArray(array_name)
  end
  local grid = form.textgrid_battle_info
  grid:ClearRow()
  local battle_index = nx_int((param_count - 8) / 17)
  for i = 0, BATTLEFIELD_RESULT_INFO_COUNT - 1 do
    local msg_index = 8 + i * 18
    if param_count <= msg_index then
      break
    end
    local array_name = BATTLEFIELD_RESULT_ARRAY_INFO .. nx_string(i + 1)
    common_array:AddArray(array_name, form, 600, true)
    common_array:AddChild(array_name, "battle_name", nx_string(arg[msg_index + 1]))
    common_array:AddChild(array_name, "battle_time", nx_double(arg[msg_index + 2]))
    common_array:AddChild(array_name, "battle_type", nx_int(arg[msg_index + 3]))
    common_array:AddChild(array_name, "battle_is_win", nx_int(arg[msg_index + 4]))
    common_array:AddChild(array_name, "battle_sort", nx_int(arg[msg_index + 5]))
    common_array:AddChild(array_name, "battle_score", nx_int(arg[msg_index + 6]))
    common_array:AddChild(array_name, "battle_live_point", nx_int(arg[msg_index + 7]))
    common_array:AddChild(array_name, "battle_kill_count", nx_int(arg[msg_index + 8]))
    common_array:AddChild(array_name, "battle_dead_count", nx_int(arg[msg_index + 9]))
    common_array:AddChild(array_name, "battle_queue_kill", nx_int(arg[msg_index + 10]))
    common_array:AddChild(array_name, "battle_max_equip", nx_int(arg[msg_index + 11]))
    common_array:AddChild(array_name, "battle_max_skill", nx_string(arg[msg_index + 12]))
    common_array:AddChild(array_name, "battle_boss_count", nx_int(arg[msg_index + 13]))
    common_array:AddChild(array_name, "battle_duration", nx_int(arg[msg_index + 14]))
    common_array:AddChild(array_name, "battle_karma_id", nx_int(arg[msg_index + 15]))
    common_array:AddChild(array_name, "battle_karma_val", nx_int(arg[msg_index + 16]))
    common_array:AddChild(array_name, "battle_money", nx_int(arg[msg_index + 17]))
    common_array:AddChild(array_name, "battle_help_kill", nx_int(arg[msg_index + 18]))
  end
  refresh_battlefield_grid(form.textgrid_battle_info, BATTLEFIELD_RESULT_TYPE_SIDE)
  form.ani_connect.Visible = false
  form.ani_connect.PlayMode = 0
  form.lbl_connect.Visible = false
  util_show_form(FORM_BATTLEFIELD_RESULT, true)
end
function refresh_pbar(form, client_level, side_bf_level, dead_bf_level, wrestle_bf_level)
  local level_rule_ini = nx_execute("util_functions", "get_ini", BATTLEFIELD_RULE_INI_PATH)
  if not nx_is_valid(level_rule_ini) then
    return
  end
  local sec_index = level_rule_ini:FindSectionIndex("houselevels")
  if sec_index < 0 then
    return
  end
  local pbar_max = 3000
  local r_count = level_rule_ini:GetSectionItemCount(sec_index)
  for i = r_count, 1, -1 do
    local r_string = level_rule_ini:ReadString(sec_index, "r" .. i, "")
    local str_lst = util_split_string(r_string, ",")
    if table.getn(str_lst) >= 5 then
      local power_level = nx_int(str_lst[2])
      local level_max = nx_int(str_lst[5])
      if power_level >= nx_int(client_level) then
        pbar_max = level_max
      end
    end
  end
  if nx_int(0) == pbar_max then
    pbar_max = 1000000
  end
  if nx_int(side_bf_level) > nx_int(pbar_max) then
    pbar_max = side_bf_level
  end
  if nx_int(dead_bf_level) > nx_int(pbar_max) then
    pbar_max = dead_bf_level
  end
  if nx_int(wrestle_bf_level) > nx_int(pbar_max) then
    pbar_max = wrestle_bf_level
  end
  form.pbar_side.Maximum = pbar_max
  form.pbar_side.Value = side_bf_level
  form.pbar_dead.Maximum = pbar_max
  form.pbar_dead.Value = dead_bf_level
  form.pbar_wrestle.Maximum = pbar_max
  form.pbar_wrestle.Value = wrestle_bf_level
end
function refresh_friend_combobox(form)
  if not nx_is_valid(form) then
    return
  end
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  if not client_role:FindProp("Name") then
    return
  end
  local player_name = nx_widestr(client_role:QueryProp("Name"))
  form.combobox_friend.OnlySelect = true
  form.combobox_friend.DropListBox.SelectIndex = 0
  form.combobox_friend.DropListBox:ClearString()
  form.combobox_friend.DropListBox:AddString(player_name)
  if client_role:FindProp("PartnerNamePrivate") then
    local parent_name = client_role:QueryProp("PartnerNamePrivate")
    if not nx_ws_equal(nx_widestr(""), parent_name) then
      form.combobox_friend.DropListBox:AddString(parent_name)
    end
  end
  get_combobox_list(form.combobox_friend, client_role, FRIEND_REC)
  get_combobox_list(form.combobox_friend, client_role, BUDDY_REC)
end
function get_combobox_list(combobox, player, table_name)
  if not nx_is_valid(combobox) then
    return
  end
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return
  end
  for i = 0, rows - 1 do
    local friend_name = nx_widestr(player:QueryRecord(table_name, i, FRIEND_REC_NAME))
    local friend_offline_state = nx_int(player:QueryRecord(table_name, i, FRIEND_REC_ONLINE))
    if nx_int(OFFLINE_STATE_ONLINE) == friend_offline_state then
      combobox.DropListBox:AddString(friend_name)
    end
  end
end
function refresh_battlefield_grid(grid, battle_type)
  if not nx_is_valid(grid) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local gui = nx_value("gui")
  grid:ClearRow()
  grid:ClearSelect()
  for i = 1, BATTLEFIELD_RESULT_INFO_COUNT do
    local array_name = BATTLEFIELD_RESULT_ARRAY_INFO .. nx_string(i)
    if common_array:FindArray(array_name) then
      local battleType = common_array:FindChild(nx_string(array_name), "battle_type")
      if battleType == battle_type then
        local row = grid:InsertRow(-1)
        grid:SetGridForeColor(row, 2, GRID_TEXT_COLOR)
        grid:SetGridForeColor(row, 3, GRID_TEXT_COLOR)
        grid:SetGridForeColor(row, 4, GRID_TEXT_COLOR)
        grid:SetGridForeColor(row, 5, GRID_TEXT_COLOR)
        grid:SetGridForeColor(row, 6, GRID_TEXT_COLOR)
        grid:SetGridForeColor(row, 7, GRID_TEXT_COLOR)
        grid:SetGridForeColor(row, 8, GRID_TEXT_COLOR)
        grid:SetRowTitle(row, nx_widestr(i))
        local battleName = common_array:FindChild(nx_string(array_name), "battle_name")
        if nx_is_valid(form.ini) then
          local sec_index = get_mapid_section_index(form.ini, battleName, battle_type)
          if 0 <= sec_index then
            battleName = form.ini:ReadString(sec_index, "name", "")
          end
        end
        grid:SetGridText(row, 0, gui.TextManager:GetText(battleName))
        local is_win = common_array:FindChild(nx_string(array_name), "battle_is_win")
        if 2 == is_win then
          local lbl = gui:Create("Label")
          lbl.BackImage = "gui\\language\\ChineseS\\battlefield\\win.png"
          lbl.DrawMode = "FitWindow"
          lbl.Align = "Center"
          grid:SetGridControl(row, 1, lbl)
        end
        if BATTLEFIELD_RESULT_TYPE_WRESTLE == battle_type then
          grid:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText("ui_battle_wrestle_succeed")))
        else
          grid:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText("ui_battle_killenemy")))
        end
        grid:SetGridText(row, 3, nx_widestr(common_array:FindChild(nx_string(array_name), "battle_kill_count")))
        if BATTLEFIELD_RESULT_TYPE_DEAD ~= battle_type then
          grid:SetGridText(row, 4, nx_widestr(gui.TextManager:GetText("ui_battle_help")))
          grid:SetGridText(row, 5, nx_widestr(common_array:FindChild(nx_string(array_name), "battle_help_kill")))
        end
        if BATTLEFIELD_RESULT_TYPE_WRESTLE ~= battle_type then
          grid:SetGridText(row, 6, nx_widestr(gui.TextManager:GetText("ui_battle_dead")))
          grid:SetGridText(row, 7, nx_widestr(common_array:FindChild(nx_string(array_name), "battle_dead_count")))
        end
        local year, month, day = nx_function("ext_decode_date", common_array:FindChild(nx_string(array_name), "battle_time"))
        year = year or 1970
        month = month or 1
        day = day or 1
        grid:SetGridText(row, 8, nx_widestr(year .. "." .. month .. "." .. day))
      end
    end
  end
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_two_side.Checked then
    refresh_this_battle(form, 0)
    refresh_battlefield_grid(form.textgrid_battle_info, BATTLEFIELD_RESULT_TYPE_SIDE)
    form.lbl_kill_mizong.Visible = false
    form.lbl_desc_kill_mizong.Visible = false
    form.lbl_karma_id.Visible = true
    form.lbl_desc_karma_id.Visible = true
    form.lbl_karma_val.Visible = true
    form.lbl_desc_karma_val.Visible = true
    form.lbl_max_hit.Visible = true
    form.lbl_desc_max_hit.Visible = true
    form.lbl_wrestle_succeed.Visible = false
    form.lbl_wrestle_help.Visible = false
    form.lbl_desc_wrestle_succeed.Visible = false
    form.lbl_desc_wrestle_help.Visible = false
  elseif form.rbtn_dead_mode.Checked then
    refresh_this_battle(form, 0)
    refresh_battlefield_grid(form.textgrid_battle_info, BATTLEFIELD_RESULT_TYPE_DEAD)
    form.lbl_kill_mizong.Visible = true
    form.lbl_desc_kill_mizong.Visible = true
    form.lbl_karma_id.Visible = false
    form.lbl_desc_karma_id.Visible = false
    form.lbl_karma_val.Visible = false
    form.lbl_desc_karma_val.Visible = false
    form.lbl_max_hit.Visible = true
    form.lbl_desc_max_hit.Visible = true
    form.lbl_wrestle_succeed.Visible = false
    form.lbl_wrestle_help.Visible = false
    form.lbl_desc_wrestle_succeed.Visible = false
    form.lbl_desc_wrestle_help.Visible = false
  elseif form.rbtn_wrestle_mode.Checked then
    refresh_this_battle(form, 0)
    refresh_battlefield_grid(form.textgrid_battle_info, BATTLEFIELD_RESULT_TYPE_WRESTLE)
    form.lbl_kill_mizong.Visible = false
    form.lbl_desc_kill_mizong.Visible = false
    form.lbl_karma_id.Visible = false
    form.lbl_desc_karma_id.Visible = false
    form.lbl_karma_val.Visible = false
    form.lbl_desc_karma_val.Visible = false
    form.lbl_max_hit.Visible = false
    form.lbl_desc_max_hit.Visible = false
    form.lbl_wrestle_succeed.Visible = true
    form.lbl_wrestle_help.Visible = true
    form.lbl_desc_wrestle_succeed.Visible = true
    form.lbl_desc_wrestle_help.Visible = true
  end
end
function on_textgrid_battle_info_select_row(grid, row)
  local form = grid.ParentForm
  local str_battle_index = nx_string(grid:GetRowTitle(row))
  refresh_this_battle(form, str_battle_index)
end
function refresh_this_battle(form, battle_index)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.lbl_desc_this_score.Text = nx_widestr("")
  form.lbl_desc_this_money.Text = nx_widestr("")
  form.lbl_desc_kill_mizong.Text = nx_widestr("")
  form.lbl_desc_max_hit.Text = nx_widestr("")
  form.lbl_desc_fre_skill.Text = nx_widestr("")
  form.lbl_desc_fre_weapon.Text = nx_widestr("")
  form.lbl_desc_duration.Text = nx_widestr("")
  form.lbl_desc_karma_id.Text = nx_widestr("")
  form.lbl_desc_karma_val.Text = nx_widestr("")
  form.lbl_desc_wrestle_succeed.Text = nx_widestr("")
  form.lbl_desc_wrestle_help.Text = nx_widestr("")
  local array_name = BATTLEFIELD_RESULT_ARRAY_INFO .. battle_index
  if common_array:FindArray(array_name) then
    form.lbl_desc_this_score.Text = nx_widestr(common_array:FindChild(nx_string(array_name), "battle_score"))
    form.lbl_desc_this_money.Text = nx_widestr(common_array:FindChild(nx_string(array_name), "battle_money"))
    form.lbl_desc_kill_mizong.Text = nx_widestr(common_array:FindChild(nx_string(array_name), "battle_boss_count"))
    form.lbl_desc_max_hit.Text = nx_widestr(common_array:FindChild(nx_string(array_name), "battle_queue_kill"))
    form.lbl_desc_wrestle_succeed.Text = nx_widestr(common_array:FindChild(nx_string(array_name), "battle_kill_count"))
    form.lbl_desc_wrestle_help.Text = nx_widestr(common_array:FindChild(nx_string(array_name), "battle_help_kill"))
    local taolu_id = common_array:FindChild(nx_string(array_name), "battle_max_skill")
    local str_taolu = ""
    if taolu_id ~= "" then
      gui.TextManager:Format_SetIDName(taolu_id)
      gui.TextManager:Format_AddParam("255,221,209,197")
      str_taolu = gui.TextManager:Format_GetText()
    end
    form.lbl_desc_fre_skill.Text = str_taolu
    local weaponType = common_array:FindChild(nx_string(array_name), "battle_max_equip")
    if 99 < weaponType and weaponType < 111 then
      form.lbl_desc_fre_weapon.Text = gui.TextManager:GetText(weapon_type_table[weaponType - 99])
    end
    local all_second = common_array:FindChild(nx_string(array_name), "battle_duration")
    local time_minute = nx_int(all_second / 60)
    local time_second = all_second % 60
    local str_time = nx_widestr("")
    if time_minute > nx_int(0) then
      str_time = str_time .. nx_widestr(time_minute) .. gui.TextManager:GetText("ui_minute")
    end
    if 0 < time_second then
      str_time = str_time .. nx_widestr(time_second) .. gui.TextManager:GetText("ui_seconds")
    end
    form.lbl_desc_duration.Text = str_time
    local karma_id = common_array:FindChild(nx_string(array_name), "battle_karma_id")
    if 0 < karma_id then
      form.lbl_desc_karma_id.Text = gui.TextManager:GetText("group_karma_" .. nx_string(karma_id))
      form.lbl_desc_karma_val.Text = nx_widestr(common_array:FindChild(nx_string(array_name), "battle_karma_val"))
    end
  end
end
function get_mapid_section_index(ini, map_id, rule_type)
  if not nx_is_valid(ini) then
    return
  end
  local section_count = ini:GetSectionCount()
  for i = 1, section_count do
    local sec_index = i - 1
    local id = ini:ReadString(sec_index, "map_id", "")
    local rule = ini:ReadInteger(sec_index, "rule", "")
    if id == map_id and rule_type == rule then
      return sec_index
    end
  end
  return -1
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_RESULT, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
