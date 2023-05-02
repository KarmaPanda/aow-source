require("util_gui")
require("util_functions")
local INI_NAME = "ini\\ui\\life\\thd_help.ini"
local FORM_PATH = "form_stage_main\\form_help\\form_help_thd_lead"
function on_main_form_open(self)
  self.Fixed = false
  change_form_size(self)
end
function change_form_size(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  local left = (gui.Width - self.Width) / 2
  local top = (gui.Height - self.Height) / 2
  self.Left = left
  self.Top = top
end
function on_refrsh_form(form, ini, show_id)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(show_id)
  if index < 0 then
    return
  end
  local text_1 = ini:ReadString(index, "r1", "")
  local text_2 = ini:ReadString(index, "r2", "")
  local text_3 = ini:ReadString(index, "r3", "")
  on_clear_form(form)
  local gui = nx_value("gui")
  form.mltbox_1.HtmlText = gui.TextManager:GetText(text_1)
  form.mltbox_2.HtmlText = gui.TextManager:GetText(text_2)
  form.mltbox_3.HtmlText = gui.TextManager:GetText(text_3)
end
function on_clear_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_1:Clear()
  form.mltbox_2:Clear()
  form.mltbox_3:Clear()
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  on_main_form_close(form)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  on_main_form_close(form)
end
function on_is_lead(id)
  local ini = get_ini(INI_NAME)
  if not nx_is_valid(ini) then
    return false
  end
  local index = ini:FindSectionIndex(nx_string(id))
  if index < 0 then
    return false
  end
  return true
end
function open_form(show_id)
  local ini = get_ini(INI_NAME)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string(show_id))
  if index < 0 then
    return
  end
  local form = util_get_form(FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  on_refrsh_form(form, ini, nx_string(show_id))
  form.Visible = true
  form:Show()
end
