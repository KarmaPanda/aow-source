require("util_gui")
require("util_functions")
require("const_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  local wstr = util_format_string("ui_revise_exit_tips", nx_int(self.count))
  self.mltbox_info:Clear()
  self.mltbox_info:AddHtmlText(wstr, nx_int(-1))
  return 1
end
function main_form_close(self)
  nx_destroy(self)
end
function show_revise_exit_time_form(count)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_name_modify_endtime", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.count = count
  form:Show()
  init_timer(form)
end
function init_timer(form)
  local timer = nx_value("timer_game")
  timer:UnRegister("form_stage_main\\form_name_modify_endtime", "on_update_time", form)
  local res = timer:Register(1000, -1, "form_stage_main\\form_name_modify_endtime", "on_update_time", form, -1, -1)
end
function on_update_time(form)
  form.count = form.count - 1
  if form.count > 0 then
    form.mltbox_info:Clear()
    local wstr = util_format_string("ui_revise_exit_tips", nx_int(form.count))
    form.mltbox_info:AddHtmlText(wstr, nx_int(-1))
  else
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "on_update_time", form)
    form:Close()
  end
end
