require("util_gui")
require("custom_sender")
local level_table = {
  [1] = "ui_sns_number_1",
  [2] = "ui_sns_number_2",
  [3] = "ui_sns_number_3",
  [4] = "ui_sns_number_4",
  [5] = "ui_sns_number_5"
}
local school_table = {
  [1] = {
    text = "ui_stall_xuhao",
    index_text = "",
    pic = ""
  },
  [2] = {
    text = "ui_shaolinlft",
    index_text = "shaolin",
    pic = "gui\\language\\ChineseS\\shengwang\\sl.png"
  },
  [3] = {
    text = "ui_wudangyqt",
    index_text = "wudang",
    pic = "gui\\language\\ChineseS\\shengwang\\wd.png"
  },
  [4] = {
    text = "ui_emeixjt",
    index_text = "emei",
    pic = "gui\\language\\ChineseS\\shengwang\\em.png"
  },
  [5] = {
    text = "ui_gaibang",
    index_text = "gaibang",
    pic = "gui\\language\\ChineseS\\shengwang\\gb.png"
  },
  [6] = {
    text = "ui_tangmen",
    index_text = "tangmen",
    pic = "gui\\language\\ChineseS\\shengwang\\tm.png"
  },
  [7] = {
    text = "ui_junzitang",
    index_text = "junzitang",
    pic = "gui\\language\\ChineseS\\shengwang\\jz.png"
  },
  [8] = {
    text = "ui_jinyiwei",
    index_text = "jinyiwei",
    pic = "gui\\language\\ChineseS\\shengwang\\jy.png"
  },
  [9] = {
    text = "ui_jilegu",
    index_text = "jilegu",
    pic = "gui\\language\\ChineseS\\shengwang\\jl.png"
  }
}
local level_title_table = {
  [1] = "ui_stall_xuhao",
  [2] = "desc_title001",
  [3] = "desc_title002",
  [4] = "desc_title003",
  [5] = "desc_title004",
  [6] = "desc_title005",
  [7] = "desc_title006",
  [8] = "desc_title007",
  [9] = "desc_title008",
  [10] = "desc_title009",
  [11] = "desc_title010",
  [12] = "desc_title011",
  [13] = "desc_title012",
  [14] = "desc_title013",
  [15] = "desc_title014",
  [16] = "desc_title015"
}
local grid_table = {
  [1] = {col_width_per = 3},
  [2] = {col_width_per = 1},
  [3] = {col_width_per = 1},
  [4] = {col_width_per = 2},
  [5] = {col_width_per = 1},
  [6] = {col_width_per = 2},
  [7] = {col_width_per = 2},
  [8] = {col_width_per = 1},
  [9] = {col_width_per = 1},
  [10] = {col_width_per = 1},
  [11] = {col_width_per = 1},
  [12] = {col_width_per = 1},
  [13] = {col_width_per = 1},
  [14] = {col_width_per = 1},
  [15] = {col_width_per = 1}
}
local grid_per_base_num = 20
local grid_col_btn_count = 8
local GUILD_MIN_LEVEL = 1
local GUILD_MAX_LEVEL = 5
local ABILITY_POWER_MAX_INDEX = 15
local CLIENT_CUSTOMMSG_GUILD = 1014
local SUB_CUSTOMMSG_SEARCH_GUILD_BY_FILTER = 52
local SUB_CUSTOMMSG_SEARCH_GUILD = 53
local SUB_CUSTOMMSG_GET_GUILD_SIMPLE_INFO = 54
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.filter_name = ""
  form.filter_power = nx_int(ABILITY_POWER_MAX_INDEX)
  form.filter_school = ""
  form.filter_from_level = nx_int(GUILD_MIN_LEVEL)
  form.filter_to_level = nx_int(GUILD_MAX_LEVEL)
  form.chose_guild = ""
  form.page_no = nx_int(1)
  form.rbtn_index = 0
  form.next_page_clicked = false
  form.sort_index = nx_int(1)
  init_controls(form)
  clear_grid(form)
  request_guild(form)
  start_timer(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_main_form_shut(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_filter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  start_timer(form)
  form.page_no = nx_int(1)
  form.sort_index = nx_int(1)
  clear_grid(form)
  request_info(form)
end
function on_grid_guild_select_row(grid, row)
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
  form.mltbox_purpose.HtmlText = nx_widestr("")
  form.guild_logo_frame.Image = ""
  form.guild_logo.Image = ""
  form.groupbox_color.BackColor = "0,0,0,0"
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GET_GUILD_SIMPLE_INFO), nx_widestr(form.chose_guild))
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked ~= true then
    return
  end
  if rbtn.tab_index == 0 then
    form.rbtn_index = 0
    refresh_form_after_tabed(form, form.rbtn_index)
  elseif rbtn.tab_index == 1 then
    form.rbtn_index = 1
    refresh_form_after_tabed(form, form.rbtn_index)
  end
end
function on_btn_sort_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.sort_index = btn.sort_index
  form.page_no = nx_int(1)
  clear_grid(form)
  start_timer(form)
  request_guild_by_filter(form)
end
function on_btn_from_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.page_no) <= nx_int(1) then
    btn.Enabled = false
    return
  end
  form.page_no = nx_int(form.page_no - 1)
  if nx_int(form.page_no) <= nx_int(1) then
    btn.Enabled = false
  end
  clear_grid(form)
  start_timer(form)
  request_info(form)
end
function on_btn_to_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.page_no = nx_int(form.page_no + 1)
  form.btn_from.Enabled = true
  form.next_page_clicked = true
  clear_grid(form)
  start_timer(form)
  request_info(form)
end
function on_btn_join_guild_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_ws_length(nx_widestr(form.chose_guild)) <= 0 then
    local warn_dlg = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(gui.TextManager:GetFormatText("ui_guild_nc"))
    nx_execute("form_common\\form_confirm", "show_common_text", warn_dlg, nx_widestr(text))
    warn_dlg:ShowModal()
    return
  end
  if is_in_guild() == true then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_int(form.rbtn_index) == nx_int(0) then
    local text = nx_widestr(gui.TextManager:GetFormatText("ui_guild_join_confirm", nx_widestr(form.chose_guild)))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_request_join_guild(form.chose_guild)
    end
  elseif nx_int(form.rbtn_index) == nx_int(1) then
    local text = nx_widestr(gui.TextManager:GetFormatText("ui_guild_respond_confirm", nx_widestr(form.chose_guild)))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_request_respond_guild(0, form.chose_guild)
    end
  end
end
function on_btn_cancel_respond_click(btn)
  custom_request_respond_guild(1, "")
end
function init_controls(form)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_join.tab_index = 0
  form.rbtn_respond.tab_index = 1
  form.lbl_4.Visible = false
  form.lbl_5.Visible = false
  form.btn_cancel_respond.Visible = false
  for i = 1, grid_col_btn_count do
    local btn_sort = form:Find("btn_sort_" .. nx_string(i))
    if nx_is_valid(btn_sort) then
      btn_sort.sort_index = i
    end
  end
  form.combobox_power.Text = nx_widestr(util_text("ui_stall_xuhao"))
  for i = 1, table.getn(level_title_table) do
    form.combobox_power.DropListBox:AddString(nx_widestr(util_text(nx_string(level_title_table[i]))))
  end
  form.combobox_school.Text = nx_widestr(util_text("ui_stall_xuhao"))
  for i = 1, table.getn(school_table) do
    form.combobox_school.DropListBox:AddString(nx_widestr(util_text(nx_string(school_table[i].text))))
  end
  form.combobox_from_level.Text = nx_widestr(util_text("ui_stall_xuhao"))
  for i = 1, table.getn(level_table) do
    form.combobox_from_level.DropListBox:AddString(nx_widestr(util_text(nx_string(level_table[i]))))
  end
  form.combobox_to_level.Text = nx_widestr(util_text("ui_stall_xuhao"))
  for i = 1, table.getn(level_table) do
    form.combobox_to_level.DropListBox:AddString(nx_widestr(util_text(nx_string(level_table[i]))))
  end
  local grid = form.grid_guild
  grid:BeginUpdate()
  local grid_width = grid.Width - 30
  for i = 1, table.getn(grid_table) do
    grid:SetColWidth(i - 1, grid_width / grid_per_base_num * nx_int(grid_table[i].col_width_per))
  end
  grid:EndUpdate()
end
function refresh_form_after_tabed(form, rbtn_index)
  if not nx_is_valid(form) then
    return
  end
  form.chose_guild = nx_widestr("")
  form.lbl_guild_name.Text = nx_widestr(form.chose_guild)
  form.mltbox_purpose.HtmlText = nx_widestr("")
  form.guild_logo_frame.Image = ""
  form.guild_logo.Image = ""
  form.groupbox_color.BackColor = "0,0,0,0"
  form.ipt_guild_name.Text = nx_widestr("")
  form.btn_from.Enabled = false
  form.btn_to.Enabled = false
  form.combobox_power.DropListBox.SelectIndex = -1
  form.combobox_power.Text = nx_widestr(util_text("ui_stall_xuhao"))
  form.combobox_school.DropListBox.SelectIndex = -1
  form.combobox_school.Text = nx_widestr(util_text("ui_stall_xuhao"))
  form.page_no = nx_int(1)
  form.next_page_clicked = false
  clear_grid(form)
  if nx_int(rbtn_index) == nx_int(0) then
    form.btn_join_guild.Text = nx_widestr(util_text("ui_guild_request_join"))
    form.combobox_from_level.Enabled = true
    form.combobox_to_level.Enabled = true
    form.btn_sort_2.Enabled = true
    form.btn_sort_5.Enabled = true
    form.btn_cancel_respond.Visible = false
  elseif nx_int(rbtn_index) == nx_int(1) then
    form.btn_join_guild.Text = nx_widestr(util_text("ui_guild_respond"))
    form.combobox_from_level.Enabled = false
    form.combobox_to_level.Enabled = false
    form.btn_sort_2.Enabled = false
    form.btn_sort_5.Enabled = false
    form.btn_cancel_respond.Visible = true
  end
  start_timer(form)
  request_guild_by_filter(form)
end
function request_info(form)
  if not nx_is_valid(form) then
    return
  end
  if is_need_filter(form) == false and form.rbtn_index == 0 then
    request_guild(form)
  else
    request_guild_by_filter(form)
  end
end
function is_need_filter(form)
  if not nx_is_valid(form) then
    return
  end
  local need_filter = false
  form.filter_name = form.ipt_guild_name.Text
  if nx_ws_length(form.filter_name) > 0 then
    need_filter = true
    return need_filter
  end
  local select_index = form.combobox_power.DropListBox.SelectIndex
  if 0 < select_index then
    need_filter = true
    return need_filter
  end
  select_index = form.combobox_school.DropListBox.SelectIndex
  if 0 < select_index then
    need_filter = true
    return need_filter
  end
  select_index = form.combobox_from_level.DropListBox.SelectIndex
  if 0 <= select_index then
    need_filter = true
    return need_filter
  end
  select_index = form.combobox_to_level.DropListBox.SelectIndex
  if 0 <= select_index then
    need_filter = true
    return need_filter
  end
  return need_filter
end
function request_guild(form)
  if not nx_is_valid(form) then
    return
  end
  local from_num = 0
  local to_num = 0
  from_num = (form.page_no - 1) * 10 + 1
  to_num = form.page_no * 10
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_SEARCH_GUILD), nx_int(form.rbtn_index), nx_int(from_num), nx_int(to_num))
end
function request_guild_by_filter(form)
  if not nx_is_valid(form) then
    return
  end
  local from_num = 0
  local to_num = 0
  from_num = (form.page_no - 1) * 10 + 1
  to_num = form.page_no * 10
  form.filter_name = form.ipt_guild_name.Text
  if nx_int(form.combobox_from_level.DropListBox.SelectIndex) ~= nx_int(-1) then
    form.filter_from_level = nx_int(form.combobox_from_level.DropListBox.SelectIndex + 1)
  else
    form.filter_from_level = nx_int(GUILD_MIN_LEVEL)
  end
  if nx_int(form.combobox_to_level.DropListBox.SelectIndex) ~= nx_int(-1) then
    form.filter_to_level = nx_int(form.combobox_to_level.DropListBox.SelectIndex + 1)
  else
    form.filter_to_level = nx_int(GUILD_MAX_LEVEL)
  end
  if nx_int(form.filter_from_level) > nx_int(form.filter_to_level) then
    return
  end
  if nx_int(form.combobox_power.DropListBox.SelectIndex) > nx_int(0) then
    form.filter_power = nx_int(form.combobox_power.DropListBox.SelectIndex)
  else
    form.filter_power = nx_int(ABILITY_POWER_MAX_INDEX)
  end
  if nx_int(form.combobox_school.DropListBox.SelectIndex) > nx_int(0) then
    local temp_index = nx_number(form.combobox_school.DropListBox.SelectIndex + 1)
    local temp_str = school_table[temp_index].index_text
    form.filter_school = temp_str
  else
    form.filter_school = ""
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_SEARCH_GUILD_BY_FILTER), nx_int(form.rbtn_index), nx_int(form.sort_index), nx_int(from_num), nx_int(to_num), nx_widestr(form.filter_name), nx_int(form.filter_power), nx_string(form.filter_school), nx_int(form.filter_from_level), nx_int(form.filter_to_level))
end
function clear_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_guild
  grid:BeginUpdate()
  grid:ClearRow()
  grid:EndUpdate()
end
function start_timer(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, 1, nx_current(), "set_btn_enabled", form, -1, -1)
    form.lbl_4.Visible = true
    form.lbl_5.Visible = true
  end
end
function set_btn_enabled(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_4.Visible = false
  form.lbl_5.Visible = false
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "set_btn_enabled", form)
  end
end
function on_rece_guild_info(...)
  local form = nx_value("form_stage_main\\form_guild\\form_search_guild")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if nx_int(size) == nx_int(1) then
    if form.next_page_clicked == true then
      form.next_page_clicked = false
      form.page_no = nx_int(form.page_no - 1)
    end
    return
  end
  clear_grid(form)
  size = table.getn(arg) - 2
  if size % 8 ~= 0 then
    return
  end
  local grid = form.grid_guild
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  for i = 1, size / 8 do
    local row = grid:InsertRow(-1)
    local temp_index = (i - 1) * 8 + 1
    grid:SetGridText(row, 0, nx_widestr(arg[temp_index]))
    temp_index = temp_index + 1
    if nx_int(arg[temp_index]) ~= nx_int(0) then
      grid:SetGridText(row, 1, nx_widestr(util_text(nx_string("ui_sns_number_") .. nx_string(arg[temp_index]))))
    else
      grid:SetGridText(row, 1, nx_widestr(util_text(nx_string("ui_None"))))
    end
    temp_index = temp_index + 1
    if nx_int(arg[temp_index]) == nx_int(0) then
      grid:SetGridText(row, 2, nx_widestr(util_text(nx_string("ui_None"))))
    else
      grid:SetGridText(row, 2, nx_widestr(arg[temp_index]))
    end
    temp_index = temp_index + 1
    grid:SetGridText(row, 3, nx_widestr(arg[temp_index]))
    temp_index = temp_index + 1
    grid:SetGridText(row, 4, nx_widestr(arg[temp_index]))
    temp_index = temp_index + 1
    local ability_limit = nx_int(arg[temp_index])
    if ability_limit <= nx_int(0) then
      ability_limit = nx_int(1)
    end
    if ability_limit > nx_int(ABILITY_POWER_MAX_INDEX) then
      ability_limit = nx_int(ABILITY_POWER_MAX_INDEX)
    end
    if ability_limit < nx_int(10) then
      grid:SetGridText(row, 5, nx_widestr(util_text("desc_title00" .. nx_string(ability_limit))))
    else
      grid:SetGridText(row, 5, nx_widestr(util_text("desc_title0" .. nx_string(ability_limit))))
    end
    temp_index = temp_index + 1
    if nx_int(arg[temp_index]) == nx_int(0) then
      grid:SetGridText(row, 6, nx_widestr(util_text(nx_string("ui_None"))))
    else
      grid:SetGridText(row, 6, nx_widestr(util_text(nx_string(arg[temp_index]))))
    end
    temp_index = temp_index + 1
    local temp_school_table = util_split_string(nx_string(arg[temp_index]), ",")
    local school_control_length = 0
    if nx_int(grid:GetColWidth(7)) >= nx_int(grid.RowHeight) then
      school_control_length = nx_int(grid.RowHeight) - 2
    else
      school_control_length = nx_int(grid:GetColWidth(7)) - 2
    end
    if nx_int(table.getn(temp_school_table)) == nx_int(0) then
      for n = 2, table.getn(school_table) do
        local gui = nx_value("gui")
        local label = gui:Create("Label")
        if nx_is_valid(label) then
          label.Width = school_control_length
          label.Height = school_control_length
          label.BackImage = school_table[n].pic
          label.HintText = nx_widestr(util_text(nx_string(school_table[n].text)))
          label.DrawMode = "FitWindow"
          label.Text = nx_widestr("")
          label.Align = "Center"
          label.NoFrame = true
          label.Solid = false
          label.Transparent = false
          grid:SetGridControl(row, 6 + n - 1, label)
        end
      end
    else
      for j = 1, table.getn(temp_school_table) do
        for n = 2, table.getn(school_table) do
          if nx_string(temp_school_table[j]) == nx_string(school_table[n].index_text) then
            local gui = nx_value("gui")
            local label = gui:Create("Label")
            if nx_is_valid(label) then
              label.Width = school_control_length
              label.Height = school_control_length
              label.BackImage = school_table[n].pic
              label.HintText = nx_widestr(util_text(nx_string(school_table[n].text)))
              label.DrawMode = "FitWindow"
              label.Text = nx_widestr("")
              label.NoFrame = true
              label.Solid = false
              label.Transparent = false
              grid:SetGridControl(row, 6 + n - 1, label)
            end
            break
          end
        end
      end
    end
  end
  grid:EndUpdate()
  local real_from_num = nx_int(arg[size + 1])
  local real_to_num = nx_int(arg[size + 2])
  if (real_to_num - real_from_num + 1) % 10 ~= 0 then
    form.next_page = false
    form.btn_to.Enabled = false
  else
    form.next_page = true
    form.btn_to.Enabled = true
  end
end
function on_rece_simple_info(...)
  local form = nx_value("form_stage_main\\form_guild\\form_search_guild")
  if not nx_is_valid(form) then
    return
  end
  local offset = 1
  form.mltbox_purpose.HtmlText = nx_widestr(arg[offset])
  offset = offset + 1
  local logo_info = util_split_string(arg[offset], "#")
  if table.getn(logo_info) <= 0 then
    form.guild_logo.Image = "gui\\guild\\formback\\bg_logo.png"
  else
    form.guild_logo_frame.Image = nx_resource_path() .. "gui\\guild\\frame\\" .. nx_string(logo_info[1])
    form.guild_logo.Image = nx_resource_path() .. "gui\\guild\\logo\\" .. nx_string(logo_info[2])
    form.groupbox_color.BackColor = nx_string(logo_info[3])
  end
end
function is_in_guild()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("GuildName") then
    local guild_name = client_player:QueryProp("GuildName")
    if nx_widestr(guild_name) ~= nx_widestr("") then
      return true
    end
  end
  return false
end
