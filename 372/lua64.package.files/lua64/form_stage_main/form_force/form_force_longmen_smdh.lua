require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_force\\form_force_longmen_smdh"
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
  form.rbtn_con.Checked = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_rbtn_con_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_con.Visible = true
    form.groupbox_damage.Visible = false
    form.groupbox_member.Visible = false
    nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 15, 1, 50)
  end
end
function on_rbtn_damage_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_con.Visible = false
    form.groupbox_damage.Visible = true
    form.groupbox_member.Visible = false
    nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 16)
  end
end
function on_rbtn_member_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_con.Visible = false
    form.groupbox_damage.Visible = false
    form.groupbox_member.Visible = true
    nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 19)
  end
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local gui = nx_value("gui")
  form.textgrid_con:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_bo_con_list_0")))
  form.textgrid_con:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_bo_con_list_1")))
  form.textgrid_con:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_bo_con_list_2")))
  form.textgrid_con:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_bo_con_list_3")))
  form.textgrid_damage:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_bo_challenge_list_0")))
  form.textgrid_damage:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_bo_challenge_list_1")))
  form.textgrid_damage:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_bo_challenge_list_2")))
  form.textgrid_damage:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_bo_challenge_list_3")))
  form.textgrid_member:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_bo_member_list_0")))
  form.textgrid_member:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_bo_member_list_1")))
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function update_con_list(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_con:ClearRow()
  form.textgrid_my_con:ClearRow()
  local row = form.textgrid_my_con:InsertRow(-1)
  if nx_int(arg[1]) == nx_int(0) then
    form.textgrid_my_con:SetGridText(row, 0, nx_widestr("--"))
    form.textgrid_my_con:SetGridText(row, 1, nx_widestr("--"))
    form.textgrid_my_con:SetGridText(row, 2, nx_widestr("--"))
    form.textgrid_my_con:SetGridText(row, 3, nx_widestr("--"))
  else
    form.textgrid_my_con:SetGridText(row, 0, nx_widestr(arg[1]))
    form.textgrid_my_con:SetGridText(row, 1, nx_widestr(arg[2]))
    form.textgrid_my_con:SetGridText(row, 2, nx_widestr(arg[3]))
    form.textgrid_my_con:SetGridText(row, 3, nx_widestr(arg[4]))
  end
  for i = 1, table.getn(arg) / 4 - 1 do
    local row = form.textgrid_con:InsertRow(-1)
    form.textgrid_con:SetGridText(row, 0, nx_widestr(arg[i * 4 + 1]))
    form.textgrid_con:SetGridText(row, 1, nx_widestr(arg[i * 4 + 2]))
    form.textgrid_con:SetGridText(row, 2, nx_widestr(arg[i * 4 + 3]))
    form.textgrid_con:SetGridText(row, 3, nx_widestr(arg[i * 4 + 4]))
  end
end
function update_damage_list(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_damage:ClearRow()
  for i = 0, table.getn(arg) / 4 - 1 do
    local row = form.textgrid_damage:InsertRow(-1)
    form.textgrid_damage:SetGridText(row, 0, nx_widestr(arg[i * 4 + 1]))
    form.textgrid_damage:SetGridText(row, 1, nx_widestr(arg[i * 4 + 2]))
    if nx_widestr(nx_widestr(arg[i * 4 + 3])) == nx_widestr("") then
      form.textgrid_damage:SetGridText(row, 2, nx_widestr(util_text("ui_cf_bdjs")))
    else
      form.textgrid_damage:SetGridText(row, 2, nx_widestr(arg[i * 4 + 3]))
    end
    local time = nx_number(arg[i * 4 + 4])
    local time_minute = nx_int(time / 60)
    local time_second = math.fmod(time, 60)
    local time_text = nx_widestr("")
    if nx_int(time_minute) < nx_int(10) then
      time_text = time_text .. nx_widestr("0")
    end
    time_text = time_text .. nx_widestr(time_minute) .. nx_widestr(":")
    if nx_int(time_second) < nx_int(10) then
      time_text = time_text .. nx_widestr("0")
    end
    time_text = time_text .. nx_widestr(time_second)
    form.textgrid_damage:SetGridText(row, 3, nx_widestr(time_text))
  end
end
function update_member_info(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_team.Text = nx_widestr(arg[1])
  form.textgrid_member:ClearRow()
  local con = nx_int(0)
  for i = 0, (table.getn(arg) - 1) / 2 - 1 do
    local row = form.textgrid_member:InsertRow(-1)
    form.textgrid_member:SetGridText(row, 0, nx_widestr(arg[i * 2 + 2]))
    form.textgrid_member:SetGridText(row, 1, nx_widestr(arg[i * 2 + 3]))
    con = con + nx_int(arg[i * 2 + 3])
  end
  form.lbl_con.Text = nx_widestr(con)
end
