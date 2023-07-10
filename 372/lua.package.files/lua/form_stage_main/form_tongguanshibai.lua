require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_tongguanshibai"
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Width = gui.Width
    form.Height = gui.Height
    form.groupbox_1.Width = gui.Width
    form.groupbox_1.Height = gui.Height
    form.Left = 0
    form.Top = 0
  end
  form.Visible = true
  form:Show()
end
function close_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
end
function change_form_size_change()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Width = gui.Width
    form.Height = gui.Height
    form.groupbox_1.Width = gui.Width
    form.groupbox_1.Height = gui.Height
    form.Left = 0
    form.Top = 0
  end
  if not nx_is_valid(form) then
    return
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Width = gui.Width
    form.Height = gui.Height
    form.groupbox_1.Width = gui.Width
    form.groupbox_1.Height = gui.Height
    form.Left = 0
    form.Top = 0
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_count_down", form)
  end
  nx_destroy(form)
end
function on_btn_close_click()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
end
