require("util_gui")
local FORM_NAME = "form_stage_main\\form_ver_201904\\form_event_task"
function form_main_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.lbl_1.Visible = false
  form.lbl_2.Visible = false
  form.lbl_3.Visible = false
  form.lbl_4.Visible = false
  on_gui_size_change()
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_delay_close", form)
  nx_destroy(form)
end
function on_gui_size_change()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return 1
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = gui.Width - form.Width - 150
    form.Top = 150
  end
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_update(index, right)
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.lbl_1.Visible = false
  form.lbl_2.Visible = false
  form.lbl_3.Visible = false
  form.lbl_4.Visible = false
  for i = nx_number(index) + 1, nx_number(index) + nx_number(right) do
    local cur_i = math.mod(i - 1, 4) + 1
    local lbl = form.groupbox_1:Find("lbl_" .. nx_string(cur_i))
    if nx_is_valid(lbl) then
      lbl.Visible = true
    end
  end
end
function on_compete(index, right)
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.lbl_1.Visible = true
  form.lbl_2.Visible = true
  form.lbl_3.Visible = true
  form.lbl_4.Visible = true
  local timer = nx_value("timer_game")
  timer:Register(1000, 1, nx_current(), "on_delay_close", form, -1, -1)
end
function on_open()
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true, false)
    if not nx_is_valid(form) then
      return
    end
    form.Visible = true
    form:Show()
  end
end
function on_delay_close(form)
  close_form()
end
