require("util_functions")
require("util_gui")
local FORM_MAIN = "form_stage_main\\form_shijia\\form_play_time"
function open_form()
  local form = nx_execute("util_gui", "util_auto_show_hide_form", FORM_MAIN)
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
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_shijia_play_time(...)
  local form = util_get_form(FORM_MAIN, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visable = true
  form:Show()
  local count = table.getn(arg)
  if count < 1 then
    return
  end
  local best_time64 = arg[1]
  local convert_time64 = arg[2]
  if nx_int64(convert_time64) <= nx_int64(0) or nx_int64(best_time64) <= nx_int64(0) then
    return false
  end
  local best_cost_time = convert_time_type(best_time64)
  form.lbl_best_hour.Text = nx_widestr(best_cost_time.hour)
  form.lbl_best_min.Text = nx_widestr(best_cost_time.min)
  form.lbl_best_second.Text = nx_widestr(best_cost_time.sec)
  local new_cost_time = convert_time_type(convert_time64)
  form.lbl_current_hour.Text = nx_widestr(new_cost_time.hour)
  form.lbl_current_min.Text = nx_widestr(new_cost_time.min)
  form.lbl_current_second.Text = nx_widestr(new_cost_time.sec)
end
function convert_time_type(current_time64)
  if not current_time64 then
    return
  end
  if nx_int64(current_time64) <= nx_int64(0) then
    return false
  end
  local year, month, day, hour, mins, sec = nx_function("ext_decode_time64_to_date", current_time64)
  local time_table = {
    hour = hour,
    min = mins,
    sec = sec
  }
  return time_table
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
