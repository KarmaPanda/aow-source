require("util_gui")
require("share\\client_custom_define")
local FORM_NAME = "form_stage_main\\form_skyhill\\form_sanhill_ready"
local CLOSE_SEC = 30
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 5
end
function on_main_form_close(form)
  if nx_running(nx_current(), "delay_close") then
    nx_kill(nx_current(), "delay_close")
  end
  nx_destroy(form)
end
function open_form(...)
  local form = util_get_form(FORM_NAME, true)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.remain_sec = arg[1]
  if nx_running(nx_current(), "delay_close") then
    nx_kill(nx_current(), "delay_close")
  end
  nx_execute(nx_current(), "delay_close", form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_sanhill_msg", 11)
  form:Close()
end
function delay_close(form)
  while nx_is_valid(form) do
    if not nx_find_custom(form, "remain_sec") then
      form.remain_sec = CLOSE_SEC
    end
    form.remain_sec = form.remain_sec - 1
    if form.remain_sec < 0 then
      form:Close()
      return
    end
    form.lbl_3.Text = nx_widestr(form.remain_sec)
    nx_pause(1)
  end
end
