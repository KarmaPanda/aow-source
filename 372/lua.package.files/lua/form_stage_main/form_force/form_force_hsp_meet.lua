require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_force\\form_force_hsp_meet"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.Visible = true
  form:Show()
  local gui = nx_value("gui")
  form.textgrid_meet:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_hs_meet_list_1")))
  form.textgrid_meet:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_hs_meet_list_2")))
  form.textgrid_meet:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_hs_meet_list_3")))
  custom_huashan_school(0)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function open_or_hide()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
    return
  end
  if form.Visible then
    form.Visible = false
  else
    form:Show()
    form.Visible = true
    custom_huashan_school(0)
  end
end
function update_meet(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  local meet_info = util_split_wstring(arg[1], ";")
  if table.getn(meet_info) <= 0 then
    return
  end
  form.textgrid_meet:ClearRow()
  for i = 1, table.getn(meet_info) - 1 do
    local player_info = util_split_wstring(meet_info[i], ",")
    local player_name = nx_widestr(player_info[1])
    local player_kill = nx_widestr(player_info[2])
    local row = form.textgrid_meet:InsertRow(-1)
    form.textgrid_meet:SetGridText(row, 0, nx_widestr(i))
    form.textgrid_meet:SetGridText(row, 1, nx_widestr(player_name))
    form.textgrid_meet:SetGridText(row, 2, nx_widestr(player_kill))
  end
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
