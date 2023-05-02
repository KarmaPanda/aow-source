require("util_gui")
require("util_functions")
local FORM_MAIN_PIKONGZHANG_DESC = "form_stage_main\\form_main\\form_main_pikongzhang_desc"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  on_size_change()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_size_change()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = nx_value(FORM_MAIN_PIKONGZHANG_DESC)
  if nx_is_valid(form) then
    form.AbsTop = (gui.Desktop.Height - form.Height) / 2
    form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function show_form()
  local form = util_get_form(FORM_MAIN_PIKONGZHANG_DESC, false)
  if nx_is_valid(form) then
    form:Close()
  else
    local form = util_get_form(FORM_MAIN_PIKONGZHANG_DESC, true, false)
    if not nx_is_valid(form) then
      return 0
    end
    util_show_form(FORM_MAIN_PIKONGZHANG_DESC, true)
  end
end
