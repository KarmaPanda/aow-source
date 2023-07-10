require("util_functions")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function open_form(...)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_task\\form_subtask_info")
  local form = util_get_form("form_stage_main\\form_task\\form_subtask_info", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.mltbox_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(arg[1])), -1)
end
