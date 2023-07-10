require("util_gui")
local CLIENT_CUSTOMMSG_GUILD = 1014
local SUB_CUSTOMMSG_REQUEST_HOSTILE_GUILD = 64
local SUB_CUSTOMMSG_REQUEST_CHASE_GUILD = 65
local SUB_CUSTOMMSG_REQUEST_BE_CHASED_INFO = 66
local ENEMY_REC_EMPTY = 0
local ENEMY_REC_FROM_OVER = 1
local ENEMY_REC_TO_OVER = 2
local ENEMY_REC_NORMAL = 3
local col_count = 5
local FORM_NAME = "form_stage_main\\form_guild_war\\form_guild_chase"
local grid_table = {
  [1] = {
    col_width_per = 2,
    col_title = "ui_escort_blackmarket_school"
  },
  [2] = {
    col_width_per = 2,
    col_title = "ui_search_by_level"
  },
  [3] = {
    col_width_per = 2,
    col_title = "ui_domain_rolenum"
  },
  [4] = {
    col_width_per = 2,
    col_title = "ui_guild_chasestate"
  },
  [5] = {
    col_width_per = 2,
    col_title = "ui_guild_chaseinfo"
  }
}
local grid_per_base_num = 10
local chase_tool_table = {
  [1] = {
    drop_text = "GUILD_CHASE_TOOL_06"
  },
  [2] = {
    drop_text = "GUILD_CHASE_TOOL_01"
  },
  [3] = {
    drop_text = "GUILD_CHASE_TOOL_02"
  },
  [4] = {
    drop_text = "GUILD_CHASE_TOOL_03"
  },
  [5] = {
    drop_text = "GUILD_CHASE_TOOL_04"
  },
  [6] = {
    drop_text = "GUILD_CHASE_TOOL_05"
  },
  [7] = {
    drop_text = "GUILD_CHASE_TOOL_07"
  },
  [8] = {
    drop_text = "GUILD_CHASE_TOOL_08"
  },
  [9] = {
    drop_text = "GUILD_CHASE_TOOL_09"
  },
  [10] = {
    drop_text = "GUILD_CHASE_TOOL_10"
  },
  [11] = {
    drop_text = "GUILD_CHASE_TOOL_11"
  }
}
local FORM_WIDTH_INIT = 566
local FORM_WIDTH_WITH_INFO = 846
local ST_FUNCTION_GUILD_CHASE_LEVEL_LIMIT = 695
local table_chase_level_info = {
  [1] = {
    {1},
    1
  },
  [2] = {
    {
      2,
      3,
      4,
      5
    },
    3
  }
}
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  load_chase_level_info(form)
  form.level_limit = false
  init_controls(form)
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  nx_set_value(FORM_NAME, form)
  form.chose_guild = ""
  form.page_no = 1
  form.request_flag = 0
  clear_grid(form)
  request_hostile_guild(1)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.textgrid) then
    local gui = nx_value("gui")
    local grid = form.textgrid
    grid:BeginUpdate()
    if grid.ColCount > 4 then
      for i = 0, grid.RowCount - 1 do
        grid:ClearGridControl(i, 3)
        grid:ClearGridControl(i, 4)
      end
    end
    grid:EndUpdate()
  end
  if form.groupbox_info.Visible == true then
    end_info_count_timer()
  end
  nx_set_value(FORM_NAME, nx_null())
  nx_destroy(form)
end
function on_main_form_shut(form)
end
function on_btn_close_click(btn_close)
  local form = btn_close.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.page_no) <= nx_int(1) then
    return
  end
  form.page_no = form.page_no - 1
  form.request_flag = 2
  request_hostile_guild(form.page_no)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.page_no = form.page_no + 1
  form.request_flag = 1
  request_hostile_guild(form.page_no)
end
function on_btn_chase_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(gui) then
    return
  end
  local toolIndex = form.tool_index
  if toolIndex > table.getn(chase_tool_table) then
    return
  end
  if nx_ws_length(nx_widestr(form.chose_guild)) <= 0 or nx_int(toolIndex) <= nx_int(0) then
    local warning_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local warning_text = nx_widestr(util_text("ui_guild_chase_choose"))
    nx_execute("form_common\\form_confirm", "show_common_text", warning_dialog, nx_widestr(warning_text))
    warning_dialog:ShowModal()
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_guild_chase_confirm", nx_widestr(util_text(nx_string(chase_tool_table[toolIndex].drop_text))), nx_widestr(form.chose_guild)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_CHASE_GUILD), nx_widestr(form.chose_guild), nx_string(chase_tool_table[toolIndex].drop_text))
    form:Close()
  end
end
function on_grid_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local guild_name = nx_widestr(grid:GetGridText(row, 0))
  if 0 >= nx_ws_length(guild_name) then
    return
  end
  if nx_ws_equal(nx_widestr(guild_name), nx_widestr(form.chose_guild)) == true then
    return
  end
  form.chose_guild = guild_name
  if 0 >= nx_ws_length(form.chose_guild) then
    return
  end
  form.lbl_guild_name.Text = guild_name
end
function on_combobox_tool_lvl_selected(self)
  local form = self.ParentForm
  form.tool_index = self.DropListBox.SelectIndex + 1
end
function on_btn_info_click(btn)
  if nx_ws_length(nx_widestr(btn.GuildName)) <= 0 then
    return
  end
  hide_groupbox_info(false)
  request_guild_be_chased_info(btn.GuildName)
end
function on_btn_info_close_click(btn)
  hide_groupbox_info(false)
end
function on_btn_1_get_capture(btn)
  if nx_is_valid(btn) then
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_chase_tips_01")), btn.AbsLeft - 80, btn.AbsTop, 0, btn)
  end
end
function on_btn_1_lost_capture(btn)
  if nx_is_valid(btn) then
    nx_execute("tips_game", "hide_tip", btn)
  end
end
function on_btn_2_get_capture(btn)
  if nx_is_valid(btn) then
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_chase_tips_02")), btn.AbsLeft - 80, btn.AbsTop, 0, btn)
  end
end
function on_btn_2_lost_capture(btn)
  if nx_is_valid(btn) then
    nx_execute("tips_game", "hide_tip", btn)
  end
end
function request_hostile_guild(page_no)
  local from_num = 0
  local to_num = 0
  from_num = (page_no - 1) * 10 + 1
  to_num = page_no * 10
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_HOSTILE_GUILD), nx_int(from_num), nx_int(to_num))
end
function request_guild_be_chased_info(guild_name)
  if nx_ws_length(nx_widestr(guild_name)) <= 0 then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_BE_CHASED_INFO), nx_widestr(guild_name))
end
function on_rec_hostile_guild(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(arg[1]) == nx_int(ENEMY_REC_FROM_OVER) or nx_int(arg[1]) == nx_int(ENEMY_REC_EMPTY) then
    if nx_int(form.request_flag) == nx_int(1) then
      form.page_no = form.page_no - 1
    elseif nx_int(form.request_flag) == nx_int(2) then
      form.page_no = form.page_no + 1
    end
  end
  form.lbl_page.Text = nx_widestr(form.page_no)
  local data_size = table.getn(arg) - 1
  if data_size <= 0 or data_size % 4 ~= 0 then
    return
  end
  clear_grid(form)
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  for i = 1, data_size / 4 do
    local row = grid:InsertRow(-1)
    local temp_index = (i - 1) * 4 + 2
    local guild_name = nx_widestr(arg[temp_index])
    grid:SetGridText(row, 0, nx_widestr(arg[temp_index]))
    temp_index = temp_index + 1
    if nx_int(arg[temp_index]) ~= nx_int(0) then
      grid:SetGridText(row, 1, nx_widestr(util_text(nx_string("ui_sns_number_") .. nx_string(arg[temp_index]))))
    else
      grid:SetGridText(row, 1, nx_widestr(util_text(nx_string("ui_None"))))
    end
    temp_index = temp_index + 1
    grid:SetGridText(row, 2, nx_widestr(arg[temp_index]))
    temp_index = temp_index + 1
    local ctrl = gui:Create("Label")
    if nx_is_valid(ctrl) then
      ctrl.AutoSize = false
      ctrl.Align = "Center"
      ctrl.DrawMode = "FitWindow"
      if nx_int(arg[temp_index]) == nx_int(0) then
        ctrl.BackImage = "gui\\guild\\guildwar\\chase_can.png"
        ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_chase_state_0"))
        ctrl.Transparent = false
      elseif nx_int(arg[temp_index]) == nx_int(1) then
        ctrl.BackImage = "gui\\guild\\guildwar\\chase_cannot.png"
        ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_chase_state_1"))
        ctrl.Transparent = false
      end
      grid:SetGridControl(row, 3, ctrl)
    end
    temp_index = temp_index + 1
    local btn = gui:Create("Button")
    if nx_is_valid(btn) then
      btn.Width = grid:GetColWidth(4)
      btn.Height = grid.RowHeight
      btn.NormalImage = "gui\\common\\button\\btn_normal1_out.png"
      btn.FocusImage = "gui\\common\\button\\btn_normal1_on.png"
      btn.PushImage = "gui\\common\\button\\btn_normal1_down.png"
      btn.DrawMode = "Expand"
      btn.ForeColor = "255, 255, 255, 255"
      btn.Text = nx_widestr(util_text("ui_xiangxixinxi"))
      btn.Align = "Center"
      btn.NoFrame = true
      btn.Solid = false
      btn.Transparent = false
      btn.GuildName = guild_name
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_info_click")
      grid:SetGridControl(row, 4, btn)
    end
  end
  grid:EndUpdate()
end
function on_rec_guild_be_chased_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if table.getn(arg) ~= 2 then
    return
  end
  if form.level_limit then
    form.lbl_chase_count_1.Text = nx_widestr(nx_string(0) .. "/" .. nx_string(1))
    form.lbl_chase_count_2.Text = nx_widestr(nx_string(0) .. "/" .. nx_string(3))
  else
    form.lbl_chase_count_1.Text = nx_widestr(nx_string(arg[1]) .. "/3")
  end
  local main_str = nx_widestr(arg[2])
  local mltbox = form.mltbox_info
  form.mltbox_info.LeftTimeStr = main_str
  form.mltbox_info.HtmlText = nx_widestr("")
  show_groupbox_info()
  refresh_be_chased_info(form)
end
function init_controls(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  local grid_width = grid.Width - 30
  for i = 1, table.getn(grid_table) do
    grid:SetColWidth(i - 1, grid_width / grid_per_base_num * nx_int(grid_table[i].col_width_per))
    grid:SetColTitle(i - 1, nx_widestr(util_text(nx_string(grid_table[i].col_title))))
  end
  grid:EndUpdate()
  form.combobox_tool_lvl.Text = nx_widestr(util_text("ui_qingxuanze"))
  form.combobox_tool_lvl.DropListBox.SelectIndex = -1
  form.tool_index = -1
  for j = 1, table.getn(chase_tool_table) do
    form.combobox_tool_lvl.DropListBox:AddString(nx_widestr(util_text(nx_string(chase_tool_table[j].drop_text))))
  end
  hide_groupbox_info(true)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_CHASE_LEVEL_LIMIT) then
    form.btn_2.Visible = false
    form.lbl_chase_2.Visible = false
    form.lbl_chase_count_2.Visible = false
  else
    form.btn_1.Visible = false
    form.lbl_chase_1.Text = nx_widestr(util_text(nx_string("ui_chase_tips_03")))
    form.lbl_chase_2.Text = nx_widestr(util_text(nx_string("ui_chase_tips_04")))
    form.level_limit = true
  end
end
function show_groupbox_info()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local group_box = form.groupbox_info
  if not nx_is_valid(group_box) then
    return
  end
  group_box.Visible = true
  form.Width = FORM_WIDTH_WITH_INFO
  start_info_count_timer(form)
end
function hide_groupbox_info(init)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local group_box = form.groupbox_info
  if not nx_is_valid(group_box) then
    return
  end
  group_box.Visible = false
  form.Width = FORM_WIDTH_INIT
  if init == true then
    return
  end
  end_info_count_timer()
end
function clear_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid
  grid:BeginUpdate()
  if grid.ColCount > 4 then
    for i = 0, grid.RowCount - 1 do
      grid:ClearGridControl(i, 3)
      grid:ClearGridControl(i, 4)
    end
  end
  grid:ClearRow()
  grid:EndUpdate()
end
function get_format_time(time)
  local time_text = ""
  if nx_number(time) < nx_number(0) then
    return time_text
  end
  local hour = nx_int(time / 3600)
  local minute = nx_int(time % 3600 / 60)
  local second = nx_int(time % 60)
  time_text = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(minute), nx_number(second))
  return time_text
end
function start_info_count_timer()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "refresh_be_chased_info", form, -1, -1)
  end
end
function end_info_count_timer()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_be_chased_info", form)
  end
end
function refresh_be_chased_info(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local group_box = form.groupbox_info
  if not nx_is_valid(group_box) then
    return
  end
  if group_box.Visible == false then
    end_info_count_timer()
    return
  end
  local mltbox = form.mltbox_info
  if not nx_is_valid(mltbox) then
    return
  end
  local main_str = mltbox.LeftTimeStr
  if nx_ws_length(nx_widestr(main_str)) <= 0 then
    end_info_count_timer()
    return
  end
  local show_text = nx_widestr("")
  local new_main_str = ""
  local new_count = 0
  local new_count_1 = 0
  local new_count_2 = 0
  local main_table = util_split_string(nx_string(main_str), "|")
  for i = 1, table.getn(main_table) do
    local sub_table = util_split_string(nx_string(main_table[i]), ",")
    if table.getn(sub_table) == 4 then
      local cur_type = sub_table[1]
      local cur_guild_name = sub_table[2]
      local left_time = nx_number(sub_table[3]) - nx_number(1)
      local guild_level = nx_int(sub_table[4])
      if nx_number(left_time) > nx_number(0) then
        if nx_int(cur_type) == nx_int(0) then
          show_text = show_text .. nx_widestr((gui.TextManager:GetFormatText("ui_chase_left_time", nx_widestr(guild_level), nx_widestr(cur_guild_name))))
          new_count = new_count + 1
          local level_type = get_chase_level_type(form, guild_level)
          if nx_number(level_type) == nx_number(1) then
            new_count_1 = new_count_1 + 1
          elseif nx_number(level_type) == nx_number(2) then
            new_count_2 = new_count_2 + 1
          end
        elseif nx_int(cur_type) == nx_int(1) then
          show_text = show_text .. nx_widestr(util_text("ui_chase_cd_left_time"))
        end
        show_text = show_text .. nx_widestr(get_format_time(nx_number(left_time)))
        show_text = show_text .. nx_widestr("<br>")
        new_main_str = new_main_str .. nx_string(cur_type) .. "," .. nx_string(cur_guild_name) .. "," .. nx_string(left_time) .. "," .. nx_string(guild_level) .. "|"
      end
    end
  end
  mltbox.LeftTimeStr = new_main_str
  if form.level_limit then
    form.lbl_chase_count_1.Text = nx_widestr(nx_string(new_count_1) .. "/" .. nx_string(table_chase_level_info[1][2]))
    form.lbl_chase_count_2.Text = nx_widestr(nx_string(new_count_2) .. "/" .. nx_string(table_chase_level_info[2][2]))
  else
    form.lbl_chase_count_1.Text = nx_widestr(nx_string(new_count) .. "/3")
  end
  mltbox.HtmlText = nx_widestr(show_text)
end
function load_chase_level_info(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildChaseWar.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("config")
  if sec_count < 0 then
    return
  end
  local level_max_info = ini:ReadString(sec_count, "be_chased_level_max", "")
  local table_info = util_split_string(nx_string(level_max_info), ";")
  for i = 1, table.getn(table_info) do
    local level_info = table_info[i]
    local tab_level_info = util_split_string(nx_string(level_info), ",")
    if table.getn(tab_level_info) == 3 then
      local tab_level = util_split_string(nx_string(tab_level_info[1]), "|")
      local level_max = nx_int(tab_level_info[2])
      table_chase_level_info[i] = {tab_level, level_max}
    end
  end
end
function get_chase_level_type(form, guild_level)
  if nx_number(guild_level) <= nx_number(0) then
    return 0
  end
  for i = 1, table.getn(table_chase_level_info) do
    local tab_level_info = table_chase_level_info[i][1]
    for j = 1, table.getn(tab_level_info) do
      if nx_number(guild_level) == nx_number(tab_level_info[j]) then
        return i
      end
    end
  end
  return 0
end
