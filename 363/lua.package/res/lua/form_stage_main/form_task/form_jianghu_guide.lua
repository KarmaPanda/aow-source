require("util_gui")
require("util_functions")
local FORM_PATH = "form_stage_main\\form_task\\form_jianghu_guide"
local LOAD_INI = "ini\\new_helper\\jh_helper.ini"
function open_form(helper_id)
  local ini = get_ini(LOAD_INI, true)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string(helper_id))
  if index < 0 then
    return
  end
  local form = util_get_form(FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  local name = ini:ReadString(index, "name", "")
  local text = ini:ReadString(index, "text", "")
  local image = ini:ReadString(index, "image", "")
  if name == "" or text == "" or image == "" then
    form:Close()
    return
  end
  local gui = nx_value("gui")
  form.lbl_name.Text = gui.TextManager:GetText(name)
  form.mltbox_text.HtmlText = gui.TextManager:GetText(text)
  form.lbl_tip.BackImage = image
  form.Visible = true
  form:Show()
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end