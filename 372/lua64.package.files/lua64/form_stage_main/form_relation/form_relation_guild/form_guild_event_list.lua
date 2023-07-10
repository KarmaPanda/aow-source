require("custom_sender")
require("util_functions")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
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
  self.lbl_connect.Visible = false
  self.lbl_wait.Visible = false
  request_event_list(self.pageno, 0)
  return 1
end
function request_event_list(pageno, is_history)
  local from = (pageno - 1) * 10
  local to = pageno * 10
  if 0 == is_history then
    custom_request_guild_event(from, to, 0)
  elseif 1 == is_history then
    custom_request_guild_event(from, to, 1)
  end
end
function on_recv_event(from, to, ...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_event_list")
  if not nx_is_valid(form) then
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
  form.pageno = from / 10 + 1
  form.lbl_page.Text = nx_widestr(form.pageno)
  local rows = size / 4
  if 10 < rows then
    rows = 10
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
      mlt_text_box.TextColor = "255,255,0,0"
      mlt_text_box.Font = "font_text_title1"
    elseif nx_int(event_level) == nx_int(2) then
      mlt_text_box.TextColor = "255,0,0,255"
      mlt_text_box.Font = "font_text"
    elseif nx_int(event_level) == nx_int(3) then
      mlt_text_box.TextColor = "255,95,67,37"
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
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      form.btn_last.Enabled = false
      form.btn_next.Enabled = false
      form.btn_history.Enabled = false
      form.lbl_wait.Visible = true
      form.lbl_connect.Visible = true
      timer:Register(3000, 1, nx_current(), "set_btn_enabled", form, -1, -1)
    end
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    request_event_list(form.pageno + 1, form.IsHistory)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      form.btn_last.Enabled = false
      form.btn_next.Enabled = false
      form.btn_history.Enabled = false
      form.lbl_wait.Visible = true
      form.lbl_connect.Visible = true
      timer:Register(3000, 1, nx_current(), "set_btn_enabled", form, -1, -1)
    end
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
    request_event_list(form.pageno, 1)
    form.IsHistory = 1
    local return_text = nx_widestr(gui.TextManager:GetText("ui_return"))
    btn.Text = return_text
  elseif 1 == form.IsHistory then
    request_event_list(form.pageno, 0)
    form.IsHistory = 0
    local log_text = nx_widestr(gui.TextManager:GetText("ui_log"))
    btn.Text = log_text
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    form.btn_last.Enabled = false
    form.btn_next.Enabled = false
    form.btn_history.Enabled = false
    form.lbl_wait.Visible = true
    form.lbl_connect.Visible = true
    timer:Register(3000, 1, nx_current(), "set_btn_enabled", form, -1, -1)
  end
end
function on_btn_guild_area_click(btn)
  nx_execute("form_stage_main\\form_guild_domain\\form_guild_domain_map", "open_form_for_browse")
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
  form.lbl_wait.Visible = false
  form.lbl_connect.Visible = false
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "set_btn_enabled", form)
  end
end
