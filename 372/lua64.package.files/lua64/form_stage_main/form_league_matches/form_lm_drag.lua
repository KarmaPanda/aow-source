require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_league_matches\\form_lm_drag"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  custom_league_matches(10)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_lm_drag(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local player_side = nx_number(arg[1])
  local rows_fight = nx_number(arg[2])
  local tab_fight = {}
  for i = 1, rows_fight do
    local member_info = nx_widestr(arg[i + 2])
    local tab_member_info = util_split_wstring(member_info, ",")
    local member_name = tab_member_info[1]
    local level_title = nx_string(tab_member_info[2])
    table.insert(tab_fight, {member_name, level_title})
  end
  local tab_see = {}
  local rows_see = nx_number(arg[2 + rows_fight + 1])
  for i = 1, rows_see do
    local member_info = nx_widestr(arg[3 + rows_fight + i])
    local tab_member_info = util_split_wstring(member_info, ",")
    local member_name = tab_member_info[1]
    local level_title = nx_string(tab_member_info[2])
    local forbid = nx_number(tab_member_info[3])
    table.insert(tab_see, {
      member_name,
      level_title,
      forbid
    })
  end
  table.sort(tab_fight, function(a, b)
    return a[2] > b[2]
  end)
  table.sort(tab_see, function(a, b)
    return a[2] > b[2]
  end)
  form.tg_fight:ClearSelect()
  form.tg_fight:ClearRow()
  for i = 1, table.getn(tab_fight) do
    local member_name = tab_fight[i][1]
    local level_title = tab_fight[i][2]
    local row = form.tg_fight:InsertRow(-1)
    local gb = create_ctrl("GroupBox", "gb_fight_" .. nx_string(i), form.gb_mod, nil)
    local cbtn = create_ctrl("CheckButton", "cbtn_fight_" .. nx_string(i), form.cbtn_mod, gb)
    gb.cbtn_mod = cbtn
    cbtn.member_name = member_name
    form.tg_fight:SetGridControl(row, 0, gb)
    form.tg_fight:SetGridText(row, 1, member_name)
    form.tg_fight:SetGridText(row, 2, nx_widestr(util_text("desc_" .. level_title)))
  end
  form.tg_see:ClearSelect()
  form.tg_see:ClearRow()
  for i = 1, table.getn(tab_see) do
    local member_name = tab_see[i][1]
    local level_title = tab_see[i][2]
    local forbid = tab_see[i][3]
    local row = form.tg_see:InsertRow(-1)
    local gb = create_ctrl("GroupBox", "gb_see_" .. nx_string(i), form.gb_mod, nil)
    local cbtn = create_ctrl("CheckButton", "cbtn_see_" .. nx_string(i), form.cbtn_mod, gb)
    gb.cbtn_mod = cbtn
    cbtn.member_name = member_name
    form.tg_see:SetGridControl(row, 0, gb)
    form.tg_see:SetGridText(row, 1, member_name)
    form.tg_see:SetGridText(row, 2, nx_widestr(util_text("desc_" .. level_title)))
    if 1 == forbid then
      cbtn.Enabled = false
      form.tg_see:SetGridForeColor(row, 0, "255,255,0,0")
      form.tg_see:SetGridForeColor(row, 1, "255,255,0,0")
      form.tg_see:SetGridForeColor(row, 2, "255,255,0,0")
    end
  end
end
function on_lm_drag_confirm()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  if confirm_dialog(nx_widestr(util_text("ui_lm_drag_to_see_confirm"))) then
    custom_league_matches(12)
  end
end
function on_btn_drag_to_see_click(btn)
  local form = btn.ParentForm
  local member_info = ""
  for i = 0, form.tg_fight.RowCount - 1 do
    local gb = form.tg_fight:GetGridControl(i, 0)
    local cbtn = gb.cbtn_mod
    local member_name = cbtn.member_name
    if member_name ~= "" and cbtn.Checked then
      member_info = member_info .. nx_string(member_name) .. ","
    end
  end
  if member_info == "" then
    return
  end
  custom_league_matches(4, nx_widestr(member_info))
end
function on_btn_drag_to_fight_click(btn)
  local form = btn.ParentForm
  local member_info = ""
  for i = 0, form.tg_see.RowCount - 1 do
    local gb = form.tg_see:GetGridControl(i, 0)
    local cbtn = gb.cbtn_mod
    local member_name = cbtn.member_name
    if member_name ~= "" and cbtn.Checked then
      member_info = member_info .. nx_string(member_name) .. ","
    end
  end
  if member_info == "" then
    return
  end
  custom_league_matches(3, nx_widestr(member_info))
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(refer_ctrl.ParentForm, name, ctrl)
  ctrl.Name = name
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function a(info)
  nx_msgbox(nx_string(info))
end
function confirm_dialog(text)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
end
