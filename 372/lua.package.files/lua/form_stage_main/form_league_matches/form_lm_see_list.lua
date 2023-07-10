require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_league_matches\\form_lm_see_list"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  custom_league_matches(11)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function open_or_hide()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
  else
    form:Close()
  end
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
function on_lm_see_list(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local player_side = nx_number(arg[1])
  local target_name = nx_widestr(arg[2])
  local fight_rows = nx_number(arg[3])
  form.tg_see_list:ClearSelect()
  form.tg_see_list:ClearRow()
  for i = 1, fight_rows do
    local see_name = nx_widestr(arg[3 + i])
    local row = form.tg_see_list:InsertRow(-1)
    form.tg_see_list:SetGridText(row, 0, see_name)
    if target_name ~= see_name then
      local gb = create_ctrl("GroupBox", "gb_see_list_" .. nx_string(i), form.gb_mod, nil)
      local btn = create_ctrl("Button", "btn_see_list_" .. nx_string(i), form.btn_mod_see, gb)
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_see_list_click")
      btn.target_name = see_name
      form.tg_see_list:SetGridControl(row, 1, gb)
    end
  end
end
function on_btn_see_list_click(btn)
  custom_league_matches(5, btn.target_name)
  close_form()
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
