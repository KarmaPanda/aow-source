require("custom_sender")
require("util_functions")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local guild_event_type_guild_important = 1
local guild_event_type_guild_build = 2
local guild_event_type_guild_war = 4
local guild_event_type_captial_important = 8
local guild_event_type_captial_escort = 16
local guild_event_type_captial_contribute = 32
local guild_event_type_member_important = 64
local guild_event_type_member_fight = 128
local guild_event_type_member_contribute = 256
local guild_event_type_member_change = 512
local MAX_ROW = 13
function main_form_init(self)
  self.Fixed = true
  self.pageno = 1
  self.page_next_ok = 1
  self.IsHistory = 0
end
function on_main_form_open(self)
  local width = self.textgrid_1.Width
  self.textgrid_1:SetColWidth(0, width / 3)
  self.textgrid_1:SetColWidth(1, width * 2 / 3)
  self.textgrid_1:SetColTitle(0, nx_widestr(util_text("ui_shijian")))
  self.textgrid_1:SetColTitle(1, nx_widestr(util_text("ui_guild_event")))
  self.groupbox_guild.Visible = false
  self.groupbox_capital.Visible = false
  self.groupbox_member.Visible = false
  self.rbtn_guild.Checked = true
  on_rbtn_guild_checked_changed(self.rbtn_guild)
  request_event_list(self.pageno, 0)
  return 1
end
function request_event_list(pageno, is_history)
  local from = (pageno - 1) * MAX_ROW
  local to = pageno * MAX_ROW
  if 0 == is_history then
    local total_type, sub_type = get_search_type()
    custom_request_guild_event(from, to, total_type, sub_type)
  elseif 1 == is_history then
    custom_request_old_guild_event(from, to)
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    form.btn_last.Enabled = false
    form.btn_next.Enabled = false
    form.btn_history.Enabled = false
    form.btn_search.Enabled = false
    form.rbtn_guild.Enabled = false
    form.rbtn_capital.Enabled = false
    form.rbtn_member.Enabled = false
    form.lbl_connect.Visible = true
    form.lbl_wait.Visible = true
    timer:Register(3000, 1, nx_current(), "set_btn_enabled", form, -1, -1)
  end
end
function on_recv_event(...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_event_list")
  if not nx_is_valid(form) then
    return
  end
  if form.IsHistory ~= 0 then
    return
  end
  local size = table.getn(arg)
  if size < 2 then
    return
  end
  local from = nx_int(arg[size - 1])
  local to = nx_int(arg[size])
  if from < nx_int(0) then
    form.page_next_ok = 0
    return
  end
  form.page_next_ok = 1
  table.remove(arg)
  table.remove(arg)
  size = table.getn(arg)
  if size <= 0 or size % 3 ~= 0 then
    return 0
  end
  form.pageno = from / MAX_ROW + 1
  form.lbl_page.Text = nx_widestr(form.pageno)
  local rows = size / 3
  if rows > MAX_ROW then
    rows = MAX_ROW
  end
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  for i = 1, rows do
    local base = (i - 1) * 3
    local row = form.textgrid_1:InsertRow(-1)
    form.textgrid_1:SetGridText(row, 0, nx_widestr(transform_date(arg[base + 1])))
    local string_id = nx_string(arg[base + 2])
    local para = util_split_wstring(arg[base + 3], "#")
    for i = 1, table.getn(para) do
      if string.find(nx_string(para[i]), "@:") ~= nil then
        para[i] = guild_util_get_text(string.sub(nx_string(para[i]), 3))
      elseif nx_int(para[i]) > nx_int(0) then
        para[i] = nx_int(para[i])
      else
        para[i] = nx_widestr(para[i])
      end
    end
    local content = nx_widestr(guild_util_get_text(string_id, unpack(para)))
    local gui = nx_value("gui")
    local mlt_text_box = gui:Create("MultiTextBox")
    mlt_text_box.Width = form.textgrid_1:GetColWidth(1)
    mlt_text_box.Height = form.textgrid_1.RowHeight
    local redit_h = mlt_text_box.Height
    local redit_w = mlt_text_box.Width
    mlt_text_box.ViewRect = "1, 6, " .. redit_w - 1 .. ", " .. redit_h
    mlt_text_box.NoFrame = true
    mlt_text_box.ReadOnly = true
    mlt_text_box.Solid = false
    mlt_text_box.BackColor = "0,255,255,255"
    if form.rbtn_guild.Checked then
      mlt_text_box.TextColor = form.rbtn_guild.DataSource
      mlt_text_box.Font = "font_text"
    elseif form.rbtn_capital.Checked then
      mlt_text_box.TextColor = form.rbtn_capital.DataSource
      mlt_text_box.Font = "font_text"
    elseif form.rbtn_member.Checked then
      mlt_text_box.TextColor = form.rbtn_member.DataSource
      mlt_text_box.Font = "font_text"
    end
    mlt_text_box.HtmlText = content
    mlt_text_box.SelectBarColor = "0,0,0,0"
    mlt_text_box.MouseInBarColor = "0,0,0,0"
    form.textgrid_1:SetGridControl(row, 1, mlt_text_box)
  end
  form.textgrid_1:EndUpdate()
end
function on_recv_old_event(from, to, ...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_event_list")
  if not nx_is_valid(form) then
    return
  end
  if form.IsHistory ~= 1 then
    return
  end
  if from < 0 then
    form.page_next_ok = 0
    return
  end
  form.page_next_ok = 1
  local size = table.getn(arg)
  if size <= 0 or size % 4 ~= 0 then
    return 0
  end
  form.pageno = from / MAX_ROW + 1
  form.lbl_page.Text = nx_widestr(form.pageno)
  local rows = size / 4
  if rows > MAX_ROW then
    rows = MAX_ROW
  end
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  for i = 1, rows do
    local base = (i - 1) * 4
    local row = form.textgrid_1:InsertRow(-1)
    form.textgrid_1:SetGridText(row, 0, nx_widestr(transform_date(arg[base + 1])))
    local string_id = nx_string(arg[base + 2])
    local para = util_split_wstring(arg[base + 3], "#")
    local event_level = nx_int(arg[base + 4])
    for i = 1, table.getn(para) do
      if string.find(nx_string(para[i]), "@:") ~= nil then
        para[i] = guild_util_get_text(string.sub(nx_string(para[i]), 3))
      elseif nx_int(para[i]) > nx_int(0) then
        para[i] = nx_int(para[i])
      else
        para[i] = nx_widestr(para[i])
      end
    end
    local content = nx_widestr(guild_util_get_text(string_id, unpack(para)))
    local gui = nx_value("gui")
    local mlt_text_box = gui:Create("MultiTextBox")
    mlt_text_box.Width = form.textgrid_1:GetColWidth(1)
    mlt_text_box.Height = form.textgrid_1.RowHeight
    local redit_h = mlt_text_box.Height
    local redit_w = mlt_text_box.Width
    mlt_text_box.ViewRect = "1, 6, " .. redit_w - 1 .. ", " .. redit_h
    mlt_text_box.NoFrame = true
    mlt_text_box.ReadOnly = true
    mlt_text_box.Solid = false
    mlt_text_box.BackColor = "0,255,255,255"
    if nx_int(event_level) == nx_int(1) then
      mlt_text_box.TextColor = form.rbtn_guild.DataSource
      mlt_text_box.Font = "font_text"
    elseif nx_int(event_level) == nx_int(2) then
      mlt_text_box.TextColor = form.rbtn_capital.DataSource
      mlt_text_box.Font = "font_text"
    elseif nx_int(event_level) == nx_int(3) then
      mlt_text_box.TextColor = form.rbtn_member.DataSource
      mlt_text_box.Font = "font_text"
    end
    mlt_text_box.HtmlText = content
    mlt_text_box.SelectBarColor = "0,0,0,0"
    mlt_text_box.MouseInBarColor = "0,0,0,0"
    form.textgrid_1:SetGridControl(row, 1, mlt_text_box)
  end
  form.textgrid_1:EndUpdate()
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.pageno > 1 then
    request_event_list(form.pageno - 1, form.IsHistory)
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    request_event_list(form.pageno + 1, form.IsHistory)
  end
end
function on_btn_history_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.pageno = 1
  local gui = nx_value("gui")
  if 0 == form.IsHistory then
    form.IsHistory = 1
    local return_text = nx_widestr(gui.TextManager:GetText("ui_return"))
    btn.Text = return_text
    show_old_element(true)
    request_event_list(form.pageno, form.IsHistory)
  elseif 1 == form.IsHistory then
    form.IsHistory = 0
    local log_text = nx_widestr(gui.TextManager:GetText("ui_log"))
    btn.Text = log_text
    show_old_element(false)
    request_event_list(form.pageno, form.IsHistory)
  end
end
function on_main_form_close(self)
end
function set_btn_enabled(form)
  if not nx_is_valid(form) then
    return 0
  end
  form.btn_last.Enabled = true
  form.btn_next.Enabled = true
  form.btn_history.Enabled = true
  form.btn_search.Enabled = true
  form.rbtn_guild.Enabled = true
  form.rbtn_capital.Enabled = true
  form.rbtn_member.Enabled = true
  form.lbl_connect.Visible = false
  form.lbl_wait.Visible = false
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "set_btn_enabled", form)
  end
end
function get_search_type()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local total_type = 0
  local sub_type = 0
  if form.groupbox_guild.Visible then
    total_type = 0
    if form.cbtn_g_important.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_guild_important)
    end
    if form.cbtn_g_build.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_guild_build)
    end
    if form.cbtn_g_battle.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_guild_war)
    end
  elseif form.groupbox_capital.Visible then
    total_type = 1
    if form.cbtn_c_important.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_captial_important)
    end
    if form.cbtn_c_es.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_captial_escort)
    end
    if form.cbtn_c_pay.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_captial_contribute)
    end
  elseif form.groupbox_member.Visible then
    total_type = 2
    if form.cbtn_m_important.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_member_important)
    end
    if form.cbtn_m_battle.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_member_fight)
    end
    if form.cbtn_m_pay.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_member_contribute)
    end
    if form.cbtn_m_change.Checked then
      sub_type = nx_function("ext_bit_bor", sub_type, guild_event_type_member_change)
    end
  end
  return total_type, sub_type
end
function on_rbtn_guild_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_guild.Visible = true
  form.groupbox_capital.Visible = false
  form.groupbox_member.Visible = false
  form.pageno = 1
  form.IsHistory = 0
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  form.textgrid_1:EndUpdate()
  form.cbtn_g_important.Checked = true
  form.cbtn_g_build.Checked = true
  form.cbtn_g_battle.Checked = true
  request_event_list(form.pageno, form.IsHistory)
end
function on_rbtn_capital_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_guild.Visible = false
  form.groupbox_capital.Visible = true
  form.groupbox_member.Visible = false
  form.pageno = 1
  form.IsHistory = 0
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  form.textgrid_1:EndUpdate()
  form.cbtn_c_important.Checked = true
  form.cbtn_c_es.Checked = true
  form.cbtn_c_pay.Checked = true
  request_event_list(form.pageno, form.IsHistory)
end
function on_rbtn_member_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_guild.Visible = false
  form.groupbox_capital.Visible = false
  form.groupbox_member.Visible = true
  form.pageno = 1
  form.IsHistory = 0
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  form.textgrid_1:EndUpdate()
  form.cbtn_m_important.Checked = true
  form.cbtn_m_battle.Checked = true
  form.cbtn_m_pay.Checked = true
  form.cbtn_m_change.Checked = true
  request_event_list(form.pageno, form.IsHistory)
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.pageno = 1
  form.IsHistory = 0
  request_event_list(form.pageno, form.IsHistory)
end
function show_old_element(is_show)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_sub.Visible = not is_show
  if form.rbtn_guild.Checked then
    form.groupbox_guild.Visible = not is_show
  elseif form.rbtn_capital.Checked then
    form.groupbox_capital.Visible = not is_show
  elseif form.rbtn_member.Checked then
    form.groupbox_member.Visible = not is_show
  end
  form.btn_search.Visible = not is_show
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  form.textgrid_1:EndUpdate()
end
