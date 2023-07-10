require("util_gui")
require("util_functions")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local WUXUE_COL_DATA = 0
local WUXUE_COL_TIME = 1
local WUXUE_COL_SCENE = 2
local WUXUE_COL_AREA = 3
local WUXUE_COL_TYPE = 4
local WUXUE_COL_NAME = 5
local WX_TYPE_MIN = 0
local WX_TYPE_NEIGONG = 1
local WX_TYPE_ZHAOSHI = 2
local WX_TYPE_QINGGONG = 3
local WX_TYPE_QGSKILL = 4
local WX_TYPE_ZHENFA = 5
local WX_TYPE_JINGMAI = 6
local WX_TYPE_XUEWEI = 7
local WX_TYPE_SHOUFA = 8
local WX_TYPE_MAX
local MAX_SHOW_COUNT = 12
function open_form()
  util_auto_show_hide_form(nx_current())
end
function main_form_init(self)
  self.Fixed = true
  self.cur_year = 0
  self.cur_month = 0
  self.focus = nil
  self.wuxue_name = ""
  self.wuxue_type = ""
  self.wuxue_list = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.wuxue_list = nx_call("util_gui", "get_arraylist", "wuxue_list")
  if nx_is_valid(form.wuxue_list) then
    init_wuxue_list(form.wuxue_list)
  end
  util_show_form("form_stage_main\\form_note\\form_note_wuxue_back", true, false)
  form.btn_return_month.Visible = false
  form.btn_return_day.Visible = false
  form.lbl_return.Visible = false
  form.lbl_fan.Visible = false
  form.lbl_hui.Visible = false
  form.textgrid_wuxue.Visible = false
  form.textgrid_month.Visible = false
  form.textgrid_day.Visible = false
  form.lbl_sbar.Visible = false
  show_year_btn(form)
  form.groupbox_info.Visible = false
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.wuxue_list) then
    form.wuxue_list:ClearChild()
    nx_destroy(form.wuxue_list)
  end
  local form_back = util_get_form("form_stage_main\\form_note\\form_note_wuxue_back", false, false)
  if nx_is_valid(form_back) then
    form_back:Close()
  end
  nx_destroy(form)
  return 1
end
function on_btn_close_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_year_checked_changed(self)
  local form = self.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  if self.Checked then
    form.cur_year = nx_int(self.DataSource)
    refresh_year_form(form)
  end
end
function on_btn_particular_click(self)
  local form = self.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  open_wuxue_info(form.wuxue_type, form.wuxue_name)
end
function on_btn_share_click(self)
end
function on_btn_return_month_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_wuxue.Visible = true
  form.textgrid_month.Visible = false
  form.textgrid_day.Visible = false
  form.lbl_return.Visible = false
  form.btn_return_month.Visible = false
  form.lbl_fan.Visible = false
  form.lbl_hui.Visible = false
  form.groupbox_year.Visible = true
  form.lbl_date.Visible = false
  form.lbl_back.BackImage = "gui\\special\\jianghu_log\\bg_year.png"
  is_show_hscrollbar(form.textgrid_wuxue)
end
function on_btn_return_day_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_wuxue.Visible = false
  form.textgrid_month.Visible = true
  form.textgrid_day.Visible = false
  form.btn_return_month.Visible = true
  form.btn_return_day.Visible = false
  form.lbl_return.Visible = true
  form.lbl_fan.Visible = true
  form.lbl_hui.Visible = true
  local gui = nx_value("gui")
  local year_text = gui.TextManager:GetText("ui_year")
  local month_text = gui.TextManager:GetText("ui_month")
  form.lbl_back.BackImage = "gui\\special\\jianghu_log\\bg_month.png"
  form.lbl_date.Text = nx_widestr(nx_widestr(form.cur_year) .. nx_widestr(year_text) .. nx_widestr(form.cur_month) .. nx_widestr(month_text))
  is_show_hscrollbar(form.textgrid_month)
end
function process_checked_changed(self)
  local form = self.Parent.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  resume_form_control(form)
  form.focus = self
  local form_grp = self.Parent
  if not nx_is_valid(form_grp) then
    return
  end
  form_grp.BackImage = "gui\\special\\jianghu_log\\icon_select_1.png"
  form_grp.DrawMode = "FitWindow"
  self.ForeColor = "255,255,255,255"
  form.groupbox_info.Visible = true
  local learn_year, learn_month, learn_day = get_wuxue_learn_data(self.data)
  form.lbl_data.Text = nx_widestr(nx_widestr(learn_year) .. nx_widestr(gui.TextManager:GetText("ui_year")) .. nx_widestr(learn_month) .. nx_widestr(gui.TextManager:GetText("ui_month")) .. nx_widestr(learn_day) .. nx_widestr(gui.TextManager:GetText("str_date")))
  local text_zai = nx_widestr(nx_widestr("<font color=\"#FFFFFF\">") .. nx_widestr(gui.TextManager:GetText("ui_zai")) .. nx_widestr("</font>"))
  local text_sence = nx_widestr(nx_widestr("<font color=\"#A0D000\">") .. nx_widestr(gui.TextManager:GetText(self.scene)) .. nx_widestr("</font>"))
  local text_succee = nx_widestr(nx_widestr("<font color=\"#FFFFFF\">") .. nx_widestr(gui.TextManager:GetText("ui_chenggongxide")) .. nx_widestr("</font>"))
  local text_wuxue = nx_widestr(nx_widestr("<font color=\"#A0D000\">") .. nx_widestr(gui.TextManager:GetText(self.wuxue)) .. nx_widestr("</font>"))
  form.mltbox_info.HtmlText = text_zai .. text_sence .. text_succee .. text_wuxue
  form.wuxue_name = self.wuxue
  form.wuxue_type = self.type
end
function show_wuxue(self)
  if not nx_is_valid(self) then
    return
  end
  open_wuxue_info(self.type, self.wuxue)
end
function refresh_year_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  resume_form_control(form)
  form.lbl_back.BackImage = "gui\\special\\jianghu_log\\bg_year.png"
  form.btn_return_month.Visible = false
  form.btn_return_day.Visible = false
  form.lbl_fan.Visible = false
  form.lbl_hui.Visible = false
  form.textgrid_wuxue.Visible = true
  form.textgrid_month.Visible = false
  form.textgrid_day.Visible = false
  form.lbl_return.Visible = false
  form.textgrid_wuxue:BeginUpdate()
  form.textgrid_wuxue:ClearRow()
  form.textgrid_day.HScrollBar.Value = 0
  form.textgrid_wuxue.ColCount = 12
  set_year_control(form)
  local row_month = form.textgrid_wuxue:InsertRow(-1)
  for col = 0, 11 do
    local month_btn = creat_month_button(form, form.cur_year, col, form.textgrid_wuxue)
    form.textgrid_wuxue:SetGridControl(row_month, col, month_btn)
  end
  set_back_color(form.textgrid_wuxue)
  form.textgrid_wuxue:EndUpdate()
  is_show_hscrollbar(form.textgrid_wuxue)
end
function refresh_month_form(self)
  local form = self.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.cur_month = self.month
  resume_form_control(form)
  form.lbl_back.BackImage = "gui\\special\\jianghu_log\\bg_month.png"
  form.btn_return_month.Visible = true
  form.btn_return_day.Visible = false
  form.lbl_fan.Visible = true
  form.lbl_hui.Visible = true
  form.textgrid_wuxue.Visible = false
  form.textgrid_month.Visible = true
  form.textgrid_day.Visible = false
  form.groupbox_year.Visible = false
  form.lbl_return.Visible = true
  form.lbl_date.Visible = true
  local year_text = gui.TextManager:GetText("ui_year")
  local month_text = gui.TextManager:GetText("ui_month")
  form.lbl_date.Text = nx_widestr(nx_widestr(form.cur_year) .. nx_widestr(year_text) .. nx_widestr(self.month) .. nx_widestr(month_text))
  form.textgrid_month:BeginUpdate()
  form.textgrid_month:ClearRow()
  set_month_control(form, self.month)
  local row_day = form.textgrid_month:InsertRow(-1)
  for col = 0, 31 do
    local day_btn = creat_day_button(form, form.cur_year, self.month, col, form.textgrid_month)
    form.textgrid_month:SetGridControl(row_day, col, day_btn)
  end
  local first_day = get_month_first_wuxue(form, self.month)
  if nx_int(first_day) < nx_int(15) then
    form.textgrid_month.HScrollBar.Value = 0
  else
    form.textgrid_month.HScrollBar.Value = 14
  end
  set_back_color(form.textgrid_month)
  form.textgrid_month:EndUpdate()
  is_show_hscrollbar(form.textgrid_month)
end
function refresh_day_form(self)
  local form = self.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  resume_form_control(form)
  form.lbl_back.BackImage = "gui\\special\\jianghu_log\\bg_day.png"
  form.textgrid_wuxue.Visible = false
  form.textgrid_month.Visible = false
  form.textgrid_day.Visible = true
  form.btn_return_month.Visible = false
  form.btn_return_day.Visible = true
  local year_text = gui.TextManager:GetText("ui_year")
  local month_text = gui.TextManager:GetText("ui_month")
  local day_text = gui.TextManager:GetText("str_date")
  form.lbl_date.Text = nx_widestr(nx_widestr(form.cur_year) .. nx_widestr(year_text) .. nx_widestr(self.month) .. nx_widestr(month_text) .. nx_widestr(self.day) .. nx_widestr(day_text))
  form.textgrid_day:BeginUpdate()
  form.textgrid_day:ClearRow()
  form.textgrid_day.HScrollBar.Value = 0
  form.textgrid_day.ColCount = get_time_max_count(form, self.month, self.day)
  set_day_control(form, self.month, self.day)
  set_back_color(form.textgrid_day)
  form.textgrid_day:EndUpdate()
  is_show_hscrollbar(form.textgrid_day)
end
function init_wuxue_list(wuxue_list)
  if not nx_is_valid(wuxue_list) then
    return
  end
  wuxue_list:ClearChild()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("note_wuxue_rec") then
    return
  end
  local rows = client_player:GetRecordRows("note_wuxue_rec")
  for i = 0, rows - 1 do
    local child = wuxue_list:CreateChild(nx_string(i))
    if nx_is_valid(child) then
      child.data = client_player:QueryRecord("note_wuxue_rec", i, WUXUE_COL_DATA)
      child.time = client_player:QueryRecord("note_wuxue_rec", i, WUXUE_COL_TIME)
      child.scene = client_player:QueryRecord("note_wuxue_rec", i, WUXUE_COL_SCENE)
      child.type = client_player:QueryRecord("note_wuxue_rec", i, WUXUE_COL_TYPE)
      child.name = client_player:QueryRecord("note_wuxue_rec", i, WUXUE_COL_NAME)
    end
  end
end
function get_month_count(form, cur_year, month)
  if nx_int(cur_year) == nx_int(0) or cur_year == nil then
    return 0
  end
  local begin_data = cur_year * 10000 + month * 100 + 1
  local end_data = cur_year * 10000 + month * 100 + 31
  local wuxue_list = form.wuxue_list
  if not nx_is_valid(wuxue_list) then
    return 0
  end
  local wuxue_count = 0
  local list_count = wuxue_list:GetChildCount()
  for i = 0, list_count - 1 do
    local obj = wuxue_list:GetChild(nx_string(i))
    if nx_int(obj.data) >= nx_int(begin_data) and nx_int(obj.data) <= nx_int(end_data) then
      wuxue_count = wuxue_count + 1
    end
  end
  return wuxue_count
end
function get_day_count(form, cur_year, cur_month, cur_day)
  if nx_int(cur_year) == nx_int(0) or cur_year == nil then
    return 0
  end
  local wuxue_list = form.wuxue_list
  if not nx_is_valid(wuxue_list) then
    return 0
  end
  local wuxue_count = 0
  local learn_data = cur_year * 10000 + cur_month * 100 + cur_day
  local list_count = wuxue_list:GetChildCount()
  for i = 0, list_count - 1 do
    local obj = wuxue_list:GetChild(nx_string(i))
    if nx_int(obj.data) == nx_int(learn_data) then
      wuxue_count = wuxue_count + 1
    end
  end
  return wuxue_count
end
function creat_wuxue_button(obj, cur_col)
  if not nx_is_valid(obj) then
    return
  end
  local gui = nx_value("gui")
  local btn = gui:Create("Button")
  btn.Text = nx_widestr(gui.TextManager:GetText(obj.name))
  btn.HintText = nx_widestr(gui.TextManager:GetText(obj.name))
  btn.Align = "Left"
  btn.Font = "font_text"
  btn.data = obj.data
  btn.wuxue = obj.name
  btn.scene = obj.scene
  btn.type = obj.type
  btn.Left = 25
  btn.Width = 300
  btn.Height = 30
  btn.LineColor = "0,0,0,0"
  btn.DrawMode = "FitWindow"
  btn.FocusColor = "255,200,0,0"
  btn.FocusImage = "gui\\special\\jianghu_log\\icon_select_2.png"
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "process_checked_changed")
  nx_callback(btn, "on_left_double_click", "show_wuxue")
  local lbl = gui:Create("Label")
  lbl.AutoSize = true
  lbl.Top = 7
  lbl.Left = 4
  if nx_int(obj.type) == nx_int(WX_TYPE_NEIGONG) then
    lbl.BackImage = "gui\\language\\ChineseS\\jianghu_log\\icon_nei.png"
  elseif nx_int(obj.type) == nx_int(WX_TYPE_ZHAOSHI) then
    lbl.BackImage = "gui\\language\\ChineseS\\jianghu_log\\icon_zhao.png"
  elseif nx_int(obj.type) == nx_int(WX_TYPE_QINGGONG) or nx_int(obj.type) == nx_int(WX_TYPE_QGSKILL) then
    lbl.BackImage = "gui\\language\\ChineseS\\jianghu_log\\icon_qing.png"
  elseif nx_int(obj.type) == nx_int(WX_TYPE_ZHENFA) then
    lbl.BackImage = "gui\\language\\ChineseS\\jianghu_log\\icon_zhen.png"
  elseif nx_int(obj.type) == nx_int(WX_TYPE_SHOUFA) then
    lbl.BackImage = "gui\\language\\ChineseS\\jianghu_log\\icon_an.png"
  end
  local grp = gui:Create("GroupBox")
  grp.LineColor = "0,0,0,0"
  if nx_int(cur_col % 2) ~= nx_int(0) then
    grp.BackColor = "25,137,125,96"
  else
    grp.BackColor = "0,0,0,0"
  end
  grp:Add(btn)
  grp:Add(lbl)
  return grp
end
function creat_month_button(form, cur_year, col, self)
  local gui = nx_value("gui")
  local btn = gui:Create("Button")
  local month = nx_int(col) + 1
  local wuxue_count = get_month_count(form, cur_year, month)
  btn.ForeColor = "255,0,0,0"
  btn.Font = "font_text"
  btn.NormalImage = "gui\\special\\jianghu_log\\btn_month_out.png"
  btn.FocusImage = "gui\\special\\jianghu_log\\btn_month_on.png"
  btn.PushImage = "gui\\special\\jianghu_log\\btn_month_down.png"
  btn.DrawMode = "ExpandH"
  btn.DisableColor = "255,255,255,255"
  btn.month = month
  if nx_int(wuxue_count) ~= nx_int(0) then
    btn.Text = nx_widestr(nx_widestr(month) .. nx_widestr(gui.TextManager:GetFormatText("ui_month")) .. nx_widestr("(") .. nx_widestr(wuxue_count) .. nx_widestr(")"))
    btn.Enabled = true
    self:SetColWidth(col, 300)
  else
    btn.Enabled = false
    btn.Text = nx_widestr(nx_widestr(month) .. nx_widestr(gui.TextManager:GetFormatText("ui_month")))
    self:SetColWidth(col, 300)
  end
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "refresh_month_form")
  return btn
end
function creat_day_button(form, cur_year, cur_month, col, self)
  local gui = nx_value("gui")
  local btn = gui:Create("Button")
  local day = col + 1
  local wuxue_count = get_day_count(form, cur_year, cur_month, day)
  btn.ForeColor = "255,0,0,0"
  btn.Font = "font_text"
  btn.NormalImage = "gui\\special\\jianghu_log\\btn_month_out.png"
  btn.FocusImage = "gui\\special\\jianghu_log\\btn_month_on.png"
  btn.PushImage = "gui\\special\\jianghu_log\\btn_month_down.png"
  btn.DrawMode = "ExpandH"
  btn.DisableColor = "255,255,255,255"
  btn.month = cur_month
  btn.day = day
  if nx_int(wuxue_count) ~= nx_int(0) then
    btn.Text = nx_widestr(nx_widestr(day) .. nx_widestr(gui.TextManager:GetFormatText("str_date")) .. nx_widestr("(") .. nx_widestr(wuxue_count) .. nx_widestr(")"))
    btn.Enabled = true
    self:SetColWidth(col, 200)
  else
    btn.Enabled = false
    btn.Text = nx_widestr(nx_widestr(day) .. nx_widestr(gui.TextManager:GetFormatText("str_date")))
    self:SetColWidth(col, 200)
  end
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "refresh_day_form")
  return btn
end
function set_year_control(form)
  if not nx_is_valid(form) then
    return
  end
  local wuxue_list = form.wuxue_list
  if not nx_is_valid(wuxue_list) then
    return
  end
  local faculty_query = nx_value("faculty_query")
  for row = 1, 12 do
    form.textgrid_wuxue:InsertRow(-1)
  end
  for i = 1, 12 do
    local list_count = wuxue_list:GetChildCount()
    local wuxue_table = {}
    for j = 0, list_count - 1 do
      local obj = wuxue_list:GetChild(nx_string(j))
      local learn_year, learn_month, learn_day = get_wuxue_learn_data(obj.data)
      if nx_int(learn_year) == nx_int(form.cur_year) and nx_int(learn_month) == nx_int(i) then
        table.insert(wuxue_table, {
          obj,
          faculty_query:GetQuality(obj.name)
        })
      end
    end
    if 12 < table.getn(wuxue_table) then
      table.sort(wuxue_table, function(l, r)
        return l[2] > r[2]
      end)
    end
    for j = 0, table.getn(wuxue_table) - 1 do
      local wuxue_btn = creat_wuxue_button(wuxue_table[j + 1][1], i - 1)
      form.textgrid_wuxue:SetGridControl(11 - j, i - 1, wuxue_btn)
      if nx_int(j) >= nx_int(11) then
        break
      end
    end
  end
end
function set_month_control(form, cur_month)
  if not nx_is_valid(form) then
    return
  end
  local wuxue_list = form.wuxue_list
  if not nx_is_valid(wuxue_list) then
    return
  end
  local list_count = wuxue_list:GetChildCount()
  local faculty_query = nx_value("faculty_query")
  for row = 1, 12 do
    form.textgrid_month:InsertRow(-1)
  end
  for col = 1, 31 do
    local wuxue_table = {}
    for j = 0, list_count - 1 do
      local obj = wuxue_list:GetChild(nx_string(j))
      local learn_year, learn_month, learn_day = get_wuxue_learn_data(obj.data)
      if nx_int(learn_year) == nx_int(form.cur_year) and nx_int(learn_month) == nx_int(cur_month) and nx_int(learn_day) == nx_int(col) then
        table.insert(wuxue_table, {
          obj,
          faculty_query:GetQuality(obj.name)
        })
      end
    end
    if 12 < table.getn(wuxue_table) then
      table.sort(wuxue_table, function(l, r)
        return l[2] > r[2]
      end)
    end
    for j = 0, table.getn(wuxue_table) - 1 do
      local wuxue_btn = creat_wuxue_button(wuxue_table[j + 1][1], col - 1)
      form.textgrid_month:SetGridControl(11 - j, col - 1, wuxue_btn)
      if nx_int(j) >= nx_int(11) then
        break
      end
    end
  end
end
function set_day_control(form, cur_month, cur_day)
  if not nx_is_valid(form) then
    return
  end
  local wuxue_list = form.wuxue_list
  if not nx_is_valid(wuxue_list) then
    return
  end
  local list_count = wuxue_list:GetChildCount()
  for row = 1, 12 do
    form.textgrid_day:InsertRow(-1)
  end
  for cur_row = 0, 11 do
    local wuxue_count = 0
    for i = 0, list_count - 1 do
      local obj = wuxue_list:GetChild(nx_string(i))
      local learn_year, learn_month, learn_day = get_wuxue_learn_data(obj.data)
      local learn_time = get_wuxue_learn_time(obj.time)
      if nx_int(learn_year) == nx_int(form.cur_year) and nx_int(learn_month) == nx_int(cur_month) and nx_int(learn_day) == nx_int(cur_day) and nx_int(learn_time) == nx_int(cur_row) then
        local wuxue_btn = creat_wuxue_button(obj, wuxue_count)
        form.textgrid_day:SetGridControl(cur_row, wuxue_count, wuxue_btn)
        wuxue_count = wuxue_count + 1
      end
    end
  end
end
function resume_form_control(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.focus) then
    form.focus.ForeColor = "255,0,0,0"
    local grp_focus = form.focus.Parent
    if nx_is_valid(grp_focus) then
      grp_focus.BackImage = ""
    end
  end
  form.focus = nil
end
function get_time_max_count(form, cur_month, cur_day)
  if not nx_is_valid(form) then
    return 0
  end
  local wuxue_list = form.wuxue_list
  if not nx_is_valid(wuxue_list) then
    return 0
  end
  local list_count = wuxue_list:GetChildCount()
  local time_count = 0
  for time = 0, 11 do
    local wuxue_count = 0
    for i = 0, list_count - 1 do
      local obj = wuxue_list:GetChild(nx_string(i))
      local learn_year, learn_month, learn_day = get_wuxue_learn_data(obj.data)
      local learn_time = get_wuxue_learn_time(obj.time)
      if nx_int(learn_year) == nx_int(form.cur_year) and nx_int(learn_month) == nx_int(cur_month) and nx_int(learn_day) == nx_int(cur_day) and nx_int(learn_time) == nx_int(time) then
        wuxue_count = wuxue_count + 1
        if nx_int(time_count) < nx_int(wuxue_count) then
          time_count = wuxue_count
        end
      end
    end
  end
  return time_count
end
function get_wuxue_learn_time(time)
  if time == nil then
    return 0
  end
  return nx_int(time / 10000 / 2)
end
function get_wuxue_learn_data(data)
  if data == nil then
    return 0, 0, 0
  end
  local year = nx_int(data / 10000)
  local month = nx_int(data % 10000 / 100)
  local day = nx_int(data % 100)
  return year, month, day
end
function show_year_btn(form)
  local wuxue_list = form.wuxue_list
  if not nx_is_valid(wuxue_list) then
    return 0
  end
  local list_count = wuxue_list:GetChildCount()
  local min_year = 0
  local max_year = 0
  local min_wuxue = wuxue_list:GetChild(nx_string(0))
  local max_wuxue = wuxue_list:GetChild(nx_string(list_count - 1))
  if nx_is_valid(min_wuxue) and nx_is_valid(max_wuxue) and min_wuxue.data ~= nil and max_wuxue.data ~= nil then
    min_year = nx_int(min_wuxue.data / 10000)
    max_year = nx_int(max_wuxue.data / 10000)
  end
  for i = 2011, 2016 do
    rbtn = form.groupbox_year:Find("rbtn_" .. nx_string(i))
    if not nx_is_valid(rbtn) then
      break
    end
    lbl = form.groupbox_year:Find("lbl_" .. nx_string(i))
    if not nx_is_valid(lbl) then
      break
    end
    if nx_int(min_year) <= nx_int(i) and nx_int(i) <= nx_int(max_year) then
      rbtn.Visible = true
      lbl.Visible = true
    else
      rbtn.Visible = false
      lbl.Visible = false
    end
  end
  local groupbox_place = 80
  for i = 2011, 2016 do
    rbtn = form.groupbox_year:Find("rbtn_" .. nx_string(i))
    if not nx_is_valid(rbtn) then
      break
    end
    if rbtn.Visible == true then
      rbtn.Checked = true
      form.groupbox_year.Left = groupbox_place
      break
    end
    groupbox_place = groupbox_place - 80
  end
end
function is_show_hscrollbar(grid)
  if not nx_is_valid(grid) then
    return 0
  end
  local form = grid.Parent
  if not nx_is_valid(form) then
    return 0
  end
  if nx_is_valid(grid.HScrollBar) and grid.HScrollBar.Visible then
    form.lbl_sbar.Visible = true
  else
    form.lbl_sbar.Visible = false
  end
end
function set_back_color(grid)
  local row_count = grid.RowCount
  local col_count = grid.ColCount
  for i = 0, row_count - 1 do
    for j = 1, col_count - 1, 2 do
      grid:SetGridBackColor(nx_int(i), nx_int(j), "25,137,125,96")
    end
  end
end
function get_month_first_wuxue(form, cur_month)
  if not nx_is_valid(form) then
    return 0
  end
  local wuxue_list = form.wuxue_list
  if not nx_is_valid(wuxue_list) then
    return 0
  end
  local list_count = wuxue_list:GetChildCount()
  for i = 0, list_count - 1 do
    local obj = wuxue_list:GetChild(nx_string(i))
    local learn_year, learn_month, learn_day = get_wuxue_learn_data(obj.data)
    if nx_int(learn_year) == nx_int(form.cur_year) and nx_int(learn_month) == nx_int(cur_month) then
      return nx_int(learn_day)
    end
  end
  return 0
end
function open_wuxue_info(wuxue_type, wuxue_name)
  local open_type = ""
  if nx_int(wuxue_type) == nx_int(WX_TYPE_NEIGONG) then
    open_type = nx_number(WUXUE_NEIGONG)
  elseif nx_int(wuxue_type) == nx_int(WX_TYPE_ZHAOSHI) then
    open_type = nx_number(WUXUE_SKILL)
  elseif nx_int(wuxue_type) == nx_int(WX_TYPE_QINGGONG) or nx_int(wuxue_type) == nx_int(WX_TYPE_QGSKILL) then
    open_type = nx_number(WUXUE_QGSKILL)
  elseif nx_int(wuxue_type) == nx_int(WX_TYPE_ZHENFA) then
    open_type = nx_number(WUXUE_ZHENFA)
  elseif nx_int(wuxue_type) == nx_int(WX_TYPE_SHOUFA) then
    open_type = nx_number(WUXUE_ANQI)
  else
    return false
  end
  local type_name = get_type_by_wuxue_id(wuxue_name, open_type)
  if type_name == "" or type_name == nil then
    type_name = wuxue_name
  end
  open_wuxue_sub_page(nx_number(open_type), type_name)
  local bselect = select_item_wuxue(nx_number(open_type), wuxue_name)
  if bselect == false and nx_int(wuxue_type) == nx_int(WX_TYPE_ZHAOSHI) then
    local type_name = get_type_by_wuxue_id(wuxue_name, nx_number(WUXUE_ZHENFA))
    if type_name == "" or type_name == nil then
      type_name = wuxue_name
    end
    open_wuxue_sub_page(nx_number(WUXUE_ZHENFA), type_name)
    select_item_wuxue(nx_number(WUXUE_ZHENFA), wuxue_name)
  end
end
