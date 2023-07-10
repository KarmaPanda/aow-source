require("util_functions")
require("custom_sender")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
function main_form_init(self)
  self.Fixed = true
  self.pageno = 1
  self.page_next_ok = 1
end
function on_main_form_open(form)
  local width = form.textgrid_1.Width
  form.textgrid_1:SetColWidth(0, width / 5 - 1)
  form.textgrid_1:SetColWidth(1, width / 5 - 1)
  form.textgrid_1:SetColWidth(2, width / 5 - 1)
  form.textgrid_1:SetColWidth(3, width / 5 - 1)
  form.textgrid_1:SetColWidth(4, width / 5 - 1)
  form.textgrid_1:SetColTitle(0, nx_widestr(util_text("ui_guild_player_name")))
  form.textgrid_1:SetColTitle(1, nx_widestr(util_text("ui_guild_school")))
  form.textgrid_1:SetColTitle(2, nx_widestr(util_text("ui_guild_power")))
  form.textgrid_1:SetColTitle(3, nx_widestr(util_text("ui_guild_request_date")))
  form.textgrid_1:SetColTitle(4, nx_widestr(util_text("ui_guild_last_online")))
  request_candidate_list(form.pageno)
  nx_set_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_candidate", form)
end
function on_main_form_close(form)
  form.Visible = false
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if form.pageno > 1 then
    request_candidate_list(form.pageno - 1)
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    request_candidate_list(form.pageno + 1)
  end
end
function request_candidate_list(pageno)
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  custom_request_guild_candidate(from, to)
end
function on_recv_candidate(from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_candidate")
  if not nx_is_valid(form) then
    return 0
  end
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  form.textgrid_1:EndUpdate()
  if from < 0 then
    form.page_next_ok = 0
    form.lbl_pageno.Text = nx_widestr("0/0")
    return
  end
  if to >= rowcount - 1 then
    form.page_next_ok = 0
  else
    form.page_next_ok = 1
  end
  local size = table.getn(arg)
  if size < 0 or size % 6 ~= 0 then
    return 0
  end
  form.pageno = from / 10 + 1
  local nowpage = nx_string(form.pageno)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / 10))
  form.lbl_pageno.Text = nx_widestr(nowpage .. maxpage)
  local rows = size / 6
  if 10 < rows then
    rows = 10
  end
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  for i = 1, rows do
    local base = (i - 1) * 6
    local row = form.textgrid_1:InsertRow(-1)
    form.textgrid_1:SetGridText(row, 0, nx_widestr(arg[base + 1]))
    form.textgrid_1:SetGridText(row, 1, nx_widestr(util_text(arg[base + 2])))
    form.textgrid_1:SetGridText(row, 2, nx_widestr(util_text("desc_" .. arg[base + 3])))
    form.textgrid_1:SetGridText(row, 3, nx_widestr(transform_date(arg[base + 5])))
    form.textgrid_1:SetGridText(row, 4, nx_widestr(transform_date(arg[base + 6])))
    local state = nx_int(arg[base + 4])
    if state == nx_int(0) then
      form.textgrid_1:SetGridForeColor(row, 0, "255,160,160,160")
      form.textgrid_1:SetGridForeColor(row, 1, "255,160,160,160")
      form.textgrid_1:SetGridForeColor(row, 2, "255,160,160,160")
      form.textgrid_1:SetGridForeColor(row, 3, "255,160,160,160")
      form.textgrid_1:SetGridForeColor(row, 4, "255,160,160,160")
    end
  end
  form.textgrid_1:EndUpdate()
end
function on_btn_accept_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local player_name = form.textgrid_1:GetGridText(form.textgrid_1.RowSelectIndex, 0)
  custom_request_accept_guild_member(player_name)
end
function on_btn_reject_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local player_name = form.textgrid_1:GetGridText(form.textgrid_1.RowSelectIndex, 0)
  if nx_string(player_name) ~= "" then
    custom_request_reject_guild_member(player_name)
  end
end
function on_refresh_candidate()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_candidate")
  if not nx_is_valid(form) then
    return 0
  end
  request_candidate_list(form.pageno)
end
