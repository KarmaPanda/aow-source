require("util_gui")
local form_regulations_helper = "form_stage_main\\form_helper\\form_regulations_helper"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function util_open_more_form(parent_form)
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, true)
  if not nx_is_valid(form) then
    return 0
  end
  if not form.Visible then
    form.Visible = true
    form:Show()
  end
  parent_form.mltbox_more = form.mltbox_more
  parent_form.btn_close_more = form.btn_close_more
  parent_form.groupbox_more = form
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.groupbox_more.Visible = true
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
end
function on_mltbox_more_select_item_change(self, newitemindex)
  nx_execute(form_regulations_helper, "on_mltbox_select_item_change", self, newitemindex)
end
function on_btn_close_more_click(self)
  local form = self.ParentForm
  form.Visible = false
  return 0
end
