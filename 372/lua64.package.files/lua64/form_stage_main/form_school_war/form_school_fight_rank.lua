require("util_functions")
require("util_gui")
require("form_stage_main\\form_school_war\\school_war_define")
local form_name = "form_stage_main\\form_school_war\\form_school_fight_rank"
local TimeEventName = "schoolfight002"
local TimeLimitRecTableName = "Time_Limit_Form_Rec"
local DEFENDINDEX = 1
local DEFENDHELPINDEX = 2
local ATTACKINDEX = 3
local ATTACKHELPINDEX = 4
local SELFINDEX = 5
local DATANAME = {
  "defend_data",
  "defend_help_data",
  "attack_data",
  "attack_help_data",
  "self_data"
}
local NUM_PER_PAGE = 15
local EXPLOIT = {
  "ui_schoolfightrank_zhangong02",
  "ui_schoolfightrank_zhangong03",
  "ui_schoolfightrank_zhangong04",
  "ui_schoolfightrank_zhangong05"
}
local DELTATIME = 300000
local DELAYTIME = 10000
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  init_form(self)
  self.lbl_waiting.Visible = true
  self.lbl_back.Visible = true
  self.refreshcombobox = true
  request_open_form(2, 0, 0)
  self.receivedata = false
  self.updatetime = nx_function("ext_get_tickcount")
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", self)
  timer:Register(1000, -1, nx_current(), "on_update_time", self, -1, -1)
  on_update_time(self)
  self.selIndex = 1
  local gui = nx_value("gui")
  self.mltbox_help.HtmlText = gui.TextManager:GetText("desc_schoolwar_jifen")
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_update_time(form)
  local interval = nx_int(nx_function("ext_get_tickcount")) - nx_int(form.updatetime)
  if not form.receivedata and nx_int(interval) > nx_int(DELAYTIME) then
    form:Close()
    return
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  if nx_int(interval) > nx_int(DELTATIME) then
    refresh_current_rank_data(form, form.ipt_page.Text)
    form.receivedata = false
    form.updatetime = nx_function("ext_get_tickcount")
  end
  if not client_scene:FindRecord(TimeLimitRecTableName) then
    return
  end
  local rows = client_scene:FindRecordRow(TimeLimitRecTableName, 0, TimeEventName)
  if rows < 0 then
    return
  end
  local endtimer = client_scene:QueryRecord(TimeLimitRecTableName, rows, 3)
  local msg_delay = nx_value("MessageDelay")
  local curservertime = msg_delay:GetServerNowTime()
  local live_time = (nx_int64(endtimer) - nx_int64(curservertime)) / 1000
  if nx_int(live_time) <= nx_int(0) then
    form:Close()
    return
  end
  form.lbl_time.Text = nx_widestr(get_format_time_text(live_time))
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local grid = form.textgrid_rec
  grid.ColCount = 9
  for i = 1, grid.ColCount do
    grid:SetColAlign(i - 1, "center")
  end
  grid.HeaderColWidth = 10
  grid:SetColTitle(0, gui.TextManager:GetText("ui_rank_cur_no"))
  grid:SetColTitle(1, gui.TextManager:GetText("ui_player"))
  grid:SetColTitle(2, gui.TextManager:GetText("ui_menpaizhan8"))
  grid:SetColTitle(3, gui.TextManager:GetText("ui_crshu"))
  grid:SetColTitle(4, gui.TextManager:GetText("ui_bsshu"))
  grid:SetColTitle(5, gui.TextManager:GetText("ui_schoolwar_bindscore"))
  grid:SetColTitle(6, gui.TextManager:GetText("ui_schoolwar_honorscore"))
  grid:SetColTitle(7, gui.TextManager:GetText("ui_zongjf"))
  grid:SetColTitle(8, gui.TextManager:GetText("ui_schoolfightrank_zhangong01"))
  form.rbtn_attack.Checked = true
  form.combobox_school.InputEdit.Text = nx_widestr("")
  form.combobox_school.DropListBox:ClearString()
end
function init_school_combobox(form)
  if not nx_is_valid(form) then
    return
  end
  if not (nx_find_custom(form, "def_schoolid") and nx_find_custom(form, "att_schoolid") and nx_find_custom(form, "def_help")) or not nx_find_custom(form, "att_help") then
    return
  end
  if not form.refreshcombobox then
    return
  end
  local gui = nx_value("gui")
  local def_schoolid = nx_number(form.def_schoolid)
  local att_schoolid = nx_number(form.att_schoolid)
  local def_help = nx_number(form.def_help)
  local att_help = nx_number(form.att_help)
  local atthelplist = get_help_list(att_help)
  local defhelplist = get_help_list(def_help)
  local total_name = gui.TextManager:GetText("ui_schoolfightrank_all")
  if form.rbtn_defend.Checked then
    form.combobox_school.DropListBox:AddString(nx_widestr(total_name))
    form.combobox_school.Text = nx_widestr(total_name)
    local def_school_name = gui.TextManager:GetText(school_table[def_schoolid].school)
    form.combobox_school.DropListBox:AddString(nx_widestr(def_school_name))
    for i = 1, table.getn(defhelplist) do
      local school_id = nx_number(defhelplist[i])
      form.combobox_school.DropListBox:AddString(nx_widestr(gui.TextManager:GetText(school_table[school_id].school)))
    end
  else
    form.combobox_school.DropListBox:AddString(nx_widestr(total_name))
    form.combobox_school.Text = nx_widestr(total_name)
    local att_school_name = gui.TextManager:GetText(school_table[att_schoolid].school)
    form.combobox_school.DropListBox:AddString(nx_widestr(att_school_name))
    for i = 1, table.getn(atthelplist) do
      local school_id = nx_number(atthelplist[i])
      form.combobox_school.DropListBox:AddString(nx_widestr(gui.TextManager:GetText(school_table[school_id].school)))
    end
  end
  if table.getn(atthelplist) + table.getn(defhelplist) < 6 then
    form.combobox_school.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_schoolwar_other")))
  end
  form.refreshcombobox = false
end
function reset_form_info(form)
  form.combobox_school.InputEdit.Text = nx_widestr("")
  form.combobox_school.DropListBox:ClearString()
  init_school_combobox(form)
  form.textgrid_rec:ClearRow()
  form.lbl_index.Text = nx_widestr("")
  form.lbl_name.Text = nx_widestr("")
  form.lbl_school.Text = nx_widestr("")
  form.lbl_killed.Text = nx_widestr("")
  form.lbl_bekilled.Text = nx_widestr("")
  form.lbl_score.Text = nx_widestr("")
  form.lbl_bindscore.Text = nx_widestr("")
  form.lbl_honorscore.Text = nx_widestr("")
end
function on_rbtn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.refreshcombobox = true
  reset_form_info(form)
  form.combobox_school.DropListBox.SelectIndex = 0
  refresh_current_rank_data(form, 0)
end
function get_help_list(helpdata)
  local result = {}
  local tmpdata = helpdata
  for i = table.getn(school_id_table) - 1, 0, -1 do
    if tmpdata <= 0 then
      return result
    end
    local tmp = math.floor(tmpdata / math.pow(2, i))
    if tmp == 1 then
      table.insert(result, school_id_table[i])
      tmpdata = tmpdata - math.pow(2, i)
    end
  end
  return result
end
function open_form(def_school_id, att_school_id, def_help, att_help, def_count, att_count, max_col, page, total_page, ...)
  local form = nx_execute("util_gui", "util_get_form", form_name, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.def_schoolid = nx_number(def_school_id)
  form.att_schoolid = nx_number(att_school_id)
  form.def_help = nx_number(def_help)
  form.att_help = nx_number(att_help)
  local gui = nx_value("gui")
  init_school_combobox(form)
  local curindex = 1
  local rank_count = nx_number(arg[curindex])
  if math.fmod(rank_count, max_col) ~= 0 then
    return
  end
  local row_count = rank_count / max_col
  if nx_int(rank_count + curindex) > nx_int(table.getn(arg)) then
    return
  end
  local grid = form.textgrid_rec
  grid:ClearRow()
  if nx_number(page) ~= 0 then
    form.groupbox_paging.Visible = true
    form.btn_left.Enabled = true
    form.btn_right.Enabled = true
    form.btn_leftest.Enabled = true
    form.btn_rightest.Enabled = true
    if nx_number(page) <= 1 then
      page = 1
      form.btn_leftest.Enabled = false
      form.btn_left.Enabled = false
    end
    if nx_number(page) >= nx_number(total_page) then
      page = total_page
      form.btn_rightest.Enabled = false
      form.btn_right.Enabled = false
    end
    form.ipt_page.Text = nx_widestr(page)
    if nx_int(form.ipt_page.Text) == 0 then
      form.ipt_page.Text = nx_widestr(1)
    end
  else
    form.groupbox_paging.Visible = false
  end
  for j = 1, row_count do
    local name = nx_widestr(arg[curindex + 1])
    local school = nx_string(arg[curindex + 2])
    local score = nx_int(arg[curindex + 3])
    local killed = nx_int(arg[curindex + 4])
    local bekilled = nx_int(arg[curindex + 5])
    local bindscore = nx_int(arg[curindex + 6])
    local honorscore = nx_int(arg[curindex + 7])
    local exploit = nx_widestr("")
    if page ~= 0 and score ~= nx_int(0) then
      local ranking = (page - 1) * NUM_PER_PAGE + j
      exploit = nx_widestr(get_exploit(ranking))
    end
    local row = grid:InsertRow(-1)
    if page ~= 0 then
      grid:SetGridText(row, 0, nx_widestr(j + (page - 1) * NUM_PER_PAGE))
    else
      grid:SetGridText(row, 0, nx_widestr(j))
    end
    grid:SetGridText(row, 1, nx_widestr(name))
    grid:SetGridText(row, 2, gui.TextManager:GetText(school))
    grid:SetGridText(row, 3, nx_widestr(killed))
    grid:SetGridText(row, 4, nx_widestr(bekilled))
    grid:SetGridText(row, 5, nx_widestr(bindscore))
    grid:SetGridText(row, 6, nx_widestr(honorscore))
    grid:SetGridText(row, 7, nx_widestr(score))
    grid:SetGridText(row, 8, nx_widestr(exploit))
    curindex = curindex + max_col
  end
  form.lbl_index.Text = nx_widestr("")
  form.lbl_name.Text = nx_widestr("")
  form.lbl_school.Text = nx_widestr("")
  form.lbl_killed.Text = nx_widestr("")
  form.lbl_bekilled.Text = nx_widestr("")
  form.lbl_score.Text = nx_widestr("")
  form.lbl_bindscore.Text = nx_widestr("")
  form.lbl_honorscore.Text = nx_widestr("")
  form.lbl_exploit.Text = nx_widestr("")
  if nx_number(curindex + 2) < table.getn(arg) then
    local self_rank = nx_number(arg[curindex + 1])
    local self_value_cnt = nx_number(arg[curindex + 2])
    curindex = curindex + 2
    if nx_number(curindex + self_value_cnt) <= table.getn(arg) then
      local name = nx_widestr(arg[curindex + 1])
      local school = nx_string(arg[curindex + 2])
      local score = nx_int(arg[curindex + 3])
      local killed = nx_int(arg[curindex + 4])
      local bekilled = nx_int(arg[curindex + 5])
      local bindscore = nx_int(arg[curindex + 6])
      local honorscore = nx_int(arg[curindex + 7])
      form.lbl_index.Text = nx_widestr(self_rank)
      local show_name = name
      if nx_ws_length(show_name) > 16 then
        show_name = nx_function("ext_ws_substr", show_name, 0, 3) .. nx_widestr("...")
        form.lbl_name.HintText = name
      else
        form.lbl_name.HintText = ""
      end
      form.lbl_name.Text = nx_widestr(show_name)
      form.lbl_school.Text = nx_widestr(gui.TextManager:GetText(school))
      form.lbl_killed.Text = nx_widestr(killed)
      form.lbl_bekilled.Text = nx_widestr(bekilled)
      form.lbl_score.Text = nx_widestr(score)
      form.lbl_bindscore.Text = nx_widestr(bindscore)
      form.lbl_honorscore.Text = nx_widestr(honorscore)
      if page ~= 0 and score ~= nx_int(0) then
        form.lbl_exploit.Text = nx_widestr(get_exploit(self_rank))
      end
    end
  end
  form.lbl_attacker.Text = nx_widestr(att_count)
  form.lbl_defender.Text = nx_widestr(def_count)
  form.lbl_waiting.Visible = false
  form.lbl_back.Visible = false
  form.receivedata = true
end
function refresh_current_rank_data(form, page)
  if not nx_is_valid(form) then
    return
  end
  local select_index = form.combobox_school.DropListBox.SelectIndex
  local side = 0
  local helplist = {}
  local data_type = 0
  if form.rbtn_attack.Checked then
    if nx_find_custom(form, "att_help") then
      helplist = get_help_list(form.att_help)
    end
    side = 2
  elseif form.rbtn_defend.Checked then
    if nx_find_custom(form, "def_help") then
      helplist = get_help_list(form.def_help)
    end
    side = 1
  end
  if side == 0 then
    return
  end
  if select_index == 0 or select_index == -1 then
    data_type = 0
  elseif select_index == 1 then
    data_type = 1
  elseif 1 < select_index and select_index - 1 <= table.getn(helplist) then
    data_type = helplist[select_index - 1]
  else
    data_type = 2
  end
  if data_type ~= 0 then
    page = 0
  end
  request_open_form(side, data_type, page)
end
function on_combobox_school_selected(combox)
  local form = combox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_current_rank_data(form, form.ipt_page.Text)
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_current_rank_data(form, nx_int(form.ipt_page.Text) - 1)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_current_rank_data(form, nx_int(form.ipt_page.Text) + 1)
end
function on_btn_leftest_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_current_rank_data(form, 1)
end
function on_btn_rightest_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_current_rank_data(form, 9999)
end
function on_btn_jump_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_current_rank_data(form, nx_int(form.ipt_page.Text))
end
function request_open_form(side, data_type, page)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local is_in_fight = client_player:QueryProp("IsInSchoolFight")
  if nx_int(is_in_fight) == nx_int(1) then
    if data_type ~= 0 then
      page = 0
    end
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 1, nx_int(side), nx_int(data_type), nx_int(page))
  end
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_cbtn_help_checked_changed(self)
  local gui = nx_value("gui")
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.groupbox_help) then
    return
  end
  if form.groupbox_help.Visible then
    form.groupbox_help.Visible = false
    form.Width = form.Width - form.groupbox_help.Width
  else
    form.groupbox_help.Visible = true
    form.Width = form.Width + form.groupbox_help.Width
    if form.selIndex == 1 then
      form.mltbox_help.HtmlText = gui.TextManager:GetText("desc_schoolwar_jifen")
    elseif form.selIndex == 2 then
      form.mltbox_help.HtmlText = gui.TextManager:GetText("desc_schoolwar_jiangli")
    elseif form.selIndex == 3 then
      form.mltbox_help.HtmlText = gui.TextManager:GetText("desc_schoolwar_qita")
    end
  end
end
function on_rbtn_jf_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.selIndex = 1
  form.mltbox_help.HtmlText = gui.TextManager:GetText("desc_schoolwar_jifen")
end
function on_rbtn_jl_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.selIndex = 2
  form.mltbox_help.HtmlText = gui.TextManager:GetText("desc_schoolwar_jiangli")
end
function on_rbtn_qt_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.selIndex = 3
  form.mltbox_help.HtmlText = gui.TextManager:GetText("desc_schoolwar_qita")
end
function on_btn_help_quit_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_help.Visible = false
  form.Width = form.Width - form.groupbox_help.Width
end
function get_exploit(ranking)
  if ranking <= 0 then
    return nx_widestr("")
  end
  local gui = nx_value("gui")
  local result = ""
  if ranking <= 20 then
    result = EXPLOIT[1]
  elseif ranking <= 100 then
    result = EXPLOIT[2]
  elseif ranking <= 200 then
    result = EXPLOIT[3]
  else
    result = EXPLOIT[4]
  end
  return gui.TextManager:GetText(nx_string(result))
end
function on_textgrid_rec_right_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local playername = grid:GetGridText(row, 1)
  if nx_ws_equal(nx_widestr(playername), nx_widestr("")) then
    return
  end
  local result = nx_execute("form_stage_main\\form_school_fight\\form_school_fight_map", "CanKickTarget")
  if not result then
    return
  end
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "schoolfight_rank", "schoolfight_rank")
  nx_execute("menu_game", "menu_recompose", menu_game, playername)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
