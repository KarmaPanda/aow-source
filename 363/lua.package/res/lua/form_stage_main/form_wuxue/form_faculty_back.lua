require("util_gui")
function main_form_init(self)
  self.Fixed = false
  self.name = ""
end
function on_main_form_open(form)
  change_form_size()
  local form_main = util_get_form(form.name, false, false)
  if nx_is_valid(form_main) then
    local gui = nx_value("gui")
    gui.Desktop:ToBack(form)
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local form_main = util_get_form(form.name, false, false)
  if nx_is_valid(form_main) then
    form_main:Close()
  end
  nx_destroy(form)
end
function change_form_size()
  local form = util_get_form("form_stage_main\\form_wuxue\\form_faculty_back", false, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.lbl_back.Width = form.Width
  form.lbl_back.Height = form.Height
end
