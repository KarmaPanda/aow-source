require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
local FORM_BUILDING_SELECT = "form_stage_main\\form_home\\form_building_select"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  reset_size(form)
  form.gb_model.Left = 1000
  form.building_id = nil
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_levelup_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_home\\form_building_levelup", "open_form", form.building_id)
end
function on_btn_hire_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_home\\form_building_hire", "open_form", form.building_id)
end
function on_btn_select_click(btn)
  local form = btn.ParentForm
  if form.is_active then
    client_to_server_msg(CLIENT_SUB_BUILDING_ACTIVE, nx_string(form.building_id))
  else
    local index = btn.index
    client_to_server_msg(CLIENT_SUB_BUILDING_SELECT, nx_string(form.building_id), nx_int(index) - 1)
  end
  close_form()
end
function open_form_active(building_id)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_SELECT, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.building_id = building_id
  form.is_active = true
  form.gsb_select.IsEditMode = true
  form.gsb_select:DeleteAll()
  local gb_select = create_ctrl("GroupBox", "groupbox_select_" .. nx_string(0), form.gb_model, form.gsb_select)
  if nx_is_valid(gb_select) then
    gb_select.index = nx_int(0)
    local btn = create_ctrl("Button", "btn_select_" .. nx_string(0), form.btn_select, gb_select)
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_select_click")
    btn.index = nx_int(0)
    gb_select.Left = 0
    gb_select.Top = 0
  end
  form.gsb_select.IsEditMode = false
  form.gsb_select:ResetChildrenYPos()
end
function open_form(building_id, ...)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_SELECT, false, false)
  if nx_is_valid(form) then
    return
  end
  form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_SELECT, true, false)
  form:Show()
  form.Visible = true
  form.building_id = building_id
  form.is_active = false
  local arg_count = table.getn(arg)
  local level_max = arg[1]
  local building_type = arg[2]
  form.gsb_select.IsEditMode = true
  form.gsb_select:DeleteAll()
  if nx_int(level_max) > nx_int(1) then
    local gb_levelup = create_ctrl("GroupBox", "groupbox_levelup", form.gb_model, form.gsb_select)
    if nx_is_valid(gb_levelup) then
      local btn = create_ctrl("Button", "btn_levelup", form.btn_select, gb_levelup)
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_levelup_click")
      btn.Text = nx_widestr(util_text("ui_home_building_levelup"))
      gb_levelup.Left = 0
    end
  else
    arg_count = arg_count - 1
  end
  if nx_int(building_type) ~= nx_int(0) then
    local gb_levelup = create_ctrl("GroupBox", "groupbox_hire", form.gb_model, form.gsb_select)
    if nx_is_valid(gb_levelup) then
      local btn = create_ctrl("Button", "btn_hire", form.btn_select, gb_levelup)
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_hire_click")
      btn.Text = nx_widestr(util_text("ui_home_building_hire"))
      gb_levelup.Left = 0
    end
  else
    arg_count = arg_count - 1
  end
  form.Height = form.Height + form.gb_model.Height * (arg_count - 1)
  form.groupbox_1.Height = form.groupbox_1.Height + form.gb_model.Height * (arg_count - 1)
  form.gsb_select.Height = form.gsb_select.Height + form.gb_model.Height * (arg_count - 1)
  reset_size(form)
  for i = 1, table.getn(arg) - 2 do
    local gb_select = create_ctrl("GroupBox", "groupbox_select_" .. nx_string(i), form.gb_model, form.gsb_select)
    if nx_is_valid(gb_select) then
      gb_select.index = nx_int(i)
      local btn = create_ctrl("Button", "btn_select_" .. nx_string(i), form.btn_select, gb_select)
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_select_click")
      btn.index = nx_int(i)
      btn.Text = nx_widestr(util_text(arg[i + 2]))
      gb_select.Left = 0
    end
  end
  form.gsb_select.IsEditMode = false
  form.gsb_select:ResetChildrenYPos()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_SELECT, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function reset_size(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
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
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function a(str)
  nx_msgbox(nx_string(str))
end
